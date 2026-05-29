/// Одна точка на кривой плотность/температура.
/// Иммутабельный value object. Не содержит бизнес-логику.
class DensityPoint {
  /// Температура, °C
  final double tempC;

  /// Плотность при данной температуре, kg/l
  final double densityKgL;

  const DensityPoint({required this.tempC, required this.densityKgL});

  /// Плотность в kg/m³ (для отображения)
  double get densityKgM3 => densityKgL * 1000;

  @override
  String toString() =>
      'DensityPoint(t=${tempC.toStringAsFixed(1)}°C, '
      'ρ=${densityKgL.toStringAsFixed(4)} kg/l)';

  @override
  bool operator ==(Object other) =>
      other is DensityPoint &&
      other.tempC == tempC &&
      other.densityKgL == densityKgL;

  @override
  int get hashCode => Object.hash(tempC, densityKgL);
}
