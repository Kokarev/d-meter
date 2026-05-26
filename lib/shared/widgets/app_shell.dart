import 'package:flutter/material.dart';

import '../../core/tokens.dart';
import '../../features/menu/app_menu_drawer.dart';
import 'app_header.dart';

class AppShell extends StatelessWidget {
  final String title;
  final Widget child;

  const AppShell({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppMenuDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(title: title),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
