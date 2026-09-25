// Keyhold without the app on this computer: the vault comes from the user's
// own Google Drive and opens with the master password, inside the extension.
// It answers the same questions the app answers over 127.0.0.1.
const Standalone = (() => {
  const ext = globalThis.browser ?? chrome;
  const t = (key, ...subs) => ext.i18n.getMessage(key, subs);
  const local = ext.storage.local;
  const session = ext.storage.session;

  // "Web application" client of the Keyhold Google project; not a secret.
  const GOOGLE_CLIENT_ID = '95881372863-ajkuag5vst7l6re7c7cvj000j4dq4gcn.apps.googleusercontent.com';
  const SCOPE = 'https://www.googleapis.com/auth/drive.file';
  // Every vault has a file of its own in the "Keyhold" folder; the master
  // password says which one is the user's.
  const VAULT_NAME = /^vault(-[0-9a-f]{8})?\.khd$/;
  const MAGIC = [0x4b, 0x48, 0x4c, 0x44, 0x31];
  const OFFER_TIME = 2 * 60 * 1000;
  const FAILED_TIME = 30 * 1000;
  const PULL_EVERY = 5 * 60 * 1000;

  // ---------- bytes ----------

  const toB64 = (bytes) => {
    let text = '';
    for (let i = 0; i < bytes.length; i += 0x8000) text += String.fromCharCode(...bytes.subarray(i, i + 0x8000));
    return btoa(text);
  };
  const fromB64 = (text) => Uint8Array.from(atob(text), (c) => c.charCodeAt(0));
  const concat = (...parts) => {
    const out = new Uint8Array(parts.reduce((n, p) => n + p.length, 0));
    let at = 0;
    for (const p of parts) {
      out.set(p, at);
      at += p.length;
    }
    return out;
  };
  const randomId = () => [...crypto.getRandomValues(new Uint8Array(16))].map((b) => b.toString(16).padStart(2, '0')).join('');

  // ---------- the vault file: "KHLD1", flag, salt, wrapped key, then the sealed JSON ----------

  function parse(bytes) {
    const magic = MAGIC.every((b, i) => bytes[i] === b);
    if (!magic) return { header: new Uint8Array(0), payload: bytes };
    let at = MAGIC.length;
    const flag = bytes[at++];
    let salt = null;
    let wrapped = null;
    // Bit 1: the key sealed by the master password; bit 2: by the recovery code.
    if (flag & 1) {
      salt = bytes.slice(at, at + 16);
      at += 16;
      const length = (bytes[at] << 8) | bytes[at + 1];
      at += 2;
      wrapped = bytes.slice(at, at + length);
      at += length;
    }
    if (flag & 2) {
      const length = (bytes[at] << 8) | bytes[at + 1];
      at += 2 + length;
    }
    return { header: bytes.slice(0, at), salt, wrapped, payload: bytes.slice(at) };
  }

  // AES-256-GCM as the app does it: 12-byte nonce, then ciphertext with its tag.
  async function open(keyBytes, blob) {
    const key = await crypto.subtle.importKey('raw', keyBytes, 'AES-GCM', false, ['decrypt']);
    return new Uint8Array(await crypto.subtle.decrypt({ name: 'AES-GCM', iv: blob.slice(0, 12) }, key, blob.slice(12)));
  }

  async function seal(keyBytes, plain) {
    const key = await crypto.subtle.importKey('raw', keyBytes, 'AES-GCM', false, ['encrypt']);
    const iv = crypto.getRandomValues(new Uint8Array(12));
    return concat(iv, new Uint8Array(await crypto.subtle.encrypt({ name: 'AES-GCM', iv }, key, plain)));
  }

  // The master password opens the vault key: Argon2id with the app's settings.
  async function unwrap(password, salt, wrapped) {
    const kek = await globalThis.hashwasm.argon2id({
      password,
      salt,
      parallelism: 4,
      iterations: 3,
      memorySize: 64 * 1024,
      hashLength: 32,
      outputType: 'binary',
    });
    return open(kek, wrapped);
  }

  // ---------- Google Drive ----------

  // Google no longer signs in without asking: the user's own action may bring its window up.
  const signInError = (text) => Object.assign(new Error(text), { signIn: true });

  async function token(interactive) {
    const { driveToken } = await session.get('driveToken');
    if (driveToken && driveToken.until > Date.now() + 60 * 1000) return driveToken.token;

    const { driveEmail } = await local.get('driveEmail');
    const query = {
      client_id: GOOGLE_CLIENT_ID,
      response_type: 'token',
      redirect_uri: ext.identity.getRedirectURL(),
      scope: SCOPE,
    };
    if (!interactive) query.prompt = 'none';
    if (driveEmail) query.login_hint = driveEmail;
    let back;
    try {
      back = await ext.identity.launchWebAuthFlow({
        url: `https://accounts.google.com/o/oauth2/v2/auth?${new URLSearchParams(query)}`,
        interactive,
      });
    } catch (e) {
      throw signInError(e.message || t('googleDidNotSignIn'));
    }
    const answer = new URLSearchParams(new URL(back).hash.slice(1));
    const value = answer.get('access_token');
    if (!value) throw signInError(answer.get('error') || t('googleDidNotSignIn'));
    await session.set({
      driveToken: { token: value, until: Date.now() + Number(answer.get('expires_in') || 3600) * 1000 },
    });
    return value;
  }

  async function drive(url, init = {}, interactive = false) {
    const send = async () =>
      fetch(url, {
        ...init,
        headers: { ...(init.headers || {}), Authorization: `Bearer ${await token(interactive)}` },
      });
    let response = await send();
    if (response.status === 401) {
      // A token Google no longer takes: once more with a fresh one.
      await session.remove('driveToken');
      response = await send();
    }
    if (!response.ok) throw new Error(t('driveAnswered', String(response.status)));
    return response;
  }

  // The account signed in, so a silent renewal later asks Google for this very one.
  async function rememberAccount() {
    try {
      const about = await (await drive('https://www.googleapis.com/drive/v3/about?fields=user(emailAddress)')).json();
      if (about.user && about.user.emailAddress) await local.set({ driveEmail: about.user.emailAddress });
    } catch (e) {
      // the renewal then goes without the hint
    }
  }

  // Something the user just did: when the silent sign-in no longer works,
  // Google's window comes up once instead of the change being lost.
  async function signedIn(job) {
    try {
      return await job();
    } catch (e) {
      if (!e.signIn) throw e;
      await session.remove('driveToken');
      await token(true);
      await rememberAccount();
      return job();
    }
  }

  async function revision(id) {
    return (await (await drive(`https://www.googleapis.com/drive/v3/files/${id}?fields=version`)).json()).version;
  }

  async function vaultFiles(interactive) {
    const query = new URLSearchParams({
      q: "name contains 'vault' and trashed = false and mimeType != 'application/vnd.google-apps.folder'",
      orderBy: 'modifiedTime desc',
      fields: 'files(id,name)',
      pageSize: '200',
    });
    const { files } = await (await drive(`https://www.googleapis.com/drive/v3/files?${query}`, {}, interactive)).json();
    return (files || []).filter((f) => VAULT_NAME.test(f.name));
  }

  async function fetchFile(id) {
    const response = await drive(`https://www.googleapis.com/drive/v3/files/${id}?alt=media`);
    return new Uint8Array(await response.arrayBuffer());
  }

  // The file of the vault opened here.
  async function download() {
    const { driveFile } = await local.get('driveFile');
    if (!driveFile) throw new Error(t('noVaultInDrive'));
    const bytes = await fetchFile(driveFile);
    await local.set({ vaultFile: toB64(bytes), pulledAt: Date.now() });
    return bytes;
  }

  async function upload(bytes) {
    const { driveFile: id } = await local.get('driveFile');
    await drive(`https://www.googleapis.com/upload/drive/v3/files/${id}?uploadType=media`, {
      method: 'PATCH',
      headers: { 'content-type': 'application/octet-stream' },
      body: bytes,
    });
    await local.set({ vaultFile: toB64(bytes), pulledAt: Date.now() });
  }

  // ---------- the open vault ----------

  let loaded = null;

  // The vault opened here closes by itself after half an hour without use.
  const IDLE_LOCK = 30 * 60 * 1000;

  async function vault() {
    const { dek, usedAt } = await session.get(['dek', 'usedAt']);
    if (dek && usedAt && Date.now() - usedAt > IDLE_LOCK) {
      loaded = null;
      await session.remove(['dek', 'aloneOffers', 'usedAt']);
      return null;
    }
    if (dek && (!usedAt || Date.now() - usedAt > 60 * 1000)) await session.set({ usedAt: Date.now() });
    if (loaded) return loaded;
    const { vaultFile } = await local.get('vaultFile');
    if (!dek || !vaultFile) return null;
    const parts = parse(fromB64(vaultFile));
    loaded = JSON.parse(new TextDecoder().decode(await open(fromB64(dek), parts.payload)));
    return loaded;
  }

  // Every write and pull of the vault file, one after another: two at once
  // would start from the same copy, and one of the changes would be lost.
  let queue = Promise.resolve();
  const serial = (job) => {
    const run = queue.then(() => job(), () => job());
    queue = run.catch(() => {});
    return run;
  };

  // Newer copy from Drive every few minutes, without holding anything up.
  async function pullSoon() {
    const { pulledAt } = await local.get('pulledAt');
    if (pulledAt && Date.now() - pulledAt < PULL_EVERY) return;
    await local.set({ pulledAt: Date.now() });
    serial(download)
      .then(() => (loaded = null))
      .catch(() => {});
  }

  // The newest copy from Drive for a page about to change an entry; offline, the one kept here.
  async function fresh(data) {
    try {
      await serial(download);
      loaded = null;
      return (await vault()) || data;
    } catch (e) {
      return data;
    }
  }

  // Answers that changed nothing need no upload.
  const UNCHANGED = new Set(['kept', 'missing', 'changed']);

  // Changes go on top of the newest copy in Drive, so nothing another device
  // saved meanwhile is lost; if the file moves before the upload, again on the newer one.
  function write(change) {
    return serial(async () => {
      const { dek } = await session.get('dek');
      const { driveFile } = await local.get('driveFile');
      const key = fromB64(dek);
      for (let attempt = 0; attempt < 3; attempt++) {
        const before = await revision(driveFile);
        const parts = parse(await download());
        const data = JSON.parse(new TextDecoder().decode(await open(key, parts.payload)));
        const result = change(data);
        if (UNCHANGED.has(result)) return result;
        const payload = await seal(key, new TextEncoder().encode(JSON.stringify(data)));
        if ((await revision(driveFile)) !== before) continue;
        await upload(concat(parts.header, payload));
        loaded = data;
        return result;
      }
      throw new Error(t('driveNotReachable'));
    });
  }

  // ---------- matching, as the app does it ----------

  function hostOf(url) {
    let text = (url || '').trim();
    if (!text) return '';
    if (!text.includes('://')) text = `https://${text}`;
    try {
      const host = new URL(text).hostname.toLowerCase();
      return host.startsWith('www.') ? host.slice(4) : host;
    } catch (e) {
      return '';
    }
  }

  function portOf(url) {
    let text = (url || '').trim();
    if (!text.includes('://')) text = `https://${text}`;
    try {
      return new URL(text).port || null;
    } catch (e) {
      return null;
    }
  }

  const visible = (data) =>
    (data.entries || [])
      .filter((e) => !e.deleted)
      .sort((a, b) => (a.title || '').toLowerCase().localeCompare((b.title || '').toLowerCase()));

  // Only this very host (and port, when given) if there is a login for it;
  // otherwise its parent domain or a subdomain.
  function forSite(data, address) {
    const host = hostOf(address);
    if (!host) return [];
    const port = portOf(address);
    // A login kept for an https page is not handed to the same site over plain http.
    const plain = address.trim().toLowerCase().startsWith('http://');
    const withAddress = visible(data).filter((e) => hostOf(e.url) && !(plain && (e.url || '').trim().toLowerCase().startsWith('https://')));
    const exact = withAddress.filter((e) => hostOf(e.url) === host && (!port || portOf(e.url) === port));
    if (exact.length) return exact;
    return withAddress.filter((e) => {
      const entryHost = hostOf(e.url);
      return entryHost === host || host.endsWith(`.${entryHost}`) || entryHost.endsWith(`.${host}`);
    });
  }

  // Like the app: a new password lands only on the login of exactly this site.
  function loginAt(data, url, username) {
    const host = hostOf(url);
    return visible(data).find((e) => !(e.totp && !e.password) && e.username === username && hostOf(e.url) === host);
  }

  // The same site (host and port; the title without an address) and username
  // kept more than once.
  function duplicateIds(data) {
    const bySite = new Map();
    for (const e of visible(data)) {
      if (e.totp && !e.password) continue;
      const host = hostOf(e.url);
      const site = host ? `${host}:${portOf(e.url) || ''}` : (e.title || '').trim().toLowerCase();
      if (!site) continue;
      const key = `${site}\n${(e.username || '').trim().toLowerCase()}`;
      bySite.set(key, [...(bySite.get(key) || []), e.id]);
    }
    return new Set([...bySite.values()].filter((ids) => ids.length > 1).flat());
  }

  // ---------- site icons, fetched straight from each site ----------

  // Never through an icon service, which would learn every site the user has
  // an account on; no cookies are sent. Kept here, next to the vault copy.
  const ICON_RETRY = 24 * 60 * 60 * 1000;
  const ICON_LINK = /<link\b[^>]*>/gi;
  let icons = null;
  let iconSaving = Promise.resolve();
  const iconQueue = [];
  const iconBusy = new Set();
  let iconRunning = 0;

  const iconKey = (url) => {
    const host = hostOf(url);
    if (!host) return '';
    const port = portOf(url);
    return port ? `${host}:${port}` : host;
  };

  async function iconMap() {
    if (!icons) icons = (await local.get('icons')).icons || {};
    return icons;
  }

  function iconFrom(map, url) {
    const key = iconKey(url);
    if (!key) return null;
    const known = map[key];
    if (typeof known === 'string') return known;
    if ((!known || Date.now() - known.failed > ICON_RETRY) && !iconBusy.has(key)) {
      iconBusy.add(key);
      iconQueue.push([key, url]);
      pumpIcons();
    }
    return null;
  }

  function pumpIcons() {
    while (iconRunning < 4 && iconQueue.length) {
      const [key, url] = iconQueue.shift();
      iconRunning++;
      fetchIcon(url)
        .catch(() => null)
        .then(async (icon) => {
          const map = await iconMap();
          map[key] = icon || { failed: Date.now() };
          iconSaving = iconSaving.then(() => local.set({ icons: map }));
        })
        .finally(() => {
          iconRunning--;
          iconBusy.delete(key);
          pumpIcons();
        });
    }
  }

  async function grab(url, asText) {
    const stop = new AbortController();
    const timer = setTimeout(() => stop.abort(), 6000);
    try {
      const response = await fetch(url, { signal: stop.signal, credentials: 'omit' });
      if (!response.ok) return null;
      if (asText) return { text: (await response.text()).slice(0, 512 * 1024), url: response.url };
      const type = (response.headers.get('content-type') || '').split(';')[0].trim();
      const bytes = new Uint8Array(await response.arrayBuffer());
      if (bytes.length < 50 || bytes.length > 200 * 1024) return null;
      if (!type.startsWith('image/') && !/\.ico(\?|$)/i.test(url)) return null;
      return `data:${type.startsWith('image/') ? type : 'image/x-icon'};base64,${toB64(bytes)}`;
    } catch (e) {
      return null;
    } finally {
      clearTimeout(timer);
    }
  }

  // Icons the page names itself, the larger and the more touch-friendly first.
  function iconLinks(html, base) {
    const found = [];
    for (const tag of html.match(ICON_LINK) || []) {
      const attr = (name) => {
        const m = tag.match(new RegExp(`\\b${name}\\s*=\\s*("([^"]*)"|'([^']*)'|([^\\s>]+))`, 'i'));
        return m ? m[2] ?? m[3] ?? m[4] : null;
      };
      const rel = (attr('rel') || '').toLowerCase();
      const href = attr('href');
      if (!rel.includes('icon') || !href || href.startsWith('data:')) continue;
      let score = parseInt(((attr('sizes') || '').match(/(\d+)x/) || [])[1] || '32', 10);
      if (rel.includes('apple-touch')) score += 1000;
      try {
        found.push([score, new URL(href, base).href]);
      } catch (e) {
        // an address the page got wrong
      }
    }
    return found.sort((a, b) => b[0] - a[0]).map(([, href]) => href);
  }

  // The address as given first, then the other scheme; a login page on a
  // subdomain (id.…, passport.…) falls back to the main site.
  async function fetchIcon(url) {
    let text = url.trim();
    if (!text.includes('://')) text = `https://${text}`;
    const first = new URL(text);
    const hosts = [first.host];
    const labels = first.hostname.split('.');
    if (labels.length > 2 && !/^[\d.]+$/.test(first.hostname)) hosts.push(labels.slice(1).join('.'));
    const schemes = first.protocol === 'http:' ? ['http:', 'https:'] : ['https:', 'http:'];

    for (const host of hosts) {
      for (const scheme of schemes) {
        const origin = `${scheme}//${host}/`;
        const page = await grab(origin, true);
        const candidates = page ? iconLinks(page.text, page.url) : [];
        candidates.push(new URL('/favicon.ico', page ? page.url : origin).href);
        for (const candidate of candidates) {
          const icon = await grab(candidate, false);
          if (icon) return icon;
        }
        if (page) break;
      }
    }
    return null;
  }

  // Two-factor codes of their own (name, key, note, address) and the logins
  // that point at one by its id — as in the app.
  const isCode = (e) => !!e.totp && !e.password;
  const codesOf = (data) => visible(data).filter(isCode);
  const loginsOf = (data, code) => visible(data).filter((e) => e.twoFactor === code.id);
  // Where a code is used: its own addresses and those of the logins pinned to it.
  const sitesOf = (data, code) => [...(code.sites || []), ...loginsOf(data, code).map((l) => (l.url || '').trim()).filter(Boolean)];
  const paired = (data, code) => sitesOf(data, code).length > 0;

  // Exactly this page's host (and port, when given); a related domain's entry
  // is for the popup only, never for the list on the page.
  function exactFor(data, e, address) {
    const host = hostOf(address);
    const port = portOf(address);
    const here = (site) => hostOf(site) === host && (!port || portOf(site) === port);
    return isCode(e) ? sitesOf(data, e).some(here) : here(e.url);
  }

  function codesForSite(data, address) {
    const host = hostOf(address);
    if (!host) return [];
    const port = portOf(address);
    const exact = (site) => hostOf(site) === host && (!port || portOf(site) === port);
    const related = (site) => {
      const h = hostOf(site);
      return !!h && (h === host || host.endsWith(`.${h}`) || h.endsWith(`.${host}`));
    };
    const found = codesOf(data).filter((c) => sitesOf(data, c).some(exact));
    return found.length ? found : codesOf(data).filter((c) => sitesOf(data, c).some(related));
  }
  const secretFor = (data, e) => {
    if (e.totp) return e.totp;
    const code = (data.entries || []).find((x) => x.id === e.twoFactor && !x.deleted);
    return code ? code.totp : null;
  };
  const codeOf = (data, e, map) => ({
    id: e.id,
    title: e.title,
    username: e.username || '',
    hasCode: true,
    paired: paired(data, e),
    icon: iconFrom(map, sitesOf(data, e)[0] || ''),
  });

  // ---------- two-factor codes ----------

  function base32(text) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    const out = [];
    let buffer = 0;
    let bits = 0;
    for (const char of text.toUpperCase().replace(/[^A-Z2-7]/g, '')) {
      buffer = (buffer << 5) | alphabet.indexOf(char);
      bits += 5;
      if (bits >= 8) {
        bits -= 8;
        out.push((buffer >> bits) & 0xff);
      }
    }
    return new Uint8Array(out);
  }

  async function totp(secret) {
    let counter = Math.floor(Date.now() / 1000 / 30);
    const message = new Uint8Array(8);
    for (let i = 7; i >= 0; i--) {
      message[i] = counter & 0xff;
      counter = Math.floor(counter / 256);
    }
    const key = await crypto.subtle.importKey('raw', base32(secret), { name: 'HMAC', hash: 'SHA-1' }, false, ['sign']);
    const mac = new Uint8Array(await crypto.subtle.sign('HMAC', key, message));
    const at = mac[mac.length - 1] & 0x0f;
    const binary = ((mac[at] & 0x7f) << 24) | (mac[at + 1] << 16) | (mac[at + 2] << 8) | mac[at + 3];
    return String(binary % 1000000).padStart(6, '0');
  }

  const secondsLeft = () => 30 - (Math.floor(Date.now() / 1000) % 30);

  // ---------- caught logins, held in memory until the user answers ----------

  async function offers() {
    const { aloneOffers = {} } = await session.get('aloneOffers');
    const now = Date.now();
    for (const [id, offer] of Object.entries(aloneOffers)) if (offer.until < now) delete aloneOffers[id];
    return aloneOffers;
  }

  const keepOffers = (list) => session.set({ aloneOffers: list });

  async function settings() {
    const { aloneSettings } = await local.get('aloneSettings');
    return { neverSave: [], autoSave: false, ...aloneSettings };
  }

  // ---------- the app's endpoints ----------

  const routes = {
    async '/lookup'(data, body) {
      pullSoon();
      const host = hostOf(body.url);
      const { neverSave, autoSave } = await settings();
      const duplicates = duplicateIds(data);
      const map = await iconMap();
      const codes = codesOf(data);
      return {
        alone: true,
        never: neverSave.includes(host),
        autoSave,
        unpaired: codes.filter((e) => !paired(data, e)).map((e) => codeOf(data, e, map)),
        codeCount: codes.length,
        entries: [...forSite(data, body.url).filter((e) => !isCode(e)), ...codesForSite(data, body.url)].map((e) => ({
          id: e.id,
          title: e.title,
          username: e.username,
          group: e.group || '',
          hasCode: !!secretFor(data, e),
          isCode: isCode(e),
          linked: !!e.twoFactor,
          duplicate: duplicates.has(e.id),
          icon: iconFrom(map, isCode(e) ? sitesOf(data, e)[0] || '' : e.url),
          exact: exactFor(data, e, body.url),
          host: hostOf(isCode(e) ? sitesOf(data, e)[0] || '' : e.url),
        })),
      };
    },

    async '/codes'(data) {
      const map = await iconMap();
      return { codes: codesOf(data).map((e) => codeOf(data, e, map)) };
    },

    // A code with no site yet gets the page it was just used on.
    async '/pair'(data, body) {
      return {
        result: await signedIn(() => write((fresh) => {
          const e = (fresh.entries || []).find((x) => x.id === body.id && !x.deleted);
          if (!e || paired(fresh, e)) return 'kept';
          e.sites = [...(e.sites || []), new URL(body.url).origin];
          e.updatedAt = Date.now();
          return 'paired';
        })),
      };
    },

    async '/fill'(data, body) {
      const e = visible(data).find((x) => x.id === body.id);
      if (!e) return { error: t('notFound') };
      const secret = secretFor(data, e);
      return { username: e.username, password: e.password, code: secret ? await totp(secret) : null };
    },

    async '/code'(data, body) {
      const e = visible(data).find((x) => x.id === body.id);
      const secret = e && secretFor(data, e);
      if (!secret) return { error: t('notFound') };
      return { code: await totp(secret), left: secondsLeft() };
    },

    async '/save'(data, body) {
      const host = hostOf(body.url);
      if (!body.password || !host) return { result: 'ignored' };
      const { neverSave, autoSave } = await settings();
      if (neverSave.includes(host)) return { result: 'blocked' };

      const existing = loginAt(data, body.url, body.username || '');
      const known = !!existing && existing.password === body.password;
      const list = await offers();
      // A retry on the same site replaces the earlier attempt.
      for (const [id, o] of Object.entries(list)) if (o.host === host && o.username === body.username) delete list[id];
      const id = randomId();
      list[id] = {
        url: body.url,
        host,
        username: body.username || '',
        password: body.password,
        changed: !!existing && !known,
        known,
        failed: false,
        until: Date.now() + OFFER_TIME,
      };
      await keepOffers(list);
      return { result: 'offered', id, known, changed: !!existing && !known, autoSave };
    },

    async '/offers'() {
      const list = await offers();
      const now = Date.now();
      return {
        offers: Object.entries(list)
          .filter(([, o]) => !o.known || o.failed)
          .map(([id, o]) => ({
            id,
            host: o.host,
            username: o.username,
            changed: o.changed,
            known: o.known,
            failed: o.failed,
            left: Math.round((o.until - now) / 1000),
          })),
      };
    },

    async '/review'(data, body) {
      const offer = (await offers())[body.id];
      if (!offer) return { result: 'missing' };
      let result = 'dropped';
      // A login kept leaves the list only once it is in Drive: a failed save can be tried again.
      if (body.keep && !offer.known) {
        result = await signedIn(() => write((fresh) => {
          const existing = loginAt(fresh, offer.url, offer.username);
          if (existing) {
            existing.password = offer.password;
            existing.updatedAt = Date.now();
            return 'updated';
          }
          fresh.entries = fresh.entries || [];
          fresh.entries.push({
            id: randomId(),
            title: offer.host,
            username: offer.username,
            password: offer.password,
            url: offer.url,
            notes: '',
            // Like the app: an older vault's English web group keeps its name.
            group: fresh.entries.some((x) => !x.deleted && x.group === 'Web') ? 'Web' : t('groupWeb'),
            updatedAt: Date.now(),
          });
          return 'saved';
        }));
      }
      const list = await offers();
      delete list[body.id];
      await keepOffers(list);
      return { result };
    },

    async '/fail'(data, body) {
      const list = await offers();
      const offer = list[body.id];
      if (!offer) return { result: 'missing' };
      offer.failed = true;
      offer.until = Date.now() + FAILED_TIME;
      await keepOffers(list);
      return { result: 'failed' };
    },

    async '/never'(data, body) {
      const host = hostOf(body.url);
      const current = await settings();
      const neverSave = current.neverSave.filter((h) => h !== host);
      if (body.never && host) neverSave.push(host);
      await local.set({ aloneSettings: { ...current, neverSave } });
      if (body.never) {
        const list = await offers();
        for (const [id, o] of Object.entries(list)) if (o.host === host) delete list[id];
        await keepOffers(list);
      }
      return { never: neverSave.includes(host) };
    },

    // The edit page: one whole entry; for a login also the codes to pin to it,
    // each with its current digits, as names can repeat.
    async '/entry'(data, body) {
      data = await fresh(data);
      const e = visible(data).find((x) => x.id === body.id);
      if (!e) return { error: t('notFound') };
      const groups = [...new Set(visible(data).map((x) => x.group).filter(Boolean))].sort();
      const codes = [];
      for (const c of codesOf(data)) codes.push({ id: c.id, title: c.title, code: await totp(c.totp) });
      return {
        code: isCode(e),
        entry: {
          id: e.id,
          title: e.title || '',
          username: e.username || '',
          password: e.password || '',
          url: e.url || '',
          totp: e.totp || '',
          group: e.group || '',
          notes: e.notes || '',
          twoFactor: e.twoFactor || '',
          updatedAt: e.updatedAt || 0,
        },
        sites: e.sites || [],
        pinned: isCode(e) ? loginsOf(data, e).map((l) => ({ id: l.id, label: `${l.title} — ${l.username}`, url: l.url || '' })) : [],
        codes,
        groups,
      };
    },

    async '/put'(data, body) {
      const changed = body.entry || {};
      return {
        result: await signedIn(() => write((fresh) => {
          const e = (fresh.entries || []).find((x) => x.id === changed.id && !x.deleted);
          if (!e) return 'missing';
          // Changed on another device since the page opened: its fields would go back.
          if ((e.updatedAt || 0) !== (changed.updatedAt || 0)) return 'changed';
          e.title = changed.title || '';
          e.url = changed.url || '';
          e.notes = changed.notes || '';
          if (isCode(e)) {
            if (changed.totp) e.totp = changed.totp;
            e.url = '';
            e.sites = changed.sites || [];
            // Logins let go of here lose the pin on their side too.
            for (const login of (fresh.entries || []).filter((x) => (changed.unpin || []).includes(x.id))) {
              delete login.twoFactor;
              login.updatedAt = Date.now();
            }
          } else {
            e.username = changed.username || '';
            e.password = changed.password || '';
            e.group = changed.group || '';
            if (changed.twoFactor) e.twoFactor = changed.twoFactor;
            else delete e.twoFactor;
          }
          e.updatedAt = Date.now();
          return 'saved';
        })),
      };
    },

    // As in the app: the entry stays as a marker so the deletion reaches other devices.
    async '/delete'(data, body) {
      return {
        result: await signedIn(() => write((fresh) => {
          const e = (fresh.entries || []).find((x) => x.id === body.id);
          if (!e) return 'missing';
          e.deleted = true;
          e.password = '';
          delete e.totp;
          e.updatedAt = Date.now();
          return 'deleted';
        })),
      };
    },

    async '/autosave'(data, body) {
      const current = await settings();
      await local.set({ aloneSettings: { ...current, autoSave: body.on === true } });
      return { autoSave: body.on === true };
    },
  };

  return {
    /// Answers like the app would, or null while the vault is not open here.
    async handle(path, body) {
      const route = routes[path];
      if (!route) return null;
      const data = await vault();
      if (!data) return null;
      try {
        return await route(data, body || {});
      } catch (e) {
        return { error: e.message || t('driveNotReachable') };
      }
    },

    /// "none" (never connected here), "locked" or "open".
    async state() {
      const { vaultFile, driveConnected } = await local.get(['vaultFile', 'driveConnected']);
      if (!vaultFile && !driveConnected) return { state: 'none' };
      const { dek } = await session.get('dek');
      return { state: dek ? 'open' : 'locked' };
    },

    /// Signs in to Google; the master password then picks the vault.
    async connect() {
      try {
        await session.remove('driveToken');
        await local.remove(['driveFile', 'vaultFile']);
        if ((await vaultFiles(true)).length === 0) return { error: t('noVaultInDrive') };
        await rememberAccount();
        await local.set({ driveConnected: true });
        return { ok: true };
      } catch (e) {
        const text = e.message || '';
        if (/only one web auth flow/i.test(text)) {
          return { error: t('signInWindowOpen') };
        }
        return { error: text || t('driveNotConnected') };
      }
    },

    /// The vault opened here before is tried first, then every vault in Drive:
    /// the one this password opens is the user's.
    async unlock(password) {
      const keyIn = async (bytes) => {
        const parts = parse(bytes);
        if (!parts.salt) return null;
        try {
          return await unwrap(password, parts.salt, parts.wrapped);
        } catch {
          return null;
        }
      };
      const opened = async (dek) => {
        await session.set({ dek: toB64(dek), usedAt: Date.now() });
        loaded = null;
        // Every missing icon, so the list under the fields has them too.
        const map = await iconMap();
        for (const e of visible(await vault())) iconFrom(map, e.url);
        return { ok: true };
      };

      const { driveFile, vaultFile } = await local.get(['driveFile', 'vaultFile']);
      let ids;
      try {
        ids = (await signedIn(() => vaultFiles(false))).map((f) => f.id);
      } catch (e) {
        // Signed out of Google: said so, not opened from an old copy.
        if (e.signIn || !vaultFile) return { error: e.message };
        // Offline: only the copy kept here can open.
        const dek = await keyIn(fromB64(vaultFile));
        return dek ? opened(dek) : { error: t('wrongMasterPassword') };
      }
      if (driveFile && ids.includes(driveFile)) ids = [driveFile, ...ids.filter((id) => id !== driveFile)];
      for (const id of ids) {
        const bytes = await fetchFile(id);
        const dek = await keyIn(bytes);
        if (!dek) continue;
        await local.set({ driveFile: id, vaultFile: toB64(bytes), pulledAt: Date.now() });
        return opened(dek);
      }
      return { error: t(ids.length ? 'noVaultMatches' : 'noVaultInDrive') };
    },

    async lock() {
      loaded = null;
      await session.remove(['dek', 'aloneOffers', 'usedAt']);
      return { ok: true };
    },

    async disconnect() {
      loaded = null;
      icons = null;
      await session.remove(['dek', 'aloneOffers', 'driveToken', 'usedAt']);
      await local.remove(['driveFile', 'vaultFile', 'pulledAt', 'driveEmail', 'icons', 'driveConnected']);
      return { ok: true };
    },
  };
})();
