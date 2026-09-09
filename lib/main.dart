import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';
import 'core/routes/app_pages.dart';
import 'core/theme/app_theme.dart';
import 'presentation/bindings/dashboard_binding.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/main_layout_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pustaka Iman Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialBinding: DashboardBinding(),
      home: const AppAuthGate(),
      getPages: AppPages.pages,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: FlutterQuillLocalizations.supportedLocales,
    );
  }
}

class AppAuthGate extends StatelessWidget {
  const AppAuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // 1. Jika masih menunggu inisialisasi awal stream
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Jika session sinkron sudah ada dari memori, langsung tampilkan MainLayoutPage
          if (Supabase.instance.client.auth.currentSession != null) {
            return const MainLayoutPage();
          }
          return const Scaffold(
            backgroundColor: AppTheme.sidebarColor,
            body: Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryLight,
              ),
            ),
          );
        }

        final session = snapshot.data?.session ?? Supabase.instance.client.auth.currentSession;

        // 2. Jika sesi valid, buka MainLayoutPage (yang akan memulihkan view terakhir)
        if (session != null) {
          return const MainLayoutPage();
        }

        // 3. Hanya buka LoginPage jika benar-benar terkonfirmasi TIDAK ada sesi
        return const LoginPage();
      },
    );
  }
}

