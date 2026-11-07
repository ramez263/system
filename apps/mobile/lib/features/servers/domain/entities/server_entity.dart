import 'package:equatable/equatable.dart';

class ServerEntity extends Equatable {
  final int id;
  final String name;
  final String countryCode;
  final String countryName;
  final String? city;
  final String flagEmoji;
  final String protocol;
  final String ipAddress;
  final int port;
  final int pingMs;
  final int currentLoad;
  final bool isPremium;
  final bool hasOvpn;

  const ServerEntity({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.countryName,
    this.city,
    required this.flagEmoji,
    required this.protocol,
    required this.ipAddress,
    required this.port,
    required this.pingMs,
    required this.currentLoad,
    required this.isPremium,
    this.hasOvpn = true,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        countryCode,
        countryName,
        city,
        flagEmoji,
        protocol,
        ipAddress,
        port,
        pingMs,
        currentLoad,
        isPremium,
        hasOvpn,
      ];
}
