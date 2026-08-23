import 'package:flutter_application_1/features/notifications/domain/entities/app_notification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppNotification', () {
    test('parses a DB row into a typed entity', () {
      final AppNotification notification =
          AppNotification.fromJson(<String, dynamic>{
        'id': 'n-1',
        'user_id': 'u-1',
        'type': 'technician_accepted',
        'title': 'Order accepted',
        'body': 'Your technician is on the way',
        'data': <String, dynamic>{'deep_link': '/orders/o-1/tracking'},
        'read': false,
        'created_at': '2026-08-23T10:00:00Z',
      });

      expect(notification.id, 'n-1');
      expect(notification.userId, 'u-1');
      expect(notification.type, 'technician_accepted');
      expect(notification.read, isFalse);
      expect(notification.deepLink, '/orders/o-1/tracking');
    });

    test('defaults missing optional fields', () {
      final AppNotification notification =
          AppNotification.fromJson(<String, dynamic>{
        'id': 'n-2',
        'user_id': 'u-1',
        'type': 'payment_confirmed',
        'title': 'Paid',
        'body': 'Payment received',
      });

      expect(notification.read, isFalse);
      expect(notification.data, isEmpty);
      expect(notification.deepLink, isNull);
    });
  });
}
