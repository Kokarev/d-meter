import 'package:flutter_test/flutter_test.dart';
import 'package:d_meter/core/fuel_grade.dart';
import 'package:d_meter/shared/state/density_memory.dart';

void main() {
  setUp(DensityMemory.clear);

  test('starts null', () {
    expect(DensityMemory.p15VacKgL, isNull);
    expect(DensityMemory.family, isNull);
  });

  test('setP15KgM3 stores correctly', () {
    DensityMemory.setP15KgM3(833.9, FuelFamily.diesel);

    expect(DensityMemory.p15VacKgM3, 833.9);
    expect(DensityMemory.p15VacKgL, closeTo(0.8339, 0.0001));
    expect(DensityMemory.family, FuelFamily.diesel);
  });

  test('setP15KgL round-trips correctly', () {
    DensityMemory.setP15KgL(0.8339, FuelFamily.diesel);

    expect(DensityMemory.p15VacKgM3, closeTo(833.9, 0.01));
    expect(DensityMemory.family, FuelFamily.diesel);
  });

  test('clear resets all fields', () {
    DensityMemory.setP15KgM3(833.9, FuelFamily.diesel);
    DensityMemory.clear();

    expect(DensityMemory.p15VacKgL, isNull);
    expect(DensityMemory.family, isNull);
  });

  test('gasoline family stored correctly', () {
    DensityMemory.setP15KgM3(743.3, FuelFamily.gasoline);

    expect(DensityMemory.family, FuelFamily.gasoline);
  });
}
