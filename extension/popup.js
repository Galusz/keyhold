const api = globalThis.browser ?? chrome;
const ORIGINS = ['http://127.0.0.1:19919/*', '*://*/*'];
const content = document.getElementById('content');

// Runs inside the page, so it must not reference anything outside itself.
function fillPage(data) {
  const visible = (el) => el && !el.disabled && el.getClientRects().length > 0;
  // Includes fields inside shadow roots (Home Assistant and other component pages).
  const deep = (root, out = []) => {
    for (const el of root.querySelectorAll('*')) {
      if (el.tagName === 'INPUT') out.push(el);
      if (el.shadowRoot) deep(el.shadowRoot, out);
    }
    return out;
  };
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

  const inputs = deep(document).filter(visible);
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

// Logins Keyhold caught and holds for two minutes: nothing is saved until ✓.
function renderOffers(offers) {
  for (const offer of offers) {
    const row = document.createElement('div');
    row.className = offer.failed ? 'entry failed' : 'entry pending';
    siteIcon(row, offer.icon, offer.host);

    const box = document.createElement('div');
    const title = document.createElement('div');
    title.className = 'title';
    title.textContent = offer.host;
    const user = document.createElement('div');
    user.className = 'user';
    user.textContent = offer.username;
    const note = document.createElement('div');
    note.className = 'note';
    note.textContent = offer.known
      ? 'The saved password did not work. Sign in with the new one and Keyhold will offer to update it.'
      : offer.failed
        ? 'This login did not work'
        : offer.changed
          ? 'Update the password in Keyhold?'
          : 'Save this login in Keyhold?';
    box.append(title, user, note);

    const review = document.createElement('div');
    review.className = 'review';
    const answers = [
      ['✓', true, 'yes', offer.failed ? 'Save anyway' : offer.changed ? 'Update' : 'Save'],
      ['✕', false, 'no', offer.known ? 'OK' : 'Forget it'],
    ];
    for (const [label, keep, cls, tip] of offer.known ? answers.slice(1) : answers) {
      const b = document.createElement('button');
      b.textContent = label;
      b.className = cls;
      b.title = tip;
      b.onclick = async () => {
        await api.runtime.sendMessage({ type: 'review', id: offer.id, keep });
        load();
      };
      review.append(b);
    }
    row.append(box, review);
    content.append(row);
  }
}

// The site's icon from Keyhold, or its first letter.
function siteIcon(row, icon, name) {
  const box = document.createElement('div');
  box.className = 'site';
  const letter = () => {
    box.classList.add('letter');
    box.textContent = (name || '?').charAt(0).toUpperCase();
  };
  if (icon) {
    const image = document.createElement('img');
    image.src = icon;
    image.alt = '';
    image.onerror = () => {
      image.remove();
      letter();
    };
    box.append(image);
  } else {
    letter();
  }
  row.append(box);
}

function render(entries, tab) {
  if (entries.length === 0) {
    const hint = document.createElement('p');
    hint.className = 'muted';
    hint.textContent = 'No entry for this site yet. Log in once and Keyhold will offer to save it.';
    content.append(hint);
    return;
  }

  for (const entry of entries) {
    const row = document.createElement('div');
    row.className = 'entry';
    siteIcon(row, entry.icon, entry.title);

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
  document.getElementById('never').hidden = true;
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
  if (!result || result.error === 'bad token') {
    pairingScreen();
    return;
  }
  if (result.error === 'no token' || result.error === 'app offline') {
    const alone = await api.runtime.sendMessage({ type: 'alone' });
    if (alone && alone.state === 'locked') unlockScreen();
    else noAppScreen();
    return;
  }
  if (result.error) {
    message(result.error);
    return;
  }
  const offers = await api.runtime.sendMessage({ type: 'offers' });
  content.className = '';
  content.innerHTML = '';
  renderOffers(offers || []);
  render(result.entries || [], tab);
  neverSwitch(result.never === true, tab);
  autoSaveSwitch(result.autoSave === true);
  if (result.alone) aloneFooter();
}

// No Keyhold app on this computer: the vault can come from Google Drive instead.
async function noAppScreen() {
  const { token } = await api.storage.local.get('token');
  content.className = '';
  content.innerHTML = '';
  const hint = document.createElement('p');
  hint.className = 'muted';
  hint.textContent = token
    ? 'Paired with the Keyhold app on this computer, but it is not running. Start Keyhold and it takes over.'
    : 'Keyhold is not running on this computer.';
  const drive = document.createElement('button');
  drive.textContent = 'Use my vault from Google Drive';
  const note = document.createElement('p');
  note.className = 'muted small';
  note.textContent = 'It stays encrypted and opens here with your master password.';
  drive.onclick = async () => {
    drive.disabled = true;
    drive.textContent = 'Connecting…';
    const result = await api.runtime.sendMessage({ type: 'alone-connect' });
    if (result && result.ok) {
      unlockScreen();
      return;
    }
    drive.disabled = false;
    drive.textContent = 'Use my vault from Google Drive';
    note.textContent = (result && result.error) || 'Google Drive was not connected.';
  };
  const pair = document.createElement('a');
  pair.href = '#';
  pair.className = 'link';
  pair.textContent = token ? 'Pair again' : 'The Keyhold app runs here — pair with it';
  pair.onclick = (e) => {
    e.preventDefault();
    pairingScreen();
  };
  content.append(hint, drive, note, pair);
}

function unlockScreen() {
  content.className = '';
  content.innerHTML = '';
  const hint = document.createElement('p');
  hint.className = 'muted';
  hint.textContent = 'Master password of your Keyhold vault';
  const input = document.createElement('input');
  input.type = 'password';
  input.autofocus = true;
  const button = document.createElement('button');
  button.textContent = 'Unlock';
  const note = document.createElement('p');
  note.className = 'muted small';
  const unlock = async () => {
    button.disabled = true;
    button.textContent = 'Opening…';
    const result = await api.runtime.sendMessage({ type: 'alone-unlock', password: input.value });
    if (result && result.ok) {
      load();
      return;
    }
    button.disabled = false;
    button.textContent = 'Unlock';
    note.textContent = (result && result.error) || 'The vault did not open.';
    input.select();
  };
  button.onclick = unlock;
  input.onkeydown = (e) => {
    if (e.key === 'Enter') unlock();
  };
  const disconnect = document.createElement('a');
  disconnect.href = '#';
  disconnect.className = 'link';
  disconnect.textContent = 'Disconnect Google Drive';
  disconnect.onclick = async (e) => {
    e.preventDefault();
    await api.runtime.sendMessage({ type: 'alone-disconnect' });
    load();
  };
  content.append(hint, input, button, note, disconnect);
  input.focus();
}

function aloneFooter() {
  const row = document.createElement('div');
  row.className = 'alone';
  const text = document.createElement('span');
  text.textContent = 'Vault from Google Drive';
  const lock = document.createElement('button');
  lock.textContent = 'Lock';
  lock.onclick = async () => {
    await api.runtime.sendMessage({ type: 'alone-lock' });
    load();
  };
  row.append(text, lock);
  content.append(row);
}

function autoSaveSwitch(on) {
  const row = document.createElement('label');
  row.className = 'switch';
  row.title = 'When a login clearly works, Keyhold keeps it straight away';
  const box = document.createElement('input');
  box.type = 'checkbox';
  box.checked = on;
  box.onchange = () => api.runtime.sendMessage({ type: 'autosave', on: box.checked });
  const text = document.createElement('span');
  text.textContent = 'Save logins without asking';
  row.append(box, text);
  content.append(row);
}

// The struck-through lock by the title: saving off (or back on) for this site.
function neverSwitch(never, tab) {
  const button = document.getElementById('never');
  const host = new URL(tab.url).hostname;
  button.hidden = false;
  button.classList.toggle('on', never);
  button.title = never ? `Logins are not saved on ${host} — click to allow` : 'Never save logins on this site';
  button.onclick = async () => {
    await api.runtime.sendMessage({ type: 'never', on: !never, url: tab.url });
    load();
  };
}

load();
