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
}