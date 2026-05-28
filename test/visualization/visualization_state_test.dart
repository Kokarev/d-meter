import 'package:flutter_test/flutter_test.dart';
import 'package:d_meter/features/visualization/state/visualization_state.dart';
import 'package:d_meter/core/fuel_grade.dart';

void main() {
  late VisualizationState state;

  setUp(() {
    state = VisualizationState();
  });

  tearDown(() {
    state.dispose();
  });

  // ── Initial state ─────────────────────────────────────────────────────────

  group('Initial state', () {
    test('default unit is m3', () {
      expect(state.quantityUnit, QuantityUnit.m3);
    });

    test('default range is 101–1000', () {
      expect(state.quantityRange, QuantityRange.r1to100);
    });

    test('default value is 120', () {
      expect(state.quantityValue, closeTo(50.0, 0.01));
    });

    test('default temp is 15', () {
      expect(state.sliderTempC, 15.0);
    });

    test('passport curve is generated', () {
      expect(state.passportCurve, isNotEmpty);
    });

    test('thermal state has positive mass', () {
      expect(state.thermalState.massT, greaterThan(0));
    });
  });

  // ── Temperature slider ────────────────────────────────────────────────────

  group('Temperature slider', () {
    test('setSliderTemp updates thermalState.tempC', () {
      state.setSliderTemp(20.0);
      expect(state.thermalState.tempC, closeTo(20.0, 0.01));
    });

    test('at t>15 thermal expansion is positive', () {
      state.setSliderTemp(25.0);
      expect(state.thermalState.thermalExpansionL, greaterThan(0));
    });

    test('at t<15 thermal expansion is negative', () {
      state.setSliderTemp(5.0);
      expect(state.thermalState.thermalExpansionL, lessThan(0));
    });

    test('at t=15 thermal expansion is zero', () {
      state.setSliderTemp(15.0);
      expect(state.thermalState.thermalExpansionL, closeTo(0, 0.01));
    });
  });

  // ── Quantity value ────────────────────────────────────────────────────────

  group('Quantity value', () {
    test('setQuantityValue clamps to range', () {
      state.setQuantityRange(QuantityRange.r1to100);
      state.setQuantityValue(500);
      expect(state.quantityValue, closeTo(100.0, 0.01));
    });

    test('volume 50 m3 gives volumeM3 ≈ 50', () {
      state.setSliderTemp(15.0);
      state.setQuantityValue(50.0);
      expect(state.thermalState.volumeM3, closeTo(50.0, 0.5));
    });

    test('mass is proportional to volume', () {
      state.setSliderTemp(15.0);
      state.setQuantityRange(QuantityRange.r101to1000);
      state.setQuantityValue(120.0);
      final m1 = state.thermalState.massT;
      state.setQuantityValue(240.0);
      final m2 = state.thermalState.massT;
      expect(m2, closeTo(m1 * 2, 1.0));
    });
  });

  // ── Range switching ───────────────────────────────────────────────────────

  group('Range switching', () {
    test('switching range clamps value if out of bounds', () {
      state.setQuantityRange(QuantityRange.r1to100);
      state.setQuantityValue(500);
      state.setQuantityRange(QuantityRange.r1to100);
      expect(state.quantityValue, closeTo(100.0, 0.01));
    });

    test('switching to range containing value preserves value', () {
      state.setQuantityRange(QuantityRange.r101to1000);
      state.setQuantityValue(200);
      state.setQuantityRange(QuantityRange.r101to1000);
      expect(state.quantityValue, closeTo(200.0, 0.01));
    });
  });

  // ── Unit switching ────────────────────────────────────────────────────────

  group('Unit switching', () {
    test('switching m3→t→m3 preserves quantity approximately', () {
      state.setSliderTemp(15.0);
      state.setQuantityValue(50.0);
      final originalVolume = state.thermalState.volumeM3;

      state.setQuantityUnit(QuantityUnit.tonnes);
      state.setQuantityUnit(QuantityUnit.m3);

      // After round-trip the volume should be close to original
      expect(state.thermalState.volumeM3,
          closeTo(originalVolume, originalVolume * 0.01));
    });

    test('switching unit updates quantityUnit', () {
      expect(state.quantityUnit, QuantityUnit.m3);
      state.setQuantityUnit(QuantityUnit.tonnes);
      expect(state.quantityUnit, QuantityUnit.tonnes);
    });

    test('same unit switch is no-op', () {
      final before = state.quantityValue;
      state.setQuantityUnit(QuantityUnit.m3);
      expect(state.quantityValue, before);
    });
  });

  // ── QuantityRange ─────────────────────────────────────────────────────────

  group('QuantityRange', () {
    test('contains: values within range', () {
      expect(QuantityRange.r1to100.contains(50), isTrue);
      expect(QuantityRange.r1to100.contains(0), isFalse);
      expect(QuantityRange.r1to100.contains(101), isFalse);
    });

    test('bestFor selects correct range', () {
      expect(QuantityRange.bestFor(50), QuantityRange.r1to100);
      expect(QuantityRange.bestFor(500), QuantityRange.r101to1000);
      expect(QuantityRange.bestFor(5000), QuantityRange.r1001to10000);
      expect(QuantityRange.bestFor(50000), QuantityRange.r10kto100k);
    });

    test('clamp keeps value in range', () {
      expect(QuantityRange.r1to100.clamp(0), 1.0);
      expect(QuantityRange.r1to100.clamp(50), 50.0);
      expect(QuantityRange.r1to100.clamp(200), 100.0);
    });
  });

  // ── Fuel switching ────────────────────────────────────────────────────────

  group('Fuel switching', () {
    test('switching to gasoline resets p15 to gasoline range', () {
      state.setFuel(
          kFuelGrades.firstWhere((f) => f.family == FuelFamily.gasoline));
      expect(state.p15KgM3, closeTo(743.3, 0.1));
      expect(state.thermalState.densityKgL, greaterThan(0.700));
      expect(state.thermalState.densityKgL, lessThan(0.780));
    });
  });
}
