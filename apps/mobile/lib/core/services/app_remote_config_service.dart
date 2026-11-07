import 'dart:convert';
import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import '../storage/hive_storage_service.dart';

class RemoteAppConfig {
  final String minAppVersion;
  final String latestAppVersion;
  final bool forceUpdate;
  final bool maintenanceMode;
  final String announcementAr;
  final String announcementEn;
  final List<String> defaultDnsServers;
  final List<String> supportedProtocols;
  final Map<String, bool> features;

  const RemoteAppConfig({
    this.minAppVersion = '1.0.0',
    this.latestAppVersion = '1.0.0',
    this.forceUpdate = false,
    this.maintenanceMode = false,
    this.announcementAr = 'مرحباً بك في رامز تنل بلس',
    this.announcementEn = 'Welcome to Ramez Tunnel Plus',
    this.defaultDnsServers = const ['1.1.1.1', '1.0.0.1'],
    this.supportedProtocols = const ['ovpn', 'vless', 'vmess', 'trojan', 'rtp', 'ssh'],
    this.features = const {
      'custom_config_import': true,
      'split_tunneling': true,
      'kill_switch': true,
      'dark_mode': true,
      'community_sharing': true,
    },
  });

  factory RemoteAppConfig.fromJson(Map<String, dynamic> json) {
    final announcement = json['announcement'] as Map<String, dynamic>? ?? {};
    final featuresMap = json['features'] as Map<String, dynamic>? ?? {};

    return RemoteAppConfig(
      minAppVersion: json['min_app_version'] as String? ?? '1.0.0',
      latestAppVersion: json['latest_app_version'] as String? ?? '1.0.0',
      forceUpdate: json['force_update'] as bool? ?? false,
      maintenanceMode: json['maintenance_mode'] as bool? ?? false,
      announcementAr: announcement['ar'] as String? ?? 'مرحباً بك في رامز تنل بلس',
      announcementEn: announcement['en'] as String? ?? 'Welcome to Ramez Tunnel Plus',
      defaultDnsServers: json['default_dns_servers'] != null
          ? List<String>.from(json['default_dns_servers'] as List)
          : const ['1.1.1.1', '1.0.0.1'],
      supportedProtocols: json['supported_protocols'] != null
          ? List<String>.from(json['supported_protocols'] as List)
          : const ['ovpn', 'vless', 'vmess', 'trojan', 'rtp', 'ssh'],
      features: featuresMap.map((k, v) => MapEntry(k, v as bool? ?? false)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min_app_version': minAppVersion,
      'latest_app_version': latestAppVersion,
      'force_update': forceUpdate,
      'maintenance_mode': maintenanceMode,
      'announcement': {
        'ar': announcementAr,
        'en': announcementEn,
      },
      'default_dns_servers': defaultDnsServers,
      'supported_protocols': supportedProtocols,
      'features': features,
    };
  }
}

class AppRemoteConfigService {
  final DioClient _dioClient;
  final IHiveStorageService _hiveStorage;

  static const String _cacheKey = 'remote_app_config_cache';

  AppRemoteConfigService({
    required DioClient dioClient,
    required IHiveStorageService hiveStorage,
  })  : _dioClient = dioClient,
        _hiveStorage = hiveStorage;

  RemoteAppConfig _currentConfig = const RemoteAppConfig();
  RemoteAppConfig get currentConfig => _currentConfig;

  Future<RemoteAppConfig> fetchConfig() async {
    try {
      final response = await _dioClient.get('/api/v1/app/config');
      final data = response.data;
      if (data != null && data['status'] == 'success') {
        _currentConfig = RemoteAppConfig.fromJson(data['data'] as Map<String, dynamic>);
        await _hiveStorage.put(HiveStorageService.boxCache, _cacheKey, jsonEncode(_currentConfig.toJson()));
        return _currentConfig;
      }
    } on DioException catch (_) {
      // Offline fallback: load from cache
      final cached = _hiveStorage.get<String>(HiveStorageService.boxCache, _cacheKey);
      if (cached != null) {
        try {
          _currentConfig = RemoteAppConfig.fromJson(jsonDecode(cached));
          return _currentConfig;
        } catch (_) {}
      }
    } catch (_) {}

    return _currentConfig;
  }
}
