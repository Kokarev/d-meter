import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/fuel_grade.dart';
import '../../../core/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_header.dart';
import '../../calculator/models/density_point.dart';
import '../../calculator/ui/widgets/density_chart.dart';
import '../../calculator/ui/widgets/density_slider.dart';
import '../../calculator/ui/widgets/thermal_info_panel.dart';
import '../state/visualization_state.dart';

class DensityVisualizationScreen extends StatelessWidget {
  const DensityVisualizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VisualizationState(),
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
                AppHeader(title: l.vizScreenTitle),
                Expanded(child: _Body()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<VisualizationState>();
    final l     = AppL10n.of(context);

    final operatingPoint = DensityPoint(
      tempC:      state.sliderTempC,
      densityKgL: state.thermalState.densityKgL,
    );

    return ListView(
      padding: AppSpacing.screenPadding,
      children: [
        const SizedBox(height: AppSpacing.sm),

        // ── Fuel selector ──────────────────────────────────────────────
        Text('FUEL'.toUpperCase(), style: AppText.sectionLabel),
        const SizedBox(height: AppSpacing.xs + 2),
        _FuelToggle(
          isDiesel:  state.fuel.family == FuelFamily.diesel,
          onDiesel:  () => state.setFuel(kFuelGrades.firstWhere(
              (f) => f.family == FuelFamily.diesel)),
          onGasoline: () => state.setFuel(kFuelGrades.firstWhere(
              (f) => f.family == FuelFamily.gasoline)),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Chart ──────────────────────────────────────────────────────
        Text(l.vizChartTitle.toUpperCase(),
            style: AppText.sectionLabel),
        const SizedBox(height: AppSpacing.xs + 2),
        DensityChart(
          curve:          state.passportCurve,
          operatingPoint: operatingPoint,
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Legend ─────────────────────────────────────────────────────
        Row(
          children: [
            const _LegendDot(color: AppColors.accent),
            const SizedBox(width: 4),
            Text(l.vizLegendPassport,
                style: AppText.detailUnit),
            const SizedBox(width: AppSpacing.md),
            const _LegendDot(color: AppColors.brand),
            const SizedBox(width: 4),
            Text(l.vizLegendOperating,
                style: AppText.detailUnit),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Slider ─────────────────────────────────────────────────────
        DensitySlider(
          value:     state.sliderTempC,
          min:       state.sliderMin,
          max:       state.sliderMax,
          onChanged: state.setSliderTemp,
          label:     l.labelDeliveryTemp,
        ),
        const SizedBox(height: AppSpacing.md),

        // ── ThermalInfoPanel ───────────────────────────────────────────
        ThermalInfoPanel(
          state:          state.thermalState,
          labelDensity:   l.resultDeliveryDensity,
          labelVolume:    l.detailVolume,
          labelMass:      l.detailWeight,
          labelExpansion: l.vizThermalExpansion,
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

// ─── Widgets ──────────────────────────────────────────────────────────────────

class _FuelToggle extends StatelessWidget {
  final bool         isDiesel;
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
        color:        AppColors.surfaceAlt,
        borderRadius: AppRadii.mdAll,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          _Tab(label: 'Diesel',   active: isDiesel,  onTap: onDiesel),
          _Tab(label: 'Gasoline', active: !isDiesel, onTap: onGasoline),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String       label;
  final bool         active;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.active,
               required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm, horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            color:        active ? AppColors.accent : Colors.transparent,
            borderRadius: AppRadii.smAll,
          ),
          child: Text(label,
              textAlign: TextAlign.center,
              style: active ? AppText.modeActive : AppText.modeInactive),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: 8, height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
