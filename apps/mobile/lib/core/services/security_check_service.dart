import 'package:flutter/services.dart';

/// Service providing informational device integrity signals.
/// Per project architecture guidelines, root/tamper detection is used
/// strictly as an informational signal without blocking legitimate user access.
class SecurityCheckService {
  static const MethodChannel _channel = MethodChannel('com.ramez.tunnel_plus/security');

  /// Check if the Android device exhibits signs of root access.
  static Future<bool> isDeviceRooted() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkRootStatus');
      return result ?? false;
    } on MissingPluginException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Evaluates overall device posture for diagnostic logs or security advisory warnings.
  static Future<Map<String, dynamic>> evaluateDeviceSecurityPosture() async {
    final rooted = await isDeviceRooted();
    return {
      'is_rooted': rooted,
      'tamper_risk_level': rooted ? 'ELEVATED' : 'LOW',
      'recommendation': rooted
          ? 'Root access detected. Use caution with sensitive tunnel credentials and keys.'
          : 'Standard operational environment.',
    };
  }
}
