// ─────────────────────────────────────────────────────────────────────────────
// VisualizationState
//
// Изолирован от CalculatorState — отдельный экран, отдельное состояние.
// UI не содержит математики — только вызовы сервисов.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import '../../../core/fuel_grade.dart';
import '../../calculator/models/density_point.dart';
import '../../calculator/models/fuel_mixture.dart';
import '../../calculator/models/thermal_state.dart';
import '../../calculator/services/density_curve_service.dart';
import '../../calculator/services/fuel_mixing_service.dart';

class VisualizationState extends ChangeNotifier {
  // ── Входные параметры ─────────────────────────────────────────────────────
  FuelGrade _fuel     = kFuelGrades.first;
  double    _p15KgM3  = 833.9;
  double    _massT    = 100.0;
  double    _sliderT  = 15.0;

  // ── Диапазон слайдера ─────────────────────────────────────────────────────
  double get sliderMin => -10.0;
  double get sliderMax =>  50.0;

  // ── Публичные геттеры ─────────────────────────────────────────────────────
  FuelGrade get fuel      => _fuel;
  double    get p15KgM3   => _p15KgM3;
  double    get massT     => _massT;
  double    get sliderTempC => _sliderT;

  // ── Вычисленные данные ────────────────────────────────────────────────────
  late List<DensityPoint> _passportCurve;
  late ThermalState        _thermalState;

  List<DensityPoint> get passportCurve => _passportCurve;
  ThermalState        get thermalState  => _thermalState;

  // ── Phase 3: смешивание ───────────────────────────────────────────────────
  FuelBatch?     _batchA;
  FuelBatch?     _batchB;
  MixtureResult? _mixtureResult;
  String?        _mixtureError;

  FuelBatch?     get batchA        => _batchA;
  FuelBatch?     get batchB        => _batchB;
  MixtureResult? get mixtureResult => _mixtureResult;
  String?        get mixtureError  => _mixtureError;

  // ─────────────────────────────────────────────────────────────────────────

  VisualizationState() {
    _recalculate();
  }

  // ── Сеттеры ───────────────────────────────────────────────────────────────

  void setFuel(FuelGrade f) {
    _fuel     = f;
    _p15KgM3  = f.family == FuelFamily.diesel ? 833.9 : 743.3;
    _recalculate();
  }

  void setP15(double p15KgM3) {
    _p15KgM3 = p15KgM3;
    _recalculate();
  }

  void setMass(double massT) {
    _massT = massT;
    _recalculate();
  }

  /// Вызывается при движении слайдера.
  /// Обновляет только ThermalState — не перестраивает кривую.
  void setSliderTemp(double tempC) {
    _sliderT     = tempC;
    _thermalState = DensityCurveService.computeThermalState(
      p15KgM3: _p15KgM3,
      family:  _fuel.family,
      tempC:   tempC,
      massT:   _massT,
    );
    notifyListeners();
  }

  // ── Phase 3 ───────────────────────────────────────────────────────────────

  void setBatchA(FuelBatch batch) {
    _batchA = batch;
    _computeMixture();
  }

  void setBatchB(FuelBatch batch) {
    _batchB = batch;
    _computeMixture();
  }

  void clearMixture() {
    _batchA = _batchB = null;
    _mixtureResult = null;
    _mixtureError  = null;
    notifyListeners();
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  void _recalculate() {
    _passportCurve = DensityCurveService.generateCurve(
      p15KgM3:  _p15KgM3,
      family:   _fuel.family,
      tempFrom: sliderMin,
      tempTo:   sliderMax,
    );
    _thermalState = DensityCurveService.computeThermalState(
      p15KgM3: _p15KgM3,
      family:  _fuel.family,
      tempC:   _sliderT,
      massT:   _massT,
    );
    notifyListeners();
  }

  void _computeMixture() {
    _mixtureError = FuelMixingService.validate(_batchA, _batchB);
    if (_mixtureError != null) {
      _mixtureResult = null;
    } else {
      try {
        _mixtureResult = FuelMixingService.mix(_batchA!, _batchB!);
        _mixtureError  = null;
      } on ArgumentError catch (e) {
        _mixtureResult = null;
        _mixtureError  = e.message.toString();
      }
    }
    notifyListeners();
  }
}
