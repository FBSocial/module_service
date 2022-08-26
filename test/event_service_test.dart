@Timeout(Duration(seconds: 1))
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:service/service.dart';

void main() {
  late EventService s;
  StreamSubscription? subscription;

  setUp(() {
    s = EventService();
  });
  tearDown(() {
    subscription?.cancel();
  });

  test("Listening for channel exiting", () {
    const id = "channel_id_0";
    const e = EventChannelExited(id);
    expect(s.onChannelExited(id), emitsInOrder([e, emitsDone]));
    s.addEvent(e);
    s.close();
  });

  test("Listener shouldn't be invoke due to wrong channel id", () async {
    const correctId = "channel_id_0";
    const wrongId = "channel_id_2";
    expect(s.onChannelExited(wrongId), emitsDone);
    s.addEvent(const EventChannelExited(correctId));
    s.close();
  });

  test("Listening for guild exiting", () {
    const id = "guild_id_0";
    const e = EventGuildExited(id);
    expect(s.onGuildExited(id), emitsInOrder([e, emitsDone]));
    s
      ..addEvent(e)
      ..close();
  });

  test("Listener shouldn't be invoke due to wrong guild id", () async {
    const correctId = "id_0";
    const wrongId = "id_2";
    const e = EventGuildExited(correctId);
    expect(s.onGuildExited(wrongId), emitsInOrder([emitsDone]));
    s
      ..addEvent(e)
      ..close();
  });

  test("Listening for the invalidation of specify message", () {
    const channelId = "channel_id_0";
    const messageId = "message_id_0";

    const e1 = EventMessageRecalled(channelId, messageId, "operator_0");
    const e2 = EventMessageDeleted(channelId, messageId);
    const e3 =
        EventMessageRecalled(channelId, 'another message id', 'operator_0');
    const e4 = EventMessageDeleted(channelId, 'another message id');

    expect(s.onMessageInvalided(channelId, messageId),
        emitsInOrder([e1, e2, emitsDone]));
    s
      ..addEvent(e1)
      ..addEvent(e2)
      ..addEvent(e3)
      ..addEvent(e4)
      ..close();
  });

  test("Listen to the invalidation of all messages on the specified channel",
      () {
    const channelId = "channel_id_0";

    const e1 = EventMessageRecalled(channelId, 'message_0', "operator_0");
    const e2 = EventMessageDeleted(channelId, 'message_1');
    const e3 =
        EventMessageRecalled('another channel', 'message_3', 'operator_0');
    const e4 = EventMessageDeleted('another channel', 'message_4');

    expect(s.onMessageInvalided(channelId), emitsInOrder([e1, e2, emitsDone]));
    s
      ..addEvent(e1)
      ..addEvent(e2)
      ..addEvent(e3)
      ..addEvent(e4)
      ..close();
  });

  test("Listen to the invalidation of all messages", () {
    const e1 = EventMessageRecalled('channel_0', 'message_0', "operator_0");
    const e2 = EventMessageDeleted('channel_1', 'message_1');
    const e3 = EventMessageRecalled('channel_2', 'message_2', 'operator_0');
    const e4 = EventMessageDeleted('channel_3', 'message_3');

    expect(s.onMessageInvalided(), emitsInOrder([e1, e2, e3, e4, emitsDone]));
    s
      ..addEvent(e1)
      ..addEvent(e2)
      ..addEvent(e3)
      ..addEvent(e4)
      ..close();
  });
}
