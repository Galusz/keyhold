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
  String get connectDrive => 'Google Drive verbinden';

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
  String get stopWatching => 'Nicht mehr überwachen';

  @override
  String get watchFolder => 'Ordner überwachen';

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
  String get unlockVault => 'Tresor entsperren';

  @override
  String get unlockHint =>
      'Keyhold kann diesen Tresor auf diesem Gerät nicht von selbst öffnen, etwa nach einer Neuinstallation des Systems oder wenn er von einem anderen Computer kopiert wurde. Gib sein Master-Passwort ein.';

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
      'Wenn du es vergisst, öffnet nur der Wiederherstellungsschlüssel deinen Tresor: Notfallblatt drucken.';

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
  String get deleteCsvHint => 'Sie enthält alle Passwörter im Klartext';

  @override
  String get cameraHint =>
      'Auf den Zwei-Faktor-QR-Code einer Website oder den Export aus Google Authenticator richten.';

  @override
  String get deleteThisCode => 'Diesen Zwei-Faktor-Code löschen?';

  @override
  String get deleteCodeWarning =>
      'Er verschwindet von allen deinen Geräten. Ohne ihn kannst du dich dort, wo er genutzt wird, nicht mehr anmelden.';

  @override
  String get deleteLoginWarning => 'Sie verschwinden von allen deinen Geräten.';

  @override
  String get recoverySheet => 'Notfallblatt';

  @override
  String get recoveryIntro =>
      'Dieser Schlüssel öffnet deinen Tresor, falls du das Master-Passwort einmal vergisst. Das Blatt drucken, die letzte Zeile von Hand daraufschreiben und zu Hause aufbewahren.';

  @override
  String get print => 'Drucken';

  @override
  String get done => 'Fertig';

  @override
  String get sheetTitle => 'Keyhold-Notfallblatt';

  @override
  String sheetMade(String date) {
    return 'Erstellt am $date';
  }

  @override
  String get sheetWhere => 'Wo dein Tresor liegt';

  @override
  String sheetDrive(String email) {
    return 'Google Drive von $email, Ordner „Keyhold“';
  }

  @override
  String sheetFolders(String folders) {
    return 'Kopien in Ordnern: $folders';
  }

  @override
  String sheetServer(String host) {
    return 'Kopien auf dem Server $host';
  }

  @override
  String get sheetOnlyHere =>
      'Nur auf diesem Gerät. In Keyhold eine Sicherung einschalten.';

  @override
  String get sheetSteps => 'Auf einem neuen Computer oder Smartphone';

  @override
  String get sheetStep1 => 'Keyhold installieren: galusz.github.io/keyhold';

  @override
  String get sheetStep2 =>
      'Wähle „Meinen Tresor öffnen“, dann „Aus Google Drive“ (oder „Aus einer Datei (.khd)“, wenn du eine Kopie hast).';

  @override
  String get sheetStep3 =>
      'Gib statt des Master-Passworts diesen Wiederherstellungsschlüssel ein. Wähle danach ein neues Master-Passwort.';

  @override
  String get sheetKeepSafe =>
      'Mit diesem ausgefüllten Blatt kann jeder deinen Tresor öffnen. Wie einen Ersatzschlüssel fürs Haus aufbewahren.';

  @override
  String get sheetDriveNoEmail => 'Google Drive, Ordner „Keyhold“';

  @override
  String get noBackupPlaces =>
      'Kein Sicherungsordner, Server oder Google Drive: Der Tresor ist nur auf diesem Computer. Zum Einrichten klicken.';

  @override
  String get deleteVault => 'Tresor löschen';

  @override
  String get deleteVaultFolders =>
      'Auch die Kopien in den Sicherungsordnern löschen';

  @override
  String get deleteVaultSure => 'Tresor endgültig löschen?';

  @override
  String get deleteVaultSureHint => 'Das lässt sich nicht rückgängig machen.';

  @override
  String get recoveryGate =>
      'Master-Passwort eingeben, um den Wiederherstellungsschlüssel zu sehen.';

  @override
  String get showKey => 'Schlüssel anzeigen';

  @override
  String get recoveryCopyRow =>
      'Diese Zeile von Hand auf das gedruckte Blatt übertragen';

  @override
  String get checkRow =>
      'Dann die letzte Zeile so eingeben, wie sie auf dem Blatt steht';

  @override
  String get check => 'Prüfen';

  @override
  String get rowMatches =>
      'Stimmt überein. Das Blatt an einem sicheren Ort aufbewahren.';

  @override
  String get rowDiffers =>
      'Stimmt nicht überein. Die letzte Zeile mit dem Bildschirm vergleichen und auf dem Blatt korrigieren.';

  @override
  String get sheetKeyLabel => 'Wiederherstellungsschlüssel';

  @override
  String get sheetCopyRow =>
      'Die letzte Zeile hier von Hand vom Keyhold-Bildschirm abschreiben.';

  @override
  String get orRecoveryCode =>
      'Vergessen? Stattdessen den Wiederherstellungsschlüssel vom Notfallblatt eingeben.';

  @override
  String get newPasswordAfterKey =>
      'Der Wiederherstellungsschlüssel hat deinen Tresor geöffnet. Neues Master-Passwort wählen: Es ersetzt das vergessene auf allen deinen Geräten.';

  @override
  String get otherVaultTitle => 'Kopien eines anderen Tresors';

  @override
  String otherVaultHint(String when) {
    return 'In diesem Ordner liegen schon Kopien eines anderen Keyhold-Tresors (die neueste vom $when). Zum Ansehen öffnen? Dein Tresor bleibt, wie er ist.';
  }

  @override
  String get copyPasswordTitle => 'Master-Passwort dieser Kopie';

  @override
  String get copyNotOpened =>
      'Die Kopie ließ sich nicht öffnen: falsches Passwort oder falscher Wiederherstellungsschlüssel, oder kein Keyhold-Tresor.';

  @override
  String copyTitle(String name) {
    return 'Kopie: $name';
  }

  @override
  String get copyReadOnly =>
      'Nur zum Ansehen: Hier ändert sich nichts an deinem Tresor. Einzelne Einträge kannst du in deinen Tresor übernehmen.';

  @override
  String get myVault => 'Mein Tresor';

  @override
  String get vaultTab => 'Tresor';

  @override
  String get syncTab => 'Sync';

  @override
  String get copiesTab => 'Sicherungen';

  @override
  String get startHint =>
      'Deine Passwörter und Zwei-Faktor-Codes in einem Tresor: auf dem Computer, auf dem Smartphone und im Browser.';

  @override
  String get createVault => 'Neuen Tresor anlegen';

  @override
  String get openMyVault => 'Meinen Tresor öffnen';

  @override
  String get newVault => 'Neuer Tresor';

  @override
  String get vaultName => 'Name des Tresors';

  @override
  String get newVaultHint =>
      'Das Master-Passwort öffnet diesen Tresor auf jedem deiner Geräte: Computer, Smartphone und Browser. Keyhold kann es nicht wiederherstellen; das kann der Wiederherstellungsschlüssel, den du gleich bekommst.';

  @override
  String get sealHint =>
      'Dein Tresor hat noch kein Master-Passwort. Leg es jetzt fest: Es öffnet diesen Tresor auf deinen anderen Geräten und im Browser.';

  @override
  String get createVaultButton => 'Tresor anlegen';

  @override
  String get forgotPassword => 'Passwort vergessen?';

  @override
  String get usePassword => 'Master-Passwort verwenden';

  @override
  String get recoveryKey => 'Wiederherstellungsschlüssel';

  @override
  String get recoveryKeyFieldHint =>
      'Die 36 Zeichen von deinem Notfallblatt; Leerzeichen spielen keine Rolle.';

  @override
  String get openVaultTitle => 'Tresor öffnen';

  @override
  String get openVaultHint =>
      'Der Tresor öffnet sich so, wie er ist. Er wird nie mit einem anderen Tresor zusammengelegt.';

  @override
  String get fromDrive => 'Aus Google Drive';

  @override
  String get fromDriveHint =>
      'Bei Google anmelden, dann das Master-Passwort des Tresors eingeben.';

  @override
  String fromDriveAs(String email) {
    return '$email: das Master-Passwort des Tresors eingeben.';
  }

  @override
  String get fromFile => 'Aus einer Datei (.khd)';

  @override
  String get fromFileHint =>
      'Eine Kopie aus einem Sicherungsordner, von einem USB-Stick oder einem alten Computer.';

  @override
  String get closedHere => 'Früher auf diesem Gerät geöffnet';

  @override
  String closedOn(String date) {
    return 'geschlossen am $date';
  }

  @override
  String get closedVaultGone =>
      'Die Datei dieses Tresors ist nicht mehr auf diesem Gerät.';

  @override
  String get typeVaultPassword =>
      'Gib das Master-Passwort des Tresors ein, den du öffnen willst. Keyhold probiert es an jedem Tresor in deinem Google Drive.';

  @override
  String lookingForVault(int at, int of) {
    return 'Dein Tresor wird gesucht: $at von $of';
  }

  @override
  String get noVaultInDrive =>
      'In diesem Google Drive gibt es noch keinen Keyhold-Tresor.';

  @override
  String get noVaultMatches =>
      'Kein Tresor in deinem Google Drive lässt sich mit diesem Passwort öffnen.';

  @override
  String get sameVaultFile =>
      'Diese Datei ist eine Kopie des Tresors, der gerade offen ist. Einträge daraus holst du über Sicherungen und dann Kopie ansehen.';

  @override
  String fileVaultPassword(String name) {
    return 'Gib das Master-Passwort für $name ein.';
  }

  @override
  String get driveFileUnreadable =>
      'Die Datei dieses Tresors in Google Drive lässt sich nicht lesen. Keyhold lässt sie unverändert.';

  @override
  String get vaultInfoHint =>
      'Dieser Tresor öffnet sich auf jedem Gerät mit seinem Master-Passwort. Wenn du das Passwort vergisst, öffnet der Wiederherstellungsschlüssel den Tresor und du wählst ein neues.';

  @override
  String get recoveryKeyHint =>
      'Nach dem Master-Passwort angezeigt und gedruckt';

  @override
  String get otherVaults => 'Andere Tresore';

  @override
  String get openOtherVault => 'Anderen Tresor öffnen';

  @override
  String get openOtherVaultHint =>
      'Aus Google Drive, aus einer Datei oder von diesem Gerät';

  @override
  String get createNewVaultHint => 'Leer, mit eigenem Master-Passwort';

  @override
  String closeVaultTitle(String name) {
    return '„$name“ auf diesem Gerät schließen?';
  }

  @override
  String get closeVaultHint =>
      'Nichts wird gelöscht: Er bleibt in Google Drive, in den Sicherungskopien und in der Tresorliste dieses Geräts. Er öffnet sich wieder mit seinem Master-Passwort.';

  @override
  String get continueLabel => 'Weiter';

  @override
  String get renameVault => 'Tresor umbenennen';

  @override
  String get reviewCopy => 'Kopie ansehen';

  @override
  String get driveVaultHint =>
      'Legt diesen Tresor als eigene verschlüsselte Datei im Ordner „Keyhold“ in deinem Google Drive ab. Deine anderen Geräte öffnen ihn mit seinem Master-Passwort. Mehrere Tresore können dasselbe Google Drive nutzen und vermischen sich nie. Google kann sie nicht lesen.';

  @override
  String get foldersSlotsHint =>
      'Jedes Speichern aktualisiert in jedem Ordner bis zu 7 Kopien des Tresors: die neueste und welche von vor etwa einer Stunde, einem Tag, einer Woche, einem Monat, drei Monaten und einem Jahr.';

  @override
  String get deleteVaultHereHint =>
      'Der Tresor wird von diesem Gerät gelöscht: Passwörter, Zwei-Faktor-Codes und Dateien. Früher hier geöffnete Tresore bleiben. Danach zeigt Keyhold den Startbildschirm.';

  @override
  String get deleteVaultDriveMine =>
      'Auch aus Google Drive löschen (andere Tresore dort bleiben)';

  @override
  String get vaultDeletedHere => 'Der Tresor ist gelöscht.';

  @override
  String get menu => 'Menü';

  @override
  String get importTitle => 'Importieren';

  @override
  String get importMenuHint =>
      'Passwörter und Codes aus anderen Apps oder einem anderen Tresor';

  @override
  String get importAnyHint =>
      'Wähle einen Export aus einem anderen Passwort-Manager oder einer Authenticator-App, eine KeePass-Datenbank oder einen anderen Keyhold-Tresor. Keyhold erkennt die Datei selbst, und du hakst ab, was übernommen wird.';

  @override
  String get importReading => 'Datei wird gelesen…';

  @override
  String importPasswordTitle(String format) {
    return 'Passwort dieser $format-Datei';
  }

  @override
  String get importWrongPassword => 'Dieses Passwort öffnet die Datei nicht.';

  @override
  String get importUnknown =>
      'Keyhold erkennt diese Datei nicht. Exportiere noch einmal aus der anderen App, als CSV oder JSON.';

  @override
  String importNothing(String format) {
    return '$format: In dieser Datei ist nichts, was Keyhold übernehmen kann.';
  }

  @override
  String get keePassUnsupported =>
      'Diese KeePass-Datenbank nutzt etwas, das Keyhold nicht öffnen kann (eine Schlüsseldatei oder Twofish). Exportiere sie in KeePass als CSV.';

  @override
  String get bitwardenAccountLocked =>
      'Dieser Bitwarden-Export öffnet sich nur mit deinem Bitwarden-Konto. Exportiere noch einmal als JSON, passwortgeschützt oder unverschlüsselt.';

  @override
  String get otpLinks => 'otpauth-Links';

  @override
  String get importPickHint =>
      'Hake ab, was in deinen Tresor soll. Was du schon hast, ist nicht abgehakt.';

  @override
  String codesLeftOut(int count) {
    return 'Ausgelassene Codes: $count. Keyhold erzeugt nur 6-stellige Codes alle 30 Sekunden, keine 8 Stellen, 60 Sekunden, Zähler oder Steam.';
  }

  @override
  String recordsLeftOut(int count) {
    return 'Ausgelassene Datensätze: $count (leere, Karten und Identitäten).';
  }

  @override
  String get selectAll => 'Alle auswählen';

  @override
  String get alreadyInVault => 'schon im Tresor';

  @override
  String addSelected(int count) {
    return 'Hinzufügen ($count)';
  }

  @override
  String addedCount(int count) {
    return 'Zum Tresor hinzugefügt: $count';
  }

  @override
  String get deletePlainFile => 'Datei danach löschen';

  @override
  String get importPasswordsFrom => 'Passwörter';

  @override
  String get importPasswordsList =>
      'Chrome, Edge, Firefox und Safari (CSV), Bitwarden (CSV oder JSON), 1Password (.1pux oder CSV), KeePass und KeePassXC (.kdbx oder CSV), LastPass, Proton Pass, NordPass und Dashlane (CSV) sowie ein anderer Keyhold-Tresor (.khd).';

  @override
  String get importCodesFrom => 'Zwei-Faktor-Codes';

  @override
  String get importCodesList =>
      'Aegis (.json), 2FAS (.2fas), Ente Auth, FreeOTP+ und andOTP sowie jede Datei mit otpauth://-Links. Google Authenticator: dort den Export-QR-Code anzeigen und in Keyhold die QR-Code-Schaltfläche nutzen.';

  @override
  String get importNoExport =>
      'Microsoft Authenticator und Authy geben keine Codes heraus: Zwei-Faktor bei jedem Dienst neu einschalten und den neuen QR-Code scannen.';

  @override
  String get foldersOnPhone => 'Ordner auf diesem Smartphone';

  @override
  String get phoneFoldersHint =>
      'Wähle einen Ordner im Smartphone, auf der Speicherkarte oder einer App wie Nextcloud oder OneDrive, in die Android speichern darf.';

  @override
  String get copiesPlaces => 'Ordner und dein Server';

  @override
  String get shareVaultCopy => 'Kopie des Tresors teilen';

  @override
  String get shareVaultHint =>
      'Du kannst die Tresordatei auch mailen oder in Dateien ablegen: Sie öffnet sich nur mit dem Master-Passwort oder dem Wiederherstellungsschlüssel.';

  @override
  String confirmFill(String name) {
    return 'Bestätigen, um $name auszufüllen';
  }

  @override
  String get guardedSwitch => 'Beim Ausfüllen nach Fingerabdruck fragen';

  @override
  String get guardedSwitchHint =>
      'Fingerabdruck auf dem Handy, Windows Hello am Computer – bevor Passwort oder Code in eine Seite oder App gelangt.';

  @override
  String get helloSwitch => 'Keyhold mit Windows Hello öffnen';

  @override
  String get helloSwitchHint =>
      'Gesicht, Fingerabdruck oder Windows-PIN. Sperrt nach 5 Minuten ohne Nutzung. Das Ausfüllen im Browser funktioniert weiter.';

  @override
  String get helloConfirmHint => 'Mit Windows Hello bestätigen';

  @override
  String get lockedInstead =>
      'Weder Passwort noch Wiederherstellungsschlüssel? Öffne einen anderen Tresor oder lege einen neuen an. Dieser wird beiseitegelegt, nicht gelöscht.';

  @override
  String setAsideOn(String date) {
    return 'beiseitegelegt am $date, öffnet mit seinem Master-Passwort';
  }

  @override
  String get doneAfterCheck =>
      '„Fertig“ wird aktiv, sobald die letzte Zeile stimmt.';

  @override
  String get lastCopyFailed => 'Die letzte Kopie ist fehlgeschlagen';
}
