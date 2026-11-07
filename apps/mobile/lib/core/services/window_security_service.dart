import 'package:flutter/services.dart';

/// Service to manage Android FLAG_SECURE window protection against screen capture,
/// recording, and recent-apps task switcher snapshots.
class WindowSecurityService {
  static const MethodChannel _channel = MethodChannel('com.ramez.tunnel_plus/security');

  /// Toggle FLAG_SECURE on the Android window.
  static Future<bool> setSecureScreen(bool enabled) async {
    try {
      final result = await _channel.invokeMethod<bool>('setSecureScreen', {'enabled': enabled});
      return result ?? false;
    } on MissingPluginException {
      // Gracefully no-op on non-Android platforms or in widget tests
      return false;
    } catch (_) {
      return false;
    }
  }
}
