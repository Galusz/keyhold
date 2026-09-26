// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get cancel => 'Annuler';

  @override
  String get open => 'Ouvrir';

  @override
  String get delete => 'Supprimer';

  @override
  String get copy => 'Copier';

  @override
  String get edit => 'Modifier';

  @override
  String get add => 'Ajouter';

  @override
  String get search => 'Rechercher';

  @override
  String get settings => 'Paramètres';

  @override
  String get change => 'Changer';

  @override
  String get disconnect => 'Déconnecter';

  @override
  String get unlock => 'Déverrouiller';

  @override
  String get noTitle => '(sans titre)';

  @override
  String get code => 'Code';

  @override
  String get codes => 'Codes';

  @override
  String get username => 'Nom d’utilisateur';

  @override
  String get password => 'Mot de passe';

  @override
  String get address => 'Adresse';

  @override
  String get notes => 'Notes';

  @override
  String get duplicates => 'Doublons';

  @override
  String get masterPassword => 'Mot de passe principal';

  @override
  String copied(String what) {
    return '$what copié';
  }

  @override
  String get fingerprintTitle => 'Coffre-fort Keyhold';

  @override
  String get fingerprintUnlockHint =>
      'Déverrouillez pour voir vos mots de passe et codes';

  @override
  String get fingerprintConfirmHint =>
      'Confirmez avec votre empreinte digitale';

  @override
  String driveNotConnected(String error) {
    return 'Google Drive n’a pas été connecté : $error';
  }

  @override
  String get scanQr => 'Scanner un code QR';

  @override
  String get scanQrHint =>
      'Code de double authentification d’un site ou export de Google Authenticator';

  @override
  String get newCode => 'Nouveau code de double authentification';

  @override
  String get newCodeHint => 'Saisissez vous-même la clé de configuration';

  @override
  String get newLogin => 'Nouvel identifiant';

  @override
  String get locked => 'Keyhold est verrouillé';

  @override
  String get everything => 'Tout';

  @override
  String get noCodesYet =>
      'Aucun code de double authentification — appuyez sur + pour en scanner un';

  @override
  String get nothingYet => 'Rien ici pour l’instant';

  @override
  String get justNow => 'à l’instant';

  @override
  String minutesAgo(int count) {
    return 'il y a $count min';
  }

  @override
  String hoursAgo(int count) {
    return 'il y a $count h';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count jours',
      one: 'il y a $count jour',
    );
    return '$_temp0';
  }

  @override
  String get notBackedUp =>
      'Non sauvegardé — appuyez pour connecter Google Drive';

  @override
  String get backingUp => 'Sauvegarde…';

  @override
  String backupFailed(String error) {
    return 'Échec de la sauvegarde : $error';
  }

  @override
  String get waitingFirstBackup => 'En attente de la première sauvegarde';

  @override
  String backedUpToDrive(String ago) {
    return 'Sauvegardé sur Google Drive $ago';
  }

  @override
  String get connectDrive => 'Connecter Google Drive';

  @override
  String codeSeconds(int seconds) {
    return 'Code ($seconds s)';
  }

  @override
  String get driveOnlyPhone =>
      'Non connecté — le coffre-fort n’existe que sur ce téléphone.';

  @override
  String connectedAs(String email) {
    return 'Connecté en tant que $email';
  }

  @override
  String connectedAsSynced(String email, String time) {
    return 'Connecté en tant que $email — dernière synchronisation $time';
  }

  @override
  String get syncNow => 'Synchroniser maintenant';

  @override
  String get fingerprintSwitch => 'Ouvrir Keyhold avec une empreinte digitale';

  @override
  String get fingerprintSwitchHint =>
      'Se verrouille quand l’écran s’éteint ou après une minute d’absence. Les suggestions sous les champs de connexion restent disponibles.';

  @override
  String get fillingPasswords => 'Remplissage des mots de passe';

  @override
  String get fillerOn =>
      'Keyhold remplit les identifiants dans les applis et les navigateurs : appuyez sur « Keyhold » sous un champ de connexion. Dans Chrome, activez aussi Paramètres → Services de saisie automatique → Saisie automatique avec un autre service.';

  @override
  String get fillerOff =>
      'Laissez Keyhold remplir les identifiants et les codes de double authentification dans les applis et les navigateurs.';

  @override
  String get fillWithKeyhold => 'Remplir les mots de passe avec Keyhold';

  @override
  String get deleteThisLogin => 'Supprimer cet identifiant ?';

  @override
  String deleteNamed(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get noDuplicatesLeft => 'Plus aucun doublon.';

  @override
  String get groupWeb => 'Web';

  @override
  String get groupLocal => 'Réseau local';

  @override
  String get groupServers => 'Serveurs';

  @override
  String get filterAll => 'Tous';

  @override
  String get filter2fa => '2FA';

  @override
  String get filterPasswords => 'Mots de passe';

  @override
  String get filterFiles => 'Fichiers';

  @override
  String get groups => 'Groupes';

  @override
  String get noGroup => 'Sans groupe';

  @override
  String moveCountToGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Déplacer $count éléments vers un groupe',
      one: 'Déplacer $count élément vers un groupe',
    );
    return '$_temp0';
  }

  @override
  String get newGroup => 'Nouveau groupe';

  @override
  String get newGroupHint => 'Laissez vide pour les retirer de tout groupe';

  @override
  String get move => 'Déplacer';

  @override
  String get clearSelection => 'Effacer la sélection';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sélectionnés',
      one: '$count sélectionné',
    );
    return '$_temp0';
  }

  @override
  String get moveToGroup => 'Déplacer vers un groupe';

  @override
  String get addCodesFromQr =>
      'Ajouter des codes de double authentification depuis un code QR';

  @override
  String get browserExtension => 'Extension de navigateur';

  @override
  String get addFile => 'Ajouter un fichier';

  @override
  String get newEntry => 'Nouveau';

  @override
  String get checking => 'Vérification…';

  @override
  String get notCheckedYet => 'Pas encore vérifié';

  @override
  String filesNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nouveaux',
      one: '$count nouveau',
    );
    return '$_temp0';
  }

  @override
  String filesChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modifiés',
      one: '$count modifié',
    );
    return '$_temp0';
  }

  @override
  String filesSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ignorés',
      one: '$count ignoré',
    );
    return '$_temp0';
  }

  @override
  String checkedNothingChanged(String when) {
    return 'Vérifié $when — aucun changement';
  }

  @override
  String checkedWith(String when, String changes) {
    return 'Vérifié $when — $changes';
  }

  @override
  String get watchedHint =>
      'Surveillés — copiés dans le coffre-fort dès qu’ils changent, toutes les 15 minutes';

  @override
  String get nothingWatched => 'Rien n’est surveillé pour l’instant';

  @override
  String get stopWatching => 'Arrêter la surveillance';

  @override
  String get watchFolder => 'Surveiller un dossier';

  @override
  String get checkNow => 'Vérifier maintenant';

  @override
  String fileTooBig(String name, String size) {
    return '$name fait $size — la limite est de 25 Mo';
  }

  @override
  String fileAdded(String name) {
    return '$name est maintenant dans le coffre-fort';
  }

  @override
  String savedTo(String path) {
    return 'Enregistré dans $path';
  }

  @override
  String removeNamed(String name) {
    return 'Retirer $name ?';
  }

  @override
  String get removeFileHint =>
      'Il disparaît du coffre-fort. Les anciennes sauvegardes le conservent.';

  @override
  String get remove => 'Retirer';

  @override
  String get noFilesYet =>
      'Aucun fichier pour l’instant — ajoutez des codes de récupération, des clés ou des scans';

  @override
  String get saveToDisk => 'Enregistrer sur le disque';

  @override
  String forWindow(String window) {
    return 'Pour « $window »';
  }

  @override
  String get dismiss => 'Ignorer';

  @override
  String get noBackupYet =>
      'Pas encore de sauvegarde — elle a lieu au premier enregistrement';

  @override
  String lastBackup(String ago) {
    return 'Dernière sauvegarde $ago';
  }

  @override
  String backedUpTo(String ago, String targets) {
    return 'Sauvegardé $ago — $targets';
  }

  @override
  String driveProblem(String problem) {
    return 'Google Drive : $problem';
  }

  @override
  String driveSynced(String ago) {
    return 'Google Drive : synchronisé $ago';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count éléments',
      one: '$count élément',
    );
    return '$_temp0';
  }

  @override
  String get select => 'Sélectionner';

  @override
  String get typeCode => 'Taper le code dans la fenêtre précédente';

  @override
  String get typeLogin => 'Taper le nom d’utilisateur et le mot de passe';

  @override
  String get copyPassword => 'Copier le mot de passe';

  @override
  String get save => 'Enregistrer';

  @override
  String get off => 'Désactivé';

  @override
  String get synced => 'Synchronisé';

  @override
  String get alreadyInSync => 'Déjà synchronisé';

  @override
  String get fillHostFirst => 'Indiquez d’abord l’hôte';

  @override
  String get fillUserFirst => 'Indiquez d’abord l’utilisateur';

  @override
  String get pickKeyFirst => 'Choisissez d’abord votre fichier de clé privée';

  @override
  String noFileAt(String path) {
    return 'Aucun fichier à l’emplacement $path';
  }

  @override
  String serverUnreachable(String host, String port) {
    return 'Impossible de joindre $host sur le port $port. Vérifiez l’adresse, le port et que le serveur est bien en marche.';
  }

  @override
  String serverRefusedKey(String user) {
    return 'Le serveur a refusé cette clé pour l’utilisateur $user. Vérifiez que la clé publique correspondante se trouve dans son authorized_keys.';
  }

  @override
  String get notAPrivateKey =>
      'Ce fichier n’est pas une clé privée utilisable.';

  @override
  String cannotWriteFolder(String folder) {
    return 'Connecté, mais impossible d’écrire dans « $folder ». Choisissez un autre dossier.';
  }

  @override
  String get driveNotInBuild =>
      'Google Drive n’est pas configuré dans cette version.';

  @override
  String get setPasswordFirst =>
      'Définissez d’abord un mot de passe principal — un nouvel appareil en a besoin pour ouvrir le coffre-fort.';

  @override
  String get foldersOnComputer => 'Dossiers sur cet ordinateur';

  @override
  String folderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dossiers',
      one: '$count dossier',
    );
    return '$_temp0';
  }

  @override
  String folderCountCopied(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dossiers — dernière copie $time',
      one: '$count dossier — dernière copie $time',
    );
    return '$_temp0';
  }

  @override
  String get yourServer => 'Votre serveur';

  @override
  String get noFolders => 'Aucun dossier — les copies locales sont désactivées';

  @override
  String get addFolder => 'Ajouter un dossier';

  @override
  String get serverHint =>
      'La même copie part par SFTP vers une machine qui vous appartient. Le fichier reste chiffré, le serveur ne voit donc que des octets. Laissez l’hôte vide pour ignorer cette étape.';

  @override
  String get host => 'Hôte';

  @override
  String get port => 'Port';

  @override
  String get user => 'Utilisateur';

  @override
  String get privateKeyFile => 'Fichier de clé privée';

  @override
  String get chooseFile => 'Choisir un fichier';

  @override
  String get serverFolder => 'Dossier sur le serveur';

  @override
  String get testConnection => 'Tester la connexion';

  @override
  String get notReachable => 'Injoignable pour le moment';

  @override
  String get enterCodeKey =>
      'Saisissez la clé du code de double authentification';

  @override
  String get twoFactorCode => 'Code de double authentification';

  @override
  String get newEntryTitle => 'Nouvelle entrée';

  @override
  String get editEntry => 'Modifier l’entrée';

  @override
  String get name => 'Nom';

  @override
  String get key => 'Clé';

  @override
  String get keyHint =>
      'Collez la clé de configuration ou le lien otpauth:// complet';

  @override
  String get note => 'Note';

  @override
  String get addresses => 'Adresses';

  @override
  String get codeNotUsedYet =>
      'Utilisé nulle part pour l’instant. Il s’épingle tout seul la première fois que vous l’utilisez sur un site, ou épinglez-le depuis un identifiant.';

  @override
  String get noAddress => 'aucune adresse';

  @override
  String get unpin => 'Désépingler';

  @override
  String get addAddress => 'Ajouter une adresse';

  @override
  String get title => 'Titre';

  @override
  String get noName => '(sans nom)';

  @override
  String get none => 'Aucun';

  @override
  String get choose => 'Choisir';

  @override
  String get group => 'Groupe';

  @override
  String get groupHint => 'Choisissez-en un ou tapez un nouveau nom';

  @override
  String get driveTabConnected =>
      'Keyhold est connecté à Google Drive. Vous pouvez fermer cet onglet.';

  @override
  String get driveTabNotConnected =>
      'Google Drive n’a pas été connecté. Vous pouvez fermer cet onglet.';

  @override
  String get signInTooLong =>
      'La connexion à Google a pris trop de temps — réessayez';

  @override
  String get signInCancelled => 'La connexion à Google a été annulée';

  @override
  String get noOfflineAccess =>
      'Google n’a pas autorisé l’accès hors connexion';

  @override
  String get noInternet => 'Aucune connexion Internet';

  @override
  String get wrongMasterPassword => 'Mot de passe principal incorrect';

  @override
  String driveRefusedDownload(String status) {
    return 'Google Drive a refusé le téléchargement ($status)';
  }

  @override
  String driveRefusedUpload(String status) {
    return 'Google Drive a refusé l’envoi ($status)';
  }

  @override
  String driveAnswered(String status) {
    return 'Google Drive a répondu $status';
  }

  @override
  String get driveSignInAgain =>
      'Google Drive vous demande de vous reconnecter';

  @override
  String get driveNotConnectedError => 'Google Drive n’est pas connecté';

  @override
  String get driveAccessEnded =>
      'L’accès à Google Drive a pris fin — reconnectez-le';

  @override
  String signInFailed(String status) {
    return 'Échec de la connexion à Google ($status)';
  }

  @override
  String get dupNewest => 'le plus récent';

  @override
  String get dupSamePassword => 'même mot de passe que le plus récent';

  @override
  String get dupDifferentPassword => 'mot de passe différent';

  @override
  String get noUsername => '(sans nom d’utilisateur)';

  @override
  String duplicateNote(String username, String password, String day) {
    return '$username · $password · modifié le $day';
  }

  @override
  String get fileEmpty => 'Le fichier est vide';

  @override
  String get noLoginColumns =>
      'Aucune colonne de nom d’utilisateur ou de mot de passe dans ce fichier';

  @override
  String get noQrOnScreen => 'Aucun code QR trouvé à l’écran';

  @override
  String get noQrInImage => 'Aucun code QR trouvé dans cette image';

  @override
  String get qrNotTwoFactor =>
      'Ce code QR n’est pas un code de double authentification';

  @override
  String get exportQrEmpty => 'Le code QR d’export est vide';

  @override
  String get exportQrUnreadable => 'Impossible de lire ce code QR d’export';

  @override
  String serverWritable(String account) {
    return 'Connecté en tant que $account, le dossier est accessible en écriture';
  }

  @override
  String get openKeyhold => 'Ouvrir Keyhold';

  @override
  String get quit => 'Quitter';

  @override
  String codesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count trouvés',
      one: '$count trouvé',
    );
    return '$_temp0';
  }

  @override
  String codesUnsupported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count utilisent un type de code que Keyhold ne sait pas encore générer',
      one:
          '$count utilise un type de code que Keyhold ne sait pas encore générer',
    );
    return '$_temp0';
  }

  @override
  String savedAs(String name) {
    return 'Enregistré sous $name';
  }

  @override
  String savedCodes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count codes enregistrés',
      one: '$count code enregistré',
    );
    return '$_temp0';
  }

  @override
  String get images => 'Images';

  @override
  String get addCodes => 'Ajouter des codes de double authentification';

  @override
  String get saveAll => 'Tout enregistrer';

  @override
  String get qrHintPhone =>
      'Pointez l’appareil photo vers le code QR qu’un site affiche quand vous activez la double authentification, ou vers l’export de Google Authenticator (Transférer des comptes → Exporter).';

  @override
  String get qrHintComputer =>
      'Affichez le code QR à l’écran et scannez-le. Il peut s’agir du code qu’un site affiche quand vous activez la double authentification, ou de l’export de Google Authenticator (Transférer des comptes → Exporter). Une photo du code fonctionne aussi.';

  @override
  String get qrMicrosoftHint =>
      'Microsoft Authenticator ne peut pas exporter ses codes — désactivez puis réactivez la double authentification sur chaque site et scannez le nouveau code ici.';

  @override
  String get scanCamera => 'Scanner avec l’appareil photo';

  @override
  String get scanScreen => 'Scanner l’écran';

  @override
  String get openImage => 'Ouvrir une image';

  @override
  String get saved => 'Enregistré';

  @override
  String get alreadyInKeyhold => 'Déjà dans Keyhold';

  @override
  String asName(String name) {
    return 'sous « $name »';
  }

  @override
  String get typePasswordFirst => 'Saisissez d’abord votre mot de passe';

  @override
  String get atLeast8 => 'Utilisez au moins 8 caractères';

  @override
  String get passwordsDiffer => 'Les deux mots de passe sont différents';

  @override
  String get passwordDoesNotOpen =>
      'Ce mot de passe n’ouvre pas ce coffre-fort';

  @override
  String get unlockVault => 'Déverrouiller le coffre-fort';

  @override
  String get unlockHint =>
      'Keyhold ne peut pas ouvrir ce coffre-fort tout seul sur cet appareil, par exemple après une réinstallation du système ou une copie depuis un autre ordinateur. Saisissez son mot de passe principal.';

  @override
  String get newMasterPassword => 'Nouveau mot de passe principal';

  @override
  String get repeatIt => 'Répétez-le';

  @override
  String get openVault => 'Ouvrir le coffre-fort';

  @override
  String get savePassword => 'Enregistrer le mot de passe';

  @override
  String get nobodyCanRecover =>
      'Si vous l’oubliez, seule la clé de récupération ouvre votre coffre-fort : imprimez la fiche de récupération.';

  @override
  String get groupApps => 'Applis';

  @override
  String get openKeyholdFirst =>
      'Ouvrez Keyhold une fois et saisissez le mot de passe principal, puis réessayez.';

  @override
  String pinTo(String name, String place) {
    return 'Épingler « $name » sur $place ?';
  }

  @override
  String get pinHint =>
      'Il sera alors proposé ici directement, sans recherche.';

  @override
  String get doNotAskCode => 'Ne plus demander pour ce code';

  @override
  String get notNow => 'Pas maintenant';

  @override
  String get pin => 'Épingler';

  @override
  String get savedToKeyhold => 'Enregistré dans Keyhold';

  @override
  String get passwordUpdated => 'Mot de passe mis à jour dans Keyhold';

  @override
  String get searchAllLogins => 'Rechercher dans tous les identifiants';

  @override
  String get nothingFound => 'Aucun résultat.';

  @override
  String get noLoginForSite =>
      'Aucun identifiant pour ce site. Cherchez ci-dessus, ou connectez-vous et Android proposera de l’enregistrer.';

  @override
  String get noLoginForApp =>
      'Aucun identifiant pour cette appli. Cherchez ci-dessus, ou connectez-vous et Android proposera de l’enregistrer.';

  @override
  String listening(String address) {
    return 'À l’écoute sur $address';
  }

  @override
  String get notListening =>
      'Pas à l’écoute — un autre Keyhold est peut-être déjà lancé';

  @override
  String get pairingToken => 'Jeton d’association';

  @override
  String get pairingTokenHint =>
      'Collez-le une fois dans l’extension. Seules les requêtes qui le contiennent reçoivent une réponse, et seulement de l’extension elle-même — une page web ne peut pas atteindre le coffre-fort.';

  @override
  String get tokenCopied => 'Jeton copié';

  @override
  String get copyToken => 'Copier le jeton';

  @override
  String get installIt => 'Installez-la';

  @override
  String get installChrome =>
      'Chrome ou Edge : ouvrez chrome://extensions, activez le Mode développeur, cliquez sur « Charger l’extension non empaquetée » et choisissez le dossier ci-dessous.';

  @override
  String get installFirefox =>
      'Firefox : ouvrez about:debugging#/runtime/this-firefox, cliquez sur « Charger un module complémentaire temporaire » et choisissez manifest.json dans ce dossier.';

  @override
  String get installPaste =>
      'Cliquez sur l’icône Keyhold dans la barre d’outils et collez le jeton.';

  @override
  String get newCodeShort => 'Nouveau code';

  @override
  String get free => 'Libres';

  @override
  String get searchCodes => 'Rechercher des codes';

  @override
  String get everyCodePinned =>
      'Chaque code est épinglé quelque part. Passez à « Tous » pour les voir.';

  @override
  String get noCodesFound => 'Aucun code trouvé.';

  @override
  String pinnedTo(String hosts) {
    return 'épinglé sur $hosts';
  }

  @override
  String get notPinned => 'non épinglé';

  @override
  String changedOn(String day) {
    return 'modifié le $day';
  }

  @override
  String get deleteCsvHint => 'Il contient tous les mots de passe en clair';

  @override
  String get cameraHint =>
      'Pointez vers le code QR de double authentification d’un site, ou vers l’export de Google Authenticator.';

  @override
  String get deleteThisCode => 'Supprimer ce code de double authentification ?';

  @override
  String get deleteCodeWarning =>
      'Il disparaît de tous vos appareils. Sans lui, vous ne pourrez plus vous connecter là où il sert.';

  @override
  String get deleteLoginWarning => 'Il disparaît de tous vos appareils.';

  @override
  String get recoverySheet => 'Fiche de récupération';

  @override
  String get recoveryIntro =>
      'Cette clé ouvre votre coffre-fort si vous oubliez un jour le mot de passe principal. Imprimez la fiche, recopiez-y la dernière ligne à la main et gardez-la chez vous.';

  @override
  String get print => 'Imprimer';

  @override
  String get done => 'Terminé';

  @override
  String get sheetTitle => 'Fiche de récupération Keyhold';

  @override
  String sheetMade(String date) {
    return 'Créée le $date';
  }

  @override
  String get sheetWhere => 'Où se trouve votre coffre-fort';

  @override
  String sheetDrive(String email) {
    return 'Google Drive de $email, dossier « Keyhold »';
  }

  @override
  String sheetFolders(String folders) {
    return 'Copies dans les dossiers : $folders';
  }

  @override
  String sheetServer(String host) {
    return 'Copies sur le serveur $host';
  }

  @override
  String get sheetOnlyHere =>
      'Uniquement sur cet appareil. Activez une sauvegarde dans Keyhold.';

  @override
  String get sheetSteps => 'Sur un nouvel ordinateur ou téléphone';

  @override
  String get sheetStep1 => 'Installez Keyhold : galusz.github.io/keyhold';

  @override
  String get sheetStep2 =>
      'Choisissez « Ouvrir mon coffre-fort », puis « Depuis Google Drive » (ou « Depuis un fichier (.khd) » si vous avez une copie).';

  @override
  String get sheetStep3 =>
      'Saisissez cette clé de récupération à la place du mot de passe principal. Choisissez ensuite un nouveau mot de passe principal.';

  @override
  String get sheetKeepSafe =>
      'Toute personne qui a cette fiche complétée peut ouvrir votre coffre-fort. Rangez-la comme un double des clés de la maison.';

  @override
  String get sheetDriveNoEmail => 'Google Drive, dossier « Keyhold »';

  @override
  String get noBackupPlaces =>
      'Aucun dossier de sauvegarde, serveur ni Google Drive : le coffre-fort n’est que sur cet ordinateur. Cliquez pour en configurer un.';

  @override
  String get deleteVault => 'Supprimer le coffre-fort';

  @override
  String get deleteVaultFolders =>
      'Supprimer aussi les copies dans les dossiers de sauvegarde';

  @override
  String get deleteVaultSure => 'Supprimer le coffre-fort définitivement ?';

  @override
  String get deleteVaultSureHint => 'Cette action est irréversible.';

  @override
  String get recoveryGate =>
      'Saisissez votre mot de passe principal pour voir la clé de récupération.';

  @override
  String get showKey => 'Afficher la clé';

  @override
  String get recoveryCopyRow =>
      'Recopiez cette ligne à la main sur la fiche imprimée';

  @override
  String get checkRow =>
      'Puis saisissez la dernière ligne telle que vous l’avez écrite sur la fiche';

  @override
  String get check => 'Vérifier';

  @override
  String get rowMatches => 'Elle correspond. Rangez la fiche en lieu sûr.';

  @override
  String get rowDiffers =>
      'Elle ne correspond pas. Comparez la dernière ligne avec l’écran et corrigez-la sur la fiche.';

  @override
  String get sheetKeyLabel => 'Clé de récupération';

  @override
  String get sheetCopyRow =>
      'Recopiez ici à la main la dernière ligne affichée à l’écran de Keyhold.';

  @override
  String get orRecoveryCode =>
      'Oublié ? Saisissez plutôt la clé de récupération inscrite sur votre fiche.';

  @override
  String get newPasswordAfterKey =>
      'La clé de récupération a ouvert votre coffre-fort. Choisissez un nouveau mot de passe principal : il remplacera celui que vous avez oublié sur tous vos appareils.';

  @override
  String get otherVaultTitle => 'Copies d’un autre coffre-fort';

  @override
  String otherVaultHint(String when) {
    return 'Ce dossier contient déjà des copies d’un autre coffre-fort Keyhold (la plus récente du $when). L’ouvrir pour la consulter ? Votre coffre-fort reste tel quel.';
  }

  @override
  String get copyPasswordTitle => 'Mot de passe principal de cette copie';

  @override
  String get copyNotOpened =>
      'La copie ne s’est pas ouverte : mauvais mot de passe ou mauvaise clé de récupération, ou ce n’est pas un coffre-fort Keyhold.';

  @override
  String copyTitle(String name) {
    return 'Copie : $name';
  }

  @override
  String get copyReadOnly =>
      'Consultation seulement : rien ici ne modifie votre coffre-fort. Vous pouvez y ajouter une entrée à la fois.';

  @override
  String get myVault => 'Mon coffre-fort';

  @override
  String get vaultTab => 'Coffre-fort';

  @override
  String get syncTab => 'Synchro';

  @override
  String get copiesTab => 'Sauvegardes';

  @override
  String get startHint =>
      'Vos mots de passe et codes de double authentification dans un seul coffre-fort : sur votre ordinateur, votre téléphone et dans votre navigateur.';

  @override
  String get createVault => 'Créer un nouveau coffre-fort';

  @override
  String get openMyVault => 'Ouvrir mon coffre-fort';

  @override
  String get newVault => 'Nouveau coffre-fort';

  @override
  String get vaultName => 'Nom du coffre-fort';

  @override
  String get newVaultHint =>
      'Le mot de passe principal ouvre ce coffre-fort sur chacun de vos appareils : ordinateur, téléphone et navigateur. Keyhold ne peut pas le récupérer ; la clé de récupération que vous recevrez ensuite, si.';

  @override
  String get sealHint =>
      'Votre coffre-fort n’a pas encore de mot de passe principal. Définissez-le maintenant : il ouvre ce coffre-fort sur vos autres appareils et dans le navigateur.';

  @override
  String get createVaultButton => 'Créer le coffre-fort';

  @override
  String get forgotPassword => 'Mot de passe oublié ?';

  @override
  String get usePassword => 'Utiliser le mot de passe principal';

  @override
  String get recoveryKey => 'Clé de récupération';

  @override
  String get recoveryKeyFieldHint =>
      'Les 36 caractères de votre fiche de récupération ; les espaces ne comptent pas.';

  @override
  String get openVaultTitle => 'Ouvrir un coffre-fort';

  @override
  String get openVaultHint =>
      'Le coffre-fort s’ouvre tel qu’il est. Il n’est jamais fusionné avec un autre coffre-fort.';

  @override
  String get fromDrive => 'Depuis Google Drive';

  @override
  String get fromDriveHint =>
      'Connectez-vous à Google, puis saisissez le mot de passe principal du coffre-fort.';

  @override
  String fromDriveAs(String email) {
    return '$email : saisissez le mot de passe principal du coffre-fort.';
  }

  @override
  String get fromFile => 'Depuis un fichier (.khd)';

  @override
  String get fromFileHint =>
      'Une copie d’un dossier de sauvegarde, d’une clé USB ou d’un ancien ordinateur.';

  @override
  String get closedHere => 'Ouverts auparavant sur cet appareil';

  @override
  String closedOn(String date) {
    return 'fermé le $date';
  }

  @override
  String get closedVaultGone =>
      'Le fichier de ce coffre-fort n’est plus sur cet appareil.';

  @override
  String get typeVaultPassword =>
      'Saisissez le mot de passe principal du coffre-fort à ouvrir. Keyhold l’essaie sur chaque coffre-fort de votre Google Drive.';

  @override
  String lookingForVault(int at, int of) {
    return 'Recherche de votre coffre-fort : $at sur $of';
  }

  @override
  String get noVaultInDrive =>
      'Il n’y a pas encore de coffre-fort Keyhold dans ce Google Drive.';

  @override
  String get noVaultMatches =>
      'Aucun coffre-fort de votre Google Drive ne s’ouvre avec ce mot de passe.';

  @override
  String get sameVaultFile =>
      'Ce fichier est une copie du coffre-fort déjà ouvert. Pour en reprendre des entrées, passez par Sauvegardes, puis Consulter une copie.';

  @override
  String fileVaultPassword(String name) {
    return 'Saisissez le mot de passe principal de $name.';
  }

  @override
  String get driveFileUnreadable =>
      'Le fichier de ce coffre-fort dans Google Drive est illisible. Keyhold le laisse tel quel.';

  @override
  String get vaultInfoHint =>
      'Ce coffre-fort s’ouvre avec son mot de passe principal sur chaque appareil. Si vous oubliez le mot de passe, la clé de récupération ouvre le coffre-fort et vous en choisissez un nouveau.';

  @override
  String get recoveryKeyHint =>
      'Affichée et imprimée après le mot de passe principal';

  @override
  String get otherVaults => 'Autres coffres-forts';

  @override
  String get openOtherVault => 'Ouvrir un autre coffre-fort';

  @override
  String get openOtherVaultHint =>
      'Depuis Google Drive, un fichier ou cet appareil';

  @override
  String get createNewVaultHint =>
      'Vide, avec son propre mot de passe principal';

  @override
  String closeVaultTitle(String name) {
    return 'Fermer « $name » sur cet appareil ?';
  }

  @override
  String get closeVaultHint =>
      'Rien n’est supprimé : il reste dans Google Drive, dans les sauvegardes et dans la liste des coffres-forts de cet appareil. Il s’ouvre à nouveau avec son mot de passe principal.';

  @override
  String get continueLabel => 'Continuer';

  @override
  String get renameVault => 'Renommer le coffre-fort';

  @override
  String get reviewCopy => 'Consulter une copie';

  @override
  String get driveVaultHint =>
      'Garde ce coffre-fort dans son propre fichier chiffré, dans un dossier « Keyhold » de votre Google Drive. Vos autres appareils l’ouvrent avec son mot de passe principal. Plusieurs coffres-forts peuvent partager un même Google Drive sans jamais se mélanger. Google ne peut pas les lire.';

  @override
  String get foldersSlotsHint =>
      'Chaque enregistrement met à jour jusqu’à 7 copies du coffre-fort dans chaque dossier : la plus récente, puis d’environ une heure, un jour, une semaine, un mois, trois mois et un an.';

  @override
  String get deleteVaultHereHint =>
      'Le coffre-fort est effacé de cet appareil : mots de passe, codes de double authentification et fichiers. Les coffres-forts ouverts ici auparavant restent. Keyhold affiche ensuite son écran d’accueil.';

  @override
  String get deleteVaultDriveMine =>
      'Le supprimer aussi de Google Drive (les autres coffres-forts restent)';

  @override
  String get vaultDeletedHere => 'Le coffre-fort est supprimé.';

  @override
  String get menu => 'Menu';

  @override
  String get importTitle => 'Importer';

  @override
  String get importMenuHint =>
      'Mots de passe et codes d’autres apps ou d’un autre coffre-fort';

  @override
  String get importAnyHint =>
      'Choisissez un export d’un autre gestionnaire de mots de passe ou d’une app d’authentification, une base KeePass ou un autre coffre-fort Keyhold. Keyhold reconnaît le fichier tout seul, et vous cochez ce qui entre.';

  @override
  String get importReading => 'Lecture du fichier…';

  @override
  String importPasswordTitle(String format) {
    return 'Mot de passe de ce fichier $format';
  }

  @override
  String get importWrongPassword => 'Ce mot de passe n’ouvre pas ce fichier.';

  @override
  String get importUnknown =>
      'Keyhold ne reconnaît pas ce fichier. Exportez-le de nouveau depuis l’autre app, en CSV ou en JSON.';

  @override
  String importNothing(String format) {
    return '$format : ce fichier ne contient rien que Keyhold puisse garder.';
  }

  @override
  String get keePassUnsupported =>
      'Cette base KeePass utilise quelque chose que Keyhold ne sait pas ouvrir (un fichier clé ou le chiffrement Twofish). Exportez-la depuis KeePass en CSV.';

  @override
  String get bitwardenAccountLocked =>
      'Cet export Bitwarden ne s’ouvre qu’avec votre compte Bitwarden. Exportez de nouveau en JSON, protégé par mot de passe ou non chiffré.';

  @override
  String get otpLinks => 'liens otpauth';

  @override
  String get importPickHint =>
      'Cochez ce qui doit entrer dans votre coffre-fort. Ce que vous avez déjà reste décoché.';

  @override
  String codesLeftOut(int count) {
    return 'Codes laissés de côté : $count. Keyhold ne produit que des codes à 6 chiffres toutes les 30 secondes, pas 8 chiffres, 60 secondes, compteurs ni Steam.';
  }

  @override
  String recordsLeftOut(int count) {
    return 'Éléments laissés de côté : $count (vides, cartes et identités).';
  }

  @override
  String get selectAll => 'Tout sélectionner';

  @override
  String get alreadyInVault => 'déjà dans votre coffre-fort';

  @override
  String addSelected(int count) {
    return 'Ajouter ($count)';
  }

  @override
  String addedCount(int count) {
    return 'Ajouté au coffre-fort : $count';
  }

  @override
  String get deletePlainFile => 'Supprimer le fichier ensuite';

  @override
  String get importPasswordsFrom => 'Mots de passe';

  @override
  String get importPasswordsList =>
      'Chrome, Edge, Firefox et Safari (CSV), Bitwarden (CSV ou JSON), 1Password (.1pux ou CSV), KeePass et KeePassXC (.kdbx ou CSV), LastPass, Proton Pass, NordPass et Dashlane (CSV), et un autre coffre-fort Keyhold (.khd).';

  @override
  String get importCodesFrom => 'Codes de double authentification';

  @override
  String get importCodesList =>
      'Aegis (.json), 2FAS (.2fas), Ente Auth, FreeOTP+ et andOTP, et tout fichier de liens otpauth://. Google Authenticator : affichez son QR code d’export et utilisez le bouton QR code de Keyhold.';

  @override
  String get importNoExport =>
      'Microsoft Authenticator et Authy ne laissent pas sortir les codes : réactivez la double authentification sur chaque service et scannez son nouveau QR code.';

  @override
  String get foldersOnPhone => 'Dossiers sur ce téléphone';

  @override
  String get phoneFoldersHint =>
      'Choisissez un dossier du téléphone, de la carte mémoire ou d’une app comme Nextcloud ou OneDrive qui laisse Android y enregistrer.';

  @override
  String get copiesPlaces => 'Dossiers et votre serveur';

  @override
  String get shareVaultCopy => 'Partager une copie du coffre-fort';

  @override
  String get shareVaultHint =>
      'Vous pouvez aussi envoyer le fichier par e-mail ou le garder dans Fichiers : il ne s’ouvre qu’avec le mot de passe principal ou la clé de récupération.';

  @override
  String confirmFill(String name) {
    return 'Confirmez pour remplir $name';
  }

  @override
  String get guardedSwitch => 'Demander l\'empreinte au remplissage';

  @override
  String get guardedSwitchHint =>
      'Empreinte sur le téléphone, Windows Hello sur l\'ordinateur, avant que le mot de passe ou le code n\'aille dans une page ou une appli.';

  @override
  String get helloSwitch => 'Ouvrir Keyhold avec Windows Hello';

  @override
  String get helloSwitchHint =>
      'Visage, empreinte ou code PIN Windows. Se verrouille après 5 minutes sans utilisation. Le remplissage dans le navigateur continue de fonctionner.';

  @override
  String get helloConfirmHint => 'Confirmez avec Windows Hello';

  @override
  String get lockedInstead =>
      'Ni mot de passe ni clé de récupération ? Ouvrez un autre coffre-fort ou créez-en un nouveau. Celui-ci est mis de côté, pas supprimé.';

  @override
  String setAsideOn(String date) {
    return 'mis de côté le $date, s’ouvre avec son mot de passe principal';
  }

  @override
  String get doneAfterCheck =>
      '« Terminé » s’active dès que la dernière ligne correspond.';

  @override
  String get lastCopyFailed => 'La dernière copie a échoué';

  @override
  String get guardOpenHint =>
      'Déverrouiller les entrées protégées pour 5 minutes';

  @override
  String get saveChanges => 'Enregistrer les modifications ?';

  @override
  String get dontSave => 'Ne pas enregistrer';
}
