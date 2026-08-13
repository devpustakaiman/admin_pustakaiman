import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/book_controller.dart';

class BookManagementPage extends StatelessWidget {
  const BookManagementPage({super.key});

  Widget _buildCoverImage(String coverUrl, {double width = 50, double height = 50}) {
    final isValidUrl =
        coverUrl.startsWith('http://') || coverUrl.startsWith('https://');
    if (!isValidUrl) {
      return const Icon(Icons.book);
    }
    return Image.network(
      coverUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Icon(Icons.book),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Buku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchBooks(),
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
                  onPressed: () => controller.fetchBooks(),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (controller.books.isEmpty) {
          return const Center(
            child: Text('Belum ada data buku.'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.books.length,
          itemBuilder: (context, index) {
            final book = controller.books[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: _buildCoverImage(book.coverUrl),
                title: Text(
                  book.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${book.author} • ${book.category}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => controller.openFormDialog(book: book),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        Get.defaultDialog(
                          title: 'Hapus Buku',
                          middleText:
                              'Apakah Anda yakin ingin menghapus "${book.title}"?',
                          textCancel: 'Batal',
                          textConfirm: 'Hapus',
                          confirmTextColor: Colors.white,
                          buttonColor: Colors.red,
                          onConfirm: () {
                            Get.back();
                            controller.deleteBook(book.id);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.openFormDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
