import 'package:flutter_application_1/core/logger/app_logger.dart';
import 'package:flutter_application_1/features/_shared/data/mappers/entity_mappers.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/order.dart';
import 'package:flutter_application_1/features/orders/domain/repositories/orders_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation of [OrdersRepository].
///
/// All methods preserve byte-for-byte the column writes that the legacy
/// `AuthService.createOrder` etc. produced. The only behavioural change is
/// the type returned from read methods (`Order` instead of
/// `Map<String, dynamic>`).
class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl(this._supabase);

  final SupabaseClient _supabase;

  static const String _table = 'orders';

  @override
  Future<void> createOrder({
    required String clientId,
    required String carId,
    required String serviceType,
    required String description,
    String? imageUrl,
    required double latitude,
    required double longitude,
  }) async {
    final currentUser = _supabase.auth.currentUser;
    final customerName = currentUser?.userMetadata?['full_name'] as String?;
    final customerPhone = currentUser?.userMetadata?['phone'] as String?;

    appLogger.i('OrdersRepository.createOrder client=$clientId car=$carId');
    await _supabase.from(_table).insert(<String, dynamic>{
      'customer_id': clientId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'car_id': carId,
      'service_type': serviceType,
      'description': description,
      'image_url': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'status': 'pending',
      'technician_id': null,
      'technician_name': null,
      'payment_status': 'pending',
      'accepted_at': null,
      'driving_at': null,
      'arrived_at': null,
      'working_at': null,
      'finished_at': null,
      'completed_at': null,
      'notes': null,
      'total_amount': null,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<Order>> getClientOrders({required String clientId}) async {
    appLogger.i('OrdersRepository.getClientOrders clientId=$clientId');
    final response = await _supabase
        .from(_table)
        .select('*, car_info:cars(*)')
        .eq('customer_id', clientId)
        .order('created_at', ascending: false);
    return EntityMappers.ordersFromJson(
      response.cast<Map<String, dynamic>>(),
    );
  }

  @override
  Future<List<Order>> getPendingOrders() async {
    appLogger.i('OrdersRepository.getPendingOrders');
    final response = await _supabase
        .from(_table)
        .select('*, car_info:cars(*)')
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return EntityMappers.ordersFromJson(
      response.cast<Map<String, dynamic>>(),
    );
  }

  @override
  Future<void> acceptOrder({
    required String orderId,
    required String technicianId,
    required String technicianName,
  }) async {
    appLogger.i('OrdersRepository.acceptOrder id=$orderId tech=$technicianId');
    await _supabase.from(_table).update(<String, dynamic>{
      'status': 'accepted',
      'technician_id': technicianId,
      'technician_name': technicianName,
      'accepted_at': DateTime.now().toIso8601String(),
    }).eq('id', orderId);
  }

  @override
  Future<void> confirmOrderCompletion({required String orderId}) async {
    appLogger.i('OrdersRepository.confirmOrderCompletion id=$orderId');
    await _supabase.from(_table).update(<String, dynamic>{
      'status': 'completed',
      'completed_at': DateTime.now().toIso8601String(),
    }).eq('id', orderId);
  }

  @override
  Future<void> payOrder({
    required String orderId,
    required String paymentMethod,
  }) async {
    appLogger.i('OrdersRepository.payOrder id=$orderId method=$paymentMethod');
    await _supabase.from(_table).update(<String, dynamic>{
      'status': 'paid',
      'payment_status': 'paid',
      'payment_method': paymentMethod,
      'completed_at': DateTime.now().toIso8601String(),
    }).eq('id', orderId);
  }

  @override
  Future<void> submitRating({
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    appLogger.i('OrdersRepository.submitRating id=$orderId rating=$rating');
    await _supabase.from(_table).update(<String, dynamic>{
      'rating': rating,
      'rating_comment': comment,
      'rated_at': DateTime.now().toIso8601String(),
    }).eq('id', orderId);
  }

  @override
  Future<bool> hasAcceptedOrders({required String technicianId}) async {
    final response = await _supabase
        .from(_table)
        .select('id')
        .eq('technician_id', technicianId)
        .inFilter('status', <String>[
          'accepted',
          'on_the_way',
          'arrived',
          'working',
          'finished',
        ])
        .maybeSingle();
    return response != null;
  }

}
