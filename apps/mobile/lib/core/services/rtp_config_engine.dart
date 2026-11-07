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

  /// Parses standard WireGuard (.conf) configuration file into a RtpProfile
  static RtpProfile parseWireGuard(String confContent, {String? defaultName}) {
    if (confContent.length > maxConfigSizeBytes) {
      throw const ConfigParsingFailure('WireGuard configuration file exceeds 1 MB limit.');
    }

    String privateKey = '';
    String address = '10.0.0.2/32';
    List<String> dnsList = ['1.1.1.1', '1.0.0.1'];
    int mtu = 1420;
    String peerPublicKey = '';
    String endpointHost = '127.0.0.1';
    int endpointPort = 51820;
    List<String> allowedIps = ['0.0.0.0/0'];
    int keepalive = 25;

    final lines = LineSplitter.split(confContent);
    for (final rawLine in lines) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) continue;

      final eqIdx = line.indexOf('=');
      if (eqIdx == -1) continue;

      final key = line.substring(0, eqIdx).trim().toLowerCase();
      final val = line.substring(eqIdx + 1).trim();

      switch (key) {
        case 'privatekey':
          privateKey = val;
          break;
        case 'address':
          address = val;
          break;
        case 'dns':
          dnsList = val.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          break;
        case 'mtu':
          mtu = int.tryParse(val) ?? 1420;
          break;
        case 'publickey':
          peerPublicKey = val;
          break;
        case 'endpoint':
          final epParts = val.split(':');
          endpointHost = epParts[0].trim();
          if (epParts.length > 1) {
            endpointPort = int.tryParse(epParts[1].trim()) ?? 51820;
          }
          break;
        case 'allowedips':
          allowedIps = val.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
          break;
        case 'persistentkeepalive':
          keepalive = int.tryParse(val) ?? 25;
          break;
      }
    }

    if (privateKey.isEmpty && peerPublicKey.isEmpty && !confContent.toLowerCase().contains('[interface]')) {
      throw const ConfigParsingFailure('Invalid WireGuard configuration: Missing [Interface] or key pairs.');
    }

    final name = defaultName ?? 'WireGuard ($endpointHost:$endpointPort)';

    return RtpProfile(
      id: const Uuid().v4(),
      name: name,
      protocol: 'wireguard',
      serverAddress: endpointHost,
      serverPort: endpointPort,
      transport: 'udp',
      credentials: {
        'privateKey': privateKey,
        'address': address,
        'publicKey': peerPublicKey,
        'allowedIps': allowedIps,
        'mtu': mtu,
        'persistentKeepalive': keepalive,
      },
      dnsServers: dnsList.isNotEmpty ? dnsList : const ['1.1.1.1', '1.0.0.1'],
      rawPayload: confContent,
      createdAt: DateTime.now(),
    );
  }

  /// Parses SSH Tunnel configuration or SSH URI
  static RtpProfile parseSsh(String input, {String? defaultName}) {
    if (input.length > maxConfigSizeBytes) {
      throw const ConfigParsingFailure('SSH configuration exceeds 1 MB limit.');
    }

    String host = '127.0.0.1';
    int port = 22;
    String username = '';
    String password = '';
    String payload = '';
    String sni = '';

    final trimmed = input.trim();
    if (trimmed.startsWith('ssh://')) {
      final uri = Uri.tryParse(trimmed);
      if (uri != null) {
        host = uri.host.isNotEmpty ? uri.host : host;
        port = uri.hasPort ? uri.port : 22;
        if (uri.userInfo.isNotEmpty) {
          final uParts = uri.userInfo.split(':');
          username = uParts[0];
          if (uParts.length > 1) password = uParts[1];
        }
        payload = uri.queryParameters['payload'] ?? '';
        sni = uri.queryParameters['sni'] ?? '';
      }
    } else {
      final lines = LineSplitter.split(trimmed);
      for (final rawLine in lines) {
        final line = rawLine.trim();
        if (line.isEmpty || line.startsWith('#') || line.startsWith(';')) continue;

        final eqIdx = line.indexOf('=');
        if (eqIdx == -1) continue;

        final key = line.substring(0, eqIdx).trim().toLowerCase();
        final val = line.substring(eqIdx + 1).trim();

        switch (key) {
          case 'host':
          case 'server':
            host = val;
            break;
          case 'port':
            port = int.tryParse(val) ?? 22;
            break;
          case 'user':
          case 'username':
            username = val;
            break;
          case 'pass':
          case 'password':
            password = val;
            break;
          case 'payload':
            payload = val;
            break;
          case 'sni':
            sni = val;
            break;
        }
      }
    }

    final name = defaultName ?? 'SSH Tunnel ($host:$port)';

    return RtpProfile(
      id: const Uuid().v4(),
      name: name,
      protocol: 'ssh',
      serverAddress: host,
      serverPort: port,
      transport: 'tcp',
      credentials: {
        'username': username,
        'password': password,
        'payload': payload,
      },
      sni: sni.isNotEmpty ? sni : null,
      hostHeader: payload.isNotEmpty ? payload : null,
      rawPayload: input,
      createdAt: DateTime.now(),
    );
  }

  /// Automatically parses any format: RTP JSON, OVPN text, WireGuard conf, SSH, or URI link
  static RtpProfile parseAny(String input, {String? currentDeviceUuid, String? defaultName}) {
    final trimmed = input.trim();
    if (trimmed.startsWith('{') && trimmed.endsWith('}')) {
      return parseRtp(trimmed, currentDeviceUuid: currentDeviceUuid);
    } else if (trimmed.startsWith('vless://') || 
               trimmed.startsWith('vmess://') || 
               trimmed.startsWith('trojan://') || 
               trimmed.startsWith('ss://')) {
      return parseProxyUri(trimmed);
    } else if (trimmed.startsWith('ssh://') || trimmed.contains('[SSH]')) {
      return parseSsh(trimmed, defaultName: defaultName);
    } else if (trimmed.contains('[Interface]') && trimmed.contains('[Peer]')) {
      return parseWireGuard(trimmed, defaultName: defaultName);
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
