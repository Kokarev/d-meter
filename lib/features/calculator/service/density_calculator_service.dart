// ─────────────────────────────────────────────────────────────────────────────
// DensityCalculatorService
//
// Implements EN ISO 91-1 / EN ISO 12185 density-temperature correction.
//
// Formulas (all densities in kg/m³ internally; results exposed as kg/l):
//   Pt  = P15 − a × (t − 15) / 1000     [kg/m³]
//   t   = (P15 − Pt) × 1000 / a + 15    [°C]
//   V   = mass / (Pt / 1000)             [m³],  mass in tonnes
//   m   = V × (Pt / 1000)               [t]
//
// ── Correction coefficient tables (EN ISO 91-1 Table B) ──────────────────────
//
// Diesel / gasoil — density range 810–880 kg/m³:
//   P15   810  820  830  840  850  860  870  880
//   a     752  738  725  712  699  686  673  660
//
// Gasoline / petrol — density range 710–780 kg/m³:
//   P15   710  720  730  740  750  760  770  780
//   a     884  870  857  844  831  818  805  792
//
// These tables are DIFFERENT.  Diesel coefficients MUST NOT be used for
// gasoline and vice versa.  The correct table is selected via FuelFamily.
// ─────────────────────────────────────────────────────────────────────────────

import '../../../core/fuel_grade.dart';
import '../../../core/validation.dart';

// ─── Result ──────────────────────────────────────────────────────────────────

class DensityResult {
  final double densityAtTempKgL;    // Pt,  kg/l  — primary result
  final double densityAt15KgL;      // P15, kg/l
  final double densityInAirKgL;     // Pt − 0.0011  (buoyancy correction)
  final double contractDensityKgL;  // from fuel grade passport
  final double tempC;               // delivery temperature
  final double volumeM3;            // calculated or input
  final double weightT;             // calculated or input
  final double coeffA;              // interpolated a coefficient (raw integer value)

  const DensityResult({
    required this.densityAtTempKgL,
    required this.densityAt15KgL,
    required this.densityInAirKgL,
    required this.contractDensityKgL,
    required this.tempC,
    required this.volumeM3,
    required this.weightT,
    required this.coeffA,
  });
}

// ─── Service ─────────────────────────────────────────────────────────────────

class DensityCalculatorService {
  static const double airFactor = 1.00135178;

  // ── Coefficient tables ─────────────────────────────────────────────────────
  // Each entry: (P15 breakpoint in kg/m³, a coefficient as raw integer).
  // a is stored as the integer from the standard table (e.g. 752, not 0.752).
  // Usage in formula: Pt = P15 - a*(t-15)/1000

  static const List<(double, double)> _dieselTable = [
    (810, 752), (820, 738), (830, 725), (840, 712),
    (850, 699), (860, 686), (870, 673), (880, 660),
  ];

  static const List<(double, double)> _gasolineTable = [
    (710, 884), (720, 870), (730, 857), (740, 844),
    (750, 831), (760, 818), (770, 805), (780, 792),
  ];

  /// Returns the correction table for the given fuel family.
  static List<(double, double)> _tableFor(FuelFamily family) {
    return switch (family) {
      FuelFamily.diesel   => _dieselTable,
      FuelFamily.gasoline => _gasolineTable,
    };
  }

  // ── Interpolation ──────────────────────────────────────────────────────────

  /// Interpolates the correction coefficient for [p15KgM3] from the table
  /// that matches [family].
  ///
  /// Returns the raw integer coefficient (e.g. 738.0).
  ///
  /// Throws [ArgumentError] if [p15KgM3] is outside the valid range for
  /// the given fuel family — callers should validate before calling.
  static double interpolateA(double p15KgM3, FuelFamily family) {
    final table = _tableFor(family);
    final minP  = table.first.$1;
    final maxP  = table.last.$1;

    if (p15KgM3 < minP || p15KgM3 > maxP) {
      throw ArgumentError(
        'P15 $p15KgM3 kg/m³ is outside the ${family.name} table '
        'range [$minP, $maxP] kg/m³.',
      );
    }

    for (int i = 0; i < table.length - 1; i++) {
      final (double p0, double a0) = table[i];
      final (double p1, double a1) = table[i + 1];
      if (p15KgM3 >= p0 && p15KgM3 <= p1) {
        final frac = (p15KgM3 - p0) / (p1 - p0);
        return a0 + frac * (a1 - a0);
      }
    }
    // Unreachable after bounds check, but satisfies the type system.
    return table.last.$2;
  }

  // ── Mode A: P15 + temperature → density at temp ───────────────────────────

  /// Calculate density at delivery temperature.
  ///
  /// [p15KgM3]             — reference density at 15°C, kg/m³ (e.g. 833.9)
  /// [tempC]               — delivery temperature, °C          (e.g. 11.0)
  /// [weightT]             — cargo weight, tonnes              (e.g. 100.0)
  /// [contractDensityKgM3] — passport contract density, kg/m³
  /// [fuelFamily]          — selects diesel or gasoline coefficient table
  static DensityResult calcFromWeight({
    required double p15KgM3,
    required double tempC,
    required double weightT,
    required double contractDensityKgM3,
    required FuelFamily fuelFamily,
  }) {
    final a   = interpolateA(p15KgM3, fuelFamily);
    final ptKgM3 = p15KgM3 - a * (tempC - 15) / 1000;
    final pt = ptKgM3 / 1000; // kg/l
    final vol = weightT / pt;                          // m³
    return DensityResult(
      densityAtTempKgL:   pt,
      densityAt15KgL:     p15KgM3 / 1000,
      densityInAirKgL:    (p15KgM3 / 1000) / airFactor,
      contractDensityKgL: contractDensityKgM3 / 1000,
      tempC:              tempC,
      volumeM3:           vol,
      weightT:            weightT,
      coeffA:             a,
    );
  }

  // ── Mode B: P15 + actual density → temperature ────────────────────────────

  /// Calculate delivery temperature from actual density.
  ///
  /// [p15KgM3]             — reference density at 15°C, kg/m³
  /// [actualDensityKgL]    — measured density at delivery, kg/l
  /// [volumeM3]            — measured volume, m³
  /// [contractDensityKgM3] — passport contract density, kg/m³
  /// [fuelFamily]          — selects diesel or gasoline coefficient table
  static DensityResult calcFromDensity({
    required double p15KgM3,
    required double actualDensityKgL,
    required double volumeM3,
    required double contractDensityKgM3,
    required FuelFamily fuelFamily,
  }) {
    final a    = interpolateA(p15KgM3, fuelFamily);
    // t = (P15 - Pt*1000) * 1000 / a + 15  → simplified:
    final t = (p15KgM3 - actualDensityKgL * 1000) * 1000 / a + 15;
    final mass = volumeM3 * actualDensityKgL; // tonnes
    return DensityResult(
      densityAtTempKgL:   actualDensityKgL,
      densityAt15KgL:     p15KgM3 / 1000,
      densityInAirKgL:    (p15KgM3 / 1000) / airFactor,
      contractDensityKgL: contractDensityKgM3 / 1000,
      tempC:              t,
      volumeM3:           volumeM3,
      weightT:            mass,
      coeffA:             a,
    );
  }

  // ── Validation ────────────────────────────────────────────────────────────
  // Methods return ValidationError? (a typed value).
  // The UI converts to a localized string via ValidationErrorL10n.localize().

  /// Validates P15 against the correct table range for [family].
  static ValidationError? validateP15(String? raw, FuelFamily family) {
    if (raw == null || raw.trim().isEmpty) return const ValidationError.required();
    final v = double.tryParse(raw.replaceAll(',', '.'));
    if (v == null) return const ValidationError.notANumber();

    final table = _tableFor(family);
    final min   = table.first.$1;
    final max   = table.last.$1;
    if (v < min || v > max) {
      return ValidationError(
        ValidationErrorKind.densityKgM3OutOfRange,
        min: min.toStringAsFixed(0),
        max: max.toStringAsFixed(0),
        family: family.name,
      );
    }
    return null;
  }

  static ValidationError? validateTemp(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const ValidationError.required();
    final v = double.tryParse(raw.replaceAll(',', '.'));
    if (v == null) return const ValidationError.notANumber();
    if (v < -40 || v > 80) return const ValidationError.tempOutOfRange();
    return null;
  }

  static ValidationError? validateWeight(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const ValidationError.required();
    final v = double.tryParse(raw.replaceAll(',', '.'));
    if (v == null) return const ValidationError.notANumber();
    if (v <= 0) return const ValidationError.mustBePositive();
    return null;
  }

  /// Validates actual delivery density.
  /// Acceptable range is fuel-family specific:
  /// diesel 0.810–0.880 kg/l, gasoline 0.710–0.780 kg/l.
  static ValidationError? validateDensityKgL(String? raw, FuelFamily family) {
    if (raw == null || raw.trim().isEmpty) return const ValidationError.required();
    final v = double.tryParse(raw.replaceAll(',', '.'));
    if (v == null) return const ValidationError.notANumber();

    final table  = _tableFor(family);
    final minKgL = table.first.$1 / 1000;
    final maxKgL = table.last.$1  / 1000;
    if (v < minKgL || v > maxKgL) {
      return ValidationError(
        ValidationErrorKind.densityKgLOutOfRange,
        min: minKgL.toStringAsFixed(3),
        max: maxKgL.toStringAsFixed(3),
        family: family.name,
      );
    }
    return null;
  }

  static ValidationError? validateVolume(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const ValidationError.required();
    final v = double.tryParse(raw.replaceAll(',', '.'));
    if (v == null) return const ValidationError.notANumber();
    if (v <= 0) return const ValidationError.mustBePositive();
    return null;
  }
}
