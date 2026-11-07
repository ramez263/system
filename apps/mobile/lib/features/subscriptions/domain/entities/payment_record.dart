import 'package:equatable/equatable.dart';

class PaymentRecord extends Equatable {
  final int id;
  final String orderId;
  final String planName;
  final int amountCents;
  final String formattedAmount;
  final String currency;
  final String store;
  final String status;
  final bool isAutoRenewing;
  final String date;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const PaymentRecord({
    required this.id,
    required this.orderId,
    required this.planName,
    required this.amountCents,
    required this.formattedAmount,
    required this.currency,
    required this.store,
    required this.status,
    this.isAutoRenewing = true,
    required this.date,
    required this.createdAt,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        planName,
        amountCents,
        formattedAmount,
        currency,
        store,
        status,
        isAutoRenewing,
        date,
        createdAt,
        expiresAt,
      ];
}
