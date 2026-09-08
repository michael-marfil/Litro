import '../data/database.dart';
import 'fuel_stats.dart';

/// Due-date maths for a bike's service schedule.
///
/// An item can be tracked by distance, by time, or both. When both, whichever
/// comes first wins.
abstract final class Maintenance {
  /// Kilometres until due. Negative means overdue.
  /// Null when there's no km interval, no last reading, or no odometer yet.
  static int? kmRemaining(MaintenanceItem item, int? currentOdo) {
    final interval = item.intervalKm;
    final last = item.lastOdo;
    if (interval == null || last == null || currentOdo == null) return null;
    return (last + interval) - currentOdo;
  }

  /// Days until due. Negative means overdue.
  static int? daysRemaining(MaintenanceItem item, DateTime now) {
    final months = item.intervalMonths;
    final last = item.lastDate;
    if (months == null || last == null) return null;

    final due = DateTime(last.year, last.month + months, last.day);
    final today = DateTime(now.year, now.month, now.day);
    return due.difference(today).inDays;
  }

  /// How far through the interval we are: 0 = just done, 1 = due now,
  /// above 1 = overdue. Null when the item can't be tracked at all.
  /// 
  /// With both intervals set, returns whichever is further along - that's
  /// "whichever comes first", expressed as a single comparable number.
  static double? progress(
    MaintenanceItem item,
    int? currentOdo,
    DateTime now,
  ) {
    double? byKm;
    final intervalKm = item.intervalKm;
    final lastOdo = item.lastOdo;
    if (intervalKm != null && intervalKm > 0 && lastOdo != null && currentOdo != null) {
      byKm = (currentOdo - lastOdo) / intervalKm;
    }

    double? byTime;
    final intervalMonths = item.intervalMonths;
    final lastDate = item.lastDate;
    if (intervalMonths != null && intervalMonths > 0 && lastDate != null) {
      final elapsedDays = now.difference(lastDate).inDays;
      byTime = elapsedDays / (intervalMonths * 30.44);
    }

    if (byKm == null) return byTime;
    if (byTime == null) return byKm;
    return byKm > byTime ? byKm : byTime;
  }

  /// Average distance covered per day, from the spread of logged fill-ups.
  /// Null until there are two entries far enough apart to mean anything.
  static double? averageKmPerDay(List<FuelEntry> entries) {
    if (entries.length < 3) return null;

    final odometers = entries.map((e) => e.odometer).toList()..sort();
    final dates = entries.map((e) => e.date).toList()..sort();

    final km = odometers.last - odometers.first;
    final days = dates.last.difference(dates.first).inDays;

    // Too short a wisndow to extrapolate weeks ahead from.
    if (km <= 0 || days < 14) return null;

    return km / days;
  }

  /// When this item is expected to fall due.
  ///
  /// Distance-based items are projected using [averageKmPerDay]; time-based
  /// ones are known outright. With both, the earlier date wins — "whichever
  /// comes first". Null when there isn't enough histroy to say.
  static DateTime? estimatedDueDate(
    MaintenanceItem item,
    List<FuelEntry> entries,
    DateTime now,
  ) {
    DateTime? byTime;
    final months = item.intervalMonths;
    final lastDate = item.lastDate;
    if (months != null && lastDate != null) {
      byTime = DateTime(lastDate.year, lastDate.month + months, lastDate.day);
    }

    DateTime? byDistance;
    final intervalKm = item.intervalKm;
    final lastOdo = item.lastOdo;
    final currentOdo = FuelStats.currentOdometer(entries);
    final perDay = averageKmPerDay(entries);

    if (intervalKm != null && lastOdo != null && currentOdo != null && perDay != null) {
      final remaining = (lastOdo + intervalKm) - currentOdo;
      final days = (remaining / perDay).ceil();
      byDistance = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(Duration(days: days));
    }

    if (byTime == null) return byDistance;
    if (byDistance == null) return byTime;
    return byTime.isBefore(byDistance) ? byTime : byDistance;
  }

  /// Most urgent first. Untrackable items sink to the bottom.
  static List<MaintenanceItem> byUrgency(
    List<MaintenanceItem> items,
    int? currentOdo,
    DateTime now,
  ) {
    final sorted = [...items];
    sorted.sort((a, b) {
      final pa = progress(a, currentOdo, now) ?? -1;
      final pb = progress(b, currentOdo, now) ?? -1;
      return pb.compareTo(pa);
    });
    return sorted;
  }
}