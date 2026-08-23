import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../routes/app_routes.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) {
      return const RouteSettings(name: AppRoutes.login);
    }
    return null;
  }
}
