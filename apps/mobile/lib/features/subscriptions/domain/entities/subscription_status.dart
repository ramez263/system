import 'package:equatable/equatable.dart';

class SubscriptionStatus extends Equatable {
  final String deviceUuid;
  final bool isPremium;
  final String tier;
  final Map<String, dynamic> entitlements;
  final Map<String, dynamic> usage;
  final String? activePlanName;
  final String? activeOrderId;
  final String? activeStore;
  final DateTime? expiresAt;
  final bool isAutoRenewing;

  const SubscriptionStatus({
    required this.deviceUuid,
    required this.isPremium,
    required this.tier,
    this.entitlements = const {},
    this.usage = const {},
    this.activePlanName,
    this.activeOrderId,
    this.activeStore,
    this.expiresAt,
    this.isAutoRenewing = true,
  });

  bool get canConnectVipServers => isPremium;
  int get totalBytesUsed => (usage['total_bytes'] as num?)?.toInt() ?? 0;
  int? get bandwidthCapBytes => (usage['bandwidth_cap_bytes'] as num?)?.toInt();
  bool get isCapExceeded => usage['cap_exceeded'] == true;

  @override
  List<Object?> get props => [
        deviceUuid,
        isPremium,
        tier,
        entitlements,
        usage,
        activePlanName,
        activeOrderId,
        activeStore,
        expiresAt,
        isAutoRenewing,
      ];
}
