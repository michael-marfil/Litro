/// Starting values for common PH models, so adding a bike is one tap.
/// 
/// Tank capacities and claimed economy area manufacturer figures via
/// Zigwheels Philippines. `factoryKmPerL` is null where no official figure
/// is published — better blank than invented, and the field is optional.
/// 
/// None of this affects measured efficiency; `factoryKmPerL` only feeds the 
/// "claims vs actual" comparison. Everything stays editable after picking.
class BikePreset {
  const BikePreset({
    required this.make,
    required this.model,
    required this.tankCapacityL,
    this.factoryKmPerL,
  });

  final String make;
  final String model;
  final double tankCapacityL;
  final double? factoryKmPerL;

  String get label => '$make $model';
}

const bikePresets = <BikePreset>[
  BikePreset(
    make: 'Honda',
    model: 'Click 125i',
    tankCapacityL: 5.5,
    factoryKmPerL: 50.3,
  ),
  BikePreset(
    make: 'Honda',
    model: 'Click 160',
    tankCapacityL: 5.5,
    factoryKmPerL: 46.7,
  ),
  BikePreset(make: 'Honda', model: 'BeAT', tankCapacityL: 4.2, factoryKmPerL: 58.2),
  BikePreset(
    make: 'Honda',
    model: 'PCX160',
    tankCapacityL: 8.0,
    factoryKmPerL: 46,
  ),
  BikePreset(make: 'Yamaha', model: 'Nmax 155', tankCapacityL: 7.1, factoryKmPerL: 52.2) ,
  BikePreset(make: 'Yamaha', model: 'Aerox 155', tankCapacityL: 5.5, factoryKmPerL: 48.6),
  BikePreset(make: 'Yamaha', model: 'Mio i 125', tankCapacityL: 4.2, factoryKmPerL: 50),
  BikePreset(make: 'Yamaha', model: 'Sniper 155', tankCapacityL: 5.4, factoryKmPerL: 48),
  BikePreset(make: 'Suzuki', model: 'Raider R150 Fi', tankCapacityL: 4.0, factoryKmPerL: 50),
];