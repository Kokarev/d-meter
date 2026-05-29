import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/fuel_grade.dart';
import '../../../core/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/state/density_memory.dart';
import '../../calculator/models/density_point.dart';
import '../../calculator/ui/widgets/density_chart.dart';
import '../../calculator/ui/widgets/density_slider.dart';
import '../../calculator/ui/widgets/thermal_info_panel.dart';
import '../state/visualization_state.dart';
import '../utils/unit_converter.dart';

class DensityVisualizationScreen extends StatelessWidget {
  const DensityVisualizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VisualizationState(
        initialP15KgM3: DensityMemory.p15VacKgM3,
        initialFamily: DensityMemory.family,
      ),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View();

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                _VizHeader(title: l.vizScreenTitle),
                const Expanded(child: _Body()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VizHeader extends StatelessWidget {
  final String title;

  const _VizHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 600;
    final state  = context.watch<VisualizationState>();

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          if (!isWide) ...[
            GestureDetector(
              onTap: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: AppRadii.smAll,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  color: AppColors.accent,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'D-',
                  style: AppText.sectionLabel.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: isWide ? 20 : null,
                  ),
                ),
                TextSpan(
                  text: 'METER',
                  style: AppText.sectionLabel.copyWith(
                    color: AppColors.brand,
                    fontSize: isWide ? 20 : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              title,
              style: AppText.sectionLabel,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isWide)
            TextButton.icon(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.chevron_left_rounded),
              label: const Text('Calculator'),
            ),
          const SizedBox(width: AppSpacing.xs),
          _SystemToggle(
            isUs:      state.unitSystem == UnitSystem.us,
            onChanged: state.setUnitSystem,
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VisualizationState>();
    final l = AppL10n.of(context);

    final operatingPoint = DensityPoint(
      tempC: state.sliderTempC,
      densityKgL: state.thermalState.densityKgL,
    );

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        const SizedBox(height: AppSpacing.sm),
        const Text('FUEL', style: AppText.sectionLabel),
        const SizedBox(height: AppSpacing.xs + 2),
        _FuelToggle(
          isDiesel: state.fuel.family == FuelFamily.diesel,
          onDiesel: () => state.setFuel(
            kFuelGrades.firstWhere((f) => f.family == FuelFamily.diesel),
          ),
          onGasoline: () => state.setFuel(
            kFuelGrades.firstWhere((f) => f.family == FuelFamily.gasoline),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(l.vizChartTitle.toUpperCase(), style: AppText.sectionLabel),
        const SizedBox(height: AppSpacing.xs + 2),
        DensityChart(
          curve:          state.passportCurve,
          operatingPoint: operatingPoint,
          unitSystem:     state.unitSystem,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            const _LegendDot(color: AppColors.accent),
            const SizedBox(width: 4),
            Text(l.vizLegendPassport, style: AppText.detailUnit),
            const SizedBox(width: AppSpacing.md),
            const _LegendDot(color: AppColors.brand),
            const SizedBox(width: 4),
            Text(l.vizLegendOperating, style: AppText.detailUnit),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        DensitySlider(
          value: state.sliderTempC,
          min: state.sliderMin,
          max: state.sliderMax,
          onChanged: state.setSliderTemp,
          label: l.labelDeliveryTemp,
        ),
        const SizedBox(height: AppSpacing.md),
        const _QuantityCard(),
        const SizedBox(height: AppSpacing.md),
        ThermalInfoPanel(
          state: state.thermalState,
          labelDensity: l.resultDeliveryDensity,
          labelVolume: l.detailVolume,
          labelMass: l.detailWeight,
          labelExpansion: l.vizThermalExpansion,
          unitSystem:     state.unitSystem,
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _QuantityCard extends StatelessWidget {
  const _QuantityCard();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<VisualizationState>();
    final unitText = state.quantityUnit == QuantityUnit.m3 ? 'm³' : 't';
    final isFineVolumeRange = state.quantityUnit == QuantityUnit.m3 &&
        state.quantityRange == QuantityRange.r1to100;
    final valueDecimals = isFineVolumeRange ? 3 : 0;
    final sliderDivisions = isFineVolumeRange ? 99000 : 1000;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Quantity', style: AppText.detailKey),
              const Spacer(),
              _UnitButton(
                label: 'm³',
                active: state.quantityUnit == QuantityUnit.m3,
                onTap: () => state.setQuantityUnit(QuantityUnit.m3),
              ),
              const SizedBox(width: 6),
              _UnitButton(
                label: 't',
                active: state.quantityUnit == QuantityUnit.tonnes,
                onTap: () => state.setQuantityUnit(QuantityUnit.tonnes),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Text(
                state.quantityValue.toStringAsFixed(valueDecimals),
                style: AppText.detailValue.copyWith(color: AppColors.accent),
              ),
              const SizedBox(width: 6),
              Text(unitText, style: AppText.detailUnit),
              const Spacer(),
              Text(state.quantityRange.description, style: AppText.detailUnit),
            ],
          ),
          Slider(
            value: state.quantityValue.clamp(
              state.quantityRange.min,
              state.quantityRange.max,
            ),
            min: state.quantityRange.min,
            max: state.quantityRange.max,
            divisions: sliderDivisions,
            onChanged: state.setQuantityValue,
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: QuantityRange.values.map((r) {
              return _RangeChip(
                range: r,
                active: r == state.quantityRange,
                onTap: () => state.setQuantityRange(r),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _UnitButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _UnitButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.accent : AppColors.surfaceAlt,
          borderRadius: AppRadii.smAll,
        ),
        child: Text(
          label,
          style: active ? AppText.modeActive : AppText.modeInactive,
        ),
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  final QuantityRange range;
  final bool active;
  final VoidCallback onTap;

  const _RangeChip({
    required this.range,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.accent : AppColors.surfaceAlt,
          borderRadius: AppRadii.smAll,
        ),
        child: Text(
          range.label,
          style: active ? AppText.modeActive : AppText.detailUnit,
        ),
      ),
    );
  }
}

class _FuelToggle extends StatelessWidget {
  final bool isDiesel;
  final VoidCallback onDiesel;
  final VoidCallback onGasoline;

  const _FuelToggle({
    required this.isDiesel,
    required this.onDiesel,
    required this.onGasoline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          _Tab(label: 'Diesel', active: isDiesel, onTap: onDiesel),
          _Tab(label: 'Gasoline', active: !isDiesel, onTap: onGasoline),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: active ? AppColors.accent : Colors.transparent,
            borderRadius: AppRadii.smAll,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: active ? AppText.modeActive : AppText.modeInactive,
          ),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;

  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ── Unit system toggle ────────────────────────────────────────────────────────

class _SystemToggle extends StatelessWidget {
  final bool isUs;
  final ValueChanged<UnitSystem> onChanged;
  const _SystemToggle({required this.isUs, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color:        AppColors.surfaceAlt,
        borderRadius: AppRadii.smAll,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SysChip(label: 'SI', active: !isUs,
              onTap: () => onChanged(UnitSystem.metric)),
          _SysChip(label: 'US', active: isUs,
              onTap: () => onChanged(UnitSystem.us)),
        ],
      ),
    );
  }
}

class _SysChip extends StatelessWidget {
  final String       label;
  final bool         active;
  final VoidCallback onTap;
  const _SysChip({required this.label, required this.active,
                  required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm + 2, vertical: 4),
        decoration: BoxDecoration(
          color:        active ? AppColors.accent : Colors.transparent,
          borderRadius: AppRadii.smAll,
        ),
        child: Text(label,
          style: TextStyle(
            fontSize:   11,
            fontWeight: FontWeight.w600,
            color: active ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
