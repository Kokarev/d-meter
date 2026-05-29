import 'package:flutter_test/flutter_test.dart';
import 'package:d_meter/core/fuel_grade.dart';
import 'package:d_meter/features/calculator/models/fuel_mixture.dart';
import 'package:d_meter/features/calculator/services/fuel_mixing_service.dart';

void main() {
  const dieselA = FuelBatch(
    family: FuelFamily.diesel, volumeM3: 5.0,
    p15KgM3: 830.0, actualDensityKgL: 0.820, tempC: 18.5,
  );
  const dieselB = FuelBatch(
    family: FuelFamily.diesel, volumeM3: 10.0,
    p15KgM3: 840.0, actualDensityKgL: 0.835, tempC: 18.0,
  );
  const gasolineA = FuelBatch(
    family: FuelFamily.gasoline, volumeM3: 3.0,
    p15KgM3: 740.0, actualDensityKgL: 0.735, tempC: 20.0,
  );

  group('FuelMixingService.mix', () {
    test('итоговая масса = сумма масс', () {
      final r = FuelMixingService.mix(dieselA, dieselB);
      expect(r.totalMassT,
          closeTo(dieselA.massT + dieselB.massT, 0.001));
    });

    test('объём = масса / плотность', () {
      final r = FuelMixingService.mix(dieselA, dieselB);
      expect(r.totalVolumeM3,
          closeTo(r.totalMassT / r.mixedActualDensityKgL, 0.001));
    });

    test('смешанная плотность между min и max', () {
      final r = FuelMixingService.mix(dieselA, dieselB);
      expect(r.mixedActualDensityKgL,
          greaterThanOrEqualTo(dieselA.actualDensityKgL));
      expect(r.mixedActualDensityKgL,
          lessThanOrEqualTo(dieselB.actualDensityKgL));
    });

    test('одинаковые партии → результат совпадает с партией', () {
      final r = FuelMixingService.mix(dieselA, dieselA);
      expect(r.mixedActualDensityKgL,
          closeTo(dieselA.actualDensityKgL, 0.0001));
    });

    test('нельзя смешивать diesel и gasoline', () {
      expect(() => FuelMixingService.mix(dieselA, gasolineA),
          throwsArgumentError);
    });
  });

  group('FuelMixingService.validate', () {
    test('валидные diesel → null', () {
      expect(FuelMixingService.validate(dieselA, dieselB), isNull);
    });
    test('null → ошибка', () {
      expect(FuelMixingService.validate(null, dieselB), isNotNull);
    });
    test('разные типы → ошибка', () {
      expect(FuelMixingService.validate(dieselA, gasolineA), isNotNull);
    });
    test('нулевой объём → ошибка', () {
      const zero = FuelBatch(
        family: FuelFamily.diesel, volumeM3: 0,
        p15KgM3: 830.0, actualDensityKgL: 0.820, tempC: 18.0,
      );
      expect(FuelMixingService.validate(zero, dieselB), isNotNull);
    });
  });

  group('FuelBatch helpers', () {
    test('massT = volumeM3 × density', () {
      expect(dieselA.massT,
          closeTo(dieselA.volumeM3 * dieselA.actualDensityKgL, 0.0001));
    });
    test('densityAt15KgL = p15KgM3 / 1000', () {
      expect(dieselA.densityAt15KgL,
          closeTo(dieselA.p15KgM3 / 1000, 0.0001));
    });
  });
}
