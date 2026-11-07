import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity _connectivity;
  final _controller = StreamController<bool>.broadcast();

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _connectivity.onConnectivityChanged.listen(_handleConnectivity);
  }

  Stream<bool> get isOnlineStream => _controller.stream;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  void _handleConnectivity(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    if (_isOnline != online) {
      _isOnline = online;
      _controller.add(online);
    }
  }

  Future<bool> checkIsOnline() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _isOnline = results.any((r) => r != ConnectivityResult.none);
      return _isOnline;
    } catch (_) {
      return true;
    }
  }

  void dispose() {
    _controller.close();
  }
}
