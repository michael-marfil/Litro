import 'package:drift/drift.dart' show OrderingTerm, leftOuterJoin;
import 'package:flutter/material.dart';

import '../data/database.dart';
import '../domain/fuel_stats.dart';
import '../widgets/fill_row.dart';
import '../widgets/app_feedback.dart';
import 'add_entry_sheet.dart';

class AllFillsScreen extends StatelessWidget {
  const AllFillsScreen({super.key, required this.db, required this.bike});

  final AppDatabase db;
  final Bike bike;

  Stream<List<({FuelEntry entry, Station? station})>> _watch() {
    final query = db.select(db.fuelEntries).join([
      leftOuterJoin(
        db.stations,
        db.stations.id.equalsExp(db.fuelEntries.stationId),
      ),
    ])
      ..where(db.fuelEntries.bikeId.equals(bike.id))
      ..orderBy([OrderingTerm.desc(db.fuelEntries.odometer)]);

    return query.watch().map(
          (rows) => rows
              .map(
                (r) => (
                  entry: r.readTable(db.fuelEntries),
                  station: r.readTableOrNull(db.stations),
                ),
              )
              .toList(),
        );
  }

  Future<void> _delete(BuildContext context, int id) async {
    await (db.delete(db.fuelEntries)..where((t) => t.id.equals(id))).go();
    if (context.mounted) {
      showAppAlert(context, 'Full-up Deleted');
    }
  }

  Future<bool?> _confirmDelete(BuildContext context, FuelEntry e) {
    final theme = Theme.of(context);

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surfaceContainer,
        title: const Text('Delete this fill-up?'),
        content: const Text('Your efficiency numbers will recalculate.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'DELETE',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(bike.nickname),
        backgroundColor: theme.colorScheme.surfaceContainer,
      ),
      body: StreamBuilder<List<({FuelEntry entry, Station? station})>>(
        stream: _watch(),
        builder: (context, snapshot) {
          final rows = snapshot.data;
          if (rows == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (rows.isEmpty) {
            return Center(
              child: Text(
                'No fill-ups yet.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          final entries = rows.map((r) => r.entry).toList();

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: rows.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = rows[i];

              return Dismissible(
                key: ValueKey(r.entry.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmDelete(context, r.entry),
                onDismissed: (_) => _delete(context, r.entry.id),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.delete, color: theme.colorScheme.onError),
                ),
                child: InkWell(
                  onTap: () => showAddEntrySheet(
                    context,
                    db,
                    bike,
                    entry: r.entry,
                    stationName: r.station?.name,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  child: FillRow(
                    entry: r.entry,
                    station: r.station,
                    kmPerL: FuelStats.efficiencyForFullTank(entries, r.entry),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
