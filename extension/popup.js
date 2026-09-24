const api = globalThis.browser ?? chrome;
const t = (key, ...subs) => api.i18n.getMessage(key, subs);
const ORIGINS = ['http://127.0.0.1:19919/*', '*://*/*'];
const content = document.getElementById('content');
content.textContent = t('lookingForMatches');

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
  hint.textContent = t('permissionHint');
  const button = document.createElement('button');
  button.textContent = t('allow');
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
  hint.textContent = t('pairingHint');
  const input = document.createElement('input');
  input.placeholder = t('pairingToken');
  const button = document.createElement('button');
  button.textContent = t('connect');
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
      ? t('offerKnownFailed')
      : offer.failed
        ? t('offerFailed')
        : offer.changed
          ? t('offerChanged')
          : t('offerNew');
    box.append(title, user, note);

    const review = document.createElement('div');
    review.className = 'review';
    const answers = [
      ['✓', true, 'yes', offer.failed ? t('saveAnyway') : offer.changed ? t('update') : t('save')],
      ['✕', false, 'no', offer.known ? t('ok') : t('forgetIt')],
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

// "Pin this code to the site?" after a code with no site was used there.
function renderPins(pins) {
  for (const pin of pins) {
    const row = document.createElement('div');
    row.className = 'entry pending';
    const box = document.createElement('div');
    const title = document.createElement('div');
    title.className = 'title';
    title.textContent = pin.title || t('twoFactorCode');
    const note = document.createElement('div');
    note.className = 'note';
    note.textContent = t('pinThisCode', pin.host);
    box.append(title, note);
    const answers = document.createElement('div');
    answers.className = 'review';
    for (const [label, yes, cls, tip] of [
      ['✓', true, 'yes', t('pinIt')],
      ['✕', false, 'no', t('notNow')],
    ]) {
      const b = document.createElement('button');
      b.textContent = label;
      b.className = cls;
      b.title = tip;
      b.onclick = async () => {
        await api.runtime.sendMessage({ type: 'pin-answer', key: pin.key, yes });
        load();
      };
      answers.append(b);
    }
    row.append(box, answers);
    content.append(row);
  }
}

function render(entries, tab, alone) {
  if (entries.length === 0) {
    const hint = document.createElement('p');
    hint.className = 'muted';
    hint.textContent = t('noEntryYet');
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

    if (entry.duplicate) {
      const badge = document.createElement('span');
      badge.className = 'badge duplicate';
      badge.title = t('duplicateHint');
      badge.textContent = t('duplicate');
      row.append(badge);
    }
    if (entry.hasCode) {
      const badge = document.createElement('span');
      badge.className = 'badge';
      badge.textContent = '2FA';
      row.append(badge);
    }

    // Edit: in Keyhold's window when the app runs here, otherwise on a page of its own.
    const pencil = document.createElement('button');
    pencil.className = 'pencil';
    pencil.title = t('edit');
    pencil.textContent = '✎';
    pencil.onclick = async (e) => {
      e.stopPropagation();
      if (alone) {
        await api.tabs.create({ url: api.runtime.getURL(`edit.html?id=${encodeURIComponent(entry.id)}`) });
      } else {
        await api.runtime.sendMessage({ type: 'open', id: entry.id });
      }
      window.close();
    };
    row.append(pencil);

    row.onclick = async () => {
      const data = await api.runtime.sendMessage({ type: 'fill', id: entry.id });
      if (!data || data.error) {
        message(t('appDidNotAnswer'));
        return;
      }
      const [result] = await api.scripting.executeScript({
        target: { tabId: tab.id, allFrames: false },
        func: fillPage,
        args: [data],
      });
      if (result && result.result === 'none') {
        message(t('noLoginField'));
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
    message(t('openWebsiteFirst'));
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
  const pins = await api.runtime.sendMessage({ type: 'pins' });
  content.className = '';
  content.innerHTML = '';
  renderPins(pins || []);
  renderOffers(offers || []);
  render(result.entries || [], tab, result.alone === true);
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
    ? t('pairedNotRunning')
    : t('notRunning');
  const drive = document.createElement('button');
  drive.textContent = t('useDriveVault');
  const note = document.createElement('p');
  note.className = 'muted small';
  note.textContent = t('driveVaultHint');
  drive.onclick = async () => {
    drive.disabled = true;
    drive.textContent = t('connecting');
    const result = await api.runtime.sendMessage({ type: 'alone-connect' });
    if (result && result.ok) {
      unlockScreen();
      return;
    }
    drive.disabled = false;
    drive.textContent = t('useDriveVault');
    note.textContent = (result && result.error) || t('driveNotConnected');
  };
  const pair = document.createElement('a');
  pair.href = '#';
  pair.className = 'link';
  pair.textContent = token ? t('pairAgain') : t('pairWithApp');
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
  hint.textContent = t('masterPasswordOfVault');
  const input = document.createElement('input');
  input.type = 'password';
  input.autofocus = true;
  // Our own eye: Edge's built-in one goes away once the field was left.
  const field = document.createElement('div');
  field.className = 'with-eye';
  const eye = document.createElement('button');
  eye.className = 'eye';
  eye.title = t('show');
  eye.textContent = '👁';
  eye.onclick = () => {
    input.type = input.type === 'password' ? 'text' : 'password';
    input.focus();
  };
  field.append(input, eye);
  const button = document.createElement('button');
  button.textContent = t('unlock');
  const note = document.createElement('p');
  note.className = 'muted small';
  const unlock = async () => {
    button.disabled = true;
    button.textContent = t('opening');
    const result = await api.runtime.sendMessage({ type: 'alone-unlock', password: input.value });
    if (result && result.ok) {
      load();
      return;
    }
    button.disabled = false;
    button.textContent = t('unlock');
    note.textContent = (result && result.error) || t('vaultDidNotOpen');
    input.select();
  };
  button.onclick = unlock;
  input.onkeydown = (e) => {
    if (e.key === 'Enter') unlock();
  };
  const disconnect = document.createElement('a');
  disconnect.href = '#';
  disconnect.className = 'link';
  disconnect.textContent = t('disconnectDrive');
  disconnect.onclick = async (e) => {
    e.preventDefault();
    await api.runtime.sendMessage({ type: 'alone-disconnect' });
    load();
  };
  content.append(hint, field, button, note, disconnect);
  input.focus();
}

function aloneFooter() {
  const row = document.createElement('div');
  row.className = 'alone';
  const text = document.createElement('span');
  text.textContent = t('vaultFromDrive');
  const lock = document.createElement('button');
  lock.textContent = t('lock');
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
  row.title = t('autoSaveHint');
  const box = document.createElement('input');
  box.type = 'checkbox';
  box.checked = on;
  box.onchange = () => api.runtime.sendMessage({ type: 'autosave', on: box.checked });
  const text = document.createElement('span');
  text.textContent = t('autoSave');
  row.append(box, text);
  content.append(row);
}

// The struck-through lock by the title: saving off (or back on) for this site.
function neverSwitch(never, tab) {
  const button = document.getElementById('never');
  const host = new URL(tab.url).hostname;
  button.hidden = false;
  button.classList.toggle('on', never);
  button.title = never ? t('neverOn', host) : t('neverOff');
  button.onclick = async () => {
    await api.runtime.sendMessage({ type: 'never', on: !never, url: tab.url });
    load();
  };
}

load();
