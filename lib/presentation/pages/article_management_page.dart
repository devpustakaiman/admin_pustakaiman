import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/article.dart';
import '../controllers/article_controller.dart';

class ArticleManagementPage extends StatelessWidget {
  const ArticleManagementPage({super.key});

  Widget _buildArticleImage(String imageUrl, {double width = 70, double height = 70}) {
    final isValidUrl = imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
    if (!isValidUrl) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.inputFillColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(LucideIcons.fileText, color: AppTheme.textMuted, size: 24),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: AppTheme.inputFillColor,
          child: const Center(
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor),
            ),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          width: width,
          height: height,
          color: AppTheme.inputFillColor,
          child: const Icon(LucideIcons.imageOff, color: AppTheme.textMuted, size: 24),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArticleController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header Title
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manajemen Artikel',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Kelola publikasi artikel berita dan kabar pustaka',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Unified Action Bar (Search, Sort, Spacer, Refresh, Add)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Compact Search Input Field (Height 44)
                SizedBox(
                  width: 280,
                  height: 44,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderColor),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Obx(() {
                      return TextField(
                        onChanged: (val) => controller.searchQuery.value = val,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: 'Cari artikel, penulis...',
                          prefixIcon: const Icon(LucideIcons.search, size: 16, color: AppTheme.textSecondary),
                          suffixIcon: controller.searchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(LucideIcons.x, size: 14, color: AppTheme.textSecondary),
                                  onPressed: () {
                                    controller.searchQuery.value = '';
                                  },
                                )
                              : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                          fillColor: Colors.white,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(width: 12),

                // Sort By Dropdown (Height 44)
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderColor),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Obx(() {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.arrowUpDown, size: 16, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.sortBy.value,
                            icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppTheme.textSecondary),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                controller.sortBy.value = newValue;
                              }
                            },
                            items: const [
                              DropdownMenuItem(value: 'date', child: Text('Urut: Tanggal Artikel')),
                              DropdownMenuItem(value: 'title', child: Text('Urut: Judul')),
                              DropdownMenuItem(value: 'author', child: Text('Urut: Penulis')),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),

                const SizedBox(width: 12),

                // Asc / Desc Toggle Button (Height 44)
                Obx(() {
                  final isAsc = controller.isAscending.value;
                  return InkWell(
                    onTap: () => controller.isAscending.value = !isAsc,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderColor),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Icon(
                        isAsc ? LucideIcons.arrowUp : LucideIcons.arrowDown,
                        size: 18,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  );
                }),

                // Pushes Refresh and Add buttons neatly to the far right!
                const Spacer(),

                // Refresh Button (IconButton, Height 44)
                IconButton(
                  onPressed: () => controller.fetchArticles(),
                  icon: const Icon(LucideIcons.refreshCw, size: 18),
                  tooltip: 'Segarkan Data',
                  style: IconButton.styleFrom(
                    fixedSize: const Size(44, 44),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppTheme.borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Tambah Artikel Baru Button (ElevatedButton, Height 44)
                ElevatedButton.icon(
                  onPressed: () => controller.openFormDialog(),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('Tambah Artikel Baru'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Content List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.alertCircle, color: Colors.redAccent, size: 40),
                          const SizedBox(height: 12),
                          Text(
                            'Terjadi Kesalahan:\n${controller.errorMessage.value}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => controller.fetchArticles(),
                            icon: const Icon(LucideIcons.refreshCw, size: 16),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final displayArticles = controller.filteredArticles;

                if (displayArticles.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.fileText,
                            size: 48,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.searchQuery.value.isNotEmpty
                              ? 'Tidak ditemukan artikel dengan kata kunci "${controller.searchQuery.value}"'
                              : 'Belum ada artikel publikasi.',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (controller.searchQuery.value.isEmpty)
                          ElevatedButton.icon(
                            onPressed: () => controller.openFormDialog(),
                            icon: const Icon(LucideIcons.plus, size: 18),
                            label: const Text('Tambah Artikel Pertama'),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: displayArticles.length,
                  itemBuilder: (context, index) {
                    final article = displayArticles[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderColor),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            _buildArticleImage(article.imageUrl, width: 75, height: 75),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(LucideIcons.user, size: 13, color: AppTheme.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        article.author.isNotEmpty ? article.author : 'Redaksi',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(LucideIcons.calendar, size: 13, color: AppTheme.textMuted),
                                      const SizedBox(width: 4),
                                      Text(
                                        article.date.toString().split(' ').first,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(LucideIcons.edit3, size: 18, color: Colors.blueAccent),
                              tooltip: 'Edit Artikel',
                              onPressed: () => controller.openFormDialog(article: article),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.redAccent),
                              tooltip: 'Hapus Artikel',
                              onPressed: () => _confirmDelete(controller, article),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(ArticleController controller, Article article) {
    Get.defaultDialog(
      title: 'Hapus Artikel',
      middleText: 'Apakah Anda yakin ingin menghapus artikel "${article.title}"?',
      titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      middleTextStyle: const TextStyle(fontSize: 14),
      textCancel: 'Batal',
      textConfirm: 'Hapus',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () {
        Get.back();
        controller.deleteArticle(article.id);
      },
    );
  }
}
