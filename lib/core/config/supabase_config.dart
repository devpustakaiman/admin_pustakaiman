import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const String supabaseUrl = 'https://bswcdqzgjitgpcekviuv.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_AIHXtPkry6-pIk0ldJjsgA_CvrkDBFY';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
  }
}
