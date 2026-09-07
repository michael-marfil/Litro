import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../domain/maintenance.dart';
import 'log_maintenance_sheet.dart';
import '../widgets/app_feedback.dart';

Future<void> showMaintenanceSheet(
  BuildContext context,
  AppDatabase db,
  Bike bike,
  int? currentOdo,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => MaintenanceSheet(db: db, bike: bike, currentOdo: currentOdo),
  );
}

class MaintenanceSheet extends StatelessWidget {
  const MaintenanceSheet({
    super.key,
    required this.db,
    required this.bike,
    required this.currentOdo,
  });

  final AppDatabase db;
  final Bike bike;
  final int? currentOdo;

  Future<void> _delete(BuildContext context, MaintenanceItem item) async {
    final theme = Theme.of(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surfaceContainer,
        title: Text('Remove ${item.name}?'),
        content: const Text('It stops being tracked. Nothing else changes.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'REMOVE',
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (ok != true) return;
    await (db.delete(db.maintenanceItems)..where((t) => t.id.equals(item.id)))
        .go();

    if (context.mounted) {
      showAppAlert(context, '${item.name} removed');
    }
  }

  String _subtitle(MaintenanceItem i) {
    final km = i.intervalKm;
    final months = i.intervalMonths;
    if (km != null && months != null) return 'Every $km km or $months months';
    if (km != null) return 'Every ${NumberFormat.decimalPattern().format(km)} km';
    if (months != null) return 'Every $months months';
    return 'No interval set';
  }

  String _trailing(MaintenanceItem i) {
    final km = Maintenance.kmRemaining(i, currentOdo);
    if (km != null) {
      return km < 0
          ? '${NumberFormat.decimalPattern().format(-km)} km over'
          : '${NumberFormat.decimalPattern().format(km)} km';
    }
    final days = Maintenance.daysRemaining(i, DateTime.now());
    if (days != null) return days < 0 ? '${-days} d over' : '$days d';
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    final query = db.select(db.maintenanceItems)
      ..where((t) => t.bikeId.equals(bike.id));

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
          Text('Maintenance', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Tap an item to log that you did it.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          StreamBuilder<List<MaintenanceItem>>(
            stream: query.watch(),
            builder: (context, snapshot) {
              final items = Maintenance.byUrgency(
                snapshot.data ?? const [],
                currentOdo,
                now
              );

              if (items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Nothing tracked yet.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  for (final i in items)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(i.name),
                      subtitle: Text(_subtitle(i)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _trailing(i),
                            style: theme.textTheme.labelMedium?.copyWith(
                              letterSpacing: 0,
                              color: (Maintenance.progress(i, currentOdo, now) ?? 0) > 0.9
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.primary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            color: theme.colorScheme.onSurfaceVariant,
                            onPressed: () {
                              Navigator.of(context).pop();
                              showEditMaintenanceSheet(
                                context,
                                db,
                                bike,
                                item: i,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            color: theme.colorScheme.onSurfaceVariant,
                            onPressed: () => _delete(context, i),
                          ),
                        ],
                      ),
                      onTap: () => 
                          showLogMaintenanceSheet(context, db, i, currentOdo),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => showEditMaintenanceSheet(context, db, bike),
            icon: const Icon(Icons.add),
            label: const Text('ADD ITEM'),
          ),
        ],
      ),
    );
  }
}

// --------------------------------------------------------------------------------------------------------------
Future<void> showEditMaintenanceSheet(
  BuildContext context,
  AppDatabase db,
  Bike bike, {
    MaintenanceItem? item,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => EditMaintenanceSheet(db: db, bike: bike, item: item),
  );
}

class EditMaintenanceSheet extends StatefulWidget {
  const EditMaintenanceSheet({super.key, required this.db, required this.bike, this.item});

  final AppDatabase db;
  final Bike bike;
  final MaintenanceItem? item;

  @override
  State<EditMaintenanceSheet> createState() => _EditMaintenanceSheetState();
}

class _EditMaintenanceSheetState extends State<EditMaintenanceSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _km;
  late final TextEditingController _months;

  bool _saving = false;
  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    _name = TextEditingController(text: i?.name ?? '');
    _km = TextEditingController(text: i?.intervalKm?.toString() ?? '');
    _months = TextEditingController(text: i?.intervalMonths?.toString() ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _km.dispose();
    _months.dispose();
    super.dispose();
  }

  String? _required(String? v) => 
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  String? _optionalInt(String? v) {
    final t = v?.trim() ?? '';
    if (t.isEmpty) return null;
    final n = int.tryParse(t);
    if (n == null) return 'Numbers only';
    if (n <= 0) return 'Must be more than 0';
    return null;
  }

  Value<int?> _opt(TextEditingController c) {
    final t = c.text.trim();
    return Value(t.isEmpty ? null : int.parse(t));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final item = widget.item;

    if (item != null) {
      await (widget.db.update(widget.db.maintenanceItems)
            ..where((t) => t.id.equals(item.id)))
          .write(
        MaintenanceItemsCompanion(
          name: Value(_name.text.trim()),
          intervalKm: _opt(_km),
          intervalMonths: _opt(_months),
        ),
      );
    } else {
      await widget.db.into(widget.db.maintenanceItems).insert(
        MaintenanceItemsCompanion.insert(
          bikeId: widget.bike.id,
          name: _name.text.trim(),
          intervalKm: _opt(_km),
          intervalMonths: _opt(_months),
        ),
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop();
    showAppAlert(context, 'Successfully Added');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _isEditing ? 'Edit maintenance' : 'Add maintenance',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Set a distance, a time, or both - whichever comes first wins.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'What is it? e.g. CVT cleaning',
              ),
              validator: _required,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _km,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Every … km (optional)',
              ),
              validator: _optionalInt,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _months,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Every … months (optional)',
              ),
              validator: _optionalInt,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(
                _saving
                    ? 'SAVING...'
                    : (_isEditing ? 'SAVE CHANGES' : 'ADD ITEM'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}