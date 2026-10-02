import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database.dart';

/// Bumped when the *shape of the backup file* changes - separate from the
/// database's schemaVersion, which describes the tables.
const _formatVersion = 2;

abstract final class Backup {
  /// The entire database as a JSON string.
  static Future<String> toJson(AppDatabase db) async {
    final bikes = await db.select(db.bikes).get();
    final stations = await db.select(db.stations).get();
    final entries = await db.select(db.fuelEntries).get();
    final maintenance = await db.select(db.maintenanceItems).get();
    final serviceLogs = await db.select(db.serviceLogs).get();

    final payload = <String, Object?>{
      'app': 'litro',
      'formatVersion': _formatVersion,
      'schemaVersion': db.schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'bikes': bikes.map((b) => b.toJson()).toList(),
      'stations': stations.map((s) => s.toJson()).toList(),
      'fuelEntries': entries.map((e) => e.toJson()).toList(),
      'maintenanceItems': maintenance.map((m) => m.toJson()).toList(),
      'serviceLogs': serviceLogs.map((l) => l.toJson()).toList(),
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
      // Format 1 predats service logs. Those files are still valid - they
      // simply have no history to restore.
      serviceLogs: fileFormat < 2
          ? const []
          : _section(decoded, 'serviceLogs').map(ServiceLog.fromJson).toList(),
    );
  }

  /// Replaces everything in the database with [payload].
  static Future<void> apply(AppDatabase db, BackupPayload payload) {
    return db.transaction(() async {
      // Children before parents — foreign keys are enforced.
      await db.delete(db.serviceLogs).go();
      await db.delete(db.fuelEntries).go();
      await db.delete(db.maintenanceItems).go();
      await db.delete(db.bikes).go();
      await db.delete(db.stations).go();

      await db.batch((b) {
        b.insertAll(db.stations, payload.stations);
        b.insertAll(db.bikes, payload.bikes);
        b.insertAll(db.fuelEntries, payload.entries);
        b.insertAll(db.maintenanceItems, payload.maintenance);
        b.insertAll(db.serviceLogs, payload.serviceLogs);
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

  static const _lastBackupKey = 'last_backup_at';
  static const _snoozeKey = 'backup_snoozed_until';

  /// Whether to nudge. A null [last] means never backed up at all, which is
  /// the case worth nagging about hardest - there is no other copy.
  static bool isOverdue(DateTime? last, DateTime now, {int afterDays = 30}) {
    if (last == null) return true;
    return now.difference(last).inDays >= afterDays;
  }

  /// Call after a backup actually succedds - not when one is started.
  static Future<void> markBackedUp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastBackupKey, DateTime.now().millisecondsSinceEpoch);
  }

  static Future<DateTime?> lastBackupAt() async {
    final prefs = await SharedPreferences.getInstance();
    final ms =  prefs.getInt(_lastBackupKey);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// Dismissing the nudge quitens it for a week rather than forever - 
  /// "not now" is almos never "never".
  static Future<void> snooze() async {
    final prefs = await SharedPreferences.getInstance();
    final until = DateTime.now().add(const Duration(days: 7));
    await prefs.setInt(_snoozeKey, until.millisecondsSinceEpoch);
  }

  static Future<bool> isSnoozed() async {
    final prefs = await SharedPreferences.getInstance();
    final until = prefs.getInt(_snoozeKey);
    if (until == null) return false;
    return DateTime.now().millisecondsSinceEpoch < until;
  }
}

/// A parsed, validated backup. Nothing has touched the database yet.
class BackupPayload {
  const BackupPayload({
    required this.bikes,
    required this.stations,
    required this.entries,
    required this.maintenance,
    required this.serviceLogs,
  });

  final List<Bike> bikes;
  final List<Station> stations;
  final List<FuelEntry> entries;
  final List<MaintenanceItem> maintenance;
  final List<ServiceLog> serviceLogs;
}