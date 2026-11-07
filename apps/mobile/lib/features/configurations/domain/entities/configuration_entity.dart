import 'package:equatable/equatable.dart';

class ConfigurationEntity extends Equatable {
  final int? id; // Nullable for new configs before persisting to SQLite
  final String name;
  final String? description;
  final String protocol; // ovpn, vless, vmess, trojan, ssh, rtp
  final String serverAddress;
  final int serverPort;
  final String rawConfig;
  final bool isFavorite;
  final bool isLocked;
  final String? shareCode;
  final bool isPublic;
  final int downloadsCount;
  final DateTime createdAt;

  const ConfigurationEntity({
    this.id,
    required this.name,
    this.description,
    required this.protocol,
    required this.serverAddress,
    required this.serverPort,
    required this.rawConfig,
    this.isFavorite = false,
    this.isLocked = false,
    this.shareCode,
    this.isPublic = false,
    this.downloadsCount = 0,
    required this.createdAt,
  });

  ConfigurationEntity copyWith({
    int? id,
    String? name,
    String? description,
    String? protocol,
    String? serverAddress,
    int? serverPort,
    String? rawConfig,
    bool? isFavorite,
    bool? isLocked,
    String? shareCode,
    bool? isPublic,
    int? downloadsCount,
    DateTime? createdAt,
  }) {
    return ConfigurationEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      protocol: protocol ?? this.protocol,
      serverAddress: serverAddress ?? this.serverAddress,
      serverPort: serverPort ?? this.serverPort,
      rawConfig: rawConfig ?? this.rawConfig,
      isFavorite: isFavorite ?? this.isFavorite,
      isLocked: isLocked ?? this.isLocked,
      shareCode: shareCode ?? this.shareCode,
      isPublic: isPublic ?? this.isPublic,
      downloadsCount: downloadsCount ?? this.downloadsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        protocol,
        serverAddress,
        serverPort,
        rawConfig,
        isFavorite,
        isLocked,
        shareCode,
        isPublic,
        downloadsCount,
        createdAt,
      ];
}
