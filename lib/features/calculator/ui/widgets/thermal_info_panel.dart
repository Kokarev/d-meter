import 'package:flutter/material.dart';
import '../../../../core/tokens.dart';
import '../../models/thermal_state.dart';

/// Панель live-результатов при движении слайдера:
/// Density / Volume / Mass / Thermal expansion.
class ThermalInfoPanel extends StatelessWidget {
  final ThermalState state;
  final String labelDensity;
  final String labelVolume;
  final String labelMass;
  final String labelExpansion;

  const ThermalInfoPanel({
    super.key,
    required this.state,
    required this.labelDensity,
    required this.labelVolume,
    required this.labelMass,
    required this.labelExpansion,
  });

  @override
  Widget build(BuildContext context) {
    final isExpanded   = state.thermalExpansionL >= 0;
    final expColor     = isExpanded ? AppColors.warning : AppColors.accent;
    final expSign      = isExpanded ? '+' : '';

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          _Row(label: labelDensity,
               value: state.densityKgL.toStringAsFixed(4),
               unit:  'kg/l'),
          _Row(label: labelVolume,
               value: state.volumeM3.toStringAsFixed(3),
               unit:  'm³'),
          _Row(label: labelMass,
               value: state.massT.toStringAsFixed(3),
               unit:  't',
               muted: true),
          const SizedBox(height: AppSpacing.xs),
          const Divider(height: 1, thickness: 0.5,
              color: AppColors.divider),
          const SizedBox(height: AppSpacing.xs),
          _Row(
            label:      labelExpansion,
            value:
                '$expSign${state.thermalExpansionL.toStringAsFixed(1)}',
            unit:       'L vs 15°C',
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
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.detailRowV),
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
              color: valueColor ??
                     (muted ? AppColors.textHint : null),
              fontFeatures:
                  const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 4),
          SizedBox(
            width: 56,
            child: Text(unit,
                style: AppText.detailUnit,
                textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
