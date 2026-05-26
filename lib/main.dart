import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/tokens.dart';
import 'features/calculator/ui/calculator_screen.dart';
import 'l10n/app_localizations.dart';

void main() => runApp(const DmeterApp());

class DmeterApp extends StatelessWidget {
  const DmeterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'D-METER',
      debugShowCheckedModeBanner: false,
      locale: const Locale('uk'),
      localizationsDelegates: const [
        AppL10n.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppL10n.supportedLocales,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: AppColors.accent,
          secondary: AppColors.brand,
          surface: AppColors.surface,
          error: AppColors.danger,
        ),
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const CalculatorScreen(),
    );
  }
}
