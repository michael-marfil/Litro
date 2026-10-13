import 'package:flutter_test/flutter_test.dart';
import 'package:litro/domain/chart_range.dart';

void main() {
  final now = DateTime(2026, 2, 10);

  test('all of history has no cutoff', () {
    expect(ChartRange.all.cutoff(now), isNull);
  });

  test('six months back from February lands in the previous year', () {
    expect(ChartRange.sixMonths.cutoff(now), DateTime(2025, 8, 10));
  });

  test('a year back is the same day last year', () {
    expect(ChartRange.year.cutoff(now), DateTime(2025, 2, 10));
  });
}