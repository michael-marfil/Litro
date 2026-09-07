import 'package:flutter_test/flutter_test.dart';
import 'package:litro/data/database.dart';
import 'package:litro/domain/fuel_stats.dart';

FuelEntry entry({
  required int odometer,
  required double liters,
  required double amountPaid,
  bool isFullTank = true,
  DateTime? date,
}) {
  return FuelEntry(
    id: odometer,
    bikeId: 1,
    date: date ?? DateTime(2026, 8, 1),
    odometer: odometer,
    liters: liters,
    pricePerLiter: amountPaid / liters,
    amountPaid: amountPaid,
    isFullTank: isFullTank,
  );
}

void main() {
  group('lifetimeKmPerL', () {
    test('is null with no entries', () {
      expect(FuelStats.lifetimeKmPerL([]), isNull);
    });

    test('is null with one entry — no distance to measure', () {
      expect(
        FuelStats.lifetimeKmPerL([
          entry(odometer: 35000, liters: 4, amountPaid: 300),
        ]),
        isNull,
      );
    });

    test('excludes the first fill from litres burned', () {
      final entries = [
        entry(odometer: 35000, liters: 5, amountPaid: 400),
        entry(odometer: 35300, liters: 6, amountPaid: 480),
      ];
      expect(FuelStats.lifetimeKmPerL(entries), closeTo(50.0, 0.001));
    });

    test('is null when the odometer never moved', () {
      final entries = [
        entry(odometer: 35000, liters: 5, amountPaid: 400),
        entry(odometer: 35000, liters: 6, amountPaid: 480),
      ];
      expect(FuelStats.lifetimeKmPerL(entries), isNull);
    });

    test('does not depend on input order', () {
      final a = entry(odometer: 35000, liters: 5, amountPaid: 400);
      final b = entry(odometer: 35300, liters: 6, amountPaid: 480);
      expect(FuelStats.lifetimeKmPerL([b, a]), FuelStats.lifetimeKmPerL([a, b]));
    });
  });

  group('costPerKm', () {
    test('divides total spend by distance', () {
      final entries = [
        entry(odometer: 35000, liters: 5, amountPaid: 400),
        entry(odometer: 35400, liters: 6, amountPaid: 480),
      ];
      expect(FuelStats.costPerKm(entries), closeTo(2.2, 0.001));
    });

    test('is null with one entry', () {
      expect(
        FuelStats.costPerKm([
          entry(odometer: 35000, liters: 4, amountPaid: 300),
        ]),
        isNull,
      );
    });
  });

  group('spendInMonth', () {
    test('counts only the given month', () {
      final entries = [
        entry(odometer: 35000, liters: 5, amountPaid: 400, date: DateTime(2026, 7, 20)),
        entry(odometer: 35300, liters: 6, amountPaid: 480, date: DateTime(2026, 8, 3)),
        entry(odometer: 35600, liters: 4, amountPaid: 320, date: DateTime(2026, 8, 28)),
      ];
      expect(FuelStats.spendInMonth(entries, DateTime(2026, 8, 15)), 800);
    });

    test('is zero when nothing was logged that month', () {
      expect(FuelStats.spendInMonth([], DateTime(2026, 8, 1)), 0);
    });
  });

  group('latestFullTankKmPerL',  () {
    test('is null with no entries', () {
      expect(FuelStats.latestFullTankKmPerL([]), isNull);
    });

    test('is null with a single full tank - nothing to measure from', () {
      expect(
        FuelStats.latestFullTankKmPerL([
          entry(odometer: 35000, liters: 5, amountPaid: 400),
        ]),
        isNull,
      );
    });

    test('measures between two full tanks', () {
      final entries = [
        entry(odometer: 35000, liters: 5, amountPaid: 400),
        entry(odometer: 35300, liters: 6, amountPaid: 480),
      ];
      // 300 km on the 6 L added after the first full tank.
      expect(FuelStats.latestFullTankKmPerL(entries), closeTo(50.0, 0.001));
    });

     test('counts partial top-ups in between', () {
      final entries = [
        entry(odometer: 35000, liters: 5, amountPaid: 400),
        entry(odometer: 35150, liters: 2, amountPaid: 160, isFullTank: false),
        entry(odometer: 35300, liters: 4, amountPaid: 320),
      ];
      // 300 km on 2 + 4 = 6 L.
      expect(FuelStats.latestFullTankKmPerL(entries), closeTo(50.0, 0.001));
    });

    test('is null when only partial fills exist', () {
      final entries = [
        entry(odometer: 35000, liters: 5, amountPaid: 400, isFullTank: false),
        entry(odometer: 35300, liters: 6, amountPaid: 480, isFullTank: false),
      ];
      expect(FuelStats.latestFullTankKmPerL(entries), isNull);
    });

    test('ignores a trailing partial fill and uses the last full tank', () {
      final entries = [
        entry(odometer: 35000, liters: 5, amountPaid: 400),
        entry(odometer: 35300, liters: 6, amountPaid: 480),
        entry(odometer: 35400, liters: 2, amountPaid: 160, isFullTank: false),
      ];
      expect(FuelStats.latestFullTankKmPerL(entries), closeTo(50.0, 0.001));
    });
  });
}
