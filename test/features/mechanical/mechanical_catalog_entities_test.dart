// Tests for the Mechanical Issues Catalog domain entities + matching rules.
import 'package:flutter_application_1/features/_shared/domain/entities/car.dart';
import 'package:flutter_application_1/features/mechanical/domain/entities/mechanical_catalog_entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CarModelCatalogEntry.matchesCar', () {
    test('matches on brand + model case-insensitively, trimmed', () {
      const entry = CarModelCatalogEntry(
        id: 'm1',
        brand: 'Hyundai',
        model: 'Verna',
        getsExtraIssues: true,
      );

      expect(
        entry.matchesCar(
          const Car(
            id: 'c1',
            userId: 'u1',
            carType: 'Hyundai',
            carModel: 'Verna',
            plateNumber: 'ABC',
          ),
        ),
        isTrue,
      );

      // Case-insensitive + whitespace tolerance.
      expect(
        entry.matchesCar(
          const Car(
            id: 'c2',
            userId: 'u1',
            carType: '  hyundai ',
            carModel: ' verna ',
            plateNumber: 'ABC',
          ),
        ),
        isTrue,
      );
    });

    test('does NOT match different brand or model', () {
      const entry = CarModelCatalogEntry(
        id: 'm1',
        brand: 'Hyundai',
        model: 'Verna',
        getsExtraIssues: false,
      );

      const car = Car(
        id: 'c1',
        userId: 'u1',
        carType: 'Hyundai',
        carModel: 'Accent',
        plateNumber: 'ABC',
      );

      expect(entry.matchesCar(car), isFalse);
    });
  });

  group('MechanicalIssuesResult', () {
    test('noMatch has no model entry and no issues', () {
      const result = MechanicalIssuesResult.noMatch();

      expect(result.hasMatch, isFalse);
      expect(result.modelEntry, isNull);
      expect(result.issues, isEmpty);
    });

    test('matched exposes the model entry and issues', () {
      const entry = CarModelCatalogEntry(
        id: 'm1',
        brand: 'Hyundai',
        model: 'Verna',
        getsExtraIssues: true,
      );
      const common = MechanicalIssue(
        id: 'i1',
        name: 'تغيير تيل الفرامل',
        isCommon: true,
      );
      const extra = MechanicalIssue(
        id: 'i2',
        name: 'تغيير سير الكاتينة',
        isCommon: false,
      );

      const result = MechanicalIssuesResult.matched(
        modelEntry: entry,
        issues: [common, extra],
      );

      expect(result.hasMatch, isTrue);
      expect(result.modelEntry, entry);
      expect(result.issues, hasLength(2));
    });
  });
}
