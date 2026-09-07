import '../data/database.dart';

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