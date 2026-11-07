import '../../domain/entities/payment_record.dart';

class PaymentRecordModel extends PaymentRecord {
  const PaymentRecordModel({
    required super.id,
    required super.orderId,
    required super.planName,
    required super.amountCents,
    required super.formattedAmount,
    required super.currency,
    required super.store,
    required super.status,
    super.isAutoRenewing = true,
    required super.date,
    required super.createdAt,
    super.expiresAt,
  });

  factory PaymentRecordModel.fromJson(Map<String, dynamic> json) {
    return PaymentRecordModel(
      id: (json['id'] as num).toInt(),
      orderId: json['order_id'] as String? ?? '',
      planName: json['plan_name'] as String? ?? 'VIP Plan',
      amountCents: (json['amount_cents'] as num?)?.toInt() ?? 0,
      formattedAmount: json['formatted_amount'] as String? ?? '\$0.00',
      currency: json['currency'] as String? ?? 'USD',
      store: json['store'] as String? ?? 'Google Play',
      status: json['status'] as String? ?? 'Active',
      isAutoRenewing: json['is_auto_renewing'] == true,
      date: json['date'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      expiresAt: json['expires_at'] != null ? DateTime.tryParse(json['expires_at'] as String) : null,
    );
  }
}
