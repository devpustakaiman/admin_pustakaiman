import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../pages/login_page.dart';
import '../pages/main_layout_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isAuthLoading = true;
  Session? _session;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _initAuthGate();
  }

  void _initAuthGate() {
    try {
      final initialSession = Supabase.instance.client.auth.currentSession;
      if (initialSession != null) {
        _session = initialSession;
        _isAuthLoading = false;
      }
    } catch (_) {}

    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        final currentSession = data.session;
        if (mounted) {
          setState(() {
            _session = currentSession;
            _isAuthLoading = false;
          });
        }
      },
      onError: (err) {
        debugPrint('AuthGate listener error: $err');
        if (mounted && _isAuthLoading) {
          setState(() {
            _isAuthLoading = false;
          });
        }
      },
    );

    // Fallback timer (400ms) in case auth state event is delayed
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted && _isAuthLoading) {
        try {
          final fallbackSession = Supabase.instance.client.auth.currentSession;
          setState(() {
            _session = fallbackSession;
            _isAuthLoading = false;
          });
        } catch (_) {
          setState(() {
            _isAuthLoading = false;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAuthLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.sidebarColor,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryLight,
          ),
        ),
      );
    }

    if (_session == null) {
      return const LoginPage();
    }

    return const MainLayoutPage();
  }
}
