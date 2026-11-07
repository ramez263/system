import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/hive_storage_service.dart';
import '../../domain/entities/payment_record.dart';
import '../../domain/entities/subscription_plan.dart';
import '../../domain/entities/subscription_status.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../models/payment_record_model.dart';
import '../models/subscription_plan_model.dart';
import '../models/subscription_status_model.dart';

class SubscriptionRepositoryImpl implements ISubscriptionRepository {
  final DioClient _dioClient;
  final IHiveStorageService _hiveStorage;

  static const String _plansCacheKey = 'cached_plans_list';

  SubscriptionRepositoryImpl({
    required DioClient dioClient,
    required IHiveStorageService hiveStorage,
  })  : _dioClient = dioClient,
        _hiveStorage = hiveStorage;

  @override
  Future<Either<Failure, List<SubscriptionPlan>>> getPlans() async {
    try {
      final response = await _dioClient.get('/api/v1/plans');
      final data = response.data;

      if (data != null && data['status'] == 'success') {
        final list = (data['data'] as List)
            .map((e) => SubscriptionPlanModel.fromJson(e as Map<String, dynamic>))
            .toList();

        final serialized = jsonEncode(list.map((p) => p.toJson()).toList());
        await _hiveStorage.put(HiveStorageService.boxCache, _plansCacheKey, serialized);

        return Right(list);
      }

      return const Left(ServerFailure('Failed to parse subscription plans.'));
    } on DioException catch (e) {
      final cached = _hiveStorage.get<String>(HiveStorageService.boxCache, _plansCacheKey);
      if (cached != null) {
        try {
          final decoded = jsonDecode(cached) as List;
          return Right(decoded.map((e) => SubscriptionPlanModel.fromJson(e as Map<String, dynamic>)).toList());
        } catch (_) {}
      }
      return Left(ServerFailure(e.message ?? 'Network error while fetching subscription plans.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionStatus>> getStatus() async {
    try {
      final response = await _dioClient.get('/api/v1/subscriptions/status');
      final data = response.data;

      if (data != null && data['status'] == 'success') {
        final status = SubscriptionStatusModel.fromJson(data['data'] as Map<String, dynamic>);
        return Right(status);
      }

      return const Left(ServerFailure('Failed to retrieve subscription status.'));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error while checking subscription status.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentRecord>>> getPaymentHistory() async {
    try {
      final response = await _dioClient.get('/api/v1/subscriptions/history');
      final data = response.data;

      if (data != null && data['status'] == 'success') {
        final list = (data['data'] as List)
            .map((e) => PaymentRecordModel.fromJson(e as Map<String, dynamic>))
            .toList();
        return Right(list);
      }

      return const Left(ServerFailure('Failed to parse payment history.'));
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Network error while loading payment history.'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionStatus>> verifyPurchase({
    required int planId,
    required String purchaseToken,
    String? orderId,
    String? store,
  }) async {
    try {
      final payload = {
        'plan_id': planId,
        'purchase_token': purchaseToken,
        'order_id': orderId,
        'store': store ?? 'google_play',
      };

      final response = await _dioClient.post('/api/v1/subscriptions/verify', data: payload);
      final data = response.data;

      if (data != null && data['status'] == 'success') {
        // Fetch refreshed status with entitlements
        return await getStatus();
      }

      final errorMsg = data?['message'] as String? ?? 'Purchase verification failed.';
      return Left(ServerFailure(errorMsg));
    } on DioException catch (e) {
      final errorData = e.response?.data;
      final msg = errorData is Map && errorData['message'] != null
          ? errorData['message'] as String
          : (e.message ?? 'Network error verifying purchase.');
      return Left(ServerFailure(msg));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SubscriptionStatus>> redeemPromoCode(String code) async {
    try {
      final response = await _dioClient.post(
        '/api/v1/subscriptions/redeem-code',
        data: {'code': code.trim().toUpperCase()},
      );

      final data = response.data;
      if (data != null && data['status'] == 'success') {
        return await getStatus();
      }

      final msg = data?['message'] as String? ?? 'Invalid promo code.';
      return Left(ServerFailure(msg));
    } on DioException catch (e) {
      final errorData = e.response?.data;
      final msg = errorData is Map && errorData['message'] != null
          ? errorData['message'] as String
          : (e.message ?? 'Failed to redeem promo code.');
      return Left(ServerFailure(msg));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
