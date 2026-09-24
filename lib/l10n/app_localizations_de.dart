// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get cancel => 'Abbrechen';

  @override
  String get open => 'Öffnen';

  @override
  String get delete => 'Löschen';

  @override
  String get copy => 'Kopieren';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get add => 'Hinzufügen';

  @override
  String get search => 'Suchen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get change => 'Ändern';

  @override
  String get connect => 'Verbinden';

  @override
  String get disconnect => 'Trennen';

  @override
  String get unlock => 'Entsperren';

  @override
  String get noTitle => '(kein Titel)';

  @override
  String get code => 'Code';

  @override
  String get codes => 'Codes';

  @override
  String get username => 'Nutzername';

  @override
  String get password => 'Passwort';

  @override
  String get address => 'Adresse';

  @override
  String get notes => 'Notizen';

  @override
  String get duplicates => 'Duplikate';

  @override
  String get masterPassword => 'Master-Passwort';

  @override
  String get setMasterPassword => 'Master-Passwort festlegen';

  @override
  String copied(String what) {
    return '$what kopiert';
  }

  @override
  String get fingerprintTitle => 'Keyhold-Tresor';

  @override
  String get fingerprintUnlockHint =>
      'Entsperren, um deine Passwörter und Codes zu sehen';

  @override
  String get fingerprintConfirmHint => 'Mit Fingerabdruck bestätigen';

  @override
  String driveNotConnected(String error) {
    return 'Google Drive wurde nicht verbunden: $error';
  }

  @override
  String get masterPasswordOfVault => 'Master-Passwort deines Tresors';

  @override
  String get masterPasswordFromComputer =>
      'Das Passwort aus Keyhold auf deinem Computer';

  @override
  String get scanQr => 'QR-Code scannen';

  @override
  String get scanQrHint =>
      'Zwei-Faktor-Code einer Website oder Export aus Google Authenticator';

  @override
  String get newCode => 'Neuer Zwei-Faktor-Code';

  @override
  String get newCodeHint => 'Einrichtungsschlüssel selbst eingeben';

  @override
  String get newLogin => 'Neue Zugangsdaten';

  @override
  String get locked => 'Keyhold ist gesperrt';

  @override
  String get everything => 'Alles';

  @override
  String get noCodesYet =>
      'Noch keine Zwei-Faktor-Codes – zum Scannen auf + tippen';

  @override
  String get nothingYet => 'Noch nichts hier';

  @override
  String get justNow => 'gerade eben';

  @override
  String minutesAgo(int count) {
    return 'vor $count Min.';
  }

  @override
  String hoursAgo(int count) {
    return 'vor $count Std.';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'vor $count Tagen',
      one: 'vor 1 Tag',
    );
    return '$_temp0';
  }

  @override
  String get notBackedUp =>
      'Nicht gesichert – tippen, um Google Drive zu verbinden';

  @override
  String get backingUp => 'Wird gesichert…';

  @override
  String backupFailed(String error) {
    return 'Sicherung fehlgeschlagen: $error';
  }

  @override
  String get waitingFirstBackup => 'Warten auf die erste Sicherung';

  @override
  String backedUpToDrive(String ago) {
    return 'In Google Drive gesichert $ago';
  }

  @override
  String get phoneWelcome =>
      'Deine Passwörter und Zwei-Faktor-Codes – derselbe Tresor wie auf deinem Computer, synchron gehalten über dein eigenes Google Drive.';

  @override
  String get connectDrive => 'Google Drive verbinden';

  @override
  String get startEmpty => 'Mit leerem Tresor starten';

  @override
  String codeSeconds(int seconds) {
    return 'Code ($seconds s)';
  }

  @override
  String get driveOnlyPhone =>
      'Nicht verbunden – der Tresor ist nur auf diesem Smartphone.';

  @override
  String connectedAs(String email) {
    return 'Verbunden als $email';
  }

  @override
  String connectedAsSynced(String email, String time) {
    return 'Verbunden als $email – letzte Synchronisierung $time';
  }

  @override
  String get syncNow => 'Jetzt synchronisieren';

  @override
  String get fingerprintLock => 'Fingerabdrucksperre';

  @override
  String get fingerprintSwitch => 'Keyhold mit Fingerabdruck öffnen';

  @override
  String get fingerprintSwitchHint =>
      'Sperrt sich, wenn der Bildschirm ausgeht oder nach einer Minute außerhalb der App. Vorschläge unter Anmeldefeldern funktionieren weiter.';

  @override
  String get fillingPasswords => 'Passwörter ausfüllen';

  @override
  String get fillerOn =>
      'Keyhold füllt Zugangsdaten in Apps und Browsern aus: unter einem Anmeldefeld auf „Keyhold“ tippen. In Chrome zusätzlich Einstellungen → Autofill-Dienste → Autofill mit einem anderen Dienst aktivieren.';

  @override
  String get fillerOff =>
      'Keyhold Zugangsdaten und Zwei-Faktor-Codes in Apps und Browsern ausfüllen lassen.';

  @override
  String get fillWithKeyhold => 'Passwörter mit Keyhold ausfüllen';

  @override
  String get passwordSetPhone =>
      'Festgelegt. Es öffnet diesen Tresor auf einem neuen Gerät.';

  @override
  String get passwordNotSetPhone =>
      'Nicht festgelegt. Ein neues Gerät kann den Tresor sonst nicht öffnen.';

  @override
  String get deleteThisLogin => 'Diese Zugangsdaten löschen?';

  @override
  String deleteNamed(String name) {
    return '$name löschen?';
  }

  @override
  String get noDuplicatesLeft => 'Keine Duplikate mehr.';

  @override
  String get groupWeb => 'Web';

  @override
  String get groupLocal => 'Lokales Netzwerk';

  @override
  String get groupServers => 'Server';

  @override
  String get filterAll => 'Alle';

  @override
  String get filter2fa => '2FA';

  @override
  String get filterPasswords => 'Passwörter';

  @override
  String get filterFiles => 'Dateien';

  @override
  String get groups => 'Gruppen';

  @override
  String get noGroup => 'Keine Gruppe';

  @override
  String moveCountToGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge in eine Gruppe verschieben',
      one: '1 Eintrag in eine Gruppe verschieben',
    );
    return '$_temp0';
  }

  @override
  String get newGroup => 'Neue Gruppe';

  @override
  String get newGroupHint => 'Leer lassen, um sie aus ihrer Gruppe zu nehmen';

  @override
  String get move => 'Verschieben';

  @override
  String get clearSelection => 'Auswahl aufheben';

  @override
  String selectedCount(int count) {
    return '$count ausgewählt';
  }

  @override
  String get moveToGroup => 'In Gruppe verschieben';

  @override
  String get addCodesFromQr => 'Zwei-Faktor-Codes aus QR-Code hinzufügen';

  @override
  String get browserExtension => 'Browsererweiterung';

  @override
  String get backup => 'Sicherung';

  @override
  String get importCsv => 'Aus CSV importieren';

  @override
  String get changeMasterPassword => 'Master-Passwort ändern';

  @override
  String get addFile => 'Datei hinzufügen';

  @override
  String get newEntry => 'Neu';

  @override
  String get checking => 'Wird geprüft…';

  @override
  String get notCheckedYet => 'Noch nicht geprüft';

  @override
  String filesNew(int count) {
    return '$count neu';
  }

  @override
  String filesChanged(int count) {
    return '$count geändert';
  }

  @override
  String filesSkipped(int count) {
    return '$count übersprungen';
  }

  @override
  String checkedNothingChanged(String when) {
    return 'Geprüft $when – nichts geändert';
  }

  @override
  String checkedWith(String when, String changes) {
    return 'Geprüft $when – $changes';
  }

  @override
  String get watchedHint =>
      'Überwacht – bei jeder Änderung in den Tresor kopiert, alle 15 Minuten';

  @override
  String get nothingWatched => 'Noch nichts überwacht';

  @override
  String pathNotFound(String path) {
    return '$path – nicht gefunden';
  }

  @override
  String get stopWatching => 'Nicht mehr überwachen';

  @override
  String get watchFolder => 'Ordner überwachen';

  @override
  String get watchFile => 'Datei überwachen';

  @override
  String get checkNow => 'Jetzt prüfen';

  @override
  String fileTooBig(String name, String size) {
    return '$name ist $size groß – maximal 25 MB';
  }

  @override
  String fileAdded(String name) {
    return '$name ist jetzt im Tresor';
  }

  @override
  String savedTo(String path) {
    return 'Gespeichert unter $path';
  }

  @override
  String removeNamed(String name) {
    return '$name entfernen?';
  }

  @override
  String get removeFileHint =>
      'Sie verschwindet aus dem Tresor. Ältere Sicherungen enthalten sie noch.';

  @override
  String get remove => 'Entfernen';

  @override
  String get noFilesYet =>
      'Noch keine Dateien – Wiederherstellungscodes, Schlüssel oder Scans hinzufügen';

  @override
  String get saveToDisk => 'Auf Festplatte speichern';

  @override
  String forWindow(String window) {
    return 'Für „$window“';
  }

  @override
  String get dismiss => 'Ausblenden';

  @override
  String get noBackupYet =>
      'Noch keine Sicherung – sie startet beim ersten Speichern';

  @override
  String lastBackup(String ago) {
    return 'Letzte Sicherung $ago';
  }

  @override
  String backedUpTo(String ago, String targets) {
    return 'Gesichert $ago – $targets';
  }

  @override
  String get driveNeedsPassword =>
      'Google Drive: Sicherung öffnen und Master-Passwort eingeben';

  @override
  String driveProblem(String problem) {
    return 'Google Drive: $problem';
  }

  @override
  String driveSynced(String ago) {
    return 'Google Drive: synchronisiert $ago';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge',
      one: '1 Eintrag',
    );
    return '$_temp0';
  }

  @override
  String get select => 'Auswählen';

  @override
  String get typeCode => 'Code ins vorherige Fenster tippen';

  @override
  String get typeLogin => 'Nutzername und Passwort tippen';

  @override
  String get copyPassword => 'Passwort kopieren';

  @override
  String get save => 'Speichern';

  @override
  String get off => 'Aus';

  @override
  String onWith(String detail) {
    return 'An – $detail';
  }

  @override
  String get join => 'Beitreten';

  @override
  String get synced => 'Synchronisiert';

  @override
  String get alreadyInSync => 'Bereits synchron';

  @override
  String get fillHostFirst => 'Zuerst den Host eingeben';

  @override
  String get fillUserFirst => 'Zuerst den Nutzer eingeben';

  @override
  String get pickKeyFirst => 'Zuerst die private Schlüsseldatei wählen';

  @override
  String noFileAt(String path) {
    return 'Unter $path gibt es keine Datei';
  }

  @override
  String serverUnreachable(String host, String port) {
    return '$host ist auf Port $port nicht erreichbar. Prüfe die Adresse, den Port und ob der Server läuft.';
  }

  @override
  String serverRefusedKey(String user) {
    return 'Der Server hat diesen Schlüssel für den Nutzer $user abgelehnt. Der passende öffentliche Schlüssel muss in seiner authorized_keys stehen.';
  }

  @override
  String get notAPrivateKey =>
      'Diese Datei ist kein nutzbarer privater Schlüssel.';

  @override
  String cannotWriteFolder(String folder) {
    return 'Angemeldet, aber in „$folder“ kann nicht geschrieben werden. Anderen Ordner wählen.';
  }

  @override
  String get driveHoldsVault =>
      'In Google Drive liegt bereits ein Keyhold-Tresor. Zum Beitreten wird sein Master-Passwort benötigt.';

  @override
  String get masterPasswordOfDriveVault =>
      'Master-Passwort des Tresors in Google Drive';

  @override
  String get driveHint =>
      'Speichert den verschlüsselten Tresor im Ordner „Keyhold“ in deinem eigenen Google Drive. So bleiben deine anderen Geräte synchron, und mit einem verlorenen Computer geht nichts verloren. Google kann ihn nicht lesen.';

  @override
  String get driveNotInBuild =>
      'Google Drive ist in dieser Version nicht eingerichtet.';

  @override
  String get setPasswordFirst =>
      'Zuerst ein Master-Passwort festlegen – ein neues Gerät braucht es, um den Tresor zu öffnen.';

  @override
  String get foldersOnComputer => 'Ordner auf diesem Computer';

  @override
  String folderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ordner',
      one: '1 Ordner',
    );
    return '$_temp0';
  }

  @override
  String folderCountCopied(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Ordner – letzte Kopie $time',
      one: '1 Ordner – letzte Kopie $time',
    );
    return '$_temp0';
  }

  @override
  String get yourServer => 'Dein Server';

  @override
  String get foldersHint =>
      'Bei jedem Speichern landet eine datierte Kopie in jedem Ordner, die letzten 30 bleiben erhalten.';

  @override
  String get noFolders => 'Keine Ordner – lokale Kopien sind aus';

  @override
  String get addFolder => 'Ordner hinzufügen';

  @override
  String get serverHint =>
      'Dieselbe Kopie geht per SFTP an einen Rechner, der dir gehört. Die Datei bleibt verschlüsselt, der Server sieht nur Bytes, sonst nichts. Host leer lassen, um das zu überspringen.';

  @override
  String get host => 'Host';

  @override
  String get port => 'Port';

  @override
  String get user => 'Nutzer';

  @override
  String get privateKeyFile => 'Private Schlüsseldatei';

  @override
  String get chooseFile => 'Datei wählen';

  @override
  String get serverFolder => 'Ordner auf dem Server';

  @override
  String get testConnection => 'Verbindung testen';

  @override
  String get notReachable => 'Gerade nicht erreichbar';

  @override
  String get enterCodeKey => 'Schlüssel des Zwei-Faktor-Codes eingeben';

  @override
  String get twoFactorCode => 'Zwei-Faktor-Code';

  @override
  String get newEntryTitle => 'Neuer Eintrag';

  @override
  String get editEntry => 'Eintrag bearbeiten';

  @override
  String get name => 'Name';

  @override
  String get key => 'Schlüssel';

  @override
  String get keyHint =>
      'Einrichtungsschlüssel oder ganzen otpauth://-Link einfügen';

  @override
  String get note => 'Notiz';

  @override
  String get addresses => 'Adressen';

  @override
  String get codeNotUsedYet =>
      'Noch nirgends verwendet. Er wird angeheftet, sobald du ihn zum ersten Mal auf einer Website nutzt, oder du heftest ihn in Zugangsdaten an.';

  @override
  String get noAddress => 'keine Adresse';

  @override
  String get unpin => 'Loslösen';

  @override
  String get addAddress => 'Adresse hinzufügen';

  @override
  String get title => 'Titel';

  @override
  String get noName => '(kein Name)';

  @override
  String get none => 'Keiner';

  @override
  String get choose => 'Wählen';

  @override
  String get group => 'Gruppe';

  @override
  String get groupHint => 'Eine wählen oder neuen Namen eingeben';

  @override
  String get driveTabConnected =>
      'Keyhold ist mit Google Drive verbunden. Du kannst diesen Tab schließen.';

  @override
  String get driveTabNotConnected =>
      'Google Drive wurde nicht verbunden. Du kannst diesen Tab schließen.';

  @override
  String get signInTooLong =>
      'Google-Anmeldung dauerte zu lange – noch einmal versuchen';

  @override
  String get signInCancelled => 'Google-Anmeldung wurde abgebrochen';

  @override
  String get noOfflineAccess => 'Google hat keinen Offlinezugriff erlaubt';

  @override
  String get noInternet => 'Keine Internetverbindung';

  @override
  String get wrongMasterPassword => 'Falsches Master-Passwort';

  @override
  String driveRefusedDownload(String status) {
    return 'Google Drive hat den Download abgelehnt ($status)';
  }

  @override
  String driveRefusedUpload(String status) {
    return 'Google Drive hat den Upload abgelehnt ($status)';
  }

  @override
  String driveAnswered(String status) {
    return 'Antwort von Google Drive: $status';
  }

  @override
  String get driveSignInAgain => 'Google Drive verlangt eine erneute Anmeldung';

  @override
  String get driveNotConnectedError => 'Google Drive ist nicht verbunden';

  @override
  String get driveAccessEnded =>
      'Zugriff auf Google Drive beendet – neu verbinden';

  @override
  String signInFailed(String status) {
    return 'Google-Anmeldung fehlgeschlagen ($status)';
  }

  @override
  String get dupNewest => 'neuester';

  @override
  String get dupSamePassword => 'gleiches Passwort wie der neueste';

  @override
  String get dupDifferentPassword => 'anderes Passwort';

  @override
  String get noUsername => '(kein Nutzername)';

  @override
  String duplicateNote(String username, String password, String day) {
    return '$username · $password · geändert am $day';
  }

  @override
  String get fileEmpty => 'Die Datei ist leer';

  @override
  String get noLoginColumns =>
      'Keine Spalte für Nutzername oder Passwort in dieser Datei gefunden';

  @override
  String get noQrOnScreen => 'Kein QR-Code auf dem Bildschirm gefunden';

  @override
  String get noQrInImage => 'Kein QR-Code in diesem Bild gefunden';

  @override
  String get qrNotTwoFactor => 'Dieser QR-Code ist kein Zwei-Faktor-Code';

  @override
  String get exportQrEmpty => 'Der Export-QR-Code ist leer';

  @override
  String get exportQrUnreadable =>
      'Dieser Export-QR-Code konnte nicht gelesen werden';

  @override
  String serverWritable(String account) {
    return 'Verbunden als $account, Ordner ist beschreibbar';
  }

  @override
  String get openKeyhold => 'Keyhold öffnen';

  @override
  String get quit => 'Beenden';

  @override
  String codesFound(int count) {
    return '$count gefunden';
  }

  @override
  String codesUnsupported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count nutzen einen Codetyp, den Keyhold noch nicht erzeugen kann',
      one: '1 nutzt einen Codetyp, den Keyhold noch nicht erzeugen kann',
    );
    return '$_temp0';
  }

  @override
  String savedAs(String name) {
    return 'Gespeichert als $name';
  }

  @override
  String savedCodes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Codes gespeichert',
      one: '1 Code gespeichert',
    );
    return '$_temp0';
  }

  @override
  String get images => 'Bilder';

  @override
  String get addCodes => 'Zwei-Faktor-Codes hinzufügen';

  @override
  String get saveAll => 'Alle speichern';

  @override
  String get qrHintPhone =>
      'Kamera auf den QR-Code richten, den eine Website beim Einschalten der Zwei-Faktor-Anmeldung zeigt, oder auf den Export aus Google Authenticator (Konten übertragen → Konten exportieren).';

  @override
  String get qrHintComputer =>
      'QR-Code auf dem Bildschirm anzeigen und scannen. Das kann der Code sein, den eine Website beim Einschalten der Zwei-Faktor-Anmeldung zeigt, oder der Export aus Google Authenticator (Konten übertragen → Konten exportieren). Ein Foto des Codes geht auch.';

  @override
  String get qrMicrosoftHint =>
      'Microsoft Authenticator kann seine Codes nicht exportieren – Zwei-Faktor-Anmeldung auf jeder Website aus- und wieder einschalten und den neuen Code hier scannen.';

  @override
  String get scanCamera => 'Mit der Kamera scannen';

  @override
  String get scanScreen => 'Bildschirm scannen';

  @override
  String get openImage => 'Bild öffnen';

  @override
  String get saved => 'Gespeichert';

  @override
  String get alreadyInKeyhold => 'Bereits in Keyhold';

  @override
  String asName(String name) {
    return 'als „$name“';
  }

  @override
  String get typePasswordFirst => 'Zuerst dein Passwort eingeben';

  @override
  String get atLeast8 => 'Mindestens 8 Zeichen verwenden';

  @override
  String get passwordsDiffer => 'Die Passwörter stimmen nicht überein';

  @override
  String get passwordDoesNotOpen =>
      'Mit diesem Passwort lässt sich der Tresor nicht öffnen';

  @override
  String get currentPasswordWrong => 'Das aktuelle Master-Passwort ist falsch';

  @override
  String get unlockVault => 'Tresor entsperren';

  @override
  String get unlockHint =>
      'Dieser Tresor stammt von einem anderen Computer. Zum Öffnen hier das Master-Passwort eingeben.';

  @override
  String get masterPasswordHint =>
      'Windows öffnet diesen Tresor automatisch für dich. Mit dem Master-Passwort kommst du nach einer Neuinstallation, auf einem neuen Computer oder auf deinem Smartphone wieder hinein.';

  @override
  String get currentMasterPassword => 'Aktuelles Master-Passwort';

  @override
  String get newMasterPassword => 'Neues Master-Passwort';

  @override
  String get repeatIt => 'Wiederholen';

  @override
  String get openVault => 'Tresor öffnen';

  @override
  String get savePassword => 'Passwort speichern';

  @override
  String get nobodyCanRecover =>
      'Niemand kann es für dich wiederherstellen – nicht einmal diese App. Notiere es an einem sicheren Ort.';

  @override
  String get groupApps => 'Apps';

  @override
  String get openKeyholdFirst =>
      'Keyhold einmal öffnen und das Master-Passwort eingeben, dann erneut versuchen.';

  @override
  String pinTo(String name, String place) {
    return '„$name“ an $place anheften?';
  }

  @override
  String get pinHint => 'Dann wird er hier sofort angeboten, ohne Suche.';

  @override
  String get doNotAskCode => 'Nicht mehr nach diesem Code fragen';

  @override
  String get notNow => 'Nicht jetzt';

  @override
  String get pin => 'Anheften';

  @override
  String get savedToKeyhold => 'In Keyhold gespeichert';

  @override
  String get passwordUpdated => 'Passwort in Keyhold aktualisiert';

  @override
  String get searchAllLogins => 'Alle Zugangsdaten durchsuchen';

  @override
  String get nothingFound => 'Nichts gefunden.';

  @override
  String get noLoginForSite =>
      'Noch keine Zugangsdaten für diese Website. Oben suchen oder anmelden – Android bietet dann an, sie zu speichern.';

  @override
  String get noLoginForApp =>
      'Noch keine Zugangsdaten für diese App. Oben suchen oder anmelden – Android bietet dann an, sie zu speichern.';

  @override
  String listening(String address) {
    return 'Empfangsbereit auf $address';
  }

  @override
  String get notListening =>
      'Nicht empfangsbereit – vielleicht läuft schon ein anderes Keyhold';

  @override
  String get pairingToken => 'Kopplungstoken';

  @override
  String get pairingTokenHint =>
      'Einmal in die Erweiterung einfügen. Nur Anfragen mit diesem Token werden beantwortet, und nur von der Erweiterung selbst – eine Webseite kommt nicht an den Tresor.';

  @override
  String get tokenCopied => 'Token kopiert';

  @override
  String get copyToken => 'Token kopieren';

  @override
  String get installIt => 'Installation';

  @override
  String get installChrome =>
      'Chrome oder Edge: chrome://extensions öffnen, Entwicklermodus aktivieren, auf „Entpackte Erweiterung laden“ klicken und den Ordner unten wählen.';

  @override
  String get installFirefox =>
      'Firefox: about:debugging#/runtime/this-firefox öffnen, auf „Temporäres Add-on laden…“ klicken und manifest.json in diesem Ordner wählen.';

  @override
  String get installPaste =>
      'Auf das Keyhold-Symbol in der Symbolleiste klicken und das Token einfügen.';

  @override
  String get newCodeShort => 'Neuer Code';

  @override
  String get free => 'Frei';

  @override
  String get searchCodes => 'Codes suchen';

  @override
  String get everyCodePinned =>
      'Jeder Code ist irgendwo angeheftet. Zu „Alle“ wechseln, um sie zu sehen.';

  @override
  String get noCodesFound => 'Keine Codes gefunden.';

  @override
  String pinnedTo(String hosts) {
    return 'angeheftet an $hosts';
  }

  @override
  String get notPinned => 'nicht angeheftet';

  @override
  String changedOn(String day) {
    return 'geändert am $day';
  }

  @override
  String get importPasswords => 'Passwörter importieren';

  @override
  String get importHint =>
      'Passwörter aus dem Browser als CSV exportieren und die Datei hier laden. Exporte aus Chrome, Edge, Firefox, Bitwarden und KeePassXC funktionieren.';

  @override
  String get chooseCsv => 'CSV-Datei wählen';

  @override
  String entriesReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge bereit',
      one: '1 Eintrag bereit',
    );
    return '$_temp0';
  }

  @override
  String entriesReadySkipped(int count, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge bereit',
      one: '1 Eintrag bereit',
    );
    String _temp1 = intl.Intl.pluralLogic(
      skipped,
      locale: localeName,
      other: '$skipped leere Zeilen übersprungen',
      one: '1 leere Zeile übersprungen',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String andMore(int count) {
    return 'und $count weitere';
  }

  @override
  String get deleteCsv => 'CSV-Datei nach dem Import löschen';

  @override
  String get deleteCsvHint => 'Sie enthält alle Passwörter im Klartext';

  @override
  String importEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge importieren',
      one: '1 Eintrag importieren',
    );
    return '$_temp0';
  }

  @override
  String get cameraHint =>
      'Auf den Zwei-Faktor-QR-Code einer Website oder den Export aus Google Authenticator richten.';
}
