/// Операционное состояние при заданной температуре.
///
/// Масса инвариантна — volume и density меняются при сдвиге t.
class ThermalState {
  final double tempC;
  final double densityKgL;
  final double volumeM3;
  final double massT;
  final double densityAt15KgL;

  /// Тепловое расширение vs 15°C, литры.
  /// Положительное = расширение (t > 15), отрицательное = сжатие (t < 15).
  final double thermalExpansionL;

  const ThermalState({
    required this.tempC,
    required this.densityKgL,
    required this.volumeM3,
    required this.massT,
    required this.densityAt15KgL,
    required this.thermalExpansionL,
  });

  /// Объём при 15°C для сравнения
  double get volumeAt15M3 => massT / densityAt15KgL;
}
