import 'package:drift/drift.dart' show Value, OrderingTerm;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import '../data/notifications.dart';
import '../widgets/app_feedback.dart';

Future<void> showLogMaintenanceSheet(
  BuildContext context,
  AppDatabase db,
  MaintenanceItem item,
  int? currentOdometer,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => LogMaintenanceSheet(
      db: db,
      item: item,
      currentOdometer: currentOdometer,
    ),
  );
}

class LogMaintenanceSheet extends StatefulWidget {
  const LogMaintenanceSheet({
    super.key,
    required this.db,
    required this.item,
    required this.currentOdometer,
  });

  final AppDatabase db;
  final MaintenanceItem item;
  final int? currentOdometer;

  @override
  State<LogMaintenanceSheet> createState() => _LogMaintenanceSheetState();
}

class _LogMaintenanceSheetState extends State<LogMaintenanceSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _odometer;
  late final TextEditingController _cost;
  
  DateTime _date = DateTime.now();
  bool _saving = false;
  int? _previousOdo;

  @override
  void initState() {
    super.initState();
    _odometer = TextEditingController(
      text: widget.currentOdometer?.toString() ?? '',
    );
    _cost = TextEditingController();
    _loadPreviousService();
  }

  @override
  void dispose() {
    _odometer.dispose();
    _cost.dispose();
    super.dispose();
  }

  String? _serviceOdometer(String? v) {
    final n = int.tryParse(v?.trim() ?? '');
    if (n == null) return 'Numbers only';
    if (n <= 0) return 'Must be more than 0';

    // An odometer only goes up. A reading below the last recorded service
    // is a typo - this is how 4,000 km got logged on a 38,000 km bike.
    final previous = _previousOdo;
    if (previous != null && n < previous) {
      final km = NumberFormat.decimalPattern().format(previous);
      return 'Last service was at $km km';
    }

    return null;
  }

  /// Cost is optional - blank is a valid answer.
  String? _optionalMoney(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return null;
    final n = double.tryParse(s);
    if (n == null) return 'Numbers only';
    if (n < 0) return "Can't be negative";
    return null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    final odo = int.parse(_odometer.text.trim());
    final costText = _cost.text.trim();
    final cost = costText.isEmpty ? null : double.parse(costText);

    // One writer, one transaction. The log is the record; the item's
    // lastOdo/lastDate are a cache of its newest row. Because both writes
    // live here and nowhere else, they can't drift apart.
    await widget.db.transaction(() async {
      await widget.db
        .into(widget.db.serviceLogs)
        .insert(
          ServiceLogsCompanion.insert(
            itemId: widget.item.id,
            odometer: odo,
            date: _date,
            cost: Value(cost),
          ),
        );

      await (widget.db.update(widget.db.maintenanceItems)
            ..where((t) => t.id.equals(widget.item.id)))
          .write(
            MaintenanceItemsCompanion(
              lastOdo: Value(odo),
              lastDate: Value(_date),
            ),
          );
    });

    await Notifications.sync(widget.db);
    if (!mounted) return;
    Navigator.of(context).pop();
    showAppAlert(context, '${widget.item.name} Logged');
  }

  String get _intervalLine {
    final km = widget.item.intervalKm;
    final months = widget.item.intervalMonths;
    if (km != null && months != null) {
      return 'Next due in $km km or $months months, whichever comes first.';
    }
    if (km != null) return 'Next due $km km after this.';
    if (months != null) return 'Next due $months months after this.';
    return 'No interval set for this item yet.';
  }

  /// Removes one service and repairs the cache behind it.
  Future<void> _deleteLog(ServiceLog log) async {
    await widget.db.transaction(() async {
      await (widget.db.delete(widget.db.serviceLogs)
            ..where((t) => t.id.equals(log.id)))
          .go();

      // The cache mirrors the newest surviving log - or nothing at all, if
      // that was the last one. This is the single writer keeping its promise.
      final newest =
          await (widget.db.select(widget.db.serviceLogs)
                ..where((t) => t.itemId.equals(widget.item.id))
                ..orderBy([(t) => OrderingTerm.desc(t.date)])
                ..limit(1))
              .getSingleOrNull();

      await (widget.db.update(widget.db.maintenanceItems)
            ..where((t) => t.id.equals(widget.item.id)))
          .write(
            MaintenanceItemsCompanion(
              lastOdo: Value(newest?.odometer),
              lastDate: Value(newest?.date),
            ),
          );
    });

    await Notifications.sync(widget.db);
    if (!mounted) return;
    showAppAlert(context, 'Service removed');
  }

  /// The three most recent services, newest first.
  Stream<List<ServiceLog>> _history() {
    return (widget.db.select(widget.db.serviceLogs)
          ..where((t) => t.itemId.equals(widget.item.id))
          ..orderBy([(t) => OrderingTerm.desc(t.date)])
          ..limit(3))
        .watch();
  }

    /// The highest odometer this item was ever serviced at - the floor for a
  /// new entry.
  Future<void> _loadPreviousService() async {
    final row =
        await (widget.db.select(widget.db.serviceLogs)
              ..where((t) => t.itemId.equals(widget.item.id))
              ..orderBy([(t) => OrderingTerm.desc(t.odometer)])
              ..limit(1))
            .getSingleOrNull();

    if (!mounted) return;
    setState(() {
      _previousOdo = row?.odometer;

      // Two sources know the odometer: fuel entries (the prefill) and past
      // services. Offer whichever is higher, so the form never opens on a
      // value its own validator would reject.
      final shown = int.tryParse(_odometer.text.trim()) ?? 0;
      if (row != null && row.odometer > shown) {
        _odometer.text = row.odometer.toString();
      }
    });
  }

  Widget _historySection(ThemeData theme) {
    return StreamBuilder<List<ServiceLog>>(
      stream: _history(),
      builder: (context, snapshot) {
        final logs = snapshot.data;
        if (logs == null || logs.isEmpty) return const SizedBox.shrink();

        final date = DateFormat('d MMM yyyy');
        final km = NumberFormat.decimalPattern();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'PREVIOUSLY',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            for (final log in logs)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${date.format(log.date)} · ${km.format(log.odometer)} km'
                      '${log.cost == null ? '' : ' · ₱${log.cost!.toStringAsFixed(0)}'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    visualDensity: VisualDensity.compact,
                    color: theme.colorScheme.onSurfaceVariant,
                    onPressed: () => _deleteLog(log),
                  ),
                ],
              ),
          ],
        );
      },
    );
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
            Text('Log ${widget.item.name}', style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              _intervalLine,
                style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            _historySection(theme),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today, size: 16),
              label: Text('${_date.day}/${_date.month}/${_date.year}'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _odometer,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Odometer at service (km)',
              ),
              validator: _serviceOdometer,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cost,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Cost',
                prefixText: '₱ ',
                helperText: 'Optional - parts and labour',
              ),
              validator: _optionalMoney,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_saving ? 'SAVING...' : 'LOG IT'),
            ),
          ],
        ),
      ),
    );
  }
}