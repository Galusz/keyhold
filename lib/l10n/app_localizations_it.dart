// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get cancel => 'Annulla';

  @override
  String get open => 'Apri';

  @override
  String get delete => 'Elimina';

  @override
  String get copy => 'Copia';

  @override
  String get edit => 'Modifica';

  @override
  String get add => 'Aggiungi';

  @override
  String get search => 'Cerca';

  @override
  String get settings => 'Impostazioni';

  @override
  String get change => 'Cambia';

  @override
  String get connect => 'Connetti';

  @override
  String get disconnect => 'Disconnetti';

  @override
  String get unlock => 'Sblocca';

  @override
  String get noTitle => '(senza titolo)';

  @override
  String get code => 'Codice';

  @override
  String get codes => 'Codici';

  @override
  String get username => 'Nome utente';

  @override
  String get password => 'Password';

  @override
  String get address => 'Indirizzo';

  @override
  String get notes => 'Note';

  @override
  String get duplicates => 'Duplicati';

  @override
  String get masterPassword => 'Password principale';

  @override
  String get setMasterPassword => 'Imposta password principale';

  @override
  String copied(String what) {
    return 'Copiato: $what';
  }

  @override
  String get fingerprintTitle => 'Cassaforte Keyhold';

  @override
  String get fingerprintUnlockHint =>
      'Sblocca per vedere le tue password e i tuoi codici';

  @override
  String get fingerprintConfirmHint => 'Conferma con la tua impronta';

  @override
  String driveNotConnected(String error) {
    return 'Google Drive non è stato connesso: $error';
  }

  @override
  String get masterPasswordOfVault =>
      'Password principale della tua cassaforte';

  @override
  String get masterPasswordFromComputer =>
      'Quella che hai impostato in Keyhold sul computer';

  @override
  String get scanQr => 'Scansiona un codice QR';

  @override
  String get scanQrHint =>
      'Codice a due fattori di un sito o esportazione di Google Authenticator';

  @override
  String get newCode => 'Nuovo codice a due fattori';

  @override
  String get newCodeHint => 'Digita tu la chiave di configurazione';

  @override
  String get newLogin => 'Nuove credenziali';

  @override
  String get locked => 'Keyhold è bloccato';

  @override
  String get everything => 'Tutto';

  @override
  String get noCodesYet =>
      'Ancora nessun codice a due fattori — tocca + per scansionarne uno';

  @override
  String get nothingYet => 'Ancora niente qui';

  @override
  String get justNow => 'poco fa';

  @override
  String minutesAgo(int count) {
    return '$count min fa';
  }

  @override
  String hoursAgo(int count) {
    return '$count h fa';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count giorni fa',
      one: '1 giorno fa',
    );
    return '$_temp0';
  }

  @override
  String get notBackedUp => 'Nessun backup — tocca per connettere Google Drive';

  @override
  String get backingUp => 'Backup in corso…';

  @override
  String backupFailed(String error) {
    return 'Backup non riuscito: $error';
  }

  @override
  String get waitingFirstBackup => 'In attesa del primo backup';

  @override
  String backedUpToDrive(String ago) {
    return 'Backup su Google Drive $ago';
  }

  @override
  String get phoneWelcome =>
      'Le tue password e i codici a due fattori — la stessa cassaforte del computer, sempre allineata tramite il tuo Google Drive.';

  @override
  String get connectDrive => 'Connetti Google Drive';

  @override
  String get startEmpty => 'Inizia con una cassaforte vuota';

  @override
  String codeSeconds(int seconds) {
    return 'Codice ($seconds s)';
  }

  @override
  String get driveOnlyPhone =>
      'Non connesso — la cassaforte è solo su questo telefono.';

  @override
  String connectedAs(String email) {
    return 'Connesso come $email';
  }

  @override
  String connectedAsSynced(String email, String time) {
    return 'Connesso come $email — ultima sincronizzazione $time';
  }

  @override
  String get syncNow => 'Sincronizza ora';

  @override
  String get fingerprintLock => 'Blocco con impronta';

  @override
  String get fingerprintSwitch => 'Apri Keyhold con l\'impronta';

  @override
  String get fingerprintSwitchHint =>
      'Si blocca quando lo schermo si spegne o dopo un minuto di inattività. I suggerimenti sotto i campi di accesso continuano a funzionare.';

  @override
  String get fillingPasswords => 'Compilazione password';

  @override
  String get fillerOn =>
      'Keyhold compila le credenziali in app e browser: tocca \"Keyhold\" sotto un campo di accesso. In Chrome attiva anche Impostazioni → Servizi di compilazione automatica → Compilazione automatica con un altro servizio.';

  @override
  String get fillerOff =>
      'Consenti a Keyhold di compilare credenziali e codici a due fattori in app e browser.';

  @override
  String get fillWithKeyhold => 'Compila le password con Keyhold';

  @override
  String get passwordSetPhone =>
      'Impostata. Apre questa cassaforte su un nuovo dispositivo.';

  @override
  String get passwordNotSetPhone =>
      'Non impostata. Senza di essa un nuovo dispositivo non può aprire la cassaforte.';

  @override
  String get deleteThisLogin => 'Eliminare queste credenziali?';

  @override
  String deleteNamed(String name) {
    return 'Eliminare $name?';
  }

  @override
  String get noDuplicatesLeft => 'Nessun duplicato rimasto.';

  @override
  String get groupWeb => 'Web';

  @override
  String get groupLocal => 'Rete locale';

  @override
  String get groupServers => 'Server';

  @override
  String get filterAll => 'Tutti';

  @override
  String get filter2fa => '2FA';

  @override
  String get filterPasswords => 'Password';

  @override
  String get filterFiles => 'File';

  @override
  String get groups => 'Gruppi';

  @override
  String get noGroup => 'Nessun gruppo';

  @override
  String moveCountToGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sposta $count elementi in un gruppo',
      one: 'Sposta 1 elemento in un gruppo',
    );
    return '$_temp0';
  }

  @override
  String get newGroup => 'Nuovo gruppo';

  @override
  String get newGroupHint => 'Lascia vuoto per toglierli da ogni gruppo';

  @override
  String get move => 'Sposta';

  @override
  String get clearSelection => 'Annulla selezione';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selezionati',
      one: '1 selezionato',
    );
    return '$_temp0';
  }

  @override
  String get moveToGroup => 'Sposta in un gruppo';

  @override
  String get addCodesFromQr => 'Aggiungi codici a due fattori da un codice QR';

  @override
  String get browserExtension => 'Estensione del browser';

  @override
  String get backup => 'Backup';

  @override
  String get importCsv => 'Importa da CSV';

  @override
  String get changeMasterPassword => 'Cambia password principale';

  @override
  String get addFile => 'Aggiungi file';

  @override
  String get newEntry => 'Nuovo';

  @override
  String get checking => 'Controllo in corso…';

  @override
  String get notCheckedYet => 'Non ancora controllato';

  @override
  String filesNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuovi',
      one: '1 nuovo',
    );
    return '$_temp0';
  }

  @override
  String filesChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modificati',
      one: '1 modificato',
    );
    return '$_temp0';
  }

  @override
  String filesSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count saltati',
      one: '1 saltato',
    );
    return '$_temp0';
  }

  @override
  String checkedNothingChanged(String when) {
    return 'Controllato $when — nessuna modifica';
  }

  @override
  String checkedWith(String when, String changes) {
    return 'Controllato $when — $changes';
  }

  @override
  String get watchedHint =>
      'Monitorati — copiati nella cassaforte quando cambiano, ogni 15 minuti';

  @override
  String get nothingWatched => 'Nessun elemento monitorato';

  @override
  String pathNotFound(String path) {
    return '$path — non trovato';
  }

  @override
  String get stopWatching => 'Smetti di monitorare';

  @override
  String get watchFolder => 'Monitora cartella';

  @override
  String get watchFile => 'Monitora file';

  @override
  String get checkNow => 'Controlla ora';

  @override
  String fileTooBig(String name, String size) {
    return '$name pesa $size — il limite è 25 MB';
  }

  @override
  String fileAdded(String name) {
    return '$name ora è nella cassaforte';
  }

  @override
  String savedTo(String path) {
    return 'Salvato in $path';
  }

  @override
  String removeNamed(String name) {
    return 'Rimuovere $name?';
  }

  @override
  String get removeFileHint =>
      'Sparisce dalla cassaforte. I backup precedenti lo contengono ancora.';

  @override
  String get remove => 'Rimuovi';

  @override
  String get noFilesYet =>
      'Ancora nessun file — aggiungi codici di recupero, chiavi o scansioni';

  @override
  String get saveToDisk => 'Salva su disco';

  @override
  String forWindow(String window) {
    return 'Per \"$window\"';
  }

  @override
  String get dismiss => 'Chiudi';

  @override
  String get noBackupYet => 'Ancora nessun backup — parte al primo salvataggio';

  @override
  String lastBackup(String ago) {
    return 'Ultimo backup $ago';
  }

  @override
  String backedUpTo(String ago, String targets) {
    return 'Backup $ago — $targets';
  }

  @override
  String get driveNeedsPassword =>
      'Google Drive: apri Backup e inserisci la password principale';

  @override
  String driveProblem(String problem) {
    return 'Google Drive: $problem';
  }

  @override
  String driveSynced(String ago) {
    return 'Google Drive: sincronizzato $ago';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementi',
      one: '1 elemento',
    );
    return '$_temp0';
  }

  @override
  String get select => 'Seleziona';

  @override
  String get typeCode => 'Digita il codice nella finestra precedente';

  @override
  String get typeLogin => 'Digita nome utente e password';

  @override
  String get copyPassword => 'Copia password';

  @override
  String get save => 'Salva';

  @override
  String get off => 'Disattivato';

  @override
  String onWith(String detail) {
    return 'Attivo — $detail';
  }

  @override
  String get join => 'Unisciti';

  @override
  String get synced => 'Sincronizzato';

  @override
  String get alreadyInSync => 'Già sincronizzato';

  @override
  String get fillHostFirst => 'Inserisci prima l\'host';

  @override
  String get fillUserFirst => 'Inserisci prima l\'utente';

  @override
  String get pickKeyFirst => 'Scegli prima il file della chiave privata';

  @override
  String noFileAt(String path) {
    return 'Non c\'è nessun file in $path';
  }

  @override
  String serverUnreachable(String host, String port) {
    return 'Impossibile raggiungere $host sulla porta $port. Controlla l\'indirizzo, la porta e che il server sia acceso.';
  }

  @override
  String serverRefusedKey(String user) {
    return 'Il server ha rifiutato questa chiave per l\'utente $user. Assicurati che la chiave pubblica corrispondente sia nel suo authorized_keys.';
  }

  @override
  String get notAPrivateKey =>
      'Quel file non è una chiave privata utilizzabile.';

  @override
  String cannotWriteFolder(String folder) {
    return 'Accesso riuscito, ma impossibile scrivere in \"$folder\". Scegli un\'altra cartella.';
  }

  @override
  String get driveHoldsVault =>
      'Google Drive contiene già una cassaforte Keyhold. Serve la sua password principale per unirti.';

  @override
  String get masterPasswordOfDriveVault =>
      'Password principale della cassaforte su Google Drive';

  @override
  String get driveHint =>
      'Tiene la cassaforte crittografata in una cartella \"Keyhold\" nel tuo Google Drive, così gli altri tuoi dispositivi restano sincronizzati e se perdi il computer non perdi nulla. Google non può leggerla.';

  @override
  String get driveNotInBuild =>
      'Google Drive non è configurato in questa versione.';

  @override
  String get setPasswordFirst =>
      'Imposta prima una password principale — un nuovo dispositivo ne ha bisogno per aprire la cassaforte.';

  @override
  String get foldersOnComputer => 'Cartelle su questo computer';

  @override
  String folderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartelle',
      one: '1 cartella',
    );
    return '$_temp0';
  }

  @override
  String folderCountCopied(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cartelle — ultima copia $time',
      one: '1 cartella — ultima copia $time',
    );
    return '$_temp0';
  }

  @override
  String get yourServer => 'Il tuo server';

  @override
  String get foldersHint =>
      'Ogni salvataggio mette una copia datata in ogni cartella e conserva le ultime 30.';

  @override
  String get noFolders => 'Nessuna cartella — le copie locali sono disattivate';

  @override
  String get addFolder => 'Aggiungi cartella';

  @override
  String get serverHint =>
      'La stessa copia va via SFTP a una macchina tua. Il file resta crittografato, quindi il server vede solo byte e nient\'altro. Lascia vuoto l\'host per saltare questo passaggio.';

  @override
  String get host => 'Host';

  @override
  String get port => 'Porta';

  @override
  String get user => 'Utente';

  @override
  String get privateKeyFile => 'File della chiave privata';

  @override
  String get chooseFile => 'Scegli file';

  @override
  String get serverFolder => 'Cartella sul server';

  @override
  String get testConnection => 'Prova connessione';

  @override
  String get notReachable => 'Non raggiungibile al momento';

  @override
  String get enterCodeKey => 'Inserisci la chiave del codice a due fattori';

  @override
  String get twoFactorCode => 'Codice a due fattori';

  @override
  String get newEntryTitle => 'Nuova voce';

  @override
  String get editEntry => 'Modifica voce';

  @override
  String get name => 'Nome';

  @override
  String get key => 'Chiave';

  @override
  String get keyHint =>
      'Incolla la chiave di configurazione o l\'intero link otpauth://';

  @override
  String get note => 'Nota';

  @override
  String get addresses => 'Indirizzi';

  @override
  String get codeNotUsedYet =>
      'Non ancora usato da nessuna parte. Si fissa da solo la prima volta che lo usi su un sito, oppure fissalo dalle credenziali.';

  @override
  String get noAddress => 'nessun indirizzo';

  @override
  String get unpin => 'Stacca';

  @override
  String get addAddress => 'Aggiungi un indirizzo';

  @override
  String get title => 'Titolo';

  @override
  String get noName => '(senza nome)';

  @override
  String get none => 'Nessuno';

  @override
  String get choose => 'Scegli';

  @override
  String get group => 'Gruppo';

  @override
  String get groupHint => 'Scegline uno o digita un nuovo nome';

  @override
  String get driveTabConnected =>
      'Keyhold è connesso a Google Drive. Puoi chiudere questa scheda.';

  @override
  String get driveTabNotConnected =>
      'Google Drive non è stato connesso. Puoi chiudere questa scheda.';

  @override
  String get signInTooLong =>
      'L\'accesso a Google ha richiesto troppo tempo — riprova';

  @override
  String get signInCancelled => 'L\'accesso a Google è stato annullato';

  @override
  String get noOfflineAccess => 'Google non ha consentito l\'accesso offline';

  @override
  String get noInternet => 'Nessuna connessione a Internet';

  @override
  String get wrongMasterPassword => 'Password principale errata';

  @override
  String driveRefusedDownload(String status) {
    return 'Google Drive ha rifiutato il download ($status)';
  }

  @override
  String driveRefusedUpload(String status) {
    return 'Google Drive ha rifiutato il caricamento ($status)';
  }

  @override
  String driveAnswered(String status) {
    return 'Google Drive ha risposto $status';
  }

  @override
  String get driveSignInAgain => 'Google Drive ti chiede di accedere di nuovo';

  @override
  String get driveNotConnectedError => 'Google Drive non è connesso';

  @override
  String get driveAccessEnded =>
      'L\'accesso a Google Drive è terminato — connettilo di nuovo';

  @override
  String signInFailed(String status) {
    return 'Accesso a Google non riuscito ($status)';
  }

  @override
  String get dupNewest => 'più recente';

  @override
  String get dupSamePassword => 'stessa password della più recente';

  @override
  String get dupDifferentPassword => 'password diversa';

  @override
  String get noUsername => '(senza nome utente)';

  @override
  String duplicateNote(String username, String password, String day) {
    return '$username · $password · modificato il $day';
  }

  @override
  String get fileEmpty => 'Il file è vuoto';

  @override
  String get noLoginColumns =>
      'In questo file non c\'è una colonna per nome utente o password';

  @override
  String get noQrOnScreen => 'Nessun codice QR trovato sullo schermo';

  @override
  String get noQrInImage => 'Nessun codice QR trovato in questa immagine';

  @override
  String get qrNotTwoFactor => 'Questo codice QR non è un codice a due fattori';

  @override
  String get exportQrEmpty => 'Il codice QR di esportazione è vuoto';

  @override
  String get exportQrUnreadable =>
      'Impossibile leggere questo codice QR di esportazione';

  @override
  String serverWritable(String account) {
    return 'Connesso come $account, la cartella è scrivibile';
  }

  @override
  String get openKeyhold => 'Apri Keyhold';

  @override
  String get quit => 'Esci';

  @override
  String codesFound(int count) {
    return '$count trovati';
  }

  @override
  String codesUnsupported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count usano un tipo di codice che Keyhold non sa ancora generare',
      one: '1 usa un tipo di codice che Keyhold non sa ancora generare',
    );
    return '$_temp0';
  }

  @override
  String savedAs(String name) {
    return 'Salvato come $name';
  }

  @override
  String savedCodes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count codici salvati',
      one: '1 codice salvato',
    );
    return '$_temp0';
  }

  @override
  String get images => 'Immagini';

  @override
  String get addCodes => 'Aggiungi codici a due fattori';

  @override
  String get saveAll => 'Salva tutto';

  @override
  String get qrHintPhone =>
      'Inquadra il codice QR che un sito mostra quando attivi l\'autenticazione a due fattori, oppure l\'esportazione di Google Authenticator (Trasferisci account → Esporta).';

  @override
  String get qrHintComputer =>
      'Mostra il codice QR sullo schermo e scansionalo. Può essere il codice che un sito mostra quando attivi l\'autenticazione a due fattori, oppure l\'esportazione di Google Authenticator (Trasferisci account → Esporta). Va bene anche una foto del codice.';

  @override
  String get qrMicrosoftHint =>
      'Microsoft Authenticator non può esportare i suoi codici — disattiva e riattiva l\'autenticazione a due fattori su ogni sito e scansiona qui il nuovo codice.';

  @override
  String get scanCamera => 'Scansiona con la fotocamera';

  @override
  String get scanScreen => 'Scansiona lo schermo';

  @override
  String get openImage => 'Apri un\'immagine';

  @override
  String get saved => 'Salvato';

  @override
  String get alreadyInKeyhold => 'Già in Keyhold';

  @override
  String asName(String name) {
    return 'come \"$name\"';
  }

  @override
  String get typePasswordFirst => 'Prima digita la password';

  @override
  String get atLeast8 => 'Usa almeno 8 caratteri';

  @override
  String get passwordsDiffer => 'Le due password sono diverse';

  @override
  String get passwordDoesNotOpen => 'Questa password non apre la cassaforte';

  @override
  String get currentPasswordWrong => 'La password principale attuale è errata';

  @override
  String get unlockVault => 'Sblocca cassaforte';

  @override
  String get unlockHint =>
      'Questa cassaforte viene da un altro computer. Digita la password principale per aprirla qui.';

  @override
  String get masterPasswordHint =>
      'Windows apre questa cassaforte per te in automatico. La password principale ti fa rientrare dopo una reinstallazione, su un nuovo computer o sul telefono.';

  @override
  String get currentMasterPassword => 'Password principale attuale';

  @override
  String get newMasterPassword => 'Nuova password principale';

  @override
  String get repeatIt => 'Ripetila';

  @override
  String get openVault => 'Apri cassaforte';

  @override
  String get savePassword => 'Salva password';

  @override
  String get nobodyCanRecover =>
      'Se la dimentichi, solo la chiave di recupero apre la tua cassaforte: stampa il foglio di recupero.';

  @override
  String get groupApps => 'App';

  @override
  String get openKeyholdFirst =>
      'Apri Keyhold una volta e inserisci la password principale, poi riprova.';

  @override
  String pinTo(String name, String place) {
    return 'Fissare \"$name\" a $place?';
  }

  @override
  String get pinHint => 'Così qui ti verrà proposto subito, senza cercarlo.';

  @override
  String get doNotAskCode => 'Non chiedere più per questo codice';

  @override
  String get notNow => 'Non ora';

  @override
  String get pin => 'Fissa';

  @override
  String get savedToKeyhold => 'Salvato in Keyhold';

  @override
  String get passwordUpdated => 'Password aggiornata in Keyhold';

  @override
  String get searchAllLogins => 'Cerca in tutte le credenziali';

  @override
  String get nothingFound => 'Nessun risultato.';

  @override
  String get noLoginForSite =>
      'Ancora nessuna credenziale per questo sito. Cerca qui sopra, oppure accedi e Android ti proporrà di salvarla.';

  @override
  String get noLoginForApp =>
      'Ancora nessuna credenziale per questa app. Cerca qui sopra, oppure accedi e Android ti proporrà di salvarla.';

  @override
  String listening(String address) {
    return 'In ascolto su $address';
  }

  @override
  String get notListening =>
      'Non in ascolto — forse un altro Keyhold è già aperto';

  @override
  String get pairingToken => 'Token di abbinamento';

  @override
  String get pairingTokenHint =>
      'Incollalo una volta nell\'estensione. Solo le richieste che lo contengono ricevono risposta, e solo dall\'estensione stessa — una pagina web non può raggiungere la cassaforte.';

  @override
  String get tokenCopied => 'Token copiato';

  @override
  String get copyToken => 'Copia token';

  @override
  String get installIt => 'Installala';

  @override
  String get installChrome =>
      'Chrome o Edge: apri chrome://extensions, attiva la Modalità sviluppatore, fai clic su \"Carica estensione non pacchettizzata\" e scegli la cartella qui sotto.';

  @override
  String get installFirefox =>
      'Firefox: apri about:debugging#/runtime/this-firefox, fai clic su \"Carica componente aggiuntivo temporaneo\" e scegli manifest.json in quella cartella.';

  @override
  String get installPaste =>
      'Fai clic sull\'icona di Keyhold nella barra degli strumenti e incolla il token.';

  @override
  String get newCodeShort => 'Nuovo codice';

  @override
  String get free => 'Liberi';

  @override
  String get searchCodes => 'Cerca codici';

  @override
  String get everyCodePinned =>
      'Ogni codice è fissato da qualche parte. Passa a Tutti per vederli.';

  @override
  String get noCodesFound => 'Nessun codice trovato.';

  @override
  String pinnedTo(String hosts) {
    return 'fissato a $hosts';
  }

  @override
  String get notPinned => 'non fissato';

  @override
  String changedOn(String day) {
    return 'modificato il $day';
  }

  @override
  String get importPasswords => 'Importa password';

  @override
  String get importHint =>
      'Esporta le password dal browser in formato CSV, poi carica qui il file. Vanno bene le esportazioni di Chrome, Edge, Firefox, Bitwarden e KeePassXC.';

  @override
  String get chooseCsv => 'Scegli file CSV';

  @override
  String entriesReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voci pronte',
      one: '1 voce pronta',
    );
    return '$_temp0';
  }

  @override
  String entriesReadySkipped(int count, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voci pronte',
      one: '1 voce pronta',
    );
    String _temp1 = intl.Intl.pluralLogic(
      skipped,
      locale: localeName,
      other: '$skipped righe vuote saltate',
      one: '1 riga vuota saltata',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String andMore(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'e altre $count',
      one: 'e un\'altra',
    );
    return '$_temp0';
  }

  @override
  String get deleteCsv => 'Elimina il file CSV dopo l\'importazione';

  @override
  String get deleteCsvHint => 'Contiene tutte le password in chiaro';

  @override
  String importEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importa $count voci',
      one: 'Importa 1 voce',
    );
    return '$_temp0';
  }

  @override
  String get cameraHint =>
      'Inquadra il codice QR a due fattori di un sito, oppure l\'esportazione di Google Authenticator.';

  @override
  String get deleteThisCode => 'Eliminare questo codice a due fattori?';

  @override
  String get deleteCodeWarning =>
      'Sparisce da tutti i tuoi dispositivi. Senza di esso non puoi accedere dove viene usato.';

  @override
  String get deleteLoginWarning => 'Spariscono da tutti i tuoi dispositivi.';

  @override
  String nextCode(String code) {
    return 'prossimo $code';
  }

  @override
  String get noMasterPasswordBar =>
      'Nessuna password principale: i tuoi backup non si possono aprire su un altro computer. Fai clic per impostarla.';

  @override
  String get printRecoverySheet => 'Stampa il foglio di recupero';

  @override
  String get recoverySheet => 'Foglio di recupero';

  @override
  String get recoveryIntro =>
      'Questa chiave apre la tua cassaforte se dimentichi la password principale. Stampa il foglio, copiaci a mano l\'ultima riga e tienilo a casa.';

  @override
  String get print => 'Stampa';

  @override
  String get done => 'Fatto';

  @override
  String get sheetTitle => 'Foglio di recupero Keyhold';

  @override
  String sheetMade(String date) {
    return 'Creato il $date';
  }

  @override
  String get sheetWhere => 'Dove si trova la tua cassaforte';

  @override
  String sheetDrive(String email) {
    return 'Google Drive di $email, cartella \"Keyhold\"';
  }

  @override
  String sheetFolders(String folders) {
    return 'Copie nelle cartelle: $folders';
  }

  @override
  String sheetServer(String host) {
    return 'Copie sul server $host';
  }

  @override
  String get sheetOnlyHere =>
      'Solo su questo dispositivo. Attiva un backup in Keyhold.';

  @override
  String get sheetSteps => 'Su un nuovo computer o telefono';

  @override
  String get sheetStep1 => 'Installa Keyhold: galusz.github.io/keyhold';

  @override
  String get sheetStep2 => 'Connetti lo stesso Google Drive in Keyhold.';

  @override
  String get sheetStep3 =>
      'Quando Keyhold chiede la password principale, digita questa chiave di recupero. Poi scegli una nuova password principale.';

  @override
  String get sheetKeepSafe =>
      'Chiunque abbia questo foglio completato può aprire la tua cassaforte. Custodiscilo come una chiave di casa di riserva.';

  @override
  String get sheetDriveNoEmail => 'Google Drive, cartella \"Keyhold\"';

  @override
  String get noBackupPlaces =>
      'Nessuna cartella di backup, server o Google Drive: la cassaforte è solo su questo computer. Fai clic per configurarne uno.';

  @override
  String get deleteVault => 'Elimina la cassaforte';

  @override
  String get deleteVaultHint =>
      'Tutto ciò che Keyhold conserva su questo dispositivo viene cancellato: password, codici a due fattori, file e impostazioni. Poi Keyhold si chiude e riparte vuoto.';

  @override
  String get deleteVaultDrive =>
      'Eliminala anche da Google Drive (gli altri dispositivi tengono la loro copia finché non la elimini anche lì)';

  @override
  String get deleteVaultFolders =>
      'Elimina anche le copie nelle cartelle di backup';

  @override
  String get deleteVaultSure => 'Eliminare la cassaforte per sempre?';

  @override
  String get deleteVaultSureHint => 'L’operazione non si può annullare.';

  @override
  String get vaultDeleted =>
      'La cassaforte è stata eliminata. Keyhold ora si chiude.';

  @override
  String get recoveryGate =>
      'Digita la tua password principale per vedere la chiave di recupero.';

  @override
  String get showKey => 'Mostra la chiave';

  @override
  String get recoveryNeedsPassword =>
      'Prima imposta una password principale: la chiave di recupero appare solo dopo.';

  @override
  String get recoveryCopyRow => 'Copia a mano questa riga sul foglio stampato';

  @override
  String get checkRow =>
      'Poi digita l\'ultima riga come l\'hai scritta sul foglio';

  @override
  String get check => 'Controlla';

  @override
  String get rowMatches =>
      'Corrisponde. Conserva il foglio in un posto sicuro.';

  @override
  String get rowDiffers =>
      'Non corrisponde. Confronta l\'ultima riga con lo schermo e correggila sul foglio.';

  @override
  String get sheetKeyLabel => 'Chiave di recupero';

  @override
  String get sheetCopyRow =>
      'Copia qui a mano l\'ultima riga dalla schermata di Keyhold.';

  @override
  String get orRecoveryCode =>
      'L\'hai dimenticata? Digita invece la chiave di recupero del tuo foglio di recupero.';

  @override
  String get newPasswordAfterKey =>
      'La chiave di recupero ha aperto la tua cassaforte. Scegli una nuova password principale: sostituirà quella dimenticata su tutti i tuoi dispositivi.';

  @override
  String get otherVaultTitle => 'Copie di un’altra cassaforte';

  @override
  String otherVaultHint(String when) {
    return 'Questa cartella contiene già copie di un’altra cassaforte Keyhold (la più recente del $when). Aprirla per guardarci dentro? La tua cassaforte resta com’è.';
  }

  @override
  String get copyPasswordTitle => 'Password principale di questa copia';

  @override
  String get copyNotOpened =>
      'Impossibile aprire la copia: password o chiave di recupero errata, oppure non è una cassaforte Keyhold.';

  @override
  String get openCopy => 'Apri una copia di backup…';

  @override
  String copyTitle(String name) {
    return 'Copia: $name';
  }

  @override
  String get copyReadOnly =>
      'Solo da consultare: qui nulla cambia la tua cassaforte. Puoi aggiungere singole voci alla tua cassaforte.';

  @override
  String get addToVault => 'Aggiungi alla mia cassaforte';

  @override
  String addedToVault(String name) {
    return '\"$name\" è nella tua cassaforte';
  }
}
