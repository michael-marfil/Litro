import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

/// A motorcycle. Every full-up belongs to exactly one.
class Bikes extends Table {
    IntColumn get id => integer().autoIncrement()();
    TextColumn get nickname => text().withLength(min: 1, max: 40)();
    TextColumn get make => text()();
    TextColumn get model => text()();
    IntColumn get year => integer().nullable()();
    RealColumn get tankCapacityL => real().nullable()();
    RealColumn get factoryKmPerL => real().nullable()();
    IntColumn get oilIntervalKm => integer()();
    BoolColumn get isActive => boolean().withDefault(const Constant(false))();
    IntColumn get lastOilChangeOdo => integer().nullable()();
    DateTimeColumn get lastOilChangeDate => dateTime().nullable()();
}

/// A gas station. Shared across bikes - a price is a price.
class Stations extends Table {
    IntColumn get id => integer().autoIncrement()();
    TextColumn get name => text().unique()();
}

/// One fill-up. The core record.
@DataClassName('FuelEntry')
class FuelEntries extends Table {
    IntColumn get id => integer().autoIncrement()();
    IntColumn get bikeId =>
      integer().references(Bikes, #id, onDelete: KeyAction.cascade)();
    DateTimeColumn get date => dateTime()();
    IntColumn get odometer => integer()();
    RealColumn get liters => real()();
    RealColumn get pricePerLiter => real()();
    RealColumn get amountPaid => real()();
    BoolColumn get isFullTank => boolean()();
    IntColumn get stationId => integer()
        .nullable()
        .references(Stations, #id, onDelete: KeyAction.setNull)();
    TextColumn get note => text().nullable()();
}

/// A recurring service on a bike - oil, chain, brake pads, valve clearance.
class MaintenanceItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get bikeId => integer().references(Bikes, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text().withLength(min: 1, max: 40)();
  IntColumn get intervalKm => integer().nullable()();
  IntColumn get intervalMonths => integer().nullable()();
  IntColumn get lastOdo => integer().nullable()();
  DateTimeColumn get lastDate => dateTime().nullable()();
}

@DriftDatabase(tables: [Bikes, Stations, FuelEntries, MaintenanceItems])
class AppDatabase extends _$AppDatabase {
    AppDatabase() : super(driftDatabase(name: 'litro'));
    AppDatabase.forTesting(super.executor);

    @override
    int get schemaVersion => 3;

    @override
    MigrationStrategy get migration => MigrationStrategy(
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(bikes, bikes.lastOilChangeOdo);
          await m.addColumn(bikes, bikes.lastOilChangeDate);
        }
        if (from < 3) {
          await m.createTable(maintenanceItems);

          // Every existing bike keeps its oil tracking.
          for (final b in await select(bikes).get()) {
            await into(maintenanceItems).insert(
              MaintenanceItemsCompanion.insert(
                bikeId: b.id,
                name: 'Oil change',
                intervalKm: Value(b.oilIntervalKm),
                lastOdo: Value(b.lastOilChangeOdo),
                lastDate: Value(b.lastOilChangeDate),
              ),
            );
          }
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
}