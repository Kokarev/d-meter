import 'package:flutter/foundation.dart';

import '../../../core/fuel_grade.dart';
import '../../calculator/models/density_point.dart';
import '../../calculator/models/fuel_mixture.dart';
import '../../calculator/models/thermal_state.dart';
import '../../calculator/services/density_curve_service.dart';
import '../../calculator/services/fuel_mixing_service.dart';

enum QuantityUnit { m3, tonnes }

enum QuantityRange {
  r1to100(min: 1, max: 100, label: '1–100', description: 'Tank trucks'),
  r101to1000(
      min: 101, max: 1000, label: '101–1 000', description: 'Oil depots'),
  r1001to10000(
      min: 1001,
      max: 10000,
      label: '1 001–10 000',
      description: 'Tanker fleet'),
  r10kto100k(
      min: 10001,
      max: 100000,
      label: '10 001–100 000',
      description: 'Refineries / Panamax');

  final double min;
  final double max;
  final String label;
  final String description;

  const QuantityRange({
    required this.min,
    required this.max,
    required this.label,
    required this.description,
  });

  bool contains(double value) => value >= min && value <= max;

  double clamp(double value) => value.clamp(min, max).toDouble();

  static QuantityRange bestFor(double value) {
    for (final r in QuantityRange.values) {
      if (r.contains(value)) return r;
    }
    return value < 1 ? QuantityRange.r1to100 : QuantityRange.r10kto100k;
  }
}

class VisualizationState extends ChangeNotifier {
  FuelGrade _fuel = kFuelGrades.first;
  double _p15KgM3 = 833.9;
  double _sliderT = 15.0;

  QuantityUnit _qUnit = QuantityUnit.m3;
  QuantityRange _qRange = QuantityRange.r1to100;
  double _qValue = 50.0;

  late List<DensityPoint> _passportCurve;
  late ThermalState _thermalState;

  FuelBatch? _batchA;
  FuelBatch? _batchB;
  MixtureResult? _mixtureResult;
  String? _mixtureError;

  VisualizationState({
    double? initialP15KgM3,
    FuelFamily? initialFamily,
  }) {
    if (initialFamily != null) {
      _fuel = kFuelGrades.firstWhere(
        (f) => f.family == initialFamily,
        orElse: () => _fuel,
      );
    }

    if (initialP15KgM3 != null) {
      _p15KgM3 = initialP15KgM3;
    }

    _recalculate();
  }

  FuelGrade get fuel => _fuel;
  double get p15KgM3 => _p15KgM3;

  double get sliderTempC => _sliderT;
  double get sliderMin => -10.0;
  double get sliderMax => 50.0;

  QuantityUnit get quantityUnit => _qUnit;
  QuantityRange get quantityRange => _qRange;
  double get quantityValue => _qValue;

  double get massT => _thermalState.massT;

  List<DensityPoint> get passportCurve => _passportCurve;
  ThermalState get thermalState => _thermalState;

  FuelBatch? get batchA => _batchA;
  FuelBatch? get batchB => _batchB;
  MixtureResult? get mixtureResult => _mixtureResult;
  String? get mixtureError => _mixtureError;

  void setFuel(FuelGrade f) {
    _fuel = f;
    _p15KgM3 = f.family == FuelFamily.diesel ? 833.9 : 743.3;
    _recalculate();
  }

  void setP15(double p15KgM3) {
    _p15KgM3 = p15KgM3;
    _recalculate();
  }

  void setSliderTemp(double tempC) {
    _sliderT = tempC;
    _thermalState = _computeState(tempC);
    notifyListeners();
  }

  void setMass(double massT) {
    _qUnit = QuantityUnit.tonnes;
    _qRange = QuantityRange.bestFor(massT);
    _qValue = _qRange.clamp(massT);
    _thermalState = _computeState(_sliderT);
    notifyListeners();
  }

  void setQuantityValue(double value) {
    _qValue = _qRange.clamp(value);
    _thermalState = _computeState(_sliderT);
    notifyListeners();
  }

  void setQuantityUnit(QuantityUnit unit) {
    if (unit == _qUnit) return;

    final converted = unit == QuantityUnit.tonnes
        ? _thermalState.massT
        : _thermalState.volumeM3;

    _qUnit = unit;
    _qRange = QuantityRange.bestFor(converted);
    _qValue = _qRange.clamp(converted);

    _thermalState = _computeState(_sliderT);
    notifyListeners();
  }

  void setQuantityRange(QuantityRange range) {
    _qRange = range;
    _qValue = range.clamp(_qValue);
    _thermalState = _computeState(_sliderT);
    notifyListeners();
  }

  void setBatchA(FuelBatch batch) {
    _batchA = batch;
    _computeMixture();
  }

  void setBatchB(FuelBatch batch) {
    _batchB = batch;
    _computeMixture();
  }

  void clearMixture() {
    _batchA = null;
    _batchB = null;
    _mixtureResult = null;
    _mixtureError = null;
    notifyListeners();
  }

  ThermalState _computeState(double tempC) {
    final densityState = DensityCurveService.computeThermalState(
      p15KgM3: _p15KgM3,
      family: _fuel.family,
      tempC: tempC,
      massT: 1.0,
    );

    final densityKgL = densityState.densityKgL;

    final massT = _qUnit == QuantityUnit.m3 ? _qValue * densityKgL : _qValue;

    return DensityCurveService.computeThermalState(
      p15KgM3: _p15KgM3,
      family: _fuel.family,
      tempC: tempC,
      massT: massT > 0 ? massT : 0.001,
    );
  }

  void _recalculate() {
    _passportCurve = DensityCurveService.generateCurve(
      p15KgM3: _p15KgM3,
      family: _fuel.family,
      tempFrom: sliderMin,
      tempTo: sliderMax,
    );
    _thermalState = _computeState(_sliderT);
    notifyListeners();
  }

  void _computeMixture() {
    _mixtureError = FuelMixingService.validate(_batchA, _batchB);
    if (_mixtureError != null) {
      _mixtureResult = null;
    } else {
      try {
        _mixtureResult = FuelMixingService.mix(_batchA!, _batchB!);
        _mixtureError = null;
      } on ArgumentError catch (e) {
        _mixtureResult = null;
        _mixtureError = e.message.toString();
      }
    }
    notifyListeners();
  }
}
