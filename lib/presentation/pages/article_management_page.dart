import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_toast.dart';
import '../../domain/entities/article.dart';
import '../controllers/article_controller.dart';

class ArticleManagementPage extends StatelessWidget {
  const ArticleManagementPage({super.key});

  Widget _buildArticleImage(Article article, {double width = 56, double height = 56}) {
    debugPrint('RENDERING ARTICLE IMAGE [${article.title}]: ${article.imageUrl}');
    if (article.imageUrl.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          article.imageUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            debugPrint('IMAGE LOAD ERROR for ${article.imageUrl}: $error');

            // Support Web CORS Fallback (HTML proxy rendering for cross-origin URLs e.g. WordPress)
            if (kIsWeb && !article.imageUrl.contains('weserv.nl')) {
              final proxyUrl = 'https://images.weserv.nl/?url=${Uri.encodeComponent(article.imageUrl)}';
              return Image.network(
                proxyUrl,
                width: width,
                height: height,
                fit: BoxFit.cover,
                errorBuilder: (context, err2, st2) {
                  debugPrint('CORS FALLBACK ERROR for ${article.imageUrl}: $err2');
                  return _buildFallbackIcon(width: width, height: height);
                },
              );
            }

            return _buildFallbackIcon(width: width, height: height);
          },
        ),
      );
    }
    return _buildFallbackIcon(width: width, height: height);
  }

  Widget _buildFallbackIcon({double width = 56, double height = 56}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.description_outlined, color: Color(0xFF94A3B8)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ArticleController>();
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(controller, isMobile: true),
              const SizedBox(height: 20),
              _buildFilters(controller, isMobile: true),
              const SizedBox(height: 24),
              _buildContentList(context, controller, isMobileScroll: true),
              const SizedBox(height: 16),
              _buildPaginationFooter(context, controller, isMobile: true),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(controller, isMobile: false),
            const SizedBox(height: 20),
            _buildFilters(controller, isMobile: false),
            const SizedBox(height: 24),
            Expanded(
              child: _buildContentList(context, controller, isMobileScroll: false),
            ),
            const SizedBox(height: 16),
            _buildPaginationFooter(context, controller, isMobile: false),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ArticleController controller, {required bool isMobile}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Page Header Title
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Manajemen Artikel',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Obx(() {
              final total = controller.filteredArticles.length;
              final displayed = controller.paginatedArticles.length;
              return Text(
                total == 0
                    ? 'Menampilkan 0 dari 0 artikel terdaftar'
                    : 'Menampilkan $displayed dari $total artikel terdaftar',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              );
            }),
          ],
        ),

        const SizedBox(height: 20),

        // Action Bar: Top Tier Search & Primary Actions
        if (isMobile) ...[
          SizedBox(
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
          const SizedBox(height: 12),
          Row(
            children: [
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
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => controller.openFormDialog(),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('Tambah Artikel'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ] else
          Row(
            children: [
              Expanded(
                child: SizedBox(
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
              ),
              const SizedBox(width: 12),
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
              ElevatedButton.icon(
                onPressed: () => controller.openFormDialog(),
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text('Tambah Artikel'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildFilters(ArticleController controller, {required bool isMobile}) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
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
      ],
    );
  }

  Widget _buildContentList(BuildContext context, ArticleController controller, {required bool isMobileScroll}) {
    return Obx(() {
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

      final displayArticles = controller.paginatedArticles;

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
        shrinkWrap: isMobileScroll,
        physics: isMobileScroll ? const NeverScrollableScrollPhysics() : null,
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
                  _buildArticleImage(article, width: 56, height: 56),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.user, size: 13, color: AppTheme.textSecondary),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    article.author.isNotEmpty ? article.author : 'Redaksi',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
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
                    onPressed: () => _confirmDelete(context, controller, article),
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
    });
  }

  Widget _buildPaginationFooter(BuildContext context, ArticleController controller, {required bool isMobile}) {
    return Obx(() {
      final total = controller.filteredArticles.length;
      final page = controller.currentPage.value;
      final pageSize = controller.pageSize;
      final start = total == 0 ? 0 : (page * pageSize) + 1;
      final end = ((page + 1) * pageSize).clamp(0, total);
      final hasPrev = page > 0;
      final hasNext = (page + 1) * pageSize < total;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderColor),
          boxShadow: AppTheme.softShadow,
        ),
        child: isMobile
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    total > 0
                        ? 'Menampilkan $start - $end dari $total artikel'
                        : 'Menampilkan 0 dari 0',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: hasPrev ? controller.prevPage : null,
                        icon: const Icon(LucideIcons.chevronLeft, size: 16),
                        tooltip: 'Sebelumnya',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          'Halaman ${page + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: hasNext ? controller.nextPage : null,
                        icon: const Icon(LucideIcons.chevronRight, size: 16),
                        tooltip: 'Selanjutnya',
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    total > 0
                        ? 'Menampilkan $start - $end dari $total artikel (Halaman ${page + 1})'
                        : 'Menampilkan 0 dari 0',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: hasPrev ? controller.prevPage : null,
                        icon: const Icon(LucideIcons.chevronLeft, size: 14),
                        label: const Text('Sebelumnya'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Halaman ${page + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: hasNext ? controller.nextPage : null,
                        icon: const Icon(LucideIcons.chevronRight, size: 14),
                        label: const Text('Selanjutnya'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      );
    });
  }

  void _confirmDelete(BuildContext context, ArticleController controller, Article article) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Artikel', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin memindahkan artikel "${article.title}" ke Keranjang Sampah?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await controller.deleteArticle(article.id);
              if (context.mounted) {
                AppToast.showSuccess(context, 'Artikel "${article.title}" dipindahkan ke Keranjang Sampah.');
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
