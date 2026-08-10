import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_layout_controller.dart';
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
