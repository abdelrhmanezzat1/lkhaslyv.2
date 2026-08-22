// Tests for the new shared domain entities (Phase 1).
import 'package:flutter_application_1/features/_shared/domain/entities/car.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/order.dart';
import 'package:flutter_application_1/features/_shared/domain/entities/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UserProfile', () {
    test('parses legacy dual role/user_type column', () {
      final profile = UserProfile.fromJson(<String, dynamic>{
        'id': 'u1',
        'first_name': 'Ada',
        'last_name': 'Lovelace',
        'email': 'ada@example.com',
        'phone': '+1-555-0100',
        'role': 'technician',
        'user_type': 'technician',
      });

      expect(profile.id, 'u1');
      expect(profile.fullName, 'Ada Lovelace');
      expect(profile.isTechnician, isTrue);
      expect(profile.userType, 'technician');
    });

    test('defaults to client role', () {
      final profile = UserProfile.fromJson(<String, dynamic>{
        'id': 'u2',
        'first_name': '',
        'last_name': '',
        'email': '',
      });

      expect(profile.role, UserRole.client);
      expect(profile.isTechnician, isFalse);
      expect(profile.fullName, '');
    });
  });

  group('Car', () {
    test('parses DB row into typed entity', () {
      final car = Car.fromJson(<String, dynamic>{
        'id': 'c1',
        'user_id': 'u1',
        'car_type': 'Sedan',
        'car_model': 'Model S',
        'plate_number': 'ABC-123',
        'car_year': '2020',
        'color': 'red',
      });

      expect(car.displayName, 'Sedan Model S');
      expect(car.plateNumber, 'ABC-123');
    });

    test('toInsertJson omits optional nulls', () {
      const car = Car(
        id: '',
        userId: 'u1',
        carType: 'SUV',
        carModel: 'RAV4',
        plateNumber: 'XYZ',
      );
      final json = car.toInsertJson();
      expect(json.containsKey('id'), isFalse);
      expect(json['user_id'], 'u1');
      expect(json.containsKey('car_year'), isFalse);
      expect(json.containsKey('color'), isFalse);
    });
  });

  group('Order', () {
    test('parses status enums and car_info join', () {
      final order = Order.fromJson(<String, dynamic>{
        'id': 'o1',
        'customer_id': 'u1',
        'car_id': 'c1',
        'service_type': 'Mechanical',
        'description': 'engine noise',
        'latitude': 30.0,
        'longitude': 31.0,
        'status': 'on_the_way',
        'payment_status': 'pending',
        'car_info': <String, dynamic>{'car_type': 'Sedan'},
        'created_at': '2026-07-01T00:00:00Z',
      });

      expect(order.status, OrderStatus.onTheWay);
      expect(order.paymentStatus, PaymentStatus.pending);
      expect(order.carInfo?['car_type'], 'Sedan');
    });
  });
}
