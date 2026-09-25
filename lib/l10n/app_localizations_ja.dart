// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get cancel => 'キャンセル';

  @override
  String get open => '開く';

  @override
  String get delete => '削除';

  @override
  String get copy => 'コピー';

  @override
  String get edit => '編集';

  @override
  String get add => '追加';

  @override
  String get search => '検索';

  @override
  String get settings => '設定';

  @override
  String get change => '変更';

  @override
  String get connect => '接続';

  @override
  String get disconnect => '接続を解除';

  @override
  String get unlock => 'ロック解除';

  @override
  String get noTitle => '（タイトルなし）';

  @override
  String get code => 'コード';

  @override
  String get codes => 'コード';

  @override
  String get username => 'ユーザー名';

  @override
  String get password => 'パスワード';

  @override
  String get address => 'アドレス';

  @override
  String get notes => 'メモ';

  @override
  String get duplicates => '重複';

  @override
  String get masterPassword => 'マスターパスワード';

  @override
  String get setMasterPassword => 'マスターパスワードを設定';

  @override
  String copied(String what) {
    return '$whatをコピーしました';
  }

  @override
  String get fingerprintTitle => 'Keyhold 保管庫';

  @override
  String get fingerprintUnlockHint => 'ロックを解除して、パスワードとコードを表示します';

  @override
  String get fingerprintConfirmHint => '指紋で確認してください';

  @override
  String driveNotConnected(String error) {
    return 'Google Drive に接続できませんでした：$error';
  }

  @override
  String get masterPasswordOfVault => '保管庫のマスターパスワード';

  @override
  String get masterPasswordFromComputer => 'パソコンの Keyhold で設定したパスワード';

  @override
  String get scanQr => 'QR コードをスキャン';

  @override
  String get scanQrHint => 'ウェブサイトの 2 段階認証コード、または Google Authenticator のエクスポート';

  @override
  String get newCode => '新しい 2 段階認証コード';

  @override
  String get newCodeHint => 'セットアップキーを手動で入力';

  @override
  String get newLogin => '新しいログイン情報';

  @override
  String get locked => 'Keyhold はロックされています';

  @override
  String get everything => 'すべて';

  @override
  String get noCodesYet => '2 段階認証コードはまだありません。+ をタップしてスキャンしてください';

  @override
  String get nothingYet => 'まだ何もありません';

  @override
  String get justNow => 'たった今';

  @override
  String minutesAgo(int count) {
    return '$count 分前';
  }

  @override
  String hoursAgo(int count) {
    return '$count 時間前';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 日前',
    );
    return '$_temp0';
  }

  @override
  String get notBackedUp => 'バックアップされていません — タップして Google Drive に接続';

  @override
  String get backingUp => 'バックアップ中…';

  @override
  String backupFailed(String error) {
    return 'バックアップに失敗しました：$error';
  }

  @override
  String get waitingFirstBackup => '最初のバックアップを待っています';

  @override
  String backedUpToDrive(String ago) {
    return 'Google Drive にバックアップ済み（$ago）';
  }

  @override
  String get phoneWelcome =>
      'パスワードと 2 段階認証コードを、パソコンと同じ保管庫で管理できます。ご自身の Google Drive を通じて常に同期されます。';

  @override
  String get connectDrive => 'Google Drive に接続';

  @override
  String get startEmpty => '空の保管庫で始める';

  @override
  String codeSeconds(int seconds) {
    return 'コード（$seconds 秒）';
  }

  @override
  String get driveOnlyPhone => '未接続です。保管庫はこのスマートフォンにしかありません。';

  @override
  String connectedAs(String email) {
    return '$email で接続中';
  }

  @override
  String connectedAsSynced(String email, String time) {
    return '$email で接続中 — 前回の同期：$time';
  }

  @override
  String get syncNow => '今すぐ同期';

  @override
  String get fingerprintLock => '指紋ロック';

  @override
  String get fingerprintSwitch => '指紋で Keyhold を開く';

  @override
  String get fingerprintSwitchHint =>
      '画面が消えたとき、またはアプリから離れて 1 分たつとロックされます。ログイン欄の下の候補は引き続き表示されます。';

  @override
  String get fillingPasswords => 'パスワードの自動入力';

  @override
  String get fillerOn =>
      'Keyhold がアプリやブラウザでログイン情報を自動入力します。ログイン欄の下の「Keyhold」をタップしてください。Chrome では「設定」→「自動入力サービス」→「別のサービスを使用して自動入力」も選択してください。';

  @override
  String get fillerOff => 'Keyhold がアプリやブラウザでログイン情報と 2 段階認証コードを自動入力できるようにします。';

  @override
  String get fillWithKeyhold => 'Keyhold でパスワードを自動入力';

  @override
  String get passwordSetPhone => '設定済みです。新しいデバイスでこの保管庫を開くときに使います。';

  @override
  String get passwordNotSetPhone => '未設定です。これがないと、新しいデバイスで保管庫を開けません。';

  @override
  String get deleteThisLogin => 'このログイン情報を削除しますか？';

  @override
  String deleteNamed(String name) {
    return '「$name」を削除しますか？';
  }

  @override
  String get noDuplicatesLeft => '重複はもうありません。';

  @override
  String get groupWeb => 'ウェブ';

  @override
  String get groupLocal => 'ローカルネットワーク';

  @override
  String get groupServers => 'サーバー';

  @override
  String get filterAll => 'すべて';

  @override
  String get filter2fa => '2FA';

  @override
  String get filterPasswords => 'パスワード';

  @override
  String get filterFiles => 'ファイル';

  @override
  String get groups => 'グループ';

  @override
  String get noGroup => 'グループなし';

  @override
  String moveCountToGroup(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件をグループに移動',
    );
    return '$_temp0';
  }

  @override
  String get newGroup => '新しいグループ';

  @override
  String get newGroupHint => '空欄にすると、どのグループからも外れます';

  @override
  String get move => '移動';

  @override
  String get clearSelection => '選択を解除';

  @override
  String selectedCount(int count) {
    return '$count 件選択中';
  }

  @override
  String get moveToGroup => 'グループに移動';

  @override
  String get addCodesFromQr => 'QR コードから 2 段階認証コードを追加';

  @override
  String get browserExtension => 'ブラウザ拡張機能';

  @override
  String get backup => 'バックアップ';

  @override
  String get importCsv => 'CSV からインポート';

  @override
  String get changeMasterPassword => 'マスターパスワードを変更';

  @override
  String get addFile => 'ファイルを追加';

  @override
  String get newEntry => '新規';

  @override
  String get checking => '確認中…';

  @override
  String get notCheckedYet => '未確認';

  @override
  String filesNew(int count) {
    return '新規 $count 件';
  }

  @override
  String filesChanged(int count) {
    return '変更 $count 件';
  }

  @override
  String filesSkipped(int count) {
    return 'スキップ $count 件';
  }

  @override
  String checkedNothingChanged(String when) {
    return '確認済み（$when）— 変更なし';
  }

  @override
  String checkedWith(String when, String changes) {
    return '確認済み（$when）— $changes';
  }

  @override
  String get watchedHint => '監視中 — 変更があれば 15 分ごとに保管庫へコピーされます';

  @override
  String get nothingWatched => 'まだ何も監視していません';

  @override
  String pathNotFound(String path) {
    return '$path — 見つかりません';
  }

  @override
  String get stopWatching => '監視を停止';

  @override
  String get watchFolder => 'フォルダを監視';

  @override
  String get watchFile => 'ファイルを監視';

  @override
  String get checkNow => '今すぐ確認';

  @override
  String fileTooBig(String name, String size) {
    return '「$name」のサイズは $size です。上限は 25 MB です';
  }

  @override
  String fileAdded(String name) {
    return '「$name」を保管庫に追加しました';
  }

  @override
  String savedTo(String path) {
    return '$path に保存しました';
  }

  @override
  String removeNamed(String name) {
    return '「$name」を削除しますか？';
  }

  @override
  String get removeFileHint => '保管庫から消えます。以前のバックアップには残ります。';

  @override
  String get remove => '削除';

  @override
  String get noFilesYet => 'ファイルはまだありません — リカバリーコード、鍵、スキャン画像などを追加できます';

  @override
  String get saveToDisk => 'ディスクに保存';

  @override
  String forWindow(String window) {
    return '「$window」用';
  }

  @override
  String get dismiss => '閉じる';

  @override
  String get noBackupYet => 'バックアップはまだありません — 最初の保存時に実行されます';

  @override
  String lastBackup(String ago) {
    return '前回のバックアップ：$ago';
  }

  @override
  String backedUpTo(String ago, String targets) {
    return 'バックアップ済み（$ago）— $targets';
  }

  @override
  String get driveNeedsPassword =>
      'Google Drive：「バックアップ」を開いてマスターパスワードを入力してください';

  @override
  String driveProblem(String problem) {
    return 'Google Drive：$problem';
  }

  @override
  String driveSynced(String ago) {
    return 'Google Drive：同期済み（$ago）';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件',
    );
    return '$_temp0';
  }

  @override
  String get select => '選択';

  @override
  String get typeCode => '前のウィンドウにコードを入力';

  @override
  String get typeLogin => 'ユーザー名とパスワードを入力';

  @override
  String get copyPassword => 'パスワードをコピー';

  @override
  String get save => '保存';

  @override
  String get off => 'オフ';

  @override
  String onWith(String detail) {
    return 'オン — $detail';
  }

  @override
  String get join => '参加';

  @override
  String get synced => '同期しました';

  @override
  String get alreadyInSync => 'すでに同期されています';

  @override
  String get fillHostFirst => '先にホストを入力してください';

  @override
  String get fillUserFirst => '先にユーザーを入力してください';

  @override
  String get pickKeyFirst => '先に秘密鍵ファイルを選択してください';

  @override
  String noFileAt(String path) {
    return '$path にファイルがありません';
  }

  @override
  String serverUnreachable(String host, String port) {
    return '$host のポート $port に接続できません。アドレスとポート、サーバーが起動しているかを確認してください。';
  }

  @override
  String serverRefusedKey(String user) {
    return 'サーバーがユーザー $user のこの鍵を拒否しました。対応する公開鍵がサーバーの authorized_keys に登録されているか確認してください。';
  }

  @override
  String get notAPrivateKey => 'このファイルは使用できる秘密鍵ではありません。';

  @override
  String cannotWriteFolder(String folder) {
    return 'ログインしましたが、「$folder」に書き込めません。別のフォルダを選択してください。';
  }

  @override
  String get driveHoldsVault =>
      'Google Drive にはすでに Keyhold の保管庫があります。参加するには、その保管庫のマスターパスワードが必要です。';

  @override
  String get masterPasswordOfDriveVault => 'Google Drive にある保管庫のマスターパスワード';

  @override
  String get driveHint =>
      '暗号化された保管庫を、ご自身の Google Drive の「Keyhold」フォルダに保存します。ほかのデバイスとも同期され、パソコンをなくしても何も失われません。Google が中身を読むことはできません。';

  @override
  String get driveNotInBuild => 'このビルドでは Google Drive が設定されていません。';

  @override
  String get setPasswordFirst => '先にマスターパスワードを設定してください。新しいデバイスで保管庫を開くときに必要です。';

  @override
  String get foldersOnComputer => 'このパソコンのフォルダ';

  @override
  String folderCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個のフォルダ',
    );
    return '$_temp0';
  }

  @override
  String folderCountCopied(int count, String time) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 個のフォルダ — 前回のコピー：$time',
    );
    return '$_temp0';
  }

  @override
  String get yourServer => '自分のサーバー';

  @override
  String get foldersHint => '保存するたびに、日付入りのコピーを各フォルダに作成し、最新の 30 個を残します。';

  @override
  String get noFolders => 'フォルダなし — ローカルコピーはオフです';

  @override
  String get addFolder => 'フォルダを追加';

  @override
  String get serverHint =>
      '同じコピーを SFTP でご自身のマシンにも送ります。ファイルは暗号化されたままなので、サーバーに見えるのは読めないデータだけです。使わない場合は、ホストを空欄のままにしてください。';

  @override
  String get host => 'ホスト';

  @override
  String get port => 'ポート';

  @override
  String get user => 'ユーザー';

  @override
  String get privateKeyFile => '秘密鍵ファイル';

  @override
  String get chooseFile => 'ファイルを選択';

  @override
  String get serverFolder => 'サーバー上のフォルダ';

  @override
  String get testConnection => '接続をテスト';

  @override
  String get notReachable => '現在接続できません';

  @override
  String get enterCodeKey => '2 段階認証コードのキーを入力してください';

  @override
  String get twoFactorCode => '2 段階認証コード';

  @override
  String get newEntryTitle => '新しい項目';

  @override
  String get editEntry => '項目を編集';

  @override
  String get name => '名前';

  @override
  String get key => 'キー';

  @override
  String get keyHint => 'セットアップキーか、otpauth:// リンク全体を貼り付けてください';

  @override
  String get note => 'メモ';

  @override
  String get addresses => 'アドレス';

  @override
  String get codeNotUsedYet =>
      'まだどこにも使われていません。サイトで初めて使うと自動で固定されます。ログイン情報から固定することもできます。';

  @override
  String get noAddress => 'アドレスなし';

  @override
  String get unpin => '固定を解除';

  @override
  String get addAddress => 'アドレスを追加';

  @override
  String get title => 'タイトル';

  @override
  String get noName => '（名前なし）';

  @override
  String get none => 'なし';

  @override
  String get choose => '選択';

  @override
  String get group => 'グループ';

  @override
  String get groupHint => '選択するか、新しい名前を入力してください';

  @override
  String get driveTabConnected =>
      'Keyhold が Google Drive に接続されました。このタブは閉じてかまいません。';

  @override
  String get driveTabNotConnected => 'Google Drive に接続できませんでした。このタブは閉じてかまいません。';

  @override
  String get signInTooLong => 'Google へのログインに時間がかかりすぎました。もう一度お試しください';

  @override
  String get signInCancelled => 'Google へのログインがキャンセルされました';

  @override
  String get noOfflineAccess => 'Google がオフラインアクセスを許可しませんでした';

  @override
  String get noInternet => 'インターネットに接続されていません';

  @override
  String get wrongMasterPassword => 'マスターパスワードが違います';

  @override
  String driveRefusedDownload(String status) {
    return 'Google Drive がダウンロードを拒否しました（$status）';
  }

  @override
  String driveRefusedUpload(String status) {
    return 'Google Drive がアップロードを拒否しました（$status）';
  }

  @override
  String driveAnswered(String status) {
    return 'Google Drive の応答：$status';
  }

  @override
  String get driveSignInAgain => 'Google Drive にもう一度ログインしてください';

  @override
  String get driveNotConnectedError => 'Google Drive に接続されていません';

  @override
  String get driveAccessEnded => 'Google Drive へのアクセスが切れました。もう一度接続してください';

  @override
  String signInFailed(String status) {
    return 'Google へのログインに失敗しました（$status）';
  }

  @override
  String get dupNewest => '最新';

  @override
  String get dupSamePassword => '最新と同じパスワード';

  @override
  String get dupDifferentPassword => '異なるパスワード';

  @override
  String get noUsername => '（ユーザー名なし）';

  @override
  String duplicateNote(String username, String password, String day) {
    return '$username · $password · $day に変更';
  }

  @override
  String get fileEmpty => 'ファイルが空です';

  @override
  String get noLoginColumns => 'このファイルにユーザー名またはパスワードの列が見つかりません';

  @override
  String get noQrOnScreen => '画面に QR コードが見つかりません';

  @override
  String get noQrInImage => 'この画像に QR コードが見つかりません';

  @override
  String get qrNotTwoFactor => 'この QR コードは 2 段階認証コードではありません';

  @override
  String get exportQrEmpty => 'エクスポートの QR コードが空です';

  @override
  String get exportQrUnreadable => 'エクスポートの QR コードを読み取れませんでした';

  @override
  String serverWritable(String account) {
    return '$account で接続しました。フォルダに書き込めます';
  }

  @override
  String get openKeyhold => 'Keyhold を開く';

  @override
  String get quit => '終了';

  @override
  String codesFound(int count) {
    return '$count 件見つかりました';
  }

  @override
  String codesUnsupported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件は Keyhold でまだ生成できない種類のコードです',
    );
    return '$_temp0';
  }

  @override
  String savedAs(String name) {
    return '「$name」として保存しました';
  }

  @override
  String savedCodes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件のコードを保存しました',
    );
    return '$_temp0';
  }

  @override
  String get images => '画像';

  @override
  String get addCodes => '2 段階認証コードを追加';

  @override
  String get saveAll => 'すべて保存';

  @override
  String get qrHintPhone =>
      '2 段階認証をオンにしたときにウェブサイトに表示される QR コード、または Google Authenticator のエクスポート（「アカウントを移行」→「アカウントのエクスポート」）にカメラを向けてください。';

  @override
  String get qrHintComputer =>
      'QR コードを画面に表示してスキャンします。2 段階認証をオンにしたときにウェブサイトに表示されるコードや、Google Authenticator のエクスポート（「アカウントを移行」→「アカウントのエクスポート」）が使えます。コードの写真でもかまいません。';

  @override
  String get qrMicrosoftHint =>
      'Microsoft Authenticator はコードをエクスポートできません。サイトごとに 2 段階認証をいったんオフにしてから再びオンにし、表示された新しいコードをここでスキャンしてください。';

  @override
  String get scanCamera => 'カメラでスキャン';

  @override
  String get scanScreen => '画面をスキャン';

  @override
  String get openImage => '画像を開く';

  @override
  String get saved => '保存済み';

  @override
  String get alreadyInKeyhold => 'Keyhold に登録済み';

  @override
  String asName(String name) {
    return '「$name」として';
  }

  @override
  String get typePasswordFirst => '先にパスワードを入力してください';

  @override
  String get atLeast8 => '8 文字以上にしてください';

  @override
  String get passwordsDiffer => '2 つのパスワードが一致しません';

  @override
  String get passwordDoesNotOpen => 'そのパスワードではこの保管庫を開けません';

  @override
  String get currentPasswordWrong => '現在のマスターパスワードが違います';

  @override
  String get unlockVault => '保管庫のロックを解除';

  @override
  String get unlockHint => 'この保管庫は別のパソコンから移されたものです。ここで開くには、マスターパスワードを入力してください。';

  @override
  String get masterPasswordHint =>
      'この保管庫は Windows が自動で開きます。マスターパスワードは、再インストール後や新しいパソコン、スマートフォンで保管庫を開くときに使います。';

  @override
  String get currentMasterPassword => '現在のマスターパスワード';

  @override
  String get newMasterPassword => '新しいマスターパスワード';

  @override
  String get repeatIt => 'もう一度入力';

  @override
  String get openVault => '保管庫を開く';

  @override
  String get savePassword => 'パスワードを保存';

  @override
  String get nobodyCanRecover =>
      '忘れた場合、保管庫を開けるのはリカバリーキーだけです。リカバリーシートを印刷してください。';

  @override
  String get groupApps => 'アプリ';

  @override
  String get openKeyholdFirst => '一度 Keyhold を開いてマスターパスワードを入力してから、もう一度お試しください。';

  @override
  String pinTo(String name, String place) {
    return '「$name」を $place に固定しますか？';
  }

  @override
  String get pinHint => '固定すると、検索しなくてもここにすぐ表示されます。';

  @override
  String get doNotAskCode => 'このコードについて今後は確認しない';

  @override
  String get notNow => '今はしない';

  @override
  String get pin => '固定';

  @override
  String get savedToKeyhold => 'Keyhold に保存しました';

  @override
  String get passwordUpdated => 'Keyhold のパスワードを更新しました';

  @override
  String get searchAllLogins => 'すべてのログイン情報を検索';

  @override
  String get nothingFound => '見つかりませんでした。';

  @override
  String get noLoginForSite =>
      'このサイトのログイン情報はまだありません。上で検索するか、ログインすると Android が保存を提案します。';

  @override
  String get noLoginForApp =>
      'このアプリのログイン情報はまだありません。上で検索するか、ログインすると Android が保存を提案します。';

  @override
  String listening(String address) {
    return '$address で待機中';
  }

  @override
  String get notListening => '待機していません — 別の Keyhold がすでに実行中の可能性があります';

  @override
  String get pairingToken => 'ペアリングトークン';

  @override
  String get pairingTokenHint =>
      'これを拡張機能に一度だけ貼り付けてください。このトークン付きのリクエストにだけ、しかも拡張機能自体からの場合にのみ応答します。ウェブページから保管庫にアクセスすることはできません。';

  @override
  String get tokenCopied => 'トークンをコピーしました';

  @override
  String get copyToken => 'トークンをコピー';

  @override
  String get installIt => 'インストール';

  @override
  String get installChrome =>
      'Chrome または Edge：chrome://extensions を開き、「デベロッパー モード」をオンにして「パッケージ化されていない拡張機能を読み込む」をクリックし、下のフォルダを選択します。';

  @override
  String get installFirefox =>
      'Firefox：about:debugging#/runtime/this-firefox を開き、「一時的なアドオンを読み込む」をクリックして、そのフォルダ内の manifest.json を選択します。';

  @override
  String get installPaste => 'ツールバーの Keyhold アイコンをクリックして、トークンを貼り付けます。';

  @override
  String get newCodeShort => '新しいコード';

  @override
  String get free => '未固定';

  @override
  String get searchCodes => 'コードを検索';

  @override
  String get everyCodePinned => 'すべてのコードがどこかに固定されています。表示するには「すべて」に切り替えてください。';

  @override
  String get noCodesFound => 'コードが見つかりませんでした。';

  @override
  String pinnedTo(String hosts) {
    return '$hosts に固定';
  }

  @override
  String get notPinned => '未固定';

  @override
  String changedOn(String day) {
    return '$day に変更';
  }

  @override
  String get importPasswords => 'パスワードをインポート';

  @override
  String get importHint =>
      'ブラウザからパスワードを CSV 形式でエクスポートし、そのファイルをここで読み込みます。Chrome、Edge、Firefox、Bitwarden、KeePassXC のエクスポートに対応しています。';

  @override
  String get chooseCsv => 'CSV ファイルを選択';

  @override
  String entriesReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件をインポートできます',
    );
    return '$_temp0';
  }

  @override
  String entriesReadySkipped(int count, int skipped) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件をインポートできます',
    );
    String _temp1 = intl.Intl.pluralLogic(
      skipped,
      locale: localeName,
      other: '空の行 $skipped 件をスキップ',
    );
    return '$_temp0（$_temp1）';
  }

  @override
  String andMore(int count) {
    return 'ほか $count 件';
  }

  @override
  String get deleteCsv => 'インポート後に CSV ファイルを削除';

  @override
  String get deleteCsvHint => 'すべてのパスワードが暗号化されずに保存されています';

  @override
  String importEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件をインポート',
    );
    return '$_temp0';
  }

  @override
  String get cameraHint =>
      'ウェブサイトの 2 段階認証 QR コード、または Google Authenticator のエクスポートにカメラを向けてください。';

  @override
  String get deleteThisCode => 'この 2 段階認証コードを削除しますか？';

  @override
  String get deleteCodeWarning =>
      'すべてのデバイスから削除されます。このコードがないと、使用しているサイトにログインできなくなります。';

  @override
  String get deleteLoginWarning => 'すべてのデバイスから削除されます。';

  @override
  String nextCode(String code) {
    return '次：$code';
  }

  @override
  String get noMasterPasswordBar =>
      'マスターパスワードが未設定です。バックアップを別のパソコンで開けません。クリックして設定してください。';

  @override
  String get printRecoverySheet => 'リカバリーシートを印刷';

  @override
  String get recoverySheet => 'リカバリーシート';

  @override
  String get recoveryIntro =>
      'マスターパスワードを忘れたときは、このキーで保管庫を開けます。シートを印刷し、最後の行を手書きで書き写して、自宅に保管してください。';

  @override
  String get print => '印刷';

  @override
  String get done => '完了';

  @override
  String get sheetTitle => 'Keyhold リカバリーシート';

  @override
  String sheetMade(String date) {
    return '作成日：$date';
  }

  @override
  String get sheetWhere => '保管庫の保存場所';

  @override
  String sheetDrive(String email) {
    return '$email の Google Drive、「Keyhold」フォルダ';
  }

  @override
  String sheetFolders(String folders) {
    return 'フォルダ内のコピー：$folders';
  }

  @override
  String sheetServer(String host) {
    return 'サーバー $host 上のコピー';
  }

  @override
  String get sheetOnlyHere => 'このデバイスにしか保存されていません。Keyhold でバックアップをオンにしてください。';

  @override
  String get sheetSteps => '新しいパソコンやスマートフォンで';

  @override
  String get sheetStep1 => 'Keyhold をインストールします：galusz.github.io/keyhold';

  @override
  String get sheetStep2 => 'Keyhold で同じ Google Drive に接続します。';

  @override
  String get sheetStep3 =>
      'Keyhold にマスターパスワードを求められたら、このリカバリーキーを入力します。その後、新しいマスターパスワードを設定します。';

  @override
  String get sheetKeepSafe =>
      '記入済みのこのシートがあれば、誰でも保管庫を開けます。家の合鍵と同じように大切に保管してください。';

  @override
  String get sheetDriveNoEmail => 'Google Drive の「Keyhold」フォルダ';

  @override
  String get noBackupPlaces =>
      'バックアップ先のフォルダ、サーバー、Google Drive がありません。保管庫はこのパソコンにしかありません。クリックして設定します。';

  @override
  String get deleteVault => '保管庫を削除';

  @override
  String get deleteVaultHint =>
      'Keyhold がこのデバイスに保存しているすべてのもの（パスワード、2 段階認証コード、ファイル、設定）が消去されます。その後 Keyhold は終了し、空の状態で起動します。';

  @override
  String get deleteVaultDrive =>
      'Google Drive からも削除する（ほかのデバイスでは、そこで削除するまでコピーが残ります）';

  @override
  String get deleteVaultFolders => 'バックアップ先フォルダのコピーも削除する';

  @override
  String get deleteVaultSure => '保管庫を完全に削除しますか？';

  @override
  String get deleteVaultSureHint => 'この操作は元に戻せません。';

  @override
  String get vaultDeleted => '保管庫を削除しました。Keyhold を終了します。';

  @override
  String get recoveryGate => 'リカバリーキーを表示するには、マスターパスワードを入力してください。';

  @override
  String get showKey => 'キーを表示';

  @override
  String get recoveryNeedsPassword =>
      '先にマスターパスワードを設定してください。リカバリーキーは設定後に表示されます。';

  @override
  String get recoveryCopyRow => 'この行を、印刷したシートに手書きで書き写してください';

  @override
  String get checkRow => '次に、シートに書いたとおりに最後の行を入力してください';

  @override
  String get check => '確認';

  @override
  String get rowMatches => '一致しました。シートを安全な場所に保管してください。';

  @override
  String get rowDiffers => '一致しません。最後の行を画面と見比べて、シートを修正してください。';

  @override
  String get sheetKeyLabel => 'リカバリーキー';

  @override
  String get sheetCopyRow => '最後の行を Keyhold の画面からここに手書きで書き写してください。';

  @override
  String get orRecoveryCode => 'お忘れの場合は、代わりにリカバリーシートのリカバリーキーを入力してください。';

  @override
  String get newPasswordAfterKey =>
      'リカバリーキーで保管庫を開きました。新しいマスターパスワードを設定してください。すべてのデバイスで、忘れたパスワードの代わりに使われます。';

  @override
  String get otherVaultTitle => '別の保管庫のコピー';

  @override
  String otherVaultHint(String when) {
    return 'このフォルダには別の Keyhold 保管庫のコピーがすでにあります（最新は $when）。開いて中身を見ますか？あなたの保管庫はそのままです。';
  }

  @override
  String get copyPasswordTitle => 'このコピーのマスターパスワード';

  @override
  String get copyNotOpened =>
      'コピーを開けませんでした。パスワードかリカバリーキーが違うか、Keyhold の保管庫ではありません。';

  @override
  String get openCopy => 'バックアップのコピーを開く…';

  @override
  String copyTitle(String name) {
    return 'コピー：$name';
  }

  @override
  String get copyReadOnly => '閲覧のみです。ここでの操作で保管庫は変わりません。個別の項目を保管庫に追加できます。';

  @override
  String get addToVault => '自分の保管庫に追加';

  @override
  String addedToVault(String name) {
    return '「$name」は保管庫にあります';
  }
}
