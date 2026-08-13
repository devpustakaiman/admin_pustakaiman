import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/article.dart';
import '../controllers/article_controller.dart';

class ArticleManagementPage extends StatelessWidget {
  const ArticleManagementPage({super.key});

  Widget _buildArticleImage(String imageUrl, {double width = 45, double height = 45}) {
    final isValidUrl =
        imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
    if (!isValidUrl) {
      return const Icon(Icons.article);
    }
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.article),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArticleController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Artikel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchArticles(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Terjadi Kesalahan:\n${controller.errorMessage.value}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchArticles(),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (controller.articles.isEmpty) {
          return const Center(
            child: Text('Belum ada data artikel.'),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 600) {
              return _buildDataTable(context, controller);
            }
            return _buildListView(context, controller);
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.openFormDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Artikel'),
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, ArticleController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: availableWidth),
                child: DataTable(
                  columnSpacing: 10,
                  horizontalMargin: 12,
                  columns: const [
                    DataColumn(label: Text('Gambar')),
                    DataColumn(label: Text('Judul')),
                    DataColumn(label: Text('Penulis')),
                    DataColumn(label: Text('Tanggal')),
                    DataColumn(label: Text('Dibuat')),
                    DataColumn(label: Text('Aksi')),
                  ],
                  rows: controller.articles.map((article) {
                    return DataRow(
                      cells: [
                        DataCell(
                          _buildArticleImage(article.imageUrl, width: 40, height: 40),
                        ),
                        DataCell(
                          SizedBox(
                            width: 140,
                            child: Text(
                              article.title,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 80,
                            child: Text(
                              article.author.isNotEmpty ? article.author : '-',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(article.date.toString().split(' ').first),
                        ),
                        DataCell(
                          Text(article.createdAt.toString().split(' ').first),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                tooltip: 'Edit',
                                onPressed: () =>
                                    controller.openFormDialog(article: article),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Hapus',
                                onPressed: () => _confirmDelete(controller, article),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context, ArticleController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.articles.length,
      itemBuilder: (context, index) {
        final article = controller.articles[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: _buildArticleImage(article.imageUrl, width: 45, height: 45),
            title: Text(
              article.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${article.author} • ${article.date.toString().split(' ').first}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Edit',
                  onPressed: () => controller.openFormDialog(article: article),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Hapus',
                  onPressed: () => _confirmDelete(controller, article),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(ArticleController controller, Article article) {
    Get.defaultDialog(
      title: 'Hapus Artikel',
      middleText: 'Apakah Anda yakin ingin menghapus "${article.title}"?',
      textCancel: 'Batal',
      textConfirm: 'Hapus',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.deleteArticle(article.id);
      },
    );
  }
}
