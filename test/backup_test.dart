import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:litro/data/backup.dart';
import 'package:litro/data/database.dart';

ServiceLog serviceLog(int id, {double? cost}) => ServiceLog(
  id: id,
  itemId: 1,
  odometer: 35000 + id,
  date: DateTime(2026, 9, id),
  cost: cost,
);

/// A backup envelope with every section empty unless given otherwise.
String envelope({
  int formatVersion = 2,
  List<ServiceLog> serviceLogs = const [],
  bool includeServiceLogs = true,
  String app = 'litro',
}) {
  return jsonEncode(<String, Object?>{
    'app': app,
    'formatVersion': formatVersion,
    'schemaVersion': 4,
    'exportedAt': DateTime(2026, 10, 2).toIso8601String(),
    'bikes': <Object?>[],
    'stations': <Object?>[],
    'fuelEntries': <Object?>[],
    'maintenanceItems': <Object?>[],
    if (includeServiceLogs)
      'serviceLogs': serviceLogs.map((l) => l.toJson()).toList(),
  });
}

void main() {
  group('parse', () {
    test('reads service logs from a format 2 file', () {
      final payload = Backup.parse(
        envelope(serviceLogs: [serviceLog(1, cost: 450), serviceLog(2)]),
      );

      expect(payload.serviceLogs, hasLength(2));
      expect(payload.serviceLogs.first.cost, 450);
      expect(payload.serviceLogs.last.cost, isNull);
    });

    test('accepts a format 1 file, which predates service logs', () {
      final payload = Backup.parse(
        envelope(formatVersion: 1, includeServiceLogs: false),
      );

      expect(payload.serviceLogs, isEmpty);
    });

    test('refuses a file from a newer version of the app', () {
      expect(
        () => Backup.parse(envelope(formatVersion: 3)),
        throwsFormatException,
      );
    });

    test('refuses a file that is not a Litro backup', () {
      expect(() => Backup.parse(envelope(app: 'something')), throwsA(isA<FormatException>()));
    });

    test('refuses a format 2 file with its service logs missing', () {
      // Missing, not empty - that means damage, and silently restoring
      // nothing is how a whole table gets wiped without anyone noticing.
      expect(
        () => Backup.parse(envelope(includeServiceLogs: false)),
        throwsFormatException,
      );
    });

    test('refuses anything that is not JSON', () {
      expect(() => Backup.parse('not json at all'), throwsA(anything));
    });
  });

  group('round trip', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('a service and its cost survive export and restore', () async {
      final bikeId = await db
          .into(db.bikes)
          .insert(
            BikesCompanion.insert(
              nickname: 'Daily Click',
              make: 'Honda',
              model: 'Click 125i',
              oilIntervalKm: 1500,
            ),
          );

      final itemId = await db
          .into(db.maintenanceItems)
          .insert(
            MaintenanceItemsCompanion.insert(
              bikeId: bikeId,
              name: 'Oil change',
              intervalKm: const Value(1500),
            ),
          );

      await db
          .into(db.serviceLogs)
          .insert(
            ServiceLogsCompanion.insert(
              itemId: itemId,
              odometer: 35655,
              date: DateTime(2026, 9, 3),
              cost: const Value(450),
            ),
          );

      final json = await Backup.toJson(db);
      await Backup.apply(db, Backup.parse(json));

      final logs = await db.select(db.serviceLogs).get();
      expect(logs, hasLength(1));
      expect(logs.single.cost, 450);
      expect(logs.single.odometer, 35655);
    });
  });

    group('isOverdue', () {
    final now = DateTime(2026, 10, 2);

    test('is true when there has never been a backup', () {
      expect(Backup.isOverdue(null, now), isTrue);
    });

    test('is true at exactly the threshold', () {
      expect(Backup.isOverdue(DateTime(2026, 9, 2), now), isTrue);
    });

    test('is false a day short of it', () {
      expect(Backup.isOverdue(DateTime(2026, 9, 3), now), isFalse);
    });

    test('is false right after a backup', () {
      expect(Backup.isOverdue(now, now), isFalse);
    });
  });
}
