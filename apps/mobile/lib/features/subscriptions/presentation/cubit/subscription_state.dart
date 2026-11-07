import 'package:equatable/equatable.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/subscription_status.dart';

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final List<SubscriptionPlan> plans;
  final SubscriptionStatus? status;
  final List<PaymentRecord> paymentHistory;
  final SubscriptionPlan? selectedPlan;
  final bool isPurchasing;
  final String? successMessage;
  final String? errorMessage;

  const SubscriptionLoaded({
    required this.plans,
    this.status,
    this.paymentHistory = const [],
    this.selectedPlan,
    this.isPurchasing = false,
    this.successMessage,
    this.errorMessage,
  });

  bool get isPremium => status?.isPremium ?? false;

  SubscriptionLoaded copyWith({
    List<SubscriptionPlan>? plans,
    SubscriptionStatus? status,
    List<PaymentRecord>? paymentHistory,
    SubscriptionPlan? selectedPlan,
    bool? isPurchasing,
    String? successMessage,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return SubscriptionLoaded(
      plans: plans ?? this.plans,
      status: status ?? this.status,
      paymentHistory: paymentHistory ?? this.paymentHistory,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        plans,
        status,
        paymentHistory,
        selectedPlan,
        isPurchasing,
        successMessage,
        errorMessage,
      ];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError(this.message);

  @override
  List<Object?> get props => [message];
}
