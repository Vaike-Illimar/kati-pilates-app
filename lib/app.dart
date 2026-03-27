import 'package:flutter/material.dart';

import 'config/theme.dart';
import 'config/routes.dart';

class KatiPilatesApp extends StatelessWidget {
  const KatiPilatesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kati Pilates',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
