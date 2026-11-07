import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/payment_record.dart';
import '../entities/subscription_plan.dart';
import '../entities/subscription_status.dart';

abstract class ISubscriptionRepository {
  Future<Either<Failure, List<SubscriptionPlan>>> getPlans();
  Future<Either<Failure, SubscriptionStatus>> getStatus();
  Future<Either<Failure, List<PaymentRecord>>> getPaymentHistory();
  Future<Either<Failure, SubscriptionStatus>> verifyPurchase({
    required int planId,
    required String purchaseToken,
    String? orderId,
    String? store,
  });
  Future<Either<Failure, SubscriptionStatus>> redeemPromoCode(String code);
}
