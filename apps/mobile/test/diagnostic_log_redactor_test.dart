import 'package:flutter_test/flutter_test.dart';
import 'package:tunnel_plus/core/services/diagnostic_log_redactor.dart';

void main() {
  group('DiagnosticLogRedactor Hardening & Privacy Tests', () {
    test('Redacts IPv4 and IPv6 addresses correctly', () {
      const input = 'Client connected from 192.168.1.100 and dns 8.8.8.8 with ipv6 2001:0db8:85a3::8a2e:0370:7334';
      final result = DiagnosticLogRedactor.redact(input);

      expect(result.contains('192.168.1.100'), isFalse);
      expect(result.contains('8.8.8.8'), isFalse);
      expect(result.contains('2001:0db8:85a3::8a2e:0370:7334'), isFalse);
      expect(result.contains('[REDACTED_IP]'), isTrue);
      expect(result.contains('[REDACTED_IPV6]'), isTrue);
    });

    test('Redacts device hardware UUIDs and email addresses', () {
      const input = 'Device uuid: 34597a6a-1020-4953-b830-ef816480098a registered for admin@rameztunnel.com';
      final result = DiagnosticLogRedactor.redact(input);

      expect(result.contains('34597a6a-1020-4953-b830-ef816480098a'), isFalse);
      expect(result.contains('admin@rameztunnel.com'), isFalse);
      expect(result.contains('[REDACTED_UUID]'), isTrue);
      expect(result.contains('[REDACTED_EMAIL]'), isTrue);
    });

    test('Redacts WireGuard PrivateKey and PublicKey', () {
      const input = '''
[Interface]
PrivateKey = aGVsbG93b3JsZHRlc3Rwcml2YXRla2V5MTIzNDU2Nzg5MDE=
Address = 10.0.0.2/24

[Peer]
PublicKey = dGVzdHB1YmxpY2tleTEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI=
Endpoint = 142.250.190.46:51820
''';
      final result = DiagnosticLogRedactor.redact(input);

      expect(result.contains('aGVsbG93b3JsZHRlc3Rwcml2YXRla2V5MTIzNDU2Nzg5MDE='), isFalse);
      expect(result.contains('dGVzdHB1YmxpY2tleTEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI='), isFalse);
      expect(result.contains('[REDACTED_WG_KEY]'), isTrue);
    });

    test('Redacts PEM certificates and SSH private key blocks', () {
      const input = '''
<ca>
-----BEGIN CERTIFICATE-----
MIIBkTCB+wIBADANBgkqhkiG9w0BAQsFADARMQ8wDQYDVQQDEwZSb290Q0E=
-----END CERTIFICATE-----
</ca>
<key>
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC7...
-----END PRIVATE KEY-----
</key>
''';
      final result = DiagnosticLogRedactor.redact(input);

      expect(result.contains('BEGIN CERTIFICATE'), isFalse);
      expect(result.contains('BEGIN PRIVATE KEY'), isFalse);
      expect(result.contains('[REDACTED_CRYPTO_BLOCK]'), isTrue);
    });

    test('Redacts SSH URI passwords and Bearer tokens', () {
      const input = 'Tunneling ssh://admin:SuperSecretPass123@178.62.204.30:22 with bearer: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9';
      final result = DiagnosticLogRedactor.redact(input);

      expect(result.contains('SuperSecretPass123'), isFalse);
      expect(result.contains('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'), isFalse);
      expect(result.contains('[REDACTED_PASS]'), isTrue);
      expect(result.contains('[REDACTED_SECRET]'), isTrue);
    });
  });
}
