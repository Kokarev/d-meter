import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/fuel_grade.dart';
import '../../../core/tokens.dart';
import '../../../l10n/app_localizations.dart';
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

// ── Scaffold ──────────────────────────────────────────────────────────────────

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
                // Local header with Back button — does not touch AppHeader
                _VizHeader(title: l.vizScreenTitle),
                Expanded(child: _Body()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Local header ──────────────────────────────────────────────────────────────
// Intentionally separate from AppHeader to avoid modifying the main calculator
// header. Shows a back button on the left and the screen title in the center.

class _VizHeader extends StatelessWidget {
  final String title;
  const _VizHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical:   AppSpacing.sm,
      ),
      child: Row(
        children: [
          // Back button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: AppRadii.smAll,
              onTap: () => Navigator.of(context).pop(),
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),

          // Logo
          const Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('D-', style: AppText.logoD),
              Text('METER', style: AppText.logoMeter),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),

          // Screen title
          Expanded(
            child: Text(
              title,
              style: AppText.inputLabel.copyWith(
                color: AppColors.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

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

        // ── Fuel selector ─────────────────────────────────────────────
        const Text('FUEL', style: AppText.sectionLabel),
        const SizedBox(height: AppSpacing.xs + 2),
        _FuelToggle(
          isDiesel:   state.fuel.family == FuelFamily.diesel,
          onDiesel:   () => state.setFuel(kFuelGrades.firstWhere(
              (f) => f.family == FuelFamily.diesel)),
          onGasoline: () => state.setFuel(kFuelGrades.firstWhere(
              (f) => f.family == FuelFamily.gasoline)),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Chart ─────────────────────────────────────────────────────
        Text(l.vizChartTitle.toUpperCase(), style: AppText.sectionLabel),
        const SizedBox(height: AppSpacing.xs + 2),
        DensityChart(
          curve:          state.passportCurve,
          operatingPoint: operatingPoint,
        ),
        const SizedBox(height: AppSpacing.sm),

        // Chart legend
        Row(
          children: [
            const _LegendDot(color: AppColors.accent),
            const SizedBox(width: 4),
            Text(l.vizLegendPassport,  style: AppText.detailUnit),
            const SizedBox(width: AppSpacing.md),
            const _LegendDot(color: AppColors.brand),
            const SizedBox(width: 4),
            Text(l.vizLegendOperating, style: AppText.detailUnit),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Card 1: Temperature slider ────────────────────────────────
        DensitySlider(
          value:     state.sliderTempC,
          min:       state.sliderMin,
          max:       state.sliderMax,
          onChanged: state.setSliderTemp,
          label:     l.labelDeliveryTemp,
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Card 2: Quantity control ───────────────────────────────────
        _QuantityCard(state: state),
        const SizedBox(height: AppSpacing.md),

        // ── Card 3: Thermal info ───────────────────────────────────────
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

// ── Quantity card (Card 2) ────────────────────────────────────────────────────

class _QuantityCard extends StatelessWidget {
  final VisualizationState state;
  const _QuantityCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final range = state.quantityRange;
    final unit  = state.quantityUnit;
    final value = state.quantityValue;

    final unitLabel  = unit == QuantityUnit.m3 ? 'm³' : 't';
    final isM3       = unit == QuantityUnit.m3;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical:   AppSpacing.sm + 2,
      ),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row: label + unit toggle ───────────────────────────
          Row(
            children: [
              const Text('QUANTITY', style: AppText.sectionLabel),
              const Spacer(),
              // Unit toggle: [m³] [t]
              _UnitToggle(
                isM3:       isM3,
                onChanged: (m3) => state.setQuantityUnit(
                    m3 ? QuantityUnit.m3 : QuantityUnit.tonnes),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Slider with current value ─────────────────────────────────
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor:   AppColors.accent,
                    inactiveTrackColor: AppColors.surfaceAlt,
                    thumbColor:         AppColors.accent,
                    overlayColor:       AppColors.accent.withAlpha(25),
                    trackHeight:        3,
                    thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 7),
                    overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 16),
                  ),
                  child: Slider(
                    value:     value.clamp(range.min, range.max),
                    min:       range.min,
                    max:       range.max,
                    onChanged: state.setQuantityValue,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              // Current value — prominent
              SizedBox(
                width: 80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatValue(value),
                      style: AppText.detailValue.copyWith(
                        color:      AppColors.accent,
                        fontSize:   16,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [
                          FontFeature.tabularFigures()
                        ],
                      ),
                    ),
                    Text(
                      unitLabel,
                      style: AppText.detailUnit,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Range selector ────────────────────────────────────────────
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: QuantityRange.values.map((r) {
              final active = r == range;
              return Expanded(
                child: GestureDetector(
                  onTap: () => state.setQuantityRange(r),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(
                      vertical: 4, horizontal: 2,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.accent
                          : AppColors.surfaceAlt,
                      borderRadius: AppRadii.smAll,
                    ),
                    child: Text(
                      r.label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize:   8,
                        fontWeight: active
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: active
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatValue(double v) {
    if (v >= 10000) return v.toStringAsFixed(0);
    if (v >= 1000)  return v.toStringAsFixed(0);
    if (v >= 100)   return v.toStringAsFixed(1);
    return v.toStringAsFixed(1);
  }
}

// ── Unit toggle ───────────────────────────────────────────────────────────────

class _UnitToggle extends StatelessWidget {
  final bool                 isM3;
  final ValueChanged<bool>   onChanged;
  const _UnitToggle({required this.isM3, required this.onChanged});

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
          _UnitChip(label: 'm³', active: isM3,  onTap: () => onChanged(true)),
          _UnitChip(label: 't',  active: !isM3, onTap: () => onChanged(false)),
        ],
      ),
    );
  }
}

class _UnitChip extends StatelessWidget {
  final String       label;
  final bool         active;
  final VoidCallback onTap;
  const _UnitChip({required this.label, required this.active,
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
        child: Text(
          label,
          style: TextStyle(
            fontSize:   11,
            fontWeight: FontWeight.w500,
            color: active ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── Fuel toggle ───────────────────────────────────────────────────────────────

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
          _FuelTab(label: 'Diesel',   active: isDiesel,  onTap: onDiesel),
          _FuelTab(label: 'Gasoline', active: !isDiesel, onTap: onGasoline),
        ],
      ),
    );
  }
}

class _FuelTab extends StatelessWidget {
  final String       label;
  final bool         active;
  final VoidCallback onTap;
  const _FuelTab({required this.label, required this.active,
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

// ── Legend dot ────────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: 8, height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
