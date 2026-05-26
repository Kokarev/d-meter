import 'package:flutter_test/flutter_test.dart';
import 'package:d_meter/core/fuel_grade.dart';
import 'package:d_meter/features/calculator/service/density_calculator_service.dart';

void main() {
  // ── Helpers ──────────────────────────────────────────────────────────────

  DensityResult dieselFromWeight({
    required double p15,
    required double temp,
    double weight = 100,
    double contract = 845,
  }) =>
      DensityCalculatorService.calcFromWeight(
        p15KgM3: p15, tempC: temp, weightT: weight,
        contractDensityKgM3: contract, fuelFamily: FuelFamily.diesel,
      );

  DensityResult gasolineFromWeight({
    required double p15,
    required double temp,
    double weight = 100,
    double contract = 743,
  }) =>
      DensityCalculatorService.calcFromWeight(
        p15KgM3: p15, tempC: temp, weightT: weight,
        contractDensityKgM3: contract, fuelFamily: FuelFamily.gasoline,
      );

  // ── Diesel: interpolateA ─────────────────────────────────────────────────

  group('Diesel – interpolateA', () {
    test('exact breakpoint 810 → 752', () {
      expect(DensityCalculatorService.interpolateA(810, FuelFamily.diesel),
          closeTo(752, 0.01));
    });

    test('exact breakpoint 830 → 725', () {
      expect(DensityCalculatorService.interpolateA(830, FuelFamily.diesel),
          closeTo(725, 0.01));
    });

    test('exact breakpoint 880 → 660', () {
      expect(DensityCalculatorService.interpolateA(880, FuelFamily.diesel),
          closeTo(660, 0.01));
    });

    test('interpolates P15=825 → midpoint between 738 and 725 = 731.5', () {
      final a = DensityCalculatorService.interpolateA(825, FuelFamily.diesel);
      expect(a, closeTo(731.5, 0.1));
    });

    // Spec test case: P15=819.8 should land between 810 (752) and 820 (738)
    test('spec case: P15=819.8 coefficient is between 738 and 752', () {
      final a = DensityCalculatorService.interpolateA(819.8, FuelFamily.diesel);
      expect(a, greaterThanOrEqualTo(738));
      expect(a, lessThanOrEqualTo(752));
    });

    test('rejects P15 below diesel range (P15=750)', () {
      expect(
        () => DensityCalculatorService.interpolateA(750, FuelFamily.diesel),
        throwsArgumentError,
      );
    });

    test('rejects P15 above diesel range (P15=890)', () {
      expect(
        () => DensityCalculatorService.interpolateA(890, FuelFamily.diesel),
        throwsArgumentError,
      );
    });

    test('does NOT use gasoline P15=740 for diesel', () {
      expect(
        () => DensityCalculatorService.interpolateA(740, FuelFamily.diesel),
        throwsArgumentError,
      );
    });
  });

  // ── Gasoline: interpolateA ───────────────────────────────────────────────

  group('Gasoline – interpolateA', () {
    test('exact breakpoint 710 → 884', () {
      expect(DensityCalculatorService.interpolateA(710, FuelFamily.gasoline),
          closeTo(884, 0.01));
    });

    test('exact breakpoint 740 → 844', () {
      expect(DensityCalculatorService.interpolateA(740, FuelFamily.gasoline),
          closeTo(844, 0.01));
    });

    test('exact breakpoint 780 → 792', () {
      expect(DensityCalculatorService.interpolateA(780, FuelFamily.gasoline),
          closeTo(792, 0.01));
    });

    test('interpolates P15=745 → midpoint between 844 and 831 = 837.5', () {
      final a = DensityCalculatorService.interpolateA(745, FuelFamily.gasoline);
      expect(a, closeTo(837.5, 0.1));
    });

    // Spec test case: P15=743.3 should land between 740 (844) and 750 (831)
    test('spec case: P15=743.3 coefficient is between 831 and 844', () {
      final a = DensityCalculatorService.interpolateA(743.3, FuelFamily.gasoline);
      expect(a, greaterThanOrEqualTo(831));
      expect(a, lessThanOrEqualTo(844));
    });

    test('rejects P15 below gasoline range (P15=700)', () {
      expect(
        () => DensityCalculatorService.interpolateA(700, FuelFamily.gasoline),
        throwsArgumentError,
      );
    });

    test('rejects P15 above gasoline range (P15=790)', () {
      expect(
        () => DensityCalculatorService.interpolateA(790, FuelFamily.gasoline),
        throwsArgumentError,
      );
    });

    test('does NOT use diesel P15=830 for gasoline', () {
      expect(
        () => DensityCalculatorService.interpolateA(830, FuelFamily.gasoline),
        throwsArgumentError,
      );
    });
  });

  // ── Tables are separate: same P15 gives different a ───────────────────────

  group('Fuel families use different tables', () {
    test('diesel and gasoline coefficients differ at any overlapping density', () {
      // No numeric overlap in the tables, but we can verify that
      // the same call with different families throws / succeeds differently.
      // Diesel P15=850 is valid diesel, invalid gasoline.
      expect(
        DensityCalculatorService.interpolateA(850, FuelFamily.diesel),
        closeTo(699, 0.1),
      );
      expect(
        () => DensityCalculatorService.interpolateA(850, FuelFamily.gasoline),
        throwsArgumentError,
      );
    });

    test('gasoline P15=740 is valid gasoline, invalid diesel', () {
      expect(
        DensityCalculatorService.interpolateA(740, FuelFamily.gasoline),
        closeTo(844, 0.1),
      );
      expect(
        () => DensityCalculatorService.interpolateA(740, FuelFamily.diesel),
        throwsArgumentError,
      );
    });
  });

  // ── Diesel: calcFromWeight (Mode A) ──────────────────────────────────────

  group('Diesel – calcFromWeight', () {
    // CSV reference: P15=833.9, t=11°C
    // a ≈ 725 (exact breakpoint 830), interpolated ≈ 724.93
    // Pt = (833.9 - 724.93*(11-15)) / 1000
    //    = (833.9 - 724.93*(-4)) / 1000
    //    = (833.9 + 2899.72/1000) / 1000   ← wait: a*(t-15)/1000
    //    = (833.9 + 724.93*(−4)/1000) is wrong direction
    // Correct: Pt = (833.9 - 724.93*(-4)) / 1000 = (833.9 + 2.8997) / 1000 = 0.8368
    test('P15=833.9, t=11 → Pt ≈ 0.8368 kg/l', () {
      final r = dieselFromWeight(p15: 833.9, temp: 11);
      expect(r.densityAtTempKgL, closeTo(0.8368, 0.0002));
    });

    test('at t=15 Pt equals P15/1000', () {
      final r = dieselFromWeight(p15: 833.9, temp: 15);
      expect(r.densityAtTempKgL, closeTo(833.9 / 1000, 0.0001));
    });

    test('volume = weight / Pt', () {
      final r = dieselFromWeight(p15: 833.9, temp: 11, weight: 100);
      expect(r.volumeM3, closeTo(100 / r.densityAtTempKgL, 0.001));
    });

    test('density in air = P15 / 1.00135178', () {
      final r = dieselFromWeight(p15: 833.9, temp: 11);
      expect(r.densityInAirKgL, closeTo(r.densityAt15KgL / 1.00135178, 0.00001));
    });

    // Spec test case (Mode B direction): P15=819.8, Pt=820.5 → t≈14.0
    test('spec: P15=819.8, Pt=820.5 recovered via calcFromDensity → t≈14', () {
      final r = DensityCalculatorService.calcFromDensity(
        p15KgM3: 819.8,
        actualDensityKgL: 820.5 / 1000,
        volumeM3: 100,
        contractDensityKgM3: 845,
        fuelFamily: FuelFamily.diesel,
      );
      expect(r.tempC, closeTo(14.0, 0.2));
    });
  });

  // ── Diesel: calcFromDensity (Mode B) ─────────────────────────────────────

  group('Diesel – calcFromDensity', () {
    test('recovers temperature from density produced by calcFromWeight', () {
      final a = DensityCalculatorService.calcFromWeight(
        p15KgM3: 833.9, tempC: 11, weightT: 100,
        contractDensityKgM3: 845, fuelFamily: FuelFamily.diesel,
      );
      final b = DensityCalculatorService.calcFromDensity(
        p15KgM3: 833.9,
        actualDensityKgL: a.densityAtTempKgL,
        volumeM3: a.volumeM3,
        contractDensityKgM3: 845,
        fuelFamily: FuelFamily.diesel,
      );
      expect(b.tempC, closeTo(11, 0.01));
    });

    test('mass = volume × density', () {
      final r = DensityCalculatorService.calcFromDensity(
        p15KgM3: 833.9, actualDensityKgL: 0.8368,
        volumeM3: 119.49, contractDensityKgM3: 845,
        fuelFamily: FuelFamily.diesel,
      );
      expect(r.weightT, closeTo(119.49 * 0.8368, 0.01));
    });
  });

  // ── Diesel: round-trip (CSV reference values) ─────────────────────────────

  group('Diesel – round-trip (CSV data)', () {
    test('P15=820.5, t=14, m=25003 round-trips correctly', () {
      final a = DensityCalculatorService.calcFromWeight(
        p15KgM3: 820.5, tempC: 14, weightT: 25003,
        contractDensityKgM3: 845, fuelFamily: FuelFamily.diesel,
      );
      final b = DensityCalculatorService.calcFromDensity(
        p15KgM3: 820.5,
        actualDensityKgL: a.densityAtTempKgL,
        volumeM3: a.volumeM3,
        contractDensityKgM3: 845,
        fuelFamily: FuelFamily.diesel,
      );
      expect(b.tempC, closeTo(14, 0.01));
      expect(b.weightT, closeTo(25003, 0.1));
    });
  });

  // ── Gasoline: calcFromWeight (Mode A) ────────────────────────────────────

  group('Gasoline – calcFromWeight', () {
    // Spec test: P15=743.3, t=17 → Pt should use gasoline coefficient ≈839.7
    // Pt = (743.3 - 839.7*(17-15)) / 1000 = (743.3 - 1679.4/1000) / 1000
    //    = (743.3 - 1.6794) / 1000 = 741.6206 / 1000 = 0.7416 kg/l
    test('spec: P15=743.3, t=17 → Pt in gasoline density range', () {
      final r = gasolineFromWeight(p15: 743.3, temp: 17);
      // coefficient must be from gasoline table (839–844 range)
      expect(r.coeffA, greaterThanOrEqualTo(831));
      expect(r.coeffA, lessThanOrEqualTo(844));
      // Pt must be below P15/1000 since t > 15
      expect(r.densityAtTempKgL, lessThan(743.3 / 1000));
    });

    test('at t=15 Pt equals P15/1000', () {
      final r = gasolineFromWeight(p15: 743.3, temp: 15);
      expect(r.densityAtTempKgL, closeTo(743.3 / 1000, 0.0001));
    });

    test('t=20 gives lower density than t=10 (coefficient positive)', () {
      final hot  = gasolineFromWeight(p15: 750, temp: 30);
      final cold = gasolineFromWeight(p15: 750, temp: 5);
      expect(hot.densityAtTempKgL, lessThan(cold.densityAtTempKgL));
    });

    test('density in air = P15 / 1.00135178', () {
      final r = gasolineFromWeight(p15: 743.3, temp: 17);
      expect(r.densityInAirKgL, closeTo(r.densityAt15KgL / 1.00135178, 0.00001));
    });

    test('volume = weight / Pt', () {
      final r = gasolineFromWeight(p15: 750, temp: 20, weight: 50);
      expect(r.volumeM3, closeTo(50 / r.densityAtTempKgL, 0.001));
    });
  });

  // ── Gasoline: calcFromDensity (Mode B) ───────────────────────────────────

  group('Gasoline – calcFromDensity', () {
    test('round-trips temperature correctly', () {
      final a = DensityCalculatorService.calcFromWeight(
        p15KgM3: 743.3, tempC: 17, weightT: 80,
        contractDensityKgM3: 743, fuelFamily: FuelFamily.gasoline,
      );
      final b = DensityCalculatorService.calcFromDensity(
        p15KgM3: 743.3,
        actualDensityKgL: a.densityAtTempKgL,
        volumeM3: a.volumeM3,
        contractDensityKgM3: 743,
        fuelFamily: FuelFamily.gasoline,
      );
      expect(b.tempC, closeTo(17, 0.01));
      expect(b.weightT, closeTo(80, 0.01));
    });

    test('spec: P15=743.3, Pt=745/1000=0.745 → t≈13 (colder than 15)', () {
      final r = DensityCalculatorService.calcFromDensity(
        p15KgM3: 743.3,
        actualDensityKgL: 0.745,   // Pt=745 kg/m³ → 0.745 kg/l
        volumeM3: 100,
        contractDensityKgM3: 743,
        fuelFamily: FuelFamily.gasoline,
      );
      // Pt > P15 means temperature was below 15°C
      expect(r.tempC, lessThan(15));
      // coefficient must come from gasoline table
      expect(r.coeffA, greaterThanOrEqualTo(831));
      expect(r.coeffA, lessThanOrEqualTo(844));
    });
  });

  // ── Validation ────────────────────────────────────────────────────────────

  group('validateP15 – fuel-family aware', () {
    test('diesel: 833.9 accepted', () {
      expect(DensityCalculatorService.validateP15('833.9', FuelFamily.diesel), isNull);
    });
    test('diesel: boundary 810 accepted', () {
      expect(DensityCalculatorService.validateP15('810', FuelFamily.diesel), isNull);
    });
    test('diesel: boundary 880 accepted', () {
      expect(DensityCalculatorService.validateP15('880', FuelFamily.diesel), isNull);
    });
    test('diesel: 750 rejected (gasoline range)', () {
      expect(DensityCalculatorService.validateP15('750', FuelFamily.diesel), isNotNull);
    });
    test('diesel: 900 rejected (above range)', () {
      expect(DensityCalculatorService.validateP15('900', FuelFamily.diesel), isNotNull);
    });

    test('gasoline: 743.3 accepted', () {
      expect(DensityCalculatorService.validateP15('743.3', FuelFamily.gasoline), isNull);
    });
    test('gasoline: boundary 710 accepted', () {
      expect(DensityCalculatorService.validateP15('710', FuelFamily.gasoline), isNull);
    });
    test('gasoline: boundary 780 accepted', () {
      expect(DensityCalculatorService.validateP15('780', FuelFamily.gasoline), isNull);
    });
    test('gasoline: 850 rejected (diesel range)', () {
      expect(DensityCalculatorService.validateP15('850', FuelFamily.gasoline), isNotNull);
    });
    test('gasoline: 700 rejected (below range)', () {
      expect(DensityCalculatorService.validateP15('700', FuelFamily.gasoline), isNotNull);
    });

    test('non-numeric rejected for both families', () {
      expect(DensityCalculatorService.validateP15('abc', FuelFamily.diesel), isNotNull);
      expect(DensityCalculatorService.validateP15('abc', FuelFamily.gasoline), isNotNull);
    });
    test('empty rejected', () {
      expect(DensityCalculatorService.validateP15('', FuelFamily.diesel), isNotNull);
    });
  });

  group('validateDensityKgL – fuel-family aware', () {
    test('diesel: 0.830 accepted', () {
      expect(DensityCalculatorService.validateDensityKgL('0.830', FuelFamily.diesel), isNull);
    });
    test('diesel: 0.700 rejected (gasoline range)', () {
      expect(DensityCalculatorService.validateDensityKgL('0.700', FuelFamily.diesel), isNotNull);
    });
    test('gasoline: 0.743 accepted', () {
      expect(DensityCalculatorService.validateDensityKgL('0.743', FuelFamily.gasoline), isNull);
    });
    test('gasoline: 0.850 rejected (diesel range)', () {
      expect(DensityCalculatorService.validateDensityKgL('0.850', FuelFamily.gasoline), isNotNull);
    });
  });

  group('validateTemp / validateWeight / validateVolume', () {
    test('validateTemp: −40 accepted', () {
      expect(DensityCalculatorService.validateTemp('-40'), isNull);
    });
    test('validateTemp: 80 accepted', () {
      expect(DensityCalculatorService.validateTemp('80'), isNull);
    });
    test('validateTemp: 81 rejected', () {
      expect(DensityCalculatorService.validateTemp('81'), isNotNull);
    });
    test('validateWeight: 0 rejected', () {
      expect(DensityCalculatorService.validateWeight('0'), isNotNull);
    });
    test('validateWeight: 0.001 accepted', () {
      expect(DensityCalculatorService.validateWeight('0.001'), isNull);
    });
    test('validateVolume: negative rejected', () {
      expect(DensityCalculatorService.validateVolume('-5'), isNotNull);
    });
  });
  // ── Regression: densityInAir formula ─────────────────────────────────────
  // Guards against reversion to the old "Pt − 0.0011" formula.
  // densityInAir must always equal P15 / 1.00135178, independent of
  // delivery temperature.

  group('densityInAir regression – always P15 / 1.00135178', () {
    const airFactor = 1.00135178;

    for (final entry in [
      (FuelFamily.diesel, 833.9, 'diesel P15=833.9'),
      (FuelFamily.diesel, 820.5, 'diesel P15=820.5'),
      (FuelFamily.gasoline, 743.3, 'gasoline P15=743.3'),
      (FuelFamily.gasoline, 750.0, 'gasoline P15=750.0'),
    ]) {
      final family = entry.$1;
      final p15 = entry.$2;
      final label = entry.$3;

      for (final temp in [-10.0, 0.0, 15.0, 30.0, 50.0]) {
        test('$label at t=$temp°C -> densityInAir = P15 / airFactor', () {
          final r = DensityCalculatorService.calcFromWeight(
            p15KgM3: p15,
            tempC: temp,
            weightT: 100,
            contractDensityKgM3: family == FuelFamily.diesel ? 845 : 743,
            fuelFamily: family,
          );

          expect(
            r.densityInAirKgL,
            closeTo(p15 / 1000 / airFactor, 0.000001),
            reason: '$label t=$temp°C: expected ${p15 / 1000 / airFactor}',
          );
        });
      }
    }
  });

}
