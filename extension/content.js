// Shows Keyhold logins and two-factor codes right under the field, and saves
// logins as soon as a form with a password is sent.
const api = globalThis.browser ?? chrome;

const ICON =
  'data:image/svg+xml;utf8,' +
  encodeURIComponent(
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">' +
      '<rect x="2" y="2" width="20" height="20" rx="6" fill="#1B2A26"/>' +
      '<path d="M9 11V9a3 3 0 0 1 6 0v2" stroke="#1FCFB4" stroke-width="1.8" fill="none"/>' +
      '<rect x="7.5" y="11" width="9" height="6.5" rx="1.5" fill="#1FCFB4"/></svg>'
  );

const CODE_WORDS = /one.?time|otp|totp|2fa|mfa|two.?factor|authenticat|verification|security.?code|\bcode\b|kod/;
const NOT_CODE = /zip|postal|post.?code|poczt|promo|coupon|voucher|country|phone|captcha|discount|rabat/;
const USER_WORDS = /user|login|e-?mail|mail|account|identifier|nazwa|konto/;
const SUBMIT_WORDS = /log.?in|sign.?in|zaloguj|continue|next|dalej|submit|verify|weryfik|potwierd|wejd/;

const describe = (el) =>
  `${el.name} ${el.id} ${el.autocomplete} ${el.placeholder} ${el.getAttribute('aria-label') || ''}`.toLowerCase();

const shown = (el) =>
  el.isConnected && !el.disabled && el.getClientRects().length > 0 && el.getBoundingClientRect().width > 20;

// Component-based pages (Home Assistant and many others) keep their login
// fields inside shadow roots, which plain querySelectorAll never reaches.
const watchedRoots = new WeakSet();
let rescan = () => {};

function deepInputs(root = document, out = []) {
  for (const el of root.querySelectorAll('*')) {
    if (el.tagName === 'INPUT') out.push(el);
    const inner = el.shadowRoot;
    if (inner) {
      if (!watchedRoots.has(inner)) {
        watchedRoots.add(inner);
        new MutationObserver(() => rescan()).observe(inner, { childList: true, subtree: true });
      }
      deepInputs(inner, out);
    }
  }
  return out;
}

const inputsIn = (scope) => (scope === document ? deepInputs() : [...scope.querySelectorAll('input')]);
const pathOf = (e) => (e.composedPath ? e.composedPath() : [e.target]);

function kindOf(input) {
  const type = (input.type || 'text').toLowerCase();
  if (type === 'password') return 'login';
  if (!['text', 'email', 'tel', 'number'].includes(type)) return null;
  const words = describe(input);
  if (input.autocomplete === 'one-time-code') return 'code';
  if (CODE_WORDS.test(words) && !NOT_CODE.test(words)) return 'code';
  if (type === 'email' || input.autocomplete === 'username' || USER_WORDS.test(words)) return 'login';
  if (input.form && input.form.querySelector('input[type="password"]')) return 'login';
  return null;
}

function usernameFieldFor(passwordField) {
  const all = inputsIn(passwordField.form || document);
  const candidates = all.filter((input) => {
    if (input === passwordField || !shown(input)) return false;
    return ['text', 'email', 'tel'].includes((input.type || 'text').toLowerCase()) && kindOf(input) !== 'code';
  });
  // The username field comes before the password one.
  const before = candidates.filter((input) => all.indexOf(input) < all.indexOf(passwordField));
  const pool = before.length ? before : candidates;
  const named = pool.filter((input) => USER_WORDS.test(describe(input)) || input.type === 'email');
  return named.pop() || pool.pop() || null;
}

function setValue(input, value) {
  if (!input || value == null) return;
  const setter = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value').set;
  input.focus();
  setter.call(input, value);
  input.dispatchEvent(new Event('input', { bubbles: true }));
  input.dispatchEvent(new Event('change', { bubbles: true }));
}

function fillLogin(field, data) {
  const all = inputsIn(field.form || document);
  const isPassword = field.type === 'password';
  const passwords = all.filter((i) => i.type === 'password' && shown(i));
  const password = isPassword
    ? field
    : passwords.find((p) => all.indexOf(p) > all.indexOf(field)) || passwords[0];
  const user = isPassword ? usernameFieldFor(field) : field;
  if (data.username) setValue(user, data.username);
  if (data.password) setValue(password, data.password);
}

// Some sites split the code into one box per digit.
function fillCode(field, code) {
  if (field.maxLength === 1) {
    let box = field.parentElement;
    for (let depth = 0; box && depth < 4; depth++, box = box.parentElement) {
      const digits = [...box.querySelectorAll('input')].filter((i) => i.maxLength === 1 && shown(i));
      if (digits.length >= code.length) {
        code.split('').forEach((digit, i) => setValue(digits[i], digit));
        return;
      }
    }
  }
  setValue(field, code);
}

// ---------- entries for this page ----------

let lookup = null;
const entries = () =>
  (lookup ??= api.runtime
    .sendMessage({ type: 'lookup' })
    .then((r) => (r && r.entries) || [])
    .catch(() => []));

// ---------- fields ----------

const kinds = new WeakMap();

async function scan() {
  const found = deepInputs().filter((i) => !kinds.has(i) && shown(i) && kindOf(i));
  if (found.length === 0) return;

  const list = await entries();
  if (list.length === 0) return;
  const withCode = list.some((e) => e.hasCode);

  for (const input of found) {
    const kind = kindOf(input);
    if (kind === 'code' && !withCode) continue;
    kinds.set(input, kind);
    // Password fields usually carry the page's own "show password" eye there.
    if (input.type !== 'password') {
      input.style.setProperty('background-image', `url("${ICON}")`, 'important');
      input.style.setProperty('background-repeat', 'no-repeat', 'important');
      input.style.setProperty('background-position', 'right 8px center', 'important');
      input.style.setProperty('background-size', '18px 18px', 'important');
      // A hand over the icon, so it reads as something to click.
      input.addEventListener('mousemove', (e) => {
        const onIcon = e.clientX > input.getBoundingClientRect().right - 34;
        input.style.cursor = onIcon ? 'pointer' : '';
      });
    }
    input.addEventListener('mousedown', (e) => e.isTrusted && openMenu(input));
    input.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowDown' && !menu) openMenu(input);
    });
  }
}

let scanTimer = 0;
rescan = () => {
  clearTimeout(scanTimer);
  scanTimer = setTimeout(scan, 400);
};
new MutationObserver(() => rescan()).observe(document.documentElement, { childList: true, subtree: true });
scan();

// ---------- dropdown ----------

const STYLE = `
  :host { all: initial; }
  .menu { position: fixed; z-index: 2147483647; background: #16211E; color: #E8F5F1; border-radius: 10px;
    box-shadow: 0 8px 28px rgba(0,0,0,.45); padding: 6px; font: 14px system-ui, sans-serif; max-height: 320px;
    overflow-y: auto; box-sizing: border-box; }
  .row { display: flex; align-items: center; gap: 12px; padding: 9px 12px; border-radius: 7px; cursor: pointer; }
  .row.active, .row:hover { background: #1FCFB4; color: #0C1714; }
  .row.active .sub, .row:hover .sub, .row.active .group, .row:hover .group { color: #0C1714; }
  .text { flex: 1; min-width: 0; }
  .title { font-weight: 600; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .sub { color: #9FB8B0; font-size: 12.5px; margin-top: 2px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
  .group { color: #7F9A92; font-size: 11px; font-weight: 600; text-transform: uppercase; letter-spacing: .04em; }
  .group.pending, .row:not(.active):not(:hover) .title.pending { color: #F29A2E; }
  .code { font: 600 18px ui-monospace, Consolas, monospace; letter-spacing: 1px; text-align: right; }
  .bar { height: 2px; background: currentColor; opacity: .6; margin-top: 4px; transition: width 1s linear; }
`;

let menu = null;

function closeMenu() {
  if (!menu) return;
  clearInterval(menu.timer);
  menu.host.remove();
  window.removeEventListener('scroll', menu.place, true);
  window.removeEventListener('resize', menu.place);
  menu.field.removeEventListener('keydown', menu.keys, true);
  menu.field.removeEventListener('blur', menu.blur);
  menu = null;
}

async function openMenu(field) {
  if (menu && menu.field === field) return;
  closeMenu();

  const kind = kinds.get(field);
  let items = await entries();
  if (kind === 'code') items = items.filter((e) => e.hasCode);
  if (items.length === 0) return;

  const host = document.createElement('keyhold-menu');
  const root = host.attachShadow({ mode: 'closed' });
  const style = document.createElement('style');
  style.textContent = STYLE;
  const box = document.createElement('div');
  box.className = 'menu';
  root.append(style, box);
  document.documentElement.appendChild(host);

  const rows = items.map((entry, i) => {
    const row = document.createElement('div');
    row.className = 'row';
    const text = document.createElement('div');
    text.className = 'text';
    const title = document.createElement('div');
    title.className = entry.pending ? 'title pending' : 'title';
    title.textContent = entry.title;
    const sub = document.createElement('div');
    sub.className = 'sub';
    sub.textContent = entry.username;
    text.append(title, sub);
    row.append(text);

    if (kind === 'code') {
      const code = document.createElement('div');
      code.className = 'code';
      code.textContent = '··· ···';
      const bar = document.createElement('div');
      bar.className = 'bar';
      code.append(bar);
      row.append(code);
      row.code = code;
      row.bar = bar;
    } else if (entry.pending || entry.group) {
      const group = document.createElement('div');
      group.className = entry.pending ? 'group pending' : 'group';
      group.textContent = entry.pending ? 'Not confirmed' : entry.group;
      row.append(group);
    }

    // mousedown keeps the focus in the page field
    row.addEventListener('mousedown', (e) => {
      e.preventDefault();
      if (e.isTrusted) pick(i);
    });
    box.append(row);
    return row;
  });

  menu = { host, field, items, rows, index: -1, codes: {} };

  menu.place = () => {
    if (!field.isConnected) return closeMenu();
    const r = field.getBoundingClientRect();
    const width = Math.max(r.width, 280);
    const below = window.innerHeight - r.bottom;
    box.style.width = `${width}px`;
    box.style.left = `${Math.min(r.left, window.innerWidth - width - 8)}px`;
    if (below < 200 && r.top > below) {
      box.style.top = '';
      box.style.bottom = `${window.innerHeight - r.top + 4}px`;
    } else {
      box.style.bottom = '';
      box.style.top = `${r.bottom + 4}px`;
    }
  };
  menu.keys = (e) => {
    if (e.key === 'Escape') return closeMenu();
    if (e.key === 'ArrowDown' || e.key === 'ArrowUp') {
      e.preventDefault();
      const step = e.key === 'ArrowDown' ? 1 : -1;
      highlight((menu.index + step + rows.length) % rows.length);
    } else if (e.key === 'Enter' && menu.index >= 0) {
      e.preventDefault();
      e.stopPropagation();
      pick(menu.index);
    }
  };
  menu.blur = () => setTimeout(() => document.activeElement !== field && closeMenu(), 150);

  menu.place();
  window.addEventListener('scroll', menu.place, true);
  window.addEventListener('resize', menu.place);
  field.addEventListener('keydown', menu.keys, true);
  field.addEventListener('blur', menu.blur);

  if (kind === 'code') {
    const tick = async () => {
      if (!menu) return;
      const left = 30 - (Math.floor(Date.now() / 1000) % 30);
      if (left === 30 || !menu.loaded) {
        menu.loaded = true;
        await Promise.all(
          items.map(async (entry, i) => {
            const r = await api.runtime.sendMessage({ type: 'code', id: entry.id });
            if (!menu || !r || !r.code) return;
            menu.codes[i] = r.code;
            rows[i].code.firstChild.textContent = `${r.code.slice(0, 3)} ${r.code.slice(3)}`;
          })
        );
      }
      rows.forEach((row) => (row.bar.style.width = `${(left / 30) * 100}%`));
    };
    tick();
    menu.timer = setInterval(tick, 1000);
  }
}

function highlight(index) {
  menu.rows.forEach((row, i) => row.classList.toggle('active', i === index));
  menu.index = index;
  menu.rows[index]?.scrollIntoView({ block: 'nearest' });
}

async function pick(index) {
  const { field, items, codes } = menu;
  const entry = items[index];

  if (kinds.get(field) === 'code') {
    const code = codes[index];
    closeMenu();
    if (code) fillCode(field, code);
    return;
  }

  closeMenu();
  const data = await api.runtime.sendMessage({ type: 'fill', id: entry.id });
  if (data && !data.error) fillLogin(field, data);
}

document.addEventListener(
  'mousedown',
  (e) => {
    const path = pathOf(e);
    if (menu && !path.includes(menu.field) && !path.includes(menu.host)) closeMenu();
  },
  true
);

// ---------- saving ----------

let lastSent = '';

function capture(scope) {
  const inputs = inputsIn(scope);
  const passwords = inputs.filter((p) => p.type === 'password' && p.value);

  if (passwords.length === 0) {
    const user = inputs.find(
      (i) => i.type !== 'password' && kindOf(i) === 'login' && i.value.trim() && shown(i)
    );
    if (user) api.runtime.sendMessage({ type: 'user', username: user.value.trim() });
    return;
  }

  // On a change-password form the last field holds the new password.
  const password = passwords[passwords.length - 1].value;
  const userField = usernameFieldFor(passwords[0]);
  const username = userField ? userField.value.trim() : '';

  const key = `${username}\n${password}`;
  if (key === lastSent) return;
  lastSent = key;
  api.runtime.sendMessage({ type: 'save', username, password }).catch(() => {});
}

document.addEventListener('submit', (e) => capture(e.target), true);

document.addEventListener(
  'keydown',
  (e) => {
    const input = pathOf(e)[0];
    if (e.key !== 'Enter' || !(input instanceof HTMLInputElement)) return;
    if (menu && menu.index >= 0) return;
    capture(input.form || document);
  },
  true
);

document.addEventListener(
  'click',
  (e) => {
    if (!e.isTrusted) return;
    const button = pathOf(e).find(
      (n) => n instanceof Element && n.matches('button, input[type="submit"], [role="button"]')
    );
    if (!button) return;
    const words = `${button.textContent} ${button.value || ''} ${button.getAttribute('aria-label') || ''}`.toLowerCase();
    if (button.type !== 'submit' && !SUBMIT_WORDS.test(words)) return;
    capture(button.form || button.closest('form') || document);
  },
  true
);

// ---------- notices ----------

function bar(build) {
  document.getElementById('keyhold-bar')?.remove();
  const host = document.createElement('div');
  host.id = 'keyhold-bar';
  const root = host.attachShadow({ mode: 'closed' });
  const style = document.createElement('style');
  style.textContent = `
    .bar { position: fixed; z-index: 2147483647; right: 16px; bottom: 16px; background: #1B2A26; color: #E8F5F1;
      font: 14px system-ui, sans-serif; padding: 12px 14px; border-radius: 10px; box-shadow: 0 6px 24px rgba(0,0,0,.4);
      display: flex; gap: 10px; align-items: center; }
    button { background: #1FCFB4; color: #0C1714; border: 0; border-radius: 6px; padding: 6px 12px; cursor: pointer;
      font: 500 14px system-ui, sans-serif; }
    button.plain { background: transparent; color: #9FE1CB; }
  `;
  const box = document.createElement('div');
  box.className = 'bar';
  root.append(style, box);
  build(box, () => host.remove());
  document.documentElement.appendChild(host);
  return host;
}

async function showNotice() {
  const notice = await api.runtime.sendMessage({ type: 'pending' }).catch(() => null);
  if (!notice) return;
  const who = notice.username || 'this login';

  if (notice.result === 'created') {
    const host = bar((box) => (box.textContent = `Saved ${who} to Keyhold`));
    setTimeout(() => host.remove(), 4000);
    return;
  }

  if (notice.result === 'changed') {
    bar((box, close) => {
      const text = document.createElement('span');
      text.textContent = `Update the password for ${who} on ${notice.host}?`;
      const yes = document.createElement('button');
      yes.textContent = 'Update';
      yes.onclick = async (e) => {
        if (!e.isTrusted) return;
        const result = await api.runtime.sendMessage({ type: 'update' });
        text.textContent = result?.result === 'updated' ? 'Password updated' : 'Keyhold is not running';
        yes.remove();
        no.remove();
        setTimeout(close, 2500);
      };
      const no = document.createElement('button');
      no.className = 'plain';
      no.textContent = 'Not now';
      no.onclick = (e) => {
        if (!e.isTrusted) return;
        api.runtime.sendMessage({ type: 'dismiss' });
        close();
      };
      box.append(text, yes, no);
    });
  }
}

// Notices belong to the page itself, not to a login frame inside it.
if (window.top === window) {
  showNotice();
  api.runtime.onMessage.addListener((message) => {
    if (message.type === 'notice') showNotice();
  });
}
