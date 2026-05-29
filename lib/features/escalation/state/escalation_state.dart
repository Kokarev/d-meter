import 'package:flutter/foundation.dart';

import '../../../core/fuel_grade.dart';
import '../../../core/validation.dart';
import '../../../shared/state/density_memory.dart';
import '../service/escalation_service.dart';

class EscalationState extends ChangeNotifier {
  FuelGrade _product = _initialProduct();
  FuelGrade get product => _product;

  DensityBasis _basis = DensityBasis.vac;
  DensityBasis get basis => _basis;

  String contractDensityRaw = '';
  String actualDensityRaw = '';
  String averagePlattsRaw = '1044.75';
  String sellerPremiumRaw = '140.00';

  EscalationResult? _result;
  EscalationResult? get result => _result;

  Map<String, ValidationError?> _errors = {};
  Map<String, ValidationError?> get errors => _errors;

  EscalationState() {
    contractDensityRaw =
        (_product.contractDensityKgM3 / 1000).toStringAsFixed(4);

    actualDensityRaw = DensityMemory.p15VacKgL != null
        ? DensityMemory.p15VacKgL!.toStringAsFixed(4)
        : _defaultActualDensityKgL(_product).toStringAsFixed(4);

    _calculate();
  }

  static FuelGrade _initialProduct() {
    final memoryFamily = DensityMemory.family;
    if (memoryFamily != null) {
      return kFuelGrades.firstWhere(
        (f) => f.family == memoryFamily,
        orElse: () => kFuelGrades.first,
      );
    }
    return kFuelGrades.first;
  }

  static double _defaultActualDensityKgL(FuelGrade product) {
    return product.family == FuelFamily.gasoline ? 0.7433 : 0.8332;
  }

  void setProduct(FuelGrade product) {
    _product = product;

    contractDensityRaw =
        (product.contractDensityKgM3 / 1000).toStringAsFixed(4);

    final rememberedFamily = DensityMemory.family;
    final rememberedP15 = DensityMemory.p15VacKgL;

    if (rememberedP15 != null && rememberedFamily == product.family) {
      actualDensityRaw = rememberedP15.toStringAsFixed(4);
    } else {
      actualDensityRaw = _defaultActualDensityKgL(product).toStringAsFixed(4);
    }

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

  List<FuelGrade> get availableProducts => kFuelGrades;

  void _calculate() {
    _errors = _validate();

    if (_errors.values.any((e) => e != null)) {
      _result = null;
      notifyListeners();
      return;
    }

    _result = EscalationService.calculate(
      averagePlatts: _parse(averagePlattsRaw)!,
      sellerPremium: _parse(sellerPremiumRaw)!,
      contractDensity: _parse(contractDensityRaw)!,
      actualDensity: _parse(actualDensityRaw)!,
      basis: _basis,
    );

    notifyListeners();
  }

  Map<String, ValidationError?> _validate() {
    return {
      'contractDensity': EscalationService.validateDensity(contractDensityRaw),
      'actualDensity': EscalationService.validateDensity(actualDensityRaw),
      'averagePlatts': EscalationService.validatePrice(averagePlattsRaw),
      'sellerPremium': EscalationService.validatePrice(sellerPremiumRaw),
    };
  }

  static double? _parse(String raw) =>
      double.tryParse(raw.replaceAll(',', '.'));
}
