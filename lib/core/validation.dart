// ─────────────────────────────────────────────────────────────────────────────
// Validation result types
//
// Services return ValidationError (a typed value) instead of raw English
// strings.  The UI layer calls AppL10n to turn the error into a localized
// message, so services remain locale-independent.
// ─────────────────────────────────────────────────────────────────────────────

enum ValidationErrorKind {
  required,
  notANumber,
  mustBePositive,       // strictly > 0
  mustBePositiveOrZero, // >= 0 (price fields)
  tempOutOfRange,       // −40 – 80 °C
  densityKgLOutOfRange, // family-specific kg/l range
  densityKgM3OutOfRange,// family-specific kg/m³ range
  contractDensityOutOfRange, // 0.650–1.100 kg/l
  escalationDensityOutOfRange, // 0.700–0.900 kg/l
}

/// Carries the error kind plus optional range data for out-of-range messages.
class ValidationError {
  final ValidationErrorKind kind;

  /// For range errors: human-readable min/max strings and optional family name.
  final String? min;
  final String? max;
  final String? family;

  const ValidationError(this.kind, {this.min, this.max, this.family});

  // Convenience constructors
  const ValidationError.required()
      : this(ValidationErrorKind.required);

  const ValidationError.notANumber()
      : this(ValidationErrorKind.notANumber);

  const ValidationError.mustBePositive()
      : this(ValidationErrorKind.mustBePositive);

  const ValidationError.mustBePositiveOrZero()
      : this(ValidationErrorKind.mustBePositiveOrZero);

  const ValidationError.tempOutOfRange()
      : this(ValidationErrorKind.tempOutOfRange);
}
