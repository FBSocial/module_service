// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prerequisite_config_api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuditResp _$AuditRespFromJson(Map<String, dynamic> json) => AuditResp(
      json['status'] as bool,
      json['code'] as int,
      json['message'] as String,
      json['desc'] as String,
      json['request_id'] as String,
      AuditRespData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuditRespToJson(AuditResp instance) => <String, dynamic>{
      'status': instance.status,
      'code': instance.code,
      'message': instance.message,
      'desc': instance.desc,
      'request_id': instance.requestId,
      'data': instance.data,
    };

AuditRespData _$AuditRespDataFromJson(Map<String, dynamic> json) =>
    AuditRespData(
      json['alipay'] == null
          ? null
          : Alipay.fromJson(json['alipay'] as Map<String, dynamic>),
      json['redbag'] == null
          ? null
          : RedPack.fromJson(json['redbag'] as Map<String, dynamic>),
      json['readHistory'] as bool?,
      _int2bool(json['ledou'] as int?),
      _int2bool(json['nft'] as int?),
      json['welogin'] as int?,
      json['applelogin'] as int?,
      json['notification'] == null
          ? null
          : BgNotification.fromJson(
              json['notification'] as Map<String, dynamic>),
      json['official_operation_bot_id'] as String?,
      json['setting'] == null
          ? null
          : UrlCheckEntity.fromJson(json['setting'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AuditRespDataToJson(AuditRespData instance) =>
    <String, dynamic>{
      'alipay': instance.alipay,
      'redbag': instance.redPack,
      'readHistory': instance.readHistory,
      'ledou': instance.leBean,
      'nft': instance.walletBean,
      'welogin': instance.wechatLogin,
      'applelogin': instance.appleLogin,
      'notification': instance.notificationInfo,
      'official_operation_bot_id': instance.officialOperationBotId,
      'setting': instance.urlCheckEntity,
    };

UrlCheckEntity _$UrlCheckEntityFromJson(Map<String, dynamic> json) =>
    UrlCheckEntity(
      checkHost: json['risk_domain'] as String?,
      checkInterceptUrl: json['risk_intercept_url'] as String?,
      isEnable: json['risk_switch'] == null
          ? false
          : _int2bool(json['risk_switch'] as int?),
    );

Map<String, dynamic> _$UrlCheckEntityToJson(UrlCheckEntity instance) =>
    <String, dynamic>{
      'risk_domain': instance.checkHost,
      'risk_intercept_url': instance.checkInterceptUrl,
      'risk_switch': instance.isEnable,
    };

BgNotification _$BgNotificationFromJson(Map<String, dynamic> json) =>
    BgNotification(
      enableNotDisturbBgNoti: json['open'] ?? true,
      total: json['total'] ?? 5,
    );

Map<String, dynamic> _$BgNotificationToJson(BgNotification instance) =>
    <String, dynamic>{
      'open': instance.enableNotDisturbBgNoti,
      'total': instance.total,
    };

Alipay _$AlipayFromJson(Map<String, dynamic> json) => Alipay(
      json['rule'] as String,
      json['max_len'] as int,
    );

Map<String, dynamic> _$AlipayToJson(Alipay instance) => <String, dynamic>{
      'rule': instance.rule,
      'max_len': instance.maxLen,
    };

RedPack _$RedPackFromJson(Map<String, dynamic> json) => RedPack(
      json['single_max_money'] as int,
      json['max_num'] as int,
      json['period'] as int,
    );

Map<String, dynamic> _$RedPackToJson(RedPack instance) => <String, dynamic>{
      'single_max_money': instance.singleMaxMoney,
      'max_num': instance.maxNum,
      'period': instance.period,
    };
