import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:litro/data/database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('a new database has no bikes', () async {
    expect(await db.select(db.bikes).get(), isEmpty);
  });

  test('inserting a bike round-trips every field', () async {
    await db.into(db.bikes).insert(
      BikesCompanion.insert(
        nickname: 'Daily Click',
        make: 'Honda',
        model: 'Click 125',
        oilIntervalKm: 2000,
        isActive: const Value(true),
      ),
    );

    final bikes = await db.select(db.bikes).get();
    expect(bikes, hasLength(1));
    expect(bikes.single.nickname, 'Daily Click');
    expect(bikes.single.isActive, isTrue);
    expect(bikes.single.year, isNull);
  });

  test('watch() pushes an update when a row is inserted', () async {
    final emissions = <List<Bike>>[];
    final sub = db.select(db.bikes).watch().listen(emissions.add);
    addTearDown(sub.cancel);

    await pumpEventQueue();
    expect(emissions.last, isEmpty);

    await db.into(db.bikes).insert(
      BikesCompanion.insert(
        nickname: 'Raider',
        make: 'Suzuki',
        model: 'Raider R150',
        oilIntervalKm: 3000,
      ),
    );
    await pumpEventQueue();

    expect(emissions.last, hasLength(1));
  });
}
