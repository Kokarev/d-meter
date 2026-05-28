import '../../../core/fuel_grade.dart';
import '../models/density_point.dart';
import '../models/thermal_state.dart';
import '../service/density_calculator_service.dart';

class DensityCurveService {
  static List<DensityPoint> generateCurve({
    required double p15KgM3,
    required FuelFamily family,
    double tempFrom = -10,
    double tempTo = 50,
    double step = 1,
  }) {
    assert(tempFrom <= tempTo, 'tempFrom должен быть меньше или равен tempTo');
    assert(step > 0, 'step должен быть положительным');

    final a = DensityCalculatorService.interpolateA(p15KgM3, family);
    final points = <DensityPoint>[];

    final count = ((tempTo - tempFrom) / step).round();

    for (var i = 0; i <= count; i++) {
      final t = double.parse((tempFrom + i * step).toStringAsFixed(6));
      final ptKgM3 = p15KgM3 - a * (t - 15) / 1000;
      points.add(DensityPoint(tempC: t, densityKgL: ptKgM3 / 1000));
    }

    return points;
  }

  static ThermalState computeThermalState({
    required double p15KgM3,
    required FuelFamily family,
    required double tempC,
    required double massT,
  }) {
    final a = DensityCalculatorService.interpolateA(p15KgM3, family);
    final ptKgM3 = p15KgM3 - a * (tempC - 15) / 1000;
    final ptKgL = ptKgM3 / 1000;

    final safeDensity = ptKgL > 0 ? ptKgL : 0.001;
    final safeMass = massT > 0 ? massT : 0.001;

    final volumeM3 = safeMass / safeDensity;
    final densAt15KgL = p15KgM3 / 1000;
    final volAt15M3 = safeMass / densAt15KgL;
    final expansionL = (volumeM3 - volAt15M3) * 1000;

    return ThermalState(
      tempC: tempC,
      densityKgL: safeDensity,
      volumeM3: volumeM3,
      massT: safeMass,
      densityAt15KgL: densAt15KgL,
      thermalExpansionL: expansionL,
    );
  }

  static ({double min, double max}) densityRange(List<DensityPoint> curve) {
    if (curve.isEmpty) return (min: 0.8, max: 0.9);

    final vals = curve.map((p) => p.densityKgL);
    final minVal = vals.reduce((a, b) => a < b ? a : b);
    final maxVal = vals.reduce((a, b) => a > b ? a : b);
    final rawPad = (maxVal - minVal) * 0.08;
    final pad = rawPad < 0.003 ? 0.003 : rawPad;

    return (min: minVal - pad, max: maxVal + pad);
  }
}
