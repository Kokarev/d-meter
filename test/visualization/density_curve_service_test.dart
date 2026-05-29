import 'package:flutter_test/flutter_test.dart';
import 'package:d_meter/core/fuel_grade.dart';
import 'package:d_meter/features/calculator/services/density_curve_service.dart';

void main() {
  group('DensityCurveService.generateCurve', () {
    test('генерирует точки для всего диапазона', () {
      final curve = DensityCurveService.generateCurve(
        p15KgM3: 833.9, family: FuelFamily.diesel,
        tempFrom: 0, tempTo: 30, step: 1,
      );
      expect(curve.length, 31);
      expect(curve.first.tempC, 0.0);
      expect(curve.last.tempC, 30.0);
    });

    test('при t=15 density равна P15/1000', () {
      final curve = DensityCurveService.generateCurve(
        p15KgM3: 833.9, family: FuelFamily.diesel,
        tempFrom: 15, tempTo: 15, step: 1,
      );
      expect(curve.first.densityKgL, closeTo(833.9 / 1000, 0.0001));
    });

    test('density убывает при росте температуры (diesel)', () {
      final curve = DensityCurveService.generateCurve(
        p15KgM3: 833.9, family: FuelFamily.diesel,
      );
      for (int i = 1; i < curve.length; i++) {
        expect(curve[i].densityKgL, lessThan(curve[i - 1].densityKgL));
      }
    });

    test('diesel и gasoline дают разные кривые', () {
      final d = DensityCurveService.generateCurve(
          p15KgM3: 833.9, family: FuelFamily.diesel);
      final g = DensityCurveService.generateCurve(
          p15KgM3: 743.3, family: FuelFamily.gasoline);
      expect(d.first.densityKgL,
          isNot(closeTo(g.first.densityKgL, 0.001)));
    });

    test('densityRange возвращает физический диапазон', () {
      final curve = DensityCurveService.generateCurve(
          p15KgM3: 833.9, family: FuelFamily.diesel);
      final r = DensityCurveService.densityRange(curve);
      expect(r.min, greaterThan(0.7));
      expect(r.max, lessThan(1.0));
      expect(r.min, lessThan(r.max));
    });
  });

  group('DensityCurveService.computeThermalState', () {
    test('при t=15 расширение = 0', () {
      final s = DensityCurveService.computeThermalState(
          p15KgM3: 833.9, family: FuelFamily.diesel,
          tempC: 15, massT: 100);
      expect(s.thermalExpansionL, closeTo(0, 0.001));
    });

    test('при t>15 расширение положительное', () {
      final s = DensityCurveService.computeThermalState(
          p15KgM3: 833.9, family: FuelFamily.diesel,
          tempC: 25, massT: 100);
      expect(s.thermalExpansionL, greaterThan(0));
    });

    test('при t<15 расширение отрицательное', () {
      final s = DensityCurveService.computeThermalState(
          p15KgM3: 833.9, family: FuelFamily.diesel,
          tempC: 5, massT: 100);
      expect(s.thermalExpansionL, lessThan(0));
    });

    test('масса инвариантна при любой температуре', () {
      for (final t in [0.0, 15.0, 30.0, -5.0]) {
        final s = DensityCurveService.computeThermalState(
            p15KgM3: 833.9, family: FuelFamily.diesel,
            tempC: t, massT: 150);
        expect(s.massT, closeTo(150, 0.0001));
      }
    });

    test('volume = mass / density', () {
      final s = DensityCurveService.computeThermalState(
          p15KgM3: 833.9, family: FuelFamily.diesel,
          tempC: 20, massT: 100);
      expect(s.volumeM3, closeTo(s.massT / s.densityKgL, 0.001));
    });

    test('gasoline: плотность в физическом диапазоне', () {
      final s = DensityCurveService.computeThermalState(
          p15KgM3: 743.3, family: FuelFamily.gasoline,
          tempC: 17, massT: 80);
      expect(s.densityKgL, greaterThan(0.700));
      expect(s.densityKgL, lessThan(0.780));
    });
  });
}
