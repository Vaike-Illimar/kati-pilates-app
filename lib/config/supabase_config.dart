import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // TODO: Replace with your Supabase project URL and anon key,
  // or load from environment variables / --dart-define.
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://nrdncrebjxvciapvcfph.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5yZG5jcmVianh2Y2lhcHZjZnBoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ2Mzg4NzksImV4cCI6MjA5MDIxNDg3OX0.PecrXbf6rVLT8tsEs_urFlDQNokF2LUHo-_zKy2cqdI',
  );

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
