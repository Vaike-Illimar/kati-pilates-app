import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/supabase_config.dart';
import 'config/routes.dart' show checkUserRole;
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupabaseConfig.initialize();

  // Pre-fetch user role if already logged in (cached session)
  await checkUserRole();

  runApp(
    const ProviderScope(
      child: KatiPilatesApp(),
    ),
  );
}
