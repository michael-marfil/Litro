import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show OrderingTerm, Value, StringExpressionOperators;

import '../data/database.dart';

enum _Money { liters, price, amount }
Future<void> showAddEntrySheet(
  BuildContext context, 
  AppDatabase db, 
  Bike bike, {
  FuelEntry? entry,
  String? stationName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => AddEntrySheet(
      db: db,
      bike: bike,
      entry: entry,
      stationName: stationName,
    ),
  );
}

class AddEntrySheet extends StatefulWidget {
    const AddEntrySheet({
      super.key, 
      required this.db, 
      required this.bike,
      this.entry,
      this.stationName,
    });

    final AppDatabase db;
    final Bike bike;
    final FuelEntry? entry;
    final String? stationName;

    @override
    State<AddEntrySheet> createState() => _AddEntrySheetState();
}

class _AddEntrySheetState extends State<AddEntrySheet> {
    final _formKey = GlobalKey<FormState>();
    late final TextEditingController _odometer;
    late final TextEditingController _amount;
    late final TextEditingController _price;
    late final TextEditingController _station;
    late final TextEditingController _liters;

    late DateTime _date;
    late bool _isFullTank;
    bool _saving = false;
    int? _lastOdometer;

    bool get _isEditing => widget.entry != null;

    @override
    void initState() {
      super.initState();
      final e = widget.entry;

      _odometer = TextEditingController(text: e?.odometer.toString() ?? '');
      _amount = TextEditingController(text: e?.amountPaid.toString() ?? '');
      _price = TextEditingController(text: e?.pricePerLiter.toString() ?? '');
      _station = TextEditingController(text: widget.stationName ?? '');
      _liters = TextEditingController(text: e?.liters.toStringAsFixed(2) ?? '');

      _date = e?.date ?? DateTime.now();
      _isFullTank = e?.isFullTank ?? true;
      
      _recent.addAll([_Money.amount, _Money.price]);

      if (!_isEditing) _loadLastOdometer();
    }

    Future<void> _loadLastOdometer() async {
      final query = widget.db.select(widget.db.fuelEntries)
          ..where((t) => t.bikeId.equals(widget.bike.id))
          ..orderBy([(t) => OrderingTerm.desc(t.odometer)])
          ..limit(1);

      final rows = await query.get();
      if (!mounted) return;
      setState(() {
        _lastOdometer = rows.isEmpty ? null : rows.first.odometer;
      });
    }

    @override
    void dispose() {
        _odometer.dispose();
        _amount.dispose();
        _price.dispose();
        _station.dispose();
        _liters.dispose();
        super.dispose();
    }

    // /// Litres derived from ₱ ÷ price-per-litre. Null until both are usable.
    // double? get _liters {
    //     final amount = double.tryParse(_amount.text.trim());
    //     final price = double.tryParse(_price.text.trim());
    //     if (amount == null || price == null || price <= 0) return null;
    //     return amount / price;
    // }
    /// The two fields the user most recently edited, newest first.
    final _recent = <_Money>[];

    /// The one we compute - whichever the user hasn't touched lately.
    _Money? get _derived {
      if (_recent.length < 2) return null;
      return _Money.values.firstWhere((f) => !_recent.contains(f));
    }

    void _touched(_Money field) {
      _recent 
        ..remove(field)
        ..insert(0, field);
      if (_recent.length > 2) _recent.removeLast();

      _recompute();
      setState(() {});
    }

    void _recompute() {
      final target = _derived;
      if (target == null) return;

      final liters = double.tryParse(_liters.text.trim());
      final price = double.tryParse(_price.text.trim());
      final amount = double.tryParse(_amount.text.trim());

      switch (target) {
        case _Money.liters:
          if (amount != null && price != null && price > 0) {
            _liters.text = (amount / price).toStringAsFixed(2);
          }
        case _Money.amount:
          if (liters != null && price != null) {
            _amount.text = (liters * price).toStringAsFixed(2);
          }
        case _Money.price:
          if (amount != null && liters != null && liters > 0) {
            _price.text = (amount / liters).toStringAsFixed(2);
          }
      }
    }

    String? _positive(String? v) {
        final n = double.tryParse(v?.trim() ?? '');
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

    /// Returns the id of the station with this name, creating it if it's new.
    /// Null when the field was left blank.
    Future<int?> _stationId() async {
      final name = _station.text.trim();
      if (name.isEmpty) return null;

      final db = widget.db;
      final existing = await (db.select(db.stations)
            ..where((s) => s.name.lower().equals(name.toLowerCase())))
          .getSingleOrNull();

      if (existing != null) return existing.id;

      return db.into(db.stations).insert(
        StationsCompanion.insert(name: name),
      );
    }

    Future<void> _save() async {
      if (!_formKey.currentState!.validate()) return;
      final liters = double.parse(_liters.text.trim());

      final odo = int.parse(_odometer.text.trim());

      if (!_isEditing) {
        final last = _lastOdometer;
        if (last != null && odo <= last) {
          final proceed = await _confirmLowOdometer(odo, last);
          if (proceed != true) return;
        }
      }

      final tank = widget.bike.tankCapacityL;
      if (tank != null && liters > tank * 1.05) {
        final proceed = await _confirmOverTank(liters, tank);
        if (proceed != true) return;
      } 

      setState(() => _saving = true);

      final stationId = await _stationId();
      final entry = widget.entry;

      if (entry != null) {
        await (widget.db.update(widget.db.fuelEntries)
              ..where((t) => t.id.equals(entry.id)))
            .write(
          FuelEntriesCompanion(
            date: Value(_date),
            odometer: Value(odo),
            liters: Value(liters),
            pricePerLiter: Value(double.parse(_price.text.trim())),
            amountPaid: Value(double.parse(_amount.text.trim())),
            isFullTank: Value(_isFullTank),
            stationId: Value(stationId),
          ),
        );
      } else {
        await widget.db.into(widget.db.fuelEntries).insert(
          FuelEntriesCompanion.insert(
            bikeId: widget.bike.id,
            date: _date,
            odometer: odo,
            liters: liters,
            pricePerLiter: double.parse(_price.text.trim()),
            amountPaid: double.parse(_amount.text.trim()),
            isFullTank: _isFullTank,
            stationId: Value(stationId),
          ),
        );
      }

      if (mounted) Navigator.of(context).pop();
    }

    Future<bool?> _confirmOverTank(double liters, double tank) {
      final theme = Theme.of(context);

      return showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: theme.colorScheme.surfaceContainer,
          title: const Text('More than the tank holds'),
          content: Text(
            '${liters.toStringAsFixed(2)} L is more than '
            "${widget.bike.nickname}'s ${tank.toStringAsFixed(1)} L tank."
            'Is this a typo?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('LET ME FIX IT'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                'SAVE ANYWAY',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          ],
        ),
      );
    }

    Future<bool?> _confirmLowOdometer(int odo, int last) {
      final theme = Theme.of(context);

      return showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: theme.colorScheme.surfaceContainer,
          title: const Text('Odometer looks wrong'),
          content: Text(
            '$odo km is not higher than your last reading of $last km. '
            'Odometers only go up - is this a typo?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('LET ME FIX IT'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                'SAVE ANYWAY',
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

        return Padding(
            padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
            ),
            child: SingleChildScrollView(
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
                              _isEditing ? 'Edit fill-up' : 'Log a fill-up',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 20),

                            OutlinedButton.icon(
                                onPressed: _pickDate,
                                icon: const Icon(Icons.calendar_today, size: 16),
                                label: Text('${_date.day}/${_date.month}/${_date.year}'),
                            ),
                            const SizedBox(height: 12),

                            _Field(
                                controller: _odometer,
                                label: 'Odometer (km)',
                                validator: _positive,
                                helperText: _lastOdometer == null
                                    ? null
                                    : 'Last reading: $_lastOdometer km',
                            ),
                            _Field(
                              controller: _amount,
                              label: 'Amount paid (₱)',
                              validator: _positive,
                              onChanged: (_) => _touched(_Money.amount),
                              helperText: _derived == _Money.amount
                                  ? 'computed'
                                  : null,
                            ),
                            _Field(
                              controller: _price,
                              label: 'Price per litre (₱)',
                              validator: _positive,
                              onChanged: (_) => _touched(_Money.price),
                              helperText: _derived == _Money.price
                                  ? 'computed'
                                  : null,
                            ),
                            _Field(
                              controller: _liters,
                              label: 'Litres',
                              validator: _positive,
                              onChanged: (_) => _touched(_Money.liters),
                              helperText: _derived == _Money.liters
                                  ? 'computed'
                                  : null,
                            ),
                            _Field(
                              controller: _station,
                              label: 'Station (optional)',
                            ),

                            StreamBuilder<List<Station>>(
                              stream: widget.db.select(widget.db.stations).watch(),
                              builder: (context, snapshot) {
                                final stations = snapshot.data ?? const <Station>[];
                                if (stations.isEmpty) return const SizedBox.shrink();

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      for (final s in stations)
                                        ActionChip(
                                          label: Text(s.name),
                                          onPressed: () => _station.text = s.name,
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            SwitchListTile(
                                value: _isFullTank,
                                onChanged: (v) => setState(() => _isFullTank = v),
                                title: const Text('Filled to full?'),
                                contentPadding: EdgeInsets.zero,
                            ),
                            const SizedBox(height: 4),

                            FilledButton(
                                onPressed: _saving ? null : _save,
                                child: Text(_saving ? 'SAVING...' : 'SAVE FILL-UP'),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}

class _Field extends StatelessWidget {
    const _Field({
        required this.controller,
        required this.label,
        this.validator,
        this.onChanged,
        this.helperText,
    });

    final TextEditingController controller;
    final String label;
    final String? Function(String?)? validator;
    final void Function(String)? onChanged;
    final String? helperText;

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextFormField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: label,
                  helperText: helperText,
                ),
                validator: validator,
                onChanged: onChanged,
            ),
        );
    }
}