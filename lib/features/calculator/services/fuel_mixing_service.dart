// ─────────────────────────────────────────────────────────────────────────────
// FuelMixingService — Phase 3
//
// Смешивание двух партий топлива по методу взвешенного среднего по массе.
// Работает только с одинаковым типом топлива.
// ─────────────────────────────────────────────────────────────────────────────

import '../models/fuel_mixture.dart';

class FuelMixingService {
  /// Рассчитывает результат смешивания двух партий.
  /// Выбрасывает [ArgumentError] если партии разного типа.
  static MixtureResult mix(FuelBatch batchA, FuelBatch batchB) {
    if (batchA.family != batchB.family) {
      throw ArgumentError(
        'Cannot mix ${batchA.family.name} and ${batchB.family.name}.',
      );
    }

    final massA  = batchA.massT;
    final massB  = batchB.massT;
    final total  = massA + massB;

    if (total <= 0) throw ArgumentError('Total mass must be > 0');

    final mixedD15     = (massA * batchA.densityAt15KgL +
                          massB * batchB.densityAt15KgL) / total;
    final mixedActual  = (massA * batchA.actualDensityKgL +
                          massB * batchB.actualDensityKgL) / total;
    final totalVolume  = total / mixedActual;
    final mixedTemp    = (massA * batchA.tempC +
                          massB * batchB.tempC) / total;

    return MixtureResult(
      totalVolumeM3:         totalVolume,
      totalMassT:            total,
      mixedDensityAt15KgL:   mixedD15,
      mixedActualDensityKgL: mixedActual,
      mixedTempC:            mixedTemp,
    );
  }

  /// Валидация двух партий перед смешиванием.
  /// Возвращает null если ОК, строку ошибки если нет.
  static String? validate(FuelBatch? a, FuelBatch? b) {
    if (a == null || b == null) return 'Both batches must be filled';
    if (a.volumeM3 <= 0 || b.volumeM3 <= 0) return 'Volume must be > 0';
    if (a.family != b.family) {
      return 'Different fuel types: ${a.family.name} and ${b.family.name}';
    }
    return null;
  }
}
