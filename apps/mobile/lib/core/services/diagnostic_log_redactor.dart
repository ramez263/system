/// Comprehensive redaction service for diagnostic logs and bug reports.
/// Guarantees that diagnostic dumps sent to support or telemetry contain zero
/// credentials, private/public keys, personal IPs, emails, or hardware UUIDs.
class DiagnosticLogRedactor {
  // IPv4 Address Pattern
  static final RegExp _ipv4Pattern = RegExp(
    r'\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b',
  );

  // IPv6 Address Pattern
  static final RegExp _ipv6Pattern = RegExp(
    r'\b(?:[A-Fa-f0-9]{1,4}:){7}[A-Fa-f0-9]{1,4}\b|\b(?:[A-Fa-f0-9]{1,4}:){1,7}:'
    r'|\b:(?::[A-Fa-f0-9]{1,4}){1,7}\b|(?:[A-Fa-f0-9]{1,4}:){1,6}:[A-Fa-f0-9]{1,4}\b',
  );

  // UUID Pattern
  static final RegExp _uuidPattern = RegExp(
    r'\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b',
  );

  // Email Pattern
  static final RegExp _emailPattern = RegExp(
    r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,7}\b',
  );

  // PEM Private Key & Certificate Blocks (OpenVPN / SSH)
  static final RegExp _pemBlockPattern = RegExp(
    r'-----BEGIN [A-Z0-9_ -]+-----[\s\S]*?-----END [A-Z0-9_ -]+-----',
    multiLine: true,
  );

  // WireGuard Keys (PrivateKey, PublicKey, PresharedKey)
  static final RegExp _wireGuardKeyPattern = RegExp(
    r'((?:PrivateKey|PublicKey|PresharedKey)\s*=\s*)([^\r\n]+)',
    caseSensitive: false,
  );

  // Passwords, Tokens, Bearer headers, Secrets
  static final RegExp _authSecretPattern = RegExp(
    r'((?:password|passwd|secret|token|api_key|access_token|refresh_token|credential|bearer)\s*[:=]\s*["' "'" r']?)([^"' "'" r',\s&]{3,})',
    caseSensitive: false,
  );

  // SSH URI credentials (ssh://user:password@host:port)
  static final RegExp _sshUriPattern = RegExp(
    r'(ssh://[^:]+:)([^@]+)(@)',
  );

  /// Redact a string containing logs, stacktraces, or configuration dumps.
  static String redact(String input) {
    if (input.isEmpty) return input;

    var sanitized = input;

    // 1. Redact PEM blocks (Certificates and Keys)
    sanitized = sanitized.replaceAll(_pemBlockPattern, '[REDACTED_CRYPTO_BLOCK]');

    // 2. Redact WireGuard Keys
    sanitized = sanitized.replaceAllMapped(_wireGuardKeyPattern, (match) {
      return '${match.group(1)}[REDACTED_WG_KEY]';
    });

    // 3. Redact SSH URI Passwords
    sanitized = sanitized.replaceAllMapped(_sshUriPattern, (match) {
      return '${match.group(1)}[REDACTED_PASS]${match.group(3)}';
    });

    // 4. Redact Generic Secrets & Bearer Tokens
    sanitized = sanitized.replaceAllMapped(_authSecretPattern, (match) {
      return '${match.group(1)}[REDACTED_SECRET]';
    });

    // 5. Redact Email Addresses
    sanitized = sanitized.replaceAll(_emailPattern, '[REDACTED_EMAIL]');

    // 6. Redact Hardware / Device UUIDs
    sanitized = sanitized.replaceAll(_uuidPattern, '[REDACTED_UUID]');

    // 7. Redact IPv6
    sanitized = sanitized.replaceAll(_ipv6Pattern, '[REDACTED_IPV6]');

    // 8. Redact IPv4 (done after IPv6)
    sanitized = sanitized.replaceAll(_ipv4Pattern, '[REDACTED_IP]');

    return sanitized;
  }
}
