import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/author.dart';
import '../controllers/author_controller.dart';

class AuthorManagementPage extends StatelessWidget {
  const AuthorManagementPage({super.key});

  Widget _buildAvatar(String photoUrl, {double radius = 20}) {
    final isValidUrl =
        photoUrl.startsWith('http://') || photoUrl.startsWith('https://');
    if (!isValidUrl) {
      return CircleAvatar(
        radius: radius,
        child: const Icon(Icons.person),
      );
    }
    return CircleAvatar(
      radius: radius,
      child: ClipOval(
        child: Image.network(
          photoUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.person),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthorController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Penulis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchAuthors(),
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
                  onPressed: () => controller.fetchAuthors(),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (controller.authors.isEmpty) {
          return const Center(
            child: Text('Belum ada data penulis.'),
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
        label: const Text('Tambah Penulis'),
      ),
    );
  }

  Widget _buildDataTable(BuildContext context, AuthorController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final bioWidth = (availableWidth - 360).clamp(100.0, 450.0);
            final spacing = availableWidth < 850 ? 12.0 : 24.0;
            final margin = availableWidth < 850 ? 12.0 : 24.0;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: availableWidth),
                child: DataTable(
                  columnSpacing: spacing,
                  horizontalMargin: margin,
                  columns: const [
                    DataColumn(label: Text('Foto')),
                    DataColumn(label: Text('Nama')),
                    DataColumn(label: Text('Biografi')),
                    DataColumn(label: Text('Tanggal Dibuat')),
                    DataColumn(label: Text('Aksi')),
                  ],
                  rows: controller.authors.map((author) {
                    return DataRow(
                      cells: [
                        DataCell(
                          _buildAvatar(author.photoUrl, radius: 20),
                        ),
                        DataCell(
                          Text(
                            author.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: bioWidth,
                            child: Text(
                              author.bio.isNotEmpty ? author.bio : '-',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            author.createdAt.toString().split(' ').first,
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                tooltip: 'Edit',
                                onPressed: () =>
                                    controller.openFormDialog(author: author),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Hapus',
                                onPressed: () => _confirmDelete(controller, author),
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

  Widget _buildListView(BuildContext context, AuthorController controller) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.authors.length,
      itemBuilder: (context, index) {
        final author = controller.authors[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: _buildAvatar(author.photoUrl, radius: 24),
            title: Text(
              author.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              author.bio.isNotEmpty ? author.bio : 'Tidak ada biografi',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  tooltip: 'Edit',
                  onPressed: () => controller.openFormDialog(author: author),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Hapus',
                  onPressed: () => _confirmDelete(controller, author),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(AuthorController controller, Author author) {
    Get.defaultDialog(
      title: 'Hapus Penulis',
      middleText: 'Apakah Anda yakin ingin menghapus "${author.name}"?',
      textCancel: 'Batal',
      textConfirm: 'Hapus',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back();
        controller.deleteAuthor(author.id);
      },
    );
  }
}
