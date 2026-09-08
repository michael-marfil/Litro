import 'package:flutter/material.dart';
import 'package:litro/screens/log_maintenance_sheet.dart';
import 'dart:math';
import '../data/database.dart';
import 'add_entry_sheet.dart';
import 'package:drift/drift.dart' show OrderingTerm, leftOuterJoin;
import 'package:intl/intl.dart';
import '../domain/fuel_stats.dart';
import 'add_bike_sheet.dart';
import 'garage_sheet.dart';
import '../domain/maintenance.dart';
import '../widgets/fill_row.dart';
import 'all_fills_screen.dart';
import 'stations_tab.dart';
import 'stats_tab.dart';
import 'maintenance_sheet.dart';
import 'coach_overlay.dart';
import 'settings_sheet.dart';
import '../widgets/app_feedback.dart';

class DashboardScreen extends StatefulWidget {
    const DashboardScreen({super.key, required this.db, required this.bike});

    final AppDatabase db;
    final Bike bike;

    @override
    State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
    int _tab = 0;
    final _addKey = GlobalKey();
    final _chipKey = GlobalKey();
    final _maintKey = GlobalKey();
    final _statsKey = GlobalKey();
    bool _guideDismissed = false;

    @override
    Widget build(BuildContext context) {
      final db = widget.db;
      final bike = widget.bike;

      final entriesQuery = db.select(db.fuelEntries)
        ..where((t) => t.bikeId.equals(bike.id));

      return Stack(
        children: [
          Scaffold(
            body: SafeArea(
              bottom: false,
              child: switch (_tab) {
                0 => _DashTab(db: db, bike: bike, chipKey: _chipKey, maintKey: _maintKey),
                1 => StatsTab(db: db, bike: bike),
                _ => StationsTab(db: db),
              },
            ),
            bottomNavigationBar: _BottomNav(
              db: db,
              bike: bike,
              addKey: _addKey,
              statsKey: _statsKey,
              currentIndex: _tab,
              onSelect: (i) => setState(() => _tab = i),
            ),
          ),
          if (!_guideDismissed)
              Positioned.fill(
                child: StreamBuilder<List<FuelEntry>>(
                  stream: entriesQuery.watch(),
                  builder: (context, snap) {
                    final entries = snap.data;
                    if (entries == null || entries.isNotEmpty) {
                      return const SizedBox.shrink();
                    }
                    return CoachOverlay(
                      onDone: () => 
                        setState(() => _guideDismissed = true),
                      steps: [
                        CoachStep(
                          targetKey: _addKey,
                          mascot: 'assets/mascot/point.png',
                          title: 'Log a fill-up',
                          body: 'Amount paid, price per litre, '
                              'odometer. Litro works out the '
                              'litres and your km/L.',
                        ),
                        CoachStep(
                          targetKey: _maintKey,
                          mascot: 'assets/mascot/think.png',
                          title: 'Maintenance',
                          body: 'Oil, chain, brakes — anything '
                              'on a schedule. Swipe for more, '
                              'tap one to log that you did it.', 
                        ),
                        CoachStep(
                          targetKey: _statsKey,
                          mascot: 'assets/mascot/wave.png',
                          title: 'Stats and stations',
                          body: 'Efficiency and gas-price '
                              'trends, plus which station '
                              'actually charges you least.',
                        ),
                        CoachStep(
                          targetKey: _chipKey,
                          mascot: 'assets/mascot/thumbsup.png',
                          title: 'More than one bike?',
                          body: 'Tap your bike name to switch, '
                              'add or edit. Every number '
                              'follows the bike you pick.',
                        ),
                      ],
                    );
                  },
                ),
              ),
        ],
      );
    }
}

class _DashTab extends StatelessWidget {
    const _DashTab({
      required this.db, 
      required this.bike,
      required this.chipKey,
      required this.maintKey,
    });

    final AppDatabase db;
    final Bike bike;
    final GlobalKey chipKey;
    final GlobalKey maintKey;

    @override
    Widget build(BuildContext context) {
        return SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        _Header(db: db, bike: bike, chipKey: chipKey),
                        const SizedBox(height: 16),
                        _HeroCard(db: db, bike: bike),
                        const SizedBox(height: 12),
                        _StatRow(db: db, bikeId: bike.id),
                        const SizedBox(height: 12),
                        KeyedSubtree(
                          key: maintKey,
                          child: _MaintenanceStrip(db: db, bike: bike),
                        ),
                        const SizedBox(height: 22),
                        _SectionHeader(
                          title: 'Recent fills',
                          action: 'All →',
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                AllFillsScreen(db: db, bike: bike),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _RecentFills(db: db, bike: bike),
                    ],
                ),
            ),
        );
    }
}

class _Header extends StatelessWidget {
    const _Header({required this.db,  required this.bike, required this.chipKey});

    final AppDatabase db;
    final Bike bike;
    final GlobalKey chipKey;

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);

        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Text.rich(
                    TextSpan(
                        style: theme.textTheme.titleLarge,
                        children: [
                            const TextSpan(text: 'Lit'),
                            TextSpan(
                                text: 'ro',
                                style: TextStyle(color: theme.colorScheme.primary),
                            ),
                        ],
                    ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    KeyedSubtree(
                      key: chipKey,
                      child: GestureDetector(
                        onTap: () async {
                          final action = await showGarageSheet(context, db);
                          if (action == 'add' && context.mounted) {
                            await showAddBikeSheet(context, db);
                          }
                        },
                        child: _BikeChip(name: bike.nickname),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      color: theme.colorScheme.onSurfaceVariant,
                      onPressed: () => showSettingsSheet(context, db),
                    ),
                  ],
                ),
            ],
        );
    }
}

class _BikeChip extends StatelessWidget {
    const _BikeChip({required this.name});

    final String name;

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);

        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Icon(Icons.two_wheeler, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(name, style: theme.textTheme.titleMedium),
                    const SizedBox(width: 4),
                    Icon(
                        Icons.arrow_drop_down,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                    ),
                ],
            ),
        );
    }
}

class _HeroCard extends StatelessWidget {
    const _HeroCard({required this.db, required this.bike});

    final AppDatabase db;
    final Bike bike;

    @override
    Widget build(BuildContext context) {
        final query = db.select(db.fuelEntries)
            ..where((t) => t.bikeId.equals(bike.id));

        return StreamBuilder<List<FuelEntry>>(
            stream: query.watch(),
            builder: (context, snapshot) {
                final entries = snapshot.data ?? const <FuelEntry>[];
                return _HeroCardBody(
                    bike: bike,
                    kmPerL: FuelStats.latestFullTankKmPerL(entries),
                    lifetimeKmPerL: FuelStats.lifetimeKmPerL(entries),
                );
            },
        );
    }
}

class _HeroCardBody extends StatelessWidget {
    const _HeroCardBody({
        required this.bike,
        required this.kmPerL,
        required this.lifetimeKmPerL,
    });

    final Bike bike;
    final double? kmPerL;
    final double? lifetimeKmPerL;

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);
        final label = theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
        );

        return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text('LAST FULL TANK', style: label),
                    const SizedBox(height: 28),
                    Center(
                        child: _Gauge(
                            value: kmPerL ?? 0,
                            child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                        Text(
                                            kmPerL?.toStringAsFixed(1) ?? '—',
                                            style: theme.textTheme.displayLarge,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                            'km/L',
                                            style: theme.textTheme.labelMedium?.copyWith(
                                                color: theme.colorScheme.primary,
                                                fontSize: 18,
                                                letterSpacing: 0,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                    ),
                    const SizedBox(height: 10),
                    Center(child: Text('FUEL EFFICIENCY', style: label)),
                    if (kmPerL != null && lifetimeKmPerL != null) ...[
                        const SizedBox(height: 14),
                        Center(child: _DeltaPill(delta: kmPerL! - lifetimeKmPerL!)),
                    ],
                    if (kmPerL != null && bike.factoryKmPerL != null) ...[
                        const SizedBox(height: 16),
                        Center(
                            child: _ClaimsLine(
                                make: bike.make,
                                claimed: bike.factoryKmPerL!,
                                actual: kmPerL!,
                            ),
                        ),
                    ],
                    if (kmPerL != null && bike.tankCapacityL != null) ...[
                        const SizedBox(height: 16),
                        Center(child: _RangeLine(rangeKm: bike.tankCapacityL! * kmPerL!)),
                    ],
                ],
            ),
        );
    }
}

class _Gauge extends StatelessWidget {
    const _Gauge({required this.value, required this.child});

    final double value;
    final Widget child;

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);

        return SizedBox(
            width: 230,
            height: 230,
            child: CustomPaint(
                painter: _GaugePainter(
                    value: value,
                    min: 30, 
                    max: 60,
                    trackColor: theme.colorScheme.onSurface.withValues(alpha: 0.10),
                    valueColor: theme.colorScheme.primary,
                ),
                child: Center(child: child),
            ),
        );
    }
}

class _GaugePainter extends CustomPainter {
    const _GaugePainter({
        required this.value,
        required this.min,
        required this.max,
        required this.trackColor,
        required this.valueColor,
    });

    final double value;
    final double min;
    final double max;
    final Color trackColor;
    final Color valueColor;

    static const _start = 150 * pi / 180;
    static const _sweep = 240 * pi / 180;
    static const _stroke = 14.0;

    @override
    void paint(Canvas canvas, Size size) {
        final rect = Rect.fromLTWH(
            _stroke / 2,
            _stroke / 2,
            size.width - _stroke,
            size.height - _stroke,
        );

        final paint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = _stroke
            ..strokeCap = StrokeCap.round;

        canvas.drawArc(rect, _start, _sweep, false, paint..color = trackColor);

        final t = ((value - min) / (max - min)).clamp(0.0, 1.0);
        canvas.drawArc(rect, _start, _sweep * t, false, paint..color = valueColor);
    }

    @override
    bool shouldRepaint(_GaugePainter old) => old.value != value;
}

class _DeltaPill extends StatelessWidget {
    const _DeltaPill({required this.delta});

    final double delta;

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);
        final above = delta >= 0;
        final color = above ? theme.colorScheme.primary : theme.colorScheme.error;

        return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Icon(
                        above ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        size: 18,
                        color: color,
                    ),
                    Text(
                        '${delta.abs().toStringAsFixed(1)} '
                        '${above ? 'above' : 'below'} your average', 
                        style: theme.textTheme.labelMedium?.copyWith(
                            color: color,
                            letterSpacing: 0,
                        ),
                    ),
                ],
            ),
        );
    }
}

class _ClaimsLine extends StatelessWidget {
    const _ClaimsLine({
        required this.make,
        required this.claimed,
        required this.actual,
    });

    final String make;
    final double claimed;
    final double actual;

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);

        return Text.rich(
            TextSpan(
                style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 0,
                ),
                children: [
                    TextSpan(text: '$make claims '),
                    TextSpan(
                        text: claimed.toStringAsFixed(0),
                        style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                    const TextSpan(text: ' you get '),
                    TextSpan(
                        text: actual.toStringAsFixed(1),
                        style: TextStyle(color: theme.colorScheme.primary),
                    ),
                    const TextSpan(text: ' km/L'),
                ],
            ),
        );
    }
}

class _RangeLine extends StatelessWidget {
    const _RangeLine({required this.rangeKm});

    final double rangeKm;

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);

        return Text.rich(
            TextSpan(
                style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 0,
                ),
                children: [
                    const TextSpan(text: '≈ '),
                    TextSpan(
                        text: rangeKm.toStringAsFixed(0),
                        style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                    const TextSpan(text: ' km / full tank'),
                ],
            ),
        );
    }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.db, required this.bikeId});

  final AppDatabase db;
  final int bikeId;

  @override
  Widget build(BuildContext context) {
    final query = db.select(db.fuelEntries)
      ..where((t) => t.bikeId.equals(bikeId));

    return StreamBuilder<List<FuelEntry>>(
      stream: query.watch(),
      builder: (context, snapshot) {
        final entries = snapshot.data ?? const <FuelEntry>[];

        final lifetime = FuelStats.lifetimeKmPerL(entries);
        final cost = FuelStats.costPerKm(entries);
        final month = FuelStats.spendInMonth(entries, DateTime.now());

        final peso = NumberFormat.currency(
          locale: 'en_PH',
          symbol: '₱',
          decimalDigits: 0,
        );

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatTile(
                  label: 'LIFETIME',
                  value: lifetime?.toStringAsFixed(1) ?? '—',
                  highlight: true,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  label: 'THIS MONTH',
                  value: peso.format(month),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatTile(
                  label: 'COST / KM',
                  value: cost == null ? '—' : '₱${cost.toStringAsFixed(2)}',
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
    const _StatTile({
        required this.label,
        required this.value,
        this.highlight = false,
    });

    final String label;
    final String value;
    final bool highlight;

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);

        return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Text(
                        label,
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                        ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                        value,
                        style: theme.textTheme.labelMedium?.copyWith(
                            fontSize: 20,
                            letterSpacing: 0,
                            color: highlight
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                        ),
                    ),
                ],
            ),
        );
    }
}

class _MaintenanceStrip extends StatefulWidget {
  const _MaintenanceStrip({required this.db, required this.bike});

  final AppDatabase db;
  final Bike bike;

  @override
  State<_MaintenanceStrip> createState() => _MaintenanceStripState();
}

class _MaintenanceStripState extends State<_MaintenanceStrip> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final db = widget.db;
    final bike = widget.bike;

    final itemsQuery = db.select(db.maintenanceItems)
      ..where((t) => t.bikeId.equals(bike.id));
    final entriesQuery = db.select(db.fuelEntries)
      ..where((t) => t.bikeId.equals(bike.id));

    return StreamBuilder<List<MaintenanceItem>>(
      stream: itemsQuery.watch(),
      builder: (context, itemsSnap) {
        return StreamBuilder<List<FuelEntry>>(
          stream: entriesQuery.watch(),
          builder: (context, entriesSnap) {
            final items = itemsSnap.data ?? const <MaintenanceItem>[];
            final entries = entriesSnap.data ?? const <FuelEntry>[];
            final currentOdo = FuelStats.currentOdometer(entries);
            final now = DateTime.now();

            final sorted = Maintenance.byUrgency(items, currentOdo, now);
            final shown = sorted.take(4).toList();
            final page = shown.isEmpty ? 0 : _page.clamp(0, shown.length - 1);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(
                  title: 'Maintenance',
                  action: sorted.length > shown.length
                      ? 'All ${sorted.length} →'
                      : 'All →',
                  onTap: () =>
                      showMaintenanceSheet(context, db, bike, currentOdo),
                ),
                const SizedBox(height: 10),
                if (shown.isEmpty)
                  _AddFirstItemCard(
                    onTap: () =>
                        showMaintenanceSheet(context, db, bike, currentOdo),
                  )
                else ...[
                  SizedBox(
                    height: 104,
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: shown.length,
                      onPageChanged: (i) => setState(() => _page = i),
                      itemBuilder: (context, i) => _MaintenanceChip(
                        item: shown[i],
                        currentOdo: currentOdo,
                        now: now,
                        dueDate: Maintenance.estimatedDueDate(
                          shown[i],
                          entries,
                          now,
                        ),
                        onTap: () => showLogMaintenanceSheet(
                          context,
                          db,
                          shown[i],
                          currentOdo,
                        ),
                      ),
                    ),
                  ),
                  if (shown.length > 1) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < shown.length; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: i == page ? 18 : 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: i == page
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _MaintenanceChip extends StatelessWidget {
  const _MaintenanceChip({
    required this.item,
    required this.currentOdo,
    required this.now,
    required this.dueDate,
    required this.onTap,
  });

  final MaintenanceItem item;
  final int? currentOdo;
  final DateTime now;
  final DateTime? dueDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = NumberFormat.decimalPattern();

    final km = Maintenance.kmRemaining(item, currentOdo);
    final days = Maintenance.daysRemaining(item, now);
    final progress = Maintenance.progress(item, currentOdo, now);

    final String value;
    if (km != null) {
      value = km < 0 ? '${fmt.format(-km)} km over' : '${fmt.format(km)} km';
    } else if (days != null) {
      value = days < 0 ? '${-days} d over' : '$days d';
    } else {
      value = 'Not logged';
    }

    final Color accent;
    if (progress == null) {
      accent = theme.colorScheme.onSurfaceVariant;
    } else if (progress >= 0.9) {
      accent = theme.colorScheme.error;
    } else {
      accent = theme.colorScheme.primary;
    }

    final String interval;
    if (item.intervalKm != null && item.intervalMonths != null) {
      interval = '${fmt.format(item.intervalKm!)} km / ${item.intervalMonths}mo';
    } else if (item.intervalKm != null) {
      interval = 'every ${fmt.format(item.intervalKm!)} km';
    } else if (item.intervalMonths != null) {
      interval = 'every ${item.intervalMonths} months';
    } else {
      interval = 'no interval';
    }
    final estimate = dueDate == null
        ? ''
        : ' · ≈ ${DateFormat('d MMM').format(dueDate!)}';

      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Material(
          color: theme.colorScheme.surfaceContainer,
          child: InkWell(
            onTap: onTap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 3, color: accent),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            value,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontSize: 16,
                              letterSpacing: 0,
                              color: accent,
                            ),
                          ),
                        ),
                        Text(
                          '$interval$estimate',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    // );
  }
}

class _AddFirstItemCard extends StatelessWidget {
  const _AddFirstItemCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.add, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Track oil, chain, brakes...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
    const _SectionHeader({required this.title, required this.action, required this.onTap});

    final String title;
    final String action;
    final VoidCallback onTap;

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);

        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
                Text(title, style: theme.textTheme.titleMedium),
                InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Text(
                      action,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
            ],
        );
    }
}

class _BottomNav extends StatelessWidget {
    const _BottomNav({
      required this.db,
      required this.bike,
      required this.addKey,
      required this.statsKey,
      required this.currentIndex,
      required this.onSelect,
    });

    final AppDatabase db;
    final Bike bike;
    final GlobalKey addKey;
    final GlobalKey statsKey;
    final int currentIndex;
    final ValueChanged<int> onSelect;

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);

        return DecoratedBox(
            decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                border: Border(
                    top: BorderSide(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                    ),
                ),
            ),
            child: SafeArea(
                top: false,
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                            _NavItem(
                              icon: Icons.home_outlined,
                              label: 'DASH',
                              active: currentIndex == 0,
                              onTap: () => onSelect(0),
                            ),
                            KeyedSubtree(
                              key: statsKey,
                              child: _NavItem(
                                icon: Icons.bar_chart,
                                label: 'STATS',
                                active: currentIndex == 1,
                                onTap: () => onSelect(1),
                              ),
                            ),
                            _AddButton(key: addKey, db: db, bike: bike),
                            _NavItem(
                              icon: Icons.location_on_outlined,
                              label: 'FUEL',
                              active: currentIndex == 2,
                              onTap: () => onSelect(2),
                            ),
                        ],
                    ),
                ),
            ),
        );
    }
}

class _NavItem extends StatelessWidget {
    const _NavItem({
        required this.icon,
        required this.label,
        required this.onTap,
        this.active = false,
    });

    final IconData icon;
    final String label;
    final VoidCallback onTap;
    final bool active;

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);
        final color = active
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurfaceVariant;

        return InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Icon(icon, size: 22, color: color),
                        const SizedBox(height: 5),
                        Text(
                            label,
                            style: theme.textTheme.labelSmall?.copyWith(color: color),
                        ),
                    ],
                ),
            ),
        );
    }
}

class _AddButton extends StatelessWidget {
    const _AddButton({super.key, required this.db, required this.bike});

    final AppDatabase db;
    final Bike bike;

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);

        return GestureDetector(
            onTap: () => showAddEntrySheet(context, db, bike),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.add, size: 22, color: theme.colorScheme.onPrimary),
                    ),
                    const SizedBox(height: 5),
                    Text(
                        'ADD',
                        style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                        ),
                    ),
                ],
            ),
        );
    }
}

class _RecentFills extends StatelessWidget {
  const _RecentFills({required this.db, required this.bike});

  final AppDatabase db;
  final Bike bike;

  Stream<List<({FuelEntry entry, Station? station})>> _watch() {
    final query = db.select(db.fuelEntries).join([
      leftOuterJoin(
        db.stations,
        db.stations.id.equalsExp(db.fuelEntries.stationId),
      ),
    ])
      ..where(db.fuelEntries.bikeId.equals(bike.id))
      ..orderBy([OrderingTerm.desc(db.fuelEntries.odometer)]);

    return query.watch().map(
          (rows) => rows
              .map(
                (r) => (
                  entry: r.readTable(db.fuelEntries),
                  station: r.readTableOrNull(db.stations),
                ),
              )
              .toList(),
        );
  }

  Future<void> _delete(BuildContext context, int id) async {
    await (db.delete(db.fuelEntries)..where((t) => t.id.equals(id))).go();
    if (context.mounted) {
      showAppAlert(context, 'Fill-up Deleted');
    }
  }

  Future<bool?> _confirmDelete(BuildContext context, FuelEntry e) {
    final theme = Theme.of(context);
    final date = DateFormat('MMM d').format(e.date);
    final odo = NumberFormat.decimalPattern().format(e.odometer);

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: theme.colorScheme.surfaceContainer,
        title: const Text('Delete this fill-up?'),
        content: Text(
          '$date · $odo km\n\nYour efficiency numbers will recalculate.',
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<List<({FuelEntry entry, Station? station})>>(
      stream: _watch(),
      builder: (context, snapshot) {
        final rows = snapshot.data;
        if (rows == null) return const SizedBox(height: 70);

        if (rows.isEmpty) {
          return Text(
            'No fill-ups yet.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        }

        final entries = rows.map((r) => r.entry).toList();

        return Column(
          children: [
            for (final r in rows.take(3)) ...[
              Dismissible(
                key: ValueKey(r.entry.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (_) => _confirmDelete(context, r.entry),
                onDismissed: (_) => _delete(context, r.entry.id),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.delete, color: theme.colorScheme.onError),
                ),
                child: InkWell(
                  onTap: () => showAddEntrySheet(
                    context,
                    db,
                    bike,
                    entry: r.entry,
                    stationName: r.station?.name,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  child: FillRow(
                    entry: r.entry,
                    station: r.station,
                    kmPerL: FuelStats.efficiencyForFullTank(entries, r.entry),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
        );
      },
    );
  }
}
