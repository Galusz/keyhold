// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get cancel => 'Anuluj';

  @override
  String get open => 'Otwórz';

  @override
  String get delete => 'Usuń';

  @override
  String get copy => 'Kopiuj';

  @override
  String get edit => 'Edytuj';

  @override
  String get add => 'Dodaj';

  @override
  String get search => 'Szukaj';

  @override
  String get settings => 'Ustawienia';

  @override
  String get change => 'Zmień';

  @override
  String get connect => 'Połącz';

  @override
  String get disconnect => 'Rozłącz';

  @override
  String get unlock => 'Odblokuj';

  @override
  String get noTitle => '(bez tytułu)';

  @override
  String get code => 'Kod';

  @override
  String get codes => 'Kody';

  @override
  String get username => 'Nazwa użytkownika';

  @override
  String get password => 'Hasło';

  @override
  String get address => 'Adres';

  @override
  String get notes => 'Notatki';

  @override
  String get duplicates => 'Duplikaty';

  @override
  String get masterPassword => 'Hasło główne';

  @override
  String get setMasterPassword => 'Ustaw hasło główne';

  @override
  String copied(String what) {
    return 'Skopiowano: $what';
  }

  @override
  String get fingerprintTitle => 'Magazyn kluczy Keyhold';

  @override
  String get fingerprintUnlockHint => 'Odblokuj, aby zobaczyć hasła i kody';

  @override
  String get fingerprintConfirmHint => 'Potwierdź odciskiem palca';

  @override
  String driveNotConnected(String error) {
    return 'Nie połączono z Google Drive: $error';
  }

  @override
  String get masterPasswordOfVault => 'Hasło główne sejfu';

  @override
  String get masterPasswordFromComputer =>
      'To, które ustawiono w Keyhold na komputerze';

  @override
  String get scanQr => 'Zeskanuj kod QR';

  @override
  String get scanQrHint =>
      'Kod weryfikacyjny strony albo eksport z Google Authenticator';

  @override
  String get newCode => 'Nowy kod weryfikacyjny';

  @override
  String get newCodeHint => 'Wpisz klucz konfiguracyjny ręcznie';

  @override
  String get newLogin => 'Nowe dane logowania';

  @override
  String get locked => 'Keyhold jest zablokowany';

  @override
  String get everything => 'Wszystko';

  @override
  String get noCodesYet =>
      'Brak kodów weryfikacyjnych — dotknij +, aby zeskanować';

  @override
  String get nothingYet => 'Nic tu jeszcze nie ma';

  @override
  String get justNow => 'przed chwilą';

  @override
  String minutesAgo(int count) {
    return '$count min temu';
  }

  @override
  String hoursAgo(int count) {
    return '$count godz. temu';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dnia temu',
      many: '$count dni temu',
      few: '$count dni temu',
      one: '1 dzień temu',
    );
    return '$_temp0';
  }

  @override
  String get notBackedUp =>
      'Brak kopii zapasowej — dotknij, aby połączyć Google Drive';

  @override
  String get backingUp => 'Tworzenie kopii zapasowej…';

  @override
  String backupFailed(String error) {
    return 'Błąd kopii zapasowej: $error';
  }

  @override
  String get waitingFirstBackup => 'Oczekiwanie na pierwszą kopię zapasową';

  @override
  String backedUpToDrive(String ago) {
    return 'Zapisano kopię w Google Drive $ago';
  }

  @override
  String get phoneWelcome =>
      'Twoje hasła i kody weryfikacyjne — ten sam sejf co na komputerze, synchronizowany przez Twój Google Drive.';

  @override
  String get connectDrive => 'Połącz z Google Drive';

  @override
  String get startEmpty => 'Zacznij od pustego sejfu';

  @override
  String codeSeconds(int seconds) {
    return 'Kod ($seconds s)';
  }

  @override
  String get driveOnlyPhone =>
      'Nie połączono — sejf jest tylko na tym telefonie.';

  @override
  String connectedAs(String email) {
    return 'Połączono jako $email';
  }

  @override
  String connectedAsSynced(String email, String time) {
    return 'Połączono jako $email — ostatnia synchronizacja $time';
  }

  @override
  String get syncNow => 'Synchronizuj teraz';

  @override
  String get fingerprintLock => 'Blokada odciskiem palca';

  @override
  String get fingerprintSwitch => 'Otwieraj Keyhold odciskiem palca';

  @override
  String get fingerprintSwitchHint =>
      'Blokuje się, gdy ekran zgaśnie lub po minucie poza aplikacją. Podpowiedzi pod polami logowania nadal działają.';

  @override
  String get fillingPasswords => 'Uzupełnianie haseł';

  @override
  String get fillerOn =>
      'Keyhold uzupełnia dane logowania w aplikacjach i przeglądarkach: dotknij „Keyhold” pod polem logowania. W Chrome włącz też Ustawienia → Usługi autouzupełniania → Autouzupełnianie przy użyciu innej usługi.';

  @override
  String get fillerOff =>
      'Pozwól Keyhold uzupełniać dane logowania i kody weryfikacyjne w aplikacjach i przeglądarkach.';

  @override
  String get fillWithKeyhold => 'Uzupełniaj hasła przez Keyhold';

  @override
  String get passwordSetPhone =>
      'Ustawione. Otwiera ten sejf na nowym urządzeniu.';

  @override
  String get passwordNotSetPhone =>
      'Nieustawione. Bez niego nowe urządzenie nie otworzy sejfu.';

  @override
  String get deleteThisLogin => 'Usunąć te dane logowania?';

  @override
  String deleteNamed(String name) {
    return 'Usunąć „$name”?';
  }

  @override
  String get noDuplicatesLeft => 'Nie ma już duplikatów.';

  @override
  String get groupWeb => 'Strony';

  @override
  String get groupLocal => 'Sieć lokalna';

  @override
  String get groupServers => 'Serwery';

  @override
  String get filterAll => 'Wszystkie';

  @override
  String get filter2fa => '2FA';

  @override
  String get filterPasswords => 'Hasła';

  @override
  String get filterFiles => 'Pliki';

  @override
  String get groups => 'Grupy';

  @override
  String get noGroup => 'Bez grupy';

  @override
  String moveCountToGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Przenieś $count elementu do grupy',
      many: 'Przenieś $count elementów do grupy',
      few: 'Przenieś $count elementy do grupy',
      one: 'Przenieś 1 element do grupy',
    );
    return '$_temp0';
  }

  @override
  String get newGroup => 'Nowa grupa';

  @override
  String get newGroupHint => 'Zostaw puste, aby wyjąć je z grupy';

  @override
  String get move => 'Przenieś';

  @override
  String get clearSelection => 'Wyczyść zaznaczenie';

  @override
  String selectedCount(int count) {
    return 'Zaznaczono: $count';
  }

  @override
  String get moveToGroup => 'Przenieś do grupy';

  @override
  String get addCodesFromQr => 'Dodaj kody weryfikacyjne z kodu QR';

  @override
  String get browserExtension => 'Rozszerzenie przeglądarki';

  @override
  String get backup => 'Kopia zapasowa';

  @override
  String get importCsv => 'Importuj z CSV';

  @override
  String get changeMasterPassword => 'Zmień hasło główne';

  @override
  String get addFile => 'Dodaj plik';

  @override
  String get newEntry => 'Nowy';

  @override
  String get checking => 'Sprawdzanie…';

  @override
  String get notCheckedYet => 'Jeszcze nie sprawdzono';

  @override
  String filesNew(int count) {
    return 'nowe: $count';
  }

  @override
  String filesChanged(int count) {
    return 'zmienione: $count';
  }

  @override
  String filesSkipped(int count) {
    return 'pominięte: $count';
  }

  @override
  String checkedNothingChanged(String when) {
    return 'Sprawdzono $when — bez zmian';
  }

  @override
  String checkedWith(String when, String changes) {
    return 'Sprawdzono $when — $changes';
  }

  @override
  String get watchedHint =>
      'Obserwowane — kopiowane do sejfu po każdej zmianie, co 15 minut';

  @override
  String get nothingWatched => 'Nic nie jest jeszcze obserwowane';

  @override
  String pathNotFound(String path) {
    return '$path — nie znaleziono';
  }

  @override
  String get stopWatching => 'Przestań obserwować';

  @override
  String get watchFolder => 'Obserwuj folder';

  @override
  String get watchFile => 'Obserwuj plik';

  @override
  String get checkNow => 'Sprawdź teraz';

  @override
  String fileTooBig(String name, String size) {
    return '$name ma $size — limit to 25 MB';
  }

  @override
  String fileAdded(String name) {
    return '$name jest teraz w sejfie';
  }

  @override
  String savedTo(String path) {
    return 'Zapisano w $path';
  }

  @override
  String removeNamed(String name) {
    return 'Usunąć „$name”?';
  }

  @override
  String get removeFileHint =>
      'Zniknie z sejfu. Starsze kopie zapasowe nadal go zawierają.';

  @override
  String get remove => 'Usuń';

  @override
  String get noFilesYet =>
      'Brak plików — dodaj kody odzyskiwania, klucze lub skany';

  @override
  String get saveToDisk => 'Zapisz na dysku';

  @override
  String forWindow(String window) {
    return 'Dla „$window”';
  }

  @override
  String get dismiss => 'Zamknij';

  @override
  String get noBackupYet =>
      'Brak kopii zapasowej — powstanie przy pierwszym zapisie';

  @override
  String lastBackup(String ago) {
    return 'Ostatnia kopia zapasowa $ago';
  }

  @override
  String backedUpTo(String ago, String targets) {
    return 'Zapisano kopię $ago — $targets';
  }

  @override
  String get driveNeedsPassword =>
      'Google Drive: otwórz „Kopia zapasowa” i wpisz hasło główne';

  @override
  String driveProblem(String problem) {
    return 'Google Drive: $problem';
  }

  @override
  String driveSynced(String ago) {
    return 'Google Drive: zsynchronizowano $ago';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementu',
      many: '$count elementów',
      few: '$count elementy',
      one: '1 element',
    );
    return '$_temp0';
  }

  @override
  String get select => 'Zaznacz';

  @override
  String get typeCode => 'Wpisz kod w poprzednim oknie';

  @override
  String get typeLogin => 'Wpisz nazwę użytkownika i hasło';

  @override
  String get copyPassword => 'Kopiuj hasło';

  @override
  String get save => 'Zapisz';

  @override
  String get off => 'Wyłączone';

  @override
  String onWith(String detail) {
    return 'Włączone — $detail';
  }

  @override
  String get join => 'Dołącz';

  @override
  String get synced => 'Zsynchronizowano';

  @override
  String get alreadyInSync => 'Już zsynchronizowane';

  @override
  String get fillHostFirst => 'Najpierw wpisz hosta';

  @override
  String get fillUserFirst => 'Najpierw wpisz użytkownika';

  @override
  String get pickKeyFirst => 'Najpierw wybierz plik klucza prywatnego';

  @override
  String noFileAt(String path) {
    return 'Nie ma pliku w $path';
  }

  @override
  String serverUnreachable(String host, String port) {
    return 'Nie można połączyć się z $host na porcie $port. Sprawdź adres, port i czy serwer działa.';
  }

  @override
  String serverRefusedKey(String user) {
    return 'Serwer odrzucił ten klucz dla użytkownika $user. Upewnij się, że pasujący klucz publiczny jest w jego authorized_keys.';
  }

  @override
  String get notAPrivateKey =>
      'Ten plik nie jest prawidłowym kluczem prywatnym.';

  @override
  String cannotWriteFolder(String folder) {
    return 'Zalogowano, ale nie można zapisać w „$folder”. Wybierz inny folder.';
  }

  @override
  String get driveHoldsVault =>
      'W Google Drive jest już sejf Keyhold. Aby do niego dołączyć, potrzebne jest jego hasło główne.';

  @override
  String get masterPasswordOfDriveVault => 'Hasło główne sejfu w Google Drive';

  @override
  String get driveHint =>
      'Przechowuje zaszyfrowany sejf w folderze „Keyhold” na Twoim Google Drive, więc inne urządzenia są zsynchronizowane, a zgubiony komputer niczego nie zabiera. Google nie może go odczytać.';

  @override
  String get driveNotInBuild =>
      'Google Drive nie jest skonfigurowany w tej wersji.';

  @override
  String get setPasswordFirst =>
      'Najpierw ustaw hasło główne — bez niego nowe urządzenie nie otworzy sejfu.';

  @override
  String get foldersOnComputer => 'Foldery na tym komputerze';

  @override
  String folderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count folderu',
      many: '$count folderów',
      few: '$count foldery',
      one: '1 folder',
    );
    return '$_temp0';
  }

  @override
  String folderCountCopied(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count folderu — ostatnia kopia $time',
      many: '$count folderów — ostatnia kopia $time',
      few: '$count foldery — ostatnia kopia $time',
      one: '1 folder — ostatnia kopia $time',
    );
    return '$_temp0';
  }

  @override
  String get yourServer => 'Twój serwer';

  @override
  String get foldersHint =>
      'Każdy zapis zostawia w każdym folderze kopię z datą i zachowuje 30 ostatnich.';

  @override
  String get noFolders => 'Brak folderów — kopie lokalne są wyłączone';

  @override
  String get addFolder => 'Dodaj folder';

  @override
  String get serverHint =>
      'Ta sama kopia trafia przez SFTP na Twój własny serwer. Plik pozostaje zaszyfrowany, więc serwer widzi tylko bajty. Zostaw pusty host, aby to pominąć.';

  @override
  String get host => 'Host';

  @override
  String get port => 'Port';

  @override
  String get user => 'Użytkownik';

  @override
  String get privateKeyFile => 'Plik klucza prywatnego';

  @override
  String get chooseFile => 'Wybierz plik';

  @override
  String get serverFolder => 'Folder na serwerze';

  @override
  String get testConnection => 'Sprawdź połączenie';

  @override
  String get notReachable => 'Chwilowo niedostępny';

  @override
  String get enterCodeKey => 'Wpisz klucz kodu weryfikacyjnego';

  @override
  String get twoFactorCode => 'Kod weryfikacyjny';

  @override
  String get newEntryTitle => 'Nowy wpis';

  @override
  String get editEntry => 'Edytuj wpis';

  @override
  String get name => 'Nazwa';

  @override
  String get key => 'Klucz';

  @override
  String get keyHint => 'Wklej klucz konfiguracyjny albo cały link otpauth://';

  @override
  String get note => 'Notatka';

  @override
  String get addresses => 'Adresy';

  @override
  String get codeNotUsedYet =>
      'Jeszcze nigdzie nieużywany. Przypnie się sam, gdy pierwszy raz użyjesz go na stronie, albo przypnij go w danych logowania.';

  @override
  String get noAddress => 'brak adresu';

  @override
  String get unpin => 'Odepnij';

  @override
  String get addAddress => 'Dodaj adres';

  @override
  String get title => 'Tytuł';

  @override
  String get noName => '(bez nazwy)';

  @override
  String get none => 'Brak';

  @override
  String get choose => 'Wybierz';

  @override
  String get group => 'Grupa';

  @override
  String get groupHint => 'Wybierz lub wpisz nową nazwę';

  @override
  String get driveTabConnected =>
      'Keyhold jest połączony z Google Drive. Możesz zamknąć tę kartę.';

  @override
  String get driveTabNotConnected =>
      'Nie połączono z Google Drive. Możesz zamknąć tę kartę.';

  @override
  String get signInTooLong =>
      'Logowanie w Google trwało zbyt długo — spróbuj ponownie';

  @override
  String get signInCancelled => 'Logowanie w Google zostało anulowane';

  @override
  String get noOfflineAccess => 'Google nie zezwolił na dostęp offline';

  @override
  String get noInternet => 'Brak połączenia z internetem';

  @override
  String get wrongMasterPassword => 'Nieprawidłowe hasło główne';

  @override
  String driveRefusedDownload(String status) {
    return 'Google Drive odmówił pobrania ($status)';
  }

  @override
  String driveRefusedUpload(String status) {
    return 'Google Drive odmówił przesłania ($status)';
  }

  @override
  String driveAnswered(String status) {
    return 'Google Drive odpowiedział: $status';
  }

  @override
  String get driveSignInAgain => 'Google Drive wymaga ponownego zalogowania';

  @override
  String get driveNotConnectedError => 'Google Drive nie jest połączony';

  @override
  String get driveAccessEnded =>
      'Dostęp do Google Drive wygasł — połącz ponownie';

  @override
  String signInFailed(String status) {
    return 'Logowanie w Google nie powiodło się ($status)';
  }

  @override
  String get dupNewest => 'najnowszy';

  @override
  String get dupSamePassword => 'to samo hasło co najnowszy';

  @override
  String get dupDifferentPassword => 'inne hasło';

  @override
  String get noUsername => '(bez nazwy użytkownika)';

  @override
  String duplicateNote(String username, String password, String day) {
    return '$username · $password · zmieniono $day';
  }

  @override
  String get fileEmpty => 'Plik jest pusty';

  @override
  String get noLoginColumns =>
      'W tym pliku nie ma kolumny z nazwą użytkownika ani hasłem';

  @override
  String get noQrOnScreen => 'Nie znaleziono kodu QR na ekranie';

  @override
  String get noQrInImage => 'Nie znaleziono kodu QR na tym obrazie';

  @override
  String get qrNotTwoFactor => 'Ten kod QR nie jest kodem weryfikacyjnym';

  @override
  String get exportQrEmpty => 'Kod QR eksportu jest pusty';

  @override
  String get exportQrUnreadable =>
      'Nie udało się odczytać tego kodu QR eksportu';

  @override
  String serverWritable(String account) {
    return 'Połączono jako $account, można zapisywać w folderze';
  }

  @override
  String get openKeyhold => 'Otwórz Keyhold';

  @override
  String get quit => 'Zakończ';

  @override
  String codesFound(int count) {
    return 'Znaleziono: $count';
  }

  @override
  String codesUnsupported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count używa typu kodu, którego Keyhold jeszcze nie obsługuje',
      many: '$count używa typu kodu, którego Keyhold jeszcze nie obsługuje',
      few: '$count używają typu kodu, którego Keyhold jeszcze nie obsługuje',
      one: '1 używa typu kodu, którego Keyhold jeszcze nie obsługuje',
    );
    return '$_temp0';
  }

  @override
  String savedAs(String name) {
    return 'Zapisano jako $name';
  }

  @override
  String savedCodes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zapisano $count kodu',
      many: 'Zapisano $count kodów',
      few: 'Zapisano $count kody',
      one: 'Zapisano 1 kod',
    );
    return '$_temp0';
  }

  @override
  String get images => 'Obrazy';

  @override
  String get addCodes => 'Dodaj kody weryfikacyjne';

  @override
  String get saveAll => 'Zapisz wszystkie';

  @override
  String get qrHintPhone =>
      'Skieruj aparat na kod QR, który pokazuje strona, gdy włączasz weryfikację dwuetapową, albo na eksport z Google Authenticator (Przenieś konta → Eksportuj konta).';

  @override
  String get qrHintComputer =>
      'Wyświetl kod QR na ekranie i zeskanuj go. Może to być kod, który pokazuje strona, gdy włączasz weryfikację dwuetapową, albo eksport z Google Authenticator (Przenieś konta → Eksportuj konta). Zdjęcie kodu też zadziała.';

  @override
  String get qrMicrosoftHint =>
      'Microsoft Authenticator nie pozwala eksportować kodów — wyłącz i ponownie włącz weryfikację dwuetapową na każdej stronie i zeskanuj tu nowy kod.';

  @override
  String get scanCamera => 'Skanuj aparatem';

  @override
  String get scanScreen => 'Skanuj ekran';

  @override
  String get openImage => 'Otwórz obraz';

  @override
  String get saved => 'Zapisano';

  @override
  String get alreadyInKeyhold => 'Już jest w Keyhold';

  @override
  String asName(String name) {
    return 'jako „$name”';
  }

  @override
  String get typePasswordFirst => 'Najpierw wpisz hasło';

  @override
  String get atLeast8 => 'Użyj co najmniej 8 znaków';

  @override
  String get passwordsDiffer => 'Hasła się różnią';

  @override
  String get passwordDoesNotOpen => 'To hasło nie otwiera tego sejfu';

  @override
  String get currentPasswordWrong => 'Obecne hasło główne jest nieprawidłowe';

  @override
  String get unlockVault => 'Odblokuj sejf';

  @override
  String get unlockHint =>
      'Ten sejf pochodzi z innego komputera. Wpisz hasło główne, aby go tu otworzyć.';

  @override
  String get masterPasswordHint =>
      'Windows otwiera ten sejf automatycznie. Hasło główne pozwala do niego wrócić po ponownej instalacji, na nowym komputerze albo na telefonie.';

  @override
  String get currentMasterPassword => 'Obecne hasło główne';

  @override
  String get newMasterPassword => 'Nowe hasło główne';

  @override
  String get repeatIt => 'Powtórz hasło';

  @override
  String get openVault => 'Otwórz sejf';

  @override
  String get savePassword => 'Zapisz hasło';

  @override
  String get nobodyCanRecover =>
      'Jeśli je zapomnisz, sejf otworzy tylko klucz ratunkowy: wydrukuj zestaw ratunkowy.';

  @override
  String get groupApps => 'Aplikacje';

  @override
  String get openKeyholdFirst =>
      'Otwórz raz Keyhold i wpisz hasło główne, potem spróbuj ponownie.';

  @override
  String pinTo(String name, String place) {
    return 'Przypiąć „$name” do $place?';
  }

  @override
  String get pinHint => 'Wtedy od razu będzie tu podpowiadany, bez szukania.';

  @override
  String get doNotAskCode => 'Nie pytaj więcej o ten kod';

  @override
  String get notNow => 'Nie teraz';

  @override
  String get pin => 'Przypnij';

  @override
  String get savedToKeyhold => 'Zapisano w Keyhold';

  @override
  String get passwordUpdated => 'Zaktualizowano hasło w Keyhold';

  @override
  String get searchAllLogins => 'Szukaj we wszystkich danych logowania';

  @override
  String get nothingFound => 'Nic nie znaleziono.';

  @override
  String get noLoginForSite =>
      'Brak danych logowania do tej strony. Wyszukaj powyżej albo zaloguj się, a Android zaproponuje ich zapisanie.';

  @override
  String get noLoginForApp =>
      'Brak danych logowania do tej aplikacji. Wyszukaj powyżej albo zaloguj się, a Android zaproponuje ich zapisanie.';

  @override
  String listening(String address) {
    return 'Nasłuchuje na $address';
  }

  @override
  String get notListening =>
      'Nie nasłuchuje — możliwe, że działa już inny Keyhold';

  @override
  String get pairingToken => 'Token parowania';

  @override
  String get pairingTokenHint =>
      'Wklej go raz do rozszerzenia. Odpowiedź dostają tylko żądania z tym tokenem i tylko z samego rozszerzenia — strona internetowa nie ma dostępu do sejfu.';

  @override
  String get tokenCopied => 'Skopiowano token';

  @override
  String get copyToken => 'Kopiuj token';

  @override
  String get installIt => 'Instalacja';

  @override
  String get installChrome =>
      'Chrome lub Edge: otwórz chrome://extensions, włącz Tryb dewelopera, kliknij „Załaduj rozpakowane” i wybierz folder poniżej.';

  @override
  String get installFirefox =>
      'Firefox: otwórz about:debugging#/runtime/this-firefox, kliknij „Wczytaj tymczasowy dodatek” i wybierz manifest.json w tym folderze.';

  @override
  String get installPaste =>
      'Kliknij ikonę Keyhold na pasku narzędzi i wklej token.';

  @override
  String get newCodeShort => 'Nowy kod';

  @override
  String get free => 'Wolne';

  @override
  String get searchCodes => 'Szukaj kodów';

  @override
  String get everyCodePinned =>
      'Każdy kod jest już gdzieś przypięty. Przełącz na „Wszystkie”, aby je zobaczyć.';

  @override
  String get noCodesFound => 'Nie znaleziono kodów.';

  @override
  String pinnedTo(String hosts) {
    return 'przypięty do $hosts';
  }

  @override
  String get notPinned => 'nieprzypięty';

  @override
  String changedOn(String day) {
    return 'zmieniono $day';
  }

  @override
  String get importPasswords => 'Importuj hasła';

  @override
  String get importHint =>
      'Wyeksportuj hasła z przeglądarki do pliku CSV, a potem wczytaj go tutaj. Działają eksporty z Chrome, Edge, Firefox, Bitwarden i KeePassXC.';

  @override
  String get chooseCsv => 'Wybierz plik CSV';

  @override
  String entriesReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wpisu gotowego',
      many: '$count wpisów gotowych',
      few: '$count wpisy gotowe',
      one: '1 wpis gotowy',
    );
    return '$_temp0';
  }

  @override
  String entriesReadySkipped(int count, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count wpisu gotowego',
      many: '$count wpisów gotowych',
      few: '$count wpisy gotowe',
      one: '1 wpis gotowy',
    );
    String _temp1 = intl.Intl.pluralLogic(
      skipped,
      locale: localeName,
      other: 'pominięto $skipped pustego wiersza',
      many: 'pominięto $skipped pustych wierszy',
      few: 'pominięto $skipped puste wiersze',
      one: 'pominięto 1 pusty wiersz',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String andMore(int count) {
    return 'i jeszcze $count';
  }

  @override
  String get deleteCsv => 'Usuń plik CSV po imporcie';

  @override
  String get deleteCsvHint => 'Wszystkie hasła są w nim niezaszyfrowane';

  @override
  String importEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importuj $count wpisu',
      many: 'Importuj $count wpisów',
      few: 'Importuj $count wpisy',
      one: 'Importuj 1 wpis',
    );
    return '$_temp0';
  }

  @override
  String get cameraHint =>
      'Skieruj aparat na kod QR weryfikacji dwuetapowej ze strony albo na eksport z Google Authenticator.';

  @override
  String get deleteThisCode => 'Usunąć ten kod weryfikacyjny?';

  @override
  String get deleteCodeWarning =>
      'Zniknie ze wszystkich urządzeń. Bez niego nie zalogujesz się tam, gdzie jest używany.';

  @override
  String get deleteLoginWarning => 'Znikną ze wszystkich urządzeń.';

  @override
  String nextCode(String code) {
    return 'następny $code';
  }

  @override
  String get noMasterPasswordBar =>
      'Brak hasła głównego: kopii zapasowych nie da się otworzyć na innym komputerze. Kliknij, aby je ustawić.';

  @override
  String get printRecoverySheet => 'Wydrukuj zestaw ratunkowy';

  @override
  String get recoverySheet => 'Zestaw ratunkowy';

  @override
  String get recoveryIntro =>
      'Ten klucz otworzy sejf, jeśli kiedyś zapomnisz hasła głównego. Wydrukuj zestaw, przepisz na niego odręcznie ostatni wiersz i trzymaj go w domu.';

  @override
  String get print => 'Drukuj';

  @override
  String get done => 'Gotowe';

  @override
  String get sheetTitle => 'Zestaw ratunkowy Keyhold';

  @override
  String sheetMade(String date) {
    return 'Utworzono $date';
  }

  @override
  String get sheetWhere => 'Gdzie jest sejf';

  @override
  String sheetDrive(String email) {
    return 'Google Drive konta $email, folder „Keyhold”';
  }

  @override
  String sheetFolders(String folders) {
    return 'Kopie w folderach: $folders';
  }

  @override
  String sheetServer(String host) {
    return 'Kopie na serwerze $host';
  }

  @override
  String get sheetOnlyHere =>
      'Tylko na tym urządzeniu. Włącz kopię zapasową w Keyhold.';

  @override
  String get sheetSteps => 'Na nowym komputerze lub telefonie';

  @override
  String get sheetStep1 => 'Zainstaluj Keyhold: galusz.github.io/keyhold';

  @override
  String get sheetStep2 => 'Połącz Keyhold z tym samym Google Drive.';

  @override
  String get sheetStep3 =>
      'Gdy Keyhold poprosi o hasło główne, wpisz ten klucz ratunkowy. Potem wybierz nowe hasło główne.';

  @override
  String get sheetKeepSafe =>
      'Każdy, kto ma ten wypełniony zestaw, może otworzyć sejf. Przechowuj go jak zapasowy klucz do domu.';

  @override
  String get sheetDriveNoEmail => 'Google Drive, folder „Keyhold”';

  @override
  String get noBackupPlaces =>
      'Brak folderu kopii, serwera i Google Drive: sejf jest tylko na tym komputerze. Kliknij, aby to ustawić.';

  @override
  String get deleteVault => 'Usuń sejf';

  @override
  String get deleteVaultHint =>
      'Wszystko, co Keyhold trzyma na tym urządzeniu, zostanie wymazane: hasła, kody weryfikacyjne, pliki i ustawienia. Potem Keyhold zamknie się i zacznie od pustego sejfu.';

  @override
  String get deleteVaultDrive =>
      'Usuń go też z Google Drive (inne urządzenia zachowają swoją kopię, dopóki nie usuniesz jej także tam)';

  @override
  String get deleteVaultFolders =>
      'Usuń też kopie w folderach kopii zapasowych';

  @override
  String get deleteVaultSure => 'Usunąć sejf na zawsze?';

  @override
  String get deleteVaultSureHint => 'Tego nie da się cofnąć.';

  @override
  String get vaultDeleted => 'Sejf został usunięty. Keyhold zaraz się zamknie.';

  @override
  String get recoveryGate =>
      'Wpisz hasło główne, aby zobaczyć klucz ratunkowy.';

  @override
  String get showKey => 'Pokaż klucz';

  @override
  String get recoveryNeedsPassword =>
      'Najpierw ustaw hasło główne: klucz ratunkowy pojawi się dopiero potem.';

  @override
  String get recoveryCopyRow =>
      'Przepisz ten wiersz odręcznie na wydrukowany zestaw';

  @override
  String get checkRow =>
      'Potem wpisz ostatni wiersz tak, jak jest zapisany na zestawie';

  @override
  String get check => 'Sprawdź';

  @override
  String get rowMatches =>
      'Zgadza się. Przechowuj zestaw w bezpiecznym miejscu.';

  @override
  String get rowDiffers =>
      'Nie zgadza się. Porównaj ostatni wiersz z ekranem i popraw go na zestawie.';

  @override
  String get sheetKeyLabel => 'Klucz ratunkowy';

  @override
  String get sheetCopyRow =>
      'Przepisz tu odręcznie ostatni wiersz z ekranu Keyhold.';

  @override
  String get orRecoveryCode =>
      'Nie pamiętasz? Wpisz zamiast niego klucz ratunkowy z zestawu ratunkowego.';

  @override
  String get newPasswordAfterKey =>
      'Klucz ratunkowy otworzył sejf. Wybierz nowe hasło główne: zastąpi zapomniane na wszystkich urządzeniach.';

  @override
  String get otherVaultTitle => 'Kopie innego sejfu';

  @override
  String otherVaultHint(String when) {
    return 'W tym folderze są już kopie innego sejfu Keyhold (najnowsza z $when). Otworzyć ją do podglądu? Twój sejf zostanie bez zmian.';
  }

  @override
  String get copyPasswordTitle => 'Hasło główne tej kopii';

  @override
  String get copyNotOpened =>
      'Nie udało się otworzyć kopii: złe hasło lub klucz ratunkowy albo to nie jest sejf Keyhold.';

  @override
  String get openCopy => 'Otwórz plik kopii…';

  @override
  String copyTitle(String name) {
    return 'Kopia: $name';
  }

  @override
  String get copyReadOnly =>
      'Tylko do podglądu: nic tu nie zmienia Twojego sejfu. Pojedynczy wpis możesz dodać do swojego sejfu.';

  @override
  String get addToVault => 'Dodaj do mojego sejfu';

  @override
  String addedToVault(String name) {
    return '„$name” jest w Twoim sejfie';
  }
}
