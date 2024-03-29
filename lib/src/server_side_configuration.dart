import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lib_entity/global.dart';
import 'package:lib_net/lib_net.dart';
import 'package:lib_utils/config/sp_service.dart';
import 'package:lib_utils/loggers.dart';
import 'package:lib_utils/universal_platform.dart';

class ServerSideConfiguration {
  static ServerSideConfiguration instance = ServerSideConfiguration._();

  /// 我的-数字藏品 入口 是否打开, 默认关
  bool walletIsOpen = false;

  /// 第三方支付(微信支付宝)是否打开
  bool thirdPayIsOpen = false; // 默认关 (1开启 0 关闭)

  /// 是否显示第三方登录入口
  ValueNotifier<bool> appleLoginOpen = ValueNotifier(false); //苹果登录 默认关
  ValueNotifier<bool> wechatLoginOpen =
      ValueNotifier(UniversalPlatform.isAndroid); //微信登录 android 默认开 - iOS 默认关

  /// APP后台通知部分
  bool serverEnableNotiInBg = true;
  int maxNotiCountInBg = 5;
  int currentNotiCountInBg = 0;
  // -none 无信息流入口  recommend 火山推荐  hot 按fanbook热度推荐 normal 85%的正常流量数据
  // - 注：guild_id逻辑的优先级高于abtestBucketName，如果guild_id不等于0，那么abtestBucketName会返回空字符串
  RxString abtestBucketName = ''.obs;
  RxString inGuildBlack = ''.obs; // - 发现页功能用户黑名单,如果有值，则为黑名单服务器，发现页展示黑名单服务器的圈子内容
  double singleMaxMoney = 20000; // 发送单个红包最大金额
  int maxNum = 2000; // 拼手气红包最多分成这么多份
  int period = 24 * 60 * 60; // 默认的红包过期时间24小时，服务器配置，单位为秒
  UrlCheckEntity urlCheckEntity = UrlCheckEntity.defaultValue();

  /// 配置链接黑名单
  String officialOperationBotId = "398308634552958976";

  static Completer<CommonSettingsRes>? _settingsCompleter;
  static CommonSettingsRes settings = CommonSettingsRes();
  static Completer<bool>? _initCompleter;

  ServerSideConfiguration._();

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
        if (_settings.shareHostSetting != null) {
          Global.shareHost = _settings.shareHostSetting?.host;
          Global.cardHosts = _settings.shareHostSetting?.cardHosts ?? {};
          logger.info('------- init shareHost ok.');
        }
        if (_settings.circleConfig != null) {
          Global.postTagLimit = _settings.circleConfig?.postTagLimit ?? 0;
          Global.postAtLimit = _settings.circleConfig?.postAtLimit ?? 0;
        }
        settings = _settings;
        SpService.instance.setInt(SP.videoMax, _settings.videoMax);
        //  缓存AI舆情屏蔽文案
        if (_settings.aiBanTips?.isNotEmpty ?? false) {
          Global.shieldContentMsgs = _settings.aiBanTips!.split(";");
        }
      },
      onFail: (code, message) {
        logger.severe('getCommonSetting fail: $code $message');
        _settingsCompleter!.completeError(Exception());
      },
      options: options,
    );
    return _settingsCompleter!.future;
  }

  Future<bool> init() async {
    if (_initCompleter != null && await _initCompleter!.future) return true;

    // 获取本地的发现页显示配置和黑名单
    abtestBucketName.value =
        SpService.instance.getString(SP.bucketName) ?? 'normal';
    inGuildBlack.value = SpService.instance.getString(SP.inGuildBlack) ?? '';

    _initCompleter = Completer();
    final exception = await CommonApi.prerequisiteConfig(
      onSuccess: (config) {
        walletIsOpen = config.walletBean;
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

        urlCheckEntity = config.urlCheckEntity ?? UrlCheckEntity.defaultValue();
        _initCompleter?.complete(true);
      },
      onFail: (errCrode, errMsg) => _initCompleter?.complete(false),
    ).timeout(5.seconds).catchError((e) {
      _initCompleter?.complete(false);
      return e;
    });

    if (exception != null) logger.info("初始化服务端配置失败，将使用客户端默认配置。原因： $exception");
    return _initCompleter!.future;
  }

  /// - 更新保存到本地存储
  void getPersonalSetting() {
    CommonApi.getPersonalCommonSetting(onSuccess: (_settings) {
      // 黑名单服务器id
      final int inGuildBlackGuildId = _settings['guild_id'] as int? ?? 0;
      // abtest的字符串
      final String bucketName = _settings['bucket_name'] ?? 'normal';

      // 没有命中黑名单逻辑或者是虽然命中但是同时在白名单中为0，否则为服务器id信息
      inGuildBlack.value =
          inGuildBlackGuildId != 0 ? inGuildBlackGuildId.toString() : '';

      // 显不显示发现页入口
      //  none 无信息流入口  recommend 火山推荐  hot 按fanbook热度推荐 normal 85%的正常流量数据
      //  注：guild_id逻辑的优先级高于abtestBucketName，如果guild_id不等于0，那么abtestBucketName会返回空字符串

      // 有变化才更新
      if (abtestBucketName.value != bucketName) {
        // 通知相关接口进行重新获取数据
        abtestBucketName.value = bucketName;
      }
      if (bucketName.isEmpty) {
        // 如果为空，采用兜底策略
        abtestBucketName.value = 'normal';
      }

      // 更新本地数据
      SpService.instance.setString(SP.bucketName, abtestBucketName.value);
      SpService.instance.setString(SP.inGuildBlack, inGuildBlack.value);
    }, onFail: (errCode, errMsg) {
      // 接口失败，采用兜底策略，让用户获取normal桶中的数据
      abtestBucketName.value = 'normal';
    });
  }

  /// 退出登录将abtest的恢复成默认
  void setAbtestDefault() {
    abtestBucketName.value = 'normal';
    inGuildBlack.value = '';
    SpService.instance.setString(SP.bucketName, abtestBucketName.value);
    SpService.instance.setString(SP.inGuildBlack, inGuildBlack.value);
  }

  /// 动态上热门是否使用彩虹规则；圈子列表加载是否使用彩虹规则（AB test）
  bool isCircleUseCaiHongHot(String guildId) {
    return settings.abtestHotCircle == 2 ||
        (settings.abtestHotCircle == 1 &&
            settings.abtestGuilds.contains(guildId));
  }

  /// 获取新是分享host(有值则采用新host的创建统一格式的分享链接)
  String getShareHost() {
    final ShareHostSetting? shareHostSetting = settings.shareHostSetting;
    return shareHostSetting?.host ?? '';
  }

  /// 新的分享卡片解析host(用于匹配分享链接成卡片类型的消息)
  Set<String> getCardHosts() {
    final ShareHostSetting? shareHostSetting = settings.shareHostSetting;
    return shareHostSetting?.cardHosts ?? {};
  }
}
