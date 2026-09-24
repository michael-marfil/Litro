import '../data/database.dart';

/// One month's outgoings. Fuel and servicing stay separate because they
/// behave differently - fuel is steady, servicing is lumpy and occasional.
typedef MonthSpend = ({DateTime month, double fuel, double service});

/// What the bike costs to run, over time.
abstract final class Spending {
  /// Everything ever spend on fuel.
  static double fuelSpend(List<FuelEntry> entries) =>
      entries.fold<double>(0, (sum, e) => sum + e.amountPaid);

  /// The last [months] calendar months, oldest first, ending with the month
  /// containing [now].
  /// 
  /// Months with no spending come back as zeros rather than being skipped -
  /// an empty bar is information, and dropping it would squash the time axis.
  static List<MonthSpend> byMonth(
    List<FuelEntry> entries,
    List<ServiceLog> logs,
    DateTime now, {
      int months = 6,
  }) {
    final result = <MonthSpend>[];

    for (var i = months - 1; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i);

      final fuel = entries
          .where((e) => e.date.year == m.year && e.date.month == m.month)
          .fold<double>(0, (sum, e) => sum + e.amountPaid);

      final service = logs
          .where((l) => l.date.year == m.year && l.date.month == m.month)
          .fold<double>(0, (sum, l) => sum + (l.cost ?? 0));

      result.add((month: m, fuel: fuel, service: service));
    }

    return result;
  }
}