import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../data/database.dart';
import '../widgets/app_feedback.dart';
import 'add_bike_sheet.dart';

/// Returns 'add' if the user asked to add a bike, otherwise null.
Future<String?> showGarageSheet(BuildContext context, AppDatabase db) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => GarageSheet(db: db),
  );
}

class GarageSheet extends StatelessWidget {
  const GarageSheet({super.key, required this.db});

  final AppDatabase db;

  Future<void> _setActive(int id) {
    return db.transaction(() async {
      await db
          .update(db.bikes)
          .write(const BikesCompanion(isActive: Value(false)));
      await (db.update(db.bikes)..where((b) => b.id.equals(id)))
          .write(const BikesCompanion(isActive: Value(true)));
    });
  }

  Future<void> _delete(BuildContext context, Bike bike) async {
    final theme = Theme.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surfaceContainer,
        title: Text('Delete ${bike.nickname}?'),
        content: const Text(
          'Every fill-up logged against this bike goes too. '
          'This cannot be undone.',
        ),
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

    if (confirmed != true) return;

    await db.transaction(() async {
      await (db.delete(db.bikes)..where((b) => b.id.equals(bike.id))).go();

      // If we just deleted the active bike, promote another one.
      final remaining = await db.select(db.bikes).get();
      if (remaining.isNotEmpty && !remaining.any((b) => b.isActive)) {
        await (db.update(db.bikes)
              ..where((b) => b.id.equals(remaining.first.id)))
            .write(const BikesCompanion(isActive: Value(true)));
      }
    });

    if (context.mounted) {
      showAppAlert(context, '${bike.nickname} deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Garage', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          StreamBuilder<List<Bike>>(
            stream: db.select(db.bikes).watch(),
            builder: (context, snapshot) {
              final bikes = snapshot.data ?? const <Bike>[];
              return Column(
                children: [
                  for (final b in bikes)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.two_wheeler,
                        color: b.isActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      title: Text(b.nickname),
                      subtitle: Text('${b.make} ${b.model}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (b.isActive)
                            Icon(
                              Icons.check,
                              color: theme.colorScheme.primary,
                            ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            color: theme.colorScheme.onSurfaceVariant,
                            onPressed: () {
                              Navigator.of(context).pop();
                              showAddBikeSheet(context, db, bike: b);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: theme.colorScheme.onSurfaceVariant,
                            onPressed: () => _delete(context, b),
                          ),
                        ],
                      ),
                      onTap: () async {
                        await _setActive(b.id);
                        if (context.mounted) Navigator.of(context).pop();
                      },
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop('add'),
            icon: const Icon(Icons.add),
            label: const Text('ADD BIKE'),
          ),
        ],
      ),
    );
  }
}
