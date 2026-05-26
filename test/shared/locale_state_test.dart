import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:d_meter/shared/state/locale_state.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('LocaleState', () {
    test('load with no saved value -> locale is null', () async {
      final state = LocaleState();

      await state.load();

      expect(state.locale, isNull);
    });

    test('setLocale updates locale', () async {
      final state = LocaleState();

      await state.setLocale(const Locale('uk'));

      expect(state.locale, const Locale('uk'));
    });

    test('setLocale persists across instances', () async {
      final stateA = LocaleState();

      await stateA.setLocale(const Locale('uk'));

      SharedPreferences.setMockInitialValues({
        'app_locale': 'uk',
      });

      final stateB = LocaleState();

      await stateB.load();

      expect(stateB.locale, const Locale('uk'));
    });

    test('load ignores unsupported locale codes', () async {
      SharedPreferences.setMockInitialValues({
        'app_locale': 'fr',
      });

      final state = LocaleState();

      await state.load();

      expect(state.locale, isNull);
    });

    test('resetToSystem clears locale', () async {
      SharedPreferences.setMockInitialValues({
        'app_locale': 'uk',
      });

      final state = LocaleState();

      await state.load();

      await state.resetToSystem();

      expect(state.locale, isNull);
    });

    test('setLocale notifies listeners', () async {
      final state = LocaleState();

      var notified = false;

      state.addListener(() {
        notified = true;
      });

      await state.setLocale(const Locale('uk'));

      expect(notified, isTrue);
    });

    test('setLocale with same locale does NOT notify', () async {
      final state = LocaleState();

      await state.setLocale(const Locale('uk'));

      var count = 0;

      state.addListener(() {
        count++;
      });

      await state.setLocale(const Locale('uk'));

      expect(count, 0);
    });

    test('resetToSystem when null does NOT notify', () async {
      final state = LocaleState();

      var notified = false;

      state.addListener(() {
        notified = true;
      });

      await state.resetToSystem();

      expect(notified, isFalse);
    });

    test('setLocale throws on unsupported locale', () async {
      final state = LocaleState();

      expect(
        () async => state.setLocale(const Locale('fr')),
        throwsArgumentError,
      );
    });

    test('displayCode returns УК for uk', () {
      final state = LocaleState();

      expect(state.displayCode('uk'), 'УК');
    });

    test('displayCode returns EN for en', () {
      final state = LocaleState();

      expect(state.displayCode('en'), 'EN');
    });

    test('displayCode returns EN for unknown code', () {
      final state = LocaleState();

      expect(state.displayCode('fr'), 'EN');
    });
  });
}
