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

  /// No description provided for @connectDrive.
  ///
  /// In en, this message translates to:
  /// **'Connect Google Drive'**
  String get connectDrive;

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

  /// No description provided for @unlockVault.
  ///
  /// In en, this message translates to:
  /// **'Unlock vault'**
  String get unlockVault;

  /// No description provided for @unlockHint.
  ///
  /// In en, this message translates to:
  /// **'Keyhold cannot open this vault by itself on this device, for example after the system was reinstalled or the vault was copied from another computer. Type its master password.'**
  String get unlockHint;

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

  /// No description provided for @deleteCsvHint.
  ///
  /// In en, this message translates to:
  /// **'It holds every password in plain text'**
  String get deleteCsvHint;

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
  /// **'Choose “Open my vault”, then “From Google Drive” (or “From a file (.khd)” if you have a copy).'**
  String get sheetStep2;

  /// No description provided for @sheetStep3.
  ///
  /// In en, this message translates to:
  /// **'Type this recovery key instead of the master password. Then choose a new master password.'**
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

  /// No description provided for @myVault.
  ///
  /// In en, this message translates to:
  /// **'My vault'**
  String get myVault;

  /// No description provided for @vaultTab.
  ///
  /// In en, this message translates to:
  /// **'Vault'**
  String get vaultTab;

  /// No description provided for @syncTab.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get syncTab;

  /// No description provided for @copiesTab.
  ///
  /// In en, this message translates to:
  /// **'Backups'**
  String get copiesTab;

  /// No description provided for @startHint.
  ///
  /// In en, this message translates to:
  /// **'Your passwords and two-factor codes in one vault: on your computer, on your phone and in your browser.'**
  String get startHint;

  /// No description provided for @createVault.
  ///
  /// In en, this message translates to:
  /// **'Create a new vault'**
  String get createVault;

  /// No description provided for @openMyVault.
  ///
  /// In en, this message translates to:
  /// **'Open my vault'**
  String get openMyVault;

  /// No description provided for @newVault.
  ///
  /// In en, this message translates to:
  /// **'New vault'**
  String get newVault;

  /// No description provided for @vaultName.
  ///
  /// In en, this message translates to:
  /// **'Vault name'**
  String get vaultName;

  /// No description provided for @newVaultHint.
  ///
  /// In en, this message translates to:
  /// **'The master password opens this vault on each of your devices: computer, phone and browser. Keyhold can\'t recover it; the recovery key you get next can.'**
  String get newVaultHint;

  /// No description provided for @sealHint.
  ///
  /// In en, this message translates to:
  /// **'Your vault has no master password yet. Set it now: it opens this vault on your other devices and in the browser.'**
  String get sealHint;

  /// No description provided for @createVaultButton.
  ///
  /// In en, this message translates to:
  /// **'Create the vault'**
  String get createVaultButton;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot the password?'**
  String get forgotPassword;

  /// No description provided for @usePassword.
  ///
  /// In en, this message translates to:
  /// **'Use the master password'**
  String get usePassword;

  /// No description provided for @recoveryKey.
  ///
  /// In en, this message translates to:
  /// **'Recovery key'**
  String get recoveryKey;

  /// No description provided for @recoveryKeyFieldHint.
  ///
  /// In en, this message translates to:
  /// **'The 36 characters from your recovery sheet; spaces don\'t matter.'**
  String get recoveryKeyFieldHint;

  /// No description provided for @openVaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Open a vault'**
  String get openVaultTitle;

  /// No description provided for @openVaultHint.
  ///
  /// In en, this message translates to:
  /// **'The vault opens as it is. It is never merged with another vault.'**
  String get openVaultHint;

  /// No description provided for @fromDrive.
  ///
  /// In en, this message translates to:
  /// **'From Google Drive'**
  String get fromDrive;

  /// No description provided for @fromDriveHint.
  ///
  /// In en, this message translates to:
  /// **'Sign in to Google, then type the vault\'s master password.'**
  String get fromDriveHint;

  /// No description provided for @fromDriveAs.
  ///
  /// In en, this message translates to:
  /// **'{email}: type the vault\'s master password.'**
  String fromDriveAs(String email);

  /// No description provided for @fromFile.
  ///
  /// In en, this message translates to:
  /// **'From a file (.khd)'**
  String get fromFile;

  /// No description provided for @fromFileHint.
  ///
  /// In en, this message translates to:
  /// **'A copy from a backup folder, a USB stick or an old computer.'**
  String get fromFileHint;

  /// No description provided for @closedHere.
  ///
  /// In en, this message translates to:
  /// **'Opened on this device before'**
  String get closedHere;

  /// No description provided for @closedOn.
  ///
  /// In en, this message translates to:
  /// **'closed {date}'**
  String closedOn(String date);

  /// No description provided for @closedVaultGone.
  ///
  /// In en, this message translates to:
  /// **'That vault\'s file is no longer on this device.'**
  String get closedVaultGone;

  /// No description provided for @typeVaultPassword.
  ///
  /// In en, this message translates to:
  /// **'Type the master password of the vault you want to open. Keyhold tries it on every vault in your Google Drive.'**
  String get typeVaultPassword;

  /// No description provided for @lookingForVault.
  ///
  /// In en, this message translates to:
  /// **'Looking for your vault: {at} of {of}'**
  String lookingForVault(int at, int of);

  /// No description provided for @noVaultInDrive.
  ///
  /// In en, this message translates to:
  /// **'There is no Keyhold vault in this Google Drive yet.'**
  String get noVaultInDrive;

  /// No description provided for @noVaultMatches.
  ///
  /// In en, this message translates to:
  /// **'No vault in your Google Drive opens with this password.'**
  String get noVaultMatches;

  /// No description provided for @sameVaultFile.
  ///
  /// In en, this message translates to:
  /// **'This file is a copy of the vault you have open. To take entries out of it, use Backups, then Review a copy.'**
  String get sameVaultFile;

  /// No description provided for @fileVaultPassword.
  ///
  /// In en, this message translates to:
  /// **'Type the master password of {name}.'**
  String fileVaultPassword(String name);

  /// No description provided for @driveFileUnreadable.
  ///
  /// In en, this message translates to:
  /// **'This vault\'s file in Google Drive can\'t be read. Keyhold leaves it as it is.'**
  String get driveFileUnreadable;

  /// No description provided for @vaultInfoHint.
  ///
  /// In en, this message translates to:
  /// **'This vault opens with its master password on every device. If you forget the password, the recovery key opens the vault and you choose a new one.'**
  String get vaultInfoHint;

  /// No description provided for @recoveryKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Shown and printed after the master password'**
  String get recoveryKeyHint;

  /// No description provided for @otherVaults.
  ///
  /// In en, this message translates to:
  /// **'Other vaults'**
  String get otherVaults;

  /// No description provided for @openOtherVault.
  ///
  /// In en, this message translates to:
  /// **'Open another vault'**
  String get openOtherVault;

  /// No description provided for @openOtherVaultHint.
  ///
  /// In en, this message translates to:
  /// **'From Google Drive, from a file or from this device'**
  String get openOtherVaultHint;

  /// No description provided for @createNewVaultHint.
  ///
  /// In en, this message translates to:
  /// **'Empty, with its own master password'**
  String get createNewVaultHint;

  /// No description provided for @closeVaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Close \"{name}\" on this device?'**
  String closeVaultTitle(String name);

  /// No description provided for @closeVaultHint.
  ///
  /// In en, this message translates to:
  /// **'Nothing is deleted: it stays in Google Drive, in the backup copies and on this device\'s list of vaults. It opens again with its master password.'**
  String get closeVaultHint;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @renameVault.
  ///
  /// In en, this message translates to:
  /// **'Rename the vault'**
  String get renameVault;

  /// No description provided for @reviewCopy.
  ///
  /// In en, this message translates to:
  /// **'Review a copy'**
  String get reviewCopy;

  /// No description provided for @driveVaultHint.
  ///
  /// In en, this message translates to:
  /// **'Keeps this vault as its own encrypted file in a \"Keyhold\" folder in your Google Drive. Your other devices open it with its master password. Several vaults can share one Google Drive; they never mix. Google cannot read them.'**
  String get driveVaultHint;

  /// No description provided for @foldersSlotsHint.
  ///
  /// In en, this message translates to:
  /// **'Every save updates up to 7 copies of the vault in each folder: the latest one, and ones about an hour, a day, a week, a month, three months and a year old.'**
  String get foldersSlotsHint;

  /// No description provided for @deleteVaultHereHint.
  ///
  /// In en, this message translates to:
  /// **'The vault is erased from this device: passwords, two-factor codes and files. Vaults opened here before stay. Keyhold then shows its start screen.'**
  String get deleteVaultHereHint;

  /// No description provided for @deleteVaultDriveMine.
  ///
  /// In en, this message translates to:
  /// **'Also delete it from Google Drive (other vaults there stay)'**
  String get deleteVaultDriveMine;

  /// No description provided for @vaultDeletedHere.
  ///
  /// In en, this message translates to:
  /// **'The vault is deleted.'**
  String get vaultDeletedHere;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @importTitle.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importTitle;

  /// No description provided for @importMenuHint.
  ///
  /// In en, this message translates to:
  /// **'Passwords and codes from other apps or another vault'**
  String get importMenuHint;

  /// No description provided for @importAnyHint.
  ///
  /// In en, this message translates to:
  /// **'Choose an export from another password manager or authenticator app, a KeePass database or another Keyhold vault. Keyhold tells from the file what it is, and you tick what comes in.'**
  String get importAnyHint;

  /// No description provided for @importReading.
  ///
  /// In en, this message translates to:
  /// **'Reading the file…'**
  String get importReading;

  /// No description provided for @importPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Password of this {format} file'**
  String importPasswordTitle(String format);

  /// No description provided for @importWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'That password doesn\'t open this file.'**
  String get importWrongPassword;

  /// No description provided for @importUnknown.
  ///
  /// In en, this message translates to:
  /// **'Keyhold doesn\'t recognise this file. Export again from the other app, as CSV or JSON.'**
  String get importUnknown;

  /// No description provided for @importNothing.
  ///
  /// In en, this message translates to:
  /// **'{format}: nothing in this file that Keyhold can keep.'**
  String importNothing(String format);

  /// No description provided for @keePassUnsupported.
  ///
  /// In en, this message translates to:
  /// **'This KeePass database uses something Keyhold can\'t open (a key file or the Twofish cipher). Export it from KeePass as CSV instead.'**
  String get keePassUnsupported;

  /// No description provided for @bitwardenAccountLocked.
  ///
  /// In en, this message translates to:
  /// **'This Bitwarden export only opens with your Bitwarden account. Export again as JSON, password protected or without encryption.'**
  String get bitwardenAccountLocked;

  /// No description provided for @otpLinks.
  ///
  /// In en, this message translates to:
  /// **'otpauth links'**
  String get otpLinks;

  /// No description provided for @importPickHint.
  ///
  /// In en, this message translates to:
  /// **'Tick what should go into your vault. Entries you already have are left unticked.'**
  String get importPickHint;

  /// No description provided for @codesLeftOut.
  ///
  /// In en, this message translates to:
  /// **'Codes left out: {count}. Keyhold makes 6-digit codes every 30 seconds only, not 8 digits, 60 seconds, counters or Steam.'**
  String codesLeftOut(int count);

  /// No description provided for @recordsLeftOut.
  ///
  /// In en, this message translates to:
  /// **'Records left out: {count} (empty ones, cards and identities).'**
  String recordsLeftOut(int count);

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get selectAll;

  /// No description provided for @alreadyInVault.
  ///
  /// In en, this message translates to:
  /// **'already in your vault'**
  String get alreadyInVault;

  /// No description provided for @addSelected.
  ///
  /// In en, this message translates to:
  /// **'Add ({count})'**
  String addSelected(int count);

  /// No description provided for @addedCount.
  ///
  /// In en, this message translates to:
  /// **'Added to your vault: {count}'**
  String addedCount(int count);

  /// No description provided for @deletePlainFile.
  ///
  /// In en, this message translates to:
  /// **'Delete the file afterwards'**
  String get deletePlainFile;

  /// No description provided for @importPasswordsFrom.
  ///
  /// In en, this message translates to:
  /// **'Passwords'**
  String get importPasswordsFrom;

  /// No description provided for @importPasswordsList.
  ///
  /// In en, this message translates to:
  /// **'Chrome, Edge, Firefox and Safari (CSV), Bitwarden (CSV or JSON), 1Password (.1pux or CSV), KeePass and KeePassXC (.kdbx or CSV), LastPass, Proton Pass, NordPass and Dashlane (CSV), and another Keyhold vault (.khd).'**
  String get importPasswordsList;

  /// No description provided for @importCodesFrom.
  ///
  /// In en, this message translates to:
  /// **'Two-factor codes'**
  String get importCodesFrom;

  /// No description provided for @importCodesList.
  ///
  /// In en, this message translates to:
  /// **'Aegis (.json), 2FAS (.2fas), Ente Auth, FreeOTP+ and andOTP, and any file of otpauth:// links. Google Authenticator: show its export QR code and use Keyhold\'s QR code button.'**
  String get importCodesList;

  /// No description provided for @importNoExport.
  ///
  /// In en, this message translates to:
  /// **'Microsoft Authenticator and Authy don\'t let codes out: turn two-factor on again at each service and scan its new QR code.'**
  String get importNoExport;

  /// No description provided for @foldersOnPhone.
  ///
  /// In en, this message translates to:
  /// **'Folders on this phone'**
  String get foldersOnPhone;

  /// No description provided for @phoneFoldersHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a folder in the phone, on its memory card, or of an app such as Nextcloud or OneDrive that lets Android save there.'**
  String get phoneFoldersHint;

  /// No description provided for @copiesPlaces.
  ///
  /// In en, this message translates to:
  /// **'Folders and your server'**
  String get copiesPlaces;

  /// No description provided for @shareVaultCopy.
  ///
  /// In en, this message translates to:
  /// **'Share a copy of the vault'**
  String get shareVaultCopy;

  /// No description provided for @shareVaultHint.
  ///
  /// In en, this message translates to:
  /// **'You can also mail the vault file or keep it in Files: it opens only with the master password or the recovery key.'**
  String get shareVaultHint;

  /// No description provided for @confirmFill.
  ///
  /// In en, this message translates to:
  /// **'Confirm to fill in {name}'**
  String confirmFill(String name);

  /// No description provided for @guardedSwitch.
  ///
  /// In en, this message translates to:
  /// **'Ask for a fingerprint when filling in'**
  String get guardedSwitch;

  /// No description provided for @guardedSwitchHint.
  ///
  /// In en, this message translates to:
  /// **'A fingerprint on the phone, Windows Hello on the computer — before the password or code goes into a page or an app.'**
  String get guardedSwitchHint;

  /// No description provided for @helloSwitch.
  ///
  /// In en, this message translates to:
  /// **'Open Keyhold with Windows Hello'**
  String get helloSwitch;

  /// No description provided for @helloSwitchHint.
  ///
  /// In en, this message translates to:
  /// **'Face, fingerprint or Windows PIN. Locks after 5 minutes without use. Filling in from the browser keeps working.'**
  String get helloSwitchHint;

  /// No description provided for @helloConfirmHint.
  ///
  /// In en, this message translates to:
  /// **'Confirm with Windows Hello'**
  String get helloConfirmHint;

  /// No description provided for @lockedInstead.
  ///
  /// In en, this message translates to:
  /// **'Neither the password nor the recovery key? Open another vault or create a new one. This one is set aside, not deleted.'**
  String get lockedInstead;

  /// No description provided for @setAsideOn.
  ///
  /// In en, this message translates to:
  /// **'set aside on {date}, opens with its master password'**
  String setAsideOn(String date);

  /// No description provided for @doneAfterCheck.
  ///
  /// In en, this message translates to:
  /// **'“Done” turns on once the last row matches.'**
  String get doneAfterCheck;

  /// No description provided for @lastCopyFailed.
  ///
  /// In en, this message translates to:
  /// **'The last copy failed'**
  String get lastCopyFailed;

  /// No description provided for @guardOpenHint.
  ///
  /// In en, this message translates to:
  /// **'Unlock protected entries for 5 minutes'**
  String get guardOpenHint;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save the changes?'**
  String get saveChanges;

  /// No description provided for @dontSave.
  ///
  /// In en, this message translates to:
  /// **'Don\'t save'**
  String get dontSave;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;
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
