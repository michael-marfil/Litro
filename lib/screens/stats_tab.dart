import 'package:drift/drift.dart' show OrderingTerm;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/database.dart';
import '../domain/fuel_stats.dart';

class StatsTab extends StatelessWidget {
  const StatsTab({super.key, required this.db, required this.bike});

  final AppDatabase db;
  final Bike bike;

  @override
  Widget build(BuildContext context) {
    final query = db.select(db.fuelEntries)
      ..where((t) => t.bikeId.equals(bike.id))
      ..orderBy([(t) => OrderingTerm.asc(t.odometer)]);

    return StreamBuilder<List<FuelEntry>>(
      stream: query.watch(),
      builder: (context, snapshot) {
        final entries = snapshot.data;
        if (entries == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final efficiency = <FlSpot>[];
        for (final e in entries) {
          final value = FuelStats.efficiencyForFullTank(entries, e);
          if (value != null) {
            efficiency.add(FlSpot(efficiency.length.toDouble(), value));
          }
        }

        final price = <FlSpot>[
          for (var i = 0; i < entries.length; i++)
            FlSpot(i.toDouble(), entries[i].pricePerLiter),
        ];

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
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
            reservedSize: 44,
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