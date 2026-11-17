import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

class ShawafApp extends StatelessWidget {
  const ShawafApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SHAWAF AI — Industrial Control Room',
      debugShowCheckedModeBanner: false,
      locale: const Locale('en', 'US'),
      supportedLocales: const [Locale('en', 'US')],
      theme: AppTheme.darkTheme,
      routerConfig: appRouter,
    );
  }
}
