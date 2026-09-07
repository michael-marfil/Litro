import 'package:flutter_test/flutter_test.dart';
import 'package:litro/data/database.dart';
import 'package:litro/domain/maintenance.dart';

MaintenanceItem item({
  int? intervalKm,
  int? intervalMonths,
  int? lastOdo,
  DateTime? lastDate,
  String name = 'Oil change',
}) {
  return MaintenanceItem(
    id: 1,
    bikeId: 1,
    name: name,
    intervalKm: intervalKm,
    intervalMonths: intervalMonths,
    lastOdo: lastOdo,
    lastDate: lastDate,
  );
}

void main() {
  final now = DateTime(2026, 9, 4);

  group('kmRemaining', () {
    test('counts down from the last service', () {
      expect(
        Maintenance.kmRemaining(
          item(intervalKm: 2000, lastOdo: 34000),
          35700,
        ),
        300,
      );
    });

    test('goes negative when overdue', () {
      expect(
        Maintenance.kmRemaining(
          item(intervalKm: 2000, lastOdo: 30000),
          35700,
        ),
        -3700,
      );
    });

    test('is null with no odometer reading yet', () {
      expect(
        Maintenance.kmRemaining(item(intervalKm: 2000, lastOdo: 34000), null),
        isNull,
      );
    });

    test('is null when the item is time-based only', () {
      expect(
        Maintenance.kmRemaining(
          item(intervalMonths: 6, lastDate: DateTime(2026, 3, 1)),
          35700,
        ),
        isNull,
      );
    });
  });

  group('daysRemaining', () {
    test('counts down from the last service date', () {
      expect(
        Maintenance.daysRemaining(
          item(intervalMonths: 3, lastDate: DateTime(2026, 8, 4)),
          now,
        ),
        61,
      );
    });

    test('goes negative when overdue', () {
      expect(
        Maintenance.daysRemaining(
          item(intervalMonths: 3, lastDate: DateTime(2026, 1, 1)),
          now,
        ),
        lessThan(0),
      );
    });
  });

  group('progress — whichever comes first', () {
    test('uses distance when only km is set', () {
      expect(
        Maintenance.progress(
          item(intervalKm: 2000, lastOdo: 34000),
          35000,
          now,
        ),
        closeTo(0.5, 0.001),
      );
    });

    test('takes the further-along of the two', () {
      // 25% through on distance, but ~99% through on time.
      final both = item(
        intervalKm: 2000,
        lastOdo: 34000,
        intervalMonths: 3,
        lastDate: DateTime(2026, 6, 5),
      );
      expect(
        Maintenance.progress(both, 34500, now),
        greaterThan(0.9),
      );
    });

    test('is null when nothing is trackable', () {
      expect(Maintenance.progress(item(), 35000, now), isNull);
    });
  });

  group('byUrgency', () {
    test('puts the most overdue first and untrackable last', () {
      final overdue = item(intervalKm: 1000, lastOdo: 30000, name: 'Chain');
      final fresh = item(intervalKm: 2000, lastOdo: 35500, name: 'Oil');
      final unknown = item(name: 'Tyres');

      final sorted = Maintenance.byUrgency(
        [fresh, unknown, overdue],
        35700,
        now,
      );

      expect(sorted.map((i) => i.name), ['Chain', 'Oil', 'Tyres']);
    });
  });
}
