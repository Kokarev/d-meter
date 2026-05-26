import '../../core/fuel_grade.dart';

class DensityMemory {
  static FuelFamily? family;
  static double? p15VacKgM3;

  static double? get p15VacKgL =>
      p15VacKgM3 == null ? null : p15VacKgM3! / 1000;

  static void setP15KgM3(double value, FuelFamily fuelFamily) {
    p15VacKgM3 = value;
    family = fuelFamily;
  }

  static void setP15KgL(double value, FuelFamily fuelFamily) {
    p15VacKgM3 = value * 1000;
    family = fuelFamily;
  }

  static void clear() {
    p15VacKgM3 = null;
    family = null;
  }
}
