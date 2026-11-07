import 'package:flutter/services.dart';

/// Service to detect and guide battery optimization exemptions for uninterrupted VPN tunnels.
class BatteryOptimizationService {
  static const MethodChannel _channel = MethodChannel('com.ramez.tunnel_plus/security');

  /// Check whether battery optimization is currently ignored for Ramez Tunnel Plus.
  static Future<bool> isBatteryOptimizationIgnored() async {
    try {
      final result = await _channel.invokeMethod<bool>('isBatteryOptimizationIgnored');
      return result ?? false;
    } on MissingPluginException {
      return true; // Mock true in tests / desktop
    } catch (_) {
      return false;
    }
  }

  /// Trigger the system prompt asking the user to exempt Ramez Tunnel Plus from battery optimization.
  static Future<bool> requestIgnoreBatteryOptimization() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestIgnoreBatteryOptimization');
      return result ?? false;
    } on MissingPluginException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
