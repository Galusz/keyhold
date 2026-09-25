// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get cancel => '取消';

  @override
  String get open => '打开';

  @override
  String get delete => '删除';

  @override
  String get copy => '复制';

  @override
  String get edit => '编辑';

  @override
  String get add => '添加';

  @override
  String get search => '搜索';

  @override
  String get settings => '设置';

  @override
  String get change => '更改';

  @override
  String get connect => '连接';

  @override
  String get disconnect => '断开连接';

  @override
  String get unlock => '解锁';

  @override
  String get noTitle => '（无标题）';

  @override
  String get code => '验证码';

  @override
  String get codes => '验证码';

  @override
  String get username => '用户名';

  @override
  String get password => '密码';

  @override
  String get address => '网址';

  @override
  String get notes => '备注';

  @override
  String get duplicates => '重复项';

  @override
  String get masterPassword => '主密码';

  @override
  String get setMasterPassword => '设置主密码';

  @override
  String copied(String what) {
    return '已复制$what';
  }

  @override
  String get fingerprintTitle => 'Keyhold 密码库';

  @override
  String get fingerprintUnlockHint => '解锁以查看您的密码和验证码';

  @override
  String get fingerprintConfirmHint => '请用指纹确认';

  @override
  String driveNotConnected(String error) {
    return '未能连接 Google Drive：$error';
  }

  @override
  String get masterPasswordOfVault => '密码库的主密码';

  @override
  String get masterPasswordFromComputer => '就是您在电脑上的 Keyhold 中设置的那个';

  @override
  String get scanQr => '扫描二维码';

  @override
  String get scanQrHint => '网站的双重验证码，或从 Google Authenticator 导出的码';

  @override
  String get newCode => '新建双重验证码';

  @override
  String get newCodeHint => '手动输入设置密钥';

  @override
  String get newLogin => '新建登录信息';

  @override
  String get locked => 'Keyhold 已锁定';

  @override
  String get everything => '全部';

  @override
  String get noCodesYet => '还没有双重验证码，点按 + 即可扫描';

  @override
  String get nothingYet => '这里还没有内容';

  @override
  String get justNow => '刚刚';

  @override
  String minutesAgo(int count) {
    return '$count 分钟前';
  }

  @override
  String hoursAgo(int count) {
    return '$count 小时前';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 天前',
    );
    return '$_temp0';
  }

  @override
  String get notBackedUp => '尚未备份，点按即可连接 Google Drive';

  @override
  String get backingUp => '正在备份…';

  @override
  String backupFailed(String error) {
    return '备份失败：$error';
  }

  @override
  String get waitingFirstBackup => '正在等待首次备份';

  @override
  String backedUpToDrive(String ago) {
    return '$ago已备份到 Google Drive';
  }

  @override
  String get phoneWelcome =>
      '您的密码和双重验证码——与电脑上是同一个密码库，通过您自己的 Google Drive 保持同步。';

  @override
  String get connectDrive => '连接 Google Drive';

  @override
  String get startEmpty => '从空密码库开始';

  @override
  String codeSeconds(int seconds) {
    return '验证码（$seconds 秒）';
  }

  @override
  String get driveOnlyPhone => '未连接，密码库只保存在这部手机上。';

  @override
  String connectedAs(String email) {
    return '已连接：$email';
  }

  @override
  String connectedAsSynced(String email, String time) {
    return '已连接：$email，上次同步于 $time';
  }

  @override
  String get syncNow => '立即同步';

  @override
  String get fingerprintLock => '指纹锁';

  @override
  String get fingerprintSwitch => '用指纹打开 Keyhold';

  @override
  String get fingerprintSwitchHint => '屏幕熄灭或离开一分钟后自动锁定。登录框下方的建议仍可使用。';

  @override
  String get fillingPasswords => '填写密码';

  @override
  String get fillerOn =>
      'Keyhold 可在应用和浏览器中填写登录信息：点按登录框下方的“Keyhold”即可。在 Chrome 中还需开启“设置 → 自动填充服务 → 使用其他服务自动填充”。';

  @override
  String get fillerOff => '让 Keyhold 在应用和浏览器中填写登录信息和双重验证码。';

  @override
  String get fillWithKeyhold => '用 Keyhold 填写密码';

  @override
  String get passwordSetPhone => '已设置。在新设备上用它打开这个密码库。';

  @override
  String get passwordNotSetPhone => '未设置。没有它，新设备就无法打开密码库。';

  @override
  String get deleteThisLogin => '删除此登录信息？';

  @override
  String deleteNamed(String name) {
    return '删除“$name”？';
  }

  @override
  String get noDuplicatesLeft => '已没有重复项。';

  @override
  String get groupWeb => '网站';

  @override
  String get groupLocal => '局域网';

  @override
  String get groupServers => '服务器';

  @override
  String get filterAll => '全部';

  @override
  String get filter2fa => '2FA';

  @override
  String get filterPasswords => '密码';

  @override
  String get filterFiles => '文件';

  @override
  String get groups => '分组';

  @override
  String get noGroup => '未分组';

  @override
  String moveCountToGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '将 $count 项移到分组',
    );
    return '$_temp0';
  }

  @override
  String get newGroup => '新分组';

  @override
  String get newGroupHint => '留空即可将它们移出所有分组';

  @override
  String get move => '移动';

  @override
  String get clearSelection => '取消选择';

  @override
  String selectedCount(int count) {
    return '已选择 $count 项';
  }

  @override
  String get moveToGroup => '移到分组';

  @override
  String get addCodesFromQr => '从二维码添加双重验证码';

  @override
  String get browserExtension => '浏览器扩展程序';

  @override
  String get backup => '备份';

  @override
  String get importCsv => '从 CSV 导入';

  @override
  String get changeMasterPassword => '更改主密码';

  @override
  String get addFile => '添加文件';

  @override
  String get newEntry => '新建';

  @override
  String get checking => '正在检查…';

  @override
  String get notCheckedYet => '尚未检查';

  @override
  String filesNew(int count) {
    return '新增 $count 个';
  }

  @override
  String filesChanged(int count) {
    return '更改 $count 个';
  }

  @override
  String filesSkipped(int count) {
    return '跳过 $count 个';
  }

  @override
  String checkedNothingChanged(String when) {
    return '$when已检查，没有变化';
  }

  @override
  String checkedWith(String when, String changes) {
    return '$when已检查：$changes';
  }

  @override
  String get watchedHint => '监视中：一有变化就复制到密码库，每 15 分钟检查一次';

  @override
  String get nothingWatched => '尚未监视任何内容';

  @override
  String pathNotFound(String path) {
    return '找不到 $path';
  }

  @override
  String get stopWatching => '停止监视';

  @override
  String get watchFolder => '监视文件夹';

  @override
  String get watchFile => '监视文件';

  @override
  String get checkNow => '立即检查';

  @override
  String fileTooBig(String name, String size) {
    return '“$name”大小为 $size，上限是 25 MB';
  }

  @override
  String fileAdded(String name) {
    return '“$name”已存入密码库';
  }

  @override
  String savedTo(String path) {
    return '已保存到 $path';
  }

  @override
  String removeNamed(String name) {
    return '移除“$name”？';
  }

  @override
  String get removeFileHint => '它会从密码库中消失，但旧的备份中仍保留着它。';

  @override
  String get remove => '移除';

  @override
  String get noFilesYet => '还没有文件，可以添加恢复码、密钥或扫描件';

  @override
  String get saveToDisk => '保存到磁盘';

  @override
  String forWindow(String window) {
    return '用于“$window”';
  }

  @override
  String get dismiss => '关闭';

  @override
  String get noBackupYet => '尚未备份，首次保存时会自动备份';

  @override
  String lastBackup(String ago) {
    return '上次备份：$ago';
  }

  @override
  String backedUpTo(String ago, String targets) {
    return '$ago已备份：$targets';
  }

  @override
  String get driveNeedsPassword => 'Google Drive：请打开“备份”并输入主密码';

  @override
  String driveProblem(String problem) {
    return 'Google Drive：$problem';
  }

  @override
  String driveSynced(String ago) {
    return 'Google Drive：$ago已同步';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 项',
    );
    return '$_temp0';
  }

  @override
  String get select => '选择';

  @override
  String get typeCode => '将验证码键入上一个窗口';

  @override
  String get typeLogin => '键入用户名和密码';

  @override
  String get copyPassword => '复制密码';

  @override
  String get save => '保存';

  @override
  String get off => '已关闭';

  @override
  String onWith(String detail) {
    return '已开启：$detail';
  }

  @override
  String get join => '加入';

  @override
  String get synced => '已同步';

  @override
  String get alreadyInSync => '已经是同步的';

  @override
  String get fillHostFirst => '请先填写主机';

  @override
  String get fillUserFirst => '请先填写用户';

  @override
  String get pickKeyFirst => '请先选择您的私钥文件';

  @override
  String noFileAt(String path) {
    return '$path 处没有文件';
  }

  @override
  String serverUnreachable(String host, String port) {
    return '无法连接到 $host 的 $port 端口。请检查地址、端口以及服务器是否正在运行。';
  }

  @override
  String serverRefusedKey(String user) {
    return '服务器拒绝了用户 $user 的这个密钥。请确认对应的公钥已添加到服务器的 authorized_keys 中。';
  }

  @override
  String get notAPrivateKey => '该文件不是可用的私钥。';

  @override
  String cannotWriteFolder(String folder) {
    return '已登录，但无法写入“$folder”。请选择其他文件夹。';
  }

  @override
  String get driveHoldsVault => 'Google Drive 中已有一个 Keyhold 密码库。需要它的主密码才能加入。';

  @override
  String get masterPasswordOfDriveVault => 'Google Drive 中密码库的主密码';

  @override
  String get driveHint =>
      '将加密的密码库保存在您自己 Google Drive 的“Keyhold”文件夹中，让您的其他设备保持同步，电脑丢了也不会丢失任何数据。Google 无法读取它。';

  @override
  String get driveNotInBuild => '此版本未设置 Google Drive。';

  @override
  String get setPasswordFirst => '请先设置主密码，新设备需要用它打开密码库。';

  @override
  String get foldersOnComputer => '这台电脑上的文件夹';

  @override
  String folderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个文件夹',
    );
    return '$_temp0';
  }

  @override
  String folderCountCopied(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个文件夹，上次复制于 $time',
    );
    return '$_temp0';
  }

  @override
  String get yourServer => '您的服务器';

  @override
  String get foldersHint => '每次保存都会在每个文件夹中放入一份带日期的副本，并保留最近 30 份。';

  @override
  String get noFolders => '没有文件夹，本地副本已关闭';

  @override
  String get addFolder => '添加文件夹';

  @override
  String get serverHint =>
      '同一份副本会通过 SFTP 传到您自己的机器上。文件始终是加密的，服务器只能看到一串字节，别的什么也看不到。主机留空即可跳过此项。';

  @override
  String get host => '主机';

  @override
  String get port => '端口';

  @override
  String get user => '用户';

  @override
  String get privateKeyFile => '私钥文件';

  @override
  String get chooseFile => '选择文件';

  @override
  String get serverFolder => '服务器上的文件夹';

  @override
  String get testConnection => '测试连接';

  @override
  String get notReachable => '暂时无法连接';

  @override
  String get enterCodeKey => '输入双重验证码的密钥';

  @override
  String get twoFactorCode => '双重验证码';

  @override
  String get newEntryTitle => '新建条目';

  @override
  String get editEntry => '编辑条目';

  @override
  String get name => '名称';

  @override
  String get key => '密钥';

  @override
  String get keyHint => '粘贴设置密钥或完整的 otpauth:// 链接';

  @override
  String get note => '备注';

  @override
  String get addresses => '网址';

  @override
  String get codeNotUsedYet => '尚未在任何地方使用。首次在某个网站上使用时会自动关联，也可以从登录信息中关联。';

  @override
  String get noAddress => '无网址';

  @override
  String get unpin => '取消关联';

  @override
  String get addAddress => '添加网址';

  @override
  String get title => '标题';

  @override
  String get noName => '（无名称）';

  @override
  String get none => '无';

  @override
  String get choose => '选择';

  @override
  String get group => '分组';

  @override
  String get groupHint => '选择一个或输入新名称';

  @override
  String get driveTabConnected => 'Keyhold 已连接到 Google Drive。您可以关闭此标签页。';

  @override
  String get driveTabNotConnected => '未能连接 Google Drive。您可以关闭此标签页。';

  @override
  String get signInTooLong => 'Google 登录耗时过长，请重试';

  @override
  String get signInCancelled => 'Google 登录已取消';

  @override
  String get noOfflineAccess => 'Google 未允许离线访问';

  @override
  String get noInternet => '无网络连接';

  @override
  String get wrongMasterPassword => '主密码错误';

  @override
  String driveRefusedDownload(String status) {
    return 'Google Drive 拒绝了下载（$status）';
  }

  @override
  String driveRefusedUpload(String status) {
    return 'Google Drive 拒绝了上传（$status）';
  }

  @override
  String driveAnswered(String status) {
    return 'Google Drive 返回了 $status';
  }

  @override
  String get driveSignInAgain => 'Google Drive 需要您重新登录';

  @override
  String get driveNotConnectedError => '未连接 Google Drive';

  @override
  String get driveAccessEnded => 'Google Drive 访问权限已失效，请重新连接';

  @override
  String signInFailed(String status) {
    return 'Google 登录失败（$status）';
  }

  @override
  String get dupNewest => '最新';

  @override
  String get dupSamePassword => '密码与最新的相同';

  @override
  String get dupDifferentPassword => '密码不同';

  @override
  String get noUsername => '（无用户名）';

  @override
  String duplicateNote(String username, String password, String day) {
    return '$username · $password · 更改于 $day';
  }

  @override
  String get fileEmpty => '文件为空';

  @override
  String get noLoginColumns => '此文件中找不到用户名或密码列';

  @override
  String get noQrOnScreen => '屏幕上找不到二维码';

  @override
  String get noQrInImage => '此图片中找不到二维码';

  @override
  String get qrNotTwoFactor => '此二维码不是双重验证码';

  @override
  String get exportQrEmpty => '导出的二维码是空的';

  @override
  String get exportQrUnreadable => '无法读取此导出二维码';

  @override
  String serverWritable(String account) {
    return '已连接：$account，文件夹可写入';
  }

  @override
  String get openKeyhold => '打开 Keyhold';

  @override
  String get quit => '退出';

  @override
  String codesFound(int count) {
    return '找到 $count 个';
  }

  @override
  String codesUnsupported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个使用了 Keyhold 暂时无法生成的验证码类型',
    );
    return '$_temp0';
  }

  @override
  String savedAs(String name) {
    return '已保存为“$name”';
  }

  @override
  String savedCodes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已保存 $count 个验证码',
    );
    return '$_temp0';
  }

  @override
  String get images => '图片';

  @override
  String get addCodes => '添加双重验证码';

  @override
  String get saveAll => '全部保存';

  @override
  String get qrHintPhone =>
      '将相机对准网站在您开启双重验证时显示的二维码，或对准 Google Authenticator 导出的二维码（转移帐号 → 导出帐号）。';

  @override
  String get qrHintComputer =>
      '让二维码显示在屏幕上，然后扫描。可以是网站在您开启双重验证时显示的二维码，也可以是 Google Authenticator 导出的二维码（转移帐号 → 导出帐号）。二维码的照片也可以。';

  @override
  String get qrMicrosoftHint =>
      'Microsoft Authenticator 无法导出验证码。请在每个网站上关闭再重新开启双重验证，然后在这里扫描新的二维码。';

  @override
  String get scanCamera => '用相机扫描';

  @override
  String get scanScreen => '扫描屏幕';

  @override
  String get openImage => '打开图片';

  @override
  String get saved => '已保存';

  @override
  String get alreadyInKeyhold => '已在 Keyhold 中';

  @override
  String asName(String name) {
    return '名为“$name”';
  }

  @override
  String get typePasswordFirst => '请先输入密码';

  @override
  String get atLeast8 => '请至少使用 8 个字符';

  @override
  String get passwordsDiffer => '两次输入的密码不一致';

  @override
  String get passwordDoesNotOpen => '该密码无法打开此密码库';

  @override
  String get currentPasswordWrong => '当前主密码错误';

  @override
  String get unlockVault => '解锁密码库';

  @override
  String get unlockHint => '此密码库来自另一台电脑。请输入主密码，在这里打开它。';

  @override
  String get masterPasswordHint =>
      'Windows 会自动为您打开此密码库。重装系统后、在新电脑上或在手机上，都要靠主密码才能重新打开。';

  @override
  String get currentMasterPassword => '当前主密码';

  @override
  String get newMasterPassword => '新主密码';

  @override
  String get repeatIt => '再输入一次';

  @override
  String get openVault => '打开密码库';

  @override
  String get savePassword => '保存密码';

  @override
  String get nobodyCanRecover => '如果您忘记了它，只有恢复密钥才能打开您的密码库：请打印恢复单。';

  @override
  String get groupApps => '应用';

  @override
  String get openKeyholdFirst => '请先打开一次 Keyhold 并输入主密码，然后重试。';

  @override
  String pinTo(String name, String place) {
    return '将“$name”关联到 $place？';
  }

  @override
  String get pinHint => '这样以后在这里会直接提供它，无需搜索。';

  @override
  String get doNotAskCode => '不再询问此验证码';

  @override
  String get notNow => '以后再说';

  @override
  String get pin => '关联';

  @override
  String get savedToKeyhold => '已保存到 Keyhold';

  @override
  String get passwordUpdated => '已在 Keyhold 中更新密码';

  @override
  String get searchAllLogins => '搜索所有登录信息';

  @override
  String get nothingFound => '未找到任何内容。';

  @override
  String get noLoginForSite => '此网站还没有登录信息。请在上方搜索，或者直接登录，Android 会提示您保存。';

  @override
  String get noLoginForApp => '此应用还没有登录信息。请在上方搜索，或者直接登录，Android 会提示您保存。';

  @override
  String listening(String address) {
    return '正在监听 $address';
  }

  @override
  String get notListening => '未在监听，可能已有另一个 Keyhold 在运行';

  @override
  String get pairingToken => '配对令牌';

  @override
  String get pairingTokenHint =>
      '将它粘贴到扩展程序中一次即可。只有带着它的请求才会得到响应，而且只响应扩展程序本身——网页无法访问密码库。';

  @override
  String get tokenCopied => '已复制令牌';

  @override
  String get copyToken => '复制令牌';

  @override
  String get installIt => '安装';

  @override
  String get installChrome =>
      'Chrome 或 Edge：打开 chrome://extensions，开启开发者模式，点击“加载已解压的扩展程序”，然后选择下面的文件夹。';

  @override
  String get installFirefox =>
      'Firefox：打开 about:debugging#/runtime/this-firefox，点击“临时载入附加组件”，然后选择该文件夹中的 manifest.json。';

  @override
  String get installPaste => '点击工具栏中的 Keyhold 图标，然后粘贴令牌。';

  @override
  String get newCodeShort => '新验证码';

  @override
  String get free => '未关联';

  @override
  String get searchCodes => '搜索验证码';

  @override
  String get everyCodePinned => '每个验证码都已关联到某处。切换到“全部”即可查看。';

  @override
  String get noCodesFound => '未找到验证码。';

  @override
  String pinnedTo(String hosts) {
    return '已关联到 $hosts';
  }

  @override
  String get notPinned => '未关联';

  @override
  String changedOn(String day) {
    return '更改于 $day';
  }

  @override
  String get importPasswords => '导入密码';

  @override
  String get importHint =>
      '先从浏览器中将密码导出为 CSV 文件，再在这里加载该文件。Chrome、Edge、Firefox、Bitwarden 和 KeePassXC 导出的文件都可以使用。';

  @override
  String get chooseCsv => '选择 CSV 文件';

  @override
  String entriesReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已准备好 $count 个条目',
    );
    return '$_temp0';
  }

  @override
  String entriesReadySkipped(int count, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '已准备好 $count 个条目',
    );
    String _temp1 = intl.Intl.pluralLogic(
      skipped,
      locale: localeName,
      other: '已跳过 $skipped 个空行',
    );
    return '$_temp0，$_temp1';
  }

  @override
  String andMore(int count) {
    return '还有 $count 个';
  }

  @override
  String get deleteCsv => '导入后删除 CSV 文件';

  @override
  String get deleteCsvHint => '它以明文保存了所有密码';

  @override
  String importEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '导入 $count 个条目',
    );
    return '$_temp0';
  }

  @override
  String get cameraHint => '对准网站的双重验证二维码，或 Google Authenticator 导出的二维码。';

  @override
  String get deleteThisCode => '删除此双重验证码？';

  @override
  String get deleteCodeWarning => '它会从您的所有设备上消失。没有它，您将无法在用到它的地方登录。';

  @override
  String get deleteLoginWarning => '它会从您的所有设备上消失。';

  @override
  String nextCode(String code) {
    return '下一个 $code';
  }

  @override
  String get noMasterPasswordBar => '未设置主密码：您的备份无法在其他电脑上打开。点击即可设置。';

  @override
  String get printRecoverySheet => '打印恢复单';

  @override
  String get recoverySheet => '恢复单';

  @override
  String get recoveryIntro =>
      '如果您忘记了主密码，这个密钥可以打开您的密码库。请打印恢复单，把最后一行亲手抄上去，然后放在家里。';

  @override
  String get print => '打印';

  @override
  String get done => '完成';

  @override
  String get sheetTitle => 'Keyhold 恢复单';

  @override
  String sheetMade(String date) {
    return '创建于 $date';
  }

  @override
  String get sheetWhere => '密码库存放位置';

  @override
  String sheetDrive(String email) {
    return '$email 的 Google Drive，“Keyhold”文件夹';
  }

  @override
  String sheetFolders(String folders) {
    return '文件夹中的副本：$folders';
  }

  @override
  String sheetServer(String host) {
    return '服务器 $host 上的副本';
  }

  @override
  String get sheetOnlyHere => '只保存在这台设备上。请在 Keyhold 中开启备份。';

  @override
  String get sheetSteps => '在新电脑或新手机上';

  @override
  String get sheetStep1 => '安装 Keyhold：galusz.github.io/keyhold';

  @override
  String get sheetStep2 => '在 Keyhold 中连接同一个 Google Drive。';

  @override
  String get sheetStep3 => 'Keyhold 要求输入主密码时，请输入此恢复密钥。然后设置新的主密码。';

  @override
  String get sheetKeepSafe => '任何人拿到这张填好的恢复单，都能打开您的密码库。请像保管家里的备用钥匙一样保管它。';

  @override
  String get sheetDriveNoEmail => 'Google Drive 中的“Keyhold”文件夹';

  @override
  String get noBackupPlaces => '没有备份文件夹、服务器或 Google Drive：密码库只在这台电脑上。点击进行设置。';

  @override
  String get deleteVault => '删除密码库';

  @override
  String get deleteVaultHint =>
      'Keyhold 在此设备上保存的所有内容都将被清除：密码、双重验证码、文件和设置。之后 Keyhold 会关闭，并以空密码库重新开始。';

  @override
  String get deleteVaultDrive =>
      '同时从 Google Drive 中删除（其他设备会保留各自的副本，直到您在那里也将其删除）';

  @override
  String get deleteVaultFolders => '同时删除备份文件夹中的副本';

  @override
  String get deleteVaultSure => '要永久删除密码库吗？';

  @override
  String get deleteVaultSureHint => '此操作无法撤消。';

  @override
  String get vaultDeleted => '密码库已删除。Keyhold 即将关闭。';

  @override
  String get recoveryGate => '输入主密码即可查看恢复密钥。';

  @override
  String get showKey => '显示密钥';

  @override
  String get recoveryNeedsPassword => '请先设置主密码：设置之后才会显示恢复密钥。';

  @override
  String get recoveryCopyRow => '将这一行亲手抄到打印好的恢复单上';

  @override
  String get checkRow => '然后输入您在恢复单上写下的最后一行';

  @override
  String get check => '核对';

  @override
  String get rowMatches => '一致。请把恢复单放在安全的地方。';

  @override
  String get rowDiffers => '不一致。请将最后一行与屏幕上的内容对照，并在恢复单上改正。';

  @override
  String get sheetKeyLabel => '恢复密钥';

  @override
  String get sheetCopyRow => '请从 Keyhold 屏幕上将最后一行亲手抄在这里。';

  @override
  String get orRecoveryCode => '忘记了？请改为输入恢复单上的恢复密钥。';

  @override
  String get newPasswordAfterKey => '恢复密钥已打开您的密码库。请设置新的主密码：它将在您的所有设备上取代忘记的那个。';

  @override
  String get otherVaultTitle => '另一个密码库的副本';

  @override
  String otherVaultHint(String when) {
    return '此文件夹中已有另一个 Keyhold 密码库的副本（最新的来自 $when）。要打开查看吗？您的密码库保持不变。';
  }

  @override
  String get copyPasswordTitle => '此副本的主密码';

  @override
  String get copyNotOpened => '无法打开副本：密码或恢复密钥错误，或者这不是 Keyhold 密码库。';

  @override
  String get openCopy => '打开备份副本…';

  @override
  String copyTitle(String name) {
    return '副本：$name';
  }

  @override
  String get copyReadOnly => '仅供查看：这里的操作不会改变您的密码库。可以将单个条目添加到您的密码库。';

  @override
  String get addToVault => '添加到我的密码库';

  @override
  String addedToVault(String name) {
    return '“$name”已在您的密码库中';
  }
}
