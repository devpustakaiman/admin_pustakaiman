import 'package:get/get.dart';
import '../../main.dart';
import '../../presentation/bindings/dashboard_binding.dart';
import '../../presentation/pages/login_page.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: AppRoutes.mainLayout,
      page: () => const AppAuthGate(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.bookManagement,
      page: () => const AppAuthGate(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.submissionManagement,
      page: () => const AppAuthGate(),
      binding: DashboardBinding(),
    ),
  ];
}

