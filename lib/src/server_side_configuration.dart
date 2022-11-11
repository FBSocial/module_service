import 'package:flutter/widgets.dart';
import 'package:lib_net/lib_net.dart';

class ServerSideConfiguration {
  static ServerSideConfiguration instance = ServerSideConfiguration._();

  bool readHistoryPermissionEnabled = true;

  /// 我的-数字藏品 入口 是否打开, 默认关
  bool walletIsOpen = false;

  ///支付乐豆入口 是否打款, 默认关
  bool payIsOpen = false;

  /// 是否显示第三方登录入口
  //苹果登录 默认关
  ValueNotifier<bool> appleLoginOpen = ValueNotifier(false);

  //微信登录 默认关
  ValueNotifier<bool> wechatLoginOpen = ValueNotifier(false);

  /// APP后台通知部分
  bool serverEnableNotiInBg = true;
  int maxNotiCountInBg = 5;
  int currentNotiCountInBg = 0;

  double singleMaxMoney = 20000; // 发送单个红包最大金额
  int maxNum = 2000; // 拼手气红包最多分成这么多份
  int period = 24 * 60 * 60; // 默认的红包过期时间24小时，服务器配置，单位为秒

  /// 腾讯文档参数
  String? tcDocEnvId;
  String? tcDocEnvName;

  /// 临时字段，禁用excel批注，默认值为false
  bool disableExcelComment = false;

  /// 配置链接黑名单
  UrlCheckEntity urlCheckEntity = const UrlCheckEntity();

  String officialOperationBotId = "398308634552958976";

  late Future<Exception?> _requestFuture;

  /// 使用此 Future 确保已经完成了最新配置的加载
  Future<void> ensureRequestDone() => _requestFuture;

  ServerSideConfiguration._() {
    init();
  }

  Future<void> init() async {
    _requestFuture = CommonApi.prerequisiteConfig(onSuccess: (config) {
      walletIsOpen = config.walletBean;
      payIsOpen = config.leBean;

      serverEnableNotiInBg =
          config.notificationInfo?.enableNotDisturbBgNoti ?? true;
      maxNotiCountInBg = config.notificationInfo?.total ?? 5;

      appleLoginOpen.value = config.appleLogin == 1;
      wechatLoginOpen.value = config.wechatLogin == 1;

      singleMaxMoney = config.redPack?.singleMaxMoney.toDouble() ?? 20000;
      maxNum = config.redPack?.maxNum ?? 2000;
      period = config.redPack?.period ?? 24 * 60 * 60;

      officialOperationBotId =
          config.officialOperationBotId ?? officialOperationBotId;

      debugPrint(
          'a=${appleLoginOpen.value}  w=${wechatLoginOpen.value} l=$payIsOpen');

      readHistoryPermissionEnabled = config.readHistory ?? true;

      urlCheckEntity = config.urlCheckEntity ?? const UrlCheckEntity();
    });

    final exception = await _requestFuture;
    if (exception != null) {
      debugPrint("初始化服务端配置失败，将使用客户端默认配置。原因： $exception");
    }
  }
}
