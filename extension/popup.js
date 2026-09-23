const api = globalThis.browser ?? chrome;
const ORIGINS = ['http://127.0.0.1:19919/*', '*://*/*'];
const content = document.getElementById('content');

// Runs inside the page, so it must not reference anything outside itself.
function fillPage(data) {
  const visible = (el) => el && el.offsetParent !== null && !el.disabled;
  const describe = (el) =>
    `${el.name} ${el.id} ${el.autocomplete} ${el.placeholder} ${el.getAttribute('aria-label') || ''}`.toLowerCase();
  const setValue = (input, value) => {
    if (!input || value == null) return false;
    const setter = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set;
    input.focus();
    setter.call(input, value);
    input.dispatchEvent(new Event('input', { bubbles: true }));
    input.dispatchEvent(new Event('change', { bubbles: true }));
    return true;
  };

  const inputs = [...document.querySelectorAll('input')].filter(visible);
  const password = inputs.find((i) => i.type === 'password');
  const code = inputs.find(
    (i) =>
      i.type !== 'password' &&
      (i.autocomplete === 'one-time-code' || /otp|totp|2fa|two.?factor|one.?time|verification|kod|code/.test(describe(i)))
  );
  const textual = inputs.filter(
    (i) => i !== password && i !== code && ['text', 'email', 'tel', ''].includes((i.type || 'text').toLowerCase())
  );
  const user =
    textual.filter((i) => /user|login|email|mail|account|nazwa/.test(describe(i))).pop() ||
    textual[0] ||
    null;

  // Two-factor step: only a code field on screen.
  if (code && !password && data.code) return setValue(code, data.code) ? 'code' : 'none';

  // Normal login: username and password together.
  if (password) {
    setValue(user, data.username);
    setValue(password, data.password);
    return 'login';
  }

  // First step of a two-step login: only the username is asked for.
  if (user) return setValue(user, data.username) ? 'username' : 'none';
  return 'none';
}

function message(text) {
  content.className = 'muted';
  content.textContent = text;
}

function permissionScreen() {
  content.className = '';
  content.innerHTML = '';
  const hint = document.createElement('p');
  hint.className = 'muted';
  hint.textContent = 'Keyhold needs your permission to talk to the app on this computer and to fill login forms.';
  const button = document.createElement('button');
  button.textContent = 'Allow';
  button.onclick = async () => {
    const granted = await api.permissions.request({ origins: ORIGINS });
    if (granted) load();
  };
  content.append(hint, button);
}

function pairingScreen() {
  content.className = '';
  content.innerHTML = '';
  const hint = document.createElement('p');
  hint.className = 'muted';
  hint.textContent = 'Open Keyhold, click the puzzle icon and paste the pairing token here.';
  const input = document.createElement('input');
  input.placeholder = 'Pairing token';
  const button = document.createElement('button');
  button.textContent = 'Connect';
  button.onclick = async () => {
    await api.storage.local.set({ token: input.value.trim() });
    load();
  };
  content.append(hint, input, button);
}

function render(entries, tab) {
  content.className = '';
  content.innerHTML = '';

  if (entries.length === 0) {
    message('No entry for this site yet. Log in once and Keyhold will offer to save it.');
    return;
  }

  for (const entry of entries) {
    const row = document.createElement('div');
    row.className = 'entry';

    const box = document.createElement('div');
    const title = document.createElement('div');
    title.className = 'title';
    title.textContent = entry.title;
    const user = document.createElement('div');
    user.className = 'user';
    user.textContent = entry.username;
    box.append(title, user);
    row.append(box);

    if (entry.hasCode) {
      const badge = document.createElement('span');
      badge.className = 'badge';
      badge.textContent = '2FA';
      row.append(badge);
    }

    row.onclick = async () => {
      const data = await api.runtime.sendMessage({ type: 'fill', id: entry.id });
      if (!data || data.error) {
        message('Keyhold did not answer. Is the app running?');
        return;
      }
      const [result] = await api.scripting.executeScript({
        target: { tabId: tab.id, allFrames: false },
        func: fillPage,
        args: [data],
      });
      if (result && result.result === 'none') {
        message('No login field found on this page.');
        return;
      }
      window.close();
    };

    content.append(row);
  }
}

async function load() {
  const [tab] = await api.tabs.query({ active: true, currentWindow: true });
  if (!tab || !tab.url || !/^https?:/.test(tab.url)) {
    message('Open a website first.');
    return;
  }

  if (!(await api.permissions.contains({ origins: ORIGINS }))) {
    permissionScreen();
    return;
  }

  const result = await api.runtime.sendMessage({ type: 'lookup', url: tab.url });
  if (!result || result.error === 'no token' || result.error === 'bad token') {
    pairingScreen();
    return;
  }
  if (result.error) {
    message('Keyhold is not running on this computer.');
    return;
  }
  render(result.entries || [], tab);
}

load();
