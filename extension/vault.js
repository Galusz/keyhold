// Keyhold without the app on this computer: the vault comes from the user's
// own Google Drive and opens with the master password, inside the extension.
// It answers the same questions the app answers over 127.0.0.1.
const Standalone = (() => {
  const ext = globalThis.browser ?? chrome;
  const local = ext.storage.local;
  const session = ext.storage.session;

  // "Web application" client of the Keyhold Google project; not a secret.
  const GOOGLE_CLIENT_ID = '95881372863-ajkuag5vst7l6re7c7cvj000j4dq4gcn.apps.googleusercontent.com';
  const SCOPE = 'https://www.googleapis.com/auth/drive.file';
  const FILE = 'vault.khd';
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
    if (flag === 1) {
      salt = bytes.slice(at, at + 16);
      at += 16;
      const length = (bytes[at] << 8) | bytes[at + 1];
      at += 2;
      wrapped = bytes.slice(at, at + length);
      at += length;
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
    const back = await ext.identity.launchWebAuthFlow({
      url: `https://accounts.google.com/o/oauth2/v2/auth?${new URLSearchParams(query)}`,
      interactive,
    });
    const answer = new URLSearchParams(new URL(back).hash.slice(1));
    const value = answer.get('access_token');
    if (!value) throw new Error(answer.get('error') || 'Google did not sign in');
    await session.set({
      driveToken: { token: value, until: Date.now() + Number(answer.get('expires_in') || 3600) * 1000 },
    });
    return value;
  }

  async function drive(url, init = {}, interactive = false) {
    const response = await fetch(url, {
      ...init,
      headers: { ...(init.headers || {}), Authorization: `Bearer ${await token(interactive)}` },
    });
    if (response.status === 401) await session.remove('driveToken');
    if (!response.ok) throw new Error(`Google Drive answered ${response.status}`);
    return response;
  }

  async function fileId(interactive) {
    const { driveFile } = await local.get('driveFile');
    if (driveFile) return driveFile;
    const query = new URLSearchParams({
      q: `name = '${FILE}' and trashed = false`,
      orderBy: 'modifiedTime desc',
      fields: 'files(id)',
    });
    const { files } = await (await drive(`https://www.googleapis.com/drive/v3/files?${query}`, {}, interactive)).json();
    if (!files || files.length === 0) return null;
    await local.set({ driveFile: files[0].id });
    return files[0].id;
  }

  async function download(interactive = false) {
    const id = await fileId(interactive);
    if (!id) throw new Error('There is no Keyhold vault in this Google Drive yet');
    const response = await drive(`https://www.googleapis.com/drive/v3/files/${id}?alt=media`, {}, interactive);
    const bytes = new Uint8Array(await response.arrayBuffer());
    await local.set({ vaultFile: toB64(bytes), pulledAt: Date.now() });
    return bytes;
  }

  async function upload(bytes) {
    const id = await fileId(false);
    await drive(`https://www.googleapis.com/upload/drive/v3/files/${id}?uploadType=media`, {
      method: 'PATCH',
      headers: { 'content-type': 'application/octet-stream' },
      body: bytes,
    });
    await local.set({ vaultFile: toB64(bytes), pulledAt: Date.now() });
  }

  // ---------- the open vault ----------

  let loaded = null;

  async function vault() {
    if (loaded) return loaded;
    const { dek } = await session.get('dek');
    const { vaultFile } = await local.get('vaultFile');
    if (!dek || !vaultFile) return null;
    const parts = parse(fromB64(vaultFile));
    loaded = JSON.parse(new TextDecoder().decode(await open(fromB64(dek), parts.payload)));
    return loaded;
  }

  // Newer copy from Drive every few minutes, without holding anything up.
  async function pullSoon() {
    const { pulledAt } = await local.get('pulledAt');
    if (pulledAt && Date.now() - pulledAt < PULL_EVERY) return;
    await local.set({ pulledAt: Date.now() });
    download()
      .then(() => (loaded = null))
      .catch(() => {});
  }

  // Changes go on top of the newest copy in Drive, so nothing another device
  // saved meanwhile is lost.
  async function write(change) {
    const { dek } = await session.get('dek');
    const bytes = await download();
    const parts = parse(bytes);
    const key = fromB64(dek);
    const data = JSON.parse(new TextDecoder().decode(await open(key, parts.payload)));
    const result = change(data);
    const payload = await seal(key, new TextEncoder().encode(JSON.stringify(data)));
    await upload(concat(parts.header, payload));
    loaded = data;
    return result;
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
    const withAddress = visible(data).filter((e) => hostOf(e.url));
    const exact = withAddress.filter((e) => hostOf(e.url) === host && (!port || portOf(e.url) === port));
    if (exact.length) return exact;
    return withAddress.filter((e) => {
      const entryHost = hostOf(e.url);
      return entryHost === host || host.endsWith(`.${entryHost}`) || entryHost.endsWith(`.${host}`);
    });
  }

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
      return {
        alone: true,
        never: neverSave.includes(host),
        autoSave,
        entries: forSite(data, body.url).map((e) => ({
          id: e.id,
          title: e.title,
          username: e.username,
          group: e.group || '',
          hasCode: !!e.totp,
        })),
      };
    },

    async '/fill'(data, body) {
      const e = visible(data).find((x) => x.id === body.id);
      if (!e) return { error: 'not found' };
      return { username: e.username, password: e.password, code: e.totp ? await totp(e.totp) : null };
    },

    async '/code'(data, body) {
      const e = visible(data).find((x) => x.id === body.id);
      if (!e || !e.totp) return { error: 'not found' };
      return { code: await totp(e.totp), left: secondsLeft() };
    },

    async '/save'(data, body) {
      const host = hostOf(body.url);
      if (!body.password || !host) return { result: 'ignored' };
      const { neverSave, autoSave } = await settings();
      if (neverSave.includes(host)) return { result: 'blocked' };

      const existing = forSite(data, body.url).find((e) => e.username === (body.username || ''));
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
      return { result: 'offered', id, known, autoSave };
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
      const list = await offers();
      const offer = list[body.id];
      delete list[body.id];
      await keepOffers(list);
      if (!offer) return { result: 'missing' };
      if (!body.keep || offer.known) return { result: 'dropped' };

      return {
        result: await write((fresh) => {
          const existing = forSite(fresh, offer.url).find((e) => e.username === offer.username);
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
            group: 'Web',
            updatedAt: Date.now(),
          });
          return 'saved';
        }),
      };
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

    // The edit page: one whole entry, and the group names to pick from.
    async '/entry'(data, body) {
      const e = visible(data).find((x) => x.id === body.id);
      if (!e) return { error: 'not found' };
      const groups = [...new Set(visible(data).map((x) => x.group).filter(Boolean))].sort();
      return {
        entry: {
          id: e.id,
          title: e.title || '',
          username: e.username || '',
          password: e.password || '',
          url: e.url || '',
          totp: e.totp || '',
          group: e.group || '',
          notes: e.notes || '',
        },
        groups,
      };
    },

    async '/put'(data, body) {
      const changed = body.entry || {};
      return {
        result: await write((fresh) => {
          const e = (fresh.entries || []).find((x) => x.id === changed.id && !x.deleted);
          if (!e) return 'missing';
          for (const field of ['title', 'username', 'password', 'url', 'group', 'notes']) {
            e[field] = changed[field] || '';
          }
          if (changed.totp) e.totp = changed.totp;
          else delete e.totp;
          e.updatedAt = Date.now();
          return 'saved';
        }),
      };
    },

    // As in the app: the entry stays as a marker so the deletion reaches other devices.
    async '/delete'(data, body) {
      return {
        result: await write((fresh) => {
          const e = (fresh.entries || []).find((x) => x.id === body.id);
          if (!e) return 'missing';
          e.deleted = true;
          e.password = '';
          delete e.totp;
          e.updatedAt = Date.now();
          return 'deleted';
        }),
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
        return { error: e.message || 'Google Drive is not reachable' };
      }
    },

    /// "none" (never connected here), "locked" or "open".
    async state() {
      const { vaultFile } = await local.get('vaultFile');
      if (!vaultFile) return { state: 'none' };
      const { dek } = await session.get('dek');
      return { state: dek ? 'open' : 'locked' };
    },

    /// Signs in to Google and fetches the vault; the master password comes next.
    async connect() {
      try {
        await session.remove('driveToken');
        await local.remove(['driveFile', 'vaultFile']);
        const bytes = await download(true);
        if (!parse(bytes).salt) {
          await local.remove('vaultFile');
          return { error: 'Set a master password in the Keyhold app first' };
        }
        return { ok: true };
      } catch (e) {
        const text = e.message || '';
        if (/only one web auth flow/i.test(text)) {
          return { error: 'A Google sign-in window is still open. Close it and try again.' };
        }
        return { error: text || 'Google Drive was not connected' };
      }
    },

    async unlock(password) {
      let bytes;
      try {
        bytes = await download();
      } catch (e) {
        const { vaultFile } = await local.get('vaultFile');
        if (!vaultFile) return { error: e.message };
        bytes = fromB64(vaultFile);
      }
      const parts = parse(bytes);
      if (!parts.salt) return { error: 'Set a master password in the Keyhold app first' };
      try {
        const dek = await unwrap(password, parts.salt, parts.wrapped);
        await session.set({ dek: toB64(dek) });
        loaded = null;
        return { ok: true };
      } catch (e) {
        return { error: 'Wrong master password' };
      }
    },

    async lock() {
      loaded = null;
      await session.remove(['dek', 'aloneOffers']);
      return { ok: true };
    },

    async disconnect() {
      loaded = null;
      await session.remove(['dek', 'aloneOffers', 'driveToken']);
      await local.remove(['driveFile', 'vaultFile', 'pulledAt', 'driveEmail']);
      return { ok: true };
    },
  };
})();
