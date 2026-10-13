import 'dart:math';

import 'package:drift/drift.dart' show OrderingTerm, innerJoin;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:litro/domain/chart_range.dart';
import 'package:litro/widgets/adaptive_row.dart';

import '../data/database.dart';
import '../domain/fuel_stats.dart';
import '../domain/spending.dart';

class StatsTab extends StatefulWidget {
  const StatsTab({super.key, required this.db, required this.bike});

  final AppDatabase db;
  final Bike bike;

  @override
  State<StatsTab> createState() => _StatsTabState();
}

class _StatsTabState extends State<StatsTab> {
  ChartRange _range = ChartRange.sixMonths;
  late Stream<List<FuelEntry>> _entries;

  @override
  void initState() {
    super.initState();
    _entries = _watchEntries();
  }

  // Switching bikes keeps this State and hands it a new widget, so the query
  // has to follow the bike rather than being built once and forgotten.
  @override
  void didUpdateWidget(StatsTab old) {
    super.didUpdateWidget(old);
    if (old.bike.id != widget.bike.id) _entries = _watchEntries();
  }

  Stream<List<FuelEntry>> _watchEntries() {
    return (widget.db.select(widget.db.fuelEntries)
          ..where((t) => t.bikeId.equals(widget.bike.id))
          ..orderBy([(t) => OrderingTerm.asc(t.odometer)]))
        .watch();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FuelEntry>>(
      stream: _entries,
      builder: (context, snapshot) {
        final entries = snapshot.data;
        if (entries == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Window that gets plotted, never what gets measured. A tank's
        // efficiency needs the full tank before it, which may fall outside
        // the window - so measure against all of history, then keep only
        // the points that land inside the range.
        final cutoff = _range.cutoff(DateTime.now());
        bool inRange(FuelEntry e) => cutoff == null || !e.date.isBefore(cutoff);

        final efficiency = <FlSpot>[];
        for (final e in entries.where(inRange)) {
          final value = FuelStats.efficiencyForFullTank(entries, e);
          if (value != null) {
            efficiency.add(FlSpot(efficiency.length.toDouble(), value));
          }
        }

        final shown = entries.where(inRange).toList();
        final price = <FlSpot>[
          for (var i = 0; i < shown.length; i++) 
            FlSpot(i.toDouble(), shown[i].pricePerLiter),
        ];

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SegmentedButton<ChartRange>(
              segments: [
                for (final r in ChartRange.values)
                  ButtonSegment(value: r, label: Text(r.label)),
              ],
              selected: {_range},
              onSelectionChanged: (s) => setState(() => _range = s.first),
              showSelectedIcon: false,
            ),
            const SizedBox(height: 16),
            _ChartCard(
              title: 'FUEL EFFICIENCY',
              unit: 'km/L',
              spots: efficiency,
              emptyHint: 'Log at least two full tanks to see a trend.',
            ),
            const SizedBox(height: 12),
            _ChartCard(
              title: 'GAS PRICE',
              unit: '₱/L',
              spots: price,
              emptyHint: 'Log a couple of fill-ups to see price history.',
            ),
            const SizedBox(height: 12),
            _SpendingCard(
              db: widget.db,
              bikeId: widget.bike.id,
              entries: entries,
              monthCount: _range.months ?? 12,
            ),
          ],
        );
      },
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.unit,
    required this.spots,
    required this.emptyHint,
  });

  final String title;
  final String unit;
  final List<FlSpot> spots;
  final String emptyHint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 16, 18, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '$title  ·  $unit',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: spots.length < 2
                ? Center(
                  child: Text(
                    emptyHint,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
                : LineChart(_data(context)),
          ),
        ],
      ),
    );
  }

  LineChartData _data(BuildContext context) {
    final theme = Theme.of(context);
    final line = theme.colorScheme.primary;

    final ys = spots.map((s) => s.y).toList()..sort();
    final pad = ((ys.last - ys.first) * 0.25).clamp(1.0, 1000.0);
    final minY = ys.first - pad;
    final maxY = ys.last + pad;
    final interval = (maxY - minY) / 4;
    final decimals = (maxY - minY) < 10 ? 1 : 0;

    return LineChartData(
      minY: minY,
      maxY: maxY,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: interval,
        getDrawingHorizontalLine: (_) => FlLine(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        bottomTitles: const AxisTitles(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 44 * bodyTextScale(context),
            interval: interval,
            minIncluded: false,
            maxIncluded: false,
            getTitlesWidget: (value, meta) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                value.toStringAsFixed(decimals),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => theme.colorScheme.surface,
          tooltipBorder: BorderSide(color: line.withValues(alpha: 0.4)),
          getTooltipItems: (touched) => touched
              .map(
                (s) => LineTooltipItem(
                  '${s.y.toStringAsFixed(1)} $unit',
                  theme.textTheme.labelMedium!.copyWith(
                    color: line,
                    letterSpacing: 0,
                  ),
                ),
              )
              .toList(),
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          color: line,
          barWidth: 2,
          isCurved: true,
          curveSmoothness: 0.25,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: spots.length <= 12,
            getDotPainter: (spot, _, _, _) => FlDotCirclePainter(
              radius: 4,
              color: line,
              strokeWidth: 2,
              strokeColor: theme.colorScheme.surfaceContainer,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            color: line.withValues(alpha: 0.10)
          ),
        ),
      ],
    );
  }
}

/// Fuel is the brand cyan; servicing is a gold that is deliberately NOT the
/// coral used for alerts - a normal month must not look like a warning.
const _fuelColor = Color(0xFF37D7E6);
const _serviceColor = Color(0xFFB8862E);

class _SpendingCard extends StatelessWidget {
  const _SpendingCard({
    required this.db,
    required this.bikeId,
    required this.entries,
    required this.monthCount,
  });

  final AppDatabase db;
  final int bikeId;
  final List<FuelEntry> entries;
  final int monthCount;

  Stream<List<ServiceLog>> _serviceLogs() {
    final q = 
        db.select(db.serviceLogs).join([
          innerJoin(
            db.maintenanceItems,
            db.maintenanceItems.id.equalsExp(db.serviceLogs.itemId),
          ),
        ])..where(db.maintenanceItems.bikeId.equals(bikeId));

    return q.map((row) => row.readTable(db.serviceLogs)).watch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final peso = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 0,
    );

    return StreamBuilder<List<ServiceLog>>(
      stream: _serviceLogs(),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? const <ServiceLog>[];
        final months = Spending.byMonth(
          entries,
          logs,
          DateTime.now(),
          months: monthCount,
        );

        final maxY = months.fold<double>(
          0,
          (best, m) => max(best, m.fuel + m.service),
        );
        final fuelTotal = months.fold<double>(0, (s, m) => s + m.fuel);
        final serviceTotal = months.fold<double>(0, (s, m) => s + m.service);

        return Container(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SPENDING · LAST $monthCount MONTHS',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 16,
                runSpacing: 6,
                children: [
                  _Key(color: _fuelColor, label: 'Fuel ${peso.format(fuelTotal)}'),
                  _Key(
                    color: _serviceColor,
                    label: 'Servicing ${peso.format(serviceTotal)}',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 180,
                child: maxY == 0
                    ? Center(
                        child: Text(
                          'Log a fill-up to see where the money goes.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    )
                    : BarChart(_data(theme, months, maxY, peso)),
              ),
            ],
          ),
        );
      },
    );
  }

  BarChartData _data(
    ThemeData theme,
    List<MonthSpend> months,
    double maxY,
    NumberFormat peso,
  ) {
    final grid = theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.15);

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY * 1.15,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) => FlLine(color: grid, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            getTitlesWidget: (value, meta) {
              final m = months[value.toInt()].month;
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  DateFormat('MMM').format(m),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => theme.colorScheme.surfaceContainerHighest,
          getTooltipItem: (group, _, _, _) {
            final m = months[group.x];
            return BarTooltipItem(
              '${DateFormat('MMMM').format(m.month)}\n'
              'Fuel ${peso.format(m.fuel)}'
              '${m.service == 0 ? '' : '\nServicing ${peso.format(m.service)}'}',
              theme.textTheme.bodySmall!.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            );
          },
        ),
      ),
      barGroups: [
        for (var i = 0; i < months.length; i++)
          BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: months[i].fuel + months[i].service,
                width: 18,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
                rodStackItems: [
                  BarChartRodStackItem(0, months[i].fuel, _fuelColor),
                  BarChartRodStackItem(
                    months[i].fuel,
                    months[i].fuel + months[i].service,
                    _serviceColor,
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}

/// A legend swatch. The label wears text colour, never the series colour -
/// the square carries the identity.
class _Key extends StatelessWidget {
  const _Key({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}