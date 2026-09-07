import '../data/database.dart';

/// Pure calculations over one bike's fill-ups.
///
/// Returns `null` when a value can't be computed yet — never 0, which would
/// read as a real result.
abstract final class FuelStats {
  /// Distance covered between the first and last recorded fill-up.
  static int distanceKm(List<FuelEntry> entries) {
    if (entries.length < 2) return 0;
    final odos = entries.map((e) => e.odometer).toList()..sort();
    return odos.last - odos.first;
  }

  /// Litres burned over [distanceKm].
  ///
  /// Excludes the earliest fill: that fuel was already in the tank when the
  /// measured distance began.
  static double litersBurned(List<FuelEntry> entries) {
    if (entries.length < 2) return 0;
    final sorted = [...entries]
      ..sort((a, b) => a.odometer.compareTo(b.odometer));
    return sorted.skip(1).fold<double>(0, (sum, e) => sum + e.liters);
  }

  /// Always-available headline number. Spec §3.
  static double? lifetimeKmPerL(List<FuelEntry> entries) {
    final distance = distanceKm(entries);
    final liters = litersBurned(entries);
    if (distance <= 0 || liters <= 0) return null;
    return distance / liters;
  }

  /// Total spend divided by distance. Spec §3.
  static double? costPerKm(List<FuelEntry> entries) {
    final distance = distanceKm(entries);
    if (distance <= 0) return null;
    final spent = entries.fold<double>(0, (sum, e) => sum + e.amountPaid);
    return spent / distance;
  }

  /// Spend within the calendar month containing [month].
  static double spendInMonth(List<FuelEntry> entries, DateTime month) {
    return entries
        .where((e) => e.date.year == month.year && e.date.month == month.month)
        .fold<double>(0, (sum, e) => sum + e.amountPaid);
  }

  /// Highest odometer reading logged.
  static int? currentOdometer(List<FuelEntry> entries) {
    if (entries.isEmpty) return null;
    return entries.map((e) => e.odometer).reduce((a, b) => a > b ? a : b);
  }

  /// km/L for the tank that *ends* at [target].
  ///
  /// Only measurable between two full tanks: if both ends are full, whatever
  /// was in the tank cancels out, and the fuel burned is everything added
  /// after the previous full tank up to and including [target].
  ///
  /// Returns null when there's no earlier full tank to measure from.
  static double? efficiencyForFullTank(
    List<FuelEntry> all,
    FuelEntry target,
  ) {
    if (!target.isFullTank) return null;

    final sorted = [...all]
      ..sort((a, b) => a.odometer.compareTo(b.odometer));

    final end = sorted.indexWhere((e) => e.id == target.id);
    if (end <= 0) return null;

    final start = sorted.lastIndexWhere((e) => e.isFullTank, end - 1);
    if (start < 0) return null;

    final distance = sorted[end].odometer - sorted[start].odometer;
    if (distance <= 0) return null;

    final liters = sorted
      .sublist(start + 1, end + 1)
      .fold<double>(0, (sum, e) => sum + e.liters);
    if (liters <= 0) return null;

    return distance / liters;
  }

  /// The most recent measurable full-tank efficiency - the dashboard hero.
  static double? latestFullTankKmPerL(List<FuelEntry> entries) {
    final sorted = [...entries]
      ..sort((a, b) => a.odometer.compareTo(b.odometer));
  
    for (final e in sorted.reversed) {
      final value = efficiencyForFullTank(sorted, e);
      if (value != null) return value;
    }
    return null;
  }

  /// Kilometres until the next oil change. Negative means overdue.
  /// 
  /// Null when the user has never logged an oil change, or there are no
  /// fill-ups yet to read a current odometer from.
  static int? oilKmRemaining(Bike bike, List<FuelEntry> entries) {
    final last = bike.lastOilChangeOdo;
    if (last == null) return null;

    final current = currentOdometer(entries);
    if (current == null) return null;

    return (last + bike.oilIntervalKm) - current;
  }
}
