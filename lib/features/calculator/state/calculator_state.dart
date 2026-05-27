import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../core/fuel_grade.dart';
import '../../../core/validation.dart';
import '../../../shared/state/density_memory.dart';
import '../service/density_calculator_service.dart';

enum CalcMode {
  densityAtTemp,
  tempAtDensity,
}

class CalculatorState extends ChangeNotifier {
  FuelGrade _fuel = kFuelGrades.first;
  FuelGrade get fuel => _fuel;

  CalcMode _mode = CalcMode.densityAtTemp;
  CalcMode get mode => _mode;

  String p15Raw = '833.9';
  String contractDensityRaw = '0.845';
  String tempRaw = '11.0';
  String weightRaw = '100.0';
  String densityRaw = '0.8300';
  String volumeRaw = '120.482';

  DensityResult? _result;
  DensityResult? get result => _result;

  // errors now carry typed ValidationError? — widgets localize on demand.
  Map<String, ValidationError?> _errors = {};
  Map<String, ValidationError?> get errors => _errors;

  bool _detailsOpen = false;
  bool get detailsOpen => _detailsOpen;

  // debounce для updateField — 200 мс
  Timer? _debounce;

  void setFuel(FuelGrade f) {
    final familyChanged = f.family != _fuel.family;
    _fuel = f;

    if (familyChanged) {
      p15Raw = f.family == FuelFamily.diesel ? '833.9' : '743.3';
      densityRaw = f.family == FuelFamily.diesel ? '0.8300' : '0.7433';
    }

    contractDensityRaw = (f.contractDensityKgM3 / 1000).toStringAsFixed(3);
    _calculate();
  }

  void setMode(CalcMode m) {
    _mode = m;
    _calculate();
  }

  void updateField(String key, String value) {
    switch (key) {
      case 'p15':
        p15Raw = value;
        final parsedP15 = _parse(value);
        if (parsedP15 != null) {
          DensityMemory.setP15KgM3(parsedP15, _fuel.family);
        }
      case 'contractDensity':
        contractDensityRaw = value;
      case 'temp':
        tempRaw = value;
      case 'weight':
        weightRaw = value;
      case 'density':
        densityRaw = value;
      case 'volume':
        volumeRaw = value;
    }
    // Debounce 200 мс: пересчёт откладывается пока пользователь набирает.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), _calculate);
  }

  void toggleDetails() {
    _detailsOpen = !_detailsOpen;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Только для тестов: немедленный пересчёт без debounce.
  /// В продакшн-коде не вызывать напрямую.
  @visibleForTesting
  void calculateNow() => _calculate();

  void _calculate() {
    _errors = _validate();
    if (_errors.values.any((e) => e != null)) {
      _result = null;
      notifyListeners();
      return;
    }

    final p15      = _parse(p15Raw)!;
    final contract = _parse(contractDensityRaw)! * 1000;
    final family   = _fuel.family;

    if (_mode == CalcMode.densityAtTemp) {
      _result = DensityCalculatorService.calcFromWeight(
        p15KgM3:             p15,
        tempC:               _parse(tempRaw)!,
        weightT:             _parse(weightRaw)!,
        contractDensityKgM3: contract,
        fuelFamily:          family,
      );
    } else {
      _result = DensityCalculatorService.calcFromDensity(
        p15KgM3:             p15,
        actualDensityKgL:    _parse(densityRaw)!,
        volumeM3:            _parse(volumeRaw)!,
        contractDensityKgM3: contract,
        fuelFamily:          family,
      );
    }

    notifyListeners();
  }

  Map<String, ValidationError?> _validate() {
    final e      = <String, ValidationError?>{};
    final family = _fuel.family;

    e['p15']             = DensityCalculatorService.validateP15(p15Raw, family);
    e['contractDensity'] = _validateContractDensity(contractDensityRaw);

    if (_mode == CalcMode.densityAtTemp) {
      e['temp']   = DensityCalculatorService.validateTemp(tempRaw);
      e['weight'] = DensityCalculatorService.validateWeight(weightRaw);
    } else {
      e['density'] =
          DensityCalculatorService.validateDensityKgL(densityRaw, family);
      e['volume'] = DensityCalculatorService.validateVolume(volumeRaw);
    }

    return e;
  }

  static ValidationError? _validateContractDensity(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const ValidationError.required();
    final v = double.tryParse(raw.replaceAll(',', '.'));
    if (v == null) return const ValidationError.notANumber();
    if (v < 0.650 || v > 1.100) {
      return const ValidationError(
          ValidationErrorKind.contractDensityOutOfRange);
    }
    return null;
  }

  static double? _parse(String raw) =>
      double.tryParse(raw.replaceAll(',', '.'));
}
