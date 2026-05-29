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
    final l = AppL10n.of(context);

    return AppShell(
      title: l.menuEscalation,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: AppSpacing.screenPadding,
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: AppSpacing.md),
                _FuelBasisCard(state: state),
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

class _FuelBasisCard extends StatelessWidget {
  final EscalationState state;
  const _FuelBasisCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final isGasoil = state.product.family == FuelFamily.diesel;
    final fuelLabel = isGasoil ? 'GASOIL' : 'GASOLINE';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: PopupMenuButton<FuelFamily>(
              onSelected: (family) {
                final product =
                    kFuelGrades.firstWhere((f) => f.family == family);
                state.setProduct(product);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: FuelFamily.diesel,
                  child: Text('GASOIL'),
                ),
                PopupMenuItem(
                  value: FuelFamily.gasoline,
                  child: Text('GASOLINE'),
                ),
              ],
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      fuelLabel,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.detailValue.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.accent,
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 1,
            height: 30,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            color: AppColors.border,
          ),
          _DensityBasisSwitch(state: state),
        ],
      ),
    );
  }
}

class _DensityBasisSwitch extends StatelessWidget {
  final EscalationState state;
  const _DensityBasisSwitch({required this.state});

  @override
  Widget build(BuildContext context) {
    final isAir = state.basis == DensityBasis.air;

    return GestureDetector(
      onTap: () => state.setBasis(
        isAir ? DensityBasis.vac : DensityBasis.air,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 132,
        height: 44,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: isAir ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 62,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      'VAC',
                      style: AppText.detailValue.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isAir ? AppColors.textSecondary : Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'AIR',
                      style: AppText.detailValue.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isAir ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
    final l = AppL10n.of(context);

    return Column(
      children: [
        LabeledInputField(
          label: l.labelContractDensity,
          unit: 'kg/l',
          initialValue: state.contractDensityRaw,
          error: errors['contractDensity'],
          onChanged: (v) => state.updateField('contractDensity', v),
        ),
        LabeledInputField(
          label: l.labelActualDensity15,
          unit: 'kg/l',
          initialValue: state.actualDensityRaw,
          error: errors['actualDensity'],
          onChanged: (v) => state.updateField('actualDensity', v),
        ),
        LabeledInputField(
          label: l.labelAverageQuotation,
          unit: r'$/t',
          initialValue: state.averagePlattsRaw,
          error: errors['averagePlatts'],
          onChanged: (v) => state.updateField('averagePlatts', v),
        ),
        LabeledInputField(
          label: l.labelSellerPremium,
          unit: r'$/t',
          initialValue: state.sellerPremiumRaw,
          error: errors['sellerPremium'],
          onChanged: (v) => state.updateField('sellerPremium', v),
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
    final l = AppL10n.of(context);
    final sign = result.escalationPerTon >= 0 ? '+' : '';

    return Container(
      padding: AppSpacing.resultCardPadding,
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 92,
            decoration: BoxDecoration(
              color: AppColors.accent,
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
                  l.escalationBasePrice(result.basePrice.toStringAsFixed(2)),
                  style: AppText.detailKey,
                ),
                Text(
                  l.escalationTotalPremium(
                      result.totalPremium.toStringAsFixed(2)),
                  style: AppText.detailKey,
                ),
                Text(
                  l.escalationFinalPrice(result.finalPrice.toStringAsFixed(2)),
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
        color: AppColors.formulaBg,
        borderRadius: AppRadii.lgAll,
        border: Border.all(color: AppColors.border, width: 0.5),
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
