
import '../../../core/validation.dart';

enum DensityBasis {
  vac,
  air,
}

class EscalationResult {
  final double basePrice;
  final double escalationPerTon;
  final double totalPremium;
  final double finalPrice;

  final double contractDensityVac;
  final double actualDensityVac;

  final DensityBasis basis;

  const EscalationResult({
    required this.basePrice,
    required this.escalationPerTon,
    required this.totalPremium,
    required this.finalPrice,
    required this.contractDensityVac,
    required this.actualDensityVac,
    required this.basis,
  });
}

class EscalationService {
  static const double airFactor = 1.00135178;

  // ─────────────────────────────────────────────────────────────
  // Density conversion
  // ─────────────────────────────────────────────────────────────

  static double vacToAir(double vac) {
    return vac / airFactor;
  }

  static double airToVac(double air) {
    return air * airFactor;
  }

  // ─────────────────────────────────────────────────────────────
  // Escalation calculation
  // ─────────────────────────────────────────────────────────────

  static EscalationResult calculate({
    required double averagePlatts,
    required double sellerPremium,
    required double contractDensity,
    required double actualDensity,
    required DensityBasis basis,
  }) {
    final basePrice = averagePlatts + sellerPremium;

    // Internal calculation always in VAC
    final contractVac = basis == DensityBasis.vac
        ? contractDensity
        : airToVac(contractDensity);

    final actualVac = basis == DensityBasis.vac
        ? actualDensity
        : airToVac(actualDensity);

    final escalation =
        basePrice * (contractVac / actualVac - 1);

    final totalPremium =
        sellerPremium + escalation;

    final finalPrice =
        basePrice + escalation;

    return EscalationResult(
      basePrice: basePrice,
      escalationPerTon: escalation,
      totalPremium: totalPremium,
      finalPrice: finalPrice,
      contractDensityVac: contractVac,
      actualDensityVac: actualVac,
      basis: basis,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Validation
  // ─────────────────────────────────────────────────────────────

  static ValidationError? validateDensity(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const ValidationError.required();
    }
    final v = double.tryParse(raw.replaceAll(',', '.'));
    if (v == null) return const ValidationError.notANumber();
    if (v < 0.700 || v > 0.900) {
      return const ValidationError(
          ValidationErrorKind.escalationDensityOutOfRange);
    }
    return null;
  }

  static ValidationError? validatePrice(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const ValidationError.required();
    }
    final v = double.tryParse(raw.replaceAll(',', '.'));
    if (v == null) return const ValidationError.notANumber();
    if (v < 0) return const ValidationError.mustBePositiveOrZero();
    return null;
  }
}
