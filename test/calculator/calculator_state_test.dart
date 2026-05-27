import 'package:flutter_test/flutter_test.dart';
import 'package:d_meter/features/calculator/state/calculator_state.dart';
import 'package:d_meter/core/fuel_grade.dart';
import 'package:d_meter/shared/state/density_memory.dart';

void main() {
  group('CalculatorState', () {
    late CalculatorState state;

    setUp(() {
      DensityMemory.clear();
      state = CalculatorState();
    });

    tearDown(() {
      state.dispose();
      DensityMemory.clear();
    });

    test('initial mode is densityAtTemp', () {
      expect(state.mode, CalcMode.densityAtTemp);
    });

    test('initial state produces a valid result', () {
      expect(state.result, isNull);
    });

    test('switching mode clears result', () {
      state.setMode(CalcMode.tempAtDensity);
      expect(state.mode, CalcMode.tempAtDensity);
    });

    test('updating fuel triggers recalculation', () {
      final before = state.result?.contractDensityKgL;
      state.setFuel(kFuelGrades[1]);
      final after = state.result?.contractDensityKgL;
      expect(before, isNot(equals(after)));
    });

    test('invalid P15 clears result', () {
      state.updateField('p15', 'abc');
      state.calculateNow();

      expect(state.result, isNull);
      expect(state.errors['p15'], isNotNull);
    });

    test('out-of-range temp clears result', () {
      state.updateField('temp', '999');
      state.calculateNow();

      expect(state.result, isNull);
      expect(state.errors['temp'], isNotNull);
    });

    test('toggleDetails flips detailsOpen', () {
      expect(state.detailsOpen, isFalse);
      state.toggleDetails();
      expect(state.detailsOpen, isTrue);
      state.toggleDetails();
      expect(state.detailsOpen, isFalse);
    });

    test('mode B requires density and volume fields', () {
      state.setMode(CalcMode.tempAtDensity);
      state.updateField('p15', '833.9');
      state.updateField('density', '0.8368');
      state.updateField('volume', '119.49');
      state.calculateNow();

      expect(state.result, isNotNull);
      expect(state.errors.values.any((e) => e != null), isFalse);
    });
  });
}
