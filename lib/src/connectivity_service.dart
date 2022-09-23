import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

/// [ConnectivityService] 负责维护网络状态，业务方将不再使用 [Connectivity] 插件直接从
/// 硬件获取信息
class ConnectivityService {
  static late ConnectivityService instance = ConnectivityService._();

  final ValueNotifier<ConnectivityResult> _state =
      ValueNotifier(ConnectivityResult.none);

  /// 获取当前网络状态
  ConnectivityResult get state => _state.value;

  set state(ConnectivityResult state) {
    _state.value = state;
  }

  /// 网络是否被启用
  bool get enabled => state != ConnectivityResult.none;

  /// 网络是否被禁用
  bool get disabled => state == ConnectivityResult.none;

  late StreamSubscription<ConnectivityResult> _netSubscription;
  late Stream<ConnectivityResult> _onConnectivityChanged;

  /// 监听网络状态变化
  Stream<ConnectivityResult> get onConnectivityChanged =>
      _onConnectivityChanged.distinct();

  ConnectivityService._() {
    Connectivity().checkConnectivity().then((value) {
      _state.value = value;
    });

    _onConnectivityChanged = Connectivity().onConnectivityChanged;
    if (!_onConnectivityChanged.isBroadcast) {
      _onConnectivityChanged = _onConnectivityChanged.asBroadcastStream();
    }

    startListen();
  }

  void startListen() {
    _netSubscription = _onConnectivityChanged.listen((result) {
      _state.value = result;
    });
  }

  /// 如果网络启用，则直接返回，否则，将会在网络被启用时返回
  Future<void> waitUtilConnected() async {
    if (state != ConnectivityResult.none) return;
    final c = Completer();

    void callback() {
      c.complete();
      _state.removeListener(callback);
    }

    _state.addListener(callback);
    return c.future;
  }

  void close() {
    _netSubscription.cancel();
  }
}
