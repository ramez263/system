import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:tunnel_plus/core/errors/failures.dart';
import 'package:tunnel_plus/features/subscriptions/data/services/billing_service.dart';
import 'package:tunnel_plus/features/subscriptions/domain/entities/payment_record.dart';
import 'package:tunnel_plus/features/subscriptions/domain/entities/subscription_plan.dart';
import 'package:tunnel_plus/features/subscriptions/domain/entities/subscription_status.dart';
import 'package:tunnel_plus/features/subscriptions/domain/repositories/subscription_repository.dart';
import 'package:tunnel_plus/features/subscriptions/presentation/cubit/subscription_cubit.dart';
import 'package:tunnel_plus/features/subscriptions/presentation/cubit/subscription_state.dart';

class MockSubscriptionRepository implements ISubscriptionRepository {
  List<SubscriptionPlan> mockPlans = [
    const SubscriptionPlan(
      id: 1,
      slug: 'free',
      name: 'Free Guest Tier',
      description: 'Standard speed',
      priceCents: 0,
      currency: 'USD',
      formattedPrice: 'Free',
      durationDays: 3650,
      features: ['Basic servers'],
    ),
    const SubscriptionPlan(
      id: 2,
      slug: 'pro_monthly',
      googlePlayProductId: 'com.ramez.tunnelplus.pro_monthly',
      name: 'Pro Monthly',
      description: 'VIP 1Gbps',
      priceCents: 499,
      currency: 'USD',
      formattedPrice: '\$4.99',
      durationDays: 30,
      features: ['All VIP servers', 'High speed'],
      isFeatured: true,
    ),
  ];

  SubscriptionStatus mockStatus = const SubscriptionStatus(
    deviceUuid: 'test-device-uuid',
    isPremium: false,
    tier: 'free',
  );

  List<PaymentRecord> mockHistory = [];

  bool shouldFailPlans = false;
  bool shouldFailVerify = false;
  bool shouldFailPromo = false;

  @override
  Future<Either<Failure, List<SubscriptionPlan>>> getPlans() async {
    if (shouldFailPlans) return const Left(ServerFailure('Failed to load plans'));
    return Right(mockPlans);
  }

  @override
  Future<Either<Failure, SubscriptionStatus>> getStatus() async {
    return Right(mockStatus);
  }

  @override
  Future<Either<Failure, List<PaymentRecord>>> getPaymentHistory() async {
    return Right(mockHistory);
  }

  @override
  Future<Either<Failure, SubscriptionStatus>> verifyPurchase({
    required int planId,
    required String purchaseToken,
    String? orderId,
    String? store,
  }) async {
    if (shouldFailVerify) {
      return const Left(ServerFailure('Invalid or expired purchase token'));
    }
    mockStatus = const SubscriptionStatus(
      deviceUuid: 'test-device-uuid',
      isPremium: true,
      tier: 'pro',
      activePlanName: 'Pro Monthly',
      activeOrderId: 'GPA.SANDBOX-1234',
    );
    mockHistory.add(PaymentRecord(
      id: 1,
      orderId: orderId ?? 'GPA.SANDBOX-1234',
      planName: 'Pro Monthly',
      amountCents: 499,
      formattedAmount: '\$4.99',
      currency: 'USD',
      store: 'Google Play',
      status: 'Active',
      date: '2026-11-07',
      createdAt: DateTime.now(),
    ));
    return Right(mockStatus);
  }

  @override
  Future<Either<Failure, SubscriptionStatus>> redeemPromoCode(String code) async {
    if (shouldFailPromo || code == 'INVALID') {
      return const Left(ServerFailure('Invalid or expired promo code'));
    }
    mockStatus = const SubscriptionStatus(
      deviceUuid: 'test-device-uuid',
      isPremium: true,
      tier: 'pro',
      activePlanName: 'Pro Monthly',
      activeOrderId: 'PRM-VIP-999',
    );
    return Right(mockStatus);
  }
}

class FakeBillingService extends BillingService {
  bool shouldFail = false;

  @override
  Future<bool> isStoreAvailable() async => true;

  @override
  Future<BillingPurchaseResult> purchaseSubscription({
    required String productId,
    bool forceSandbox = false,
  }) async {
    if (shouldFail) {
      return BillingPurchaseResult.failure('User cancelled purchase.');
    }
    return BillingPurchaseResult.success(
      purchaseToken: 'sandbox_test_token_abc',
      orderId: 'GPA.SANDBOX-1234',
      productId: productId,
      isSandbox: true,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockSubscriptionRepository repository;
  late FakeBillingService billingService;
  late SubscriptionCubit cubit;

  setUp(() {
    repository = MockSubscriptionRepository();
    billingService = FakeBillingService();
    cubit = SubscriptionCubit(
      repository: repository,
      billingService: billingService,
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('loadSubscriptionData emits SubscriptionLoading then SubscriptionLoaded with featured plan selected', () async {
    final expectedStates = [
      isA<SubscriptionLoading>(),
      isA<SubscriptionLoaded>()
          .having((s) => s.plans.length, 'plans length', 2)
          .having((s) => s.selectedPlan?.slug, 'selectedPlan', 'pro_monthly')
          .having((s) => s.isPremium, 'isPremium', false),
    ];

    expectLater(cubit.stream, emitsInOrder(expectedStates));
    await cubit.loadSubscriptionData();
  });

  test('selectPlan updates selectedPlan in SubscriptionLoaded state', () async {
    await cubit.loadSubscriptionData();

    final freePlan = repository.mockPlans.first;
    cubit.selectPlan(freePlan);

    expect(cubit.state, isA<SubscriptionLoaded>());
    final state = cubit.state as SubscriptionLoaded;
    expect(state.selectedPlan?.slug, 'free');
  });

  test('purchasePlan completes sandbox purchase and unlocks Pro VIP status', () async {
    await cubit.loadSubscriptionData();

    final proPlan = repository.mockPlans[1];
    await cubit.purchasePlan(proPlan);

    expect(cubit.state, isA<SubscriptionLoaded>());
    final state = cubit.state as SubscriptionLoaded;
    expect(state.isPremium, true);
    expect(state.status?.tier, 'pro');
    expect(state.successMessage, contains('VIP subscription activated'));
    expect(state.paymentHistory.length, 1);
  });

  test('purchasePlan handles billing failure gracefully', () async {
    billingService.shouldFail = true;
    await cubit.loadSubscriptionData();

    final proPlan = repository.mockPlans[1];
    await cubit.purchasePlan(proPlan);

    expect(cubit.state, isA<SubscriptionLoaded>());
    final state = cubit.state as SubscriptionLoaded;
    expect(state.isPremium, false);
    expect(state.errorMessage, contains('User cancelled purchase'));
  });

  test('redeemPromoCode unlocks Pro VIP status on valid code', () async {
    await cubit.loadSubscriptionData();

    await cubit.redeemPromoCode('RAMEZVIP');

    expect(cubit.state, isA<SubscriptionLoaded>());
    final state = cubit.state as SubscriptionLoaded;
    expect(state.isPremium, true);
    expect(state.status?.tier, 'pro');
    expect(state.successMessage, contains('Promo voucher redeemed'));
  });

  test('redeemPromoCode emits error message on invalid voucher code', () async {
    await cubit.loadSubscriptionData();

    await cubit.redeemPromoCode('INVALID');

    expect(cubit.state, isA<SubscriptionLoaded>());
    final state = cubit.state as SubscriptionLoaded;
    expect(state.isPremium, false);
    expect(state.errorMessage, contains('Invalid or expired promo code'));
  });
}
