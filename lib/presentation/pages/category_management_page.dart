import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/category.dart';
import '../controllers/category_controller.dart';

class CategoryManagementPage extends StatelessWidget {
  const CategoryManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoryController>();
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Padding(
        padding: EdgeInsets.all(isMobile ? 16.0 : 28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header Title
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kelola Kategori Buku',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Kelola taksonomi 2-tier (Kategori Utama & Sub-Kategori) untuk katalog publik',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Action Bar: Search + Refresh + Tambah Kategori
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
                            hintText: 'Cari kategori utama, sub-kategori, slug...',
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
                  onPressed: () => controller.fetchCategories(),
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
                  onPressed: () => _openCategoryFormDialog(context, controller),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text('Tambah Kategori'),
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

            // Content List (Hierarchy Tree View)
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
                            onPressed: () => controller.fetchCategories(),
                            icon: const Icon(LucideIcons.refreshCw, size: 16),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final q = controller.searchQuery.value.trim().toLowerCase();
                final mainList = controller.mainCategories;

                if (mainList.isEmpty && controller.categories.isEmpty) {
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
                            LucideIcons.tags,
                            size: 48,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada kategori terdaftar.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _openCategoryFormDialog(context, controller),
                          icon: const Icon(LucideIcons.plus, size: 18),
                          label: const Text('Tambah Kategori Pertama'),
                        ),
                      ],
                    ),
                  );
                }

                // Filter main categories by query if query is typed
                final filteredMainCategories = mainList.where((m) {
                  if (q.isEmpty) return true;
                  final matchMain = m.name.toLowerCase().contains(q) || m.slug.toLowerCase().contains(q);
                  final subs = controller.getSubCategories(m.id);
                  final matchSub = subs.any((s) => s.name.toLowerCase().contains(q) || s.slug.toLowerCase().contains(q));
                  return matchMain || matchSub;
                }).toList();

                if (filteredMainCategories.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ditemukan kategori dengan kata kunci "$q"',
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                    ),
                  );
                }

                return ListView.builder(
                  key: const PageStorageKey('category_management_list'),
                  itemCount: filteredMainCategories.length,
                  itemBuilder: (context, index) {
                    final mainCat = filteredMainCategories[index];
                    final subCats = controller.getSubCategories(mainCat.id);
                    final filteredSubCats = q.isEmpty
                        ? subCats
                        : subCats
                            .where((s) => s.name.toLowerCase().contains(q) || s.slug.toLowerCase().contains(q))
                            .toList();

                    return Obx(() {
                      final isExpanded = controller.isExpanded(mainCat.id);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderColor),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Main Category Header Tile
                              InkWell(
                                onTap: () => controller.toggleExpand(mainCat.id),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(LucideIcons.folder, color: AppTheme.primaryColor, size: 20),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    mainCat.name,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppTheme.textPrimary,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    '${subCats.length} Sub-Kategori',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppTheme.primaryColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'slug: ${mainCat.slug}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontFamily: 'monospace',
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Wrap(
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        spacing: 6,
                                        children: [
                                          OutlinedButton.icon(
                                            onPressed: () => _openCategoryFormDialog(
                                              context,
                                              controller,
                                              defaultParentCategory: mainCat,
                                            ),
                                            icon: const Icon(LucideIcons.plus, size: 13),
                                            label: const Text('Tambah Sub', style: TextStyle(fontSize: 11)),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              side: const BorderSide(color: AppTheme.primaryColor),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(LucideIcons.edit3, size: 16, color: Colors.blueAccent),
                                            tooltip: 'Edit Kategori Utama',
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.all(6),
                                            onPressed: () => _openCategoryFormDialog(
                                              context,
                                              controller,
                                              category: mainCat,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.redAccent),
                                            tooltip: 'Hapus Kategori Utama',
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.all(6),
                                            onPressed: () => _confirmDeleteCategory(context, controller, mainCat),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              isExpanded ? LucideIcons.chevronUp : LucideIcons.chevronDown,
                                              size: 18,
                                              color: AppTheme.textSecondary,
                                            ),
                                            tooltip: isExpanded ? 'Tutup Sub-Kategori' : 'Buka Sub-Kategori',
                                            constraints: const BoxConstraints(),
                                            padding: const EdgeInsets.all(6),
                                            onPressed: () => controller.toggleExpand(mainCat.id),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Sub-Categories Animated View (Controlled by controller.isExpanded)
                              AnimatedCrossFade(
                                firstChild: const SizedBox.shrink(),
                                secondChild: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Divider(height: 1),
                                    Container(
                                      width: double.infinity,
                                      color: const Color(0xFFF8FAFC),
                                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                                      child: filteredSubCats.isEmpty
                                          ? const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 8),
                                              child: Text(
                                                'Belum ada sub-kategori.',
                                                style: TextStyle(fontSize: 12, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                                              ),
                                            )
                                          : Column(
                                              children: filteredSubCats.map((subCat) {
                                                return Container(
                                                  margin: const EdgeInsets.only(bottom: 6),
                                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(color: AppTheme.borderColor),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      const Icon(LucideIcons.cornerDownRight, size: 16, color: AppTheme.textSecondary),
                                                      const SizedBox(width: 8),
                                                      const Icon(LucideIcons.tag, size: 14, color: AppTheme.primaryColor),
                                                      const SizedBox(width: 8),
                                                      Expanded(
                                                        child: Row(
                                                          children: [
                                                            Text(
                                                              subCat.name,
                                                              style: const TextStyle(
                                                                fontSize: 13,
                                                                fontWeight: FontWeight.w600,
                                                                color: AppTheme.textPrimary,
                                                              ),
                                                            ),
                                                            const SizedBox(width: 8),
                                                            Text(
                                                              '(${subCat.slug})',
                                                              style: const TextStyle(
                                                                fontSize: 11,
                                                                fontFamily: 'monospace',
                                                                color: AppTheme.textMuted,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      IconButton(
                                                        icon: const Icon(LucideIcons.edit3, size: 15, color: Colors.blueAccent),
                                                        tooltip: 'Edit / Pindah Sub-Kategori',
                                                        onPressed: () => _openCategoryFormDialog(
                                                          context,
                                                          controller,
                                                          category: subCat,
                                                        ),
                                                        constraints: const BoxConstraints(),
                                                        padding: const EdgeInsets.all(6),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      IconButton(
                                                        icon: const Icon(LucideIcons.trash2, size: 15, color: Colors.redAccent),
                                                        tooltip: 'Hapus Sub-Kategori',
                                                        onPressed: () => _confirmDeleteCategory(context, controller, subCat),
                                                        constraints: const BoxConstraints(),
                                                        padding: const EdgeInsets.all(6),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                    ),
                                  ],
                                ),
                                crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                duration: const Duration(milliseconds: 200),
                              ),
                            ],
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

  void _openCategoryFormDialog(
    BuildContext context,
    CategoryController controller, {
    Category? category,
    Category? defaultParentCategory,
  }) {
    final isEdit = category != null;
    final nameController = TextEditingController(text: category?.name ?? '');
    final slugController = TextEditingController(text: category?.slug ?? '');

    String? selectedParentId = isEdit
        ? category.parentId
        : defaultParentCategory?.id;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEdit ? 'Edit Kategori' : 'Tambah Kategori Baru',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: StatefulBuilder(
            builder: (context, setState) {
              final mains = controller.mainCategories.where((m) => !isEdit || m.id != category.id).toList();

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dropdown: Induk Kategori (opsional/nullable)
                  const Text(
                    'Induk Kategori',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String?>(
                    initialValue: mains.any((m) => m.id == selectedParentId) ? selectedParentId : null,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text(
                          'Tanpa Induk (Kategori Utama)',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                        ),
                      ),
                      ...mains.map((m) {
                        return DropdownMenuItem<String?>(
                          value: m.id,
                          child: Text(m.name),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      setState(() {
                        selectedParentId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: nameController,
                    autofocus: true,
                    onChanged: (val) {
                      if (!isEdit || slugController.text.isEmpty) {
                        final parentObj = mains.firstWhereOrNull((m) => m.id == selectedParentId);
                        slugController.text = controller.generateSlug(val, parentName: parentObj?.name);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Nama Kategori *',
                      hintText: 'Misal: Sejarah, Novel, Fiksi',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: slugController,
                    decoration: const InputDecoration(
                      labelText: 'Slug (URL Identifier)',
                      hintText: 'Misal: sejarah, novel, fiksi',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final slug = slugController.text.trim();
              if (name.isEmpty) return;

              final parentObj = controller.mainCategories.firstWhereOrNull((m) => m.id == selectedParentId);

              Navigator.of(dialogContext).pop();
              if (isEdit) {
                await controller.updateCategory(
                  category.id,
                  name,
                  slug,
                  parentId: selectedParentId,
                );
              } else {
                await controller.addCategory(
                  name,
                  customSlug: slug,
                  parentId: selectedParentId,
                  parentName: parentObj?.name,
                );
              }
            },
            child: Text(isEdit ? 'Simpan' : 'Tambah'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, CategoryController controller, Category category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus kategori "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await controller.deleteCategory(category.id, category.name);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
