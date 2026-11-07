import '../../domain/entities/configuration_entity.dart';

class ConfigurationModel extends ConfigurationEntity {
  const ConfigurationModel({
    super.id,
    required super.name,
    super.description,
    required super.protocol,
    required super.serverAddress,
    required super.serverPort,
    required super.rawConfig,
    super.isFavorite = false,
    super.isLocked = false,
    super.shareCode,
    super.isPublic = false,
    super.downloadsCount = 0,
    required super.createdAt,
  });

  factory ConfigurationModel.fromJson(Map<String, dynamic> json) {
    return ConfigurationModel(
      id: json['id'] as int?,
      name: json['name'] as String? ?? 'Imported Config',
      description: json['description'] as String?,
      protocol: json['protocol'] as String? ?? 'ovpn',
      serverAddress: json['server_address'] as String? ?? json['serverAddress'] as String? ?? '127.0.0.1',
      serverPort: json['server_port'] as int? ?? json['serverPort'] as int? ?? 1194,
      rawConfig: json['config_data'] as String? ?? json['raw_config'] as String? ?? json['rawConfig'] as String? ?? '',
      isFavorite: json['is_favorite'] as bool? ?? false,
      isLocked: json['export_locked'] as bool? ?? json['is_locked'] as bool? ?? false,
      shareCode: json['share_code'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
      downloadsCount: json['downloads_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'protocol': protocol,
      'server_address': serverAddress,
      'server_port': serverPort,
      'config_data': rawConfig,
      'is_favorite': isFavorite,
      'export_locked': isLocked,
      'share_code': shareCode,
      'is_public': isPublic,
      'downloads_count': downloadsCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
