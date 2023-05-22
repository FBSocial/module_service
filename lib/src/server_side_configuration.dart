import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lib_net/lib_net.dart';
import 'package:lib_utils/config/sp_service.dart';
import 'package:lib_utils/loggers.dart';

class ServerSideConfiguration {
  static ServerSideConfiguration instance = ServerSideConfiguration._();

  bool readHistoryPermissionEnabled = true;

  /// 我的-数字藏品 入口 是否打开, 默认关
  bool walletIsOpen = false;

  ///支付乐豆入口 是否打款, 默认关
  bool payIsOpen = false;

  /// 第三方支付(微信支付宝)是否打开
  /// 默认关 (1开启 0 关闭)
  bool thirdPayIsOpen = false;

  /// 是否显示第三方登录入口
  //苹果登录 默认关
  ValueNotifier<bool> appleLoginOpen = ValueNotifier(false);

  //微信登录 默认关
  ValueNotifier<bool> wechatLoginOpen = ValueNotifier(false);

  /// APP后台通知部分
  bool serverEnableNotiInBg = true;
  int maxNotiCountInBg = 5;
  int currentNotiCountInBg = 0;

  /// -none 无信息流入口  recommend 火山推荐  hot 按fanbook热度推荐 normal 85%的正常流量数据
  /// - 注：guild_id逻辑的优先级高于abtestBucketName，如果guild_id不等于0，那么abtestBucketName会返回空字符串
  String abtestBucketName = 'normal';

  /// - 发现tab是否可见
  RxBool isDiscoverTabVisible = false.obs;

  /// - 发现页功能用户黑名单,如果有值，则为黑名单服务器，发现页展示黑名单服务器的圈子内容
  RxString inGuildBlack = ''.obs;

  double singleMaxMoney = 20000; // 发送单个红包最大金额
  int maxNum = 2000; // 拼手气红包最多分成这么多份
  int period = 24 * 60 * 60; // 默认的红包过期时间24小时，服务器配置，单位为秒

  /// 配置链接黑名单
  UrlCheckEntity urlCheckEntity = UrlCheckEntity.defaultValue();

  String officialOperationBotId = "398308634552958976";

  late Future<Exception?> _requestFuture;

  /// 使用此 Future 确保已经完成了最新配置的加载
  Future<void> ensureRequestDone() => _requestFuture;

  ServerSideConfiguration._() {
    init();
  }

  static Completer<CommonSettingsRes>? _settingsCompleter;
  static CommonSettingsRes settings = CommonSettingsRes();

  static Future<CommonSettingsRes> getSettings([fetchRemote = false]) {
    if (!fetchRemote && _settingsCompleter != null) {
      return _settingsCompleter!.future;
    }

    final options = RetryOptions(
        retries: 100,
        retryInterval: const Duration(seconds: 5),
        retryEvaluator: (error) =>
            error.type != DioErrorType.cancel &&
            error.type != DioErrorType.response).toOptions();

    _settingsCompleter = Completer();
    CommonApi.getCommonSetting(
      onSuccess: (_settings) {
        _settingsCompleter!.complete(_settings);
        settings = _settings;
        SpService.instance.setInt(SP.videoMax, _settings.videoMax);
      },
      onFail: (code, message) {
        logger.severe('getCommonSetting fail: $code $message');
        _settingsCompleter!.completeError(Exception());
      },
      options: options,
    );
    return _settingsCompleter!.future;
  }

  Future<void> init() async {
    // 获取本地的发现页显示配置和黑名单
    _getDiscoverConfig();

    _requestFuture = CommonApi.prerequisiteConfig(onSuccess: (config) {
      walletIsOpen = config.walletBean;
      payIsOpen = config.leBean;

      serverEnableNotiInBg =
          config.notificationInfo?.enableNotDisturbBgNoti ?? true;
      maxNotiCountInBg = config.notificationInfo?.total ?? 5;

      appleLoginOpen.value = config.appleLogin == 1;
      wechatLoginOpen.value = config.wechatLogin == 1;
      thirdPayIsOpen = config.thirdPayIsOpen == 1;

      singleMaxMoney = config.redPack?.singleMaxMoney.toDouble() ?? 20000;
      maxNum = config.redPack?.maxNum ?? 2000;
      period = config.redPack?.period ?? 24 * 60 * 60;

      officialOperationBotId =
          config.officialOperationBotId ?? officialOperationBotId;

      debugPrint(
          'a=${appleLoginOpen.value}  w=${wechatLoginOpen.value} l=$payIsOpen');

      readHistoryPermissionEnabled = config.readHistory ?? true;

      urlCheckEntity = config.urlCheckEntity ?? UrlCheckEntity.defaultValue();
    });

    final exception = await _requestFuture;
    if (exception != null) {
      debugPrint("初始化服务端配置失败，将使用客户端默认配置。原因： $exception");
    }
  }

  /// - 写死的测试数据  获取本地的发现页显示配置和黑名单
  void _getDiscoverConfig() {
    isDiscoverTabVisible.value =
        SpService.instance.getBool(SP.isDiscoverTabVisible) ?? true;
    inGuildBlack.value = SpService.instance.getString(SP.inGuildBlack) ?? '';
    // todo: 临时数据
    // inGuildBlack.value =
    //     SpService.instance.getString(SP.inGuildBlack) ?? '165402542119849984';
  }

  /// - 更新保存到本地存储
  void getPersonalSetting() {
    CommonApi.getPersonalCommonSetting(onSuccess: (_settings) {
      final int inGuildBlackGuildId = _settings['guild_id'] as int? ?? 0;
      // abtest的字符串
      instance.abtestBucketName = _settings['bucket_name'] ?? 'none';
      // 没有命中黑名单逻辑或者是虽然命中但是同时在白名单中为0，否则为服务器id信息
      instance.inGuildBlack.value =
          inGuildBlackGuildId != 0 ? inGuildBlackGuildId.toString() : '';

      // 显不显示发现页入口
      //  none 无信息流入口  recommend 火山推荐  hot 按fanbook热度推荐 normal 85%的正常流量数据
      //  注：guild_id逻辑的优先级高于abtestBucketName，如果guild_id不等于0，那么abtestBucketName会返回空字符串
      instance.isDiscoverTabVisible.value =
          !(instance.inGuildBlack.value.isEmpty && abtestBucketName == 'none');

      // 更新本地数据
      SpService.instance.setBool(
          SP.isDiscoverTabVisible, instance.isDiscoverTabVisible.value);
      SpService.instance
          .setString(SP.inGuildBlack, instance.inGuildBlack.value);
    });
  }
}
