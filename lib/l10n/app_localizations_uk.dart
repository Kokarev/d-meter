// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppL10nUk extends AppL10n {
  AppL10nUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'D-METER';

  @override
  String get logoSubtitle => 'Густина палива';

  @override
  String get menuDensityCalculator => 'Калькулятор густини';

  @override
  String get menuEscalation => 'Escalation';

  @override
  String get menuHowToUse => 'Як користуватись';

  @override
  String get menuHistory => 'Історія розрахунків';

  @override
  String get menuFuelStandards => 'Стандарти палива';

  @override
  String get menuSettings => 'Налаштування';

  @override
  String get menuLanguage => 'Мова';

  @override
  String get menuAbout => 'Про D-METER';

  @override
  String get snackHowToUse => 'Як користуватись D-METER';

  @override
  String get snackHistory => 'Історія розрахунків — незабаром';

  @override
  String get snackFuelStandards => 'Стандарти палива — незабаром';

  @override
  String get snackSettings => 'Налаштування — незабаром';

  @override
  String get snackLanguage => 'Вибір мови — незабаром';

  @override
  String get snackAbout => 'D-METER v1.0.0 — EN ISO 12185';

  @override
  String get sectionFuel => 'Паливо';

  @override
  String get sectionParameters => 'Параметри';

  @override
  String get sectionDensityBasis => 'Основа густини';

  @override
  String get labelP15 => 'Густина при 15°C (паспорт)';

  @override
  String get labelDeliveryTemp => 'Температура прийому';

  @override
  String get labelWeight => 'Маса';

  @override
  String get labelActualDensity => 'Фактична густина при прийомі';

  @override
  String get labelVolume => 'Об\'єм';

  @override
  String get labelContractDensity => 'Контрактна густина';

  @override
  String get labelActualDensity15 => 'Фактична густина 15°C';

  @override
  String get labelAverageQuotation => 'Середнє котирування';

  @override
  String get labelSellerPremium => 'Премія продавця';

  @override
  String get resultDeliveryDensity => 'Густина при прийомі';

  @override
  String get resultDeliveryTemperature => 'Температура прийому';

  @override
  String get detailsToggle => 'Деталі';

  @override
  String get detailDensityAt15 => 'Густина при 15°C';

  @override
  String get detailDensityInAir => 'Густина у повітрі';

  @override
  String get detailDeliveryTemp => 'Температура прийому';

  @override
  String get detailVolume => 'Об\'єм';

  @override
  String get detailWeight => 'Маса';

  @override
  String get detailCoefficientA => 'Коефіцієнт a';

  @override
  String get formulaLabel => 'ФОРМУЛА';

  @override
  String get modeDensityAtTemp => 'Густину за темп.';

  @override
  String get modeTempAtDensity => 'Темп. за густиною';

  @override
  String get escalationSectionLabel => 'ESCALATION';

  @override
  String escalationBasePrice(String value) {
    return 'Базова ціна: $value \$/т';
  }

  @override
  String escalationTotalPremium(String value) {
    return 'Загальна премія: $value \$/т';
  }

  @override
  String escalationFinalPrice(String value) {
    return 'Кінцева ціна: $value \$/т';
  }

  @override
  String get fuelGroupGasoil => 'Газойль';

  @override
  String get fuelGroupGasoline => 'Бензин';

  @override
  String get hintModeA =>
      'Введіть референтну густину при 15°C та температуру прийому. Густина при температурі прийому буде показана як «Густина при прийомі».';

  @override
  String get hintModeB =>
      'Введіть фактичну густину при прийомі. Розрахована температура буде показана як «Температура прийому».';

  @override
  String get validationRequired => 'Обов\'язкове поле';

  @override
  String get validationEnterNumber => 'Введіть число';

  @override
  String get validationMustBePositive => 'Має бути > 0';

  @override
  String get validationMustBePositiveStrict => 'Має бути додатнім';

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
}
