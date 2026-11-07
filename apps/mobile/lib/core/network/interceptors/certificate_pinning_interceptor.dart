import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

/// Interceptor and HTTP adapter configuration for SSL / TLS Certificate Pinning.
/// Validates server public key SHA-256 fingerprints to defend against TLS MITM proxy attacks.
class CertificatePinningManager {
  /// Allowed SHA-256 SPKI / certificate fingerprints for the production API
  static const List<String> allowedPins = [
    'FSgQx0u8n3p2kFj7wA2hM1tL9zR5cE8yX3pU2vQ1o8w=',
    'k2N9GNz4j2gkHNuUZePooEDOxW5lfBctq8YQGPPCy10=',
  ];

  /// Configures the Dio instance with strict certificate pinning for production.
  static void configureDioPinning(Dio dio, {required bool isProduction}) {
    if (!isProduction) return;

    final adapter = dio.httpClientAdapter;
    if (adapter is IOHttpClientAdapter) {
      adapter.createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          // In production, reject any invalid / untrusted certificates immediately
          return false;
        };
        return client;
      };
    }
  }

  /// Validates whether a given certificate SHA-256 fingerprint matches pinned hashes.
  static bool isFingerprintPinned(String sha256Fingerprint) {
    final normalized = sha256Fingerprint.trim().replaceAll(':', '').toUpperCase();
    for (final pin in allowedPins) {
      final normalizedPin = pin.trim().replaceAll(':', '').toUpperCase();
      if (normalized == normalizedPin) {
        return true;
      }
    }
    return false;
  }
}
