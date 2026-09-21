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

FuelEntry fill(int odometer, DateTime date) {
  return FuelEntry(
    id: odometer,
    bikeId: 1,
    date: date,
    odometer: odometer,
    liters: 4,
    pricePerLiter: 78,
    amountPaid: 312,
    isFullTank: true,
  );
}

void main() {
  final now = DateTime(2026, 9, 4);

  group('kmRemaining', () {
    test('counts down from the last service', () {
      expect(
        Maintenance.kmRemaining(item(intervalKm: 2000, lastOdo: 34000), 35700),
        300,
      );
    });

    test('goes negative when overdue', () {
      expect(
        Maintenance.kmRemaining(item(intervalKm: 2000, lastOdo: 30000), 35700),
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
      expect(Maintenance.progress(both, 34500, now), greaterThan(0.9));
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

  // 750 km over 30 days — 25 km/day, about what a daily commute looks like.
  final rides = [
    fill(35000, DateTime(2026, 8, 5)),
    fill(35400, DateTime(2026, 8, 20)),
    fill(35750, DateTime(2026, 9, 4)),
  ];

  group('averageKmPerDay', () {
    test('is 25 for 750 km over 30 days', () {
      expect(Maintenance.averageKmPerDay(rides), 25);
    });

    test('is null with fewer than three fill-ups', () {
      expect(Maintenance.averageKmPerDay(rides.take(2).toList()), isNull);
    });

    test('is null when the history is under two weeks', () {
      // Real bug: three fills crammed into two days gave 600 km/day.
      final crammed = [
        fill(35000, DateTime(2026, 9, 3)),
        fill(35400, DateTime(2026, 9, 4)),
        fill(35750, DateTime(2026, 9, 4)),
      ];
      expect(Maintenance.averageKmPerDay(crammed), isNull);
    });

    test('is null when the odometer never moved', () {
      final parked = [
        fill(35000, DateTime(2026, 8, 5)),
        fill(35000, DateTime(2026, 8, 20)),
        fill(35000, DateTime(2026, 9, 4)),
      ];
      expect(Maintenance.averageKmPerDay(parked), isNull);
    });
  });

  group('estimatedDueDate', () {
    test('uses the calendar when only months are set', () {
      expect(
        Maintenance.estimatedDueDate(
          item(intervalMonths: 3, lastDate: DateTime(2026, 7, 1)),
          rides,
          now,
        ),
        DateTime(2026, 10, 1),
      );
    });

    test('projects from riding pace when only km is set', () {
      // Due at 36500. Currently 35750 → 750 km left at 25/day = 30 days.
      expect(
        Maintenance.estimatedDueDate(
          item(intervalKm: 1500, lastOdo: 35000),
          rides,
          now,
        ),
        DateTime(2026, 10, 4),
      );
    });

    test('takes whichever comes first', () {
      final both = item(
        intervalKm: 1500,
        lastOdo: 35000,
        intervalMonths: 3,
        lastDate: DateTime(2026, 7, 1),
      );
      // Calendar says 1 Oct, pace says 4 Oct.
      expect(
        Maintenance.estimatedDueDate(both, rides, now),
        DateTime(2026, 10, 1),
      );
    });

    test('is null when there is no pace and no calendar', () {
      expect(
        Maintenance.estimatedDueDate(
          item(intervalKm: 1500, lastOdo: 35000),
          rides.take(1).toList(),
          now,
        ),
        isNull,
      );
    });
  });
}
