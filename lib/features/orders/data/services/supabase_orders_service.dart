import 'package:flutter_application_1/core/logger/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase wrapper for the `orders` table.
///
/// Phase 2.6 carve-out: every method that mutates or reads `orders`
/// lives here so feature repositories never depend on
/// `AuthService`/`SupabaseAuthService` for table traffic.
class SupabaseOrdersService {
  SupabaseOrdersService(this._supabase);

  final SupabaseClient _supabase;

  static const String _table = 'orders';

  Future<void> createOrder({
    required String clientId,
    required String carId,
    required String serviceType,
    required String description,
    String? imageUrl,
    required double latitude,
    required double longitude,
    String? customerName,
    String? customerPhone,
  }) async {
    appLogger.i(
      'SupabaseOrdersService.createOrder client=$clientId car=$carId',
    );
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

  Future<List<Map<String, dynamic>>> getClientOrders({
    required String clientId,
  }) async {
    final response = await _supabase
        .from(_table)
        .select('*, car_info:cars(*)')
        .eq('customer_id', clientId)
        .order('created_at', ascending: false);
    return response.cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getPendingOrders() async {
    final response = await _supabase
        .from(_table)
        .select('*, car_info:cars(*)')
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return response.cast<Map<String, dynamic>>();
  }

  Future<void> acceptOrder({
    required String orderId,
    required String technicianId,
    required String technicianName,
  }) async {
    await _supabase.from(_table).update(<String, dynamic>{
      'status': 'accepted',
      'technician_id': technicianId,
      'technician_name': technicianName,
      'accepted_at': DateTime.now().toIso8601String(),
    }).eq('id', orderId);
  }

  Future<void> confirmOrderCompletion({required String orderId}) async {
    await _supabase.from(_table).update(<String, dynamic>{
      'status': 'completed',
      'completed_at': DateTime.now().toIso8601String(),
    }).eq('id', orderId);
  }

  Future<void> payOrder({
    required String orderId,
    required String paymentMethod,
  }) async {
    await _supabase.from(_table).update(<String, dynamic>{
      'status': 'paid',
      'payment_status': 'paid',
      'payment_method': paymentMethod,
      'completed_at': DateTime.now().toIso8601String(),
    }).eq('id', orderId);
  }

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
