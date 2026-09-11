import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

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
  
  DateTime _date = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _odometer = TextEditingController(
      text: widget.currentOdometer?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _odometer.dispose();
    super.dispose();
  }

  String? _positive(String? v) {
    final n = int.tryParse(v?.trim() ?? '');
    if (n == null) return 'Numbers only';
    if (n <= 0) return 'Must be more than 0';
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

    await (widget.db.update(widget.db.maintenanceItems)
          ..where((t) => t.id.equals(widget.item.id)))
        .write(
      MaintenanceItemsCompanion(
        lastOdo: Value(int.parse(_odometer.text.trim())),
        lastDate:  Value(_date),
      ),
    );

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
              validator: _positive,
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