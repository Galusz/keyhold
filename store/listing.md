# Store listing — Keyhold extension

Same text for Chrome Web Store, Edge Add-ons and Firefox Add-ons.
Packages: `dart run tool/pack_extension.dart` → `build/store/keyhold-extension-chromium-<version>.zip`
(Chrome, Edge) and `keyhold-extension-firefox-<version>.zip` (Firefox).

## Name
Keyhold

## Summary (up to 132 characters)
Fills logins and two-factor codes from the Keyhold app on your computer, and saves new logins as you sign in.

## Description
Keyhold keeps your passwords, two-factor codes and important files in one encrypted file on your computer. This extension connects your browser to it.

• Click a login field and pick the account from the list under it — the username and password are filled in.
• On a two-factor page the list shows the current code with a countdown; one click fills it.
• When you sign in with a new login, Keyhold saves it. When a password changes, it asks before updating.
• Works on two-step logins, where the username and the password are on separate pages.

The extension needs the free Keyhold app for Windows: https://github.com/Galusz/keyhold/releases/latest
It talks only to Keyhold on the same computer (127.0.0.1) — nothing is sent anywhere else. There is no account and no tracking.

Privacy policy: https://galusz.github.io/keyhold/privacy.html

## Category
Chrome: Productivity → Tools · Edge: Productivity · Firefox: Privacy & Security

## Links
Homepage: https://galusz.github.io/keyhold/
Support: https://github.com/Galusz/keyhold/issues
Privacy policy: https://galusz.github.io/keyhold/privacy.html

## Single purpose (Chrome)
Fill and save logins and two-factor codes from the user's own Keyhold vault on the same computer.

## Permission justifications (Chrome)
- **activeTab** — fills the login the user picks in the toolbar popup into the page that is open.
- **scripting** — inserts the picked username, password or code into that page from the popup.
- **storage** — keeps the pairing token that connects the extension to the Keyhold app, and for a few minutes the username typed on the first page of a two-step login, so it can be saved together with the password.
- **Host permissions (all sites)** — the list under login fields and the offer to save a login have to work on every site where the user signs in. `http://127.0.0.1:19919` is the Keyhold app on the same computer.
- **Remote code** — none. All code is in the package.

## Data usage (Chrome)
Handles: authentication information (usernames, passwords, two-factor codes) and website content (login forms on the current page).
- Sent only to the Keyhold app on the same computer; never to any server.
- Not sold, not transferred to third parties, not used for anything but filling and saving logins.
- Not used for creditworthiness or lending.

## Notes for reviewers
1. Install Keyhold for Windows from https://github.com/Galusz/keyhold/releases/latest (unzip, run `keyhold.exe`).
2. In Keyhold click **New** and add a login, for example Title `example`, Username `reviewer@example.com`, Password `test-password`, Address `https://practicetestautomation.com/practice-test-login/`.
3. In Keyhold click the puzzle icon and copy the pairing token.
4. Click the Keyhold icon in the browser toolbar, allow access, paste the token and press Connect.
5. Open the address from step 2 and click the username field — the list with the login appears under it; pick it to fill the form.
Without the Windows app the extension only shows "Keyhold is not running on this computer".
