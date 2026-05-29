import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_header.dart';
import '../../menu/app_menu_drawer.dart';
import '../state/calculator_state.dart';
import 'widgets/fuel_dropdown.dart';
import 'widgets/labeled_input_field.dart';
import 'widgets/mode_selector.dart';
import 'widgets/details_panel.dart';
import 'widgets/result_card.dart';
import 'package:flutter/services.dart';
import '../../settings/ui/settings_screen.dart';

class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CalculatorState(),
      child: const _CalculatorView(),
    );
  }
}

class _CalculatorView extends StatelessWidget {
  const _CalculatorView();

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.comma, meta: true): () =>
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          drawerEdgeDragWidth: 0,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColorsDark.background
              : AppColors.background,
          drawer: const AppMenuDrawer(),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SafeArea(child: _Body(title: l.menuDensityCalculator)),
            ),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final String title;
  const _Body({required this.title});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CalculatorState>();
    final l = AppL10n.of(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: AppHeader(title: title),
        ),
        SliverPadding(
          padding: AppSpacing.screenPadding,
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: AppSpacing.sm),

              // ── Fuel selector ────────────────────────────────────────
              _SectionLabel(l.sectionFuel),
              const SizedBox(height: AppSpacing.xs + 2),
              FuelDropdown(
                selected: state.fuel,
                onChanged: (f) => state.setFuel(f),
              ),
              const SizedBox(height: AppSpacing.md + 2),

              // ── Mode selector ────────────────────────────────────────
              ModeSelectorWidget(
                current: state.mode,
                onChanged: (m) => state.setMode(m),
              ),
              const SizedBox(height: AppSpacing.md + 2),

              // ── Inputs ───────────────────────────────────────────────
              _SectionLabel(l.sectionParameters),
              const SizedBox(height: AppSpacing.xs + 2),
              _InputsSection(state: state),
              const SizedBox(height: AppSpacing.xs),

              // ── Result card + adaptive Details ─────────────────────────────
              // Mobile: Details › в ResultCard → bottom sheet.
              // Desktop (>= 600): DetailsPanel раскрывается inline под картой.
              if (state.result != null) ...[
                ResultCard(result: state.result!, mode: state.mode),
                const SizedBox(height: AppSpacing.sm),
                if (Theme.of(context).platform == TargetPlatform.macOS ||
                    Theme.of(context).platform == TargetPlatform.windows ||
                    Theme.of(context).platform == TargetPlatform.linux)
                  DetailsPanel(
                    result:   state.result!,
                    mode:     state.mode,
                    isOpen:   state.detailsOpen,
                    onToggle: state.toggleDetails,
                  ),
                const SizedBox(height: AppSpacing.md),
              ],

              // ── Info hint ─────────────────────────────────────────────
              _InfoHint(mode: state.mode),
              const SizedBox(height: AppSpacing.xl),
            ]),
          ),
        ),
      ],
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: AppText.sectionLabel);
}

// ─── Inputs ───────────────────────────────────────────────────────────────────

class _InputsSection extends StatelessWidget {
  final CalculatorState state;
  const _InputsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final errors = state.errors;
    final l = AppL10n.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabeledInputField(
          label: l.labelP15,
          unit: 'kg/m³',
          initialValue: state.p15Raw,
          error: errors['p15'],
          onChanged: (v) => state.updateField('p15', v),
        ),
        if (state.mode == CalcMode.densityAtTemp) ...[
          LabeledInputField(
            label: l.labelDeliveryTemp,
            unit: '°C',
            initialValue: state.tempRaw,
            error: errors['temp'],
            onChanged: (v) => state.updateField('temp', v),
          ),
          LabeledInputField(
            label: l.labelWeight,
            unit: 't',
            initialValue: state.weightRaw,
            error: errors['weight'],
            onChanged: (v) => state.updateField('weight', v),
          ),
        ] else ...[
          LabeledInputField(
            label: l.labelActualDensity,
            unit: 'kg/l',
            initialValue: state.densityRaw,
            error: errors['density'],
            onChanged: (v) => state.updateField('density', v),
          ),
          LabeledInputField(
            label: l.labelVolume,
            unit: 'm³',
            initialValue: state.volumeRaw,
            error: errors['volume'],
            onChanged: (v) => state.updateField('volume', v),
          ),
        ],
      ],
    );
  }
}

// ─── Info hint ────────────────────────────────────────────────────────────────

class _InfoHint extends StatelessWidget {
  final CalcMode mode;
  const _InfoHint({required this.mode});

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final text = mode == CalcMode.densityAtTemp ? l.hintModeA : l.hintModeB;

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColorsDark.surface : AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColorsDark.border : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColorsDark.textHint : AppColors.textHint,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppText.detailKey.copyWith(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColorsDark.textSecondary : AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
