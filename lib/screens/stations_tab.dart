import 'package:drift/drift.dart' show leftOuterJoin;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';

typedef _Summary = ({
  Station station,
  int fills,
  double liters,
  double avgPricePerLiter,
  double totalSpent,
});

class StationsTab extends StatelessWidget {
  const StationsTab({super.key, required this.db});

  final AppDatabase db;

  Stream<List<_Summary>> _watch() {
    final query = db.select(db.fuelEntries).join([
      leftOuterJoin(
        db.stations,
        db.stations.id.equalsExp(db.fuelEntries.stationId),
      ),
    ]);

    return query.watch().map((rows) {
      final entriesBy = <int, List<FuelEntry>>{};
      final stations = <int, Station>{};

      for (final r in rows) {
        final s = r.readTableOrNull(db.stations);
        if (s == null) continue;
        stations[s.id] =  s;
        entriesBy.putIfAbsent(s.id, () => []).add(r.readTable(db.fuelEntries));
      }

      final out = entriesBy.entries.map((e) {
        final entries = e.value;
        final liters = entries.fold<double>(0, (s, x) => s + x.liters);
        final spent = entries.fold<double>(0, (s, x) => s + x.amountPaid);
        return (
          station: stations[e.key]!,
          fills: entries.length,
          liters: liters,
          avgPricePerLiter: liters == 0 ? 0.0 : spent / liters,
          totalSpent: spent,
        );
      }).toList();

      out.sort(
        (a, b) => a.avgPricePerLiter.compareTo(b.avgPricePerLiter),
      );
      return out;
    });
  }

  Future<void> _delete(BuildContext context, Station s) async {
    final theme = Theme.of(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surfaceContainer,
        title: Text('Delete ${s.name}?'),
        content: const Text(
          'Your fill-ups are kept - they just stop being linked to a station.',
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

    if (ok != true) return;
    await (db.delete(db.stations)..where((t) => t.id.equals(s.id))).go();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final peso = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 2,
    );

    return StreamBuilder<List<_Summary>>(
      stream: _watch(),
      builder: (context, snapshot) {
        final rows = snapshot.data;
        if (rows == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (rows.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No stations yet. \nAdd one when you log a fill-up.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        final totalSpent = rows.fold<double>(0, (s, r) => s + r.totalSpent);
        final totalLiters = rows.fold<double>(0, (s, r) => s + r.liters);
        final avgPrice =  totalLiters == 0 ? 0.0 : totalSpent / totalLiters;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _SummaryStrip(
                totalSpent: totalSpent,
                avgPrice: avgPrice,
                stationCount: rows.length,
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: rows.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final r = rows[i];
                  final cheapest = i == 0 && rows.length > 1;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                      border: cheapest
                          ? Border.all(
                            color: theme.colorScheme.primary.withValues(alpha: 0.5),
                          )
                          : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      r.station.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleMedium,
                                    ),
                                  ),
                                  if (cheapest) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      'CHEAPEST',
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${r.fills} fill-ups · ${peso.format(r.totalSpent)} total',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${peso.format(r.avgPricePerLiter)}/L',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontSize: 15,
                            letterSpacing: 0,
                            color: cheapest
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: theme.colorScheme.onSurfaceVariant,
                          onPressed: () => _delete(context, r.station),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  const _SummaryStrip({
    required this.totalSpent,
    required this.avgPrice,
    required this.stationCount,
  });

  final double totalSpent;
  final double avgPrice;
  final int stationCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final peso = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 2,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Cell(label: 'TOTAL SPENT', value: peso.format(totalSpent)),
              _Cell(label: 'AVG PRICE', value: '${peso.format(avgPrice)}/L'),
              _Cell(label: 'STATIONS', value: '$stationCount'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'ACROSS ALL BIKES',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: 17,
                letterSpacing: 0,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}