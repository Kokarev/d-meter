import '../../../core/fuel_grade.dart';

/// Одна партия топлива для смешивания.
class FuelBatch {
  final FuelFamily family;
  final double volumeM3;
  final double p15KgM3;
  final double actualDensityKgL;
  final double tempC;

  const FuelBatch({
    required this.family,
    required this.volumeM3,
    required this.p15KgM3,
    required this.actualDensityKgL,
    required this.tempC,
  });

  double get massT           => volumeM3 * actualDensityKgL;
  double get densityAt15KgL  => p15KgM3 / 1000;
}

/// Результат смешивания двух партий.
class MixtureResult {
  final double totalVolumeM3;
  final double totalMassT;
  final double mixedDensityAt15KgL;
  final double mixedActualDensityKgL;
  final double mixedTempC;

  const MixtureResult({
    required this.totalVolumeM3,
    required this.totalMassT,
    required this.mixedDensityAt15KgL,
    required this.mixedActualDensityKgL,
    required this.mixedTempC,
  });
}
