import 'package:shared_preferences/shared_preferences.dart';

// Shared Preferences key enum
enum SP {
  useHttps,
  useProxy,
  lastGuildCalcTime,

  /// 是否首次打开App
  isFirstOpenApp,
  userInfoSharedKey,
  networkEnvSharedKey,
  proxySharedKey,
  token,
  loginTime,
  country,
  checkProtocol,
  rememberPwd,
  needUpdate,
  updatePeriod,
  accessKey,
  isCleaningChatCache,
  cosAuth,
  publishMoment,
  checkNotificationPermission,
  isFirstLoadRedPacket,
  unModifyInfo,
  guildNotification, //通知引导
  inviteUrl, //邀请链接
  agreedProtocals, // 用户是否点击了隐私弹窗同意
  protocalHash, // 保存隐私协议hash值，用于判断隐私协议是否有更新
  isFirstOpenImagePicker, //首次打开相册
  isFirstOpenCamera, //首次打开相机
  isFirstRecord, //首次发语音
  inviteCode, // 邀请码
  isFirsPopRedPacket, // 本地第一次弹出“点亮红包功能”
  appVersion, //app版本号
  isFirstSetBotCommand, // 是否首次设置频道快捷指令
  preCompactAllBoxTime, // 压缩清理 box
  videoMax, //ama视频频道服务配置设置最大人数
  showLoggerPrint, //release模式是否开启日志打印
}

/// Shared Preferences Service
class SpService {
  static late SpService instance = SpService._();

  /// 获取原始的 [SharedPreferences] 引用，仅在特殊情况使用
  SharedPreferences? get rawSp => _sp;
  SharedPreferences? _sp;
  late Future<SharedPreferences> _initializedFuture;

  SpService._() {
    _initializedFuture = SharedPreferences.getInstance();
    _initializedFuture.then((value) => _sp = value);
  }

  Future<void> ensureInitialized() => _initializedFuture;

  Set<String> getKeys() => _sp!.getKeys();

  /// get
  bool containsKey(SP key) => _sp!.containsKey(_enum2String(key));

  Object? get(SP key) => _sp!.get(_enum2String(key));

  bool? getBool(SP key) => _sp!.getBool(_enum2String(key));

  int? getInt(SP key) => _sp!.getInt(_enum2String(key));

  int? getInt2(String key) => _sp!.getInt(key);

  double? getDouble(SP key) => _sp!.getDouble(_enum2String(key));

  String? getString(SP key) => _sp!.getString(_enum2String(key));

  /// set
  Future<bool> setBool(SP key, bool value) =>
      _sp!.setBool(_enum2String(key), value);

  Future<bool> setInt(SP key, int value) =>
      _sp!.setInt(_enum2String(key), value);

  Future<bool> setDouble(SP key, double value) =>
      _sp!.setDouble(_enum2String(key), value);

  Future<bool> setString(SP key, String value) =>
      _sp!.setString(_enum2String(key), value);

  Future<bool> setStringList(SP key, List<String> value) =>
      _sp!.setStringList(_enum2String(key), value);

  Future<bool> remove(SP key) => _sp!.remove(_enum2String(key));

  Future<bool> clear() => _sp!.clear();

  Future<void> reload() => _sp!.reload();

  String _enum2String(SP sp) {
    /// 早期已经存在的 key 保持旧的格式，新的直接用枚举
    switch (sp) {
      case SP.isFirstOpenApp:
        return "isFirstOpenApp";
      case SP.userInfoSharedKey:
        return "UserInfo_2";
      case SP.networkEnvSharedKey:
        return "NetworkEnv";
      case SP.proxySharedKey:
        return "Proxy";
      case SP.token:
        return "token";
      case SP.loginTime:
        return "login_time";
      case SP.country:
        return "country";
      case SP.checkProtocol:
        return "checkProtocol";
      case SP.rememberPwd:
        return "rememberPwd";
      case SP.needUpdate:
        return "need_update";
      case SP.updatePeriod:
        return "update_period";
      case SP.accessKey:
        return "access_key";
      case SP.isCleaningChatCache:
        return "isCleaningChatCache";
      case SP.cosAuth:
        return "cos-auth";
      case SP.publishMoment:
        return "publish_moment";
      case SP.checkNotificationPermission:
        return "checkNotificationPermission";
      case SP.isFirstLoadRedPacket:
        return 'isFirstLoadRedPacket';
      case SP.isFirstOpenImagePicker:
        return 'isFirstOpenImagePicker';
      case SP.isFirstOpenCamera:
        return 'isFirstOpenCamera';
      case SP.isFirstRecord:
        return 'isFirstRecord';
      case SP.unModifyInfo:
        return 'unModifyInfo';
      case SP.inviteUrl:
        return 'inviteUrl';
      case SP.isFirstSetBotCommand:
        return 'isFirstSetBotCommand';
      case SP.showLoggerPrint:
        return "showLoggerPrint";
      default:
        return sp.toString();
    }
  }
}
