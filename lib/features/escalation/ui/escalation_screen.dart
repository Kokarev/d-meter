import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/fuel_grade.dart';
import '../../../core/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../calculator/ui/widgets/labeled_input_field.dart';
import '../service/escalation_service.dart';
import '../state/escalation_state.dart';

class EscalationScreen extends StatelessWidget {
  const EscalationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EscalationState(),
      child: const _EscalationView(),
    );
  }
}

class _EscalationView extends StatelessWidget {
  const _EscalationView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<EscalationState>();
    final l     = AppL10n.of(context);

    return AppShell(
      title: l.menuEscalation,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: AppSpacing.screenPadding,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppSpacing.md),
                _GroupSelector(state: state),
                const SizedBox(height: AppSpacing.sm),
                _ProductSelector(state: state),
                const SizedBox(height: AppSpacing.md),
                Text(l.sectionDensityBasis.toUpperCase(),
                    style: AppText.sectionLabel),
                const SizedBox(height: AppSpacing.xs),
                _BasisSelector(state: state),
                const SizedBox(height: AppSpacing.md),
                Text(l.sectionParameters.toUpperCase(),
                    style: AppText.sectionLabel),
                const SizedBox(height: AppSpacing.xs),
                _Inputs(state: state),
                if (state.result != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _ResultCard(result: state.result!),
                  const SizedBox(height: AppSpacing.sm),
                  const _FormulaNote(),
                ],
                const SizedBox(height: AppSpacing.xl),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _GroupSelector extends StatelessWidget {
  final EscalationState state;
  const _GroupSelector({required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    String groupLabel(FuelProductGroup g) => switch (g) {
          FuelProductGroup.gasoil   => l.fuelGroupGasoil,
          FuelProductGroup.gasoline => l.fuelGroupGasoline,
        };

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color:        AppColors.surfaceAlt,
        borderRadius: AppRadii.lgAll,
      ),
      child: Row(
        children: FuelProductGroup.values.map((group) {
          final active = state.group == group;
          return Expanded(
            child: GestureDetector(
              onTap: () => state.setGroup(group),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color:        active ? AppColors.accentBg : Colors.transparent,
                  borderRadius: AppRadii.mdAll,
                ),
                child: Text(
                  groupLabel(group),
                  textAlign: TextAlign.center,
                  style: AppText.dropdownItem.copyWith(
                    color:      active ? AppColors.accent : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ProductSelector extends StatelessWidget {
  final EscalationState state;
  const _ProductSelector({required this.state});

  @override
  Widget build(BuildContext context) {
    // FuelGrade.name values are industry-standard and intentionally NOT localized.
    return PopupMenuButton<FuelGrade>(
      color: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadii.lgAll),
      onSelected: state.setProduct,
      itemBuilder: (_) => state.availableProducts.map((p) {
        return PopupMenuItem<FuelGrade>(
          value: p,
          child: Text(
            p.name,
            style: AppText.dropdownItem.copyWith(
              color: p.id == state.product.id
                  ? AppColors.accent
                  : AppColors.textPrimary,
              fontWeight:
                  p.id == state.product.id ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical:   AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color:        AppColors.surface,
          borderRadius: AppRadii.mdAll,
          border:       Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                state.product.name,
                style: AppText.dropdownItem.copyWith(
                  color:      AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size:  18,
              color: AppColors.accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _BasisSelector extends StatelessWidget {
  final EscalationState state;
  const _BasisSelector({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color:        AppColors.surfaceAlt,
        borderRadius: AppRadii.lgAll,
      ),
      child: Row(
        children: [
          // VAC and AIR are ISO standard basis names — intentionally not translated.
          _BasisButton(
            label:  'VAC',
            active: state.basis == DensityBasis.vac,
            onTap:  () => state.setBasis(DensityBasis.vac),
          ),
          _BasisButton(
            label:  'AIR',
            active: state.basis == DensityBasis.air,
            onTap:  () => state.setBasis(DensityBasis.air),
          ),
        ],
      ),
    );
  }
}

class _BasisButton extends StatelessWidget {
  final String     label;
  final bool       active;
  final VoidCallback onTap;

  const _BasisButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color:        active ? AppColors.accentBg : Colors.transparent,
            borderRadius: AppRadii.mdAll,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppText.dropdownItem.copyWith(
              color:      active ? AppColors.accent : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _Inputs extends StatelessWidget {
  final EscalationState state;
  const _Inputs({required this.state});

  @override
  Widget build(BuildContext context) {
    final errors = state.errors;
    final l      = AppL10n.of(context);

    return Column(
      children: [
        LabeledInputField(
          label:        l.labelContractDensity,
          unit:         'kg/l',
          initialValue: state.contractDensityRaw,
          error:        errors['contractDensity'],
          onChanged:    (v) => state.updateField('contractDensity', v),
        ),
        LabeledInputField(
          label:        l.labelActualDensity15,
          unit:         'kg/l',
          initialValue: state.actualDensityRaw,
          error:        errors['actualDensity'],
          onChanged:    (v) => state.updateField('actualDensity', v),
        ),
        LabeledInputField(
          label:        l.labelAverageQuotation,
          unit:         r'$/t',
          initialValue: state.averagePlattsRaw,
          error:        errors['averagePlatts'],
          onChanged:    (v) => state.updateField('averagePlatts', v),
        ),
        LabeledInputField(
          label:        l.labelSellerPremium,
          unit:         r'$/t',
          initialValue: state.sellerPremiumRaw,
          error:        errors['sellerPremium'],
          onChanged:    (v) => state.updateField('sellerPremium', v),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final EscalationResult result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final l    = AppL10n.of(context);
    final sign = result.escalationPerTon >= 0 ? '+' : '';

    return Container(
      padding: AppSpacing.resultCardPadding,
      decoration: BoxDecoration(
        color:        AppColors.cardSurface,
        borderRadius: AppRadii.lgAll,
        border:       Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width:  3,
            height: 92,
            decoration: BoxDecoration(
              color:        AppColors.accent,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // "ESCALATION" is the commercial term — kept in English.
                Text(l.escalationSectionLabel, style: AppText.sectionLabel),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$sign${result.escalationPerTon.toStringAsFixed(2)}',
                      style: AppText.resultPrimary,
                    ),
                    const SizedBox(width: 6),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6),
                      child: Text(r'$/t', style: AppText.resultUnit),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l.escalationBasePrice(
                      result.basePrice.toStringAsFixed(2)),
                  style: AppText.detailKey,
                ),
                Text(
                  l.escalationTotalPremium(
                      result.totalPremium.toStringAsFixed(2)),
                  style: AppText.detailKey,
                ),
                Text(
                  l.escalationFinalPrice(
                      result.finalPrice.toStringAsFixed(2)),
                  style: AppText.detailKey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormulaNote extends StatelessWidget {
  const _FormulaNote();

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color:        AppColors.formulaBg,
        borderRadius: AppRadii.lgAll,
        border:       Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.formulaLabel, style: AppText.formulaLabel),
          const SizedBox(height: 6),
          // Formulas contain only math — not translated.
          const Text(
            'Esc = Base × (Contract / Actual − 1)',
            style: AppText.formulaStandard,
          ),
          const SizedBox(height: 6),
          const Text(
            'AIR = VAC / 1.00135178',
            style: AppText.formulaStandard,
          ),
        ],
      ),
    );
  }
}
