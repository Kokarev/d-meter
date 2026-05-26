import 'package:flutter/foundation.dart';
import '../../../core/fuel_grade.dart';
import '../../../core/validation.dart';
import '../../../shared/state/density_memory.dart';
import '../service/escalation_service.dart';

class EscalationState extends ChangeNotifier {
  FuelProductGroup _group = FuelProductGroup.gasoil;
  FuelProductGroup get group => _group;

  FuelGrade _product = kFuelGrades.first;
  FuelGrade get product => _product;

  DensityBasis _basis = DensityBasis.vac;
  DensityBasis get basis => _basis;

  String contractDensityRaw = '0.8450';
  String actualDensityRaw   = '0.8332';
  String averagePlattsRaw   = '1044.75';
  String sellerPremiumRaw   = '140.00';

  EscalationResult? _result;
  EscalationResult? get result => _result;

  // errors carry typed ValidationError? — widgets localize on demand.
  Map<String, ValidationError?> _errors = {};
  Map<String, ValidationError?> get errors => _errors;

  EscalationState() {
    _group = DensityMemory.family == FuelFamily.gasoline
        ? FuelProductGroup.gasoline
        : FuelProductGroup.gasoil;

    _product = kFuelGrades.firstWhere(
      (f) => f.group == _group,
      orElse: () => kFuelGrades.first,
    );

    actualDensityRaw = DensityMemory.p15VacKgL != null
        ? DensityMemory.p15VacKgL!.toStringAsFixed(4)
        : (_group == FuelProductGroup.gasoil ? '0.8332' : '0.7433');

    contractDensityRaw =
        _group == FuelProductGroup.gasoil ? '0.8450' : '0.7450';

    _calculate();
  }

  void setGroup(FuelProductGroup group) {
    _group = group;
    final products = kFuelGrades.where((f) => f.group == group).toList();
    _product = products.first;

    if (group == FuelProductGroup.gasoil) {
      contractDensityRaw = '0.8450';
      actualDensityRaw   = '0.8332';
    } else {
      contractDensityRaw = '0.7450';
      actualDensityRaw   = '0.7433';
    }

    _calculate();
  }

  void setProduct(FuelGrade product) {
    _product = product;
    _group   = product.group;
    contractDensityRaw =
        (product.contractDensityKgM3 / 1000).toStringAsFixed(4);
    _calculate();
  }

  void setBasis(DensityBasis basis) {
    if (basis == _basis) return;

    final actual = _parse(actualDensityRaw);

    if (actual != null) {
      if (_basis == DensityBasis.vac && basis == DensityBasis.air) {
        actualDensityRaw =
            EscalationService.vacToAir(actual).toStringAsFixed(4);
      } else if (_basis == DensityBasis.air && basis == DensityBasis.vac) {
        actualDensityRaw =
            EscalationService.airToVac(actual).toStringAsFixed(4);
      }
    }

    _basis = basis;
    _calculate();
  }

  void updateField(String key, String value) {
    switch (key) {
      case 'contractDensity':
        contractDensityRaw = value;
      case 'actualDensity':
        actualDensityRaw = value;
        final parsedActual = _parse(value);
        if (parsedActual != null) {
          final actualVac = _basis == DensityBasis.vac
              ? parsedActual
              : EscalationService.airToVac(parsedActual);
          DensityMemory.setP15KgL(actualVac, _product.family);
        }
      case 'averagePlatts':
        averagePlattsRaw = value;
      case 'sellerPremium':
        sellerPremiumRaw = value;
    }
    _calculate();
  }

  List<FuelGrade> get availableProducts =>
      kFuelGrades.where((f) => f.group == _group).toList();

  void _calculate() {
    _errors = _validate();

    if (_errors.values.any((e) => e != null)) {
      _result = null;
      notifyListeners();
      return;
    }

    _result = EscalationService.calculate(
      averagePlatts:   _parse(averagePlattsRaw)!,
      sellerPremium:   _parse(sellerPremiumRaw)!,
      contractDensity: _parse(contractDensityRaw)!,
      actualDensity:   _parse(actualDensityRaw)!,
      basis:           _basis,
    );

    notifyListeners();
  }

  Map<String, ValidationError?> _validate() {
    return {
      'contractDensity': EscalationService.validateDensity(contractDensityRaw),
      'actualDensity':   EscalationService.validateDensity(actualDensityRaw),
      'averagePlatts':   EscalationService.validatePrice(averagePlattsRaw),
      'sellerPremium':   EscalationService.validatePrice(sellerPremiumRaw),
    };
  }

  static double? _parse(String raw) =>
      double.tryParse(raw.replaceAll(',', '.'));
}
