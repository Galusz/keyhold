// One login from the vault opened from Google Drive, with the same fields as
// the app's edit screen. Saving writes straight back to Drive.
const api = globalThis.browser ?? chrome;
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
    x.title = 'Remove';
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
    empty.textContent = 'Not used anywhere yet. It pins itself the first time you use it on a site, or pin it from a login.';
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
    status('This login is not in the open vault. Unlock Keyhold in the toolbar and try again.');
    field('save').disabled = true;
    field('delete').disabled = true;
    return;
  }
  // A two-factor code of its own: name, key, note, address.
  if (result.code) {
    document.body.classList.add('is-code');
    field('title-label').textContent = 'Name';
    field('notes-label').textContent = 'Note';
    sites = [...(result.sites || [])];
    pinned = result.pinned || [];
    renderSites();
  }
  for (const code of result.codes || []) {
    const option = document.createElement('option');
    option.value = code.id;
    option.textContent = `${code.title || '(no name)'} — ${code.code.slice(0, 3)} ${code.code.slice(3)}`;
    field('twoFactor').append(option);
  }
  for (const name of FIELDS) field(name).value = result.entry[name] || '';
  field('heading').textContent = result.entry.title || (result.code ? 'Two-factor code' : 'Edit login');
  document.title = `Keyhold — ${result.entry.title || 'edit'}`;
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
  status('Saving to Google Drive…');
  const result = await api.runtime.sendMessage({ type: 'put', entry });
  if (result && result.result === 'saved') window.close();
  else status((result && result.error) || 'Not saved.');
};

field('delete').onclick = async () => {
  if (!confirm('Delete this login from Keyhold?')) return;
  status('Deleting…');
  const result = await api.runtime.sendMessage({ type: 'delete', id });
  if (result && result.result === 'deleted') window.close();
  else status((result && result.error) || 'Not deleted.');
};

field('add-site').onclick = addSite;
field('new-site').onkeydown = (e) => {
  if (e.key === 'Enter') addSite();
};

open();
