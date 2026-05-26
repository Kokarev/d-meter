// ─────────────────────────────────────────────────────────────────────────────
// ValidationError → localized String
//
// This is the only place in the app that joins the validation layer with l10n.
// UI widgets call: error?.localize(context)
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/widgets.dart';
import '../l10n/app_localizations.dart';
import 'validation.dart';

extension ValidationErrorL10n on ValidationError {
  String localize(BuildContext context) {
    final l = AppL10n.of(context);
    return switch (kind) {
      ValidationErrorKind.required               => l.validationRequired,
      ValidationErrorKind.notANumber             => l.validationEnterNumber,
      ValidationErrorKind.mustBePositive         => l.validationMustBePositive,
      ValidationErrorKind.mustBePositiveOrZero   => l.validationMustBePositiveStrict,
      ValidationErrorKind.tempOutOfRange         => l.validationTempRange,
      ValidationErrorKind.densityKgLOutOfRange   =>
          l.validationDensityRangeKgL(min!, max!, family ?? ''),
      ValidationErrorKind.densityKgM3OutOfRange  =>
          l.validationDensityRangeKgM3(min!, max!, family ?? ''),
      ValidationErrorKind.contractDensityOutOfRange  =>
          l.validationContractDensityRange,
      ValidationErrorKind.escalationDensityOutOfRange =>
          l.validationEscalationDensityRange,
    };
  }
}
