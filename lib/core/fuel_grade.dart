enum FuelFamily {
  diesel,
  gasoline,
}

enum FuelProductGroup {
  gasoil,
  gasoline,
}

extension FuelProductGroupLabel on FuelProductGroup {
  // LOCALIZATION: these display labels may be translated in a future l10n pass.
  // Wire AppLocalizations here when the ARB files are ready.
  String get label => switch (this) {
        FuelProductGroup.gasoil => 'Gasoil',
        FuelProductGroup.gasoline => 'Gasoline',
      };
}

class FuelGrade {
  final String id;
  // LOCALIZATION: `name` holds industry-standard grade designations
  // (e.g. '10 ppm ULSD', 'Gasoil 0.1%', 'Unleaded RBOB').
  // These are international trade terms and must NOT be translated.
  final String name;
  final String standard;
  final double contractDensityKgM3;
  final FuelFamily family;
  final FuelProductGroup group;

  const FuelGrade({
    required this.id,
    required this.name,
    required this.standard,
    required this.contractDensityKgM3,
    required this.family,
    required this.group,
  });
}

const List<FuelGrade> kFuelGrades = [
  FuelGrade(
    id: 'ulsd_10',
    name: '10 ppm ULSD',
    standard: 'EN 590',
    contractDensityKgM3: 845.0,
    family: FuelFamily.diesel,
    group: FuelProductGroup.gasoil,
  ),
  FuelGrade(
    id: 'gasoil_01',
    name: 'Gasoil 0.1%',
    standard: 'EN 590',
    contractDensityKgM3: 845.0,
    family: FuelFamily.diesel,
    group: FuelProductGroup.gasoil,
  ),
  FuelGrade(
    id: 'prem_unl_10',
    name: 'Prem Unl 10 PPM',
    standard: 'EN 228',
    contractDensityKgM3: 745.0,
    family: FuelFamily.gasoline,
    group: FuelProductGroup.gasoline,
  ),
  FuelGrade(
    id: 'unleaded_rbob',
    name: 'Unleaded RBOB',
    standard: 'EN 228',
    contractDensityKgM3: 745.0,
    family: FuelFamily.gasoline,
    group: FuelProductGroup.gasoline,
  ),
];
