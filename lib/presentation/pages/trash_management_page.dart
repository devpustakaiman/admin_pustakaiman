import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_toast.dart';
import '../../data/models/preorder_model.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/author.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/submission.dart';
import '../controllers/trash_controller.dart';

class TrashManagementPage extends StatelessWidget {
  const TrashManagementPage({super.key});

  String _formatDeletedAt(DateTime? date) {
    if (date == null) return 'Dihapus pada: -';
    final local = date.toLocal();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    final day = local.day;
    final monthStr = months[local.month - 1];
    final year = local.year;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return 'Dihapus pada: $day $monthStr $year, $hour:$minute';
  }

  void _showItemDetailDialog(BuildContext context, dynamic item) {
    String title = 'Detail Data';
    Widget contentWidget = const SizedBox.shrink();

    if (item is Book) {
      title = 'Detail Buku: ${item.title}';
      contentWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.coverUrl.isNotEmpty)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: item.coverUrl,
                  height: 160,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const Icon(LucideIcons.book, size: 60),
                ),
              ),
            ),
          const SizedBox(height: 16),
          _detailRow('Judul', item.title),
          _detailRow('Penulis', item.author.isNotEmpty ? item.author : '-'),
          _detailRow('Kategori', item.category.isNotEmpty ? item.category : '-'),
          _detailRow('Harga', item.price > 0 ? 'Rp ${item.price}' : 'Gratis'),
          if (item.isPromo)
            _detailRow('Harga Promo', 'Rp ${item.promoPrice} (${item.promoPercentage}%)'),
          _detailRow('Sinopsis', item.synopsis.isNotEmpty ? item.synopsis : '-'),
          _detailRow('Tanggal Dihapus', _formatDeletedAt(item.deletedAt)),
        ],
      );
    } else if (item is Author) {
      title = 'Detail Penulis: ${item.name}';
      contentWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.photoUrl.isNotEmpty)
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundImage: NetworkImage(item.photoUrl),
              ),
            ),
          const SizedBox(height: 16),
          _detailRow('Nama Penulis', item.name),
          _detailRow('Biografi', item.bio.isNotEmpty ? item.bio : '-'),
          _detailRow('Tanggal Terdaftar', item.createdAt.toString().split('.').first),
          _detailRow('Tanggal Dihapus', _formatDeletedAt(item.deletedAt)),
        ],
      );
    } else if (item is Article) {
      title = 'Detail Artikel: ${item.title}';
      contentWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.imageUrl.isNotEmpty)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl,
                  height: 140,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const Icon(LucideIcons.fileText, size: 50),
                ),
              ),
            ),
          const SizedBox(height: 16),
          _detailRow('Judul Artikel', item.title),
          _detailRow('Penulis / Redaksi', item.author.isNotEmpty ? item.author : 'Redaksi'),
          _detailRow('Konten Artikel', item.content.isNotEmpty ? item.content : '-'),
          _detailRow('Tanggal Rilis', item.date.toString().split('.').first),
          _detailRow('Tanggal Dihapus', _formatDeletedAt(item.deletedAt)),
        ],
      );
    } else if (item is Submission) {
      title = 'Detail Naskah: ${item.senderName}';
      contentWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailRow('Nama Pengirim', item.senderName),
          _detailRow('Email Pengirim', item.email),
          _detailRow('Status Naskah', item.status.toUpperCase()),
          _detailRow('Sinopsis Naskah', item.synopsis.isNotEmpty ? item.synopsis : '-'),
          if (item.pdfDocumentUrl.isNotEmpty)
            _detailRow('Link PDF Document', item.pdfDocumentUrl),
          _detailRow('Tanggal Kirim', item.createdAt.toString().split('.').first),
          _detailRow('Tanggal Dihapus', _formatDeletedAt(item.deletedAt)),
        ],
      );
    } else if (item is PreorderModel) {
      title = 'Detail Pre-Order: ${item.customerName}';
      contentWidget = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.paymentProofUrl.isNotEmpty)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: item.paymentProofUrl,
                  height: 160,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const Icon(LucideIcons.image, size: 60),
                ),
              ),
            ),
          const SizedBox(height: 16),
          _detailRow('Nama Pemesan', item.customerName),
          _detailRow('Email Pemesan', item.email),
          _detailRow('No HP / WhatsApp', item.phone.isNotEmpty ? item.phone : '-'),
          _detailRow('Judul Buku', item.bookTitle),
          _detailRow('Kuantiti', '${item.quantity} eks'),
          _detailRow('Status Pesanan', item.status.toUpperCase()),
          _detailRow('Tanggal Pemesanan', item.createdAt.toString().split('.').first),
          _detailRow('Tanggal Dihapus', _formatDeletedAt(item.deletedAt)),
        ],
      );
    }

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.eye, color: AppTheme.primaryColor, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
              const Divider(height: 24),
              Flexible(
                child: SingleChildScrollView(
                  child: contentWidget,
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  icon: const Icon(LucideIcons.check, size: 16),
                  label: const Text('Tutup'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showPermanentDeleteConfirmation(
    BuildContext context,
    TrashController controller, {
    String? singleId,
    String? singleTitle,
  }) {
    final count = singleId != null ? 1 : controller.selectedIds.length;
    final titleMessage = count == 1
        ? 'Hapus Permanen "${singleTitle ?? 'Item Ini'}"?'
        : 'Hapus Permanen $count Item Terpilih?';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                LucideIcons.alertTriangle,
                color: Colors.redAccent,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Konfirmasi Hapus Permanen',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titleMessage,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.info, size: 18, color: Colors.redAccent),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tindakan ini tidak dapat dibatalkan. Data akan dihapus secara permanen dari server.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.redAccent,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.borderColor),
            ),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              if (singleId != null) {
                controller.selectedIds.clear();
                controller.selectedIds.add(singleId);
              }
              await controller.permanentlyDeleteSelectedItems();
              if (context.mounted) {
                AppToast.showSuccess(context, 'Data telah dihapus permanen.');
              }
            },
            icon: const Icon(LucideIcons.trash2, size: 16),
            label: const Text('Hapus Permanen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrashController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Page Header
            Container(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceColor,
                border: Border(
                  bottom: BorderSide(color: AppTheme.borderColor, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          LucideIcons.trash2,
                          color: Colors.redAccent,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                const Text(
                                  'Keranjang Sampah',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Obx(() {
                                  final totalCount = controller.deletedBooks.length +
                                      controller.deletedAuthors.length +
                                      controller.deletedArticles.length +
                                      controller.deletedSubmissions.length +
                                      controller.deletedPreorders.length;
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '$totalCount total',
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Kelola dan pulihkan data terhapus (Buku, Penulis, Artikel, Naskah Masuk, Pre-Order)',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: () => controller.fetchAllDeleted(),
                        icon: const Icon(LucideIcons.refreshCw, size: 20),
                        tooltip: 'Muat Ulang Data',
                        color: AppTheme.textSecondary,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Category Filter Chips
                  Obx(() {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryChip(
                            controller,
                            category: TrashCategory.books,
                            label: 'Buku',
                            icon: LucideIcons.bookOpen,
                            count: controller.deletedBooks.length,
                          ),
                          const SizedBox(width: 10),
                          _buildCategoryChip(
                            controller,
                            category: TrashCategory.authors,
                            label: 'Penulis',
                            icon: LucideIcons.users,
                            count: controller.deletedAuthors.length,
                          ),
                          const SizedBox(width: 10),
                          _buildCategoryChip(
                            controller,
                            category: TrashCategory.articles,
                            label: 'Artikel',
                            icon: LucideIcons.fileText,
                            count: controller.deletedArticles.length,
                          ),
                          const SizedBox(width: 10),
                          _buildCategoryChip(
                            controller,
                            category: TrashCategory.submissions,
                            label: 'Naskah Masuk',
                            icon: LucideIcons.inbox,
                            count: controller.deletedSubmissions.length,
                          ),
                          const SizedBox(width: 10),
                          _buildCategoryChip(
                            controller,
                            category: TrashCategory.preorders,
                            label: 'Pesanan Pre-Order',
                            icon: LucideIcons.shoppingBag,
                            count: controller.deletedPreorders.length,
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Search Bar
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.inputFillColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (val) => controller.searchQuery.value = val,
                      decoration: const InputDecoration(
                        hintText: 'Cari data terhapus...',
                        prefixIcon: Icon(
                          LucideIcons.search,
                          size: 18,
                          color: AppTheme.textMuted,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bulk Action Toolbar
            Obx(() {
              final list = controller.currentFilteredList;
              final selectedCount = controller.selectedIds.length;
              final isAnySelected = selectedCount > 0;
              final isAllSelected = controller.isAllSelected;

              if (list.isEmpty) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: const BoxDecoration(
                  color: AppTheme.surfaceColor,
                  border: Border(
                    bottom: BorderSide(color: AppTheme.borderColor, width: 1),
                  ),
                ),
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => controller.toggleSelectAll(!isAllSelected),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: isAllSelected
                                      ? true
                                      : (controller.isPartiallySelected ? null : false),
                                  tristate: true,
                                  activeColor: AppTheme.primaryColor,
                                  onChanged: (val) => controller.toggleSelectAll(val == true),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Pilih Semua',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (isAnySelected) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Terpilih $selectedCount dari ${list.length}',
                              style: const TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isAnySelected ? 1.0 : 0.5,
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: [
                          ElevatedButton.icon(
                            onPressed: isAnySelected && !controller.isProcessing.value
                                ? () async {
                                    await controller.restoreSelectedItems();
                                    if (context.mounted) {
                                      AppToast.showSuccess(
                                        context,
                                        '$selectedCount item berhasil dipulihkan.',
                                      );
                                    }
                                  }
                                : null,
                            icon: controller.isProcessing.value
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(LucideIcons.rotateCcw, size: 16),
                            label: Text(
                              selectedCount > 1
                                  ? 'Pulihkan ($selectedCount)'
                                  : 'Pulihkan Data',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),

                          ElevatedButton.icon(
                            onPressed: isAnySelected && !controller.isProcessing.value
                                ? () => _showPermanentDeleteConfirmation(context, controller)
                                : null,
                            icon: const Icon(LucideIcons.trash2, size: 16),
                            label: Text(
                              selectedCount > 1
                                  ? 'Hapus ($selectedCount)'
                                  : 'Hapus Permanen',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            // List Content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: AppTheme.primaryColor),
                        SizedBox(height: 16),
                        Text(
                          'Memuat data keranjang sampah...',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.alertCircle, size: 48, color: Colors.redAccent),
                        const SizedBox(height: 16),
                        Text(
                          controller.errorMessage.value,
                          style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => controller.fetchCurrentCategory(),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final list = controller.currentFilteredList;

                if (list.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: const BoxDecoration(
                              color: AppTheme.inputFillColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.trash2,
                              size: 56,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            controller.searchQuery.value.isNotEmpty
                                ? 'Tidak Ada Data Yang Cocok'
                                : 'Keranjang Sampah Kosong',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            controller.searchQuery.value.isNotEmpty
                                ? 'Coba gunakan kata kunci pencarian lain.'
                                : 'Tidak ada data terhapus di kategori ini.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(28),
                  itemCount: list.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    final itemId = _getItemId(item);

                    return Obx(() {
                      final isSelected = controller.selectedIds.contains(itemId);

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected
                                ? AppTheme.primaryColor
                                : AppTheme.borderColor,
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        color: isSelected
                            ? AppTheme.primaryColor.withValues(alpha: 0.03)
                            : AppTheme.surfaceColor,
                        child: InkWell(
                          onTap: () => controller.toggleSelectItem(
                            itemId,
                            !isSelected,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Builder(
                              builder: (context) {
                                final isMobileCard = MediaQuery.of(context).size.width < 600;

                                final actionButtons = Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Detail Eye Button
                                    IconButton(
                                      icon: const Icon(
                                        LucideIcons.eye,
                                        size: 18,
                                        color: AppTheme.primaryColor,
                                      ),
                                      tooltip: 'Lihat Detail Data',
                                      onPressed: () => _showItemDetailDialog(context, item),
                                    ),
                                    // Individual Restore Button
                                    IconButton(
                                      icon: const Icon(
                                        LucideIcons.rotateCcw,
                                        size: 18,
                                        color: Color(0xFF10B981),
                                      ),
                                      tooltip: 'Pulihkan Data Ini',
                                      onPressed: () async {
                                        controller.selectedIds.clear();
                                        controller.selectedIds.add(itemId);
                                        await controller.restoreSelectedItems();
                                        if (context.mounted) {
                                          AppToast.showSuccess(
                                            context,
                                            'Data berhasil dipulihkan.',
                                          );
                                        }
                                      },
                                    ),
                                    // Individual Permanent Delete Button
                                    IconButton(
                                      icon: const Icon(
                                        LucideIcons.trash2,
                                        size: 18,
                                        color: Colors.redAccent,
                                      ),
                                      tooltip: 'Hapus Permanen',
                                      onPressed: () => _showPermanentDeleteConfirmation(
                                        context,
                                        controller,
                                        singleId: itemId,
                                        singleTitle: _getItemTitle(item),
                                      ),
                                    ),
                                  ],
                                );

                                if (isMobileCard) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Checkbox(
                                            value: isSelected,
                                            activeColor: AppTheme.primaryColor,
                                            onChanged: (val) => controller.toggleSelectItem(
                                              itemId,
                                              val,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          _buildItemLeading(item),
                                          const SizedBox(width: 12),
                                          Expanded(child: _buildItemTitleSubtitle(item)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: actionButtons,
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    Checkbox(
                                      value: isSelected,
                                      activeColor: AppTheme.primaryColor,
                                      onChanged: (val) => controller.toggleSelectItem(
                                        itemId,
                                        val,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    _buildItemLeading(item),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildItemTitleSubtitle(item)),
                                    const SizedBox(width: 16),
                                    actionButtons,
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    });
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(
    TrashController controller, {
    required TrashCategory category,
    required String label,
    required IconData icon,
    required int count,
  }) {
    final isSelected = controller.activeCategory.value == category;

    return ChoiceChip(
      selected: isSelected,
      onSelected: (_) => controller.changeCategory(category),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.25)
                  : AppTheme.inputFillColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
      selectedColor: AppTheme.primaryColor,
      backgroundColor: AppTheme.surfaceColor,
      side: BorderSide(
        color: isSelected ? AppTheme.primaryColor : AppTheme.borderColor,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  Widget _buildItemLeading(dynamic item) {
    if (item is Book) {
      return Container(
        width: 50,
        height: 68,
        decoration: BoxDecoration(
          color: AppTheme.inputFillColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: item.coverUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: item.coverUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const Icon(LucideIcons.book, size: 20),
              )
            : const Icon(LucideIcons.book, size: 20),
      );
    } else if (item is Author) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: AppTheme.inputFillColor,
        backgroundImage: item.photoUrl.isNotEmpty ? NetworkImage(item.photoUrl) : null,
        child: item.photoUrl.isEmpty ? const Icon(LucideIcons.user, size: 20) : null,
      );
    } else if (item is Article) {
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: AppTheme.inputFillColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: item.imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => const Icon(LucideIcons.fileText, size: 20),
              )
            : const Icon(LucideIcons.fileText, size: 20),
      );
    } else if (item is Submission) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: Colors.orangeAccent.withValues(alpha: 0.1),
        child: const Icon(LucideIcons.inbox, color: Colors.orangeAccent, size: 20),
      );
    } else if (item is PreorderModel) {
      return CircleAvatar(
        radius: 24,
        backgroundColor: const Color(0xFFCCFBF1),
        child: const Icon(LucideIcons.shoppingBag, color: Color(0xFF0F766E), size: 20),
      );
    }
    return const Icon(LucideIcons.file);
  }

  Widget _buildItemTitleSubtitle(dynamic item) {
    String title = '';
    String subtitle = '';
    DateTime? deletedAt;

    if (item is Book) {
      title = item.title;
      subtitle = item.author.isNotEmpty ? 'Penulis: ${item.author}' : 'Buku';
      deletedAt = item.deletedAt;
    } else if (item is Author) {
      title = item.name;
      subtitle = item.bio.isNotEmpty ? item.bio : 'Penulis';
      deletedAt = item.deletedAt;
    } else if (item is Article) {
      title = item.title;
      subtitle = item.author.isNotEmpty ? 'Penulis: ${item.author}' : 'Artikel';
      deletedAt = item.deletedAt;
    } else if (item is Submission) {
      title = 'Naskah: ${item.senderName}';
      subtitle = 'Email: ${item.email} • Status: ${item.status.toUpperCase()}';
      deletedAt = item.deletedAt;
    } else if (item is PreorderModel) {
      title = 'Pre-Order: ${item.customerName}';
      subtitle = 'Buku: ${item.bookTitle} • WA: ${item.phone.isNotEmpty ? item.phone : '-'}';
      deletedAt = item.deletedAt;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(LucideIcons.clock, size: 12, color: Colors.redAccent),
            const SizedBox(width: 4),
            Text(
              _formatDeletedAt(deletedAt),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getItemId(dynamic item) {
    if (item is Book) return item.id;
    if (item is Author) return item.id;
    if (item is Article) return item.id;
    if (item is Submission) return item.id;
    if (item is PreorderModel) return item.id;
    return '';
  }

  String _getItemTitle(dynamic item) {
    if (item is Book) return item.title;
    if (item is Author) return item.name;
    if (item is Article) return item.title;
    if (item is Submission) return item.senderName;
    if (item is PreorderModel) return 'Pre-Order ${item.customerName}';
    return 'Item';
  }
}
