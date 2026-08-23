import 'package:get/get.dart';
import '../../presentation/bindings/dashboard_binding.dart';
import '../../presentation/pages/book_management_page.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/main_layout_page.dart';
import '../../presentation/pages/submission_management_page.dart';
import '../middleware/auth_middleware.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: AppRoutes.mainLayout,
      page: () => const MainLayoutPage(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.bookManagement,
      page: () => const BookManagementPage(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware()],
    ),
    GetPage(
      name: AppRoutes.submissionManagement,
      page: () => const SubmissionManagementPage(),
      binding: DashboardBinding(),
      middlewares: [AuthMiddleware()],
    ),
  ];
}
