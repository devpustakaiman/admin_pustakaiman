import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_toast.dart';
import '../../domain/entities/author.dart';
import '../controllers/author_controller.dart';

class AuthorManagementPage extends StatelessWidget {
  const AuthorManagementPage({super.key});

  Widget _buildAvatar(String photoUrl, {double radius = 24}) {
    final isValidUrl = photoUrl.startsWith('http://') || photoUrl.startsWith('https://');
    if (!isValidUrl) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
        child: const Icon(LucideIcons.user, color: AppTheme.primaryColor, size: 20),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppTheme.inputFillColor,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: photoUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: radius * 2,
            height: radius * 2,
            color: AppTheme.inputFillColor,
            child: const Center(
              child: SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor),
              ),
            ),
          ),
          errorWidget: (_, __, ___) => const Icon(LucideIcons.user, color: AppTheme.primaryColor, size: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthorController>();

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
                  'Data Penulis',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Kelola profil dan biografi penulis pustaka',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Responsive Two-Tier Action Bar (Top Tier: Search & Primary Actions, Bottom Tier: Sort Filters)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Tier: Search (Expanded) + Refresh IconButton + Tambah Penulis Button
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
                                hintText: 'Cari penulis, biografi...',
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
                      onPressed: () => controller.fetchAuthors(),
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
                      label: const Text('Tambah Penulis'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Bottom Tier: Sort Dropdown & Asc/Desc Toggle
                Wrap(
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
                                  DropdownMenuItem(value: 'name', child: Text('Urut: Nama')),
                                  DropdownMenuItem(value: 'date', child: Text('Urut: Tanggal Dibuat')),
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
                            onPressed: () => controller.fetchAuthors(),
                            icon: const Icon(LucideIcons.refreshCw, size: 16),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final displayAuthors = controller.filteredAuthors;

                if (displayAuthors.isEmpty) {
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
                            LucideIcons.users,
                            size: 48,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.searchQuery.value.isNotEmpty
                              ? 'Tidak ditemukan penulis dengan kata kunci "${controller.searchQuery.value}"'
                              : 'Belum ada data penulis terdaftar.',
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
                            label: const Text('Tambah Penulis Pertama'),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: displayAuthors.length,
                  itemBuilder: (context, index) {
                    final author = displayAuthors[index];

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
                            _buildAvatar(author.photoUrl, radius: 26),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    author.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    author.bio.isNotEmpty ? author.bio : 'Belum ada biografi tersedia.',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              icon: const Icon(LucideIcons.edit3, size: 18, color: Colors.blueAccent),
                              tooltip: 'Edit Penulis',
                              onPressed: () => controller.openFormDialog(author: author),
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
                              tooltip: 'Hapus Penulis',
                              onPressed: () => _confirmDelete(context, controller, author),
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

            // Pagination Controls Footer Bar
            Obx(() {
              final total = controller.totalAuthorsCount.value;
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
                          ? 'Menampilkan $start - $end dari $total penulis (Halaman ${page + 1})'
                          : 'Belum ada data penulis',
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

  void _confirmDelete(BuildContext context, AuthorController controller, Author author) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Penulis', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin memindahkan penulis "${author.name}" ke Keranjang Sampah?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await controller.deleteAuthor(author.id);
              if (context.mounted) {
                AppToast.showSuccess(context, 'Penulis "${author.name}" dipindahkan ke Keranjang Sampah.');
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
