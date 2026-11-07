import '../../domain/entities/server_entity.dart';

class ServerModel extends ServerEntity {
  const ServerModel({
    required super.id,
    required super.name,
    required super.countryCode,
    required super.countryName,
    super.city,
    required super.flagEmoji,
    required super.protocol,
    required super.ipAddress,
    required super.port,
    required super.pingMs,
    required super.currentLoad,
    required super.isPremium,
    super.hasOvpn = true,
  });

  factory ServerModel.fromJson(Map<String, dynamic> json) {
    return ServerModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'VPN Server',
      countryCode: json['country_code'] as String? ?? 'UN',
      countryName: json['country_name'] as String? ?? 'Unknown',
      city: json['city'] as String?,
      flagEmoji: json['flag_emoji'] as String? ?? '🌐',
      protocol: json['protocol'] as String? ?? 'ovpn',
      ipAddress: json['ip_address'] as String? ?? '127.0.0.1',
      port: json['port'] as int? ?? 1194,
      pingMs: json['ping_ms'] as int? ?? 50,
      currentLoad: json['current_load'] as int? ?? 20,
      isPremium: json['is_premium'] as bool? ?? false,
      hasOvpn: json['has_ovpn'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country_code': countryCode,
      'country_name': countryName,
      'city': city,
      'flag_emoji': flagEmoji,
      'protocol': protocol,
      'ip_address': ipAddress,
      'port': port,
      'ping_ms': pingMs,
      'current_load': currentLoad,
      'is_premium': isPremium,
      'has_ovpn': hasOvpn,
    };
  }
}
