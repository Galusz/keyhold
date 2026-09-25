// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancel => 'Cancel';

  @override
  String get open => 'Open';

  @override
  String get delete => 'Delete';

  @override
  String get copy => 'Copy';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get search => 'Search';

  @override
  String get settings => 'Settings';

  @override
  String get change => 'Change';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get unlock => 'Unlock';

  @override
  String get noTitle => '(no title)';

  @override
  String get code => 'Code';

  @override
  String get codes => 'Codes';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get address => 'Address';

  @override
  String get notes => 'Notes';

  @override
  String get duplicates => 'Duplicates';

  @override
  String get masterPassword => 'Master password';

  @override
  String copied(String what) {
    return '$what copied';
  }

  @override
  String get fingerprintTitle => 'Keyhold Vault';

  @override
  String get fingerprintUnlockHint => 'Unlock to see your passwords and codes';

  @override
  String get fingerprintConfirmHint => 'Confirm with your fingerprint';

  @override
  String driveNotConnected(String error) {
    return 'Google Drive was not connected: $error';
  }

  @override
  String get scanQr => 'Scan a QR code';

  @override
  String get scanQrHint =>
      'Two-factor code of a website or a Google Authenticator export';

  @override
  String get newCode => 'New two-factor code';

  @override
  String get newCodeHint => 'Type the setup key yourself';

  @override
  String get newLogin => 'New login';

  @override
  String get locked => 'Keyhold is locked';

  @override
  String get everything => 'Everything';

  @override
  String get noCodesYet => 'No two-factor codes yet — tap + to scan one';

  @override
  String get nothingYet => 'Nothing here yet';

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count h ago';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get notBackedUp => 'Not backed up — tap to connect Google Drive';

  @override
  String get backingUp => 'Backing up…';

  @override
  String backupFailed(String error) {
    return 'Backup failed: $error';
  }

  @override
  String get waitingFirstBackup => 'Waiting for the first backup';

  @override
  String backedUpToDrive(String ago) {
    return 'Backed up to Google Drive $ago';
  }

  @override
  String get connectDrive => 'Connect Google Drive';

  @override
  String codeSeconds(int seconds) {
    return 'Code ($seconds s)';
  }

  @override
  String get driveOnlyPhone =>
      'Not connected — the vault lives only on this phone.';

  @override
  String connectedAs(String email) {
    return 'Connected as $email';
  }

  @override
  String connectedAsSynced(String email, String time) {
    return 'Connected as $email — last sync $time';
  }

  @override
  String get syncNow => 'Sync now';

  @override
  String get fingerprintSwitch => 'Open Keyhold with a fingerprint';

  @override
  String get fingerprintSwitchHint =>
      'Locks when the screen goes dark or after a minute away. Suggestions under login fields keep working.';

  @override
  String get fillingPasswords => 'Filling passwords';

  @override
  String get fillerOn =>
      'Keyhold fills logins in apps and browsers: tap \"Keyhold\" under a login field. In Chrome also switch on Settings → Autofill services → Autofill using another service.';

  @override
  String get fillerOff =>
      'Let Keyhold fill logins and two-factor codes in apps and browsers.';

  @override
  String get fillWithKeyhold => 'Fill passwords with Keyhold';

  @override
  String get deleteThisLogin => 'Delete this login?';

  @override
  String deleteNamed(String name) {
    return 'Delete $name?';
  }

  @override
  String get noDuplicatesLeft => 'No duplicates left.';

  @override
  String get groupWeb => 'Web';

  @override
  String get groupLocal => 'Local network';

  @override
  String get groupServers => 'Servers';

  @override
  String get filterAll => 'All';

  @override
  String get filter2fa => '2FA';

  @override
  String get filterPasswords => 'Passwords';

  @override
  String get filterFiles => 'Files';

  @override
  String get groups => 'Groups';

  @override
  String get noGroup => 'No group';

  @override
  String moveCountToGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Move $count items to a group',
      one: 'Move 1 item to a group',
    );
    return '$_temp0';
  }

  @override
  String get newGroup => 'New group';

  @override
  String get newGroupHint => 'Leave empty to take them out of any group';

  @override
  String get move => 'Move';

  @override
  String get clearSelection => 'Clear selection';

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get moveToGroup => 'Move to group';

  @override
  String get addCodesFromQr => 'Add two-factor codes from a QR code';

  @override
  String get browserExtension => 'Browser extension';

  @override
  String get addFile => 'Add file';

  @override
  String get newEntry => 'New';

  @override
  String get checking => 'Checking…';

  @override
  String get notCheckedYet => 'Not checked yet';

  @override
  String filesNew(int count) {
    return '$count new';
  }

  @override
  String filesChanged(int count) {
    return '$count changed';
  }

  @override
  String filesSkipped(int count) {
    return '$count skipped';
  }

  @override
  String checkedNothingChanged(String when) {
    return 'Checked $when — nothing changed';
  }

  @override
  String checkedWith(String when, String changes) {
    return 'Checked $when — $changes';
  }

  @override
  String get watchedHint =>
      'Watched — copied into the vault whenever they change, every 15 minutes';

  @override
  String get nothingWatched => 'Nothing watched yet';

  @override
  String pathNotFound(String path) {
    return '$path — not found';
  }

  @override
  String get stopWatching => 'Stop watching';

  @override
  String get watchFolder => 'Watch folder';

  @override
  String get watchFile => 'Watch file';

  @override
  String get checkNow => 'Check now';

  @override
  String fileTooBig(String name, String size) {
    return '$name is $size — the limit is 25 MB';
  }

  @override
  String fileAdded(String name) {
    return '$name is now in the vault';
  }

  @override
  String savedTo(String path) {
    return 'Saved to $path';
  }

  @override
  String removeNamed(String name) {
    return 'Remove $name?';
  }

  @override
  String get removeFileHint =>
      'It disappears from the vault. Older backups still hold it.';

  @override
  String get remove => 'Remove';

  @override
  String get noFilesYet => 'No files yet — add recovery codes, keys or scans';

  @override
  String get saveToDisk => 'Save to disk';

  @override
  String forWindow(String window) {
    return 'For \"$window\"';
  }

  @override
  String get dismiss => 'Dismiss';

  @override
  String get noBackupYet => 'No backup yet — it runs on the first save';

  @override
  String lastBackup(String ago) {
    return 'Last backup $ago';
  }

  @override
  String backedUpTo(String ago, String targets) {
    return 'Backed up $ago — $targets';
  }

  @override
  String driveProblem(String problem) {
    return 'Google Drive: $problem';
  }

  @override
  String driveSynced(String ago) {
    return 'Google Drive: synced $ago';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get select => 'Select';

  @override
  String get typeCode => 'Type the code into the previous window';

  @override
  String get typeLogin => 'Type username and password';

  @override
  String get copyPassword => 'Copy password';

  @override
  String get save => 'Save';

  @override
  String get off => 'Off';

  @override
  String get synced => 'Synced';

  @override
  String get alreadyInSync => 'Already in sync';

  @override
  String get fillHostFirst => 'Fill in the host first';

  @override
  String get fillUserFirst => 'Fill in the user first';

  @override
  String get pickKeyFirst => 'Pick your private key file first';

  @override
  String noFileAt(String path) {
    return 'There is no file at $path';
  }

  @override
  String serverUnreachable(String host, String port) {
    return 'Cannot reach $host on port $port. Check the address, the port and whether the server is up.';
  }

  @override
  String serverRefusedKey(String user) {
    return 'The server refused this key for user $user. Make sure the matching public key sits in its authorized_keys.';
  }

  @override
  String get notAPrivateKey => 'That file is not a usable private key.';

  @override
  String cannotWriteFolder(String folder) {
    return 'Logged in, but cannot write into \"$folder\". Pick another folder.';
  }

  @override
  String get driveNotInBuild => 'Google Drive is not set up in this build.';

  @override
  String get setPasswordFirst =>
      'Set a master password first — a new device needs it to open the vault.';

  @override
  String get foldersOnComputer => 'Folders on this computer';

  @override
  String folderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count folders',
      one: '1 folder',
    );
    return '$_temp0';
  }

  @override
  String folderCountCopied(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count folders — last copy $time',
      one: '1 folder — last copy $time',
    );
    return '$_temp0';
  }

  @override
  String get yourServer => 'Your server';

  @override
  String get noFolders => 'No folders — local copies are off';

  @override
  String get addFolder => 'Add folder';

  @override
  String get serverHint =>
      'The same copy goes over SFTP to a machine you own. The file stays encrypted, so the server sees bytes and nothing else. Leave the host empty to skip this.';

  @override
  String get host => 'Host';

  @override
  String get port => 'Port';

  @override
  String get user => 'User';

  @override
  String get privateKeyFile => 'Private key file';

  @override
  String get chooseFile => 'Choose file';

  @override
  String get serverFolder => 'Folder on the server';

  @override
  String get testConnection => 'Test connection';

  @override
  String get notReachable => 'Not reachable right now';

  @override
  String get enterCodeKey => 'Enter the key of the two-factor code';

  @override
  String get twoFactorCode => 'Two-factor code';

  @override
  String get newEntryTitle => 'New entry';

  @override
  String get editEntry => 'Edit entry';

  @override
  String get name => 'Name';

  @override
  String get key => 'Key';

  @override
  String get keyHint => 'Paste the setup key or the whole otpauth:// link';

  @override
  String get note => 'Note';

  @override
  String get addresses => 'Addresses';

  @override
  String get codeNotUsedYet =>
      'Not used anywhere yet. It pins itself the first time you use it on a site, or pin it from a login.';

  @override
  String get noAddress => 'no address';

  @override
  String get unpin => 'Unpin';

  @override
  String get addAddress => 'Add an address';

  @override
  String get title => 'Title';

  @override
  String get noName => '(no name)';

  @override
  String get none => 'None';

  @override
  String get choose => 'Choose';

  @override
  String get group => 'Group';

  @override
  String get groupHint => 'Pick one or type a new name';

  @override
  String get driveTabConnected =>
      'Keyhold is connected to Google Drive. You can close this tab.';

  @override
  String get driveTabNotConnected =>
      'Google Drive was not connected. You can close this tab.';

  @override
  String get signInTooLong => 'Google sign-in took too long — try again';

  @override
  String get signInCancelled => 'Google sign-in was cancelled';

  @override
  String get noOfflineAccess => 'Google did not allow offline access';

  @override
  String get noInternet => 'No internet connection';

  @override
  String get wrongMasterPassword => 'Wrong master password';

  @override
  String driveRefusedDownload(String status) {
    return 'Google Drive refused the download ($status)';
  }

  @override
  String driveRefusedUpload(String status) {
    return 'Google Drive refused the upload ($status)';
  }

  @override
  String driveAnswered(String status) {
    return 'Google Drive answered $status';
  }

  @override
  String get driveSignInAgain => 'Google Drive needs you to sign in again';

  @override
  String get driveNotConnectedError => 'Google Drive is not connected';

  @override
  String get driveAccessEnded => 'Google Drive access ended — connect again';

  @override
  String signInFailed(String status) {
    return 'Google sign-in failed ($status)';
  }

  @override
  String get dupNewest => 'newest';

  @override
  String get dupSamePassword => 'same password as the newest';

  @override
  String get dupDifferentPassword => 'different password';

  @override
  String get noUsername => '(no username)';

  @override
  String duplicateNote(String username, String password, String day) {
    return '$username · $password · changed $day';
  }

  @override
  String get fileEmpty => 'The file is empty';

  @override
  String get noLoginColumns =>
      'No username or password column found in this file';

  @override
  String get noQrOnScreen => 'No QR code found on the screen';

  @override
  String get noQrInImage => 'No QR code found in this image';

  @override
  String get qrNotTwoFactor => 'This QR code is not a two-factor code';

  @override
  String get exportQrEmpty => 'The export QR code is empty';

  @override
  String get exportQrUnreadable => 'This export QR code could not be read';

  @override
  String serverWritable(String account) {
    return 'Connected as $account, folder is writable';
  }

  @override
  String get openKeyhold => 'Open Keyhold';

  @override
  String get quit => 'Quit';

  @override
  String codesFound(int count) {
    return '$count found';
  }

  @override
  String codesUnsupported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count use a code type Keyhold cannot generate yet',
      one: '1 uses a code type Keyhold cannot generate yet',
    );
    return '$_temp0';
  }

  @override
  String savedAs(String name) {
    return 'Saved as $name';
  }

  @override
  String savedCodes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Saved $count codes',
      one: 'Saved 1 code',
    );
    return '$_temp0';
  }

  @override
  String get images => 'Images';

  @override
  String get addCodes => 'Add two-factor codes';

  @override
  String get saveAll => 'Save all';

  @override
  String get qrHintPhone =>
      'Point the camera at the QR code a website shows when you turn on two-factor login, or at the export from Google Authenticator (Transfer accounts → Export).';

  @override
  String get qrHintComputer =>
      'Show the QR code on the screen and scan it. It can be the code a website shows when you turn on two-factor login, or the export from Google Authenticator (Transfer accounts → Export). A photo of the code works too.';

  @override
  String get qrMicrosoftHint =>
      'Microsoft Authenticator cannot export its codes — turn two-factor login off and on again on each site and scan the new code here.';

  @override
  String get scanCamera => 'Scan with the camera';

  @override
  String get scanScreen => 'Scan the screen';

  @override
  String get openImage => 'Open an image';

  @override
  String get saved => 'Saved';

  @override
  String get alreadyInKeyhold => 'Already in Keyhold';

  @override
  String asName(String name) {
    return 'as \"$name\"';
  }

  @override
  String get typePasswordFirst => 'Type your password first';

  @override
  String get atLeast8 => 'Use at least 8 characters';

  @override
  String get passwordsDiffer => 'The two passwords differ';

  @override
  String get passwordDoesNotOpen => 'That password does not open this vault';

  @override
  String get unlockVault => 'Unlock vault';

  @override
  String get unlockHint =>
      'This vault came from another machine. Type the master password to open it here.';

  @override
  String get newMasterPassword => 'New master password';

  @override
  String get repeatIt => 'Repeat it';

  @override
  String get openVault => 'Open vault';

  @override
  String get savePassword => 'Save password';

  @override
  String get nobodyCanRecover =>
      'If you forget it, only the recovery key opens your vault: print the recovery sheet.';

  @override
  String get groupApps => 'Apps';

  @override
  String get openKeyholdFirst =>
      'Open Keyhold once and enter the master password, then try again.';

  @override
  String pinTo(String name, String place) {
    return 'Pin \"$name\" to $place?';
  }

  @override
  String get pinHint =>
      'Then it is offered here right away, without searching.';

  @override
  String get doNotAskCode => 'Do not ask about this code again';

  @override
  String get notNow => 'Not now';

  @override
  String get pin => 'Pin';

  @override
  String get savedToKeyhold => 'Saved to Keyhold';

  @override
  String get passwordUpdated => 'Password updated in Keyhold';

  @override
  String get searchAllLogins => 'Search all logins';

  @override
  String get nothingFound => 'Nothing found.';

  @override
  String get noLoginForSite =>
      'No login for this site yet. Search above, or log in and Android will offer to save it.';

  @override
  String get noLoginForApp =>
      'No login for this app yet. Search above, or log in and Android will offer to save it.';

  @override
  String listening(String address) {
    return 'Listening on $address';
  }

  @override
  String get notListening =>
      'Not listening — another Keyhold may already be running';

  @override
  String get pairingToken => 'Pairing token';

  @override
  String get pairingTokenHint =>
      'Paste this into the extension once. Only requests carrying it are answered, and only from the extension itself — a web page cannot reach the vault.';

  @override
  String get tokenCopied => 'Token copied';

  @override
  String get copyToken => 'Copy token';

  @override
  String get installIt => 'Install it';

  @override
  String get installChrome =>
      'Chrome or Edge: open chrome://extensions, turn on Developer mode, click \"Load unpacked\" and pick the folder below.';

  @override
  String get installFirefox =>
      'Firefox: open about:debugging#/runtime/this-firefox, click \"Load Temporary Add-on\" and pick manifest.json in that folder.';

  @override
  String get installPaste =>
      'Click the Keyhold icon in the toolbar and paste the token.';

  @override
  String get newCodeShort => 'New code';

  @override
  String get free => 'Free';

  @override
  String get searchCodes => 'Search codes';

  @override
  String get everyCodePinned =>
      'Every code is pinned somewhere. Switch to All to see them.';

  @override
  String get noCodesFound => 'No codes found.';

  @override
  String pinnedTo(String hosts) {
    return 'pinned to $hosts';
  }

  @override
  String get notPinned => 'not pinned';

  @override
  String changedOn(String day) {
    return 'changed $day';
  }

  @override
  String get deleteCsvHint => 'It holds every password in plain text';

  @override
  String get cameraHint =>
      'Point at the two-factor QR code of a website, or at the export from Google Authenticator.';

  @override
  String get deleteThisCode => 'Delete this two-factor code?';

  @override
  String get deleteCodeWarning =>
      'It disappears from all your devices. Without it you cannot sign in where it is used.';

  @override
  String get deleteLoginWarning => 'It disappears from all your devices.';

  @override
  String nextCode(String code) {
    return 'next $code';
  }

  @override
  String get recoverySheet => 'Recovery sheet';

  @override
  String get recoveryIntro =>
      'This key opens your vault if you ever forget the master password. Print the sheet, copy the last row onto it by hand, and keep it at home.';

  @override
  String get print => 'Print';

  @override
  String get done => 'Done';

  @override
  String get sheetTitle => 'Keyhold recovery sheet';

  @override
  String sheetMade(String date) {
    return 'Made on $date';
  }

  @override
  String get sheetWhere => 'Where your vault is';

  @override
  String sheetDrive(String email) {
    return 'Google Drive of $email, folder \"Keyhold\"';
  }

  @override
  String sheetFolders(String folders) {
    return 'Copies in folders: $folders';
  }

  @override
  String sheetServer(String host) {
    return 'Copies on the server $host';
  }

  @override
  String get sheetOnlyHere =>
      'Only on this device. Turn on a backup in Keyhold.';

  @override
  String get sheetSteps => 'On a new computer or phone';

  @override
  String get sheetStep1 => 'Install Keyhold: galusz.github.io/keyhold';

  @override
  String get sheetStep2 => 'Connect the same Google Drive in Keyhold.';

  @override
  String get sheetStep3 =>
      'When Keyhold asks for the master password, type this recovery key. Then choose a new master password.';

  @override
  String get sheetKeepSafe =>
      'Anyone with this completed sheet can open your vault. Keep it like a spare house key.';

  @override
  String get sheetDriveNoEmail => 'Google Drive, folder \"Keyhold\"';

  @override
  String get noBackupPlaces =>
      'No backup folder, server or Google Drive: the vault is only on this computer. Click to set one up.';

  @override
  String get deleteVault => 'Delete the vault';

  @override
  String get deleteVaultFolders =>
      'Also delete the copies in the backup folders';

  @override
  String get deleteVaultSure => 'Delete the vault for good?';

  @override
  String get deleteVaultSureHint => 'This cannot be undone.';

  @override
  String get recoveryGate =>
      'Type your master password to see the recovery key.';

  @override
  String get showKey => 'Show the key';

  @override
  String get recoveryCopyRow => 'Copy this row by hand onto the printed sheet';

  @override
  String get checkRow => 'Then type the last row as you wrote it on the sheet';

  @override
  String get check => 'Check';

  @override
  String get rowMatches => 'It matches. Keep the sheet somewhere safe.';

  @override
  String get rowDiffers =>
      'It does not match. Compare the last row with the screen and correct it on the sheet.';

  @override
  String get sheetKeyLabel => 'Recovery key';

  @override
  String get sheetCopyRow =>
      'Copy the last row here by hand from the Keyhold screen.';

  @override
  String get orRecoveryCode =>
      'Forgot it? Type the recovery key from your recovery sheet instead.';

  @override
  String get newPasswordAfterKey =>
      'The recovery key opened your vault. Choose a new master password: it replaces the forgotten one on all your devices.';

  @override
  String get otherVaultTitle => 'Copies of another vault';

  @override
  String otherVaultHint(String when) {
    return 'This folder already holds copies of another Keyhold vault (the newest from $when). Open it to look inside? Your vault stays as it is.';
  }

  @override
  String get copyPasswordTitle => 'Master password of this copy';

  @override
  String get copyNotOpened =>
      'This copy did not open: wrong password or recovery key, or not a Keyhold vault.';

  @override
  String copyTitle(String name) {
    return 'Copy: $name';
  }

  @override
  String get copyReadOnly =>
      'Only for looking: nothing here changes your vault. Any single entry can be added to your vault.';

  @override
  String get myVault => 'My vault';

  @override
  String get vaultTab => 'Vault';

  @override
  String get syncTab => 'Sync';

  @override
  String get copiesTab => 'Backups';

  @override
  String get startHint =>
      'Your passwords and two-factor codes in one vault: on your computer, on your phone and in your browser.';

  @override
  String get createVault => 'Create a new vault';

  @override
  String get openMyVault => 'Open my vault';

  @override
  String get newVault => 'New vault';

  @override
  String get vaultName => 'Vault name';

  @override
  String get newVaultHint =>
      'The master password opens this vault on each of your devices: computer, phone and browser. Keyhold can\'t recover it; the recovery key you get next can.';

  @override
  String get sealHint =>
      'Your vault has no master password yet. Set it now: it opens this vault on your other devices and in the browser.';

  @override
  String get createVaultButton => 'Create the vault';

  @override
  String get forgotPassword => 'Forgot the password?';

  @override
  String get usePassword => 'Use the master password';

  @override
  String get recoveryKey => 'Recovery key';

  @override
  String get recoveryKeyFieldHint =>
      'The 36 characters from your recovery sheet; spaces don\'t matter.';

  @override
  String get openVaultTitle => 'Open a vault';

  @override
  String get openVaultHint =>
      'The vault opens as it is. It is never merged with another vault.';

  @override
  String get fromDrive => 'From Google Drive';

  @override
  String get fromDriveHint =>
      'Sign in to Google, then type the vault\'s master password.';

  @override
  String fromDriveAs(String email) {
    return '$email: type the vault\'s master password.';
  }

  @override
  String get fromFile => 'From a file (.khd)';

  @override
  String get fromFileHint =>
      'A copy from a backup folder, a USB stick or an old computer.';

  @override
  String get closedHere => 'Opened on this device before';

  @override
  String closedOn(String date) {
    return 'closed $date';
  }

  @override
  String get closedVaultGone =>
      'That vault\'s file is no longer on this device.';

  @override
  String get typeVaultPassword =>
      'Type the master password of the vault you want to open. Keyhold tries it on every vault in your Google Drive.';

  @override
  String lookingForVault(int at, int of) {
    return 'Looking for your vault: $at of $of';
  }

  @override
  String get noVaultInDrive =>
      'There is no Keyhold vault in this Google Drive yet.';

  @override
  String get noVaultMatches =>
      'No vault in your Google Drive opens with this password.';

  @override
  String get sameVaultFile =>
      'This file is a copy of the vault you have open. To take entries out of it, use Backups, then Review a copy.';

  @override
  String fileVaultPassword(String name) {
    return 'Type the master password of $name.';
  }

  @override
  String get driveFileUnreadable =>
      'This vault\'s file in Google Drive can\'t be read. Keyhold leaves it as it is.';

  @override
  String get vaultInfoHint =>
      'This vault opens with its master password on every device. If you forget the password, the recovery key opens the vault and you choose a new one.';

  @override
  String get recoveryKeyHint => 'Shown and printed after the master password';

  @override
  String get otherVaults => 'Other vaults';

  @override
  String get openOtherVault => 'Open another vault';

  @override
  String get openOtherVaultHint =>
      'From Google Drive, from a file or from this device';

  @override
  String get createNewVaultHint => 'Empty, with its own master password';

  @override
  String closeVaultTitle(String name) {
    return 'Close \"$name\" on this device?';
  }

  @override
  String get closeVaultHint =>
      'Nothing is deleted: it stays in Google Drive, in the backup copies and on this device\'s list of vaults. It opens again with its master password.';

  @override
  String get continueLabel => 'Continue';

  @override
  String get renameVault => 'Rename the vault';

  @override
  String get reviewCopy => 'Review a copy';

  @override
  String get driveVaultHint =>
      'Keeps this vault as its own encrypted file in a \"Keyhold\" folder in your Google Drive. Your other devices open it with its master password. Several vaults can share one Google Drive; they never mix. Google cannot read them.';

  @override
  String get foldersSlotsHint =>
      'Every save updates up to 7 copies of the vault in each folder: the latest one, and ones about an hour, a day, a week, a month, three months and a year old.';

  @override
  String get deleteVaultHereHint =>
      'The vault is erased from this device: passwords, two-factor codes and files. Vaults opened here before stay. Keyhold then shows its start screen.';

  @override
  String get deleteVaultDriveMine =>
      'Also delete it from Google Drive (other vaults there stay)';

  @override
  String get vaultDeletedHere => 'The vault is deleted.';

  @override
  String get menu => 'Menu';

  @override
  String get importTitle => 'Import';

  @override
  String get importMenuHint =>
      'Passwords and codes from other apps or another vault';

  @override
  String get importAnyHint =>
      'Choose an export from another password manager or authenticator app, a KeePass database or another Keyhold vault. Keyhold tells from the file what it is, and you tick what comes in.';

  @override
  String get importReading => 'Reading the file…';

  @override
  String importPasswordTitle(String format) {
    return 'Password of this $format file';
  }

  @override
  String get importWrongPassword => 'That password doesn\'t open this file.';

  @override
  String get importUnknown =>
      'Keyhold doesn\'t recognise this file. Export again from the other app, as CSV or JSON.';

  @override
  String importNothing(String format) {
    return '$format: nothing in this file that Keyhold can keep.';
  }

  @override
  String get keePassUnsupported =>
      'This KeePass database uses something Keyhold can\'t open (a key file or the Twofish cipher). Export it from KeePass as CSV instead.';

  @override
  String get bitwardenAccountLocked =>
      'This Bitwarden export only opens with your Bitwarden account. Export again as JSON, password protected or without encryption.';

  @override
  String get otpLinks => 'otpauth links';

  @override
  String get importPickHint =>
      'Tick what should go into your vault. Entries you already have are left unticked.';

  @override
  String codesLeftOut(int count) {
    return 'Codes left out: $count. Keyhold makes 6-digit codes every 30 seconds only, not 8 digits, 60 seconds, counters or Steam.';
  }

  @override
  String recordsLeftOut(int count) {
    return 'Records left out: $count (empty ones, cards and identities).';
  }

  @override
  String get selectAll => 'Select all';

  @override
  String get alreadyInVault => 'already in your vault';

  @override
  String addSelected(int count) {
    return 'Add ($count)';
  }

  @override
  String addedCount(int count) {
    return 'Added to your vault: $count';
  }

  @override
  String get deletePlainFile => 'Delete the file afterwards';

  @override
  String get importPasswordsFrom => 'Passwords';

  @override
  String get importPasswordsList =>
      'Chrome, Edge, Firefox and Safari (CSV), Bitwarden (CSV or JSON), 1Password (.1pux or CSV), KeePass and KeePassXC (.kdbx or CSV), LastPass, Proton Pass, NordPass and Dashlane (CSV), and another Keyhold vault (.khd).';

  @override
  String get importCodesFrom => 'Two-factor codes';

  @override
  String get importCodesList =>
      'Aegis (.json), 2FAS (.2fas), Ente Auth, FreeOTP+ and andOTP, and any file of otpauth:// links. Google Authenticator: show its export QR code and use Keyhold\'s QR code button.';

  @override
  String get importNoExport =>
      'Microsoft Authenticator and Authy don\'t let codes out: turn two-factor on again at each service and scan its new QR code.';
}
