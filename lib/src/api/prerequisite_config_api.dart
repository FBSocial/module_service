import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:lib_utils/config/sp_service.dart';

part 'prerequisite_config_api.g.dart';

bool _int2bool(int? json) => json == 1;

@JsonSerializable()
class AuditResp {
  final bool status;
  final int code;
  final String message;
  final String desc;
  @JsonKey(name: "request_id")
  final String requestId;
  final AuditRespData data;

  AuditResp(this.status, this.code, this.message, this.desc, this.requestId,
      this.data);

  factory AuditResp.fromJson(Map<String, dynamic> json) =>
      _$AuditRespFromJson(json);

  Map<String, dynamic> toJson() => _$AuditRespToJson(this);
}

@JsonSerializable()
class AuditRespData {
  final Alipay? alipay;
  @JsonKey(name: "redbag")
  final RedPack? redPack;
  final bool? readHistory;
  @JsonKey(name: "ledou", fromJson: _int2bool)
  final bool leBean;
  @JsonKey(name: "nft", fromJson: _int2bool)
  final bool walletBean;
  @JsonKey(name: "welogin")
  final int? wechatLogin;
  @JsonKey(name: "applelogin")
  final int? appleLogin;
  @JsonKey(name: "notification")
  final BgNotification? notificationInfo;
  @JsonKey(name: "official_operation_bot_id")
  final String? officialOperationBotId;
  @JsonKey(name: "setting")
  final UrlCheckEntity? urlCheckEntity;

  AuditRespData(
      this.alipay,
      this.redPack,
      this.readHistory,
      this.leBean,
      this.walletBean,
      this.wechatLogin,
      this.appleLogin,
      this.notificationInfo,
      this.officialOperationBotId,
      this.urlCheckEntity); // 链接黑名单配置项

  factory AuditRespData.fromJson(Map<String, dynamic> json) =>
      _$AuditRespDataFromJson(json);

  Map<String, dynamic> toJson() => _$AuditRespDataToJson(this);
}

@JsonSerializable()
class UrlCheckEntity {
  @JsonKey(name: "risk_domain")
  final String? checkHost;
  @JsonKey(name: "risk_intercept_url")
  final String? checkInterceptUrl;
  @JsonKey(name: "risk_switch", fromJson: _int2bool)
  final bool isEnable;

  const UrlCheckEntity({
    this.checkHost,
    this.checkInterceptUrl,
    this.isEnable = false,
  });

  factory UrlCheckEntity.fromJson(Map<String, dynamic> json) =>
      _$UrlCheckEntityFromJson(json);

  Map<String, dynamic> toJson() => _$UrlCheckEntityToJson(this);
}

@immutable
@JsonSerializable()
class BgNotification {
  @JsonKey(name: "open", defaultValue: true)
  final bool enableNotDisturbBgNoti = true;
  @JsonKey(defaultValue: 5)
  final int total = 5;

  const BgNotification({enableNotDisturbBgNoti = true, total = 5});

  factory BgNotification.fromJson(Map<String, dynamic> json) =>
      _$BgNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$BgNotificationToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Alipay {
  final String rule;
  final int maxLen;

  Alipay(this.rule, this.maxLen);

  factory Alipay.fromJson(Map<String, dynamic> json) => _$AlipayFromJson(json);

  Map<String, dynamic> toJson() => _$AlipayToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RedPack {
  final int singleMaxMoney; // 发送单个红包最大金额
  final int maxNum;
  final int period;

  RedPack(this.singleMaxMoney, this.maxNum, this.period);

  factory RedPack.fromJson(Map<String, dynamic> json) =>
      _$RedPackFromJson(json);

  Map<String, dynamic> toJson() => _$RedPackToJson(this);
}

class PrerequisiteConfigApi {
  static Future<AuditRespData> doRequest() async {
    final client = HttpClient();
    final request =
        await client.postUrl(Uri.https(await _getHost(), '/api/common/alipay'));
    final resp = await request.close();
    final json = await resp.transform(utf8.decoder).join();
    final result = AuditResp.fromJson(jsonDecode(json));
    if (result.status) {
      return result.data;
    } else {
      throw Exception(result.desc);
    }
  }

  static Future<String> _getHost() async {
    // TODO 待 http 模块提供后，从 http 模块获取
    const _hosts = {
      0: "a1-dev.fanbook.mobi", // 开发环境
      1: "a1-test.fanbook.mobi", // 开发环境2
      2: "a1-newtest.fanbook.mobi", // 测试环境
      3: "a1-fat.fanbook.mobi", // 测试环境
      4: "a1-pre.fanbook.mobi", // 预发布环境
      5: "a1.fanbook.mobi", // 正式环境
    };
    await SpService.instance.ensureInitialized();
    final env = SpService.instance.getInt(SP.networkEnvSharedKey);
    return _hosts[env] ?? _hosts[5]!;
  }
}
