import 'package:flutter_test/flutter_test.dart';
import 'package:tunnel_plus/core/network/interceptors/certificate_pinning_interceptor.dart';
import 'package:tunnel_plus/core/services/battery_optimization_service.dart';
import 'package:tunnel_plus/core/services/security_check_service.dart';
import 'package:tunnel_plus/core/services/window_security_service.dart';

void main() {
  group('Security Hardening & Platform Services Tests', () {
    test('CertificatePinningManager recognizes valid pinned fingerprints', () {
      // Primary and backup pins from network_security_config.xml
      expect(
        CertificatePinningManager.isFingerprintPinned('FSgQx0u8n3p2kFj7wA2hM1tL9zR5cE8yX3pU2vQ1o8w='),
        isTrue,
      );
      expect(
        CertificatePinningManager.isFingerprintPinned('k2N9GNz4j2gkHNuUZePooEDOxW5lfBctq8YQGPPCy10='),
        isTrue,
      );

      // Random untrusted pin should be rejected
      expect(
        CertificatePinningManager.isFingerprintPinned('UNTRUSTED_AND_FAKE_PIN_1234567890123456789='),
        isFalse,
      );
    });

    test('SecurityCheckService evaluates security posture gracefully', () async {
      final posture = await SecurityCheckService.evaluateDeviceSecurityPosture();
      expect(posture.containsKey('is_rooted'), isTrue);
      expect(posture.containsKey('tamper_risk_level'), isTrue);
      expect(posture.containsKey('recommendation'), isTrue);
    });

    test('WindowSecurityService handles setSecureScreen without throwing', () async {
      final res = await WindowSecurityService.setSecureScreen(true);
      expect(res, isA<bool>());
    });

    test('BatteryOptimizationService queries optimization status without throwing', () async {
      final res = await BatteryOptimizationService.isBatteryOptimizationIgnored();
      expect(res, isA<bool>());
    });
  });
}
