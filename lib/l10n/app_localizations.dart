import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_uk.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uk')
  ];

  /// App name — do not translate
  ///
  /// In en, this message translates to:
  /// **'D-METER'**
  String get appTitle;

  /// Subtitle under D-METER logo
  ///
  /// In en, this message translates to:
  /// **'Fuel Density'**
  String get logoSubtitle;

  /// No description provided for @menuDensityCalculator.
  ///
  /// In en, this message translates to:
  /// **'Density Calculator'**
  String get menuDensityCalculator;

  /// No description provided for @menuEscalation.
  ///
  /// In en, this message translates to:
  /// **'Escalation'**
  String get menuEscalation;

  /// No description provided for @menuHowToUse.
  ///
  /// In en, this message translates to:
  /// **'How to use'**
  String get menuHowToUse;

  /// No description provided for @menuHistory.
  ///
  /// In en, this message translates to:
  /// **'Calculation history'**
  String get menuHistory;

  /// No description provided for @menuFuelStandards.
  ///
  /// In en, this message translates to:
  /// **'Fuel standards'**
  String get menuFuelStandards;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get menuLanguage;

  /// No description provided for @menuAbout.
  ///
  /// In en, this message translates to:
  /// **'About D-METER'**
  String get menuAbout;

  /// No description provided for @snackHowToUse.
  ///
  /// In en, this message translates to:
  /// **'How to use D-METER'**
  String get snackHowToUse;

  /// No description provided for @snackHistory.
  ///
  /// In en, this message translates to:
  /// **'Calculation history — coming soon'**
  String get snackHistory;

  /// No description provided for @snackFuelStandards.
  ///
  /// In en, this message translates to:
  /// **'Fuel standards — coming soon'**
  String get snackFuelStandards;

  /// No description provided for @snackSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings — coming soon'**
  String get snackSettings;

  /// No description provided for @snackLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language selection — coming soon'**
  String get snackLanguage;

  /// Version string — EN ISO 12185 must not be translated
  ///
  /// In en, this message translates to:
  /// **'D-METER v1.0.0 — EN ISO 12185'**
  String get snackAbout;

  /// No description provided for @sectionFuel.
  ///
  /// In en, this message translates to:
  /// **'Fuel'**
  String get sectionFuel;

  /// No description provided for @sectionParameters.
  ///
  /// In en, this message translates to:
  /// **'Parameters'**
  String get sectionParameters;

  /// No description provided for @sectionDensityBasis.
  ///
  /// In en, this message translates to:
  /// **'Density Basis'**
  String get sectionDensityBasis;

  /// Input label — P15 is an ISO variable name, keep as-is
  ///
  /// In en, this message translates to:
  /// **'Density at 15°C (passport)'**
  String get labelP15;

  /// No description provided for @labelDeliveryTemp.
  ///
  /// In en, this message translates to:
  /// **'Delivery temperature'**
  String get labelDeliveryTemp;

  /// No description provided for @labelWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get labelWeight;

  /// No description provided for @labelActualDensity.
  ///
  /// In en, this message translates to:
  /// **'Actual density at delivery'**
  String get labelActualDensity;

  /// No description provided for @labelVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get labelVolume;

  /// No description provided for @labelContractDensity.
  ///
  /// In en, this message translates to:
  /// **'Contract density'**
  String get labelContractDensity;

  /// No description provided for @labelActualDensity15.
  ///
  /// In en, this message translates to:
  /// **'Actual density 15°C'**
  String get labelActualDensity15;

  /// No description provided for @labelAverageQuotation.
  ///
  /// In en, this message translates to:
  /// **'Average quotation'**
  String get labelAverageQuotation;

  /// No description provided for @labelSellerPremium.
  ///
  /// In en, this message translates to:
  /// **'Seller premium'**
  String get labelSellerPremium;

  /// No description provided for @resultDeliveryDensity.
  ///
  /// In en, this message translates to:
  /// **'Delivery Density'**
  String get resultDeliveryDensity;

  /// No description provided for @resultDeliveryTemperature.
  ///
  /// In en, this message translates to:
  /// **'Delivery Temperature'**
  String get resultDeliveryTemperature;

  /// No description provided for @detailsToggle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsToggle;

  /// No description provided for @detailDensityAt15.
  ///
  /// In en, this message translates to:
  /// **'Density at 15°C'**
  String get detailDensityAt15;

  /// VAC/AIR buoyancy-corrected density label
  ///
  /// In en, this message translates to:
  /// **'Density in air'**
  String get detailDensityInAir;

  /// No description provided for @detailDeliveryTemp.
  ///
  /// In en, this message translates to:
  /// **'Delivery temperature'**
  String get detailDeliveryTemp;

  /// No description provided for @detailVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get detailVolume;

  /// No description provided for @detailWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get detailWeight;

  /// EN ISO 91-1 temperature correction coefficient — 'a' is a formula variable, keep lowercase
  ///
  /// In en, this message translates to:
  /// **'Coefficient a'**
  String get detailCoefficientA;

  /// Micro-label above formula block
  ///
  /// In en, this message translates to:
  /// **'FORMULA'**
  String get formulaLabel;

  /// No description provided for @modeDensityAtTemp.
  ///
  /// In en, this message translates to:
  /// **'Density at temp'**
  String get modeDensityAtTemp;

  /// No description provided for @modeTempAtDensity.
  ///
  /// In en, this message translates to:
  /// **'Temp at density'**
  String get modeTempAtDensity;

  /// No description provided for @escalationSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'ESCALATION'**
  String get escalationSectionLabel;

  /// No description provided for @escalationBasePrice.
  ///
  /// In en, this message translates to:
  /// **'Base price: {value} \$/t'**
  String escalationBasePrice(String value);

  /// No description provided for @escalationTotalPremium.
  ///
  /// In en, this message translates to:
  /// **'Total premium: {value} \$/t'**
  String escalationTotalPremium(String value);

  /// No description provided for @escalationFinalPrice.
  ///
  /// In en, this message translates to:
  /// **'Final price: {value} \$/t'**
  String escalationFinalPrice(String value);

  /// Fuel product group display label — may be localized
  ///
  /// In en, this message translates to:
  /// **'Gasoil'**
  String get fuelGroupGasoil;

  /// Fuel product group display label — may be localized
  ///
  /// In en, this message translates to:
  /// **'Gasoline'**
  String get fuelGroupGasoline;

  /// No description provided for @hintModeA.
  ///
  /// In en, this message translates to:
  /// **'Enter the reference density at 15°C and the delivery temperature. The density at delivery temperature will be shown as Delivery Density.'**
  String get hintModeA;

  /// No description provided for @hintModeB.
  ///
  /// In en, this message translates to:
  /// **'Enter the actual delivery density. The calculated temperature will appear as Delivery Temperature.'**
  String get hintModeB;

  /// No description provided for @validationRequired.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get validationRequired;

  /// No description provided for @validationEnterNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a number'**
  String get validationEnterNumber;

  /// No description provided for @validationMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Must be > 0'**
  String get validationMustBePositive;

  /// No description provided for @validationMustBePositiveStrict.
  ///
  /// In en, this message translates to:
  /// **'Must be positive'**
  String get validationMustBePositiveStrict;

  /// Temperature range error — °C must not be translated
  ///
  /// In en, this message translates to:
  /// **'−40 – 80 °C'**
  String get validationTempRange;

  /// Density out-of-range error. family = diesel or gasoline.
  ///
  /// In en, this message translates to:
  /// **'{min}–{max} kg/l ({family})'**
  String validationDensityRangeKgL(String min, String max, String family);

  /// P15 out-of-range error.
  ///
  /// In en, this message translates to:
  /// **'{min}–{max} kg/m³ ({family})'**
  String validationDensityRangeKgM3(String min, String max, String family);

  /// No description provided for @validationContractDensityRange.
  ///
  /// In en, this message translates to:
  /// **'0.650–1.100 kg/l'**
  String get validationContractDensityRange;

  /// No description provided for @validationEscalationDensityRange.
  ///
  /// In en, this message translates to:
  /// **'0.700–0.900 kg/l'**
  String get validationEscalationDensityRange;

  /// Secondary result label in Mode A result card
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get resultVolume;

  /// Secondary result label in Mode B result card
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get resultWeight;

  /// SnackBar text after long-press copy on result card
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get detailsCopied;

  /// Details row label for contract/passport density
  ///
  /// In en, this message translates to:
  /// **'Contract density'**
  String get detailContractDensity;

  /// Title for the density visualization screen
  ///
  /// In en, this message translates to:
  /// **'Density Chart'**
  String get vizScreenTitle;

  /// Section label above the chart
  ///
  /// In en, this message translates to:
  /// **'Density vs Temperature'**
  String get vizChartTitle;

  /// Chart legend — blue passport density curve
  ///
  /// In en, this message translates to:
  /// **'Passport curve'**
  String get vizLegendPassport;

  /// Chart legend — red operating point marker
  ///
  /// In en, this message translates to:
  /// **'Operating point'**
  String get vizLegendOperating;

  /// Label for thermal expansion row
  ///
  /// In en, this message translates to:
  /// **'Thermal expansion'**
  String get vizThermalExpansion;

  /// Phase 3: section title for fuel mixing
  ///
  /// In en, this message translates to:
  /// **'Fuel Mixing'**
  String get vizMixtureTitle;

  /// Phase 3: label for batch A
  ///
  /// In en, this message translates to:
  /// **'Existing tank'**
  String get vizMixtureBatchA;

  /// Phase 3: label for batch B
  ///
  /// In en, this message translates to:
  /// **'Incoming fuel'**
  String get vizMixtureBatchB;

  /// Phase 3: result card title
  ///
  /// In en, this message translates to:
  /// **'Mixture Result'**
  String get vizMixtureResult;

  /// No description provided for @vizTotalVolume.
  ///
  /// In en, this message translates to:
  /// **'Total volume'**
  String get vizTotalVolume;

  /// No description provided for @vizTotalMass.
  ///
  /// In en, this message translates to:
  /// **'Total mass'**
  String get vizTotalMass;

  /// No description provided for @vizMixedDensity.
  ///
  /// In en, this message translates to:
  /// **'Mixed density'**
  String get vizMixedDensity;

  /// No description provided for @vizMixedTemp.
  ///
  /// In en, this message translates to:
  /// **'Mixed temperature'**
  String get vizMixedTemp;
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uk'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'uk':
      return AppL10nUk();
  }

  throw FlutterError(
      'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
