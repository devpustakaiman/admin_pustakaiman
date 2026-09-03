import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_toast.dart';
import '../controllers/book_controller.dart';
import '../widgets/category_filter_selector.dart';
import '../widgets/tri_state_filter_button.dart';

class BookManagementPage extends StatelessWidget {
  const BookManagementPage({super.key});

  Widget _buildCoverImage(String coverUrl, {double width = 60, double height = 85}) {
    final isValidUrl = coverUrl.startsWith('http://') || coverUrl.startsWith('https://');
    if (!isValidUrl) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.inputFillColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(LucideIcons.book, color: AppTheme.textMuted, size: 24),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: coverUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: width,
          height: height,
          color: AppTheme.inputFillColor,
          child: const Center(
            child: SizedBox(
              width: 16,
              height: 16,
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

  String _formatPrice(num price) {
    if (price <= 0) return 'Gratis / Belum diatur';
    final priceInt = price.toInt();
    final buffer = StringBuffer();
    final str = priceInt.toString();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return 'Rp ${buffer.toString()}';
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'Hari ini';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final day = dt.day;
    final month = months[dt.month - 1];
    final year = dt.year;
    return '$day $month $year';
  }

  String _formatShortDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = (dt.year % 100).toString().padLeft(2, '0');
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header Title
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Katalog Buku',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() => Text(
                      'Menampilkan ${controller.filteredBooks.length} dari ${controller.books.length} buku terdaftar',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    )),
              ],
            ),

            const SizedBox(height: 20),

            // Responsive Two-Tier Action Bar (Top Tier: Search & Primary Actions, Bottom Tier: Wrap Filters)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tier: Search TextField (Expanded) + Refresh IconButton + Tambah Buku ElevatedButton
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
                                hintText: 'Cari buku, penulis...',
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

                    const SizedBox(width: 16),

                    // Refresh Button (IconButton, Height 44)
                    IconButton(
                      onPressed: () => controller.fetchBooks(),
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

                    // Tambah Baru Button (ElevatedButton, Height 44)
                    ElevatedButton.icon(
                      onPressed: () => controller.openFormDialog(),
                      icon: const Icon(LucideIcons.plus, size: 18),
                      label: const Text('Tambah Buku Baru'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Bottom Tier: Wrap (Filters & Sorting, Auto-Line Break for Small Screens)
                Wrap(
                  spacing: 12.0,
                  runSpacing: 12.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // Category Filter Selector Dropdown
                    CategoryFilterSelector(controller: controller),

                    // Promo Tri-State Filter Button
                    Obx(() => TriStateFilterButton(
                          value: controller.promoFilter.value,
                          label: 'Promo',
                          activeLabel: 'Promo',
                          inactiveLabel: 'Non-Promo',
                          icon: LucideIcons.tag,
                          onChanged: (val) => controller.promoFilter.value = val,
                        )),

                    // Recommendation Tri-State Filter Button
                    Obx(() => TriStateFilterButton(
                          value: controller.recommendedFilter.value,
                          label: 'Rekomendasi',
                          activeLabel: 'Rekomendasi',
                          inactiveLabel: 'Non-Rekomendasi',
                          icon: LucideIcons.sparkles,
                          onChanged: (val) => controller.recommendedFilter.value = val,
                        )),

                    // Sort By Field Dropdown (Height 44, Includes Date)
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
                            const Icon(LucideIcons.arrowUpDown, size: 15, color: AppTheme.primaryColor),
                            const SizedBox(width: 6),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: controller.sortBy.value,
                                icon: const Icon(LucideIcons.chevronDown, size: 15, color: AppTheme.textSecondary),
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    controller.sortBy.value = newValue;
                                  }
                                },
                                items: const [
                                  DropdownMenuItem(value: 'title', child: Text('Urut: Judul')),
                                  DropdownMenuItem(value: 'date', child: Text('Urut: Tanggal Dibuat')),
                                  DropdownMenuItem(value: 'author', child: Text('Urut: Penulis')),
                                  DropdownMenuItem(value: 'price', child: Text('Urut: Harga')),
                                  DropdownMenuItem(value: 'category', child: Text('Urut: Kategori')),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),

                    // Ascending / Descending Toggle Button (Height 44)
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
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Main Book Display List
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
                            onPressed: () => controller.fetchBooks(),
                            icon: const Icon(LucideIcons.refreshCw, size: 16),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final displayBooks = controller.filteredBooks;

                if (displayBooks.isEmpty) {
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
                            LucideIcons.bookOpen,
                            size: 48,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.searchQuery.value.isNotEmpty
                              ? 'Tidak ditemukan buku dengan kata kunci "${controller.searchQuery.value}"'
                              : 'Belum ada data buku dalam katalog.',
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
                            label: const Text('Tambah Buku Pertama'),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: displayBooks.length,
                  itemBuilder: (context, index) {
                    final book = displayBooks[index];

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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cover Thumbnail Preview
                            _buildCoverImage(book.coverUrl, width: 70, height: 95),

                            const SizedBox(width: 16),

                            // Book Information Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          book.title,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                      ),
                                      // Category Pill Badge
                                      if (book.category.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: AppTheme.primaryColor.withValues(alpha: 0.2),
                                            ),
                                          ),
                                          child: Text(
                                            book.category,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),

                                  const SizedBox(height: 6),

                                  // Author & Price Row with Promo Support
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(LucideIcons.user, size: 14, color: AppTheme.textSecondary),
                                          const SizedBox(width: 6),
                                          Text(
                                            book.author.isNotEmpty ? book.author : 'Penulis Tidak Diketahui',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 4,
                                            height: 4,
                                            margin: const EdgeInsets.symmetric(horizontal: 4),
                                            decoration: const BoxDecoration(
                                              color: AppTheme.textMuted,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          if (book.isPromo && book.promoPrice != null) ...[
                                            Text(
                                              _formatPrice(book.promoPrice!),
                                              style: const TextStyle(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              _formatPrice(book.price),
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                decoration: TextDecoration.lineThrough,
                                                color: AppTheme.textMuted,
                                              ),
                                            ),
                                          ] else ...[
                                            Text(
                                              _formatPrice(book.price),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.primaryColor,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  // Synopsis snippet
                                  if (book.synopsis.isNotEmpty)
                                    Text(
                                      book.synopsis,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                        height: 1.3,
                                      ),
                                    ),

                                  const SizedBox(height: 10),

                                  // Marketing & Media Badges (Gold Recommended, Red Promo, Gallery, PDF)
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        // Gold Recommended Badge
                                        if (book.isRecommended) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFEF3C7),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: const Color(0xFFF59E0B)),
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(LucideIcons.sparkles, size: 12, color: Color(0xFFD97706)),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Rekomendasi',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFB45309),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],

                                        // Red Promo Badge
                                        if (book.isPromo) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFEE2E2),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: const Color(0xFFEF4444)),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(LucideIcons.tag, size: 12, color: Colors.redAccent),
                                                const SizedBox(width: 4),
                                                Text(
                                                  () {
                                                    final parts = <String>[];
                                                    if (book.promoPercentage != null) {
                                                      parts.add('${book.promoPercentage}%');
                                                    }
                                                    if (book.promoEndDate != null) {
                                                      parts.add('Ends: ${_formatShortDate(book.promoEndDate!)}');
                                                    }
                                                    if (parts.isEmpty) {
                                                      return 'Promo';
                                                    }
                                                    return 'Promo (${parts.join(" • ")})';
                                                  }(),
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.redAccent,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],

                                        if (book.galleryUrls.isNotEmpty) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppTheme.inputFillColor,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(LucideIcons.image, size: 12, color: AppTheme.textSecondary),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${book.galleryUrls.length} Foto Galeri',
                                                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                        if (book.pdfPreviewUrl.isNotEmpty) ...[
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppTheme.inputFillColor,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Row(
                                              children: [
                                                Icon(LucideIcons.fileText, size: 12, color: AppTheme.primaryColor),
                                                SizedBox(width: 4),
                                                Text(
                                                  'PDF Tersedia',
                                                  style: TextStyle(fontSize: 11, color: AppTheme.primaryColor),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  // Soft Date Display Footer (created_at & updated_at)
                                  Text(
                                    'Ditambahkan: ${_formatDate(book.createdAt)} | Terakhir diedit: ${_formatDate(book.updatedAt)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 16),

                            // Action Buttons (Edit & Delete)
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(LucideIcons.edit3, size: 18, color: Colors.blueAccent),
                                  tooltip: 'Edit Buku',
                                  onPressed: () => controller.openFormDialog(book: book),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                IconButton(
                                  icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.redAccent),
                                  tooltip: 'Hapus Buku',
                                  onPressed: () => _confirmDelete(context, controller, book),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            // Pagination Controls Footer Bar
            Obx(() {
              final total = controller.totalBooksCount.value;
              final page = controller.currentPage.value;
              final pageSize = controller.pageSize;
              final start = total == 0 ? 0 : (page * pageSize) + 1;
              final end = ((page + 1) * pageSize).clamp(0, total);
              final hasPrev = page > 0;
              final hasNext = (page + 1) * pageSize < total;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderColor),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      total > 0
                          ? 'Menampilkan $start - $end dari $total buku (Halaman ${page + 1})'
                          : 'Belum ada data buku',
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
            }),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, BookController controller, dynamic book) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Buku', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin memindahkan buku "${book.title}" ke Keranjang Sampah?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await controller.deleteBook(book.id);
              if (context.mounted) {
                AppToast.showSuccess(context, 'Buku "${book.title}" dipindahkan ke Keranjang Sampah.');
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
