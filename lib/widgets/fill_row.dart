import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';

/// One fill-up in a list. Pure presentation.
class FillRow extends StatelessWidget {
  const FillRow({
    super.key,
    required this.entry,
    required this.station,
    required this.kmPerL,
  });

  final FuelEntry entry;
  final Station? station;
  final double? kmPerL;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mono = theme.textTheme.labelMedium?.copyWith(letterSpacing: 0);

    final date = DateFormat('MMM d').format(entry.date);
    final odo = NumberFormat.decimalPattern().format(entry.odometer);
    final peso = NumberFormat.currency(
      locale: 'en_PH',
      symbol: '₱',
      decimalDigits: 0,
    ).format(entry.amountPaid);
    final kind = entry.isFullTank ? 'full' : 'partial';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station?.name ?? 'Fill-up',
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  '$date · $odo km · $kind',
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(peso, style: mono?.copyWith(fontSize: 14)),
              const SizedBox(height: 3),
              Text(
                kmPerL == null ? '—' : '${kmPerL!.toStringAsFixed(1)} km/L',
                style: mono?.copyWith(
                  fontSize: 13,
                  color: kmPerL == null
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
