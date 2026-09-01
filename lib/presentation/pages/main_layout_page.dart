import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_layout_controller.dart';
import '../widgets/custom_sidebar.dart';
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
          const CustomSidebar(),
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
