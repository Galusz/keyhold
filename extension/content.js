function passwordFields() {
  return [...document.querySelectorAll('input[type="password"]')].filter(
    (input) => input.offsetParent !== null && !input.disabled
  );
}

function usernameFieldFor(passwordField) {
  const form = passwordField.form || document;
  const candidates = [...form.querySelectorAll('input')].filter((input) => {
    if (input === passwordField || input.disabled || input.offsetParent === null) {
      return false;
    }
    const type = (input.type || 'text').toLowerCase();
    return ['text', 'email', 'tel', ''].includes(type);
  });

  const scored = candidates.filter((input) => {
    const hay = `${input.name} ${input.id} ${input.autocomplete} ${input.placeholder}`.toLowerCase();
    return /user|login|email|mail|account|nazwa|uzytkownik/.test(hay);
  });

  return scored.pop() || candidates.pop() || null;
}

function codeField() {
  return [...document.querySelectorAll('input')].find((input) => {
    if (input.offsetParent === null || input.disabled) return false;
    const hay = `${input.name} ${input.id} ${input.autocomplete} ${input.placeholder}`.toLowerCase();
    return /otp|totp|2fa|two.?factor|one.?time|kod|code|token/.test(hay);
  });
}

function setValue(input, value) {
  if (!input) return;
  const setter = Object.getOwnPropertyDescriptor(
    window.HTMLInputElement.prototype,
    'value'
  ).set;
  setter.call(input, value);
  input.dispatchEvent(new Event('input', { bubbles: true }));
  input.dispatchEvent(new Event('change', { bubbles: true }));
}

function fill(data) {
  const password = passwordFields()[0];
  const code = codeField();

  if (password) {
    setValue(usernameFieldFor(password), data.username);
    setValue(password, data.password);
    password.focus();
  }
  if (data.code && code) {
    setValue(code, data.code);
    code.focus();
  }
  return Boolean(password || code);
}

let captured = null;

document.addEventListener(
  'submit',
  (event) => {
    const form = event.target;
    const password = form.querySelector('input[type="password"]');
    if (!password || !password.value) return;
    const username = usernameFieldFor(password);
    captured = {
      url: location.href,
      username: username ? username.value : '',
      password: password.value,
    };
    askToSave();
  },
  true
);

function askToSave() {
  if (!captured || document.getElementById('keyhold-save-bar')) return;
  const data = captured;

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
  save.onclick = () => {
    chrome.runtime.sendMessage({ type: 'save', ...data }, (result) => {
      text.textContent =
        result && result.result === 'updated'
          ? 'Password updated'
          : result && result.result === 'created'
            ? 'Saved to Keyhold'
            : result && result.result === 'unchanged'
              ? 'Already up to date'
              : 'Keyhold is not running';
      save.remove();
      setTimeout(() => bar.remove(), 2500);
    });
  };

  const dismiss = document.createElement('button');
  dismiss.textContent = 'Not now';
  dismiss.style.cssText =
    'background:transparent;color:#9FE1CB;border:0;cursor:pointer;padding:6px 8px';
  dismiss.onclick = () => bar.remove();

  bar.append(text, save, dismiss);
  document.body.appendChild(bar);
  setTimeout(() => bar.remove(), 15000);
}

chrome.runtime.onMessage.addListener((message, sender, reply) => {
  if (message.type === 'apply') {
    reply({ ok: fill(message.data) });
  }
  return false;
});
