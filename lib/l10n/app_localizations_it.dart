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
  String get connectDrive => 'Connetti Google Drive';

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
  String get unlockVault => 'Sblocca cassaforte';

  @override
  String get unlockHint =>
      'Questa cassaforte viene da un altro computer. Digita la password principale per aprirla qui.';

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
  String get deleteCsvHint => 'Contiene tutte le password in chiaro';

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
  String get deleteVaultFolders =>
      'Elimina anche le copie nelle cartelle di backup';

  @override
  String get deleteVaultSure => 'Eliminare la cassaforte per sempre?';

  @override
  String get deleteVaultSureHint => 'L’operazione non si può annullare.';

  @override
  String get recoveryGate =>
      'Digita la tua password principale per vedere la chiave di recupero.';

  @override
  String get showKey => 'Mostra la chiave';

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
  String copyTitle(String name) {
    return 'Copia: $name';
  }

  @override
  String get copyReadOnly =>
      'Solo da consultare: qui nulla cambia la tua cassaforte. Puoi aggiungere singole voci alla tua cassaforte.';

  @override
  String get myVault => 'La mia cassaforte';

  @override
  String get vaultTab => 'Cassaforte';

  @override
  String get syncTab => 'Sincronizza';

  @override
  String get copiesTab => 'Backup';

  @override
  String get startHint =>
      'Le tue password e i codici a due fattori in una sola cassaforte: sul computer, sul telefono e nel browser.';

  @override
  String get createVault => 'Crea una nuova cassaforte';

  @override
  String get openMyVault => 'Apri la mia cassaforte';

  @override
  String get newVault => 'Nuova cassaforte';

  @override
  String get vaultName => 'Nome della cassaforte';

  @override
  String get newVaultHint =>
      'La password principale apre questa cassaforte su ogni tuo dispositivo: computer, telefono e browser. Keyhold non può recuperarla; la chiave di recupero che ricevi subito dopo sì.';

  @override
  String get sealHint =>
      'La tua cassaforte non ha ancora una password principale. Impostala ora: apre questa cassaforte sugli altri dispositivi e nel browser.';

  @override
  String get createVaultButton => 'Crea la cassaforte';

  @override
  String get forgotPassword => 'Password dimenticata?';

  @override
  String get usePassword => 'Usa la password principale';

  @override
  String get recoveryKey => 'Chiave di recupero';

  @override
  String get recoveryKeyFieldHint =>
      'I 36 caratteri del tuo foglio di recupero; gli spazi non contano.';

  @override
  String get openVaultTitle => 'Apri una cassaforte';

  @override
  String get openVaultHint =>
      'La cassaforte si apre così com’è. Non viene mai unita a un’altra cassaforte.';

  @override
  String get fromDrive => 'Da Google Drive';

  @override
  String get fromDriveHint =>
      'Accedi a Google, poi digita la password principale della cassaforte.';

  @override
  String fromDriveAs(String email) {
    return '$email: digita la password principale della cassaforte.';
  }

  @override
  String get fromFile => 'Da un file (.khd)';

  @override
  String get fromFileHint =>
      'Una copia da una cartella di backup, da una chiavetta USB o da un vecchio computer.';

  @override
  String get closedHere => 'Aperte prima su questo dispositivo';

  @override
  String closedOn(String date) {
    return 'chiusa il $date';
  }

  @override
  String get closedVaultGone =>
      'Il file di quella cassaforte non è più su questo dispositivo.';

  @override
  String get typeVaultPassword =>
      'Digita la password principale della cassaforte che vuoi aprire. Keyhold la prova su ogni cassaforte del tuo Google Drive.';

  @override
  String lookingForVault(int at, int of) {
    return 'Cerco la tua cassaforte: $at di $of';
  }

  @override
  String get noVaultInDrive =>
      'In questo Google Drive non c\'è ancora una cassaforte Keyhold.';

  @override
  String get noVaultMatches =>
      'Nessuna cassaforte nel tuo Google Drive si apre con questa password.';

  @override
  String get sameVaultFile =>
      'Questo file è una copia della cassaforte già aperta. Per riprenderne delle voci, usa Backup e poi Esamina una copia.';

  @override
  String fileVaultPassword(String name) {
    return 'Digita la password principale di $name.';
  }

  @override
  String get driveFileUnreadable =>
      'Il file di questa cassaforte in Google Drive non si può leggere. Keyhold lo lascia com’è.';

  @override
  String get vaultInfoHint =>
      'Questa cassaforte si apre con la sua password principale su ogni dispositivo. Se dimentichi la password, la chiave di recupero apre la cassaforte e ne scegli una nuova.';

  @override
  String get recoveryKeyHint =>
      'Mostrata e stampata dopo la password principale';

  @override
  String get otherVaults => 'Altre casseforti';

  @override
  String get openOtherVault => 'Apri un’altra cassaforte';

  @override
  String get openOtherVaultHint =>
      'Da Google Drive, da un file o da questo dispositivo';

  @override
  String get createNewVaultHint => 'Vuota, con una propria password principale';

  @override
  String closeVaultTitle(String name) {
    return 'Chiudere \"$name\" su questo dispositivo?';
  }

  @override
  String get closeVaultHint =>
      'Non si cancella nulla: resta in Google Drive, nelle copie di backup e nell’elenco delle casseforti di questo dispositivo. Si riapre con la sua password principale.';

  @override
  String get continueLabel => 'Continua';

  @override
  String get renameVault => 'Rinomina la cassaforte';

  @override
  String get reviewCopy => 'Esamina una copia';

  @override
  String get driveVaultHint =>
      'Tiene questa cassaforte come file cifrato a sé in una cartella \"Keyhold\" del tuo Google Drive. Gli altri dispositivi la aprono con la sua password principale. Più casseforti possono stare nello stesso Google Drive senza mai mescolarsi. Google non può leggerle.';

  @override
  String get foldersSlotsHint =>
      'Ogni salvataggio aggiorna fino a 7 copie della cassaforte in ogni cartella: la più recente e altre di circa un’ora, un giorno, una settimana, un mese, tre mesi e un anno fa.';

  @override
  String get deleteVaultHereHint =>
      'La cassaforte viene cancellata da questo dispositivo: password, codici a due fattori e file. Le casseforti aperte qui in precedenza restano. Poi Keyhold mostra la schermata iniziale.';

  @override
  String get deleteVaultDriveMine =>
      'Cancellala anche da Google Drive (le altre casseforti restano)';

  @override
  String get vaultDeletedHere => 'La cassaforte è cancellata.';

  @override
  String get menu => 'Menu';

  @override
  String get importTitle => 'Importa';

  @override
  String get importMenuHint =>
      'Password e codici da altre app o da un’altra cassaforte';

  @override
  String get importAnyHint =>
      'Scegli un’esportazione da un altro gestore di password o app di autenticazione, un database KeePass o un’altra cassaforte Keyhold. Keyhold riconosce il file da solo e tu spunti cosa entra.';

  @override
  String get importReading => 'Lettura del file…';

  @override
  String importPasswordTitle(String format) {
    return 'Password di questo file $format';
  }

  @override
  String get importWrongPassword => 'Questa password non apre il file.';

  @override
  String get importUnknown =>
      'Keyhold non riconosce questo file. Esportalo di nuovo dall’altra app, come CSV o JSON.';

  @override
  String importNothing(String format) {
    return '$format: in questo file non c’è nulla che Keyhold possa tenere.';
  }

  @override
  String get keePassUnsupported =>
      'Questo database KeePass usa qualcosa che Keyhold non sa aprire (un file chiave o il cifrario Twofish). Esportalo da KeePass come CSV.';

  @override
  String get bitwardenAccountLocked =>
      'Questa esportazione di Bitwarden si apre solo con il tuo account Bitwarden. Esporta di nuovo come JSON, protetto da password o senza cifratura.';

  @override
  String get otpLinks => 'link otpauth';

  @override
  String get importPickHint =>
      'Spunta cosa deve entrare nella tua cassaforte. Quello che hai già resta senza spunta.';

  @override
  String codesLeftOut(int count) {
    return 'Codici esclusi: $count. Keyhold genera solo codici a 6 cifre ogni 30 secondi, non a 8 cifre, 60 secondi, contatori o Steam.';
  }

  @override
  String recordsLeftOut(int count) {
    return 'Elementi esclusi: $count (vuoti, carte e identità).';
  }

  @override
  String get selectAll => 'Seleziona tutto';

  @override
  String get alreadyInVault => 'già nella cassaforte';

  @override
  String addSelected(int count) {
    return 'Aggiungi ($count)';
  }

  @override
  String addedCount(int count) {
    return 'Aggiunti alla cassaforte: $count';
  }

  @override
  String get deletePlainFile => 'Elimina il file dopo';

  @override
  String get importPasswordsFrom => 'Password';

  @override
  String get importPasswordsList =>
      'Chrome, Edge, Firefox e Safari (CSV), Bitwarden (CSV o JSON), 1Password (.1pux o CSV), KeePass e KeePassXC (.kdbx o CSV), LastPass, Proton Pass, NordPass e Dashlane (CSV), e un’altra cassaforte Keyhold (.khd).';

  @override
  String get importCodesFrom => 'Codici a due fattori';

  @override
  String get importCodesList =>
      'Aegis (.json), 2FAS (.2fas), Ente Auth, FreeOTP+ e andOTP, e qualsiasi file di link otpauth://. Google Authenticator: mostra il suo QR code di esportazione e usa il pulsante QR code di Keyhold.';

  @override
  String get importNoExport =>
      'Microsoft Authenticator e Authy non fanno uscire i codici: riattiva la verifica in due passaggi su ogni servizio e scansiona il nuovo QR code.';

  @override
  String get foldersOnPhone => 'Cartelle su questo telefono';

  @override
  String get phoneFoldersHint =>
      'Scegli una cartella del telefono, della scheda di memoria o di un’app come Nextcloud o OneDrive che permette ad Android di salvarci.';

  @override
  String get copiesPlaces => 'Cartelle e il tuo server';

  @override
  String get shareVaultCopy => 'Condividi una copia della cassaforte';

  @override
  String get shareVaultHint =>
      'Puoi anche inviare il file per e-mail o tenerlo in File: si apre solo con la password principale o la chiave di recupero.';
}
