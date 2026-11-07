import 'package:equatable/equatable.dart';

class NotificationPreferences extends Equatable {
  final bool notifyConnection;
  final bool notifyDisconnection;
  final bool notifyServerFailure;
  final bool notifySubscriptionExpiry;
  final bool notifySecurityAlerts;
  final bool notifyUpdates;
  final bool notifyPromotions;

  const NotificationPreferences({
    this.notifyConnection = true,
    this.notifyDisconnection = true,
    this.notifyServerFailure = true,
    this.notifySubscriptionExpiry = true,
    this.notifySecurityAlerts = true,
    this.notifyUpdates = true,
    this.notifyPromotions = false,
  });

  NotificationPreferences copyWith({
    bool? notifyConnection,
    bool? notifyDisconnection,
    bool? notifyServerFailure,
    bool? notifySubscriptionExpiry,
    bool? notifySecurityAlerts,
    bool? notifyUpdates,
    bool? notifyPromotions,
  }) {
    return NotificationPreferences(
      notifyConnection: notifyConnection ?? this.notifyConnection,
      notifyDisconnection: notifyDisconnection ?? this.notifyDisconnection,
      notifyServerFailure: notifyServerFailure ?? this.notifyServerFailure,
      notifySubscriptionExpiry: notifySubscriptionExpiry ?? this.notifySubscriptionExpiry,
      notifySecurityAlerts: notifySecurityAlerts ?? this.notifySecurityAlerts,
      notifyUpdates: notifyUpdates ?? this.notifyUpdates,
      notifyPromotions: notifyPromotions ?? this.notifyPromotions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notify_connection': notifyConnection,
      'notify_disconnection': notifyDisconnection,
      'notify_server_failure': notifyServerFailure,
      'notify_subscription_expiry': notifySubscriptionExpiry,
      'notify_security_alerts': notifySecurityAlerts,
      'notify_updates': notifyUpdates,
      'notify_promotions': notifyPromotions,
    };
  }

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      notifyConnection: json['notify_connection'] != false,
      notifyDisconnection: json['notify_disconnection'] != false,
      notifyServerFailure: json['notify_server_failure'] != false,
      notifySubscriptionExpiry: json['notify_subscription_expiry'] != false,
      notifySecurityAlerts: json['notify_security_alerts'] != false,
      notifyUpdates: json['notify_updates'] != false,
      notifyPromotions: json['notify_promotions'] == true,
    );
  }

  @override
  List<Object?> get props => [
        notifyConnection,
        notifyDisconnection,
        notifyServerFailure,
        notifySubscriptionExpiry,
        notifySecurityAlerts,
        notifyUpdates,
        notifyPromotions,
      ];
}
