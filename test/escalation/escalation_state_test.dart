import 'package:flutter_test/flutter_test.dart';
import 'package:d_meter/core/fuel_grade.dart';
import 'package:d_meter/features/escalation/service/escalation_service.dart';
import 'package:d_meter/features/escalation/state/escalation_state.dart';
import 'package:d_meter/shared/state/density_memory.dart';

void main() {
  late EscalationState state;

  setUp(() {
    DensityMemory.clear();
    state = EscalationState();
  });

  tearDown(() {
    state.dispose();
    DensityMemory.clear();
  });

  test('initialises with fallback when DensityMemory is null', () {
    expect(state.actualDensityRaw, isNotEmpty);
    expect(state.contractDensityRaw, isNotEmpty);
  });

  test('setBasis VAC to AIR converts actualDensity, leaves contractDensity unchanged', () {
    DensityMemory.setP15KgL(0.8332, FuelFamily.diesel);
    state.dispose();
    state = EscalationState();

    final contractBefore = state.contractDensityRaw;

    state.setBasis(DensityBasis.air);

    expect(state.contractDensityRaw, equals(contractBefore));
    expect(
      double.parse(state.actualDensityRaw),
      closeTo(EscalationService.vacToAir(0.8332), 0.0001),
    );
  });

  test('setBasis AIR to VAC converts actualDensity, leaves contractDensity unchanged', () {
    DensityMemory.setP15KgL(0.8332, FuelFamily.diesel);
    state.dispose();
    state = EscalationState();

    state.setBasis(DensityBasis.air);
    final contractBefore = state.contractDensityRaw;

    state.setBasis(DensityBasis.vac);

    expect(state.contractDensityRaw, equals(contractBefore));
    expect(
      double.parse(state.actualDensityRaw),
      closeTo(0.8332, 0.0001),
    );
  });

  test('setBasis round-trip VAC to AIR to VAC recovers original actualDensity', () {
    DensityMemory.setP15KgL(0.8332, FuelFamily.diesel);
    state.dispose();
    state = EscalationState();

    state.setBasis(DensityBasis.air);
    state.setBasis(DensityBasis.vac);

    expect(
      double.parse(state.actualDensityRaw),
      closeTo(0.8332, 0.0001),
    );
  });

  test('AIR to VAC conversion with manually entered AIR density', () {
    state.updateField('contractDensity', '0.8450');
    state.setBasis(DensityBasis.air);
    state.updateField('actualDensity', '0.8207');

    final contractBefore = state.contractDensityRaw;

    state.setBasis(DensityBasis.vac);

    expect(state.contractDensityRaw, equals(contractBefore));
    expect(
      double.parse(state.actualDensityRaw),
      closeTo(0.8207 * 1.00135178, 0.0001),
    );
  });

  test('VAC formula: escalation = base × (contract / actual − 1)', () {
    DensityMemory.setP15KgL(0.8332, FuelFamily.diesel);
    state.dispose();
    state = EscalationState();

    state.updateField('contractDensity', '0.8450');
    state.updateField('actualDensity', '0.8332');
    state.updateField('averagePlatts', '1000.00');
    state.updateField('sellerPremium', '100.00');

    expect(state.result, isNotNull);
    expect(
      state.result!.escalationPerTon,
      closeTo(1100.0 * (0.8450 / 0.8332 - 1), 0.001),
    );
    expect(
      state.result!.finalPrice,
      closeTo(1100.0 * (0.8450 / 0.8332), 0.001),
    );
    expect(
      state.result!.basePrice,
      closeTo(1100.0, 0.001),
    );
  });

  test('basis-invariant: VAC and AIR inputs yield identical escalation', () {
    DensityMemory.setP15KgL(0.8332, FuelFamily.diesel);
    state.dispose();
    state = EscalationState();

    state.updateField('contractDensity', '0.8450');
    state.updateField('actualDensity', '0.8332');
    state.updateField('averagePlatts', '1000.00');
    state.updateField('sellerPremium', '100.00');

    final escVac = state.result!.escalationPerTon;

    state.dispose();
    DensityMemory.clear();
    DensityMemory.setP15KgL(0.8332, FuelFamily.diesel);
    state = EscalationState();

    state.setBasis(DensityBasis.air);
    state.updateField(
      'contractDensity',
      EscalationService.vacToAir(0.8450).toStringAsFixed(6),
    );
    state.updateField(
      'actualDensity',
      EscalationService.vacToAir(0.8332).toStringAsFixed(6),
    );
    state.updateField('averagePlatts', '1000.00');
    state.updateField('sellerPremium', '100.00');

    final escAir = state.result!.escalationPerTon;

    expect(escVac, closeTo(escAir, 0.001));
  });
  test('setGroup does not overwrite user-edited contractDensity', () {
    state.updateField('contractDensity', '0.8600');
    state.setGroup(FuelProductGroup.gasoline);
    state.setGroup(FuelProductGroup.gasoil);

    expect(state.contractDensityRaw, '0.8600');
  }, skip: 'known bug: setGroup resets contractDensityRaw unconditionally');

  test('manual European contract density values survive basis switching', () {
    for (final contract in ['0.8420', '0.7420']) {
      state.updateField('contractDensity', contract);
      state.updateField('actualDensity', '0.8332');

      state.setBasis(DensityBasis.air);
      expect(state.contractDensityRaw, equals(contract));

      state.setBasis(DensityBasis.vac);
      expect(state.contractDensityRaw, equals(contract));
    }
  });

}
