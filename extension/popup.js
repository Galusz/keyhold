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
    note.textContent = offer.failed
      ? 'This login did not work'
      : offer.changed
        ? 'Update the password in Keyhold?'
        : 'Save this login in Keyhold?';
    box.append(title, user, note);

    const review = document.createElement('div');
    review.className = 'review';
    for (const [label, keep, cls, tip] of [
      ['✓', true, 'yes', offer.failed ? 'Save anyway' : offer.changed ? 'Update' : 'Save'],
      ['✕', false, 'no', 'Forget it'],
    ]) {
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
  const offers = await api.runtime.sendMessage({ type: 'offers' });
  content.className = '';
  content.innerHTML = '';
  renderOffers(offers || []);
  render(result.entries || [], tab);
  neverSwitch(result.never === true, tab);
  autoSaveSwitch(result.autoSave === true);
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

// Stop sign: switches saving off (or back on) for the site in this tab.
function neverSwitch(never, tab) {
  const host = new URL(tab.url).hostname;
  const row = document.createElement('div');
  row.className = never ? 'never on' : 'never';
  const text = document.createElement('span');
  text.textContent = never ? `⛔ Logins are not saved on ${host}` : '⛔ Never save logins on this site';
  row.append(text);
  if (never) {
    const allow = document.createElement('button');
    allow.textContent = 'Allow';
    allow.onclick = async () => {
      await api.runtime.sendMessage({ type: 'never', on: false, url: tab.url });
      load();
    };
    row.append(allow);
  } else {
    row.onclick = async () => {
      await api.runtime.sendMessage({ type: 'never', on: true, url: tab.url });
      load();
    };
  }
  content.append(row);
}

load();
