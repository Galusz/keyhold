// Offers to save a login right after a form with a password is sent.
const api = globalThis.browser ?? chrome;

function usernameFieldFor(passwordField) {
  const form = passwordField.form || document;
  const candidates = [...form.querySelectorAll('input')].filter((input) => {
    if (input === passwordField || input.disabled || input.offsetParent === null) return false;
    return ['text', 'email', 'tel', ''].includes((input.type || 'text').toLowerCase());
  });
  const named = candidates.filter((input) =>
    /user|login|email|mail|account|nazwa/.test(
      `${input.name} ${input.id} ${input.autocomplete} ${input.placeholder}`.toLowerCase()
    )
  );
  return named.pop() || candidates.pop() || null;
}

function askToSave(data) {
  if (document.getElementById('keyhold-save-bar')) return;

  const bar = document.createElement('div');
  bar.id = 'keyhold-save-bar';
  bar.style.cssText =
    'position:fixed;z-index:2147483647;right:16px;bottom:16px;background:#1B2A26;color:#E8F5F1;' +
    'font:14px system-ui,sans-serif;padding:12px 14px;border-radius:10px;box-shadow:0 6px 24px rgba(0,0,0,.4);' +
    'display:flex;gap:10px;align-items:center';

  const text = document.createElement('span');
  text.textContent = `Save ${data.username || 'this login'} to Keyhold?`;

  const save = document.createElement('button');
  save.textContent = 'Save';
  save.style.cssText =
    'background:#1FCFB4;color:#0C1714;border:0;border-radius:6px;padding:6px 12px;cursor:pointer;font-weight:500';
  save.onclick = async () => {
    const result = await api.runtime.sendMessage({ type: 'save', ...data });
    text.textContent =
      result?.result === 'updated' ? 'Password updated'
      : result?.result === 'created' ? 'Saved to Keyhold'
      : result?.result === 'unchanged' ? 'Already up to date'
      : 'Keyhold is not running';
    save.remove();
    setTimeout(() => bar.remove(), 2500);
  };

  const dismiss = document.createElement('button');
  dismiss.textContent = 'Not now';
  dismiss.style.cssText = 'background:transparent;color:#9FE1CB;border:0;cursor:pointer;padding:6px 8px';
  dismiss.onclick = () => bar.remove();

  bar.append(text, save, dismiss);
  document.body.appendChild(bar);
  setTimeout(() => bar.remove(), 15000);
}

document.addEventListener(
  'submit',
  (event) => {
    const password = event.target.querySelector?.('input[type="password"]');
    if (!password || !password.value) return;
    const username = usernameFieldFor(password);
    askToSave({ url: location.href, username: username ? username.value : '', password: password.value });
  },
  true
);
