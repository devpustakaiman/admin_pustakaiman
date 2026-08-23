import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/routes/app_routes.dart';
import '../controllers/main_layout_controller.dart';
import 'article_management_page.dart';
import 'author_management_page.dart';
import 'book_management_page.dart';
import 'submission_management_page.dart';

class MainLayoutPage extends StatelessWidget {
  const MainLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainLayoutController>();
    final pages = const [
      BookManagementPage(),
      SubmissionManagementPage(),
      AuthorManagementPage(),
      ArticleManagementPage(),
    ];

    return Scaffold(
      body: Row(
        children: [
          Obx(() {
            return NavigationRail(
              selectedIndex: controller.selectedIndex.value,
              onDestinationSelected: (int index) {
                controller.changePage(index);
              },
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Icon(
                  Icons.admin_panel_settings,
                  size: 32,
                  color: Colors.deepPurple,
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      tooltip: 'Keluar',
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut();
                        Get.offAllNamed(AppRoutes.login);
                      },
                    ),
                  ),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.book_outlined),
                  selectedIcon: Icon(Icons.book),
                  label: Text('Katalog Buku'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.inbox_outlined),
                  selectedIcon: Icon(Icons.inbox),
                  label: Text('Naskah Masuk'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: Text('Penulis'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.article_outlined),
                  selectedIcon: Icon(Icons.article),
                  label: Text('Artikel'),
                ),
              ],
            );
          }),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Obx(() {
              return pages[controller.selectedIndex.value];
            }),
          ),
        ],
      ),
    );
  }
}
