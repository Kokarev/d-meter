// ─────────────────────────────────────────────────────────────────────────────
// DensityCurveService
//
// Генерирует данные для графика и рассчитывает ThermalState.
//
// ВАЖНО: не дублирует формулы — вся математика остаётся в
// DensityCalculatorService. Этот сервис только вызывает interpolateA()
// и применяет стандартную формулу EN ISO 91-1.
// ─────────────────────────────────────────────────────────────────────────────

import '../../../core/fuel_grade.dart';
import '../models/density_point.dart';
import '../models/thermal_state.dart';
import '../service/density_calculator_service.dart';

class DensityCurveService {
  /// Генерирует кривую плотности для диапазона температур.
  ///
  /// Формула: Pt_kgm3 = P15_kgm3 − a × (t − 15) / 1000
  ///
  /// [p15KgM3]  — паспортная плотность при 15°C, kg/m³
  /// [family]   — тип топлива
  /// [tempFrom] — начало диапазона, °C (default −10)
  /// [tempTo]   — конец диапазона, °C  (default 50)
  /// [step]     — шаг кривой, °C       (default 1)
  static List<DensityPoint> generateCurve({
    required double p15KgM3,
    required FuelFamily family,
    double tempFrom = -10,
    double tempTo   =  50,
    double step     =   1,
  }) {
    assert(tempFrom < tempTo, 'tempFrom должен быть меньше tempTo');
    assert(step > 0, 'step должен быть положительным');

    final a      = DensityCalculatorService.interpolateA(p15KgM3, family);
    final points = <DensityPoint>[];

    var t = tempFrom;
    while (t <= tempTo + 0.001) {
      final ptKgM3 = p15KgM3 - a * (t - 15) / 1000;
      points.add(DensityPoint(tempC: t, densityKgL: ptKgM3 / 1000));
      t = double.parse((t + step).toStringAsFixed(6));
    }
    return points;
  }

  /// Рассчитывает [ThermalState] при заданной температуре.
  /// [massT] фиксирована — объём и плотность пересчитываются.
  static ThermalState computeThermalState({
    required double p15KgM3,
    required FuelFamily family,
    required double tempC,
    required double massT,
  }) {
    final a            = DensityCalculatorService.interpolateA(p15KgM3, family);
    final ptKgM3       = p15KgM3 - a * (tempC - 15) / 1000;
    final ptKgL        = ptKgM3 / 1000;
    final volumeM3     = massT / ptKgL;
    final densAt15KgL  = p15KgM3 / 1000;
    final volAt15M3    = massT / densAt15KgL;
    final expansionL   = (volumeM3 - volAt15M3) * 1000;

    return ThermalState(
      tempC:             tempC,
      densityKgL:        ptKgL,
      volumeM3:          volumeM3,
      massT:             massT,
      densityAt15KgL:    densAt15KgL,
      thermalExpansionL: expansionL,
    );
  }

  /// Диапазон плотностей кривой для масштабирования оси Y.
  static ({double min, double max}) densityRange(List<DensityPoint> curve) {
    if (curve.isEmpty) return (min: 0.8, max: 0.9);
    final vals   = curve.map((p) => p.densityKgL);
    final minVal = vals.reduce((a, b) => a < b ? a : b);
    final maxVal = vals.reduce((a, b) => a > b ? a : b);
    final pad    = (maxVal - minVal) * 0.05;
    return (min: minVal - pad, max: maxVal + pad);
  }
}
