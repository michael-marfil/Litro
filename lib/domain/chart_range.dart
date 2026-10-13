/// How far back the stats charts look.
enum ChartRange {
  threeMonths('3M', 3),
  sixMonths('6M', 6),
  year('1Y', 12),
  all('All', null);

  const ChartRange(this.label, this.months);

  final String label;

  /// Null means no limit.
  final int? months;

  /// The earliest date inside this range, or null for all of history.
  DateTime? cutoff(DateTime now) {
    final m = months;
    if (m == null) return null;
    return DateTime(now.year, now.month - m, now.day);
  }
}