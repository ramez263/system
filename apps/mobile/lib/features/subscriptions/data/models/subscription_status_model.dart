import '../../domain/entities/subscription_status.dart';

class SubscriptionStatusModel extends SubscriptionStatus {
  const SubscriptionStatusModel({
    required super.deviceUuid,
    required super.isPremium,
    required super.tier,
    super.entitlements = const {},
    super.usage = const {},
    super.activePlanName,
    super.activeOrderId,
    super.activeStore,
    super.expiresAt,
    super.isAutoRenewing = true,
  });

  factory SubscriptionStatusModel.fromJson(Map<String, dynamic> json) {
    final activeSub = json['active_subscription'] as Map<String, dynamic>?;

    return SubscriptionStatusModel(
      deviceUuid: json['device_uuid'] as String? ?? '',
      isPremium: json['is_premium'] == true,
      tier: json['tier'] as String? ?? 'free',
      entitlements: (json['entitlements'] as Map<String, dynamic>?) ?? {},
      usage: (json['usage'] as Map<String, dynamic>?) ?? {},
      activePlanName: activeSub?['plan_name'] as String?,
      activeOrderId: activeSub?['order_id'] as String?,
      activeStore: activeSub?['store'] as String?,
      expiresAt: activeSub?['expires_at'] != null ? DateTime.tryParse(activeSub!['expires_at'] as String) : null,
      isAutoRenewing: activeSub?['is_auto_renewing'] ?? true,
    );
  }
}
