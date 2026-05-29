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
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColorsDark.background
          : AppColors.background,
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

    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColorsDark.surface
          : AppColors.surface,
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
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColorsDark.surfaceAlt
                      : AppColors.surfaceAlt,
                  borderRadius: AppRadii.smAll,
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColorsDark.border
                        : AppColors.border,
                  ),
                ),
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColorsDark.accent
                      : AppColors.accent,
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
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColorsDark.textPrimary
                        : AppColors.textPrimary,
                    fontSize: isWide ? 20 : null,
                  ),
                ),
                TextSpan(
                  text: 'METER',
                  style: AppText.sectionLabel.copyWith(
                    color: AppColors.brand, // brand unchanged in dark
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

    // 🔵 Операционная точка: density @ delivery temp (движется)
    final operatingPoint = DensityPoint(
      tempC: state.sliderTempC,
      densityKgL: state.thermalState.densityKgL,
    );

    // 🔴 Паспортная точка: P15 @ 15°C (фиксирована)
    final referencePoint = DensityPoint(
      tempC: 15.0,
      densityKgL: state.p15KgM3 / 1000,
    );

    // Add bottom SafeArea padding for iPhone home indicator / nav bar.
    final bottomPad = MediaQuery.paddingOf(context).bottom;
    final listPadding = AppSpacing.screenPadding.copyWith(
      bottom: AppSpacing.screenPadding.bottom + bottomPad + AppSpacing.xl,
    );

    return ListView(
      padding: listPadding,
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
          curve: state.passportCurve,
          operatingPoint: operatingPoint,
          referencePoint: referencePoint,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _LegendDot(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColorsDark.accent
                  : AppColors.accent,
            ),
            const SizedBox(width: 4),
            Text(l.vizLegendOperating, style: AppText.detailUnit),
            const SizedBox(width: AppSpacing.md),
            const _LegendDot(color: AppColors.brand),
            const SizedBox(width: 4),
            Text(l.vizLegendPassport, style: AppText.detailUnit),
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
    // Стандартное обозначение массы: t (не tn)
    final unitText = state.quantityUnit == QuantityUnit.m3 ? 'm³' : 't';
    final isFineVolumeRange = state.quantityUnit == QuantityUnit.m3 &&
        state.quantityRange == QuantityRange.r1to100;
    // Всегда 3 знака после запятой
    const valueDecimals = 3;
    final sliderDivisions = ((state.quantityRange.max -
            state.quantityRange.min) *
        (isFineVolumeRange ? 10 : 1)).round();

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: border, width: 0.5),
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
          // Текстовый ввод + отображение значения
          _QuantityInput(
            value: state.quantityValue,
            unitText: unitText,
            decimals: valueDecimals,
            rangeMin: state.quantityRange.min,
            rangeMax: state.quantityRange.max,
            description: state.quantityRange.description,
            onChanged: state.setQuantityValue,
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor:   accent,
              inactiveTrackColor: surfaceAlt,
              thumbColor:         accent,
              overlayColor:       accent.withAlpha(25),
              trackHeight:        3,
              thumbShape:
                  const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: state.quantityValue.clamp(
                state.quantityRange.min,
                state.quantityRange.max,
              ),
              min: state.quantityRange.min,
              max: state.quantityRange.max,
              divisions: sliderDivisions,
              onChanged: state.setQuantityValue,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${state.quantityRange.min.toStringAsFixed(0)} $unitText',
                  style: AppText.detailUnit.copyWith(fontSize: 9),
                ),
                Text(
                  '${state.quantityRange.max.toStringAsFixed(0)} $unitText',
                  style: AppText.detailUnit.copyWith(fontSize: 9),
                ),
              ],
            ),
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

// ── Quantity input: текстовое поле + слайдер синхронизированы ──────────────
class _QuantityInput extends StatefulWidget {
  final double       value;
  final String       unitText;
  final int          decimals;
  final double       rangeMin;
  final double       rangeMax;
  final String       description;
  final ValueChanged<double> onChanged;

  const _QuantityInput({
    required this.value,
    required this.unitText,
    required this.decimals,
    required this.rangeMin,
    required this.rangeMax,
    required this.description,
    required this.onChanged,
  });

  @override
  State<_QuantityInput> createState() => _QuantityInputState();
}

class _QuantityInputState extends State<_QuantityInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.value.toStringAsFixed(widget.decimals),
    );
    _focusNode = FocusNode();
    // Когда поле теряет фокус — применяем введённое значение
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _onSubmit(_controller.text);
      }
    });
  }

  @override
  void didUpdateWidget(_QuantityInput old) {
    super.didUpdateWidget(old);
    // Слайдер изменил значение — синхронизируем поле
    // только когда TextField не в фокусе (пользователь не набирает)
    if (!_focusNode.hasFocus) {
      final newText = widget.value.toStringAsFixed(widget.decimals);
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSubmit(String raw) {
    final v = double.tryParse(raw.replaceAll(',', '.'));
    if (v != null) {
      final clamped = v.clamp(widget.rangeMin, widget.rangeMax);
      widget.onChanged(clamped);
      final newText = clamped.toStringAsFixed(widget.decimals);
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    } else {
      _controller.text = widget.value.toStringAsFixed(widget.decimals);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 108,
          child: TextField(
            controller: _controller,
            focusNode:  _focusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.right,
            style: AppText.detailValue.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColorsDark.accent
                  : AppColors.accent,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 6),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadii.smAll,
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColorsDark.border
                      : AppColors.border,
                  width: 0.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadii.smAll,
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColorsDark.accent
                      : AppColors.accent,
                  width: 1,
                ),
              ),
              suffixText: widget.unitText,
              suffixStyle: AppText.detailUnit,
            ),
            onSubmitted: _onSubmit,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            widget.description,
            style: AppText.detailUnit,
            textAlign: TextAlign.right,
          ),
        ),
      ],
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
          color: active
              ? (Theme.of(context).brightness == Brightness.dark
                  ? AppColorsDark.accent : AppColors.accent)
              : (Theme.of(context).brightness == Brightness.dark
                  ? AppColorsDark.surfaceAlt : AppColors.surfaceAlt),
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
          color: active
              ? (Theme.of(context).brightness == Brightness.dark
                  ? AppColorsDark.accent : AppColors.accent)
              : (Theme.of(context).brightness == Brightness.dark
                  ? AppColorsDark.surfaceAlt : AppColors.surfaceAlt),
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
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColorsDark.surfaceAlt : AppColors.surfaceAlt,
        borderRadius: AppRadii.mdAll,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColorsDark.border : AppColors.border,
          width: 0.5,
        ),
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
            color: active
                ? (Theme.of(context).brightness == Brightness.dark
                    ? AppColorsDark.accent : AppColors.accent)
                : Colors.transparent,
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
