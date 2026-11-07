import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../errors/failures.dart';

/// Represents a validated, structured Ramez Tunnel Profile (.rtp)
class RtpProfile {
  final String schemaVersion;
  final String id;
  final String name;
  final String? description;
  final String? author;
  final String protocol; // ovpn, vless, vmess, trojan, ssh
  final String serverAddress;
  final int serverPort;
  final String authMethod;
  final Map<String, dynamic> credentials;
  final String transport; // tcp, udp, ws, grpc
  final String? sni;
  final String? hostHeader;
  final Map<String, String> customHeaders;
  final List<String> dnsServers;
  final String rawPayload;
  final bool exportLocked;
  final String? hwidLock;
  final String? signature;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const RtpProfile({
    this.schemaVersion = '1.0',
    required this.id,
    required this.name,
    this.description,
    this.author,
    required this.protocol,
    required this.serverAddress,
    required this.serverPort,
    this.authMethod = 'none',
    this.credentials = const {},
    this.transport = 'udp',
    this.sni,
    this.hostHeader,
    this.customHeaders = const {},
    this.dnsServers = const ['1.1.1.1', '1.0.0.1'],
    required this.rawPayload,
    this.exportLocked = false,
    this.hwidLock,
    this.signature,
    required this.createdAt,
    this.expiresAt,
  });

  Map<String, dynamic> toJson({bool includeSecrets = true}) {
    return {
      'schemaVersion': schemaVersion,
      'id': id,
      'name': name,
      'description': description,
      'author': author,
      'protocol': protocol,
      'serverAddress': serverAddress,
      'serverPort': serverPort,
      'authMethod': authMethod,
      'credentials': (exportLocked && !includeSecrets) ? {} : credentials,
      'transport': transport,
      'sni': sni,
      'hostHeader': hostHeader,
      'customHeaders': customHeaders,
      'dnsServers': dnsServers,
      'rawPayload': (exportLocked && !includeSecrets) ? '' : rawPayload,
      'exportLocked': exportLocked,
      'hwidLock': hwidLock,
      'signature': signature,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  factory RtpProfile.fromJson(Map<String, dynamic> json) {
    return RtpProfile(
      schemaVersion: json['schemaVersion'] as String? ?? '1.0',
      id: json['id'] as String? ?? const Uuid().v4(),
      name: json['name'] as String? ?? 'Imported Profile',
      description: json['description'] as String?,
      author: json['author'] as String?,
      protocol: (json['protocol'] as String? ?? 'ovpn').toLowerCase(),
      serverAddress: json['serverAddress'] as String? ?? '127.0.0.1',
      serverPort: json['serverPort'] as int? ?? 1194,
      authMethod: json['authMethod'] as String? ?? 'none',
      credentials: json['credentials'] != null 
          ? Map<String, dynamic>.from(json['credentials'] as Map) 
          : {},
      transport: json['transport'] as String? ?? 'udp',
      sni: json['sni'] as String?,
      hostHeader: json['hostHeader'] as String?,
      customHeaders: json['customHeaders'] != null
          ? Map<String, String>.from(json['customHeaders'] as Map)
          : {},
      dnsServers: json['dnsServers'] != null
          ? List<String>.from(json['dnsServers'] as List)
          : const ['1.1.1.1', '1.0.0.1'],
      rawPayload: json['rawPayload'] as String? ?? '',
      exportLocked: json['exportLocked'] as bool? ?? false,
      hwidLock: json['hwidLock'] as String?,
      signature: json['signature'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'] as String)
          : null,
    );
  }
}

class RtpConfigEngine {
  static const int maxConfigSizeBytes = 1024 * 1024; // 1MB anti-DoS limit
  static const String _signingSecret = 'ramez_rtp_official_signature_key_2026';

  /// Parses a .rtp JSON string safely with schema & HWID enforcement.
  static RtpProfile parseRtp(String jsonString, {String? currentDeviceUuid}) {
    if (jsonString.length > maxConfigSizeBytes) {
      throw const ConfigParsingFailure('Configuration payload exceeds maximum allowed size (1 MB).');
    }

    try {
      final dynamic decoded = json.decode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        throw const ConfigParsingFailure('Invalid RTP configuration: Root element must be a JSON object.');
      }

      final profile = RtpProfile.fromJson(decoded);

      if (profile.schemaVersion != '1.0') {
        throw ConfigParsingFailure('Unsupported RTP schema version: ${profile.schemaVersion}. Required: 1.0.');
      }

      // HWID Lock Verification
      if (profile.hwidLock != null && profile.hwidLock!.isNotEmpty) {
        if (currentDeviceUuid == null || profile.hwidLock != currentDeviceUuid) {
          throw const ConfigParsingFailure('Configuration is hardware-locked to another device and cannot be imported.');
        }
      }

      // Check Expiration
      if (profile.expiresAt != null && profile.expiresAt!.isBefore(DateTime.now())) {
        throw const ConfigParsingFailure('This configuration profile has expired.');
      }

      return profile;
    } on FormatException catch (e) {
      throw ConfigParsingFailure('Malformed JSON in RTP configuration: ${e.message}');
    }
  }

  /// Exports a RtpProfile into serialized JSON. Throws if profile is export-locked.
  static String exportRtp(RtpProfile profile) {
    if (profile.exportLocked) {
      throw const ConfigParsingFailure('This configuration is export-locked by its author.');
    }

    final data = profile.toJson(includeSecrets: true);
    // Sign profile
    final signature = _computeSignature(profile);
    data['signature'] = signature;

    return const JsonEncoder.withIndent('  ').convert(data);
  }

  /// Parses raw OpenVPN (.ovpn) configuration file into a RtpProfile
  static RtpProfile parseOvpn(String ovpnContent, {String? defaultName}) {
    if (ovpnContent.length > maxConfigSizeBytes) {
      throw const ConfigParsingFailure('OpenVPN configuration file exceeds 1 MB limit.');
    }

    String serverAddress = '127.0.0.1';
    int serverPort = 1194;
    String proto = 'udp';

    final lines = LineSplitter.split(ovpnContent);
    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#') || line.startsWith(';')) continue;

      final parts = line.split(RegExp(r'\s+'));
      if (parts.isEmpty) continue;

      if (parts[0].toLowerCase() == 'remote' && parts.length >= 2) {
        serverAddress = parts[1];
        if (parts.length >= 3) {
          serverPort = int.tryParse(parts[2]) ?? 1194;
        }
      } else if (parts[0].toLowerCase() == 'proto' && parts.length >= 2) {
        proto = parts[1].toLowerCase().contains('tcp') ? 'tcp' : 'udp';
      } else if (parts[0].toLowerCase() == 'port' && parts.length >= 2) {
        serverPort = int.tryParse(parts[1]) ?? serverPort;
      }
    }

    final name = defaultName ?? 'OpenVPN ($serverAddress:$serverPort)';

    return RtpProfile(
      id: const Uuid().v4(),
      name: name,
      protocol: 'ovpn',
      serverAddress: serverAddress,
      serverPort: serverPort,
      transport: proto,
      rawPayload: ovpnContent,
      createdAt: DateTime.now(),
    );
  }

  /// Parses proxy link URIs: vless://, vmess://, trojan://
  static RtpProfile parseProxyUri(String uriString) {
    final uri = Uri.tryParse(uriString.trim());
    if (uri == null || !uri.hasScheme) {
      throw const ConfigParsingFailure('Invalid proxy link format.');
    }

    final scheme = uri.scheme.toLowerCase();
    if (!['vless', 'vmess', 'trojan', 'ss'].contains(scheme)) {
      throw ConfigParsingFailure('Unsupported URI protocol scheme: $scheme');
    }

    final serverAddress = uri.host.isNotEmpty ? uri.host : '127.0.0.1';
    final serverPort = uri.hasPort ? uri.port : 443;
    final name = uri.fragment.isNotEmpty 
        ? Uri.decodeComponent(uri.fragment) 
        : '$scheme://$serverAddress:$serverPort';

    final query = uri.queryParameters;
    final transport = query['type'] ?? 'tcp';
    final sni = query['sni'] ?? query['peer'];
    final host = query['host'];

    return RtpProfile(
      id: const Uuid().v4(),
      name: name,
      protocol: scheme,
      serverAddress: serverAddress,
      serverPort: serverPort,
      transport: transport,
      sni: sni,
      hostHeader: host,
      rawPayload: uriString.trim(),
      createdAt: DateTime.now(),
    );
  }

  /// Automatically parses any format: RTP JSON, OVPN text, or URI link
  static RtpProfile parseAny(String input, {String? currentDeviceUuid, String? defaultName}) {
    final trimmed = input.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      return parseRtp(trimmed, currentDeviceUuid: currentDeviceUuid);
    } else if (trimmed.startsWith('vless://') || 
               trimmed.startsWith('vmess://') || 
               trimmed.startsWith('trojan://') || 
               trimmed.startsWith('ss://')) {
      return parseProxyUri(trimmed);
    } else {
      // Default to OpenVPN profile
      return parseOvpn(trimmed, defaultName: defaultName);
    }
  }

  static String _computeSignature(RtpProfile profile) {
    final payload = '${profile.id}:${profile.protocol}:${profile.serverAddress}:${profile.serverPort}:${profile.rawPayload.hashCode}';
    final hmac = Hmac(sha256, utf8.encode(_signingSecret));
    return hmac.convert(utf8.encode(payload)).toString();
  }
}
