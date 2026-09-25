import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('ja'),
    Locale('pl'),
    Locale('pt'),
    Locale('zh'),
  ];

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @noTitle.
  ///
  /// In en, this message translates to:
  /// **'(no title)'**
  String get noTitle;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @codes.
  ///
  /// In en, this message translates to:
  /// **'Codes'**
  String get codes;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @duplicates.
  ///
  /// In en, this message translates to:
  /// **'Duplicates'**
  String get duplicates;

  /// No description provided for @masterPassword.
  ///
  /// In en, this message translates to:
  /// **'Master password'**
  String get masterPassword;

  /// No description provided for @setMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Set master password'**
  String get setMasterPassword;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'{what} copied'**
  String copied(String what);

  /// No description provided for @fingerprintTitle.
  ///
  /// In en, this message translates to:
  /// **'Keyhold Vault'**
  String get fingerprintTitle;

  /// No description provided for @fingerprintUnlockHint.
  ///
  /// In en, this message translates to:
  /// **'Unlock to see your passwords and codes'**
  String get fingerprintUnlockHint;

  /// No description provided for @fingerprintConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm with your fingerprint'**
  String get fingerprintConfirmHint;

  /// No description provided for @driveNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Google Drive was not connected: {error}'**
  String driveNotConnected(String error);

  /// No description provided for @masterPasswordOfVault.
  ///
  /// In en, this message translates to:
  /// **'Master password of your vault'**
  String get masterPasswordOfVault;

  /// No description provided for @masterPasswordFromComputer.
  ///
  /// In en, this message translates to:
  /// **'The one you set in Keyhold on your computer'**
  String get masterPasswordFromComputer;

  /// No description provided for @scanQr.
  ///
  /// In en, this message translates to:
  /// **'Scan a QR code'**
  String get scanQr;

  /// No description provided for @scanQrHint.
  ///
  /// In en, this message translates to:
  /// **'Two-factor code of a website or a Google Authenticator export'**
  String get scanQrHint;

  /// No description provided for @newCode.
  ///
  /// In en, this message translates to:
  /// **'New two-factor code'**
  String get newCode;

  /// No description provided for @newCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Type the setup key yourself'**
  String get newCodeHint;

  /// No description provided for @newLogin.
  ///
  /// In en, this message translates to:
  /// **'New login'**
  String get newLogin;

  /// No description provided for @locked.
  ///
  /// In en, this message translates to:
  /// **'Keyhold is locked'**
  String get locked;

  /// No description provided for @everything.
  ///
  /// In en, this message translates to:
  /// **'Everything'**
  String get everything;

  /// No description provided for @noCodesYet.
  ///
  /// In en, this message translates to:
  /// **'No two-factor codes yet — tap + to scan one'**
  String get noCodesYet;

  /// No description provided for @nothingYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get nothingYet;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String daysAgo(int count);

  /// No description provided for @notBackedUp.
  ///
  /// In en, this message translates to:
  /// **'Not backed up — tap to connect Google Drive'**
  String get notBackedUp;

  /// No description provided for @backingUp.
  ///
  /// In en, this message translates to:
  /// **'Backing up…'**
  String get backingUp;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed: {error}'**
  String backupFailed(String error);

  /// No description provided for @waitingFirstBackup.
  ///
  /// In en, this message translates to:
  /// **'Waiting for the first backup'**
  String get waitingFirstBackup;

  /// No description provided for @backedUpToDrive.
  ///
  /// In en, this message translates to:
  /// **'Backed up to Google Drive {ago}'**
  String backedUpToDrive(String ago);

  /// No description provided for @phoneWelcome.
  ///
  /// In en, this message translates to:
  /// **'Your passwords and two-factor codes — the same vault as on your computer, kept in step through your own Google Drive.'**
  String get phoneWelcome;

  /// No description provided for @connectDrive.
  ///
  /// In en, this message translates to:
  /// **'Connect Google Drive'**
  String get connectDrive;

  /// No description provided for @startEmpty.
  ///
  /// In en, this message translates to:
  /// **'Start with an empty vault'**
  String get startEmpty;

  /// No description provided for @codeSeconds.
  ///
  /// In en, this message translates to:
  /// **'Code ({seconds} s)'**
  String codeSeconds(int seconds);

  /// No description provided for @driveOnlyPhone.
  ///
  /// In en, this message translates to:
  /// **'Not connected — the vault lives only on this phone.'**
  String get driveOnlyPhone;

  /// No description provided for @connectedAs.
  ///
  /// In en, this message translates to:
  /// **'Connected as {email}'**
  String connectedAs(String email);

  /// No description provided for @connectedAsSynced.
  ///
  /// In en, this message translates to:
  /// **'Connected as {email} — last sync {time}'**
  String connectedAsSynced(String email, String time);

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @fingerprintLock.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint lock'**
  String get fingerprintLock;

  /// No description provided for @fingerprintSwitch.
  ///
  /// In en, this message translates to:
  /// **'Open Keyhold with a fingerprint'**
  String get fingerprintSwitch;

  /// No description provided for @fingerprintSwitchHint.
  ///
  /// In en, this message translates to:
  /// **'Locks when the screen goes dark or after a minute away. Suggestions under login fields keep working.'**
  String get fingerprintSwitchHint;

  /// No description provided for @fillingPasswords.
  ///
  /// In en, this message translates to:
  /// **'Filling passwords'**
  String get fillingPasswords;

  /// No description provided for @fillerOn.
  ///
  /// In en, this message translates to:
  /// **'Keyhold fills logins in apps and browsers: tap \"Keyhold\" under a login field. In Chrome also switch on Settings → Autofill services → Autofill using another service.'**
  String get fillerOn;

  /// No description provided for @fillerOff.
  ///
  /// In en, this message translates to:
  /// **'Let Keyhold fill logins and two-factor codes in apps and browsers.'**
  String get fillerOff;

  /// No description provided for @fillWithKeyhold.
  ///
  /// In en, this message translates to:
  /// **'Fill passwords with Keyhold'**
  String get fillWithKeyhold;

  /// No description provided for @passwordSetPhone.
  ///
  /// In en, this message translates to:
  /// **'Set. It opens this vault on a new device.'**
  String get passwordSetPhone;

  /// No description provided for @passwordNotSetPhone.
  ///
  /// In en, this message translates to:
  /// **'Not set. Without it a new device cannot open the vault.'**
  String get passwordNotSetPhone;

  /// No description provided for @deleteThisLogin.
  ///
  /// In en, this message translates to:
  /// **'Delete this login?'**
  String get deleteThisLogin;

  /// No description provided for @deleteNamed.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteNamed(String name);

  /// No description provided for @noDuplicatesLeft.
  ///
  /// In en, this message translates to:
  /// **'No duplicates left.'**
  String get noDuplicatesLeft;

  /// No description provided for @groupWeb.
  ///
  /// In en, this message translates to:
  /// **'Web'**
  String get groupWeb;

  /// No description provided for @groupLocal.
  ///
  /// In en, this message translates to:
  /// **'Local network'**
  String get groupLocal;

  /// No description provided for @groupServers.
  ///
  /// In en, this message translates to:
  /// **'Servers'**
  String get groupServers;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filter2fa.
  ///
  /// In en, this message translates to:
  /// **'2FA'**
  String get filter2fa;

  /// No description provided for @filterPasswords.
  ///
  /// In en, this message translates to:
  /// **'Passwords'**
  String get filterPasswords;

  /// No description provided for @filterFiles.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get filterFiles;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @noGroup.
  ///
  /// In en, this message translates to:
  /// **'No group'**
  String get noGroup;

  /// No description provided for @moveCountToGroup.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Move 1 item to a group} other{Move {count} items to a group}}'**
  String moveCountToGroup(int count);

  /// No description provided for @newGroup.
  ///
  /// In en, this message translates to:
  /// **'New group'**
  String get newGroup;

  /// No description provided for @newGroupHint.
  ///
  /// In en, this message translates to:
  /// **'Leave empty to take them out of any group'**
  String get newGroupHint;

  /// No description provided for @move.
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get move;

  /// No description provided for @clearSelection.
  ///
  /// In en, this message translates to:
  /// **'Clear selection'**
  String get clearSelection;

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @moveToGroup.
  ///
  /// In en, this message translates to:
  /// **'Move to group'**
  String get moveToGroup;

  /// No description provided for @addCodesFromQr.
  ///
  /// In en, this message translates to:
  /// **'Add two-factor codes from a QR code'**
  String get addCodesFromQr;

  /// No description provided for @browserExtension.
  ///
  /// In en, this message translates to:
  /// **'Browser extension'**
  String get browserExtension;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @importCsv.
  ///
  /// In en, this message translates to:
  /// **'Import from CSV'**
  String get importCsv;

  /// No description provided for @changeMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Change master password'**
  String get changeMasterPassword;

  /// No description provided for @addFile.
  ///
  /// In en, this message translates to:
  /// **'Add file'**
  String get addFile;

  /// No description provided for @newEntry.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newEntry;

  /// No description provided for @checking.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get checking;

  /// No description provided for @notCheckedYet.
  ///
  /// In en, this message translates to:
  /// **'Not checked yet'**
  String get notCheckedYet;

  /// No description provided for @filesNew.
  ///
  /// In en, this message translates to:
  /// **'{count} new'**
  String filesNew(int count);

  /// No description provided for @filesChanged.
  ///
  /// In en, this message translates to:
  /// **'{count} changed'**
  String filesChanged(int count);

  /// No description provided for @filesSkipped.
  ///
  /// In en, this message translates to:
  /// **'{count} skipped'**
  String filesSkipped(int count);

  /// No description provided for @checkedNothingChanged.
  ///
  /// In en, this message translates to:
  /// **'Checked {when} — nothing changed'**
  String checkedNothingChanged(String when);

  /// No description provided for @checkedWith.
  ///
  /// In en, this message translates to:
  /// **'Checked {when} — {changes}'**
  String checkedWith(String when, String changes);

  /// No description provided for @watchedHint.
  ///
  /// In en, this message translates to:
  /// **'Watched — copied into the vault whenever they change, every 15 minutes'**
  String get watchedHint;

  /// No description provided for @nothingWatched.
  ///
  /// In en, this message translates to:
  /// **'Nothing watched yet'**
  String get nothingWatched;

  /// No description provided for @pathNotFound.
  ///
  /// In en, this message translates to:
  /// **'{path} — not found'**
  String pathNotFound(String path);

  /// No description provided for @stopWatching.
  ///
  /// In en, this message translates to:
  /// **'Stop watching'**
  String get stopWatching;

  /// No description provided for @watchFolder.
  ///
  /// In en, this message translates to:
  /// **'Watch folder'**
  String get watchFolder;

  /// No description provided for @watchFile.
  ///
  /// In en, this message translates to:
  /// **'Watch file'**
  String get watchFile;

  /// No description provided for @checkNow.
  ///
  /// In en, this message translates to:
  /// **'Check now'**
  String get checkNow;

  /// No description provided for @fileTooBig.
  ///
  /// In en, this message translates to:
  /// **'{name} is {size} — the limit is 25 MB'**
  String fileTooBig(String name, String size);

  /// No description provided for @fileAdded.
  ///
  /// In en, this message translates to:
  /// **'{name} is now in the vault'**
  String fileAdded(String name);

  /// No description provided for @savedTo.
  ///
  /// In en, this message translates to:
  /// **'Saved to {path}'**
  String savedTo(String path);

  /// No description provided for @removeNamed.
  ///
  /// In en, this message translates to:
  /// **'Remove {name}?'**
  String removeNamed(String name);

  /// No description provided for @removeFileHint.
  ///
  /// In en, this message translates to:
  /// **'It disappears from the vault. Older backups still hold it.'**
  String get removeFileHint;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @noFilesYet.
  ///
  /// In en, this message translates to:
  /// **'No files yet — add recovery codes, keys or scans'**
  String get noFilesYet;

  /// No description provided for @saveToDisk.
  ///
  /// In en, this message translates to:
  /// **'Save to disk'**
  String get saveToDisk;

  /// No description provided for @forWindow.
  ///
  /// In en, this message translates to:
  /// **'For \"{window}\"'**
  String forWindow(String window);

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @noBackupYet.
  ///
  /// In en, this message translates to:
  /// **'No backup yet — it runs on the first save'**
  String get noBackupYet;

  /// No description provided for @lastBackup.
  ///
  /// In en, this message translates to:
  /// **'Last backup {ago}'**
  String lastBackup(String ago);

  /// No description provided for @backedUpTo.
  ///
  /// In en, this message translates to:
  /// **'Backed up {ago} — {targets}'**
  String backedUpTo(String ago, String targets);

  /// No description provided for @driveNeedsPassword.
  ///
  /// In en, this message translates to:
  /// **'Google Drive: open Backup and enter the master password'**
  String get driveNeedsPassword;

  /// No description provided for @driveProblem.
  ///
  /// In en, this message translates to:
  /// **'Google Drive: {problem}'**
  String driveProblem(String problem);

  /// No description provided for @driveSynced.
  ///
  /// In en, this message translates to:
  /// **'Google Drive: synced {ago}'**
  String driveSynced(String ago);

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemCount(int count);

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @typeCode.
  ///
  /// In en, this message translates to:
  /// **'Type the code into the previous window'**
  String get typeCode;

  /// No description provided for @typeLogin.
  ///
  /// In en, this message translates to:
  /// **'Type username and password'**
  String get typeLogin;

  /// No description provided for @copyPassword.
  ///
  /// In en, this message translates to:
  /// **'Copy password'**
  String get copyPassword;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @onWith.
  ///
  /// In en, this message translates to:
  /// **'On — {detail}'**
  String onWith(String detail);

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get synced;

  /// No description provided for @alreadyInSync.
  ///
  /// In en, this message translates to:
  /// **'Already in sync'**
  String get alreadyInSync;

  /// No description provided for @fillHostFirst.
  ///
  /// In en, this message translates to:
  /// **'Fill in the host first'**
  String get fillHostFirst;

  /// No description provided for @fillUserFirst.
  ///
  /// In en, this message translates to:
  /// **'Fill in the user first'**
  String get fillUserFirst;

  /// No description provided for @pickKeyFirst.
  ///
  /// In en, this message translates to:
  /// **'Pick your private key file first'**
  String get pickKeyFirst;

  /// No description provided for @noFileAt.
  ///
  /// In en, this message translates to:
  /// **'There is no file at {path}'**
  String noFileAt(String path);

  /// No description provided for @serverUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach {host} on port {port}. Check the address, the port and whether the server is up.'**
  String serverUnreachable(String host, String port);

  /// No description provided for @serverRefusedKey.
  ///
  /// In en, this message translates to:
  /// **'The server refused this key for user {user}. Make sure the matching public key sits in its authorized_keys.'**
  String serverRefusedKey(String user);

  /// No description provided for @notAPrivateKey.
  ///
  /// In en, this message translates to:
  /// **'That file is not a usable private key.'**
  String get notAPrivateKey;

  /// No description provided for @cannotWriteFolder.
  ///
  /// In en, this message translates to:
  /// **'Logged in, but cannot write into \"{folder}\". Pick another folder.'**
  String cannotWriteFolder(String folder);

  /// No description provided for @driveHoldsVault.
  ///
  /// In en, this message translates to:
  /// **'Google Drive already holds a Keyhold vault. Its master password is needed to join it.'**
  String get driveHoldsVault;

  /// No description provided for @masterPasswordOfDriveVault.
  ///
  /// In en, this message translates to:
  /// **'Master password of the vault in Google Drive'**
  String get masterPasswordOfDriveVault;

  /// No description provided for @driveHint.
  ///
  /// In en, this message translates to:
  /// **'Keeps the encrypted vault in a \"Keyhold\" folder in your own Google Drive, so your other devices stay in sync and a lost computer loses nothing. Google cannot read it.'**
  String get driveHint;

  /// No description provided for @driveNotInBuild.
  ///
  /// In en, this message translates to:
  /// **'Google Drive is not set up in this build.'**
  String get driveNotInBuild;

  /// No description provided for @setPasswordFirst.
  ///
  /// In en, this message translates to:
  /// **'Set a master password first — a new device needs it to open the vault.'**
  String get setPasswordFirst;

  /// No description provided for @foldersOnComputer.
  ///
  /// In en, this message translates to:
  /// **'Folders on this computer'**
  String get foldersOnComputer;

  /// No description provided for @folderCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 folder} other{{count} folders}}'**
  String folderCount(int count);

  /// No description provided for @folderCountCopied.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 folder — last copy {time}} other{{count} folders — last copy {time}}}'**
  String folderCountCopied(int count, String time);

  /// No description provided for @yourServer.
  ///
  /// In en, this message translates to:
  /// **'Your server'**
  String get yourServer;

  /// No description provided for @foldersHint.
  ///
  /// In en, this message translates to:
  /// **'Every save drops a dated copy into each folder and keeps the last 30.'**
  String get foldersHint;

  /// No description provided for @noFolders.
  ///
  /// In en, this message translates to:
  /// **'No folders — local copies are off'**
  String get noFolders;

  /// No description provided for @addFolder.
  ///
  /// In en, this message translates to:
  /// **'Add folder'**
  String get addFolder;

  /// No description provided for @serverHint.
  ///
  /// In en, this message translates to:
  /// **'The same copy goes over SFTP to a machine you own. The file stays encrypted, so the server sees bytes and nothing else. Leave the host empty to skip this.'**
  String get serverHint;

  /// No description provided for @host.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get host;

  /// No description provided for @port.
  ///
  /// In en, this message translates to:
  /// **'Port'**
  String get port;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @privateKeyFile.
  ///
  /// In en, this message translates to:
  /// **'Private key file'**
  String get privateKeyFile;

  /// No description provided for @chooseFile.
  ///
  /// In en, this message translates to:
  /// **'Choose file'**
  String get chooseFile;

  /// No description provided for @serverFolder.
  ///
  /// In en, this message translates to:
  /// **'Folder on the server'**
  String get serverFolder;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test connection'**
  String get testConnection;

  /// No description provided for @notReachable.
  ///
  /// In en, this message translates to:
  /// **'Not reachable right now'**
  String get notReachable;

  /// No description provided for @enterCodeKey.
  ///
  /// In en, this message translates to:
  /// **'Enter the key of the two-factor code'**
  String get enterCodeKey;

  /// No description provided for @twoFactorCode.
  ///
  /// In en, this message translates to:
  /// **'Two-factor code'**
  String get twoFactorCode;

  /// No description provided for @newEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'New entry'**
  String get newEntryTitle;

  /// No description provided for @editEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get editEntry;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @key.
  ///
  /// In en, this message translates to:
  /// **'Key'**
  String get key;

  /// No description provided for @keyHint.
  ///
  /// In en, this message translates to:
  /// **'Paste the setup key or the whole otpauth:// link'**
  String get keyHint;

  /// No description provided for @note.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get note;

  /// No description provided for @addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addresses;

  /// No description provided for @codeNotUsedYet.
  ///
  /// In en, this message translates to:
  /// **'Not used anywhere yet. It pins itself the first time you use it on a site, or pin it from a login.'**
  String get codeNotUsedYet;

  /// No description provided for @noAddress.
  ///
  /// In en, this message translates to:
  /// **'no address'**
  String get noAddress;

  /// No description provided for @unpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpin;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add an address'**
  String get addAddress;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'(no name)'**
  String get noName;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @choose.
  ///
  /// In en, this message translates to:
  /// **'Choose'**
  String get choose;

  /// No description provided for @group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get group;

  /// No description provided for @groupHint.
  ///
  /// In en, this message translates to:
  /// **'Pick one or type a new name'**
  String get groupHint;

  /// No description provided for @driveTabConnected.
  ///
  /// In en, this message translates to:
  /// **'Keyhold is connected to Google Drive. You can close this tab.'**
  String get driveTabConnected;

  /// No description provided for @driveTabNotConnected.
  ///
  /// In en, this message translates to:
  /// **'Google Drive was not connected. You can close this tab.'**
  String get driveTabNotConnected;

  /// No description provided for @signInTooLong.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in took too long — try again'**
  String get signInTooLong;

  /// No description provided for @signInCancelled.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in was cancelled'**
  String get signInCancelled;

  /// No description provided for @noOfflineAccess.
  ///
  /// In en, this message translates to:
  /// **'Google did not allow offline access'**
  String get noOfflineAccess;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternet;

  /// No description provided for @wrongMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong master password'**
  String get wrongMasterPassword;

  /// No description provided for @driveRefusedDownload.
  ///
  /// In en, this message translates to:
  /// **'Google Drive refused the download ({status})'**
  String driveRefusedDownload(String status);

  /// No description provided for @driveRefusedUpload.
  ///
  /// In en, this message translates to:
  /// **'Google Drive refused the upload ({status})'**
  String driveRefusedUpload(String status);

  /// No description provided for @driveAnswered.
  ///
  /// In en, this message translates to:
  /// **'Google Drive answered {status}'**
  String driveAnswered(String status);

  /// No description provided for @driveSignInAgain.
  ///
  /// In en, this message translates to:
  /// **'Google Drive needs you to sign in again'**
  String get driveSignInAgain;

  /// No description provided for @driveNotConnectedError.
  ///
  /// In en, this message translates to:
  /// **'Google Drive is not connected'**
  String get driveNotConnectedError;

  /// No description provided for @driveAccessEnded.
  ///
  /// In en, this message translates to:
  /// **'Google Drive access ended — connect again'**
  String get driveAccessEnded;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed ({status})'**
  String signInFailed(String status);

  /// No description provided for @dupNewest.
  ///
  /// In en, this message translates to:
  /// **'newest'**
  String get dupNewest;

  /// No description provided for @dupSamePassword.
  ///
  /// In en, this message translates to:
  /// **'same password as the newest'**
  String get dupSamePassword;

  /// No description provided for @dupDifferentPassword.
  ///
  /// In en, this message translates to:
  /// **'different password'**
  String get dupDifferentPassword;

  /// No description provided for @noUsername.
  ///
  /// In en, this message translates to:
  /// **'(no username)'**
  String get noUsername;

  /// No description provided for @duplicateNote.
  ///
  /// In en, this message translates to:
  /// **'{username} · {password} · changed {day}'**
  String duplicateNote(String username, String password, String day);

  /// No description provided for @fileEmpty.
  ///
  /// In en, this message translates to:
  /// **'The file is empty'**
  String get fileEmpty;

  /// No description provided for @noLoginColumns.
  ///
  /// In en, this message translates to:
  /// **'No username or password column found in this file'**
  String get noLoginColumns;

  /// No description provided for @noQrOnScreen.
  ///
  /// In en, this message translates to:
  /// **'No QR code found on the screen'**
  String get noQrOnScreen;

  /// No description provided for @noQrInImage.
  ///
  /// In en, this message translates to:
  /// **'No QR code found in this image'**
  String get noQrInImage;

  /// No description provided for @qrNotTwoFactor.
  ///
  /// In en, this message translates to:
  /// **'This QR code is not a two-factor code'**
  String get qrNotTwoFactor;

  /// No description provided for @exportQrEmpty.
  ///
  /// In en, this message translates to:
  /// **'The export QR code is empty'**
  String get exportQrEmpty;

  /// No description provided for @exportQrUnreadable.
  ///
  /// In en, this message translates to:
  /// **'This export QR code could not be read'**
  String get exportQrUnreadable;

  /// No description provided for @serverWritable.
  ///
  /// In en, this message translates to:
  /// **'Connected as {account}, folder is writable'**
  String serverWritable(String account);

  /// No description provided for @openKeyhold.
  ///
  /// In en, this message translates to:
  /// **'Open Keyhold'**
  String get openKeyhold;

  /// No description provided for @quit.
  ///
  /// In en, this message translates to:
  /// **'Quit'**
  String get quit;

  /// No description provided for @codesFound.
  ///
  /// In en, this message translates to:
  /// **'{count} found'**
  String codesFound(int count);

  /// No description provided for @codesUnsupported.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 uses a code type Keyhold cannot generate yet} other{{count} use a code type Keyhold cannot generate yet}}'**
  String codesUnsupported(int count);

  /// No description provided for @savedAs.
  ///
  /// In en, this message translates to:
  /// **'Saved as {name}'**
  String savedAs(String name);

  /// No description provided for @savedCodes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Saved 1 code} other{Saved {count} codes}}'**
  String savedCodes(int count);

  /// No description provided for @images.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get images;

  /// No description provided for @addCodes.
  ///
  /// In en, this message translates to:
  /// **'Add two-factor codes'**
  String get addCodes;

  /// No description provided for @saveAll.
  ///
  /// In en, this message translates to:
  /// **'Save all'**
  String get saveAll;

  /// No description provided for @qrHintPhone.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the QR code a website shows when you turn on two-factor login, or at the export from Google Authenticator (Transfer accounts → Export).'**
  String get qrHintPhone;

  /// No description provided for @qrHintComputer.
  ///
  /// In en, this message translates to:
  /// **'Show the QR code on the screen and scan it. It can be the code a website shows when you turn on two-factor login, or the export from Google Authenticator (Transfer accounts → Export). A photo of the code works too.'**
  String get qrHintComputer;

  /// No description provided for @qrMicrosoftHint.
  ///
  /// In en, this message translates to:
  /// **'Microsoft Authenticator cannot export its codes — turn two-factor login off and on again on each site and scan the new code here.'**
  String get qrMicrosoftHint;

  /// No description provided for @scanCamera.
  ///
  /// In en, this message translates to:
  /// **'Scan with the camera'**
  String get scanCamera;

  /// No description provided for @scanScreen.
  ///
  /// In en, this message translates to:
  /// **'Scan the screen'**
  String get scanScreen;

  /// No description provided for @openImage.
  ///
  /// In en, this message translates to:
  /// **'Open an image'**
  String get openImage;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @alreadyInKeyhold.
  ///
  /// In en, this message translates to:
  /// **'Already in Keyhold'**
  String get alreadyInKeyhold;

  /// No description provided for @asName.
  ///
  /// In en, this message translates to:
  /// **'as \"{name}\"'**
  String asName(String name);

  /// No description provided for @typePasswordFirst.
  ///
  /// In en, this message translates to:
  /// **'Type your password first'**
  String get typePasswordFirst;

  /// No description provided for @atLeast8.
  ///
  /// In en, this message translates to:
  /// **'Use at least 8 characters'**
  String get atLeast8;

  /// No description provided for @passwordsDiffer.
  ///
  /// In en, this message translates to:
  /// **'The two passwords differ'**
  String get passwordsDiffer;

  /// No description provided for @passwordDoesNotOpen.
  ///
  /// In en, this message translates to:
  /// **'That password does not open this vault'**
  String get passwordDoesNotOpen;

  /// No description provided for @currentPasswordWrong.
  ///
  /// In en, this message translates to:
  /// **'The current master password is wrong'**
  String get currentPasswordWrong;

  /// No description provided for @unlockVault.
  ///
  /// In en, this message translates to:
  /// **'Unlock vault'**
  String get unlockVault;

  /// No description provided for @unlockHint.
  ///
  /// In en, this message translates to:
  /// **'This vault came from another machine. Type the master password to open it here.'**
  String get unlockHint;

  /// No description provided for @masterPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Windows opens this vault for you automatically. The master password is the way back in after a reinstall, on a new machine, or on your phone.'**
  String get masterPasswordHint;

  /// No description provided for @currentMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'Current master password'**
  String get currentMasterPassword;

  /// No description provided for @newMasterPassword.
  ///
  /// In en, this message translates to:
  /// **'New master password'**
  String get newMasterPassword;

  /// No description provided for @repeatIt.
  ///
  /// In en, this message translates to:
  /// **'Repeat it'**
  String get repeatIt;

  /// No description provided for @openVault.
  ///
  /// In en, this message translates to:
  /// **'Open vault'**
  String get openVault;

  /// No description provided for @savePassword.
  ///
  /// In en, this message translates to:
  /// **'Save password'**
  String get savePassword;

  /// No description provided for @nobodyCanRecover.
  ///
  /// In en, this message translates to:
  /// **'If you forget it, only the recovery key opens your vault: print the recovery sheet.'**
  String get nobodyCanRecover;

  /// No description provided for @groupApps.
  ///
  /// In en, this message translates to:
  /// **'Apps'**
  String get groupApps;

  /// No description provided for @openKeyholdFirst.
  ///
  /// In en, this message translates to:
  /// **'Open Keyhold once and enter the master password, then try again.'**
  String get openKeyholdFirst;

  /// No description provided for @pinTo.
  ///
  /// In en, this message translates to:
  /// **'Pin \"{name}\" to {place}?'**
  String pinTo(String name, String place);

  /// No description provided for @pinHint.
  ///
  /// In en, this message translates to:
  /// **'Then it is offered here right away, without searching.'**
  String get pinHint;

  /// No description provided for @doNotAskCode.
  ///
  /// In en, this message translates to:
  /// **'Do not ask about this code again'**
  String get doNotAskCode;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pin;

  /// No description provided for @savedToKeyhold.
  ///
  /// In en, this message translates to:
  /// **'Saved to Keyhold'**
  String get savedToKeyhold;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated in Keyhold'**
  String get passwordUpdated;

  /// No description provided for @searchAllLogins.
  ///
  /// In en, this message translates to:
  /// **'Search all logins'**
  String get searchAllLogins;

  /// No description provided for @nothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found.'**
  String get nothingFound;

  /// No description provided for @noLoginForSite.
  ///
  /// In en, this message translates to:
  /// **'No login for this site yet. Search above, or log in and Android will offer to save it.'**
  String get noLoginForSite;

  /// No description provided for @noLoginForApp.
  ///
  /// In en, this message translates to:
  /// **'No login for this app yet. Search above, or log in and Android will offer to save it.'**
  String get noLoginForApp;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening on {address}'**
  String listening(String address);

  /// No description provided for @notListening.
  ///
  /// In en, this message translates to:
  /// **'Not listening — another Keyhold may already be running'**
  String get notListening;

  /// No description provided for @pairingToken.
  ///
  /// In en, this message translates to:
  /// **'Pairing token'**
  String get pairingToken;

  /// No description provided for @pairingTokenHint.
  ///
  /// In en, this message translates to:
  /// **'Paste this into the extension once. Only requests carrying it are answered, and only from the extension itself — a web page cannot reach the vault.'**
  String get pairingTokenHint;

  /// No description provided for @tokenCopied.
  ///
  /// In en, this message translates to:
  /// **'Token copied'**
  String get tokenCopied;

  /// No description provided for @copyToken.
  ///
  /// In en, this message translates to:
  /// **'Copy token'**
  String get copyToken;

  /// No description provided for @installIt.
  ///
  /// In en, this message translates to:
  /// **'Install it'**
  String get installIt;

  /// No description provided for @installChrome.
  ///
  /// In en, this message translates to:
  /// **'Chrome or Edge: open chrome://extensions, turn on Developer mode, click \"Load unpacked\" and pick the folder below.'**
  String get installChrome;

  /// No description provided for @installFirefox.
  ///
  /// In en, this message translates to:
  /// **'Firefox: open about:debugging#/runtime/this-firefox, click \"Load Temporary Add-on\" and pick manifest.json in that folder.'**
  String get installFirefox;

  /// No description provided for @installPaste.
  ///
  /// In en, this message translates to:
  /// **'Click the Keyhold icon in the toolbar and paste the token.'**
  String get installPaste;

  /// No description provided for @newCodeShort.
  ///
  /// In en, this message translates to:
  /// **'New code'**
  String get newCodeShort;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @searchCodes.
  ///
  /// In en, this message translates to:
  /// **'Search codes'**
  String get searchCodes;

  /// No description provided for @everyCodePinned.
  ///
  /// In en, this message translates to:
  /// **'Every code is pinned somewhere. Switch to All to see them.'**
  String get everyCodePinned;

  /// No description provided for @noCodesFound.
  ///
  /// In en, this message translates to:
  /// **'No codes found.'**
  String get noCodesFound;

  /// No description provided for @pinnedTo.
  ///
  /// In en, this message translates to:
  /// **'pinned to {hosts}'**
  String pinnedTo(String hosts);

  /// No description provided for @notPinned.
  ///
  /// In en, this message translates to:
  /// **'not pinned'**
  String get notPinned;

  /// No description provided for @changedOn.
  ///
  /// In en, this message translates to:
  /// **'changed {day}'**
  String changedOn(String day);

  /// No description provided for @importPasswords.
  ///
  /// In en, this message translates to:
  /// **'Import passwords'**
  String get importPasswords;

  /// No description provided for @importHint.
  ///
  /// In en, this message translates to:
  /// **'Export your passwords from the browser as CSV, then load the file here. Chrome, Edge, Firefox, Bitwarden and KeePassXC exports all work.'**
  String get importHint;

  /// No description provided for @chooseCsv.
  ///
  /// In en, this message translates to:
  /// **'Choose CSV file'**
  String get chooseCsv;

  /// No description provided for @entriesReady.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entry ready} other{{count} entries ready}}'**
  String entriesReady(int count);

  /// No description provided for @entriesReadySkipped.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entry ready} other{{count} entries ready}}, {skipped, plural, =1{1 empty row skipped} other{{skipped} empty rows skipped}}'**
  String entriesReadySkipped(int count, int skipped);

  /// No description provided for @andMore.
  ///
  /// In en, this message translates to:
  /// **'and {count} more'**
  String andMore(int count);

  /// No description provided for @deleteCsv.
  ///
  /// In en, this message translates to:
  /// **'Delete the CSV file after importing'**
  String get deleteCsv;

  /// No description provided for @deleteCsvHint.
  ///
  /// In en, this message translates to:
  /// **'It holds every password in plain text'**
  String get deleteCsvHint;

  /// No description provided for @importEntries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Import 1 entry} other{Import {count} entries}}'**
  String importEntries(int count);

  /// No description provided for @cameraHint.
  ///
  /// In en, this message translates to:
  /// **'Point at the two-factor QR code of a website, or at the export from Google Authenticator.'**
  String get cameraHint;

  /// No description provided for @deleteThisCode.
  ///
  /// In en, this message translates to:
  /// **'Delete this two-factor code?'**
  String get deleteThisCode;

  /// No description provided for @deleteCodeWarning.
  ///
  /// In en, this message translates to:
  /// **'It disappears from all your devices. Without it you cannot sign in where it is used.'**
  String get deleteCodeWarning;

  /// No description provided for @deleteLoginWarning.
  ///
  /// In en, this message translates to:
  /// **'It disappears from all your devices.'**
  String get deleteLoginWarning;

  /// No description provided for @nextCode.
  ///
  /// In en, this message translates to:
  /// **'next {code}'**
  String nextCode(String code);

  /// No description provided for @noMasterPasswordBar.
  ///
  /// In en, this message translates to:
  /// **'No master password: your backups cannot be opened on another computer. Click to set one.'**
  String get noMasterPasswordBar;

  /// No description provided for @printRecoverySheet.
  ///
  /// In en, this message translates to:
  /// **'Print the recovery sheet'**
  String get printRecoverySheet;

  /// No description provided for @recoverySheet.
  ///
  /// In en, this message translates to:
  /// **'Recovery sheet'**
  String get recoverySheet;

  /// No description provided for @recoveryIntro.
  ///
  /// In en, this message translates to:
  /// **'This key opens your vault if you ever forget the master password. Print the sheet, copy the last row onto it by hand, and keep it at home.'**
  String get recoveryIntro;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @sheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Keyhold recovery sheet'**
  String get sheetTitle;

  /// No description provided for @sheetMade.
  ///
  /// In en, this message translates to:
  /// **'Made on {date}'**
  String sheetMade(String date);

  /// No description provided for @sheetWhere.
  ///
  /// In en, this message translates to:
  /// **'Where your vault is'**
  String get sheetWhere;

  /// No description provided for @sheetDrive.
  ///
  /// In en, this message translates to:
  /// **'Google Drive of {email}, folder \"Keyhold\"'**
  String sheetDrive(String email);

  /// No description provided for @sheetFolders.
  ///
  /// In en, this message translates to:
  /// **'Copies in folders: {folders}'**
  String sheetFolders(String folders);

  /// No description provided for @sheetServer.
  ///
  /// In en, this message translates to:
  /// **'Copies on the server {host}'**
  String sheetServer(String host);

  /// No description provided for @sheetOnlyHere.
  ///
  /// In en, this message translates to:
  /// **'Only on this device. Turn on a backup in Keyhold.'**
  String get sheetOnlyHere;

  /// No description provided for @sheetSteps.
  ///
  /// In en, this message translates to:
  /// **'On a new computer or phone'**
  String get sheetSteps;

  /// No description provided for @sheetStep1.
  ///
  /// In en, this message translates to:
  /// **'Install Keyhold: galusz.github.io/keyhold'**
  String get sheetStep1;

  /// No description provided for @sheetStep2.
  ///
  /// In en, this message translates to:
  /// **'Connect the same Google Drive in Keyhold.'**
  String get sheetStep2;

  /// No description provided for @sheetStep3.
  ///
  /// In en, this message translates to:
  /// **'When Keyhold asks for the master password, type this recovery key. Then choose a new master password.'**
  String get sheetStep3;

  /// No description provided for @sheetKeepSafe.
  ///
  /// In en, this message translates to:
  /// **'Anyone with this completed sheet can open your vault. Keep it like a spare house key.'**
  String get sheetKeepSafe;

  /// No description provided for @sheetDriveNoEmail.
  ///
  /// In en, this message translates to:
  /// **'Google Drive, folder \"Keyhold\"'**
  String get sheetDriveNoEmail;

  /// No description provided for @noBackupPlaces.
  ///
  /// In en, this message translates to:
  /// **'No backup folder, server or Google Drive: the vault is only on this computer. Click to set one up.'**
  String get noBackupPlaces;

  /// No description provided for @deleteVault.
  ///
  /// In en, this message translates to:
  /// **'Delete the vault'**
  String get deleteVault;

  /// No description provided for @deleteVaultHint.
  ///
  /// In en, this message translates to:
  /// **'Everything Keyhold keeps on this device is erased: passwords, two-factor codes, files and settings. Keyhold then closes and starts empty.'**
  String get deleteVaultHint;

  /// No description provided for @deleteVaultDrive.
  ///
  /// In en, this message translates to:
  /// **'Also delete it from Google Drive (other devices keep their own copy until you delete it there too)'**
  String get deleteVaultDrive;

  /// No description provided for @deleteVaultFolders.
  ///
  /// In en, this message translates to:
  /// **'Also delete the copies in the backup folders'**
  String get deleteVaultFolders;

  /// No description provided for @deleteVaultSure.
  ///
  /// In en, this message translates to:
  /// **'Delete the vault for good?'**
  String get deleteVaultSure;

  /// No description provided for @deleteVaultSureHint.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get deleteVaultSureHint;

  /// No description provided for @vaultDeleted.
  ///
  /// In en, this message translates to:
  /// **'The vault is deleted. Keyhold closes now.'**
  String get vaultDeleted;

  /// No description provided for @recoveryGate.
  ///
  /// In en, this message translates to:
  /// **'Type your master password to see the recovery key.'**
  String get recoveryGate;

  /// No description provided for @showKey.
  ///
  /// In en, this message translates to:
  /// **'Show the key'**
  String get showKey;

  /// No description provided for @recoveryNeedsPassword.
  ///
  /// In en, this message translates to:
  /// **'Set a master password first: the recovery key is shown only after it.'**
  String get recoveryNeedsPassword;

  /// No description provided for @recoveryCopyRow.
  ///
  /// In en, this message translates to:
  /// **'Copy this row by hand onto the printed sheet'**
  String get recoveryCopyRow;

  /// No description provided for @checkRow.
  ///
  /// In en, this message translates to:
  /// **'Then type the last row as you wrote it on the sheet'**
  String get checkRow;

  /// No description provided for @check.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get check;

  /// No description provided for @rowMatches.
  ///
  /// In en, this message translates to:
  /// **'It matches. Keep the sheet somewhere safe.'**
  String get rowMatches;

  /// No description provided for @rowDiffers.
  ///
  /// In en, this message translates to:
  /// **'It does not match. Compare the last row with the screen and correct it on the sheet.'**
  String get rowDiffers;

  /// No description provided for @sheetKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'Recovery key'**
  String get sheetKeyLabel;

  /// No description provided for @sheetCopyRow.
  ///
  /// In en, this message translates to:
  /// **'Copy the last row here by hand from the Keyhold screen.'**
  String get sheetCopyRow;

  /// No description provided for @orRecoveryCode.
  ///
  /// In en, this message translates to:
  /// **'Forgot it? Type the recovery key from your recovery sheet instead.'**
  String get orRecoveryCode;

  /// No description provided for @newPasswordAfterKey.
  ///
  /// In en, this message translates to:
  /// **'The recovery key opened your vault. Choose a new master password: it replaces the forgotten one on all your devices.'**
  String get newPasswordAfterKey;

  /// No description provided for @otherVaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Copies of another vault'**
  String get otherVaultTitle;

  /// No description provided for @otherVaultHint.
  ///
  /// In en, this message translates to:
  /// **'This folder already holds copies of another Keyhold vault (the newest from {when}). Open it to look inside? Your vault stays as it is.'**
  String otherVaultHint(String when);

  /// No description provided for @copyPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Master password of this copy'**
  String get copyPasswordTitle;

  /// No description provided for @copyNotOpened.
  ///
  /// In en, this message translates to:
  /// **'This copy did not open: wrong password or recovery key, or not a Keyhold vault.'**
  String get copyNotOpened;

  /// No description provided for @openCopy.
  ///
  /// In en, this message translates to:
  /// **'Open a backup copy…'**
  String get openCopy;

  /// No description provided for @copyTitle.
  ///
  /// In en, this message translates to:
  /// **'Copy: {name}'**
  String copyTitle(String name);

  /// No description provided for @copyReadOnly.
  ///
  /// In en, this message translates to:
  /// **'Only for looking: nothing here changes your vault. Any single entry can be added to your vault.'**
  String get copyReadOnly;

  /// No description provided for @addToVault.
  ///
  /// In en, this message translates to:
  /// **'Add to my vault'**
  String get addToVault;

  /// No description provided for @addedToVault.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" is in your vault'**
  String addedToVault(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'ja',
    'pl',
    'pt',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
