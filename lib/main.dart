import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'features/calculator/ui/calculator_screen.dart';
import 'l10n/app_localizations.dart';
import 'shared/state/locale_state.dart';
import 'shared/state/theme_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeState = LocaleState();
  final themeState = ThemeState();
  await Future.wait([localeState.load(), themeState.load()]);
  runApp(DmeterApp(localeState: localeState, themeState: themeState));
}

class DmeterApp extends StatelessWidget {
  final LocaleState localeState;
  final ThemeState themeState;
  const DmeterApp({
    super.key,
    required this.localeState,
    required this.themeState,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleState>.value(value: localeState),
        ChangeNotifierProvider<ThemeState>.value(value: themeState),
      ],
      child: Consumer2<LocaleState, ThemeState>(
        builder: (_, locale, theme, __) => MaterialApp(
          title: 'D-METER',
          debugShowCheckedModeBanner: false,
          locale: locale.locale,
          localizationsDelegates: const [
            AppL10n.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppL10n.supportedLocales,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: theme.mode,
          home: const CalculatorScreen(),
        ),
      ),
    );
  }
}
