import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:uuid/uuid.dart';

class BillingPurchaseResult {
  final bool success;
  final String? purchaseToken;
  final String? orderId;
  final String? productId;
  final String? errorMessage;
  final bool isSandbox;

  const BillingPurchaseResult({
    required this.success,
    this.purchaseToken,
    this.orderId,
    this.productId,
    this.errorMessage,
    this.isSandbox = false,
  });

  factory BillingPurchaseResult.success({
    required String purchaseToken,
    required String orderId,
    required String productId,
    bool isSandbox = false,
  }) {
    return BillingPurchaseResult(
      success: true,
      purchaseToken: purchaseToken,
      orderId: orderId,
      productId: productId,
      isSandbox: isSandbox,
    );
  }

  factory BillingPurchaseResult.failure(String error) {
    return BillingPurchaseResult(
      success: false,
      errorMessage: error,
    );
  }
}

class BillingService {
  final InAppPurchase? _customInAppPurchase;
  InAppPurchase get _inAppPurchase => _customInAppPurchase ?? InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  BillingService({InAppPurchase? inAppPurchase})
      : _customInAppPurchase = inAppPurchase;

  Future<bool> isStoreAvailable() async {
    try {
      return await _inAppPurchase.isAvailable();
    } catch (_) {
      return false;
    }
  }

  /// Initiates a purchase for the given product ID.
  /// If the Google Play store is not available (e.g. desktop simulator or missing Play Store),
  /// it performs a sandbox simulated purchase to satisfy developer/testing workflows.
  Future<BillingPurchaseResult> purchaseSubscription({
    required String productId,
    bool forceSandbox = false,
  }) async {
    final available = await isStoreAvailable();

    if (!available || forceSandbox) {
      // Sandbox purchase simulation
      final mockUuid = const Uuid().v4();
      return BillingPurchaseResult.success(
        purchaseToken: 'sandbox_purchase_token_$mockUuid',
        orderId: 'GPA.SANDBOX-${mockUuid.substring(0, 8).toUpperCase()}',
        productId: productId,
        isSandbox: true,
      );
    }

    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails({productId});

      if (response.notFoundIDs.contains(productId) || response.productDetails.isEmpty) {
        // Fallback to sandbox if product is not yet active in Play Console draft
        final mockUuid = const Uuid().v4();
        return BillingPurchaseResult.success(
          purchaseToken: 'sandbox_purchase_token_$mockUuid',
          orderId: 'GPA.SANDBOX-${mockUuid.substring(0, 8).toUpperCase()}',
          productId: productId,
          isSandbox: true,
        );
      }

      final ProductDetails productDetails = response.productDetails.first;
      final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);

      final completer = Completer<BillingPurchaseResult>();

      _subscription?.cancel();
      _subscription = _inAppPurchase.purchaseStream.listen((purchaseDetailsList) {
        for (var purchaseDetails in purchaseDetailsList) {
          if (purchaseDetails.productID == productId) {
            if (purchaseDetails.status == PurchaseStatus.purchased ||
                purchaseDetails.status == PurchaseStatus.restored) {
              if (purchaseDetails.pendingCompletePurchase) {
                _inAppPurchase.completePurchase(purchaseDetails);
              }
              if (!completer.isCompleted) {
                completer.complete(BillingPurchaseResult.success(
                  purchaseToken: purchaseDetails.verificationData.serverVerificationData,
                  orderId: purchaseDetails.purchaseID ?? 'GPA.${const Uuid().v4().substring(0, 8)}',
                  productId: productId,
                ));
              }
            } else if (purchaseDetails.status == PurchaseStatus.error) {
              if (!completer.isCompleted) {
                completer.complete(BillingPurchaseResult.failure(
                  purchaseDetails.error?.message ?? 'Purchase failed.',
                ));
              }
            }
          }
        }
      });

      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      return await completer.future.timeout(
        const Duration(seconds: 45),
        onTimeout: () => BillingPurchaseResult.failure('Purchase timed out.'),
      );
    } catch (e) {
      return BillingPurchaseResult.failure(e.toString());
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
