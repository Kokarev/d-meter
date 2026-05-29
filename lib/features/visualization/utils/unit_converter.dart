enum UnitSystem { metric, us }

abstract final class UnitConverter {
  static const double m3PerBbl = 0.158987;
  static const double bblPerM3 = 1.0 / m3PerBbl;

  static double m3ToBbl(double m3)  => m3 * bblPerM3;
  static double bblToM3(double bbl) => bbl * m3PerBbl;

  static const double shortTonsPerTonne = 1.10231;
  static double tonnesToShortTons(double t) => t * shortTonsPerTonne;

  // API gravity: SG at 60°F/60°F; water at 60°F ≈ 0.9991 kg/l
  static double kglToApi(double densityKgL) {
    if (densityKgL <= 0) return 0;
    final sg = densityKgL / 0.9991;
    return 141.5 / sg - 131.5;
  }

  static double apiToKgl(double api) {
    if (api <= -131.5) return 0;
    final sg = 141.5 / (api + 131.5);
    return sg * 0.9991;
  }

  static double cToF(double c) => c * 9 / 5 + 32;
  static double fToC(double f) => (f - 32) * 5 / 9;
  static double lToBbl(double liters) => liters / 158.987;

  // ── Formatted strings ─────────────────────────────────────────────────────

  static String formatDensity(double kgl, UnitSystem sys) {
    if (sys == UnitSystem.us) return '${kglToApi(kgl).toStringAsFixed(1)}°';
    return kgl.toStringAsFixed(4);
  }
  static String densityUnit(UnitSystem sys) =>
      sys == UnitSystem.us ? '°API' : 'kg/l';

  static String formatVolume(double m3, UnitSystem sys) {
    if (sys == UnitSystem.us) {
      final b = m3ToBbl(m3);
      return b >= 1000 ? b.toStringAsFixed(0) : b.toStringAsFixed(1);
    }
    return m3.toStringAsFixed(3);
  }
  static String volumeUnit(UnitSystem sys) =>
      sys == UnitSystem.us ? 'bbl' : 'm³';

  static String formatMass(double t, UnitSystem sys) {
    if (sys == UnitSystem.us) return tonnesToShortTons(t).toStringAsFixed(1);
    return t.toStringAsFixed(3);
  }
  static String massUnit(UnitSystem sys) =>
      sys == UnitSystem.us ? 'ST' : 't';

  static String formatTemp(double c, UnitSystem sys) {
    if (sys == UnitSystem.us) return '${cToF(c).toStringAsFixed(1)} °F';
    return '${c.toStringAsFixed(1)} °C';
  }
  static String tempUnit(UnitSystem sys) =>
      sys == UnitSystem.us ? '°F' : '°C';
  static String refTemp(UnitSystem sys) =>
      sys == UnitSystem.us ? '60°F' : '15°C';

  static String formatExpansion(double liters, UnitSystem sys) {
    final sign = liters >= 0 ? '+' : '';
    if (sys == UnitSystem.us) {
      return '$sign${lToBbl(liters).toStringAsFixed(2)}';
    }
    return '$sign${liters.toStringAsFixed(1)}';
  }
  static String expansionUnit(UnitSystem sys) =>
      sys == UnitSystem.us ? 'bbl vs 60°F' : 'L vs 15°C';
}
