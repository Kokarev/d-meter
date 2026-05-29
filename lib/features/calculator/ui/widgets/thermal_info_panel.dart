import 'package:flutter/material.dart';
import '../../../../core/tokens.dart';
import '../../models/thermal_state.dart';
import '../../../visualization/utils/unit_converter.dart';

/// Панель live-результатов при движении слайдера.
/// Поддерживает metric и US единицы через [unitSystem].
class ThermalInfoPanel extends StatelessWidget {
  final ThermalState state;
  final String labelDensity;
  final String labelVolume;
  final String labelMass;
  final String labelExpansion;
  final UnitSystem unitSystem;

  const ThermalInfoPanel({
    super.key,
    required this.state,
    required this.labelDensity,
    required this.labelVolume,
    required this.labelMass,
    required this.labelExpansion,
    this.unitSystem = UnitSystem.metric,
  });

  @override
  Widget build(BuildContext context) {
    final sys = unitSystem;
    final expansionVal = UnitConverter.formatExpansion(
        state.thermalExpansionL, sys);
    final expColor = state.thermalExpansionL >= 0
        ? AppColors.warning
        : AppColors.accent;

    // API gravity row (US only)
    final apiVal = UnitConverter.kglToApi(state.densityKgL);

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          // Delivery density
          _Row(
            label: labelDensity,
            value: UnitConverter.formatDensity(state.densityKgL, sys),
            unit:  UnitConverter.densityUnit(sys),
          ),
          // API gravity — metric показывает дополнительно, US — основная
          if (sys == UnitSystem.us)
            _Row(
              label: 'Density kg/l',
              value: state.densityKgL.toStringAsFixed(4),
              unit:  'kg/l',
              muted: true,
            )
          else
            _Row(
              label: '°API gravity',
              value: apiVal.toStringAsFixed(1),
              unit:  '°API',
              muted: true,
            ),
          // Volume
          _Row(
            label: labelVolume,
            value: UnitConverter.formatVolume(state.volumeM3, sys),
            unit:  UnitConverter.volumeUnit(sys),
          ),
          // Mass
          _Row(
            label: labelMass,
            value: UnitConverter.formatMass(state.massT, sys),
            unit:  UnitConverter.massUnit(sys),
            muted: true,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Divider(height: 1, thickness: 0.5, color: AppColors.divider),
          const SizedBox(height: AppSpacing.xs),
          // Thermal expansion
          _Row(
            label:      labelExpansion,
            value:      expansionVal,
            unit:       UnitConverter.expansionUnit(sys),
            valueColor: expColor,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color? valueColor;
  final bool   muted;

  const _Row({
    required this.label,
    required this.value,
    required this.unit,
    this.valueColor,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.detailRowV),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: AppText.detailKey.copyWith(
                    color: muted ? AppColors.textHint : null)),
          ),
          Text(
            value,
            style: AppText.detailValue.copyWith(
              color: valueColor ?? (muted ? AppColors.textHint : null),
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 72,
            child: Text(unit,
                style: AppText.detailUnit,
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
