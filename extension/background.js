const api = globalThis.browser ?? chrome;
const BRIDGE = 'http://127.0.0.1:19919';

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

api.runtime.onMessage.addListener((message, sender, reply) => {
  const routes = {
    lookup: () => call('/lookup', { url: message.url }),
    fill: () => call('/fill', { id: message.id }),
    save: () =>
      call('/save', { url: message.url, username: message.username, password: message.password }),
  };
  const route = routes[message.type];
  if (!route) return false;
  route().then(reply);
  return true;
});
