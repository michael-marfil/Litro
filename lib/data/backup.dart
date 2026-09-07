import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'database.dart';

/// Bumped when the *shape of the backup file* changes - separate from the
/// database's schemaVersion, which describes the tables.
const _formatVersion = 1;

abstract final class Backup {
  /// The entire database as a JSON string.
  static Future<String> toJson(AppDatabase db) async {
    final bikes = await db.select(db.bikes).get();
    final stations = await db.select(db.stations).get();
    final entries = await db.select(db.fuelEntries).get();
    final maintenance = await db.select(db.maintenanceItems).get();

    final payload = <String, Object?>{
      'app': 'litro',
      'formatVersion': _formatVersion,
      'schemaVersion': db.schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'bikes': bikes.map((b) => b.toJson()).toList(),
      'stations': stations.map((s) => s.toJson()).toList(),
      'fuelEntries': entries.map((e) => e.toJson()).toList(),
      'maintenanceItems': maintenance.map((m) => m.toJson()).toList(),
    };

    return const JsonEncoder.withIndent(' ').convert(payload);
  }

  /// Writes the backup to a temp file, ready to hand to the share sheet.
  static Future<File> writeFile(AppDatabase db) async {
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().split('T').first;
    final file = File('${dir.path}/litro-backup-$stamp.json');
    
    return file.writeAsString(await toJson(db));
  }

  /// Reads and validates a backup file. Throws [FormatException] with a
  /// message worth showing the user. Touches nothing.
  static BackupPayload parse(String source) {
    final decoded = jsonDecode(source);

    if (decoded is! Map<String, dynamic> || decoded['app'] != 'litro') {
      throw const FormatException("That doesn't look like a Litro backup.");
    }

    final fileFormat = decoded['formatVersion'];
    if (fileFormat is! int) {
      throw const FormatException('This backup file is missing its version.');
    }
    if (fileFormat > _formatVersion) {
      throw const FormatException(
        'This backup was made by a newer version of Litro. '
        'Update the app before restoring it.',
      );
    }

    return BackupPayload(
      bikes: _section(decoded, 'bikes').map(Bike.fromJson).toList(),
      stations: _section(decoded, 'stations').map(Station.fromJson).toList(),
      entries: _section(decoded, 'fuelEntries').map(FuelEntry.fromJson).toList(),
      maintenance: _section(
        decoded,
        'maintenanceItems',
      ).map(MaintenanceItem.fromJson).toList(),
    );
  }

  /// Replaces everything in the database with [payload].
  static Future<void> apply(AppDatabase db, BackupPayload payload) {
    return db.transaction(() async {
      // Children before parents — foreign keys are enforced.
      await db.delete(db.fuelEntries).go();
      await db.delete(db.maintenanceItems).go();
      await db.delete(db.bikes).go();
      await db.delete(db.stations).go();

      await db.batch((b) {
        b.insertAll(db.stations, payload.stations);
        b.insertAll(db.bikes, payload.bikes);
        b.insertAll(db.fuelEntries, payload.entries);
        b.insertAll(db.maintenanceItems, payload.maintenance);
      });
    });
  }

  static List<Map<String, dynamic>> _section(
    Map<String, dynamic> map,
    String key,
  ) {
    if (!map.containsKey(key)) {
      throw FormatException('This backup is missing its "$key" section.');
    }
    final value = map[key];
    if (value is! List) throw FormatException('The "$key" section is damaged.');
    return value.cast<Map<String, dynamic>>();
  }
}

/// A parsed, validated backup. Nothing has touched the database yet.
class BackupPayload {
  const BackupPayload({
    required this.bikes,
    required this.stations,
    required this.entries,
    required this.maintenance,
  });

  final List<Bike> bikes;
  final List<Station> stations;
  final List<FuelEntry> entries;
  final List<MaintenanceItem> maintenance;
}