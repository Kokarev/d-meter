import 'package:flutter/material.dart';
import '../../../../core/tokens.dart';

/// Слайдер температуры с live отображением текущего значения.
class DensitySlider extends StatelessWidget {
  final double             value;
  final double             min;
  final double             max;
  final ValueChanged<double> onChanged;
  final String             label;

  const DensitySlider({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical:   AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: AppText.detailKey),
              const Spacer(),
              Text(
                '${value.toStringAsFixed(1)} °C',
                style: AppText.detailValue.copyWith(
                  color: AppColors.accent,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor:   AppColors.accent,
              inactiveTrackColor: AppColors.surfaceAlt,
              thumbColor:         AppColors.accent,
              overlayColor:       AppColors.accent.withAlpha(25),
              trackHeight:        3,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value:     value.clamp(min, max),
              min:       min,
              max:       max,
              divisions: ((max - min) * 2).round(),
              onChanged: onChanged,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${min.toStringAsFixed(0)}°C',
                    style: AppText.detailUnit.copyWith(fontSize: 9)),
                Text('${max.toStringAsFixed(0)}°C',
                    style: AppText.detailUnit.copyWith(fontSize: 9)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
