// Chrome and Edge run this alone as a service worker; Firefox loads these first itself.
if (typeof importScripts === 'function') importScripts('lib/argon2.umd.min.js', 'vault.js');

const api = globalThis.browser ?? chrome;
const BRIDGE = 'http://127.0.0.1:19919';
// Keyhold on this computer answers a question within milliseconds, while
// Windows takes seconds to give up on a closed port: an app that is off counts
// as off at once. Saving waits longer, as the app copies the vault to its backups.
const APP_WAIT = 200;
const SAVE_WAIT = 30 * 1000;
const QUESTIONS = ['/lookup', '/codes', '/fill', '/code', '/entry'];
// An app that did not answer is not asked again for a while: every question of
// a page or the popup would wait out the limit again.
const APP_RETRY = 20 * 1000;
let appDownUntil = 0;
const session = api.storage.session;
const USER_TTL = 10 * 60 * 1000;
const VERDICT_WAIT = 8 * 1000;
const FAILED_SHOW = 30 * 1000;

// The Keyhold app on this computer when it runs; otherwise the vault this
// extension opened from Google Drive, if any.
async function call(path, body) {
  const result = await callApp(path, body);
  if (result.error === 'app offline' || result.error === 'no token') {
    const alone = await Standalone.handle(path, body);
    if (alone) return alone;
  }
  // Never paired, and Keyhold answers here: pairing is the next step, not Google Drive.
  if (result.error === 'no token' && (await Standalone.state()).state === 'none' && (await appAnswers())) {
    return { error: 'bad token' };
  }
  return result;
}

async function appAnswers() {
  if (Date.now() < appDownUntil) return false;
  try {
    return (await fetch(`${BRIDGE}/lookup`, { method: 'POST', signal: AbortSignal.timeout(APP_WAIT) })).status === 401;
  } catch (e) {
    appDownUntil = Date.now() + APP_RETRY;
    return false;
  }
}

async function callApp(path, body) {
  const { token } = await api.storage.local.get('token');
  if (!token) return { error: 'no token' };
  if (Date.now() < appDownUntil) return { error: 'app offline' };

  try {
    const response = await fetch(BRIDGE + path, {
      method: 'POST',
      headers: { 'content-type': 'application/json', 'x-keyhold-token': token },
      body: JSON.stringify(body || {}),
      signal: AbortSignal.timeout(QUESTIONS.includes(path) ? APP_WAIT : SAVE_WAIT),
    });
    if (!response.ok) {
      return { error: response.status === 401 ? 'bad token' : 'app error' };
    }
    return await response.json();
  } catch (e) {
    appDownUntil = Date.now() + APP_RETRY;
    return { error: 'app offline' };
  }
}

async function read(key) {
  const stored = await session.get(key);
  return stored[key];
}

// A page only ever gets entries for its own address; the popup asks for the active tab.
const pageUrl = (message, sender) => (sender.tab ? sender.url : message.url);

async function allowed(message, sender) {
  if (!sender.tab) return true;
  const result = await call('/lookup', { url: sender.url });
  return (result.entries || []).some((e) => e.id === message.id);
}

// A code may be picked on any page: from this site's, from those with no site
// yet, or from the full list.
async function allowedCode(message, sender) {
  if (await allowed(message, sender)) return true;
  const all = await call('/codes');
  return (all.codes || []).some((e) => e.id === message.id);
}

// ---------- catching logins ----------

async function save(message, sender) {
  const tabId = sender.tab?.id;
  let username = message.username || '';

  // Two-step logins ask for the username on the page before the password.
  if (!username && tabId != null) {
    const remembered = await read(`user:${tabId}`);
    if (remembered && Date.now() - remembered.at < USER_TTL) username = remembered.username;
  }

  const result = await call('/save', { url: sender.url, username, password: message.password });
  if (result.result !== 'offered' || tabId == null) return { result: result.result };

  // Keyhold holds the login; what the page does next decides what happens to it.
  await session.set({
    [`attempt:${tabId}`]: {
      id: result.id,
      host: new URL(sender.url).hostname,
      frameId: sender.frameId,
      autoSave: result.autoSave === true,
      known: result.known === true,
      changed: result.changed === true,
      at: Date.now(),
    },
  });
  setTimeout(() => decide(tabId, result.id, 'unclear'), VERDICT_WAIT);
  return { result: 'offered' };
}

/// A password field again on the same site means the login failed, no
/// password field means it worked, anything else is left to the user.
async function outcome(message, sender) {
  const tabId = sender.tab?.id;
  const attempt = await read(`attempt:${tabId}`);
  if (!attempt || sender.frameId !== attempt.frameId) return null;

  const sameSite = new URL(sender.url).hostname === attempt.host;
  let verdict;
  if (message.passwordField === false) verdict = 'worked';
  else if (message.passwordField === true && sameSite) verdict = 'failed';
  else if (message.final) verdict = 'unclear';
  else return null;
  return decide(tabId, attempt.id, verdict);
}

async function decide(tabId, id, verdict) {
  const key = `attempt:${tabId}`;
  const attempt = await read(key);
  if (!attempt || attempt.id !== id) return null;
  await session.remove(key);

  if (verdict === 'failed') {
    await call('/fail', { id });
    await session.set({ [`failed:${tabId}`]: Date.now() + FAILED_SHOW });
    paint(tabId);
    setTimeout(() => session.remove(`failed:${tabId}`).then(() => paint(tabId)), FAILED_SHOW);
  } else if (attempt.known) {
    // The saved password did its job (or nothing tells otherwise): nothing to ask.
    await call('/review', { id, keep: false });
  } else if (verdict === 'worked' && attempt.autoSave && !attempt.changed) {
    // Only new logins are kept by themselves; a different password always asks.
    await call('/review', { id, keep: true });
  }
  await syncOffers();
  return verdict;
}

// ---------- logins waiting for ✓ / ✕ ----------

// Mirrors what Keyhold holds, minus logins whose outcome is still being watched.
// Failed ones show red in the popup but do not make the lock blink.
async function syncOffers() {
  const result = await call('/offers');
  const all = await session.get(null);
  const judging = new Set(
    Object.keys(all)
      .filter((k) => k.startsWith('attempt:') && Date.now() - all[k].at < VERDICT_WAIT)
      .map((k) => all[k].id)
  );
  const offers = (result.offers || []).filter((o) => !judging.has(o.id));
  const waiting = offers.filter((o) => !o.failed);
  const pins = (await read('pins')) || {};
  await session.set({
    offers: [...waiting.map((o) => Date.now() + o.left * 1000), ...Object.values(pins).map((p) => p.until)],
  });
  blink();
  return offers;
}

// A code with no site was just used on a page: the lock blinks and the popup
// asks whether it belongs to that page from now on.
async function offerPin(message, sender) {
  const all = await call('/codes');
  const code = (all.codes || []).find((c) => c.id === message.id);
  if (!code || code.paired) return null;
  const pins = (await read('pins')) || {};
  const host = new URL(sender.url).hostname;
  pins[`${code.id} ${host}`] = { id: code.id, title: code.title, host, url: sender.url, until: Date.now() + 2 * 60 * 1000 };
  await session.set({ pins });
  await syncOffers();
  return { asked: true };
}

async function pins() {
  const all = (await read('pins')) || {};
  const now = Date.now();
  for (const [key, pin] of Object.entries(all)) if (pin.until < now) delete all[key];
  await session.set({ pins: all });
  return Object.entries(all).map(([key, pin]) => ({ key, ...pin }));
}

async function answerPin(message) {
  const all = (await read('pins')) || {};
  const pin = all[message.key];
  delete all[message.key];
  await session.set({ pins: all });
  if (pin && message.yes) await call('/pair', { id: pin.id, url: pin.url });
  await syncOffers();
  return { ok: true };
}

async function review(message) {
  const result = await call('/review', { id: message.id, keep: message.keep });
  await syncOffers();
  return result;
}

async function never(message) {
  const result = await call('/never', { url: message.url, never: message.on });
  await syncOffers();
  const [tab] = await api.tabs.query({ active: true, currentWindow: true });
  if (tab) refreshIcon(tab.id, tab.url);
  return result;
}

// ---------- toolbar icon ----------

// Red lock: a login just failed here. Struck-through lock: saving is off here.
// Blinking orange: Keyhold holds a login that waits for ✓ / ✕.
const stopTabs = new Set();
let lit = false;
let blinking = 0;

async function paint(tabId) {
  const failedUntil = await read(`failed:${tabId}`);
  let name = 'icon';
  if (failedUntil > Date.now()) name = 'failed';
  else if (stopTabs.has(tabId)) name = 'stop';
  else if (lit) name = 'pending';
  api.action
    .setIcon({ tabId, path: { 16: `icons/${name}16.png`, 32: `icons/${name}32.png` } })
    .catch(() => {});
}

async function refreshIcon(tabId, url) {
  let stop = false;
  if (url && /^https?:/.test(url)) stop = (await call('/lookup', { url })).never === true;
  if (stop) stopTabs.add(tabId);
  else stopTabs.delete(tabId);
  paint(tabId);
  blink();
}

function blink() {
  if (blinking) return;
  const tick = async () => {
    const offers = (await read('offers')) || [];
    const waiting = offers.some((until) => until > Date.now());
    lit = waiting && !lit;
    const tabs = await api.tabs.query({ active: true });
    tabs.forEach((tab) => paint(tab.id));
    if (!waiting) {
      clearInterval(blinking);
      blinking = 0;
    }
  };
  blinking = setInterval(tick, 700);
  tick();
}

api.tabs.onUpdated.addListener((tabId, change, tab) => {
  if (change.status === 'complete') refreshIcon(tabId, tab.url);
});
api.tabs.onActivated.addListener(({ tabId }) =>
  api.tabs.get(tabId).then((tab) => refreshIcon(tabId, tab.url), () => {})
);

api.runtime.onMessage.addListener((message, sender, reply) => {
  if (sender.id !== api.runtime.id) return false;

  const routes = {
    lookup: () => call('/lookup', { url: pageUrl(message, sender) }),
    fill: async () => ((await allowed(message, sender)) ? call('/fill', { id: message.id }) : { error: 'denied' }),
    code: async () => ((await allowedCode(message, sender)) ? call('/code', { id: message.id }) : { error: 'denied' }),
    codes: () => call('/codes'),
    'pin-offer': () => offerPin(message, sender),
    save: () => save(message, sender),
    user: () => session.set({ [`user:${sender.tab?.id}`]: { username: message.username, at: Date.now() } }),
    outcome: () => outcome(message, sender),
  };
  // Answering what Keyhold caught, and editing, is for the extension's own
  // pages (popup, edit page) only, never for a website.
  const ownPage = !sender.tab || (sender.url || '').startsWith(api.runtime.getURL(''));
  if (ownPage) {
    Object.assign(routes, {
      offers: () => syncOffers(),
      review: () => review(message),
      never: () => never(message),
      autosave: () => call('/autosave', { on: message.on }),
      alone: () => Standalone.state(),
      'alone-connect': () => Standalone.connect(),
      'alone-unlock': () => Standalone.unlock(message.password || ''),
      'alone-lock': () => Standalone.lock(),
      'alone-disconnect': () => Standalone.disconnect(),
      open: () => call('/open', { id: message.id }),
      pins: () => pins(),
      'pin-answer': () => answerPin(message),
      entry: () => call('/entry', { id: message.id }),
      put: () => call('/put', { entry: message.entry }),
      delete: () => call('/delete', { id: message.id }),
    });
  }
  const route = routes[message.type];
  if (!route) return false;
  Promise.resolve(route()).then(reply, () => reply(null));
  return true;
});

api.tabs.onRemoved.addListener((tabId) => {
  stopTabs.delete(tabId);
  session.remove([`user:${tabId}`, `failed:${tabId}`]);
});
