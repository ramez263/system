import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/services/billing_service.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/repositories/subscription_repository.dart';
import 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final ISubscriptionRepository _repository;
  final BillingService _billingService;

  SubscriptionCubit({
    required ISubscriptionRepository repository,
    required BillingService billingService,
  })  : _repository = repository,
        _billingService = billingService,
        super(SubscriptionInitial());

  Future<void> loadSubscriptionData() async {
    emit(SubscriptionLoading());

    final plansResult = await _repository.getPlans();
    final statusResult = await _repository.getStatus();
    final historyResult = await _repository.getPaymentHistory();

    plansResult.fold(
      (failure) => emit(SubscriptionError(failure.message)),
      (plans) {
        final status = statusResult.fold((_) => null, (s) => s);
        final history = historyResult.fold((_) => <PaymentRecord>[], (h) => h);

        // Default selected plan: featured plan or first paid plan
        final defaultSelected = plans.firstWhere(
          (p) => p.isFeatured,
          orElse: () => plans.firstWhere((p) => !p.isFree, orElse: () => plans.first),
        );

        emit(SubscriptionLoaded(
          plans: plans,
          status: status,
          paymentHistory: history,
          selectedPlan: defaultSelected,
        ));
      },
    );
  }

  void selectPlan(SubscriptionPlan plan) {
    if (state is SubscriptionLoaded) {
      final current = state as SubscriptionLoaded;
      emit(current.copyWith(selectedPlan: plan, clearMessages: true));
    }
  }

  Future<void> purchasePlan(SubscriptionPlan plan) async {
    if (state is! SubscriptionLoaded) return;
    final current = state as SubscriptionLoaded;

    if (plan.isFree) {
      emit(current.copyWith(
        errorMessage: 'Free tier is already active by default.',
        clearMessages: false,
      ));
      return;
    }

    emit(current.copyWith(isPurchasing: true, clearMessages: true));

    try {
      final productId = plan.googlePlayProductId ?? plan.slug;
      final purchaseResult = await _billingService.purchaseSubscription(
        productId: productId,
      );

      if (!purchaseResult.success) {
        emit(current.copyWith(
          isPurchasing: false,
          errorMessage: purchaseResult.errorMessage ?? 'Purchase cancelled or failed.',
        ));
        return;
      }

      // Verify purchase server-side
      final verifyResult = await _repository.verifyPurchase(
        planId: plan.id,
        purchaseToken: purchaseResult.purchaseToken!,
        orderId: purchaseResult.orderId,
        store: purchaseResult.isSandbox ? 'sandbox' : 'google_play',
      );

      await verifyResult.fold(
        (failure) async {
          emit(current.copyWith(
            isPurchasing: false,
            errorMessage: failure.message,
          ));
        },
        (newStatus) async {
          final historyResult = await _repository.getPaymentHistory();
          final history = historyResult.fold((_) => current.paymentHistory, (h) => h);

          emit(current.copyWith(
            isPurchasing: false,
            status: newStatus,
            paymentHistory: history,
            successMessage: 'Success! VIP subscription activated on this device.',
          ));
        },
      );
    } catch (e) {
      emit(current.copyWith(
        isPurchasing: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> redeemPromoCode(String code) async {
    if (state is! SubscriptionLoaded) return;
    final current = state as SubscriptionLoaded;

    emit(current.copyWith(isPurchasing: true, clearMessages: true));

    final result = await _repository.redeemPromoCode(code);

    await result.fold(
      (failure) async {
        emit(current.copyWith(
          isPurchasing: false,
          errorMessage: failure.message,
        ));
      },
      (newStatus) async {
        final historyResult = await _repository.getPaymentHistory();
        final history = historyResult.fold((_) => current.paymentHistory, (h) => h);

        emit(current.copyWith(
          isPurchasing: false,
          status: newStatus,
          paymentHistory: history,
          successMessage: 'Promo voucher redeemed! Enjoy VIP tunnel access.',
        ));
      },
    );
  }

  Future<void> refreshStatus() async {
    if (state is! SubscriptionLoaded) return;
    final current = state as SubscriptionLoaded;

    final statusResult = await _repository.getStatus();
    final historyResult = await _repository.getPaymentHistory();

    statusResult.fold(
      (_) {},
      (newStatus) {
        final history = historyResult.fold((_) => current.paymentHistory, (h) => h);
        emit(current.copyWith(status: newStatus, paymentHistory: history));
      },
    );
  }
}
