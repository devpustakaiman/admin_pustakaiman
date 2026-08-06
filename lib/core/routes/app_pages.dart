import 'package:get/get.dart';
import '../../presentation/bindings/dashboard_binding.dart';
import '../../presentation/pages/book_management_page.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.bookManagement,
      page: () => const BookManagementPage(),
      binding: DashboardBinding(),
    ),
  ];
}
