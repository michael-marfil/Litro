import 'package:flutter_test/flutter_test.dart';
import 'package:litro/data/database.dart';
import 'package:litro/data/notifications.dart';

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
  final due = DateTime(2026, 11, 5);

  group('messageFor', () {
    test('counts down while there is still distance left', () {
      // Due at 36500, currently 36345.
      final m = Notifications.messageFor(
        item(intervalKm: 1500, lastOdo: 35000),
        due,
        'Daily Click',
        36345,
      );

      expect(m.title, 'Oil change due soon');
      expect(m.body, contains('about 155 km to go'));
    });

    test('says overdue, with a positive number, once past due', () {
      // Due at 36500, currently 37245 - 745 km late.
      final m = Notifications.messageFor(
        item(intervalKm: 1500, lastOdo: 35000),
        due,
        'Daily Click',
        37245,
      );

      expect(m.title, 'Oil change overdue');
      expect(m.body, contains('745 km past due'));
      expect(m.body, isNot(contains('-')));
    });

    test('falls back to the date when there is no distance to measure', () {
      final m = Notifications.messageFor(
        item(intervalMonths: 3, lastDate: DateTime(2026, 8, 5)),
        due,
        'Daily Click',
        36345,
      );

      expect(m.body, contains('due around 5 Nov'));
    });
  });
}
