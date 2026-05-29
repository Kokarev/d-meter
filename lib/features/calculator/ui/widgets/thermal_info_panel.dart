import 'package:flutter/material.dart';
import '../../../../core/tokens.dart';
import '../../models/thermal_state.dart';

/// Панель live-результатов при движении слайдера:
/// Density / Volume / Mass / Thermal expansion.
///
/// Theme-aware: читает brightness из BuildContext.
/// Light — AppColors.*, Dark — AppColorsDark.*
/// Публичный API и расчётная логика не изменены.
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
    final isDark       = Theme.of(context).brightness == Brightness.dark;
    final isExpanded   = state.thermalExpansionL >= 0;
    final expSign      = isExpanded ? '+' : '';

    // Thermal expansion color — warning (positive) or accent (negative)
    final expColor = isExpanded
        ? (isDark ? AppColorsDark.warning : AppColors.warning)
        : (isDark ? AppColorsDark.accent  : AppColors.accent);

    // Container colors
    final surfaceColor = isDark ? AppColorsDark.surface : AppColors.surface;
    final borderColor  = isDark ? AppColorsDark.border  : AppColors.border;
    final dividerColor = isDark ? AppColorsDark.divider : AppColors.divider;
    final hintColor    = isDark ? AppColorsDark.textHint : AppColors.textHint;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color:        surfaceColor,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        children: [
          _Row(label: labelDensity,
               value: state.densityKgL.toStringAsFixed(4),
               unit:  'kg/l',
               hintColor: hintColor),
          _Row(label: labelVolume,
               value: state.volumeM3.toStringAsFixed(3),
               unit:  'm³',
               hintColor: hintColor),
          _Row(label: labelMass,
               value: state.massT.toStringAsFixed(3),
               unit:  't',
               muted: true,
               hintColor: hintColor),
          const SizedBox(height: AppSpacing.xs),
          Divider(height: 1, thickness: 0.5, color: dividerColor),
          const SizedBox(height: AppSpacing.xs),
          _Row(
            label:      labelExpansion,
            value:      '$expSign${state.thermalExpansionL.toStringAsFixed(1)}',
            unit:       'L vs 15°C',
            valueColor: expColor,
            hintColor:  hintColor,
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
  final Color  hintColor;

  const _Row({
    required this.label,
    required this.value,
    required this.unit,
    required this.hintColor,
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
                    color: muted ? hintColor : null)),
          ),
          Text(
            value,
            style: AppText.detailValue.copyWith(
              color: valueColor ?? (muted ? hintColor : null),
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
