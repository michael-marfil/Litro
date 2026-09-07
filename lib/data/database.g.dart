// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BikesTable extends Bikes with TableInfo<$BikesTable, Bike> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BikesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _makeMeta = const VerificationMeta('make');
  @override
  late final GeneratedColumn<String> make = GeneratedColumn<String>(
    'make',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tankCapacityLMeta = const VerificationMeta(
    'tankCapacityL',
  );
  @override
  late final GeneratedColumn<double> tankCapacityL = GeneratedColumn<double>(
    'tank_capacity_l',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _factoryKmPerLMeta = const VerificationMeta(
    'factoryKmPerL',
  );
  @override
  late final GeneratedColumn<double> factoryKmPerL = GeneratedColumn<double>(
    'factory_km_per_l',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _oilIntervalKmMeta = const VerificationMeta(
    'oilIntervalKm',
  );
  @override
  late final GeneratedColumn<int> oilIntervalKm = GeneratedColumn<int>(
    'oil_interval_km',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastOilChangeOdoMeta = const VerificationMeta(
    'lastOilChangeOdo',
  );
  @override
  late final GeneratedColumn<int> lastOilChangeOdo = GeneratedColumn<int>(
    'last_oil_change_odo',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastOilChangeDateMeta = const VerificationMeta(
    'lastOilChangeDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastOilChangeDate =
      GeneratedColumn<DateTime>(
        'last_oil_change_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nickname,
    make,
    model,
    year,
    tankCapacityL,
    factoryKmPerL,
    oilIntervalKm,
    isActive,
    lastOilChangeOdo,
    lastOilChangeDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bikes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bike> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    } else if (isInserting) {
      context.missing(_nicknameMeta);
    }
    if (data.containsKey('make')) {
      context.handle(
        _makeMeta,
        make.isAcceptableOrUnknown(data['make']!, _makeMeta),
      );
    } else if (isInserting) {
      context.missing(_makeMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('tank_capacity_l')) {
      context.handle(
        _tankCapacityLMeta,
        tankCapacityL.isAcceptableOrUnknown(
          data['tank_capacity_l']!,
          _tankCapacityLMeta,
        ),
      );
    }
    if (data.containsKey('factory_km_per_l')) {
      context.handle(
        _factoryKmPerLMeta,
        factoryKmPerL.isAcceptableOrUnknown(
          data['factory_km_per_l']!,
          _factoryKmPerLMeta,
        ),
      );
    }
    if (data.containsKey('oil_interval_km')) {
      context.handle(
        _oilIntervalKmMeta,
        oilIntervalKm.isAcceptableOrUnknown(
          data['oil_interval_km']!,
          _oilIntervalKmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_oilIntervalKmMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('last_oil_change_odo')) {
      context.handle(
        _lastOilChangeOdoMeta,
        lastOilChangeOdo.isAcceptableOrUnknown(
          data['last_oil_change_odo']!,
          _lastOilChangeOdoMeta,
        ),
      );
    }
    if (data.containsKey('last_oil_change_date')) {
      context.handle(
        _lastOilChangeDateMeta,
        lastOilChangeDate.isAcceptableOrUnknown(
          data['last_oil_change_date']!,
          _lastOilChangeDateMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bike map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bike(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      )!,
      make: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}make'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      tankCapacityL: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tank_capacity_l'],
      ),
      factoryKmPerL: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}factory_km_per_l'],
      ),
      oilIntervalKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}oil_interval_km'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      lastOilChangeOdo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_oil_change_odo'],
      ),
      lastOilChangeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_oil_change_date'],
      ),
    );
  }

  @override
  $BikesTable createAlias(String alias) {
    return $BikesTable(attachedDatabase, alias);
  }
}

class Bike extends DataClass implements Insertable<Bike> {
  final int id;
  final String nickname;
  final String make;
  final String model;
  final int? year;
  final double? tankCapacityL;
  final double? factoryKmPerL;
  final int oilIntervalKm;
  final bool isActive;
  final int? lastOilChangeOdo;
  final DateTime? lastOilChangeDate;
  const Bike({
    required this.id,
    required this.nickname,
    required this.make,
    required this.model,
    this.year,
    this.tankCapacityL,
    this.factoryKmPerL,
    required this.oilIntervalKm,
    required this.isActive,
    this.lastOilChangeOdo,
    this.lastOilChangeDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nickname'] = Variable<String>(nickname);
    map['make'] = Variable<String>(make);
    map['model'] = Variable<String>(model);
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || tankCapacityL != null) {
      map['tank_capacity_l'] = Variable<double>(tankCapacityL);
    }
    if (!nullToAbsent || factoryKmPerL != null) {
      map['factory_km_per_l'] = Variable<double>(factoryKmPerL);
    }
    map['oil_interval_km'] = Variable<int>(oilIntervalKm);
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || lastOilChangeOdo != null) {
      map['last_oil_change_odo'] = Variable<int>(lastOilChangeOdo);
    }
    if (!nullToAbsent || lastOilChangeDate != null) {
      map['last_oil_change_date'] = Variable<DateTime>(lastOilChangeDate);
    }
    return map;
  }

  BikesCompanion toCompanion(bool nullToAbsent) {
    return BikesCompanion(
      id: Value(id),
      nickname: Value(nickname),
      make: Value(make),
      model: Value(model),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      tankCapacityL: tankCapacityL == null && nullToAbsent
          ? const Value.absent()
          : Value(tankCapacityL),
      factoryKmPerL: factoryKmPerL == null && nullToAbsent
          ? const Value.absent()
          : Value(factoryKmPerL),
      oilIntervalKm: Value(oilIntervalKm),
      isActive: Value(isActive),
      lastOilChangeOdo: lastOilChangeOdo == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOilChangeOdo),
      lastOilChangeDate: lastOilChangeDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOilChangeDate),
    );
  }

  factory Bike.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bike(
      id: serializer.fromJson<int>(json['id']),
      nickname: serializer.fromJson<String>(json['nickname']),
      make: serializer.fromJson<String>(json['make']),
      model: serializer.fromJson<String>(json['model']),
      year: serializer.fromJson<int?>(json['year']),
      tankCapacityL: serializer.fromJson<double?>(json['tankCapacityL']),
      factoryKmPerL: serializer.fromJson<double?>(json['factoryKmPerL']),
      oilIntervalKm: serializer.fromJson<int>(json['oilIntervalKm']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lastOilChangeOdo: serializer.fromJson<int?>(json['lastOilChangeOdo']),
      lastOilChangeDate: serializer.fromJson<DateTime?>(
        json['lastOilChangeDate'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nickname': serializer.toJson<String>(nickname),
      'make': serializer.toJson<String>(make),
      'model': serializer.toJson<String>(model),
      'year': serializer.toJson<int?>(year),
      'tankCapacityL': serializer.toJson<double?>(tankCapacityL),
      'factoryKmPerL': serializer.toJson<double?>(factoryKmPerL),
      'oilIntervalKm': serializer.toJson<int>(oilIntervalKm),
      'isActive': serializer.toJson<bool>(isActive),
      'lastOilChangeOdo': serializer.toJson<int?>(lastOilChangeOdo),
      'lastOilChangeDate': serializer.toJson<DateTime?>(lastOilChangeDate),
    };
  }

  Bike copyWith({
    int? id,
    String? nickname,
    String? make,
    String? model,
    Value<int?> year = const Value.absent(),
    Value<double?> tankCapacityL = const Value.absent(),
    Value<double?> factoryKmPerL = const Value.absent(),
    int? oilIntervalKm,
    bool? isActive,
    Value<int?> lastOilChangeOdo = const Value.absent(),
    Value<DateTime?> lastOilChangeDate = const Value.absent(),
  }) => Bike(
    id: id ?? this.id,
    nickname: nickname ?? this.nickname,
    make: make ?? this.make,
    model: model ?? this.model,
    year: year.present ? year.value : this.year,
    tankCapacityL: tankCapacityL.present
        ? tankCapacityL.value
        : this.tankCapacityL,
    factoryKmPerL: factoryKmPerL.present
        ? factoryKmPerL.value
        : this.factoryKmPerL,
    oilIntervalKm: oilIntervalKm ?? this.oilIntervalKm,
    isActive: isActive ?? this.isActive,
    lastOilChangeOdo: lastOilChangeOdo.present
        ? lastOilChangeOdo.value
        : this.lastOilChangeOdo,
    lastOilChangeDate: lastOilChangeDate.present
        ? lastOilChangeDate.value
        : this.lastOilChangeDate,
  );
  Bike copyWithCompanion(BikesCompanion data) {
    return Bike(
      id: data.id.present ? data.id.value : this.id,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      make: data.make.present ? data.make.value : this.make,
      model: data.model.present ? data.model.value : this.model,
      year: data.year.present ? data.year.value : this.year,
      tankCapacityL: data.tankCapacityL.present
          ? data.tankCapacityL.value
          : this.tankCapacityL,
      factoryKmPerL: data.factoryKmPerL.present
          ? data.factoryKmPerL.value
          : this.factoryKmPerL,
      oilIntervalKm: data.oilIntervalKm.present
          ? data.oilIntervalKm.value
          : this.oilIntervalKm,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastOilChangeOdo: data.lastOilChangeOdo.present
          ? data.lastOilChangeOdo.value
          : this.lastOilChangeOdo,
      lastOilChangeDate: data.lastOilChangeDate.present
          ? data.lastOilChangeDate.value
          : this.lastOilChangeDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bike(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('tankCapacityL: $tankCapacityL, ')
          ..write('factoryKmPerL: $factoryKmPerL, ')
          ..write('oilIntervalKm: $oilIntervalKm, ')
          ..write('isActive: $isActive, ')
          ..write('lastOilChangeOdo: $lastOilChangeOdo, ')
          ..write('lastOilChangeDate: $lastOilChangeDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nickname,
    make,
    model,
    year,
    tankCapacityL,
    factoryKmPerL,
    oilIntervalKm,
    isActive,
    lastOilChangeOdo,
    lastOilChangeDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bike &&
          other.id == this.id &&
          other.nickname == this.nickname &&
          other.make == this.make &&
          other.model == this.model &&
          other.year == this.year &&
          other.tankCapacityL == this.tankCapacityL &&
          other.factoryKmPerL == this.factoryKmPerL &&
          other.oilIntervalKm == this.oilIntervalKm &&
          other.isActive == this.isActive &&
          other.lastOilChangeOdo == this.lastOilChangeOdo &&
          other.lastOilChangeDate == this.lastOilChangeDate);
}

class BikesCompanion extends UpdateCompanion<Bike> {
  final Value<int> id;
  final Value<String> nickname;
  final Value<String> make;
  final Value<String> model;
  final Value<int?> year;
  final Value<double?> tankCapacityL;
  final Value<double?> factoryKmPerL;
  final Value<int> oilIntervalKm;
  final Value<bool> isActive;
  final Value<int?> lastOilChangeOdo;
  final Value<DateTime?> lastOilChangeDate;
  const BikesCompanion({
    this.id = const Value.absent(),
    this.nickname = const Value.absent(),
    this.make = const Value.absent(),
    this.model = const Value.absent(),
    this.year = const Value.absent(),
    this.tankCapacityL = const Value.absent(),
    this.factoryKmPerL = const Value.absent(),
    this.oilIntervalKm = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastOilChangeOdo = const Value.absent(),
    this.lastOilChangeDate = const Value.absent(),
  });
  BikesCompanion.insert({
    this.id = const Value.absent(),
    required String nickname,
    required String make,
    required String model,
    this.year = const Value.absent(),
    this.tankCapacityL = const Value.absent(),
    this.factoryKmPerL = const Value.absent(),
    required int oilIntervalKm,
    this.isActive = const Value.absent(),
    this.lastOilChangeOdo = const Value.absent(),
    this.lastOilChangeDate = const Value.absent(),
  }) : nickname = Value(nickname),
       make = Value(make),
       model = Value(model),
       oilIntervalKm = Value(oilIntervalKm);
  static Insertable<Bike> custom({
    Expression<int>? id,
    Expression<String>? nickname,
    Expression<String>? make,
    Expression<String>? model,
    Expression<int>? year,
    Expression<double>? tankCapacityL,
    Expression<double>? factoryKmPerL,
    Expression<int>? oilIntervalKm,
    Expression<bool>? isActive,
    Expression<int>? lastOilChangeOdo,
    Expression<DateTime>? lastOilChangeDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nickname != null) 'nickname': nickname,
      if (make != null) 'make': make,
      if (model != null) 'model': model,
      if (year != null) 'year': year,
      if (tankCapacityL != null) 'tank_capacity_l': tankCapacityL,
      if (factoryKmPerL != null) 'factory_km_per_l': factoryKmPerL,
      if (oilIntervalKm != null) 'oil_interval_km': oilIntervalKm,
      if (isActive != null) 'is_active': isActive,
      if (lastOilChangeOdo != null) 'last_oil_change_odo': lastOilChangeOdo,
      if (lastOilChangeDate != null) 'last_oil_change_date': lastOilChangeDate,
    });
  }

  BikesCompanion copyWith({
    Value<int>? id,
    Value<String>? nickname,
    Value<String>? make,
    Value<String>? model,
    Value<int?>? year,
    Value<double?>? tankCapacityL,
    Value<double?>? factoryKmPerL,
    Value<int>? oilIntervalKm,
    Value<bool>? isActive,
    Value<int?>? lastOilChangeOdo,
    Value<DateTime?>? lastOilChangeDate,
  }) {
    return BikesCompanion(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      tankCapacityL: tankCapacityL ?? this.tankCapacityL,
      factoryKmPerL: factoryKmPerL ?? this.factoryKmPerL,
      oilIntervalKm: oilIntervalKm ?? this.oilIntervalKm,
      isActive: isActive ?? this.isActive,
      lastOilChangeOdo: lastOilChangeOdo ?? this.lastOilChangeOdo,
      lastOilChangeDate: lastOilChangeDate ?? this.lastOilChangeDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (make.present) {
      map['make'] = Variable<String>(make.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (tankCapacityL.present) {
      map['tank_capacity_l'] = Variable<double>(tankCapacityL.value);
    }
    if (factoryKmPerL.present) {
      map['factory_km_per_l'] = Variable<double>(factoryKmPerL.value);
    }
    if (oilIntervalKm.present) {
      map['oil_interval_km'] = Variable<int>(oilIntervalKm.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (lastOilChangeOdo.present) {
      map['last_oil_change_odo'] = Variable<int>(lastOilChangeOdo.value);
    }
    if (lastOilChangeDate.present) {
      map['last_oil_change_date'] = Variable<DateTime>(lastOilChangeDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BikesCompanion(')
          ..write('id: $id, ')
          ..write('nickname: $nickname, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('year: $year, ')
          ..write('tankCapacityL: $tankCapacityL, ')
          ..write('factoryKmPerL: $factoryKmPerL, ')
          ..write('oilIntervalKm: $oilIntervalKm, ')
          ..write('isActive: $isActive, ')
          ..write('lastOilChangeOdo: $lastOilChangeOdo, ')
          ..write('lastOilChangeDate: $lastOilChangeDate')
          ..write(')'))
        .toString();
  }
}

class $StationsTable extends Stations with TableInfo<$StationsTable, Station> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Station> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Station map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Station(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $StationsTable createAlias(String alias) {
    return $StationsTable(attachedDatabase, alias);
  }
}

class Station extends DataClass implements Insertable<Station> {
  final int id;
  final String name;
  const Station({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  StationsCompanion toCompanion(bool nullToAbsent) {
    return StationsCompanion(id: Value(id), name: Value(name));
  }

  factory Station.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Station(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Station copyWith({int? id, String? name}) =>
      Station(id: id ?? this.id, name: name ?? this.name);
  Station copyWithCompanion(StationsCompanion data) {
    return Station(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Station(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Station && other.id == this.id && other.name == this.name);
}

class StationsCompanion extends UpdateCompanion<Station> {
  final Value<int> id;
  final Value<String> name;
  const StationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  StationsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<Station> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  StationsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return StationsCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $FuelEntriesTable extends FuelEntries
    with TableInfo<$FuelEntriesTable, FuelEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FuelEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bikeIdMeta = const VerificationMeta('bikeId');
  @override
  late final GeneratedColumn<int> bikeId = GeneratedColumn<int>(
    'bike_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bikes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _odometerMeta = const VerificationMeta(
    'odometer',
  );
  @override
  late final GeneratedColumn<int> odometer = GeneratedColumn<int>(
    'odometer',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _litersMeta = const VerificationMeta('liters');
  @override
  late final GeneratedColumn<double> liters = GeneratedColumn<double>(
    'liters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pricePerLiterMeta = const VerificationMeta(
    'pricePerLiter',
  );
  @override
  late final GeneratedColumn<double> pricePerLiter = GeneratedColumn<double>(
    'price_per_liter',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaidMeta = const VerificationMeta(
    'amountPaid',
  );
  @override
  late final GeneratedColumn<double> amountPaid = GeneratedColumn<double>(
    'amount_paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFullTankMeta = const VerificationMeta(
    'isFullTank',
  );
  @override
  late final GeneratedColumn<bool> isFullTank = GeneratedColumn<bool>(
    'is_full_tank',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_full_tank" IN (0, 1))',
    ),
  );
  static const VerificationMeta _stationIdMeta = const VerificationMeta(
    'stationId',
  );
  @override
  late final GeneratedColumn<int> stationId = GeneratedColumn<int>(
    'station_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stations (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bikeId,
    date,
    odometer,
    liters,
    pricePerLiter,
    amountPaid,
    isFullTank,
    stationId,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fuel_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<FuelEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bike_id')) {
      context.handle(
        _bikeIdMeta,
        bikeId.isAcceptableOrUnknown(data['bike_id']!, _bikeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bikeIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('odometer')) {
      context.handle(
        _odometerMeta,
        odometer.isAcceptableOrUnknown(data['odometer']!, _odometerMeta),
      );
    } else if (isInserting) {
      context.missing(_odometerMeta);
    }
    if (data.containsKey('liters')) {
      context.handle(
        _litersMeta,
        liters.isAcceptableOrUnknown(data['liters']!, _litersMeta),
      );
    } else if (isInserting) {
      context.missing(_litersMeta);
    }
    if (data.containsKey('price_per_liter')) {
      context.handle(
        _pricePerLiterMeta,
        pricePerLiter.isAcceptableOrUnknown(
          data['price_per_liter']!,
          _pricePerLiterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricePerLiterMeta);
    }
    if (data.containsKey('amount_paid')) {
      context.handle(
        _amountPaidMeta,
        amountPaid.isAcceptableOrUnknown(data['amount_paid']!, _amountPaidMeta),
      );
    } else if (isInserting) {
      context.missing(_amountPaidMeta);
    }
    if (data.containsKey('is_full_tank')) {
      context.handle(
        _isFullTankMeta,
        isFullTank.isAcceptableOrUnknown(
          data['is_full_tank']!,
          _isFullTankMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_isFullTankMeta);
    }
    if (data.containsKey('station_id')) {
      context.handle(
        _stationIdMeta,
        stationId.isAcceptableOrUnknown(data['station_id']!, _stationIdMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FuelEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FuelEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bikeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bike_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      odometer: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odometer'],
      )!,
      liters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}liters'],
      )!,
      pricePerLiter: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_per_liter'],
      )!,
      amountPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_paid'],
      )!,
      isFullTank: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_full_tank'],
      )!,
      stationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}station_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $FuelEntriesTable createAlias(String alias) {
    return $FuelEntriesTable(attachedDatabase, alias);
  }
}

class FuelEntry extends DataClass implements Insertable<FuelEntry> {
  final int id;
  final int bikeId;
  final DateTime date;
  final int odometer;
  final double liters;
  final double pricePerLiter;
  final double amountPaid;
  final bool isFullTank;
  final int? stationId;
  final String? note;
  const FuelEntry({
    required this.id,
    required this.bikeId,
    required this.date,
    required this.odometer,
    required this.liters,
    required this.pricePerLiter,
    required this.amountPaid,
    required this.isFullTank,
    this.stationId,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bike_id'] = Variable<int>(bikeId);
    map['date'] = Variable<DateTime>(date);
    map['odometer'] = Variable<int>(odometer);
    map['liters'] = Variable<double>(liters);
    map['price_per_liter'] = Variable<double>(pricePerLiter);
    map['amount_paid'] = Variable<double>(amountPaid);
    map['is_full_tank'] = Variable<bool>(isFullTank);
    if (!nullToAbsent || stationId != null) {
      map['station_id'] = Variable<int>(stationId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  FuelEntriesCompanion toCompanion(bool nullToAbsent) {
    return FuelEntriesCompanion(
      id: Value(id),
      bikeId: Value(bikeId),
      date: Value(date),
      odometer: Value(odometer),
      liters: Value(liters),
      pricePerLiter: Value(pricePerLiter),
      amountPaid: Value(amountPaid),
      isFullTank: Value(isFullTank),
      stationId: stationId == null && nullToAbsent
          ? const Value.absent()
          : Value(stationId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory FuelEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FuelEntry(
      id: serializer.fromJson<int>(json['id']),
      bikeId: serializer.fromJson<int>(json['bikeId']),
      date: serializer.fromJson<DateTime>(json['date']),
      odometer: serializer.fromJson<int>(json['odometer']),
      liters: serializer.fromJson<double>(json['liters']),
      pricePerLiter: serializer.fromJson<double>(json['pricePerLiter']),
      amountPaid: serializer.fromJson<double>(json['amountPaid']),
      isFullTank: serializer.fromJson<bool>(json['isFullTank']),
      stationId: serializer.fromJson<int?>(json['stationId']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bikeId': serializer.toJson<int>(bikeId),
      'date': serializer.toJson<DateTime>(date),
      'odometer': serializer.toJson<int>(odometer),
      'liters': serializer.toJson<double>(liters),
      'pricePerLiter': serializer.toJson<double>(pricePerLiter),
      'amountPaid': serializer.toJson<double>(amountPaid),
      'isFullTank': serializer.toJson<bool>(isFullTank),
      'stationId': serializer.toJson<int?>(stationId),
      'note': serializer.toJson<String?>(note),
    };
  }

  FuelEntry copyWith({
    int? id,
    int? bikeId,
    DateTime? date,
    int? odometer,
    double? liters,
    double? pricePerLiter,
    double? amountPaid,
    bool? isFullTank,
    Value<int?> stationId = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => FuelEntry(
    id: id ?? this.id,
    bikeId: bikeId ?? this.bikeId,
    date: date ?? this.date,
    odometer: odometer ?? this.odometer,
    liters: liters ?? this.liters,
    pricePerLiter: pricePerLiter ?? this.pricePerLiter,
    amountPaid: amountPaid ?? this.amountPaid,
    isFullTank: isFullTank ?? this.isFullTank,
    stationId: stationId.present ? stationId.value : this.stationId,
    note: note.present ? note.value : this.note,
  );
  FuelEntry copyWithCompanion(FuelEntriesCompanion data) {
    return FuelEntry(
      id: data.id.present ? data.id.value : this.id,
      bikeId: data.bikeId.present ? data.bikeId.value : this.bikeId,
      date: data.date.present ? data.date.value : this.date,
      odometer: data.odometer.present ? data.odometer.value : this.odometer,
      liters: data.liters.present ? data.liters.value : this.liters,
      pricePerLiter: data.pricePerLiter.present
          ? data.pricePerLiter.value
          : this.pricePerLiter,
      amountPaid: data.amountPaid.present
          ? data.amountPaid.value
          : this.amountPaid,
      isFullTank: data.isFullTank.present
          ? data.isFullTank.value
          : this.isFullTank,
      stationId: data.stationId.present ? data.stationId.value : this.stationId,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FuelEntry(')
          ..write('id: $id, ')
          ..write('bikeId: $bikeId, ')
          ..write('date: $date, ')
          ..write('odometer: $odometer, ')
          ..write('liters: $liters, ')
          ..write('pricePerLiter: $pricePerLiter, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('isFullTank: $isFullTank, ')
          ..write('stationId: $stationId, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bikeId,
    date,
    odometer,
    liters,
    pricePerLiter,
    amountPaid,
    isFullTank,
    stationId,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FuelEntry &&
          other.id == this.id &&
          other.bikeId == this.bikeId &&
          other.date == this.date &&
          other.odometer == this.odometer &&
          other.liters == this.liters &&
          other.pricePerLiter == this.pricePerLiter &&
          other.amountPaid == this.amountPaid &&
          other.isFullTank == this.isFullTank &&
          other.stationId == this.stationId &&
          other.note == this.note);
}

class FuelEntriesCompanion extends UpdateCompanion<FuelEntry> {
  final Value<int> id;
  final Value<int> bikeId;
  final Value<DateTime> date;
  final Value<int> odometer;
  final Value<double> liters;
  final Value<double> pricePerLiter;
  final Value<double> amountPaid;
  final Value<bool> isFullTank;
  final Value<int?> stationId;
  final Value<String?> note;
  const FuelEntriesCompanion({
    this.id = const Value.absent(),
    this.bikeId = const Value.absent(),
    this.date = const Value.absent(),
    this.odometer = const Value.absent(),
    this.liters = const Value.absent(),
    this.pricePerLiter = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.isFullTank = const Value.absent(),
    this.stationId = const Value.absent(),
    this.note = const Value.absent(),
  });
  FuelEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int bikeId,
    required DateTime date,
    required int odometer,
    required double liters,
    required double pricePerLiter,
    required double amountPaid,
    required bool isFullTank,
    this.stationId = const Value.absent(),
    this.note = const Value.absent(),
  }) : bikeId = Value(bikeId),
       date = Value(date),
       odometer = Value(odometer),
       liters = Value(liters),
       pricePerLiter = Value(pricePerLiter),
       amountPaid = Value(amountPaid),
       isFullTank = Value(isFullTank);
  static Insertable<FuelEntry> custom({
    Expression<int>? id,
    Expression<int>? bikeId,
    Expression<DateTime>? date,
    Expression<int>? odometer,
    Expression<double>? liters,
    Expression<double>? pricePerLiter,
    Expression<double>? amountPaid,
    Expression<bool>? isFullTank,
    Expression<int>? stationId,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bikeId != null) 'bike_id': bikeId,
      if (date != null) 'date': date,
      if (odometer != null) 'odometer': odometer,
      if (liters != null) 'liters': liters,
      if (pricePerLiter != null) 'price_per_liter': pricePerLiter,
      if (amountPaid != null) 'amount_paid': amountPaid,
      if (isFullTank != null) 'is_full_tank': isFullTank,
      if (stationId != null) 'station_id': stationId,
      if (note != null) 'note': note,
    });
  }

  FuelEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? bikeId,
    Value<DateTime>? date,
    Value<int>? odometer,
    Value<double>? liters,
    Value<double>? pricePerLiter,
    Value<double>? amountPaid,
    Value<bool>? isFullTank,
    Value<int?>? stationId,
    Value<String?>? note,
  }) {
    return FuelEntriesCompanion(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      date: date ?? this.date,
      odometer: odometer ?? this.odometer,
      liters: liters ?? this.liters,
      pricePerLiter: pricePerLiter ?? this.pricePerLiter,
      amountPaid: amountPaid ?? this.amountPaid,
      isFullTank: isFullTank ?? this.isFullTank,
      stationId: stationId ?? this.stationId,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bikeId.present) {
      map['bike_id'] = Variable<int>(bikeId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (odometer.present) {
      map['odometer'] = Variable<int>(odometer.value);
    }
    if (liters.present) {
      map['liters'] = Variable<double>(liters.value);
    }
    if (pricePerLiter.present) {
      map['price_per_liter'] = Variable<double>(pricePerLiter.value);
    }
    if (amountPaid.present) {
      map['amount_paid'] = Variable<double>(amountPaid.value);
    }
    if (isFullTank.present) {
      map['is_full_tank'] = Variable<bool>(isFullTank.value);
    }
    if (stationId.present) {
      map['station_id'] = Variable<int>(stationId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FuelEntriesCompanion(')
          ..write('id: $id, ')
          ..write('bikeId: $bikeId, ')
          ..write('date: $date, ')
          ..write('odometer: $odometer, ')
          ..write('liters: $liters, ')
          ..write('pricePerLiter: $pricePerLiter, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('isFullTank: $isFullTank, ')
          ..write('stationId: $stationId, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $MaintenanceItemsTable extends MaintenanceItems
    with TableInfo<$MaintenanceItemsTable, MaintenanceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaintenanceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bikeIdMeta = const VerificationMeta('bikeId');
  @override
  late final GeneratedColumn<int> bikeId = GeneratedColumn<int>(
    'bike_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bikes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 40,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalKmMeta = const VerificationMeta(
    'intervalKm',
  );
  @override
  late final GeneratedColumn<int> intervalKm = GeneratedColumn<int>(
    'interval_km',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intervalMonthsMeta = const VerificationMeta(
    'intervalMonths',
  );
  @override
  late final GeneratedColumn<int> intervalMonths = GeneratedColumn<int>(
    'interval_months',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastOdoMeta = const VerificationMeta(
    'lastOdo',
  );
  @override
  late final GeneratedColumn<int> lastOdo = GeneratedColumn<int>(
    'last_odo',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastDateMeta = const VerificationMeta(
    'lastDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastDate = GeneratedColumn<DateTime>(
    'last_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bikeId,
    name,
    intervalKm,
    intervalMonths,
    lastOdo,
    lastDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'maintenance_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaintenanceItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bike_id')) {
      context.handle(
        _bikeIdMeta,
        bikeId.isAcceptableOrUnknown(data['bike_id']!, _bikeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bikeIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('interval_km')) {
      context.handle(
        _intervalKmMeta,
        intervalKm.isAcceptableOrUnknown(data['interval_km']!, _intervalKmMeta),
      );
    }
    if (data.containsKey('interval_months')) {
      context.handle(
        _intervalMonthsMeta,
        intervalMonths.isAcceptableOrUnknown(
          data['interval_months']!,
          _intervalMonthsMeta,
        ),
      );
    }
    if (data.containsKey('last_odo')) {
      context.handle(
        _lastOdoMeta,
        lastOdo.isAcceptableOrUnknown(data['last_odo']!, _lastOdoMeta),
      );
    }
    if (data.containsKey('last_date')) {
      context.handle(
        _lastDateMeta,
        lastDate.isAcceptableOrUnknown(data['last_date']!, _lastDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MaintenanceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaintenanceItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bikeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bike_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      intervalKm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_km'],
      ),
      intervalMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_months'],
      ),
      lastOdo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_odo'],
      ),
      lastDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_date'],
      ),
    );
  }

  @override
  $MaintenanceItemsTable createAlias(String alias) {
    return $MaintenanceItemsTable(attachedDatabase, alias);
  }
}

class MaintenanceItem extends DataClass implements Insertable<MaintenanceItem> {
  final int id;
  final int bikeId;
  final String name;
  final int? intervalKm;
  final int? intervalMonths;
  final int? lastOdo;
  final DateTime? lastDate;
  const MaintenanceItem({
    required this.id,
    required this.bikeId,
    required this.name,
    this.intervalKm,
    this.intervalMonths,
    this.lastOdo,
    this.lastDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bike_id'] = Variable<int>(bikeId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || intervalKm != null) {
      map['interval_km'] = Variable<int>(intervalKm);
    }
    if (!nullToAbsent || intervalMonths != null) {
      map['interval_months'] = Variable<int>(intervalMonths);
    }
    if (!nullToAbsent || lastOdo != null) {
      map['last_odo'] = Variable<int>(lastOdo);
    }
    if (!nullToAbsent || lastDate != null) {
      map['last_date'] = Variable<DateTime>(lastDate);
    }
    return map;
  }

  MaintenanceItemsCompanion toCompanion(bool nullToAbsent) {
    return MaintenanceItemsCompanion(
      id: Value(id),
      bikeId: Value(bikeId),
      name: Value(name),
      intervalKm: intervalKm == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalKm),
      intervalMonths: intervalMonths == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalMonths),
      lastOdo: lastOdo == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOdo),
      lastDate: lastDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastDate),
    );
  }

  factory MaintenanceItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaintenanceItem(
      id: serializer.fromJson<int>(json['id']),
      bikeId: serializer.fromJson<int>(json['bikeId']),
      name: serializer.fromJson<String>(json['name']),
      intervalKm: serializer.fromJson<int?>(json['intervalKm']),
      intervalMonths: serializer.fromJson<int?>(json['intervalMonths']),
      lastOdo: serializer.fromJson<int?>(json['lastOdo']),
      lastDate: serializer.fromJson<DateTime?>(json['lastDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bikeId': serializer.toJson<int>(bikeId),
      'name': serializer.toJson<String>(name),
      'intervalKm': serializer.toJson<int?>(intervalKm),
      'intervalMonths': serializer.toJson<int?>(intervalMonths),
      'lastOdo': serializer.toJson<int?>(lastOdo),
      'lastDate': serializer.toJson<DateTime?>(lastDate),
    };
  }

  MaintenanceItem copyWith({
    int? id,
    int? bikeId,
    String? name,
    Value<int?> intervalKm = const Value.absent(),
    Value<int?> intervalMonths = const Value.absent(),
    Value<int?> lastOdo = const Value.absent(),
    Value<DateTime?> lastDate = const Value.absent(),
  }) => MaintenanceItem(
    id: id ?? this.id,
    bikeId: bikeId ?? this.bikeId,
    name: name ?? this.name,
    intervalKm: intervalKm.present ? intervalKm.value : this.intervalKm,
    intervalMonths: intervalMonths.present
        ? intervalMonths.value
        : this.intervalMonths,
    lastOdo: lastOdo.present ? lastOdo.value : this.lastOdo,
    lastDate: lastDate.present ? lastDate.value : this.lastDate,
  );
  MaintenanceItem copyWithCompanion(MaintenanceItemsCompanion data) {
    return MaintenanceItem(
      id: data.id.present ? data.id.value : this.id,
      bikeId: data.bikeId.present ? data.bikeId.value : this.bikeId,
      name: data.name.present ? data.name.value : this.name,
      intervalKm: data.intervalKm.present
          ? data.intervalKm.value
          : this.intervalKm,
      intervalMonths: data.intervalMonths.present
          ? data.intervalMonths.value
          : this.intervalMonths,
      lastOdo: data.lastOdo.present ? data.lastOdo.value : this.lastOdo,
      lastDate: data.lastDate.present ? data.lastDate.value : this.lastDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceItem(')
          ..write('id: $id, ')
          ..write('bikeId: $bikeId, ')
          ..write('name: $name, ')
          ..write('intervalKm: $intervalKm, ')
          ..write('intervalMonths: $intervalMonths, ')
          ..write('lastOdo: $lastOdo, ')
          ..write('lastDate: $lastDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bikeId,
    name,
    intervalKm,
    intervalMonths,
    lastOdo,
    lastDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaintenanceItem &&
          other.id == this.id &&
          other.bikeId == this.bikeId &&
          other.name == this.name &&
          other.intervalKm == this.intervalKm &&
          other.intervalMonths == this.intervalMonths &&
          other.lastOdo == this.lastOdo &&
          other.lastDate == this.lastDate);
}

class MaintenanceItemsCompanion extends UpdateCompanion<MaintenanceItem> {
  final Value<int> id;
  final Value<int> bikeId;
  final Value<String> name;
  final Value<int?> intervalKm;
  final Value<int?> intervalMonths;
  final Value<int?> lastOdo;
  final Value<DateTime?> lastDate;
  const MaintenanceItemsCompanion({
    this.id = const Value.absent(),
    this.bikeId = const Value.absent(),
    this.name = const Value.absent(),
    this.intervalKm = const Value.absent(),
    this.intervalMonths = const Value.absent(),
    this.lastOdo = const Value.absent(),
    this.lastDate = const Value.absent(),
  });
  MaintenanceItemsCompanion.insert({
    this.id = const Value.absent(),
    required int bikeId,
    required String name,
    this.intervalKm = const Value.absent(),
    this.intervalMonths = const Value.absent(),
    this.lastOdo = const Value.absent(),
    this.lastDate = const Value.absent(),
  }) : bikeId = Value(bikeId),
       name = Value(name);
  static Insertable<MaintenanceItem> custom({
    Expression<int>? id,
    Expression<int>? bikeId,
    Expression<String>? name,
    Expression<int>? intervalKm,
    Expression<int>? intervalMonths,
    Expression<int>? lastOdo,
    Expression<DateTime>? lastDate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bikeId != null) 'bike_id': bikeId,
      if (name != null) 'name': name,
      if (intervalKm != null) 'interval_km': intervalKm,
      if (intervalMonths != null) 'interval_months': intervalMonths,
      if (lastOdo != null) 'last_odo': lastOdo,
      if (lastDate != null) 'last_date': lastDate,
    });
  }

  MaintenanceItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? bikeId,
    Value<String>? name,
    Value<int?>? intervalKm,
    Value<int?>? intervalMonths,
    Value<int?>? lastOdo,
    Value<DateTime?>? lastDate,
  }) {
    return MaintenanceItemsCompanion(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      name: name ?? this.name,
      intervalKm: intervalKm ?? this.intervalKm,
      intervalMonths: intervalMonths ?? this.intervalMonths,
      lastOdo: lastOdo ?? this.lastOdo,
      lastDate: lastDate ?? this.lastDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bikeId.present) {
      map['bike_id'] = Variable<int>(bikeId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (intervalKm.present) {
      map['interval_km'] = Variable<int>(intervalKm.value);
    }
    if (intervalMonths.present) {
      map['interval_months'] = Variable<int>(intervalMonths.value);
    }
    if (lastOdo.present) {
      map['last_odo'] = Variable<int>(lastOdo.value);
    }
    if (lastDate.present) {
      map['last_date'] = Variable<DateTime>(lastDate.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceItemsCompanion(')
          ..write('id: $id, ')
          ..write('bikeId: $bikeId, ')
          ..write('name: $name, ')
          ..write('intervalKm: $intervalKm, ')
          ..write('intervalMonths: $intervalMonths, ')
          ..write('lastOdo: $lastOdo, ')
          ..write('lastDate: $lastDate')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BikesTable bikes = $BikesTable(this);
  late final $StationsTable stations = $StationsTable(this);
  late final $FuelEntriesTable fuelEntries = $FuelEntriesTable(this);
  late final $MaintenanceItemsTable maintenanceItems = $MaintenanceItemsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    bikes,
    stations,
    fuelEntries,
    maintenanceItems,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bikes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('fuel_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'stations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('fuel_entries', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bikes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('maintenance_items', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$BikesTableCreateCompanionBuilder = BikesCompanion Function({
  Value<int> id,
  required String nickname,
  required String make,
  required String model,
  Value<int?> year,
  Value<double?> tankCapacityL,
  Value<double?> factoryKmPerL,
  required int oilIntervalKm,
  Value<bool> isActive,
  Value<int?> lastOilChangeOdo,
  Value<DateTime?> lastOilChangeDate,
});
typedef $$BikesTableUpdateCompanionBuilder = BikesCompanion Function({
  Value<int> id,
  Value<String> nickname,
  Value<String> make,
  Value<String> model,
  Value<int?> year,
  Value<double?> tankCapacityL,
  Value<double?> factoryKmPerL,
  Value<int> oilIntervalKm,
  Value<bool> isActive,
  Value<int?> lastOilChangeOdo,
  Value<DateTime?> lastOilChangeDate,
});

final class $$BikesTableReferences
    extends BaseReferences<_$AppDatabase, $BikesTable, Bike> {
  $$BikesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FuelEntriesTable, List<FuelEntry>>
  _fuelEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.fuelEntries,
    aliasName: 'bikes__id__fuel_entries__bike_id',
  );

  $$FuelEntriesTableProcessedTableManager get fuelEntriesRefs {
    final manager = $$FuelEntriesTableTableManager(
      $_db,
      $_db.fuelEntries,
    ).filter((f) => f.bikeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_fuelEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MaintenanceItemsTable, List<MaintenanceItem>>
  _maintenanceItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.maintenanceItems,
    aliasName: 'bikes__id__maintenance_items__bike_id',
  );

  $$MaintenanceItemsTableProcessedTableManager get maintenanceItemsRefs {
    final manager = $$MaintenanceItemsTableTableManager(
      $_db,
      $_db.maintenanceItems,
    ).filter((f) => f.bikeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _maintenanceItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BikesTableFilterComposer extends Composer<_$AppDatabase, $BikesTable> {
  $$BikesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tankCapacityL => $composableBuilder(
    column: $table.tankCapacityL,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get factoryKmPerL => $composableBuilder(
    column: $table.factoryKmPerL,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get oilIntervalKm => $composableBuilder(
    column: $table.oilIntervalKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastOilChangeOdo => $composableBuilder(
    column: $table.lastOilChangeOdo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastOilChangeDate => $composableBuilder(
    column: $table.lastOilChangeDate,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> fuelEntriesRefs(
    Expression<bool> Function($$FuelEntriesTableFilterComposer f) f,
  ) {
    final $$FuelEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fuelEntries,
      getReferencedColumn: (t) => t.bikeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FuelEntriesTableFilterComposer(
            $db: $db,
            $table: $db.fuelEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> maintenanceItemsRefs(
    Expression<bool> Function($$MaintenanceItemsTableFilterComposer f) f,
  ) {
    final $$MaintenanceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceItems,
      getReferencedColumn: (t) => t.bikeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceItemsTableFilterComposer(
            $db: $db,
            $table: $db.maintenanceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BikesTableOrderingComposer
    extends Composer<_$AppDatabase, $BikesTable> {
  $$BikesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tankCapacityL => $composableBuilder(
    column: $table.tankCapacityL,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get factoryKmPerL => $composableBuilder(
    column: $table.factoryKmPerL,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get oilIntervalKm => $composableBuilder(
    column: $table.oilIntervalKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastOilChangeOdo => $composableBuilder(
    column: $table.lastOilChangeOdo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastOilChangeDate => $composableBuilder(
    column: $table.lastOilChangeDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BikesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BikesTable> {
  $$BikesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get make =>
      $composableBuilder(column: $table.make, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<double> get tankCapacityL => $composableBuilder(
    column: $table.tankCapacityL,
    builder: (column) => column,
  );

  GeneratedColumn<double> get factoryKmPerL => $composableBuilder(
    column: $table.factoryKmPerL,
    builder: (column) => column,
  );

  GeneratedColumn<int> get oilIntervalKm => $composableBuilder(
    column: $table.oilIntervalKm,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get lastOilChangeOdo => $composableBuilder(
    column: $table.lastOilChangeOdo,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastOilChangeDate => $composableBuilder(
    column: $table.lastOilChangeDate,
    builder: (column) => column,
  );

  Expression<T> fuelEntriesRefs<T extends Object>(
    Expression<T> Function($$FuelEntriesTableAnnotationComposer a) f,
  ) {
    final $$FuelEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fuelEntries,
      getReferencedColumn: (t) => t.bikeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FuelEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.fuelEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> maintenanceItemsRefs<T extends Object>(
    Expression<T> Function($$MaintenanceItemsTableAnnotationComposer a) f,
  ) {
    final $$MaintenanceItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceItems,
      getReferencedColumn: (t) => t.bikeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.maintenanceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BikesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BikesTable,
          Bike,
          $$BikesTableFilterComposer,
          $$BikesTableOrderingComposer,
          $$BikesTableAnnotationComposer,
          $$BikesTableCreateCompanionBuilder,
          $$BikesTableUpdateCompanionBuilder,
          (Bike, $$BikesTableReferences),
          Bike,
          PrefetchHooks Function({
            bool fuelEntriesRefs,
            bool maintenanceItemsRefs,
          })
        > {
  $$BikesTableTableManager(_$AppDatabase db, $BikesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BikesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BikesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BikesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nickname = const Value.absent(),
                Value<String> make = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<double?> tankCapacityL = const Value.absent(),
                Value<double?> factoryKmPerL = const Value.absent(),
                Value<int> oilIntervalKm = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int?> lastOilChangeOdo = const Value.absent(),
                Value<DateTime?> lastOilChangeDate = const Value.absent(),
              }) => BikesCompanion(
                id: id,
                nickname: nickname,
                make: make,
                model: model,
                year: year,
                tankCapacityL: tankCapacityL,
                factoryKmPerL: factoryKmPerL,
                oilIntervalKm: oilIntervalKm,
                isActive: isActive,
                lastOilChangeOdo: lastOilChangeOdo,
                lastOilChangeDate: lastOilChangeDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nickname,
                required String make,
                required String model,
                Value<int?> year = const Value.absent(),
                Value<double?> tankCapacityL = const Value.absent(),
                Value<double?> factoryKmPerL = const Value.absent(),
                required int oilIntervalKm,
                Value<bool> isActive = const Value.absent(),
                Value<int?> lastOilChangeOdo = const Value.absent(),
                Value<DateTime?> lastOilChangeDate = const Value.absent(),
              }) => BikesCompanion.insert(
                id: id,
                nickname: nickname,
                make: make,
                model: model,
                year: year,
                tankCapacityL: tankCapacityL,
                factoryKmPerL: factoryKmPerL,
                oilIntervalKm: oilIntervalKm,
                isActive: isActive,
                lastOilChangeOdo: lastOilChangeOdo,
                lastOilChangeDate: lastOilChangeDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BikesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({fuelEntriesRefs = false, maintenanceItemsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (fuelEntriesRefs) db.fuelEntries,
                    if (maintenanceItemsRefs) db.maintenanceItems,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (fuelEntriesRefs)
                        await $_getPrefetchedData<Bike, $BikesTable, FuelEntry>(
                          currentTable: table,
                          referencedTable: $$BikesTableReferences
                              ._fuelEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BikesTableReferences(
                                db,
                                table,
                                p0,
                              ).fuelEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bikeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (maintenanceItemsRefs)
                        await $_getPrefetchedData<
                          Bike,
                          $BikesTable,
                          MaintenanceItem
                        >(
                          currentTable: table,
                          referencedTable: $$BikesTableReferences
                              ._maintenanceItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BikesTableReferences(
                                db,
                                table,
                                p0,
                              ).maintenanceItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bikeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BikesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BikesTable,
      Bike,
      $$BikesTableFilterComposer,
      $$BikesTableOrderingComposer,
      $$BikesTableAnnotationComposer,
      $$BikesTableCreateCompanionBuilder,
      $$BikesTableUpdateCompanionBuilder,
      (Bike, $$BikesTableReferences),
      Bike,
      PrefetchHooks Function({bool fuelEntriesRefs, bool maintenanceItemsRefs})
    >;
typedef $$StationsTableCreateCompanionBuilder = StationsCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$StationsTableUpdateCompanionBuilder = StationsCompanion Function({
  Value<int> id,
  Value<String> name,
});

final class $$StationsTableReferences
    extends BaseReferences<_$AppDatabase, $StationsTable, Station> {
  $$StationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FuelEntriesTable, List<FuelEntry>>
  _fuelEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.fuelEntries,
    aliasName: 'stations__id__fuel_entries__station_id',
  );

  $$FuelEntriesTableProcessedTableManager get fuelEntriesRefs {
    final manager = $$FuelEntriesTableTableManager(
      $_db,
      $_db.fuelEntries,
    ).filter((f) => f.stationId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_fuelEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StationsTableFilterComposer
    extends Composer<_$AppDatabase, $StationsTable> {
  $$StationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> fuelEntriesRefs(
    Expression<bool> Function($$FuelEntriesTableFilterComposer f) f,
  ) {
    final $$FuelEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fuelEntries,
      getReferencedColumn: (t) => t.stationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FuelEntriesTableFilterComposer(
            $db: $db,
            $table: $db.fuelEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StationsTableOrderingComposer
    extends Composer<_$AppDatabase, $StationsTable> {
  $$StationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StationsTable> {
  $$StationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> fuelEntriesRefs<T extends Object>(
    Expression<T> Function($$FuelEntriesTableAnnotationComposer a) f,
  ) {
    final $$FuelEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fuelEntries,
      getReferencedColumn: (t) => t.stationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FuelEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.fuelEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StationsTable,
          Station,
          $$StationsTableFilterComposer,
          $$StationsTableOrderingComposer,
          $$StationsTableAnnotationComposer,
          $$StationsTableCreateCompanionBuilder,
          $$StationsTableUpdateCompanionBuilder,
          (Station, $$StationsTableReferences),
          Station,
          PrefetchHooks Function({bool fuelEntriesRefs})
        > {
  $$StationsTableTableManager(_$AppDatabase db, $StationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) => StationsCompanion(id: id, name: name),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) => StationsCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({fuelEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (fuelEntriesRefs) db.fuelEntries],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (fuelEntriesRefs)
                    await $_getPrefetchedData<
                      Station,
                      $StationsTable,
                      FuelEntry
                    >(
                      currentTable: table,
                      referencedTable: $$StationsTableReferences
                          ._fuelEntriesRefsTable(db),
                      managerFromTypedResult: (p0) => $$StationsTableReferences(
                        db,
                        table,
                        p0,
                      ).fuelEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.stationId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$StationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StationsTable,
      Station,
      $$StationsTableFilterComposer,
      $$StationsTableOrderingComposer,
      $$StationsTableAnnotationComposer,
      $$StationsTableCreateCompanionBuilder,
      $$StationsTableUpdateCompanionBuilder,
      (Station, $$StationsTableReferences),
      Station,
      PrefetchHooks Function({bool fuelEntriesRefs})
    >;
typedef $$FuelEntriesTableCreateCompanionBuilder =
    FuelEntriesCompanion Function({
      Value<int> id,
      required int bikeId,
      required DateTime date,
      required int odometer,
      required double liters,
      required double pricePerLiter,
      required double amountPaid,
      required bool isFullTank,
      Value<int?> stationId,
      Value<String?> note,
    });
typedef $$FuelEntriesTableUpdateCompanionBuilder =
    FuelEntriesCompanion Function({
      Value<int> id,
      Value<int> bikeId,
      Value<DateTime> date,
      Value<int> odometer,
      Value<double> liters,
      Value<double> pricePerLiter,
      Value<double> amountPaid,
      Value<bool> isFullTank,
      Value<int?> stationId,
      Value<String?> note,
    });

final class $$FuelEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $FuelEntriesTable, FuelEntry> {
  $$FuelEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BikesTable _bikeIdTable(_$AppDatabase db) =>
      db.bikes.createAlias('fuel_entries__bike_id__bikes__id');

  $$BikesTableProcessedTableManager get bikeId {
    final $_column = $_itemColumn<int>('bike_id')!;

    final manager = $$BikesTableTableManager(
      $_db,
      $_db.bikes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bikeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StationsTable _stationIdTable(_$AppDatabase db) =>
      db.stations.createAlias('fuel_entries__station_id__stations__id');

  $$StationsTableProcessedTableManager? get stationId {
    final $_column = $_itemColumn<int>('station_id');
    if ($_column == null) return null;
    final manager = $$StationsTableTableManager(
      $_db,
      $_db.stations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_stationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$FuelEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $FuelEntriesTable> {
  $$FuelEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odometer => $composableBuilder(
    column: $table.odometer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get liters => $composableBuilder(
    column: $table.liters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pricePerLiter => $composableBuilder(
    column: $table.pricePerLiter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFullTank => $composableBuilder(
    column: $table.isFullTank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$BikesTableFilterComposer get bikeId {
    final $$BikesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bikeId,
      referencedTable: $db.bikes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BikesTableFilterComposer(
            $db: $db,
            $table: $db.bikes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StationsTableFilterComposer get stationId {
    final $$StationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stationId,
      referencedTable: $db.stations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StationsTableFilterComposer(
            $db: $db,
            $table: $db.stations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FuelEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $FuelEntriesTable> {
  $$FuelEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odometer => $composableBuilder(
    column: $table.odometer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get liters => $composableBuilder(
    column: $table.liters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pricePerLiter => $composableBuilder(
    column: $table.pricePerLiter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFullTank => $composableBuilder(
    column: $table.isFullTank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$BikesTableOrderingComposer get bikeId {
    final $$BikesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bikeId,
      referencedTable: $db.bikes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BikesTableOrderingComposer(
            $db: $db,
            $table: $db.bikes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StationsTableOrderingComposer get stationId {
    final $$StationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stationId,
      referencedTable: $db.stations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StationsTableOrderingComposer(
            $db: $db,
            $table: $db.stations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FuelEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FuelEntriesTable> {
  $$FuelEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get odometer =>
      $composableBuilder(column: $table.odometer, builder: (column) => column);

  GeneratedColumn<double> get liters =>
      $composableBuilder(column: $table.liters, builder: (column) => column);

  GeneratedColumn<double> get pricePerLiter => $composableBuilder(
    column: $table.pricePerLiter,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFullTank => $composableBuilder(
    column: $table.isFullTank,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$BikesTableAnnotationComposer get bikeId {
    final $$BikesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bikeId,
      referencedTable: $db.bikes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BikesTableAnnotationComposer(
            $db: $db,
            $table: $db.bikes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StationsTableAnnotationComposer get stationId {
    final $$StationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.stationId,
      referencedTable: $db.stations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StationsTableAnnotationComposer(
            $db: $db,
            $table: $db.stations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FuelEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FuelEntriesTable,
          FuelEntry,
          $$FuelEntriesTableFilterComposer,
          $$FuelEntriesTableOrderingComposer,
          $$FuelEntriesTableAnnotationComposer,
          $$FuelEntriesTableCreateCompanionBuilder,
          $$FuelEntriesTableUpdateCompanionBuilder,
          (FuelEntry, $$FuelEntriesTableReferences),
          FuelEntry,
          PrefetchHooks Function({bool bikeId, bool stationId})
        > {
  $$FuelEntriesTableTableManager(_$AppDatabase db, $FuelEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FuelEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FuelEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FuelEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bikeId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> odometer = const Value.absent(),
                Value<double> liters = const Value.absent(),
                Value<double> pricePerLiter = const Value.absent(),
                Value<double> amountPaid = const Value.absent(),
                Value<bool> isFullTank = const Value.absent(),
                Value<int?> stationId = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => FuelEntriesCompanion(
                id: id,
                bikeId: bikeId,
                date: date,
                odometer: odometer,
                liters: liters,
                pricePerLiter: pricePerLiter,
                amountPaid: amountPaid,
                isFullTank: isFullTank,
                stationId: stationId,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bikeId,
                required DateTime date,
                required int odometer,
                required double liters,
                required double pricePerLiter,
                required double amountPaid,
                required bool isFullTank,
                Value<int?> stationId = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => FuelEntriesCompanion.insert(
                id: id,
                bikeId: bikeId,
                date: date,
                odometer: odometer,
                liters: liters,
                pricePerLiter: pricePerLiter,
                amountPaid: amountPaid,
                isFullTank: isFullTank,
                stationId: stationId,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FuelEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bikeId = false, stationId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bikeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bikeId,
                        referencedTable: $$FuelEntriesTableReferences
                            ._bikeIdTable(db),
                        referencedColumn: $$FuelEntriesTableReferences
                            ._bikeIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (stationId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.stationId,
                        referencedTable: $$FuelEntriesTableReferences
                            ._stationIdTable(db),
                        referencedColumn: $$FuelEntriesTableReferences
                            ._stationIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$FuelEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FuelEntriesTable,
      FuelEntry,
      $$FuelEntriesTableFilterComposer,
      $$FuelEntriesTableOrderingComposer,
      $$FuelEntriesTableAnnotationComposer,
      $$FuelEntriesTableCreateCompanionBuilder,
      $$FuelEntriesTableUpdateCompanionBuilder,
      (FuelEntry, $$FuelEntriesTableReferences),
      FuelEntry,
      PrefetchHooks Function({bool bikeId, bool stationId})
    >;
typedef $$MaintenanceItemsTableCreateCompanionBuilder =
    MaintenanceItemsCompanion Function({
      Value<int> id,
      required int bikeId,
      required String name,
      Value<int?> intervalKm,
      Value<int?> intervalMonths,
      Value<int?> lastOdo,
      Value<DateTime?> lastDate,
    });
typedef $$MaintenanceItemsTableUpdateCompanionBuilder =
    MaintenanceItemsCompanion Function({
      Value<int> id,
      Value<int> bikeId,
      Value<String> name,
      Value<int?> intervalKm,
      Value<int?> intervalMonths,
      Value<int?> lastOdo,
      Value<DateTime?> lastDate,
    });

final class $$MaintenanceItemsTableReferences
    extends
        BaseReferences<_$AppDatabase, $MaintenanceItemsTable, MaintenanceItem> {
  $$MaintenanceItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BikesTable _bikeIdTable(_$AppDatabase db) =>
      db.bikes.createAlias('maintenance_items__bike_id__bikes__id');

  $$BikesTableProcessedTableManager get bikeId {
    final $_column = $_itemColumn<int>('bike_id')!;

    final manager = $$BikesTableTableManager(
      $_db,
      $_db.bikes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bikeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MaintenanceItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MaintenanceItemsTable> {
  $$MaintenanceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalKm => $composableBuilder(
    column: $table.intervalKm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalMonths => $composableBuilder(
    column: $table.intervalMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastOdo => $composableBuilder(
    column: $table.lastOdo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastDate => $composableBuilder(
    column: $table.lastDate,
    builder: (column) => ColumnFilters(column),
  );

  $$BikesTableFilterComposer get bikeId {
    final $$BikesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bikeId,
      referencedTable: $db.bikes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BikesTableFilterComposer(
            $db: $db,
            $table: $db.bikes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MaintenanceItemsTable> {
  $$MaintenanceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalKm => $composableBuilder(
    column: $table.intervalKm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalMonths => $composableBuilder(
    column: $table.intervalMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastOdo => $composableBuilder(
    column: $table.lastOdo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastDate => $composableBuilder(
    column: $table.lastDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$BikesTableOrderingComposer get bikeId {
    final $$BikesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bikeId,
      referencedTable: $db.bikes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BikesTableOrderingComposer(
            $db: $db,
            $table: $db.bikes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaintenanceItemsTable> {
  $$MaintenanceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get intervalKm => $composableBuilder(
    column: $table.intervalKm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalMonths => $composableBuilder(
    column: $table.intervalMonths,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastOdo =>
      $composableBuilder(column: $table.lastOdo, builder: (column) => column);

  GeneratedColumn<DateTime> get lastDate =>
      $composableBuilder(column: $table.lastDate, builder: (column) => column);

  $$BikesTableAnnotationComposer get bikeId {
    final $$BikesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bikeId,
      referencedTable: $db.bikes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BikesTableAnnotationComposer(
            $db: $db,
            $table: $db.bikes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaintenanceItemsTable,
          MaintenanceItem,
          $$MaintenanceItemsTableFilterComposer,
          $$MaintenanceItemsTableOrderingComposer,
          $$MaintenanceItemsTableAnnotationComposer,
          $$MaintenanceItemsTableCreateCompanionBuilder,
          $$MaintenanceItemsTableUpdateCompanionBuilder,
          (MaintenanceItem, $$MaintenanceItemsTableReferences),
          MaintenanceItem,
          PrefetchHooks Function({bool bikeId})
        > {
  $$MaintenanceItemsTableTableManager(
    _$AppDatabase db,
    $MaintenanceItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaintenanceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaintenanceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaintenanceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bikeId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> intervalKm = const Value.absent(),
                Value<int?> intervalMonths = const Value.absent(),
                Value<int?> lastOdo = const Value.absent(),
                Value<DateTime?> lastDate = const Value.absent(),
              }) => MaintenanceItemsCompanion(
                id: id,
                bikeId: bikeId,
                name: name,
                intervalKm: intervalKm,
                intervalMonths: intervalMonths,
                lastOdo: lastOdo,
                lastDate: lastDate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bikeId,
                required String name,
                Value<int?> intervalKm = const Value.absent(),
                Value<int?> intervalMonths = const Value.absent(),
                Value<int?> lastOdo = const Value.absent(),
                Value<DateTime?> lastDate = const Value.absent(),
              }) => MaintenanceItemsCompanion.insert(
                id: id,
                bikeId: bikeId,
                name: name,
                intervalKm: intervalKm,
                intervalMonths: intervalMonths,
                lastOdo: lastOdo,
                lastDate: lastDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MaintenanceItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bikeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bikeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bikeId,
                        referencedTable: $$MaintenanceItemsTableReferences
                            ._bikeIdTable(db),
                        referencedColumn: $$MaintenanceItemsTableReferences
                            ._bikeIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MaintenanceItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaintenanceItemsTable,
      MaintenanceItem,
      $$MaintenanceItemsTableFilterComposer,
      $$MaintenanceItemsTableOrderingComposer,
      $$MaintenanceItemsTableAnnotationComposer,
      $$MaintenanceItemsTableCreateCompanionBuilder,
      $$MaintenanceItemsTableUpdateCompanionBuilder,
      (MaintenanceItem, $$MaintenanceItemsTableReferences),
      MaintenanceItem,
      PrefetchHooks Function({bool bikeId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BikesTableTableManager get bikes =>
      $$BikesTableTableManager(_db, _db.bikes);
  $$StationsTableTableManager get stations =>
      $$StationsTableTableManager(_db, _db.stations);
  $$FuelEntriesTableTableManager get fuelEntries =>
      $$FuelEntriesTableTableManager(_db, _db.fuelEntries);
  $$MaintenanceItemsTableTableManager get maintenanceItems =>
      $$MaintenanceItemsTableTableManager(_db, _db.maintenanceItems);
}
