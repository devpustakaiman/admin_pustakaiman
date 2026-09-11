import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../controllers/web_settings_controller.dart';

class BookSelectionDialog extends StatefulWidget {
  final WebSettingsController controller;
  final String? initialCategory;
  final ValueChanged<FeaturedBookItem> onSelected;
  final String title;

  const BookSelectionDialog({
    super.key,
    required this.controller,
    this.initialCategory,
    required this.onSelected,
    this.title = 'Pilih Buku (Cover 2D)',
  });

  @override
  State<BookSelectionDialog> createState() => _BookSelectionDialogState();
}

class _BookSelectionDialogState extends State<BookSelectionDialog> {
  final TextEditingController _searchCtrl = TextEditingController();
  final RxString _searchQuery = ''.obs;
  final RxString _selectedCategory = ''.obs;
  final RxBool _isFilterActive = true.obs;

  @override
  void initState() {
    super.initState();
    final initCat = widget.initialCategory?.trim() ?? '';
    if (initCat.isNotEmpty && initCat != 'Semua Kategori') {
      _selectedCategory.value = initCat;
      _isFilterActive.value = true;
    } else {
      _selectedCategory.value = 'Semua Kategori';
      _isFilterActive.value = false;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Normalisasi string untuk pencocokan kategori yang toleran
  String _normalize(String str) {
    return str
        .toLowerCase()
        .replaceAll('&', 'dan')
        .replaceAll(RegExp(r'[^a-z0-9]'), '')
        .trim();
  }

  /// Logika pencocokan kategori yang fleksibel
  bool _matchesCategory(String bookCategory, String targetCategory) {
    if (!_isFilterActive.value ||
        targetCategory.isEmpty ||
        targetCategory == 'Semua Kategori') {
      return true;
    }

    if (bookCategory.isEmpty) {
      return false;
    }

    final normBook = _normalize(bookCategory);
    final normTarget = _normalize(targetCategory);

    if (normBook == normTarget) return true;
    if (normBook.contains(normTarget) || normTarget.contains(normBook)) return true;

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 540,
        constraints: const BoxConstraints(maxHeight: 620),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        LucideIcons.bookOpen,
                        color: AppTheme.primaryColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Tutup',
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Search Bar
            TextField(
              controller: _searchCtrl,
              autofocus: true,
              onChanged: (val) => _searchQuery.value = val,
              decoration: InputDecoration(
                hintText: 'Cari judul buku atau penulis...',
                prefixIcon: const Icon(LucideIcons.search, size: 18),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchCtrl,
                  builder: (ctx, value, _) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return IconButton(
                      icon: const Icon(LucideIcons.x, size: 16),
                      onPressed: () {
                        _searchCtrl.clear();
                        _searchQuery.value = '';
                      },
                    );
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Filter Bar (Category Chips & Selector + Count)
            Obx(() {
              final availableCategories = widget.controller.availableCatalogCategories;
              final currentCat = _selectedCategory.value;
              final filterActive = _isFilterActive.value;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.inputFillColor.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.filter, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 6),

                    // Filter Chip / Badge
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (filterActive && currentCat.isNotEmpty && currentCat != 'Semua Kategori') ...[
                              // Active Filter Chip
                              InkWell(
                                onTap: () {
                                  _isFilterActive.value = false;
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(LucideIcons.tag, size: 12, color: AppTheme.primaryColor),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Kategori: $currentCat',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(LucideIcons.x, size: 12, color: AppTheme.primaryColor),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],

                            // Category Selector Dropdown Button
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: availableCategories.contains(currentCat)
                                    ? currentCat
                                    : (currentCat.isNotEmpty && filterActive ? null : 'Semua Kategori'),
                                hint: Text(
                                  filterActive && currentCat.isNotEmpty ? currentCat : 'Pilih Kategori...',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                                ),
                                style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                                icon: const Icon(LucideIcons.chevronDown, size: 14, color: AppTheme.textSecondary),
                                isDense: true,
                                onChanged: (val) {
                                  if (val != null) {
                                    if (val == 'Semua Kategori') {
                                      _isFilterActive.value = false;
                                      _selectedCategory.value = 'Semua Kategori';
                                    } else {
                                      _selectedCategory.value = val;
                                      _isFilterActive.value = true;
                                    }
                                  }
                                },
                                items: [
                                  const DropdownMenuItem<String>(
                                    value: 'Semua Kategori',
                                    child: Text('Semua Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  ...availableCategories.map((cat) {
                                    return DropdownMenuItem<String>(
                                      value: cat,
                                      child: Text(cat),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 12),

            // Books List View
            Expanded(
              child: Obx(() {
                final query = _searchQuery.value.toLowerCase().trim();
                final allBooks = widget.controller.booksList;
                final targetCategory = _selectedCategory.value;

                final filtered = allBooks.where((b) {
                  final matchesCat = _matchesCategory(b.category, targetCategory);
                  final matchesSearch = query.isEmpty ||
                      b.title.toLowerCase().contains(query) ||
                      b.author.toLowerCase().contains(query);

                  return matchesCat && matchesSearch;
                }).toList();

                if (widget.controller.isLoadingBooks.value) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Empty State with Graceful Fallback
                if (filtered.isEmpty) {
                  final isCategoryFiltered = _isFilterActive.value &&
                      targetCategory.isNotEmpty &&
                      targetCategory != 'Semua Kategori';

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.inputFillColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              LucideIcons.folderSearch,
                              size: 40,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            isCategoryFiltered
                                ? 'Belum Ada Buku di Kategori "$targetCategory"'
                                : 'Buku Tidak Ditemukan',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isCategoryFiltered
                                ? 'Tidak ada buku yang cocok dengan kategori ini. Anda dapat melihat seluruh buku lintas kategori.'
                                : 'Coba gunakan kata kunci lain atau periksa kembali ejaan judul/penulis.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                          ),
                          if (isCategoryFiltered) ...[
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () {
                                _isFilterActive.value = false;
                                _selectedCategory.value = 'Semua Kategori';
                              },
                              icon: const Icon(LucideIcons.globe, size: 14),
                              label: const Text('Tampilkan Semua Kategori'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                                side: const BorderSide(color: AppTheme.primaryColor),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Count Header
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                      child: Text(
                        'Menampilkan ${filtered.length} buku',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final item = filtered[idx];
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            hoverColor: AppTheme.primaryColor.withValues(alpha: 0.04),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: item.coverUrl.isNotEmpty
                                  ? Image.network(
                                      item.coverUrl,
                                      width: 38,
                                      height: 54,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => CachedNetworkImage(
                                        imageUrl: item.coverUrl,
                                        width: 38,
                                        height: 54,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) => Container(
                                          width: 38,
                                          height: 54,
                                          color: AppTheme.inputFillColor,
                                          child: const Icon(LucideIcons.book, size: 18, color: AppTheme.textMuted),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 38,
                                      height: 54,
                                      color: AppTheme.inputFillColor,
                                      child: const Icon(LucideIcons.book, size: 18, color: AppTheme.textMuted),
                                    ),
                            ),
                            title: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 2),
                                Text(
                                  item.author.isNotEmpty ? item.author : 'Penulis tidak tersedia',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                ),
                                if (item.category.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Text(
                                      item.category,
                                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                widget.onSelected(item);
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Pilih', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
