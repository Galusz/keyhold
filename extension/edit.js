// One login from the vault opened from Google Drive, with the same fields as
// the app's edit screen. Saving writes straight back to Drive.
const api = globalThis.browser ?? chrome;
const id = new URLSearchParams(location.search).get('id');
const field = (name) => document.getElementById(name);
const status = (text) => (field('status').textContent = text);
const FIELDS = ['title', 'username', 'password', 'url', 'totp', 'group', 'notes'];

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
  for (const name of FIELDS) field(name).value = result.entry[name] || '';
  field('heading').textContent = result.entry.title || 'Edit login';
  document.title = `Keyhold — ${result.entry.title || 'edit'}`;
  for (const group of result.groups || []) {
    const option = document.createElement('option');
    option.value = group;
    field('groups').append(option);
  }
}

field('eye').onclick = () => {
  const input = field('password');
  input.type = input.type === 'password' ? 'text' : 'password';
};

field('save').onclick = async () => {
  const entry = { id };
  for (const name of FIELDS) entry[name] = field(name).value;
  entry.title = entry.title.trim();
  entry.username = entry.username.trim();
  entry.url = entry.url.trim();
  entry.group = entry.group.trim();
  entry.totp = secretOf(entry.totp);
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

open();
