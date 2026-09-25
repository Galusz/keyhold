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
  String get connectDrive => 'Conectar Google Drive';

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
  String get unlockVault => 'Desbloquear caja fuerte';

  @override
  String get unlockHint =>
      'Esta caja fuerte viene de otro equipo. Escribe la contraseña maestra para abrirla aquí.';

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
      'Si la olvidas, solo la clave de recuperación abre tu caja fuerte: imprime la hoja de recuperación.';

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
  String get deleteCsvHint => 'Guarda todas las contraseñas sin cifrar';

  @override
  String get cameraHint =>
      'Apunta al código QR de dos factores de un sitio web, o a la exportación de Google Authenticator.';

  @override
  String get deleteThisCode => '¿Eliminar este código de dos factores?';

  @override
  String get deleteCodeWarning =>
      'Desaparece de todos tus dispositivos. Sin él no podrás iniciar sesión donde se usa.';

  @override
  String get deleteLoginWarning => 'Desaparece de todos tus dispositivos.';

  @override
  String nextCode(String code) {
    return 'siguiente $code';
  }

  @override
  String get recoverySheet => 'Hoja de recuperación';

  @override
  String get recoveryIntro =>
      'Esta clave abre tu caja fuerte si alguna vez olvidas la contraseña maestra. Imprime la hoja, copia a mano en ella la última fila y guárdala en casa.';

  @override
  String get print => 'Imprimir';

  @override
  String get done => 'Listo';

  @override
  String get sheetTitle => 'Hoja de recuperación de Keyhold';

  @override
  String sheetMade(String date) {
    return 'Creada el $date';
  }

  @override
  String get sheetWhere => 'Dónde está tu caja fuerte';

  @override
  String sheetDrive(String email) {
    return 'Google Drive de $email, carpeta \"Keyhold\"';
  }

  @override
  String sheetFolders(String folders) {
    return 'Copias en carpetas: $folders';
  }

  @override
  String sheetServer(String host) {
    return 'Copias en el servidor $host';
  }

  @override
  String get sheetOnlyHere =>
      'Solo en este dispositivo. Activa una copia de seguridad en Keyhold.';

  @override
  String get sheetSteps => 'En un equipo o teléfono nuevo';

  @override
  String get sheetStep1 => 'Instala Keyhold: galusz.github.io/keyhold';

  @override
  String get sheetStep2 => 'Conecta el mismo Google Drive en Keyhold.';

  @override
  String get sheetStep3 =>
      'Cuando Keyhold te pida la contraseña maestra, escribe esta clave de recuperación. Después elige una nueva contraseña maestra.';

  @override
  String get sheetKeepSafe =>
      'Cualquiera que tenga esta hoja completa puede abrir tu caja fuerte. Guárdala como una llave de repuesto de tu casa.';

  @override
  String get sheetDriveNoEmail => 'Google Drive, carpeta \"Keyhold\"';

  @override
  String get noBackupPlaces =>
      'Sin carpeta de copia, servidor ni Google Drive: la caja fuerte solo está en este equipo. Haz clic para configurarlo.';

  @override
  String get deleteVault => 'Eliminar la caja fuerte';

  @override
  String get deleteVaultFolders =>
      'Eliminar también las copias de las carpetas de copia de seguridad';

  @override
  String get deleteVaultSure => '¿Eliminar la caja fuerte para siempre?';

  @override
  String get deleteVaultSureHint => 'No se puede deshacer.';

  @override
  String get recoveryGate =>
      'Escribe tu contraseña maestra para ver la clave de recuperación.';

  @override
  String get showKey => 'Mostrar la clave';

  @override
  String get recoveryCopyRow => 'Copia a mano esta fila en la hoja impresa';

  @override
  String get checkRow =>
      'Después escribe la última fila tal como la anotaste en la hoja';

  @override
  String get check => 'Comprobar';

  @override
  String get rowMatches => 'Coincide. Guarda la hoja en un lugar seguro.';

  @override
  String get rowDiffers =>
      'No coincide. Compara la última fila con la pantalla y corrígela en la hoja.';

  @override
  String get sheetKeyLabel => 'Clave de recuperación';

  @override
  String get sheetCopyRow =>
      'Copia aquí a mano la última fila desde la pantalla de Keyhold.';

  @override
  String get orRecoveryCode =>
      '¿La olvidaste? Escribe en su lugar la clave de recuperación de tu hoja de recuperación.';

  @override
  String get newPasswordAfterKey =>
      'La clave de recuperación abrió tu caja fuerte. Elige una nueva contraseña maestra: sustituye a la olvidada en todos tus dispositivos.';

  @override
  String get otherVaultTitle => 'Copias de otra caja fuerte';

  @override
  String otherVaultHint(String when) {
    return 'Esta carpeta ya tiene copias de otra caja fuerte de Keyhold (la más reciente del $when). ¿Abrirla para ver su contenido? Tu caja fuerte no cambia.';
  }

  @override
  String get copyPasswordTitle => 'Contraseña maestra de esta copia';

  @override
  String get copyNotOpened =>
      'No se pudo abrir la copia: contraseña o clave de recuperación incorrecta, o no es una caja fuerte de Keyhold.';

  @override
  String copyTitle(String name) {
    return 'Copia: $name';
  }

  @override
  String get copyReadOnly =>
      'Solo para ver: aquí nada cambia tu caja fuerte. Puedes añadir entradas sueltas a tu caja fuerte.';

  @override
  String get myVault => 'Mi caja fuerte';

  @override
  String get vaultTab => 'Caja fuerte';

  @override
  String get syncTab => 'Sincronizar';

  @override
  String get copiesTab => 'Copias';

  @override
  String get startHint =>
      'Tus contraseñas y códigos de dos factores en una caja fuerte: en tu ordenador, en tu teléfono y en tu navegador.';

  @override
  String get createVault => 'Crear una caja fuerte nueva';

  @override
  String get openMyVault => 'Abrir mi caja fuerte';

  @override
  String get newVault => 'Caja fuerte nueva';

  @override
  String get vaultName => 'Nombre de la caja fuerte';

  @override
  String get newVaultHint =>
      'La contraseña maestra abre esta caja fuerte en todos tus dispositivos: ordenador, teléfono y navegador. Keyhold no puede recuperarla; la clave de recuperación que recibirás a continuación sí.';

  @override
  String get sealHint =>
      'Tu caja fuerte aún no tiene contraseña maestra. Ponla ahora: abre esta caja fuerte en tus otros dispositivos y en el navegador.';

  @override
  String get createVaultButton => 'Crear la caja fuerte';

  @override
  String get forgotPassword => '¿Olvidaste la contraseña?';

  @override
  String get usePassword => 'Usar la contraseña maestra';

  @override
  String get recoveryKey => 'Clave de recuperación';

  @override
  String get recoveryKeyFieldHint =>
      'Los 36 caracteres de tu hoja de recuperación; los espacios no importan.';

  @override
  String get openVaultTitle => 'Abrir una caja fuerte';

  @override
  String get openVaultHint =>
      'La caja fuerte se abre tal como está. Nunca se mezcla con otra caja fuerte.';

  @override
  String get fromDrive => 'Desde Google Drive';

  @override
  String get fromDriveHint =>
      'Inicia sesión en Google y escribe la contraseña maestra de la caja fuerte.';

  @override
  String fromDriveAs(String email) {
    return '$email: escribe la contraseña maestra de la caja fuerte.';
  }

  @override
  String get fromFile => 'Desde un archivo (.khd)';

  @override
  String get fromFileHint =>
      'Una copia de una carpeta de copias, de una memoria USB o de un ordenador antiguo.';

  @override
  String get closedHere => 'Abiertas antes en este dispositivo';

  @override
  String closedOn(String date) {
    return 'cerrada el $date';
  }

  @override
  String get closedVaultGone =>
      'El archivo de esa caja fuerte ya no está en este dispositivo.';

  @override
  String get typeVaultPassword =>
      'Escribe la contraseña maestra de la caja fuerte que quieres abrir. Keyhold la prueba en cada caja fuerte de tu Google Drive.';

  @override
  String lookingForVault(int at, int of) {
    return 'Buscando tu caja fuerte: $at de $of';
  }

  @override
  String get noVaultInDrive =>
      'Aún no hay ninguna caja fuerte de Keyhold en este Google Drive.';

  @override
  String get noVaultMatches =>
      'Ninguna caja fuerte de tu Google Drive se abre con esta contraseña.';

  @override
  String get sameVaultFile =>
      'Este archivo es una copia de la caja fuerte que tienes abierta. Para sacar entradas de él, usa Copias y luego Revisar una copia.';

  @override
  String fileVaultPassword(String name) {
    return 'Escribe la contraseña maestra de $name.';
  }

  @override
  String get driveFileUnreadable =>
      'No se puede leer el archivo de esta caja fuerte en Google Drive. Keyhold lo deja como está.';

  @override
  String get vaultInfoHint =>
      'Esta caja fuerte se abre con su contraseña maestra en todos los dispositivos. Si olvidas la contraseña, la clave de recuperación abre la caja fuerte y eliges una nueva.';

  @override
  String get recoveryKeyHint =>
      'Se muestra y se imprime tras la contraseña maestra';

  @override
  String get otherVaults => 'Otras cajas fuertes';

  @override
  String get openOtherVault => 'Abrir otra caja fuerte';

  @override
  String get openOtherVaultHint =>
      'Desde Google Drive, desde un archivo o desde este dispositivo';

  @override
  String get createNewVaultHint => 'Vacía, con su propia contraseña maestra';

  @override
  String closeVaultTitle(String name) {
    return '¿Cerrar \"$name\" en este dispositivo?';
  }

  @override
  String get closeVaultHint =>
      'No se borra nada: se queda en Google Drive, en las copias de seguridad y en la lista de cajas fuertes de este dispositivo. Se vuelve a abrir con su contraseña maestra.';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get renameVault => 'Cambiar el nombre de la caja fuerte';

  @override
  String get reviewCopy => 'Revisar una copia';

  @override
  String get driveVaultHint =>
      'Guarda esta caja fuerte como un archivo cifrado propio en una carpeta \"Keyhold\" de tu Google Drive. Tus otros dispositivos la abren con su contraseña maestra. Varias cajas fuertes pueden compartir un Google Drive sin mezclarse nunca. Google no puede leerlas.';

  @override
  String get foldersSlotsHint =>
      'Cada vez que guardas se actualizan hasta 7 copias de la caja fuerte en cada carpeta: la más reciente y otras de hace aproximadamente una hora, un día, una semana, un mes, tres meses y un año.';

  @override
  String get deleteVaultHereHint =>
      'La caja fuerte se borra de este dispositivo: contraseñas, códigos de dos factores y archivos. Las cajas fuertes abiertas antes aquí se quedan. Después Keyhold muestra su pantalla de inicio.';

  @override
  String get deleteVaultDriveMine =>
      'Borrarla también de Google Drive (las demás cajas fuertes se quedan)';

  @override
  String get vaultDeletedHere => 'La caja fuerte está borrada.';

  @override
  String get menu => 'Menú';

  @override
  String get importTitle => 'Importar';

  @override
  String get importMenuHint =>
      'Contraseñas y códigos de otras apps o de otra caja fuerte';

  @override
  String get importAnyHint =>
      'Elige una exportación de otro gestor de contraseñas o app de autenticación, una base de datos de KeePass u otra caja fuerte de Keyhold. Keyhold reconoce el archivo por sí mismo y tú marcas lo que entra.';

  @override
  String get importReading => 'Leyendo el archivo…';

  @override
  String importPasswordTitle(String format) {
    return 'Contraseña de este archivo de $format';
  }

  @override
  String get importWrongPassword => 'Esa contraseña no abre este archivo.';

  @override
  String get importUnknown =>
      'Keyhold no reconoce este archivo. Vuelve a exportarlo desde la otra app, como CSV o JSON.';

  @override
  String importNothing(String format) {
    return '$format: en este archivo no hay nada que Keyhold pueda guardar.';
  }

  @override
  String get keePassUnsupported =>
      'Esta base de datos de KeePass usa algo que Keyhold no puede abrir (un archivo de clave o el cifrado Twofish). Expórtala desde KeePass como CSV.';

  @override
  String get bitwardenAccountLocked =>
      'Esta exportación de Bitwarden solo se abre con tu cuenta de Bitwarden. Vuelve a exportar como JSON, protegido con contraseña o sin cifrar.';

  @override
  String get otpLinks => 'enlaces otpauth';

  @override
  String get importPickHint =>
      'Marca lo que debe entrar en tu caja fuerte. Lo que ya tienes queda sin marcar.';

  @override
  String codesLeftOut(int count) {
    return 'Códigos omitidos: $count. Keyhold solo genera códigos de 6 dígitos cada 30 segundos, no de 8 dígitos, 60 segundos, contadores ni Steam.';
  }

  @override
  String recordsLeftOut(int count) {
    return 'Registros omitidos: $count (vacíos, tarjetas e identidades).';
  }

  @override
  String get selectAll => 'Seleccionar todo';

  @override
  String get alreadyInVault => 'ya está en tu caja fuerte';

  @override
  String addSelected(int count) {
    return 'Añadir ($count)';
  }

  @override
  String addedCount(int count) {
    return 'Añadido a tu caja fuerte: $count';
  }

  @override
  String get deletePlainFile => 'Borrar el archivo después';

  @override
  String get importPasswordsFrom => 'Contraseñas';

  @override
  String get importPasswordsList =>
      'Chrome, Edge, Firefox y Safari (CSV), Bitwarden (CSV o JSON), 1Password (.1pux o CSV), KeePass y KeePassXC (.kdbx o CSV), LastPass, Proton Pass, NordPass y Dashlane (CSV), y otra caja fuerte de Keyhold (.khd).';

  @override
  String get importCodesFrom => 'Códigos de dos factores';

  @override
  String get importCodesList =>
      'Aegis (.json), 2FAS (.2fas), Ente Auth, FreeOTP+ y andOTP, y cualquier archivo con enlaces otpauth://. Google Authenticator: muestra su código QR de exportación y usa el botón de código QR de Keyhold.';

  @override
  String get importNoExport =>
      'Microsoft Authenticator y Authy no dejan salir los códigos: vuelve a activar la verificación en dos pasos en cada servicio y escanea su nuevo código QR.';
}
