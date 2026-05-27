// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'D-METER';

  @override
  String get logoSubtitle => 'Fuel Density';

  @override
  String get menuDensityCalculator => 'Density Calculator';

  @override
  String get menuEscalation => 'Escalation';

  @override
  String get menuHowToUse => 'How to use';

  @override
  String get menuHistory => 'Calculation history';

  @override
  String get menuFuelStandards => 'Fuel standards';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuLanguage => 'Language';

  @override
  String get menuAbout => 'About D-METER';

  @override
  String get snackHowToUse => 'How to use D-METER';

  @override
  String get snackHistory => 'Calculation history — coming soon';

  @override
  String get snackFuelStandards => 'Fuel standards — coming soon';

  @override
  String get snackSettings => 'Settings — coming soon';

  @override
  String get snackLanguage => 'Language selection — coming soon';

  @override
  String get snackAbout => 'D-METER v1.0.0 — EN ISO 12185';

  @override
  String get sectionFuel => 'Fuel';

  @override
  String get sectionParameters => 'Parameters';

  @override
  String get sectionDensityBasis => 'Density Basis';

  @override
  String get labelP15 => 'Density at 15°C (passport)';

  @override
  String get labelDeliveryTemp => 'Delivery temperature';

  @override
  String get labelWeight => 'Weight';

  @override
  String get labelActualDensity => 'Actual density at delivery';

  @override
  String get labelVolume => 'Volume';

  @override
  String get labelContractDensity => 'Contract density';

  @override
  String get labelActualDensity15 => 'Actual density 15°C';

  @override
  String get labelAverageQuotation => 'Average quotation';

  @override
  String get labelSellerPremium => 'Seller premium';

  @override
  String get resultDeliveryDensity => 'Delivery Density';

  @override
  String get resultDeliveryTemperature => 'Delivery Temperature';

  @override
  String get detailsToggle => 'Details';

  @override
  String get detailDensityAt15 => 'Density at 15°C';

  @override
  String get detailDensityInAir => 'Density in air';

  @override
  String get detailDeliveryTemp => 'Delivery temperature';

  @override
  String get detailVolume => 'Volume';

  @override
  String get detailWeight => 'Weight';

  @override
  String get detailCoefficientA => 'Coefficient a';

  @override
  String get formulaLabel => 'FORMULA';

  @override
  String get modeDensityAtTemp => 'Density at temp';

  @override
  String get modeTempAtDensity => 'Temp at density';

  @override
  String get escalationSectionLabel => 'ESCALATION';

  @override
  String escalationBasePrice(String value) {
    return 'Base price: $value \$/t';
  }

  @override
  String escalationTotalPremium(String value) {
    return 'Total premium: $value \$/t';
  }

  @override
  String escalationFinalPrice(String value) {
    return 'Final price: $value \$/t';
  }

  @override
  String get fuelGroupGasoil => 'Gasoil';

  @override
  String get fuelGroupGasoline => 'Gasoline';

  @override
  String get hintModeA =>
      'Enter the reference density at 15°C and the delivery temperature. The density at delivery temperature will be shown as Delivery Density.';

  @override
  String get hintModeB =>
      'Enter the actual delivery density. The calculated temperature will appear as Delivery Temperature.';

  @override
  String get validationRequired => 'Required';

  @override
  String get validationEnterNumber => 'Enter a number';

  @override
  String get validationMustBePositive => 'Must be > 0';

  @override
  String get validationMustBePositiveStrict => 'Must be positive';

  @override
  String get validationTempRange => '−40 – 80 °C';

  @override
  String validationDensityRangeKgL(String min, String max, String family) {
    return '$min–$max kg/l ($family)';
  }

  @override
  String validationDensityRangeKgM3(String min, String max, String family) {
    return '$min–$max kg/m³ ($family)';
  }

  @override
  String get validationContractDensityRange => '0.650–1.100 kg/l';

  @override
  String get validationEscalationDensityRange => '0.700–0.900 kg/l';

  @override
  String get resultVolume => 'Volume';

  @override
  String get resultWeight => 'Weight';

  @override
  String get detailsCopied => 'Copied';

  @override
  String get detailContractDensity => 'Contract density';
}
