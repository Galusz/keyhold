const api = globalThis.browser ?? chrome;
const BRIDGE = 'http://127.0.0.1:19919';
const session = api.storage.session;
const NOTICE_TTL = 2 * 60 * 1000;
const USER_TTL = 10 * 60 * 1000;

async function call(path, body) {
  const { token } = await api.storage.local.get('token');
  if (!token) return { error: 'no token' };

  try {
    const response = await fetch(BRIDGE + path, {
      method: 'POST',
      headers: { 'content-type': 'application/json', 'x-keyhold-token': token },
      body: JSON.stringify(body || {}),
    });
    if (!response.ok) {
      return { error: response.status === 401 ? 'bad token' : 'app error' };
    }
    return await response.json();
  } catch (e) {
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

async function save(message, sender) {
  const tabId = sender.tab?.id;
  let username = message.username || '';

  // Two-step logins ask for the username on the page before the password.
  if (!username && tabId != null) {
    const remembered = await read(`user:${tabId}`);
    if (remembered && Date.now() - remembered.at < USER_TTL) username = remembered.username;
  }

  const result = await call('/save', {
    url: sender.url,
    username,
    password: message.password,
    update: false,
  });

  if (tabId != null) refreshIcon(tabId, sender.tab.url);
  if (tabId != null && (result.result === 'created' || result.result === 'changed')) {
    await session.set({
      [`notice:${tabId}`]: {
        result: result.result,
        username,
        host: new URL(sender.url).hostname,
        url: sender.url,
        password: message.password,
        at: Date.now(),
      },
    });
    api.tabs.sendMessage(tabId, { type: 'notice' }, { frameId: 0 }).catch(() => {});
  }
  return result;
}

// What the page should tell the user after a save; the password never goes back to the page.
async function pending(sender) {
  const key = `notice:${sender.tab?.id}`;
  const notice = await read(key);
  if (!notice) return null;
  if (Date.now() - notice.at > NOTICE_TTL) {
    await session.remove(key);
    return null;
  }
  // A changed password stays until the user answers.
  if (notice.result === 'created') await session.remove(key);
  return { result: notice.result, username: notice.username, host: notice.host };
}

async function update(sender) {
  const key = `notice:${sender.tab?.id}`;
  const notice = await read(key);
  if (!notice || notice.result !== 'changed') return { error: 'nothing to update' };
  await session.remove(key);
  return call('/save', {
    url: notice.url,
    username: notice.username,
    password: notice.password,
    update: true,
  });
}

// Orange lock: this site has a login the extension saved but nobody confirmed.
async function refreshIcon(tabId, url) {
  let pending = false;
  if (url && /^https?:/.test(url)) {
    const result = await call('/lookup', { url });
    pending = (result.entries || []).some((e) => e.pending);
  }
  const name = pending ? 'pending' : 'icon';
  api.action
    .setIcon({ tabId, path: { 16: `icons/${name}16.png`, 32: `icons/${name}32.png` } })
    .catch(() => {});
}

api.tabs.onUpdated.addListener((tabId, change, tab) => {
  if (change.status === 'complete') refreshIcon(tabId, tab.url);
});
api.tabs.onActivated.addListener(({ tabId }) =>
  api.tabs.get(tabId).then((tab) => refreshIcon(tabId, tab.url), () => {})
);

async function review(message) {
  const result = await call('/review', { id: message.id, keep: message.keep });
  const [tab] = await api.tabs.query({ active: true, currentWindow: true });
  if (tab) refreshIcon(tab.id, tab.url);
  return result;
}

api.runtime.onMessage.addListener((message, sender, reply) => {
  if (sender.id !== api.runtime.id) return false;

  const routes = {
    lookup: () => call('/lookup', { url: pageUrl(message, sender) }),
    fill: async () => ((await allowed(message, sender)) ? call('/fill', { id: message.id }) : { error: 'denied' }),
    code: async () => ((await allowed(message, sender)) ? call('/code', { id: message.id }) : { error: 'denied' }),
    save: () => save(message, sender),
    user: () => session.set({ [`user:${sender.tab?.id}`]: { username: message.username, at: Date.now() } }),
    pending: () => pending(sender),
    update: () => update(sender),
    dismiss: () => session.remove(`notice:${sender.tab?.id}`),
    review: () => (sender.tab ? { error: 'denied' } : review(message)),
  };
  const route = routes[message.type];
  if (!route) return false;
  Promise.resolve(route()).then(reply, () => reply(null));
  return true;
});

api.tabs.onRemoved.addListener((tabId) => session.remove([`notice:${tabId}`, `user:${tabId}`]));
