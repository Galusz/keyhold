// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get cancel => 'Cancelar';

  @override
  String get open => 'Abrir';

  @override
  String get delete => 'Excluir';

  @override
  String get copy => 'Copiar';

  @override
  String get edit => 'Editar';

  @override
  String get add => 'Adicionar';

  @override
  String get search => 'Pesquisar';

  @override
  String get settings => 'Configurações';

  @override
  String get change => 'Alterar';

  @override
  String get disconnect => 'Desconectar';

  @override
  String get unlock => 'Desbloquear';

  @override
  String get noTitle => '(sem título)';

  @override
  String get code => 'Código';

  @override
  String get codes => 'Códigos';

  @override
  String get username => 'Nome de usuário';

  @override
  String get password => 'Senha';

  @override
  String get address => 'Endereço';

  @override
  String get notes => 'Notas';

  @override
  String get duplicates => 'Duplicados';

  @override
  String get masterPassword => 'Senha mestra';

  @override
  String copied(String what) {
    return 'Copiado: $what';
  }

  @override
  String get fingerprintTitle => 'Cofre Keyhold';

  @override
  String get fingerprintUnlockHint =>
      'Desbloqueie para ver suas senhas e códigos';

  @override
  String get fingerprintConfirmHint => 'Confirme com sua impressão digital';

  @override
  String driveNotConnected(String error) {
    return 'O Google Drive não foi conectado: $error';
  }

  @override
  String get scanQr => 'Ler um código QR';

  @override
  String get scanQrHint =>
      'Código de dois fatores de um site ou exportação do Google Authenticator';

  @override
  String get newCode => 'Novo código de dois fatores';

  @override
  String get newCodeHint => 'Digite você mesmo a chave de configuração';

  @override
  String get newLogin => 'Novo login';

  @override
  String get locked => 'O Keyhold está bloqueado';

  @override
  String get everything => 'Tudo';

  @override
  String get noCodesYet =>
      'Nenhum código de dois fatores ainda — toque em + para ler um';

  @override
  String get nothingYet => 'Nada aqui ainda';

  @override
  String get justNow => 'agora mesmo';

  @override
  String minutesAgo(int count) {
    return 'há $count min';
  }

  @override
  String hoursAgo(int count) {
    return 'há $count h';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'há $count dias',
      one: 'há 1 dia',
    );
    return '$_temp0';
  }

  @override
  String get notBackedUp => 'Sem backup — toque para conectar o Google Drive';

  @override
  String get backingUp => 'Fazendo backup…';

  @override
  String backupFailed(String error) {
    return 'Falha no backup: $error';
  }

  @override
  String get waitingFirstBackup => 'Aguardando o primeiro backup';

  @override
  String backedUpToDrive(String ago) {
    return 'Backup feito no Google Drive $ago';
  }

  @override
  String get connectDrive => 'Conectar o Google Drive';

  @override
  String codeSeconds(int seconds) {
    return 'Código ($seconds s)';
  }

  @override
  String get driveOnlyPhone =>
      'Não conectado — o cofre fica só neste telefone.';

  @override
  String connectedAs(String email) {
    return 'Conectado como $email';
  }

  @override
  String connectedAsSynced(String email, String time) {
    return 'Conectado como $email — última sincronização: $time';
  }

  @override
  String get syncNow => 'Sincronizar agora';

  @override
  String get fingerprintSwitch => 'Abrir o Keyhold com a impressão digital';

  @override
  String get fingerprintSwitchHint =>
      'Bloqueia quando a tela apaga ou depois de um minuto fora do app. As sugestões nos campos de login continuam funcionando.';

  @override
  String get fillingPasswords => 'Preenchimento de senhas';

  @override
  String get fillerOn =>
      'O Keyhold preenche logins em apps e navegadores: toque em \"Keyhold\" abaixo de um campo de login. No Chrome, ative também Configurações → Serviços de preenchimento automático → Preenchimento automático usando outro serviço.';

  @override
  String get fillerOff =>
      'Deixe o Keyhold preencher logins e códigos de dois fatores em apps e navegadores.';

  @override
  String get fillWithKeyhold => 'Preencher senhas com o Keyhold';

  @override
  String get deleteThisLogin => 'Excluir este login?';

  @override
  String deleteNamed(String name) {
    return 'Excluir $name?';
  }

  @override
  String get noDuplicatesLeft => 'Nenhum duplicado restante.';

  @override
  String get groupWeb => 'Web';

  @override
  String get groupLocal => 'Rede local';

  @override
  String get groupServers => 'Servidores';

  @override
  String get filterAll => 'Todos';

  @override
  String get filter2fa => '2FA';

  @override
  String get filterPasswords => 'Senhas';

  @override
  String get filterFiles => 'Arquivos';

  @override
  String get groups => 'Grupos';

  @override
  String get noGroup => 'Sem grupo';

  @override
  String moveCountToGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Mover $count itens para um grupo',
      one: 'Mover 1 item para um grupo',
    );
    return '$_temp0';
  }

  @override
  String get newGroup => 'Novo grupo';

  @override
  String get newGroupHint => 'Deixe vazio para tirá-los de qualquer grupo';

  @override
  String get move => 'Mover';

  @override
  String get clearSelection => 'Limpar seleção';

  @override
  String selectedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count selecionados',
      one: '1 selecionado',
    );
    return '$_temp0';
  }

  @override
  String get moveToGroup => 'Mover para grupo';

  @override
  String get addCodesFromQr =>
      'Adicionar códigos de dois fatores de um código QR';

  @override
  String get browserExtension => 'Extensão do navegador';

  @override
  String get addFile => 'Adicionar arquivo';

  @override
  String get newEntry => 'Novo';

  @override
  String get checking => 'Verificando…';

  @override
  String get notCheckedYet => 'Ainda não verificado';

  @override
  String filesNew(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count novos',
      one: '1 novo',
    );
    return '$_temp0';
  }

  @override
  String filesChanged(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count alterados',
      one: '1 alterado',
    );
    return '$_temp0';
  }

  @override
  String filesSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ignorados',
      one: '1 ignorado',
    );
    return '$_temp0';
  }

  @override
  String checkedNothingChanged(String when) {
    return 'Verificado $when — nada mudou';
  }

  @override
  String checkedWith(String when, String changes) {
    return 'Verificado $when — $changes';
  }

  @override
  String get watchedHint =>
      'Monitorados — copiados para o cofre sempre que mudam, a cada 15 minutos';

  @override
  String get nothingWatched => 'Nada monitorado ainda';

  @override
  String pathNotFound(String path) {
    return '$path — não encontrado';
  }

  @override
  String get stopWatching => 'Parar de monitorar';

  @override
  String get watchFolder => 'Monitorar pasta';

  @override
  String get watchFile => 'Monitorar arquivo';

  @override
  String get checkNow => 'Verificar agora';

  @override
  String fileTooBig(String name, String size) {
    return '$name tem $size — o limite é 25 MB';
  }

  @override
  String fileAdded(String name) {
    return '$name agora está no cofre';
  }

  @override
  String savedTo(String path) {
    return 'Salvo em $path';
  }

  @override
  String removeNamed(String name) {
    return 'Remover $name?';
  }

  @override
  String get removeFileHint =>
      'Ele sai do cofre. Backups mais antigos ainda o guardam.';

  @override
  String get remove => 'Remover';

  @override
  String get noFilesYet =>
      'Nenhum arquivo ainda — adicione códigos de recuperação, chaves ou digitalizações';

  @override
  String get saveToDisk => 'Salvar no disco';

  @override
  String forWindow(String window) {
    return 'Para \"$window\"';
  }

  @override
  String get dismiss => 'Dispensar';

  @override
  String get noBackupYet =>
      'Nenhum backup ainda — ele é feito ao salvar pela primeira vez';

  @override
  String lastBackup(String ago) {
    return 'Último backup $ago';
  }

  @override
  String backedUpTo(String ago, String targets) {
    return 'Backup feito $ago — $targets';
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
      other: '$count itens',
      one: '1 item',
    );
    return '$_temp0';
  }

  @override
  String get select => 'Selecionar';

  @override
  String get typeCode => 'Digitar o código na janela anterior';

  @override
  String get typeLogin => 'Digitar nome de usuário e senha';

  @override
  String get copyPassword => 'Copiar senha';

  @override
  String get save => 'Salvar';

  @override
  String get off => 'Desativado';

  @override
  String get synced => 'Sincronizado';

  @override
  String get alreadyInSync => 'Já está sincronizado';

  @override
  String get fillHostFirst => 'Preencha o host primeiro';

  @override
  String get fillUserFirst => 'Preencha o usuário primeiro';

  @override
  String get pickKeyFirst => 'Escolha primeiro o arquivo da sua chave privada';

  @override
  String noFileAt(String path) {
    return 'Não há nenhum arquivo em $path';
  }

  @override
  String serverUnreachable(String host, String port) {
    return 'Não foi possível acessar $host na porta $port. Verifique o endereço, a porta e se o servidor está no ar.';
  }

  @override
  String serverRefusedKey(String user) {
    return 'O servidor recusou esta chave para o usuário $user. Verifique se a chave pública correspondente está no authorized_keys dele.';
  }

  @override
  String get notAPrivateKey =>
      'Esse arquivo não é uma chave privada utilizável.';

  @override
  String cannotWriteFolder(String folder) {
    return 'Login feito, mas não é possível gravar em \"$folder\". Escolha outra pasta.';
  }

  @override
  String get driveNotInBuild =>
      'O Google Drive não está configurado nesta versão.';

  @override
  String get setPasswordFirst =>
      'Defina uma senha mestra primeiro — um novo dispositivo precisa dela para abrir o cofre.';

  @override
  String get foldersOnComputer => 'Pastas neste computador';

  @override
  String folderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pastas',
      one: '1 pasta',
    );
    return '$_temp0';
  }

  @override
  String folderCountCopied(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pastas — última cópia: $time',
      one: '1 pasta — última cópia: $time',
    );
    return '$_temp0';
  }

  @override
  String get yourServer => 'Seu servidor';

  @override
  String get noFolders => 'Nenhuma pasta — cópias locais desativadas';

  @override
  String get addFolder => 'Adicionar pasta';

  @override
  String get serverHint =>
      'A mesma cópia vai por SFTP para uma máquina sua. O arquivo continua criptografado, então o servidor só vê bytes e nada mais. Deixe o host vazio para pular isto.';

  @override
  String get host => 'Host';

  @override
  String get port => 'Porta';

  @override
  String get user => 'Usuário';

  @override
  String get privateKeyFile => 'Arquivo da chave privada';

  @override
  String get chooseFile => 'Escolher arquivo';

  @override
  String get serverFolder => 'Pasta no servidor';

  @override
  String get testConnection => 'Testar conexão';

  @override
  String get notReachable => 'Inacessível no momento';

  @override
  String get enterCodeKey => 'Digite a chave do código de dois fatores';

  @override
  String get twoFactorCode => 'Código de dois fatores';

  @override
  String get newEntryTitle => 'Novo item';

  @override
  String get editEntry => 'Editar item';

  @override
  String get name => 'Nome';

  @override
  String get key => 'Chave';

  @override
  String get keyHint =>
      'Cole a chave de configuração ou o link otpauth:// inteiro';

  @override
  String get note => 'Nota';

  @override
  String get addresses => 'Endereços';

  @override
  String get codeNotUsedYet =>
      'Ainda não usado em lugar nenhum. Ele se fixa sozinho na primeira vez que você o usar em um site, ou fixe-o a partir de um login.';

  @override
  String get noAddress => 'sem endereço';

  @override
  String get unpin => 'Desafixar';

  @override
  String get addAddress => 'Adicionar um endereço';

  @override
  String get title => 'Título';

  @override
  String get noName => '(sem nome)';

  @override
  String get none => 'Nenhum';

  @override
  String get choose => 'Escolher';

  @override
  String get group => 'Grupo';

  @override
  String get groupHint => 'Escolha um ou digite um novo nome';

  @override
  String get driveTabConnected =>
      'O Keyhold está conectado ao Google Drive. Você pode fechar esta aba.';

  @override
  String get driveTabNotConnected =>
      'O Google Drive não foi conectado. Você pode fechar esta aba.';

  @override
  String get signInTooLong =>
      'O login do Google demorou demais — tente novamente';

  @override
  String get signInCancelled => 'O login do Google foi cancelado';

  @override
  String get noOfflineAccess => 'O Google não permitiu o acesso off-line';

  @override
  String get noInternet => 'Sem conexão com a internet';

  @override
  String get wrongMasterPassword => 'Senha mestra incorreta';

  @override
  String driveRefusedDownload(String status) {
    return 'O Google Drive recusou o download ($status)';
  }

  @override
  String driveRefusedUpload(String status) {
    return 'O Google Drive recusou o upload ($status)';
  }

  @override
  String driveAnswered(String status) {
    return 'O Google Drive respondeu $status';
  }

  @override
  String get driveSignInAgain =>
      'O Google Drive precisa que você faça login novamente';

  @override
  String get driveNotConnectedError => 'O Google Drive não está conectado';

  @override
  String get driveAccessEnded =>
      'O acesso ao Google Drive terminou — conecte novamente';

  @override
  String signInFailed(String status) {
    return 'Falha no login do Google ($status)';
  }

  @override
  String get dupNewest => 'mais recente';

  @override
  String get dupSamePassword => 'mesma senha do mais recente';

  @override
  String get dupDifferentPassword => 'senha diferente';

  @override
  String get noUsername => '(sem nome de usuário)';

  @override
  String duplicateNote(String username, String password, String day) {
    return '$username · $password · alterado em $day';
  }

  @override
  String get fileEmpty => 'O arquivo está vazio';

  @override
  String get noLoginColumns =>
      'Nenhuma coluna de nome de usuário ou senha encontrada neste arquivo';

  @override
  String get noQrOnScreen => 'Nenhum código QR encontrado na tela';

  @override
  String get noQrInImage => 'Nenhum código QR encontrado nesta imagem';

  @override
  String get qrNotTwoFactor => 'Este código QR não é um código de dois fatores';

  @override
  String get exportQrEmpty => 'O código QR de exportação está vazio';

  @override
  String get exportQrUnreadable =>
      'Não foi possível ler este código QR de exportação';

  @override
  String serverWritable(String account) {
    return 'Conectado como $account, a pasta permite gravação';
  }

  @override
  String get openKeyhold => 'Abrir o Keyhold';

  @override
  String get quit => 'Sair';

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
      other:
          '$count usam um tipo de código que o Keyhold ainda não consegue gerar',
      one: '1 usa um tipo de código que o Keyhold ainda não consegue gerar',
    );
    return '$_temp0';
  }

  @override
  String savedAs(String name) {
    return 'Salvo como $name';
  }

  @override
  String savedCodes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count códigos salvos',
      one: '1 código salvo',
    );
    return '$_temp0';
  }

  @override
  String get images => 'Imagens';

  @override
  String get addCodes => 'Adicionar códigos de dois fatores';

  @override
  String get saveAll => 'Salvar todos';

  @override
  String get qrHintPhone =>
      'Aponte a câmera para o código QR que um site mostra quando você ativa a autenticação de dois fatores, ou para a exportação do Google Authenticator (Transferir contas → Exportar contas).';

  @override
  String get qrHintComputer =>
      'Mostre o código QR na tela e leia-o. Pode ser o código que um site mostra quando você ativa a autenticação de dois fatores, ou a exportação do Google Authenticator (Transferir contas → Exportar contas). Uma foto do código também funciona.';

  @override
  String get qrMicrosoftHint =>
      'O Microsoft Authenticator não exporta seus códigos — desative e reative a autenticação de dois fatores em cada site e leia o novo código aqui.';

  @override
  String get scanCamera => 'Ler com a câmera';

  @override
  String get scanScreen => 'Ler a tela';

  @override
  String get openImage => 'Abrir uma imagem';

  @override
  String get saved => 'Salvo';

  @override
  String get alreadyInKeyhold => 'Já está no Keyhold';

  @override
  String asName(String name) {
    return 'como \"$name\"';
  }

  @override
  String get typePasswordFirst => 'Digite sua senha primeiro';

  @override
  String get atLeast8 => 'Use pelo menos 8 caracteres';

  @override
  String get passwordsDiffer => 'As duas senhas são diferentes';

  @override
  String get passwordDoesNotOpen => 'Essa senha não abre este cofre';

  @override
  String get unlockVault => 'Desbloquear cofre';

  @override
  String get unlockHint =>
      'Este cofre veio de outro computador. Digite a senha mestra para abri-lo aqui.';

  @override
  String get newMasterPassword => 'Nova senha mestra';

  @override
  String get repeatIt => 'Repita a senha';

  @override
  String get openVault => 'Abrir cofre';

  @override
  String get savePassword => 'Salvar senha';

  @override
  String get nobodyCanRecover =>
      'Se você esquecê-la, só a chave de recuperação abre seu cofre: imprima a folha de recuperação.';

  @override
  String get groupApps => 'Apps';

  @override
  String get openKeyholdFirst =>
      'Abra o Keyhold uma vez e digite a senha mestra; depois tente novamente.';

  @override
  String pinTo(String name, String place) {
    return 'Fixar \"$name\" em $place?';
  }

  @override
  String get pinHint => 'Assim ele será oferecido aqui na hora, sem pesquisar.';

  @override
  String get doNotAskCode => 'Não perguntar mais sobre este código';

  @override
  String get notNow => 'Agora não';

  @override
  String get pin => 'Fixar';

  @override
  String get savedToKeyhold => 'Salvo no Keyhold';

  @override
  String get passwordUpdated => 'Senha atualizada no Keyhold';

  @override
  String get searchAllLogins => 'Pesquisar todos os logins';

  @override
  String get nothingFound => 'Nada encontrado.';

  @override
  String get noLoginForSite =>
      'Ainda não há login para este site. Pesquise acima ou faça login, e o Android vai oferecer para salvá-lo.';

  @override
  String get noLoginForApp =>
      'Ainda não há login para este app. Pesquise acima ou faça login, e o Android vai oferecer para salvá-lo.';

  @override
  String listening(String address) {
    return 'Escutando em $address';
  }

  @override
  String get notListening =>
      'Não está escutando — outro Keyhold pode já estar em execução';

  @override
  String get pairingToken => 'Token de pareamento';

  @override
  String get pairingTokenHint =>
      'Cole isto na extensão uma vez. Só são respondidas as solicitações que o trazem, e só da própria extensão — uma página da web não consegue acessar o cofre.';

  @override
  String get tokenCopied => 'Token copiado';

  @override
  String get copyToken => 'Copiar token';

  @override
  String get installIt => 'Instalar';

  @override
  String get installChrome =>
      'Chrome ou Edge: abra chrome://extensions, ative o Modo do desenvolvedor, clique em \"Carregar sem compactação\" e escolha a pasta abaixo.';

  @override
  String get installFirefox =>
      'Firefox: abra about:debugging#/runtime/this-firefox, clique em \"Carregar extensão temporária\" e escolha o manifest.json nessa pasta.';

  @override
  String get installPaste =>
      'Clique no ícone do Keyhold na barra de ferramentas e cole o token.';

  @override
  String get newCodeShort => 'Novo código';

  @override
  String get free => 'Livres';

  @override
  String get searchCodes => 'Pesquisar códigos';

  @override
  String get everyCodePinned =>
      'Todos os códigos estão fixados em algum lugar. Mude para Todos para vê-los.';

  @override
  String get noCodesFound => 'Nenhum código encontrado.';

  @override
  String pinnedTo(String hosts) {
    return 'fixado em $hosts';
  }

  @override
  String get notPinned => 'não fixado';

  @override
  String changedOn(String day) {
    return 'alterado em $day';
  }

  @override
  String get deleteCsvHint => 'Ele contém todas as senhas em texto simples';

  @override
  String get cameraHint =>
      'Aponte para o código QR de dois fatores de um site ou para a exportação do Google Authenticator.';

  @override
  String get deleteThisCode => 'Excluir este código de dois fatores?';

  @override
  String get deleteCodeWarning =>
      'Ele some de todos os seus dispositivos. Sem ele, você não consegue fazer login onde ele é usado.';

  @override
  String get deleteLoginWarning => 'Ele some de todos os seus dispositivos.';

  @override
  String get recoverySheet => 'Folha de recuperação';

  @override
  String get recoveryIntro =>
      'Esta chave abre seu cofre se você esquecer a senha mestra. Imprima a folha, copie nela à mão a última linha e guarde-a em casa.';

  @override
  String get print => 'Imprimir';

  @override
  String get done => 'Concluído';

  @override
  String get sheetTitle => 'Folha de recuperação do Keyhold';

  @override
  String sheetMade(String date) {
    return 'Feita em $date';
  }

  @override
  String get sheetWhere => 'Onde está seu cofre';

  @override
  String sheetDrive(String email) {
    return 'Google Drive de $email, pasta \"Keyhold\"';
  }

  @override
  String sheetFolders(String folders) {
    return 'Cópias em pastas: $folders';
  }

  @override
  String sheetServer(String host) {
    return 'Cópias no servidor $host';
  }

  @override
  String get sheetOnlyHere =>
      'Só neste dispositivo. Ative um backup no Keyhold.';

  @override
  String get sheetSteps => 'Em um novo computador ou telefone';

  @override
  String get sheetStep1 => 'Instale o Keyhold: galusz.github.io/keyhold';

  @override
  String get sheetStep2 => 'Conecte o mesmo Google Drive no Keyhold.';

  @override
  String get sheetStep3 =>
      'Quando o Keyhold pedir a senha mestra, digite esta chave de recuperação. Depois escolha uma nova senha mestra.';

  @override
  String get sheetKeepSafe =>
      'Qualquer pessoa com esta folha preenchida pode abrir seu cofre. Guarde-a como uma chave reserva de casa.';

  @override
  String get sheetDriveNoEmail => 'Google Drive, pasta \"Keyhold\"';

  @override
  String get noBackupPlaces =>
      'Nenhuma pasta de backup, servidor ou Google Drive: o cofre está só neste computador. Clique para configurar.';

  @override
  String get deleteVault => 'Excluir o cofre';

  @override
  String get deleteVaultFolders =>
      'Excluir também as cópias nas pastas de backup';

  @override
  String get deleteVaultSure => 'Excluir o cofre para sempre?';

  @override
  String get deleteVaultSureHint => 'Isso não pode ser desfeito.';

  @override
  String get recoveryGate =>
      'Digite sua senha mestra para ver a chave de recuperação.';

  @override
  String get showKey => 'Mostrar a chave';

  @override
  String get recoveryCopyRow => 'Copie esta linha à mão na folha impressa';

  @override
  String get checkRow =>
      'Depois digite a última linha como você a escreveu na folha';

  @override
  String get check => 'Verificar';

  @override
  String get rowMatches => 'Confere. Guarde a folha em um lugar seguro.';

  @override
  String get rowDiffers =>
      'Não confere. Compare a última linha com a tela e corrija-a na folha.';

  @override
  String get sheetKeyLabel => 'Chave de recuperação';

  @override
  String get sheetCopyRow =>
      'Copie aqui à mão a última linha da tela do Keyhold.';

  @override
  String get orRecoveryCode =>
      'Esqueceu? Digite a chave de recuperação da sua folha de recuperação.';

  @override
  String get newPasswordAfterKey =>
      'A chave de recuperação abriu seu cofre. Escolha uma nova senha mestra: ela substitui a esquecida em todos os seus dispositivos.';

  @override
  String get otherVaultTitle => 'Cópias de outro cofre';

  @override
  String otherVaultHint(String when) {
    return 'Esta pasta já tem cópias de outro cofre do Keyhold (a mais recente de $when). Abrir para ver o conteúdo? Seu cofre continua como está.';
  }

  @override
  String get copyPasswordTitle => 'Senha mestra desta cópia';

  @override
  String get copyNotOpened =>
      'Não foi possível abrir a cópia: senha ou chave de recuperação erradas, ou não é um cofre do Keyhold.';

  @override
  String copyTitle(String name) {
    return 'Cópia: $name';
  }

  @override
  String get copyReadOnly =>
      'Somente para ver: nada aqui altera seu cofre. Você pode adicionar itens avulsos ao seu cofre.';

  @override
  String get myVault => 'Meu cofre';

  @override
  String get vaultTab => 'Cofre';

  @override
  String get syncTab => 'Sincronizar';

  @override
  String get copiesTab => 'Backups';

  @override
  String get startHint =>
      'Suas senhas e códigos de dois fatores em um só cofre: no computador, no telefone e no navegador.';

  @override
  String get createVault => 'Criar um cofre novo';

  @override
  String get openMyVault => 'Abrir meu cofre';

  @override
  String get newVault => 'Cofre novo';

  @override
  String get vaultName => 'Nome do cofre';

  @override
  String get newVaultHint =>
      'A senha mestra abre este cofre em todos os seus dispositivos: computador, telefone e navegador. O Keyhold não consegue recuperá-la; a chave de recuperação que você recebe em seguida consegue.';

  @override
  String get sealHint =>
      'Seu cofre ainda não tem senha mestra. Defina agora: ela abre este cofre nos seus outros dispositivos e no navegador.';

  @override
  String get createVaultButton => 'Criar o cofre';

  @override
  String get forgotPassword => 'Esqueceu a senha?';

  @override
  String get usePassword => 'Usar a senha mestra';

  @override
  String get recoveryKey => 'Chave de recuperação';

  @override
  String get recoveryKeyFieldHint =>
      'Os 36 caracteres da sua folha de recuperação; espaços não importam.';

  @override
  String get openVaultTitle => 'Abrir um cofre';

  @override
  String get openVaultHint =>
      'O cofre abre como está. Ele nunca é misturado com outro cofre.';

  @override
  String get fromDrive => 'Do Google Drive';

  @override
  String get fromDriveHint =>
      'Entre no Google e digite a senha mestra do cofre.';

  @override
  String fromDriveAs(String email) {
    return '$email: digite a senha mestra do cofre.';
  }

  @override
  String get fromFile => 'De um arquivo (.khd)';

  @override
  String get fromFileHint =>
      'Uma cópia de uma pasta de backup, de um pendrive ou de um computador antigo.';

  @override
  String get closedHere => 'Abertos antes neste dispositivo';

  @override
  String closedOn(String date) {
    return 'fechado em $date';
  }

  @override
  String get closedVaultGone =>
      'O arquivo desse cofre não está mais neste dispositivo.';

  @override
  String get typeVaultPassword =>
      'Digite a senha mestra do cofre que você quer abrir. O Keyhold testa a senha em cada cofre do seu Google Drive.';

  @override
  String lookingForVault(int at, int of) {
    return 'Procurando seu cofre: $at de $of';
  }

  @override
  String get noVaultInDrive =>
      'Ainda não há nenhum cofre Keyhold neste Google Drive.';

  @override
  String get noVaultMatches =>
      'Nenhum cofre do seu Google Drive abre com esta senha.';

  @override
  String get sameVaultFile =>
      'Este arquivo é uma cópia do cofre que está aberto. Para tirar itens dele, use Backups e depois Revisar uma cópia.';

  @override
  String fileVaultPassword(String name) {
    return 'Digite a senha mestra de $name.';
  }

  @override
  String get driveFileUnreadable =>
      'Não dá para ler o arquivo deste cofre no Google Drive. O Keyhold o deixa como está.';

  @override
  String get vaultInfoHint =>
      'Este cofre abre com a senha mestra dele em todos os dispositivos. Se você esquecer a senha, a chave de recuperação abre o cofre e você escolhe uma nova.';

  @override
  String get recoveryKeyHint => 'Mostrada e impressa depois da senha mestra';

  @override
  String get otherVaults => 'Outros cofres';

  @override
  String get openOtherVault => 'Abrir outro cofre';

  @override
  String get openOtherVaultHint =>
      'Do Google Drive, de um arquivo ou deste dispositivo';

  @override
  String get createNewVaultHint => 'Vazio, com a própria senha mestra';

  @override
  String closeVaultTitle(String name) {
    return 'Fechar \"$name\" neste dispositivo?';
  }

  @override
  String get closeVaultHint =>
      'Nada é apagado: ele continua no Google Drive, nas cópias de backup e na lista de cofres deste dispositivo. Ele abre de novo com a senha mestra dele.';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get renameVault => 'Renomear o cofre';

  @override
  String get reviewCopy => 'Revisar uma cópia';

  @override
  String get driveVaultHint =>
      'Guarda este cofre como um arquivo criptografado próprio, numa pasta \"Keyhold\" do seu Google Drive. Seus outros dispositivos o abrem com a senha mestra dele. Vários cofres podem dividir um Google Drive sem nunca se misturar. O Google não consegue lê-los.';

  @override
  String get foldersSlotsHint =>
      'Cada salvamento atualiza até 7 cópias do cofre em cada pasta: a mais recente e outras de cerca de uma hora, um dia, uma semana, um mês, três meses e um ano atrás.';

  @override
  String get deleteVaultHereHint =>
      'O cofre é apagado deste dispositivo: senhas, códigos de dois fatores e arquivos. Os cofres abertos antes aqui continuam. Depois o Keyhold mostra a tela inicial.';

  @override
  String get deleteVaultDriveMine =>
      'Apagar também do Google Drive (os outros cofres continuam lá)';

  @override
  String get vaultDeletedHere => 'O cofre foi apagado.';

  @override
  String get menu => 'Menu';

  @override
  String get importTitle => 'Importar';

  @override
  String get importMenuHint =>
      'Senhas e códigos de outros apps ou de outro cofre';

  @override
  String get importAnyHint =>
      'Escolha uma exportação de outro gerenciador de senhas ou app autenticador, um banco de dados do KeePass ou outro cofre do Keyhold. O Keyhold reconhece o arquivo sozinho, e você marca o que entra.';

  @override
  String get importReading => 'Lendo o arquivo…';

  @override
  String importPasswordTitle(String format) {
    return 'Senha deste arquivo do $format';
  }

  @override
  String get importWrongPassword => 'Essa senha não abre este arquivo.';

  @override
  String get importUnknown =>
      'O Keyhold não reconhece este arquivo. Exporte de novo pelo outro app, como CSV ou JSON.';

  @override
  String importNothing(String format) {
    return '$format: não há nada neste arquivo que o Keyhold possa guardar.';
  }

  @override
  String get keePassUnsupported =>
      'Este banco do KeePass usa algo que o Keyhold não consegue abrir (um arquivo de chave ou a cifra Twofish). Exporte-o pelo KeePass como CSV.';

  @override
  String get bitwardenAccountLocked =>
      'Esta exportação do Bitwarden só abre com a sua conta do Bitwarden. Exporte de novo como JSON, protegido por senha ou sem criptografia.';

  @override
  String get otpLinks => 'links otpauth';

  @override
  String get importPickHint =>
      'Marque o que deve entrar no seu cofre. O que você já tem fica desmarcado.';

  @override
  String codesLeftOut(int count) {
    return 'Códigos deixados de fora: $count. O Keyhold só gera códigos de 6 dígitos a cada 30 segundos, sem 8 dígitos, 60 segundos, contadores ou Steam.';
  }

  @override
  String recordsLeftOut(int count) {
    return 'Registros deixados de fora: $count (vazios, cartões e identidades).';
  }

  @override
  String get selectAll => 'Selecionar tudo';

  @override
  String get alreadyInVault => 'já está no seu cofre';

  @override
  String addSelected(int count) {
    return 'Adicionar ($count)';
  }

  @override
  String addedCount(int count) {
    return 'Adicionado ao cofre: $count';
  }

  @override
  String get deletePlainFile => 'Apagar o arquivo depois';

  @override
  String get importPasswordsFrom => 'Senhas';

  @override
  String get importPasswordsList =>
      'Chrome, Edge, Firefox e Safari (CSV), Bitwarden (CSV ou JSON), 1Password (.1pux ou CSV), KeePass e KeePassXC (.kdbx ou CSV), LastPass, Proton Pass, NordPass e Dashlane (CSV), e outro cofre do Keyhold (.khd).';

  @override
  String get importCodesFrom => 'Códigos de dois fatores';

  @override
  String get importCodesList =>
      'Aegis (.json), 2FAS (.2fas), Ente Auth, FreeOTP+ e andOTP, e qualquer arquivo com links otpauth://. Google Authenticator: mostre o QR code de exportação dele e use o botão de QR code do Keyhold.';

  @override
  String get importNoExport =>
      'Microsoft Authenticator e Authy não deixam os códigos saírem: ative de novo a verificação em duas etapas em cada serviço e leia o novo QR code.';

  @override
  String get foldersOnPhone => 'Pastas neste telefone';

  @override
  String get phoneFoldersHint =>
      'Escolha uma pasta do telefone, do cartão de memória ou de um app como Nextcloud ou OneDrive que deixe o Android salvar lá.';

  @override
  String get copiesPlaces => 'Pastas e seu servidor';

  @override
  String get shareVaultCopy => 'Compartilhar uma cópia do cofre';

  @override
  String get shareVaultHint =>
      'Você também pode enviar o arquivo por e-mail ou guardá-lo em Arquivos: ele só abre com a senha mestra ou a chave de recuperação.';
}
