import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter/material.dart';

/// WS 连接上时触发
class EventWsConnected {
  const EventWsConnected();
}

/// WS 断开上时触发
class EventWsDisconnected {
  const EventWsDisconnected();
}

/// 退出指定频道时触发
class EventChannelExited {
  final String? channelId;

  const EventChannelExited(this.channelId);
}

/// 退出指定服务器时触发（被移除时）
class EventGuildExited {
  final String guildId;

  const EventGuildExited(this.guildId);
}

/// 进入指定服务器时触发
class EventGuildEntered {
  final String guildId;

  const EventGuildEntered(this.guildId);
}

/// 聊天消息被撤回
class EventMessageInvalided {
  final String messageId;
  final String? operator;
  final String channelId;
  final List<String>? displayRoleId;

  const EventMessageInvalided(
    this.channelId,
    this.messageId,
    this.operator, {
    this.displayRoleId,
  });
}

class EventChannelFeatured {
  final String guildId;
  final String? channelId;

  const EventChannelFeatured(this.guildId, this.channelId);
}

///圈子子频道信息修改时同步信息
class EventCircleChannelModify {
  final String guildId;
  final String? channelId;

  const EventCircleChannelModify(this.guildId, this.channelId);
}

// IM 消息相关是事件
/// IM 产生了一条非实体消息，参见 [MessageType.isNonentity]
@immutable
class EventNonentityMessageSpawned<T> {
  final T message;

  const EventNonentityMessageSpawned(this.message);
}

class EventMessageRecalled extends EventMessageInvalided {
  const EventMessageRecalled(
      String channelId, String messageId, String? recalledBy)
      : super(channelId, messageId, recalledBy);
}

class EventMessageDeleted extends EventMessageInvalided {
  const EventMessageDeleted(
    String channelId,
    String messageId, {
    List<String>? displayRoleId,
  }) : super(
          channelId,
          messageId,
          null,
          displayRoleId: displayRoleId,
        );
}

class EventService<MessageType> {
  static late EventService instance = EventService._();

  final _stream = StreamController.broadcast();

  Stream get stream => _stream.stream;

  EventService._();

  @visibleForTesting
  EventService();

  void close() {
    _stream.close();
  }

  void addEvent(Object event) {
    _stream.add(event);
  }

  Stream<MessageType> get onNonentityMessageSpawned {
    return _stream.stream
        .where((event) => event is EventNonentityMessageSpawned)
        .map((event) => (event as EventNonentityMessageSpawned).message)
        .cast<MessageType>();
  }

  Stream<EventWsConnected> onWsConnected() {
    return _stream.stream
        .where((e) => e is EventWsConnected)
        .cast<EventWsConnected>();
  }

  Stream<EventWsDisconnected> onWsDisconnected() {
    return _stream.stream
        .where((e) => e is EventWsDisconnected)
        .cast<EventWsDisconnected>();
  }

  // onWsDisconnected

  Stream<EventChannelExited> onChannelExited(String? channelId) {
    return _stream.stream
        .where((e) => e is EventChannelExited && e.channelId == channelId)
        .cast<EventChannelExited>();
  }

  Stream<EventGuildExited> onGuildExited(String guildId) {
    return _stream.stream
        .where((e) => e is EventGuildExited && e.guildId == guildId)
        .cast<EventGuildExited>();
  }

  Stream<EventGuildEntered> onGuildEntered(String guildId) {
    return _stream.stream
        .where((e) => e is EventGuildEntered && e.guildId == guildId)
        .cast<EventGuildEntered>();
  }

  /// IM 消息失效时触发，如果不指定 [channelId] 则监听所有消息的失效
  /// 如果不指定 [messageId] 则只监听指定频道所有消息的失效
  /// 目前有两种情况会视为失效：
  /// 1. 撤回消息
  /// 2. 删除消息
  Stream<EventMessageInvalided> onMessageInvalided<T>([
    String? channelId,
    String? messageId,
  ]) {
    return StreamGroup.merge([
      _stream.stream.where((e) =>
          e is EventMessageInvalided &&
          (channelId == null || e.channelId == channelId) &&
          (messageId == null || e.messageId == messageId))
    ]).cast<EventMessageInvalided>();
  }

  /// 精选频道
  Stream<EventChannelFeatured> onChannelFeaturedChange(String guildId) {
    return _stream.stream
        .where((e) => e is EventChannelFeatured && e.guildId == guildId)
        .cast<EventChannelFeatured>();
  }

  ///圈子子频道信息修改的变化
  Stream<EventCircleChannelModify> onCircleChannelChange(String guildId) {
    return _stream.stream
        .where((e) => e is EventCircleChannelModify && e.guildId == guildId)
        .cast<EventCircleChannelModify>();
  }

  Stream<EventCircleLike> onCircleLike() {
    return _stream.stream
        .where((e) => e is EventCircleLike)
        .cast<EventCircleLike>();
  }
}

/// 圈子点赞或取消点赞
class EventCircleLike {
  final String userId;
  final bool liked;

  const EventCircleLike(this.userId, this.liked);
}
