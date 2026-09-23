const BRIDGE = 'http://127.0.0.1:19919';

async function token() {
  const stored = await chrome.storage.local.get('token');
  return stored.token || '';
}

async function call(path, body) {
  const value = await token();
  if (!value) return { error: 'no token' };

  try {
    const response = await fetch(BRIDGE + path, {
      method: 'POST',
      headers: {
        'content-type': 'application/json',
        'x-keyhold-token': value,
      },
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

chrome.runtime.onMessage.addListener((message, sender, reply) => {
  if (message.type === 'lookup') {
    call('/lookup', { url: message.url }).then(reply);
    return true;
  }
  if (message.type === 'fill') {
    call('/fill', { id: message.id }).then(reply);
    return true;
  }
  if (message.type === 'save') {
    call('/save', {
      url: message.url,
      username: message.username,
      password: message.password,
    }).then(reply);
    return true;
  }
  return false;
});
