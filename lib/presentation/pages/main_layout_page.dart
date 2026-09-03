import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/main_layout_controller.dart';
import '../widgets/custom_sidebar.dart';
import 'article_management_page.dart';
import 'author_management_page.dart';
import 'book_management_page.dart';
import 'dashboard_page.dart';
import 'submission_management_page.dart';
import 'trash_management_page.dart';
import 'video_management_page.dart';
import 'web_settings_page.dart';

class MainLayoutPage extends StatelessWidget {
  const MainLayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainLayoutController>();
    final pages = const [
      DashboardPage(),
      BookManagementPage(),
      SubmissionManagementPage(),
      AuthorManagementPage(),
      ArticleManagementPage(),
      VideoManagementPage(),
      WebSettingsPage(),
      TrashManagementPage(),
    ];

    final pageTitles = const [
      'Dashboard',
      'Katalog Buku',
      'Naskah Masuk',
      'Data Penulis',
      'Artikel & Berita',
      'Video Media',
      'Pengaturan Web',
      'Keranjang Sampah',
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 840;

        if (isMobile) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppTheme.sidebarColor,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Obx(() {
                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.shieldCheck, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      pageTitles[controller.selectedIndex.value],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              }),
            ),
            drawer: const Drawer(
              backgroundColor: AppTheme.sidebarColor,
              child: SafeArea(
                child: CustomSidebar(),
              ),
            ),
            body: Obx(() {
              return pages[controller.selectedIndex.value];
            }),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              const CustomSidebar(),
              Expanded(
                child: Obx(() {
                  return pages[controller.selectedIndex.value];
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
