// One login from the vault opened from Google Drive, with the same fields as
// the app's edit screen. Saving writes straight back to Drive.
const api = globalThis.browser ?? chrome;
const t = (key, ...subs) => api.i18n.getMessage(key, subs);
for (const el of document.querySelectorAll('[data-i18n]')) el.textContent = t(el.dataset.i18n);
for (const el of document.querySelectorAll('[data-i18n-title]')) el.title = t(el.dataset.i18nTitle);
for (const el of document.querySelectorAll('[data-i18n-placeholder]')) el.placeholder = t(el.dataset.i18nPlaceholder);
const id = new URLSearchParams(location.search).get('id');
const field = (name) => document.getElementById(name);
const status = (text) => (field('status').textContent = text);
const FIELDS = ['title', 'username', 'password', 'url', 'totp', 'group', 'notes', 'twoFactor'];

// A code's addresses: its own ones, and the logins pinned to it (📌).
let sites = [];
let pinned = [];
const unpin = new Set();

function renderSites() {
  const box = field('sites');
  box.innerHTML = '';
  const row = (icon, text, url, remove) => {
    const line = document.createElement('div');
    line.className = 'site';
    const what = document.createElement('div');
    what.className = 'what';
    what.textContent = `${icon} ${text}`;
    if (url) {
      const small = document.createElement('div');
      small.className = 'url';
      small.textContent = url;
      what.append(small);
    }
    const x = document.createElement('button');
    x.textContent = '✕';
    x.title = t('remove');
    x.onclick = () => {
      remove();
      renderSites();
    };
    line.append(what, x);
    box.append(line);
  };
  for (const p of pinned) if (!unpin.has(p.id)) row('📌', p.label, p.url, () => unpin.add(p.id));
  for (const s of sites) row('🌐', s, '', () => (sites = sites.filter((x) => x !== s)));
  if (!box.children.length) {
    const empty = document.createElement('div');
    empty.className = 'empty';
    empty.textContent = t('codeNotUsedYet');
    box.append(empty);
  }
}

function addSite() {
  const value = field('new-site').value.trim();
  if (value && !sites.includes(value)) sites.push(value);
  field('new-site').value = '';
  renderSites();
}

// Like the app: the key from an otpauth:// link, or the pasted key without spaces.
function secretOf(text) {
  const value = text.trim();
  if (value.toLowerCase().startsWith('otpauth://')) {
    try {
      return new URL(value).searchParams.get('secret') || '';
    } catch (e) {
      return value;
    }
  }
  return value.replace(/\s+/g, '');
}

async function open() {
  const result = await api.runtime.sendMessage({ type: 'entry', id });
  if (!result || result.error) {
    status(t('loginNotInVault'));
    field('save').disabled = true;
    field('delete').disabled = true;
    return;
  }
  // A two-factor code of its own: name, key, note, address.
  if (result.code) {
    document.body.classList.add('is-code');
    field('title-label').textContent = t('name');
    field('notes-label').textContent = t('note');
    sites = [...(result.sites || [])];
    pinned = result.pinned || [];
    renderSites();
  }
  for (const code of result.codes || []) {
    const option = document.createElement('option');
    option.value = code.id;
    option.textContent = `${code.title || t('noName')} — ${code.code.slice(0, 3)} ${code.code.slice(3)}`;
    field('twoFactor').append(option);
  }
  for (const name of FIELDS) field(name).value = result.entry[name] || '';
  field('heading').textContent = result.entry.title || (result.code ? t('twoFactorCode') : t('editLogin'));
  document.title = `Keyhold — ${result.entry.title || t('editLogin')}`;
  for (const group of result.groups || []) {
    const option = document.createElement('option');
    option.value = group;
    field('groups').append(option);
  }
}

for (const [eye, input] of [['eye', 'password'], ['key-eye', 'totp']]) {
  field(eye).onclick = () => {
    field(input).type = field(input).type === 'password' ? 'text' : 'password';
  };
}

field('save').onclick = async () => {
  const entry = { id };
  for (const name of FIELDS) entry[name] = field(name).value;
  entry.title = entry.title.trim();
  entry.username = entry.username.trim();
  entry.url = entry.url.trim();
  entry.group = entry.group.trim();
  entry.totp = secretOf(entry.totp);
  addSite();
  entry.sites = sites;
  entry.unpin = [...unpin];
  status(t('savingToDrive'));
  const result = await api.runtime.sendMessage({ type: 'put', entry });
  if (result && result.result === 'saved') window.close();
  else status((result && result.error) || t('notSaved'));
};

field('delete').onclick = async () => {
  if (!confirm(t('deleteConfirm'))) return;
  status(t('deleting'));
  const result = await api.runtime.sendMessage({ type: 'delete', id });
  if (result && result.result === 'deleted') window.close();
  else status((result && result.error) || t('notDeleted'));
};

field('add-site').onclick = addSite;
field('new-site').onkeydown = (e) => {
  if (e.key === 'Enter') addSite();
};

open();
