// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get cancel => 'Cancelar';

  @override
  String get open => 'Abrir';

  @override
  String get delete => 'Eliminar';

  @override
  String get copy => 'Copiar';

  @override
  String get edit => 'Editar';

  @override
  String get add => 'Añadir';

  @override
  String get search => 'Buscar';

  @override
  String get settings => 'Configuración';

  @override
  String get change => 'Cambiar';

  @override
  String get connect => 'Conectar';

  @override
  String get disconnect => 'Desconectar';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get noTitle => '(sin título)';

  @override
  String get code => 'Código';

  @override
  String get codes => 'Códigos';

  @override
  String get username => 'Nombre de usuario';

  @override
  String get password => 'Contraseña';

  @override
  String get address => 'Dirección';

  @override
  String get notes => 'Notas';

  @override
  String get duplicates => 'Duplicados';

  @override
  String get masterPassword => 'Contraseña maestra';

  @override
  String get setMasterPassword => 'Configurar contraseña maestra';

  @override
  String copied(String what) {
    return 'Copiado: $what';
  }

  @override
  String get fingerprintTitle => 'Caja fuerte Keyhold';

  @override
  String get fingerprintUnlockHint =>
      'Desbloquea para ver tus contraseñas y códigos';

  @override
  String get fingerprintConfirmHint => 'Confirma con tu huella digital';

  @override
  String driveNotConnected(String error) {
    return 'No se pudo conectar Google Drive: $error';
  }

  @override
  String get masterPasswordOfVault => 'Contraseña maestra de tu caja fuerte';

  @override
  String get masterPasswordFromComputer =>
      'La que configuraste en Keyhold en tu PC';

  @override
  String get scanQr => 'Escanear un código QR';

  @override
  String get scanQrHint =>
      'Código de dos factores de un sitio web o una exportación de Google Authenticator';

  @override
  String get newCode => 'Nuevo código de dos factores';

  @override
  String get newCodeHint => 'Escribe la clave de configuración a mano';

  @override
  String get newLogin => 'Nuevo inicio de sesión';

  @override
  String get locked => 'Keyhold está bloqueado';

  @override
  String get everything => 'Todo';

  @override
  String get noCodesYet =>
      'Aún no hay códigos de dos factores — toca + para escanear uno';

  @override
  String get nothingYet => 'Aún no hay nada aquí';

  @override
  String get justNow => 'hace un momento';

  @override
  String minutesAgo(int count) {
    return 'hace $count min';
  }

  @override
  String hoursAgo(int count) {
    return 'hace $count h';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count días',
      one: 'hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String get notBackedUp =>
      'Sin copia de seguridad — toca para conectar Google Drive';

  @override
  String get backingUp => 'Haciendo copia…';

  @override
  String backupFailed(String error) {
    return 'Falló la copia de seguridad: $error';
  }

  @override
  String get waitingFirstBackup => 'Esperando la primera copia de seguridad';

  @override
  String backedUpToDrive(String ago) {
    return 'Copia guardada en Google Drive $ago';
  }

  @override
  String get phoneWelcome =>
      'Tus contraseñas y códigos de dos factores — la misma caja fuerte que en tu PC, sincronizada a través de tu propio Google Drive.';

  @override
  String get connectDrive => 'Conectar Google Drive';

  @override
  String get startEmpty => 'Empezar con una caja fuerte vacía';

  @override
  String codeSeconds(int seconds) {
    return 'Código ($seconds s)';
  }

  @override
  String get driveOnlyPhone =>
      'Sin conectar — la caja fuerte solo está en este teléfono.';

  @override
  String connectedAs(String email) {
    return 'Conectado como $email';
  }

  @override
  String connectedAsSynced(String email, String time) {
    return 'Conectado como $email — última sincronización $time';
  }

  @override
  String get syncNow => 'Sincronizar ahora';

  @override
  String get fingerprintLock => 'Bloqueo con huella digital';

  @override
  String get fingerprintSwitch => 'Abrir Keyhold con la huella digital';

  @override
  String get fingerprintSwitchHint =>
      'Se bloquea al apagarse la pantalla o tras un minuto fuera. Las sugerencias bajo los campos de inicio de sesión siguen funcionando.';

  @override
  String get fillingPasswords => 'Rellenar contraseñas';

  @override
  String get fillerOn =>
      'Keyhold rellena inicios de sesión en apps y navegadores: toca \"Keyhold\" bajo un campo de inicio de sesión. En Chrome activa también Configuración → Servicios de autocompletar → Autocompletar con otro servicio.';

  @override
  String get fillerOff =>
      'Deja que Keyhold rellene inicios de sesión y códigos de dos factores en apps y navegadores.';

  @override
  String get fillWithKeyhold => 'Rellenar contraseñas con Keyhold';

  @override
  String get passwordSetPhone =>
      'Configurada. Abre esta caja fuerte en un dispositivo nuevo.';

  @override
  String get passwordNotSetPhone =>
      'Sin configurar. Sin ella, un dispositivo nuevo no puede abrir la caja fuerte.';

  @override
  String get deleteThisLogin => '¿Eliminar este inicio de sesión?';

  @override
  String deleteNamed(String name) {
    return '¿Eliminar $name?';
  }

  @override
  String get noDuplicatesLeft => 'No quedan duplicados.';

  @override
  String get groupWeb => 'Web';

  @override
  String get groupLocal => 'Red local';

  @override
  String get groupServers => 'Servidores';

  @override
  String get filterAll => 'Todos';

  @override
  String get filter2fa => '2FA';

  @override
  String get filterPasswords => 'Contraseñas';

  @override
  String get filterFiles => 'Archivos';

  @override
  String get groups => 'Grupos';

  @override
  String get noGroup => 'Sin grupo';

  @override
  String moveCountToGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mover $count elementos a un grupo',
      one: 'Mover 1 elemento a un grupo',
    );
    return '$_temp0';
  }

  @override
  String get newGroup => 'Nuevo grupo';

  @override
  String get newGroupHint => 'Déjalo vacío para sacarlos de cualquier grupo';

  @override
  String get move => 'Mover';

  @override
  String get clearSelection => 'Borrar selección';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionados',
      one: '1 seleccionado',
    );
    return '$_temp0';
  }

  @override
  String get moveToGroup => 'Mover a un grupo';

  @override
  String get addCodesFromQr =>
      'Añadir códigos de dos factores desde un código QR';

  @override
  String get browserExtension => 'Extensión del navegador';

  @override
  String get backup => 'Copia de seguridad';

  @override
  String get importCsv => 'Importar desde CSV';

  @override
  String get changeMasterPassword => 'Cambiar contraseña maestra';

  @override
  String get addFile => 'Añadir archivo';

  @override
  String get newEntry => 'Nuevo';

  @override
  String get checking => 'Comprobando…';

  @override
  String get notCheckedYet => 'Aún sin comprobar';

  @override
  String filesNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuevos',
      one: '1 nuevo',
    );
    return '$_temp0';
  }

  @override
  String filesChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cambiados',
      one: '1 cambiado',
    );
    return '$_temp0';
  }

  @override
  String filesSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count omitidos',
      one: '1 omitido',
    );
    return '$_temp0';
  }

  @override
  String checkedNothingChanged(String when) {
    return 'Comprobado $when — sin cambios';
  }

  @override
  String checkedWith(String when, String changes) {
    return 'Comprobado $when — $changes';
  }

  @override
  String get watchedHint =>
      'Vigilados — se copian a la caja fuerte cuando cambian, cada 15 minutos';

  @override
  String get nothingWatched => 'Aún no se vigila nada';

  @override
  String pathNotFound(String path) {
    return '$path — no encontrado';
  }

  @override
  String get stopWatching => 'Dejar de vigilar';

  @override
  String get watchFolder => 'Vigilar carpeta';

  @override
  String get watchFile => 'Vigilar archivo';

  @override
  String get checkNow => 'Comprobar ahora';

  @override
  String fileTooBig(String name, String size) {
    return '$name ocupa $size — el límite es 25 MB';
  }

  @override
  String fileAdded(String name) {
    return '$name ya está en la caja fuerte';
  }

  @override
  String savedTo(String path) {
    return 'Guardado en $path';
  }

  @override
  String removeNamed(String name) {
    return '¿Quitar $name?';
  }

  @override
  String get removeFileHint =>
      'Desaparece de la caja fuerte. Las copias de seguridad anteriores aún lo conservan.';

  @override
  String get remove => 'Quitar';

  @override
  String get noFilesYet =>
      'Aún no hay archivos — añade códigos de recuperación, claves o escaneos';

  @override
  String get saveToDisk => 'Guardar en el disco';

  @override
  String forWindow(String window) {
    return 'Para \"$window\"';
  }

  @override
  String get dismiss => 'Descartar';

  @override
  String get noBackupYet =>
      'Aún no hay copia de seguridad — se hace al guardar por primera vez';

  @override
  String lastBackup(String ago) {
    return 'Última copia $ago';
  }

  @override
  String backedUpTo(String ago, String targets) {
    return 'Copia guardada $ago — $targets';
  }

  @override
  String get driveNeedsPassword =>
      'Google Drive: abre Copia de seguridad y escribe la contraseña maestra';

  @override
  String driveProblem(String problem) {
    return 'Google Drive: $problem';
  }

  @override
  String driveSynced(String ago) {
    return 'Google Drive: sincronizado $ago';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count elementos',
      one: '1 elemento',
    );
    return '$_temp0';
  }

  @override
  String get select => 'Seleccionar';

  @override
  String get typeCode => 'Escribir el código en la ventana anterior';

  @override
  String get typeLogin => 'Escribir usuario y contraseña';

  @override
  String get copyPassword => 'Copiar contraseña';

  @override
  String get save => 'Guardar';

  @override
  String get off => 'Desactivado';

  @override
  String onWith(String detail) {
    return 'Activado — $detail';
  }

  @override
  String get join => 'Unirse';

  @override
  String get synced => 'Sincronizado';

  @override
  String get alreadyInSync => 'Ya está sincronizado';

  @override
  String get fillHostFirst => 'Primero escribe el host';

  @override
  String get fillUserFirst => 'Primero escribe el usuario';

  @override
  String get pickKeyFirst => 'Primero elige tu archivo de clave privada';

  @override
  String noFileAt(String path) {
    return 'No hay ningún archivo en $path';
  }

  @override
  String serverUnreachable(String host, String port) {
    return 'No se puede conectar con $host en el puerto $port. Revisa la dirección, el puerto y si el servidor está encendido.';
  }

  @override
  String serverRefusedKey(String user) {
    return 'El servidor rechazó esta clave para el usuario $user. Asegúrate de que la clave pública correspondiente esté en su authorized_keys.';
  }

  @override
  String get notAPrivateKey => 'Ese archivo no es una clave privada válida.';

  @override
  String cannotWriteFolder(String folder) {
    return 'Sesión iniciada, pero no se puede escribir en \"$folder\". Elige otra carpeta.';
  }

  @override
  String get driveHoldsVault =>
      'Google Drive ya tiene una caja fuerte de Keyhold. Para unirte a ella necesitas su contraseña maestra.';

  @override
  String get masterPasswordOfDriveVault =>
      'Contraseña maestra de la caja fuerte en Google Drive';

  @override
  String get driveHint =>
      'Guarda la caja fuerte cifrada en una carpeta \"Keyhold\" de tu propio Google Drive, para que tus otros dispositivos estén sincronizados y no pierdas nada si pierdes tu PC. Google no puede leerla.';

  @override
  String get driveNotInBuild =>
      'Google Drive no está configurado en esta versión.';

  @override
  String get setPasswordFirst =>
      'Primero configura una contraseña maestra — un dispositivo nuevo la necesita para abrir la caja fuerte.';

  @override
  String get foldersOnComputer => 'Carpetas en tu PC';

  @override
  String folderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count carpetas',
      one: '1 carpeta',
    );
    return '$_temp0';
  }

  @override
  String folderCountCopied(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count carpetas — última copia $time',
      one: '1 carpeta — última copia $time',
    );
    return '$_temp0';
  }

  @override
  String get yourServer => 'Tu servidor';

  @override
  String get foldersHint =>
      'Cada guardado deja una copia con fecha en cada carpeta y conserva las 30 últimas.';

  @override
  String get noFolders =>
      'Sin carpetas — las copias locales están desactivadas';

  @override
  String get addFolder => 'Añadir carpeta';

  @override
  String get serverHint =>
      'La misma copia va por SFTP a un equipo tuyo. El archivo sigue cifrado, así que el servidor solo ve bytes. Deja el host vacío para omitir esto.';

  @override
  String get host => 'Host';

  @override
  String get port => 'Puerto';

  @override
  String get user => 'Usuario';

  @override
  String get privateKeyFile => 'Archivo de clave privada';

  @override
  String get chooseFile => 'Elegir archivo';

  @override
  String get serverFolder => 'Carpeta en el servidor';

  @override
  String get testConnection => 'Probar conexión';

  @override
  String get notReachable => 'No accesible ahora mismo';

  @override
  String get enterCodeKey => 'Escribe la clave del código de dos factores';

  @override
  String get twoFactorCode => 'Código de dos factores';

  @override
  String get newEntryTitle => 'Nueva entrada';

  @override
  String get editEntry => 'Editar entrada';

  @override
  String get name => 'Nombre';

  @override
  String get key => 'Clave';

  @override
  String get keyHint =>
      'Pega la clave de configuración o el enlace otpauth:// completo';

  @override
  String get note => 'Nota';

  @override
  String get addresses => 'Direcciones';

  @override
  String get codeNotUsedYet =>
      'Aún no se usa en ningún sitio. Se fija solo la primera vez que lo usas en un sitio, o fíjalo desde un inicio de sesión.';

  @override
  String get noAddress => 'sin dirección';

  @override
  String get unpin => 'Dejar de fijar';

  @override
  String get addAddress => 'Añadir una dirección';

  @override
  String get title => 'Título';

  @override
  String get noName => '(sin nombre)';

  @override
  String get none => 'Ninguno';

  @override
  String get choose => 'Elegir';

  @override
  String get group => 'Grupo';

  @override
  String get groupHint => 'Elige uno o escribe un nombre nuevo';

  @override
  String get driveTabConnected =>
      'Keyhold está conectado a Google Drive. Puedes cerrar esta pestaña.';

  @override
  String get driveTabNotConnected =>
      'No se pudo conectar Google Drive. Puedes cerrar esta pestaña.';

  @override
  String get signInTooLong =>
      'El inicio de sesión de Google tardó demasiado — inténtalo de nuevo';

  @override
  String get signInCancelled => 'Se canceló el inicio de sesión de Google';

  @override
  String get noOfflineAccess => 'Google no permitió el acceso sin conexión';

  @override
  String get noInternet => 'Sin conexión a Internet';

  @override
  String get wrongMasterPassword => 'Contraseña maestra incorrecta';

  @override
  String driveRefusedDownload(String status) {
    return 'Google Drive rechazó la descarga ($status)';
  }

  @override
  String driveRefusedUpload(String status) {
    return 'Google Drive rechazó la subida ($status)';
  }

  @override
  String driveAnswered(String status) {
    return 'Google Drive respondió $status';
  }

  @override
  String get driveSignInAgain =>
      'Google Drive necesita que vuelvas a iniciar sesión';

  @override
  String get driveNotConnectedError => 'Google Drive no está conectado';

  @override
  String get driveAccessEnded =>
      'El acceso a Google Drive terminó — vuelve a conectarlo';

  @override
  String signInFailed(String status) {
    return 'Falló el inicio de sesión de Google ($status)';
  }

  @override
  String get dupNewest => 'el más reciente';

  @override
  String get dupSamePassword => 'misma contraseña que el más reciente';

  @override
  String get dupDifferentPassword => 'contraseña distinta';

  @override
  String get noUsername => '(sin usuario)';

  @override
  String duplicateNote(String username, String password, String day) {
    return '$username · $password · cambiado el $day';
  }

  @override
  String get fileEmpty => 'El archivo está vacío';

  @override
  String get noLoginColumns =>
      'No se encontró ninguna columna de usuario o contraseña en este archivo';

  @override
  String get noQrOnScreen => 'No se encontró ningún código QR en la pantalla';

  @override
  String get noQrInImage => 'No se encontró ningún código QR en esta imagen';

  @override
  String get qrNotTwoFactor => 'Este código QR no es un código de dos factores';

  @override
  String get exportQrEmpty => 'El código QR de exportación está vacío';

  @override
  String get exportQrUnreadable =>
      'No se pudo leer este código QR de exportación';

  @override
  String serverWritable(String account) {
    return 'Conectado como $account, se puede escribir en la carpeta';
  }

  @override
  String get openKeyhold => 'Abrir Keyhold';

  @override
  String get quit => 'Salir';

  @override
  String codesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count encontrados',
      one: '1 encontrado',
    );
    return '$_temp0';
  }

  @override
  String codesUnsupported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count usan un tipo de código que Keyhold aún no puede generar',
      one: '1 usa un tipo de código que Keyhold aún no puede generar',
    );
    return '$_temp0';
  }

  @override
  String savedAs(String name) {
    return 'Guardado como $name';
  }

  @override
  String savedCodes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count códigos guardados',
      one: '1 código guardado',
    );
    return '$_temp0';
  }

  @override
  String get images => 'Imágenes';

  @override
  String get addCodes => 'Añadir códigos de dos factores';

  @override
  String get saveAll => 'Guardar todos';

  @override
  String get qrHintPhone =>
      'Apunta la cámara al código QR que muestra un sitio web al activar la autenticación de dos factores, o a la exportación de Google Authenticator (Transferir cuentas → Exportar cuentas).';

  @override
  String get qrHintComputer =>
      'Muestra el código QR en la pantalla y escanéalo. Puede ser el código que muestra un sitio web al activar la autenticación de dos factores, o la exportación de Google Authenticator (Transferir cuentas → Exportar cuentas). También sirve una foto del código.';

  @override
  String get qrMicrosoftHint =>
      'Microsoft Authenticator no puede exportar sus códigos — desactiva y vuelve a activar la autenticación de dos factores en cada sitio y escanea aquí el código nuevo.';

  @override
  String get scanCamera => 'Escanear con la cámara';

  @override
  String get scanScreen => 'Escanear la pantalla';

  @override
  String get openImage => 'Abrir una imagen';

  @override
  String get saved => 'Guardado';

  @override
  String get alreadyInKeyhold => 'Ya está en Keyhold';

  @override
  String asName(String name) {
    return 'como \"$name\"';
  }

  @override
  String get typePasswordFirst => 'Primero escribe tu contraseña';

  @override
  String get atLeast8 => 'Usa al menos 8 caracteres';

  @override
  String get passwordsDiffer => 'Las contraseñas no coinciden';

  @override
  String get passwordDoesNotOpen => 'Esa contraseña no abre esta caja fuerte';

  @override
  String get currentPasswordWrong =>
      'La contraseña maestra actual es incorrecta';

  @override
  String get unlockVault => 'Desbloquear caja fuerte';

  @override
  String get unlockHint =>
      'Esta caja fuerte viene de otro equipo. Escribe la contraseña maestra para abrirla aquí.';

  @override
  String get masterPasswordHint =>
      'Windows abre esta caja fuerte por ti automáticamente. La contraseña maestra te permite volver a entrar tras reinstalar, en un equipo nuevo o en tu teléfono.';

  @override
  String get currentMasterPassword => 'Contraseña maestra actual';

  @override
  String get newMasterPassword => 'Nueva contraseña maestra';

  @override
  String get repeatIt => 'Repítela';

  @override
  String get openVault => 'Abrir caja fuerte';

  @override
  String get savePassword => 'Guardar contraseña';

  @override
  String get nobodyCanRecover =>
      'Nadie puede recuperarla por ti — ni siquiera esta app. Anótala en un lugar seguro.';

  @override
  String get groupApps => 'Apps';

  @override
  String get openKeyholdFirst =>
      'Abre Keyhold una vez y escribe la contraseña maestra; luego vuelve a intentarlo.';

  @override
  String pinTo(String name, String place) {
    return '¿Fijar \"$name\" en $place?';
  }

  @override
  String get pinHint => 'Así se ofrecerá aquí al momento, sin buscarlo.';

  @override
  String get doNotAskCode => 'No volver a preguntar por este código';

  @override
  String get notNow => 'Ahora no';

  @override
  String get pin => 'Fijar';

  @override
  String get savedToKeyhold => 'Guardado en Keyhold';

  @override
  String get passwordUpdated => 'Contraseña actualizada en Keyhold';

  @override
  String get searchAllLogins => 'Buscar en todos los inicios de sesión';

  @override
  String get nothingFound => 'No se encontró nada.';

  @override
  String get noLoginForSite =>
      'Aún no hay inicio de sesión para este sitio. Busca arriba, o inicia sesión y Android te ofrecerá guardarlo.';

  @override
  String get noLoginForApp =>
      'Aún no hay inicio de sesión para esta app. Busca arriba, o inicia sesión y Android te ofrecerá guardarlo.';

  @override
  String listening(String address) {
    return 'Escuchando en $address';
  }

  @override
  String get notListening =>
      'No escucha — puede que ya se esté ejecutando otro Keyhold';

  @override
  String get pairingToken => 'Token de vinculación';

  @override
  String get pairingTokenHint =>
      'Pégalo una vez en la extensión. Solo se responde a las solicitudes que lo llevan, y solo desde la propia extensión — una página web no puede llegar a la caja fuerte.';

  @override
  String get tokenCopied => 'Token copiado';

  @override
  String get copyToken => 'Copiar token';

  @override
  String get installIt => 'Instálala';

  @override
  String get installChrome =>
      'Chrome o Edge: abre chrome://extensions, activa el Modo de desarrollador, haz clic en \"Cargar descomprimida\" y elige la carpeta de abajo.';

  @override
  String get installFirefox =>
      'Firefox: abre about:debugging#/runtime/this-firefox, haz clic en \"Cargar complemento temporal\" y elige manifest.json en esa carpeta.';

  @override
  String get installPaste =>
      'Haz clic en el icono de Keyhold en la barra de herramientas y pega el token.';

  @override
  String get newCodeShort => 'Nuevo código';

  @override
  String get free => 'Libres';

  @override
  String get searchCodes => 'Buscar códigos';

  @override
  String get everyCodePinned =>
      'Todos los códigos están fijados en algún sitio. Cambia a Todos para verlos.';

  @override
  String get noCodesFound => 'No se encontraron códigos.';

  @override
  String pinnedTo(String hosts) {
    return 'fijado en $hosts';
  }

  @override
  String get notPinned => 'sin fijar';

  @override
  String changedOn(String day) {
    return 'cambiado el $day';
  }

  @override
  String get importPasswords => 'Importar contraseñas';

  @override
  String get importHint =>
      'Exporta tus contraseñas del navegador como CSV y luego carga el archivo aquí. Sirven las exportaciones de Chrome, Edge, Firefox, Bitwarden y KeePassXC.';

  @override
  String get chooseCsv => 'Elegir archivo CSV';

  @override
  String entriesReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entradas listas',
      one: '1 entrada lista',
    );
    return '$_temp0';
  }

  @override
  String entriesReadySkipped(int count, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entradas listas',
      one: '1 entrada lista',
    );
    String _temp1 = intl.Intl.pluralLogic(
      skipped,
      locale: localeName,
      other: '$skipped filas vacías omitidas',
      one: '1 fila vacía omitida',
    );
    return '$_temp0, $_temp1';
  }

  @override
  String andMore(int count) {
    return 'y $count más';
  }

  @override
  String get deleteCsv => 'Eliminar el archivo CSV después de importar';

  @override
  String get deleteCsvHint => 'Guarda todas las contraseñas sin cifrar';

  @override
  String importEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Importar $count entradas',
      one: 'Importar 1 entrada',
    );
    return '$_temp0';
  }

  @override
  String get cameraHint =>
      'Apunta al código QR de dos factores de un sitio web, o a la exportación de Google Authenticator.';
}
