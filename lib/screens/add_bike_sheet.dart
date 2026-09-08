import 'package:flutter/material.dart';
import 'package:drift/drift.dart' show Value;
import '../data/database.dart';
import '../widgets/app_feedback.dart';
import '../data/bike_presets.dart';

Future<void> showAddBikeSheet(
  BuildContext context,
  AppDatabase db, {
  Bike? bike,  
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => AddBikeSheet(db: db, bike: bike),
  );
}

class AddBikeSheet extends StatefulWidget {
    const AddBikeSheet({super.key, required this.db, this.bike});

    final AppDatabase db;
    final Bike? bike;

    @override
    State<AddBikeSheet> createState() => _AddBikeSheetState();
}

class _AddBikeSheetState extends State<AddBikeSheet> {
    final _formKey = GlobalKey<FormState>();
    late final TextEditingController _nickname;
    late final TextEditingController _make;
    late final TextEditingController _model;
    late final TextEditingController _oilInterval;
    late final TextEditingController _year;
    late final TextEditingController _tank;
    late final TextEditingController _factory;

    bool _saving = false;
    BikePreset? _preset;
    bool get _isEditing => widget.bike != null;

    @override
    void initState() {
      super.initState();
      final b = widget.bike;
      _nickname = TextEditingController(text: b?.nickname ?? '');
      _make = TextEditingController(text: b?.make ?? '');
      _model = TextEditingController(text: b?.model ?? '');
      _oilInterval = TextEditingController(
        text: b?.oilIntervalKm.toString() ?? '2000',
      );
      _year = TextEditingController(text: b?.year?.toString() ?? '');
      _tank = TextEditingController(text: b?.tankCapacityL?.toString() ?? '');
      _factory = TextEditingController(
        text: b?.factoryKmPerL?.toString() ?? '',
      );
    }

    @override
    void dispose() {
        _nickname.dispose();
        _make.dispose();
        _model.dispose();
        _oilInterval.dispose();
        _year.dispose();
        _tank.dispose();
        _factory.dispose();
        super.dispose();
    }

    String? _required(String? v) =>
        (v == null || v.trim().isEmpty) ? 'Required' : null;

    String? _positiveInt(String? v) {
        final n = int.tryParse(v?.trim() ?? '');
        if (n == null) return 'Numbers only';
        if (n <= 0) return 'Must be more than 0';
        return null;
    }

    String? _optional(String? v) {
      final t = v?.trim() ?? '';
      if (t.isEmpty) return null;
      final n = double.tryParse(t);
      if (n == null) return 'Numbers only';
      if (n <= 0) return 'Must be more than 0';
      return null;
    }

    Value<int?> _optInt(TextEditingController c) {
      final t = c.text.trim();
      return Value(t.isEmpty ? null : int.parse(t));
    }

    Value<double?> _optDouble(TextEditingController c) {
      final t = c.text.trim();
      return Value(t.isEmpty ? null : double.parse(t));
    }

    Future<void> _save() async {
      if (!_formKey.currentState!.validate()) return;

      setState(() => _saving = true);

      final bike = widget.bike;

      if (bike != null) {
          await (widget.db.update(widget.db.bikes)
                ..where((b) => b.id.equals(bike.id)))
              .write(
            BikesCompanion(
              nickname: Value(_nickname.text.trim()),
              make: Value(_make.text.trim()),
              model: Value(_model.text.trim()),
              oilIntervalKm: Value(int.parse(_oilInterval.text.trim())),
              year: _optInt(_year),
              tankCapacityL: _optDouble(_tank),
              factoryKmPerL: _optDouble(_factory),
            ),
          );
      } else {
          await widget.db.transaction(() async {
              await widget.db
                  .update(widget.db.bikes)
                  .write(const BikesCompanion(isActive: Value(false)));

              final bikeId = await widget.db.into(widget.db.bikes).insert(
                BikesCompanion.insert(
                  nickname: _nickname.text.trim(),
                  make: _make.text.trim(),
                  model: _model.text.trim(),
                  oilIntervalKm: int.parse(_oilInterval.text.trim()),
                  isActive: const Value(true),
                  year: _optInt(_year),
                  tankCapacityL: _optDouble(_tank),
                  factoryKmPerL: _optDouble(_factory),
                ),
              );

              // Every bike starts with an oil-change schedule.
              await widget.db.into(widget.db.maintenanceItems).insert(
                MaintenanceItemsCompanion.insert(
                  bikeId: bikeId,
                  name: 'Oil change',
                  intervalKm: Value(int.parse(_oilInterval.text.trim())),
                ),
              );
          });
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      showAppAlert(context, _isEditing ? 'Successfully Updated' : 'Successfully Added');
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
                                    color: theme.colorScheme.onSurfaceVariant.withValues (
                                        alpha: 0.4,
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                ),
                            ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _isEditing ? 'Edit bike' : 'Add bike',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 20),
                        if (!_isEditing) ...[
                          DropdownButtonFormField<BikePreset>(
                            initialValue: _preset,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'Start from a model (optional)',
                              helperText: 
                                'Just a starting point — change '
                                'anything that does not match.',
                              helperMaxLines: 2,
                            ),
                            items: [
                              for (final p in bikePresets)
                                  DropdownMenuItem(
                                    value: p,
                                    child: Text(p.label),
                                  ),
                            ],
                            onChanged: (p) {
                              if (p == null) return;
                              setState(() {
                                _preset = p;
                                _make.text = p.make;
                                _model.text = p.model;
                                _tank.text = p.tankCapacityL.toString();
                                _factory.text = p.factoryKmPerL?.toString() ?? '';
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                        ],
                        _Field(
                            controller: _nickname,
                            label: 'Nickname',
                            validator: _required,
                        ),
                        _Field(controller: _make, label: 'Make', validator: _required),
                        _Field(controller: _model, label: 'Model', validator: _required),
                        _Field(
                            controller: _oilInterval,
                            label: 'Oil change interval (km)',
                            keyboardType: TextInputType.number,
                            validator: _positiveInt,
                        ),
                        _Field(
                          controller: _year,
                          label: 'Year (optional)',
                          keyboardType: TextInputType.number,
                          validator: _optional,
                        ),
                        _Field(
                          controller: _tank,
                          label: 'Tank capacity in litres (optional)',
                          keyboardType: TextInputType.number,
                          validator: _optional,
                        ),
                        _Field(
                          controller: _factory,
                          label: 'Factory km/L (optional)',
                          keyboardType: TextInputType.number,
                          validator: _optional,
                        ),
                        const SizedBox(height: 8),
                        FilledButton(
                            onPressed: _saving ? null : _save,
                            child: Text(
                              _saving 
                                ? 'SAVING...' 
                                : (_isEditing ? 'SAVE CHANGES' : 'SAVE BIKE'),  
                            ),
                        ),
                    ],
                ),
            ),
        );
    }
}

class _Field extends StatelessWidget {
    const _Field({
        required this.controller,
        required this.label,
        this.keyboardType,
        this.validator,
    });

    final TextEditingController controller;
    final String label;
    final TextInputType? keyboardType;
    final String? Function(String?)? validator;

    @override
    Widget build(BuildContext context) {
        return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                decoration: InputDecoration(labelText: label),
                validator: validator,
            ),
        );
    }
}