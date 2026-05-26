import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/tokens.dart';
import 'features/calculator/ui/calculator_screen.dart';
import 'l10n/app_localizations.dart';
import 'shared/state/locale_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeState = LocaleState();
  await localeState.load();
  runApp(DmeterApp(localeState: localeState));
}

class DmeterApp extends StatelessWidget {
  final LocaleState localeState;
  const DmeterApp({super.key, required this.localeState});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LocaleState>.value(
      value: localeState,
      child: Consumer<LocaleState>(
        builder: (_, state, __) => MaterialApp(
          title: 'D-METER',
          debugShowCheckedModeBanner: false,
          locale: state.locale,
          localizationsDelegates: const [
            AppL10n.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppL10n.supportedLocales,
          theme: ThemeData(
            colorScheme: const ColorScheme.light(
              primary:   AppColors.accent,
              secondary: AppColors.brand,
              surface:   AppColors.surface,
              error:     AppColors.danger,
            ),
            scaffoldBackgroundColor: AppColors.background,
            fontFamily: 'Roboto',
            useMaterial3: true,
          ),
          home: const CalculatorScreen(),
        ),
      ),
    );
  }
}
