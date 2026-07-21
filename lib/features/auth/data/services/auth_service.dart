import 'package:supabase_flutter/supabase_flutter.dart';

/// A service that handles direct communication with Supabase for authentication.
class AuthService {
  final SupabaseClient _supabaseClient;

  AuthService(this._supabaseClient);

  /// Provides a stream of the current user's authentication state.
  Stream<User?> get authStateChanges => _supabaseClient.auth.onAuthStateChange
      .map((event) => event.session?.user);

  /// Attempts to sign in the user with the given email and password.
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      await _ensureProfileExists();
    } on PostgrestException catch (e, st) {
      print('[AUTH] signInWithEmailAndPassword PostgrestException code=${e.code}, message=${e.message}');
      print(st);
      rethrow;
    } catch (e, st) {
      print('[AUTH] signInWithEmailAndPassword EXCEPTION: $e');
      print(st);
      rethrow;
    }
  }

  /// Attempts to sign up a new user with the given details.
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      print("=== SIGNUP METHOD ENTERED ===");
      print('[AUTH] Starting signUp for email: $email');
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );
      print("=== AFTER SIGNUP ===");
      print("USER = ${response.user?.id}");
      print('[AUTH] signUp completed. user=${response.user?.id}, session=${response.session != null}');
      final user = response.user;
      if (user != null) {
        print('[AUTH] user is not null. user.id=${user.id}');
        print('[AUTH] user.userMetadata=${user.userMetadata}');
        // Use response.user directly instead of auth.currentUser to avoid
        // race conditions where currentUser may not be updated yet.
      
        // Verify the row actually exists
        final verify = await _supabaseClient
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        print('[AUTH] Verification query result: $verify');
        
        if (verify == null) {
          print('[AUTH] ERROR: Profile insert returned success but row does not exist!');
        } else {
          print('[AUTH] SUCCESS: Profile row verified in database');
        }
      } else {
        print('[AUTH] user is null after signUp');
      }
      return user;
    } on PostgrestException catch (e, st) {
      print("=== PROFILE UPSERT EXCEPTION ===");
      print(e);
      print("========== PROFILE INSERT FAILED ==========");
      print("message: ${e.message}");
      print("code: ${e.code}");
      print("details: ${e.details}");
      print("hint: ${e.hint}");
      print("stack:");
      print(st);
      rethrow;
    } catch (e, st) {
      print("=== PROFILE UPSERT EXCEPTION ===");
      print(e);
      print("UNKNOWN ERROR");
      print(e.runtimeType);
      print(e);
      print(st);
      rethrow;
    }
  }

  /// Saves a user profile into the profiles table.
  Future<void> saveProfile({
    required String userId,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String userType,
  }) async {
    try {
      print('[AUTH] saveProfile called for userId=$userId');
      final payload = {
        'id': userId,
        'name': '$firstName $lastName',
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'role': userType,
        'user_type': userType,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      print('[AUTH] saveProfile payload: $payload');
      final response = await _supabaseClient.from('profiles').upsert(payload);
      print('[AUTH] saveProfile success: $response');
      
      final verify = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      print('[AUTH] saveProfile verification: $verify');
    } catch (e, stackTrace) {
      if (e is PostgrestException) {
        print('[AUTH] saveProfile PostgrestException code=${e.code}, message=${e.message}, details=${e.details}, hint=${e.hint}');
      } else {
        print('[AUTH] saveProfile EXCEPTION: $e');
      }
      print('[AUTH] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> _ensureProfileExists() async {
    try {
      final currentUser = _supabaseClient.auth.currentUser;
      print('[AUTH] _ensureProfileExists called. currentUser=${currentUser?.id}');
      if (currentUser == null) {
        print('[AUTH] _ensureProfileExists: currentUser is null, returning');
        return;
      }

      final existing = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', currentUser.id)
          .maybeSingle();
      print('[AUTH] _ensureProfileExists existing=$existing');

      if (existing != null) {
        print('[AUTH] _ensureProfileExists: profile already exists');
        return;
      }

      final metadata = currentUser.userMetadata ?? {};
      final payload = {
        'id': currentUser.id,
        'name': metadata['full_name'] ?? '',
        'first_name': metadata['first_name'] ?? '',
        'last_name': metadata['last_name'] ?? '',
        'email': currentUser.email ?? '',
        'phone': metadata['phone'] ?? '',
        'role': metadata['user_type'] ?? 'client',
        'user_type': metadata['user_type'] ?? 'client',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      print('[AUTH] _ensureProfileExists inserting payload: $payload');
      try {
        final response = await _supabaseClient.from('profiles').upsert(payload);
        print('[AUTH] _ensureProfileExists success: $response');
      } on PostgrestException catch (e, st) {
        print('[AUTH] _ensureProfileExists upsert PostgrestException code=${e.code}, message=${e.message}, details=${e.details}, hint=${e.hint}');
        print(st);
      } catch (e, st) {
        print('[AUTH] _ensureProfileExists upsert EXCEPTION: $e');
        print(st);
      }

      try {
        final verify = await _supabaseClient
            .from('profiles')
            .select()
            .eq('id', currentUser.id)
            .maybeSingle();
        print('[AUTH] _ensureProfileExists verification: $verify');
      } catch (e, st) {
        print('[AUTH] _ensureProfileExists verification failed: $e');
        print(st);
      }
    } catch (e, stackTrace) {
      if (e is PostgrestException) {
        print('[AUTH] _ensureProfileExists PostgrestException code=${e.code}, message=${e.message}, details=${e.details}, hint=${e.hint}');
      } else {
        print('[AUTH] _ensureProfileExists EXCEPTION: $e');
      }
      print('[AUTH] Stack trace: $stackTrace');
      // Do not rethrow to avoid crashing the auth flow.
    }
  }

  /// Saves a car into the cars table.
  Future<void> saveCar({
    required String userId,
    required String carType,
    required String carModel,
    required String plateNumber,
    String? carYear,
    String? color,
  }) async {
    await _supabaseClient.from('cars').insert({
      'user_id': userId,
      'car_type': carType,
      'car_model': carModel,
      'plate_number': plateNumber,
      'car_year': carYear,
      'color': color,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Creates a new request in the orders table.
  Future<void> createOrder({
    required String clientId,
    required String carId,
    required String serviceType,
    required String description,
    String? imageUrl,
    required double latitude,
    required double longitude,
  }) async {
    final currentUser = _supabaseClient.auth.currentUser;
    final customerName = currentUser?.userMetadata?['full_name'] as String?;
    final customerPhone = currentUser?.userMetadata?['phone'] as String?;

    await _supabaseClient.from('orders').insert({
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

  /// Fetches cars for the current user.
  Future<List<Map<String, dynamic>>> getCars({required String userId}) async {
    final response = await _supabaseClient
        .from('cars')
        .select()
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response as List<dynamic>);
  }

  /// Fetches orders for the current user.
  Future<List<Map<String, dynamic>>> getOrders({required String userId}) async {
    final response = await _supabaseClient
        .from('orders')
        .select('*, car_info:cars(*)')
        .eq('customer_id', userId)
        .order('created_at', ascending: false);
    return _normalizeRows(response);
  }

  /// Fetches a user profile by user ID.
  Future<Map<String, dynamic>?> getProfile({required String userId}) async {
    final response = await _supabaseClient
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (response == null) return null;
    return Map<String, dynamic>.from(response);
  }

  /// Fetches all pending orders for technicians.
  Future<List<Map<String, dynamic>>> getPendingOrders() async {
    final response = await _supabaseClient
        .from('orders')
        .select('*, car_info:cars(*)')
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return _normalizeRows(response);
  }

  /// Technician accepts a pending order.
  Future<void> acceptOrder({
    required String orderId,
    required String technicianId,
    required String technicianName,
  }) async {
    await _supabaseClient
        .from('orders')
        .update({
          'status': 'accepted',
          'technician_id': technicianId,
          'technician_name': technicianName,
          'accepted_at': DateTime.now().toIso8601String(),
        })
        .eq('id', orderId);
  }

  /// Sends a password reset link to the user's email.
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _supabaseClient.auth.resetPasswordForEmail(email);
  }

  /// Updates the current technician location in the profiles table.
  Future<void> updateTechnicianLocation({
    required String technicianId,
    required double latitude,
    required double longitude,
  }) async {
    await _supabaseClient
        .from('profiles')
        .update({
          'current_lat': latitude,
          'current_lng': longitude,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', technicianId);
  }

  /// Checks if a technician has any accepted or active orders.
  Future<bool> hasAcceptedOrders({required String technicianId}) async {
    final response = await _supabaseClient
        .from('orders')
        .select('id')
        .eq('technician_id', technicianId)
        .inFilter('status', ['accepted', 'on_the_way', 'arrived', 'working', 'finished'])
        .maybeSingle();
    return response != null;
  }

  /// Confirms completion of a finished order.
  Future<void> confirmOrderCompletion({required String orderId}) async {
    await _supabaseClient.from('orders').update({
      'status': 'completed',
      'completed_at': DateTime.now().toIso8601String(),
    }).eq('id', orderId);
  }

  /// Marks an order as paid and records the selected payment method.
  Future<void> payOrder({
    required String orderId,
    required String paymentMethod,
  }) async {
    await _supabaseClient.from('orders').update({
      'status': 'paid',
      'payment_status': 'paid',
      'payment_method': paymentMethod,
      'completed_at': DateTime.now().toIso8601String(),
    }).eq('id', orderId);
  }

  /// Signs out the currently logged in user.
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  /// Updates the current user's metadata and profile record.
  Future<void> updateUser({required String name}) async {
    final currentUser = _supabaseClient.auth.currentUser;
    if (currentUser == null) {
      throw AuthException('No authenticated user.');
    }

    await _supabaseClient.auth.updateUser(
      UserAttributes(data: {'full_name': name}),
    );

    await _supabaseClient
        .from('profiles')
        .update({
          'name': name,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', currentUser.id);
  }

  List<Map<String, dynamic>> _normalizeRows(dynamic response) {
    if (response is! List) {
      return [];
    }

    return response.cast<Map<String, dynamic>>();
  }
}
