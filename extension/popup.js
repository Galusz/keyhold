const content = document.getElementById('content');

function pairingForm(message) {
  content.className = '';
  content.innerHTML = '';

  const hint = document.createElement('p');
  hint.className = 'muted';
  hint.textContent = message;

  const input = document.createElement('input');
  input.placeholder = 'Pairing token from Keyhold';

  const button = document.createElement('button');
  button.textContent = 'Connect';
  button.onclick = async () => {
    await chrome.storage.local.set({ token: input.value.trim() });
    load();
  };

  content.append(hint, input, button);
}

function render(entries, tab) {
  content.className = '';
  content.innerHTML = '';

  if (entries.length === 0) {
    const empty = document.createElement('p');
    empty.className = 'muted';
    empty.textContent = 'No entry for this site yet. Log in once and Keyhold will offer to save it.';
    content.append(empty);
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

    row.onclick = () => {
      chrome.runtime.sendMessage({ type: 'fill', id: entry.id }, (data) => {
        if (!data || data.error) return;
        chrome.tabs.sendMessage(tab.id, { type: 'apply', data }, () => window.close());
      });
    };

    content.append(row);
  }
}

async function load() {
  const [tab] = await chrome.tabs.query({ active: true, currentWindow: true });
  if (!tab || !tab.url || !/^https?:/.test(tab.url)) {
    content.textContent = 'Open a website first.';
    return;
  }

  chrome.runtime.sendMessage({ type: 'lookup', url: tab.url }, (result) => {
    if (!result || result.error === 'no token' || result.error === 'bad token') {
      pairingForm(
        'Open Keyhold, go to the browser extension screen and copy the pairing token here.'
      );
      return;
    }
    if (result.error) {
      content.className = 'muted';
      content.textContent = 'Keyhold is not running on this computer.';
      return;
    }
    render(result.entries || [], tab);
  });
}

load();
