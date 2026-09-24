import 'package:flutter_test/flutter_test.dart';
import 'package:litro/data/database.dart';
import 'package:litro/domain/spending.dart';

FuelEntry entry(DateTime date, double amount) => FuelEntry(
  id: date.millisecondsSinceEpoch,
  bikeId: 1,
  date: date,
  odometer: 35000,
  liters: 4,
  pricePerLiter: 78,
  amountPaid: amount,
  isFullTank: true,
);

ServiceLog service(DateTime date, {double? cost}) => ServiceLog(
  id: date.millisecondsSinceEpoch,
  itemId: 1,
  odometer: 35000,
  date: date,
  cost: cost,
);

void main() {
  final now = DateTime(2026, 9, 15);

  group('byMonth', () {
    test('returns one bucket per month, oldest first', () {
      final months = Spending.byMonth([], [], now, months: 3);

      expect(months.length, 3);
      expect(months.map((m) => m.month.month), [7, 8, 9]);
    });

    test('drops each fill into its own month', () {
      final months = Spending.byMonth(
        [entry(DateTime(2026, 7, 10), 300), entry(DateTime(2026, 9, 5), 450)],
        [],
        now,
        months: 3,
      );

      expect(months[0].fuel, 300);
      expect(months[1].fuel, 0); // August, nothing spent
      expect(months[2].fuel, 450);
    });

    test('adds up several fills in the same month', () {
      final months = Spending.byMonth(
        [entry(DateTime(2026, 9, 2), 300), entry(DateTime(2026, 9, 20), 450)],
        [],
        now,
        months: 1,
      );

      expect(months.single.fuel, 750);
    });

    test('counts servicing apart from fuel, ignoring logs with no cost', () {
      final months = Spending.byMonth(
        [],
        [service(DateTime(2026, 9, 3), cost: 570), service(DateTime(2026, 9, 9))],
        now,
        months: 1,
      );

      expect(months.single.service, 570);
      expect(months.single.fuel, 0);
    });

    test('crosses the year boundary', () {
      final months = Spending.byMonth(
        [entry(DateTime(2025, 12, 20), 400)],
        [],
        DateTime(2026, 2, 10),
        months: 3,
      );

      expect(
        months.map((m) => '${m.month.year}-${m.month.month}'),
        ['2025-12', '2026-1', '2026-2'],
      );
      expect(months[0].fuel, 400);
    });

    test('ignores anything older than the window', () {
      final months = Spending.byMonth(
        [entry(DateTime(2026, 1, 5), 999)],
        [],
        now,
        months: 3,
      );

      expect(months.every((m) => m.fuel == 0), isTrue);
    });
  });

  group('fuelSpend', () {
    test('adds up every fill ever', () {
      expect(
        Spending.fuelSpend([
          entry(DateTime(2026, 7, 10), 300),
          entry(DateTime(2026, 9, 5), 450),
        ]),
        750,
      );
    });

    test('is zero with no fills', () {
      expect(Spending.fuelSpend([]), 0);
    });
  });
}
