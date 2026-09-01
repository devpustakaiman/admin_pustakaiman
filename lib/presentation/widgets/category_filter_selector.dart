import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/book_controller.dart';

class CategoryFilterSelector extends StatefulWidget {
  final BookController controller;

  const CategoryFilterSelector({super.key, required this.controller});

  @override
  State<CategoryFilterSelector> createState() => _CategoryFilterSelectorState();
}

class _CategoryFilterSelectorState extends State<CategoryFilterSelector> {
  final OverlayPortalController _overlayController = OverlayPortalController();
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  String? _hoveredMainCategory;
  final RxString _searchQuery = ''.obs;

  // Build hierarchical map from mizanCategories
  static Map<String, List<String>> get categoryHierarchy {
    final Map<String, List<String>> map = {};
    for (final cat in BookController.mizanCategories) {
      if (cat.contains(' - ')) {
        final parts = cat.split(' - ');
        final mainCat = parts[0].trim();
        map.putIfAbsent(mainCat, () => []).add(cat);
      } else {
        map.putIfAbsent(cat, () => []).add(cat);
      }
    }
    return map;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _searchQuery.value = val;
      if (mounted) setState(() {});
    });
  }

  void _toggleOverlay() {
    if (_overlayController.isShowing) {
      _overlayController.hide();
    } else {
      _searchController.clear();
      _searchQuery.value = '';
      _hoveredMainCategory = categoryHierarchy.keys.isNotEmpty
          ? categoryHierarchy.keys.first
          : 'Semua Kategori';
      _overlayController.show();
    }
  }

  void _selectCategory(String category) {
    widget.controller.selectedCategoryFilter.value = category;
    _overlayController.hide();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: (BuildContext context) {
          return Stack(
            children: [
              // Fullscreen transparent barrier to dismiss popup on tap outside
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    _overlayController.hide();
                  },
                ),
              ),
              // Positioned Overlay Follower Panel
              CompositedTransformFollower(
                link: _layerLink,
                targetAnchor: Alignment.bottomLeft,
                followerAnchor: Alignment.topLeft,
                offset: const Offset(0, 8),
                child: UnconstrainedBox(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      width: 550,
                      height: 360,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.borderColor),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Top Search Input for Typing Recommendation
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                                textAlignVertical: TextAlignVertical.center,
                                autofocus: true,
                                decoration: InputDecoration(
                                  hintText: 'Ketik nama kategori...',
                                  prefixIcon: const Icon(LucideIcons.search, size: 16, color: AppTheme.primaryColor),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(LucideIcons.x, size: 14, color: AppTheme.textSecondary),
                                          onPressed: () {
                                            _searchController.clear();
                                            _searchQuery.value = '';
                                            setState(() {});
                                          },
                                        )
                                      : null,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0.0),
                                  fillColor: AppTheme.inputFillColor,
                                ),
                              ),
                            ),

                            // Content Area: Search Results OR Cascading Double Dropdown
                            Expanded(
                              child: Obx(() {
                                final query = _searchQuery.value.trim().toLowerCase();

                                // 1. TYPING RECOMMENDATION MODE
                                if (query.isNotEmpty) {
                                  final matchingCategories = BookController.mizanCategories
                                      .where((cat) => cat.toLowerCase().contains(query))
                                      .toList();

                                  if (matchingCategories.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        'Kategori tidak ditemukan',
                                        style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                                      ),
                                    );
                                  }

                                  return ListView.builder(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    itemCount: matchingCategories.length,
                                    itemBuilder: (context, index) {
                                      final cat = matchingCategories[index];
                                      final isSelected =
                                          widget.controller.selectedCategoryFilter.value == cat;

                                      return ListTile(
                                        dense: true,
                                        leading: Icon(
                                          LucideIcons.tag,
                                          size: 16,
                                          color: isSelected
                                              ? AppTheme.primaryColor
                                              : AppTheme.textSecondary,
                                        ),
                                        title: Text(
                                          cat,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight:
                                                isSelected ? FontWeight.bold : FontWeight.w500,
                                            color: isSelected
                                                ? AppTheme.primaryColor
                                                : AppTheme.textPrimary,
                                          ),
                                        ),
                                        onTap: () => _selectCategory(cat),
                                      );
                                    },
                                  );
                                }

                                // 2. DOUBLE DROPDOWN / CASCADING MENU MODE
                                final hierarchy = categoryHierarchy;
                                final mainCategories = ['Semua Kategori', ...hierarchy.keys];

                                final activeMain = _hoveredMainCategory ??
                                    (hierarchy.keys.isNotEmpty ? hierarchy.keys.first : 'Semua Kategori');
                                final subCategories = activeMain == 'Semua Kategori'
                                    ? <String>[]
                                    : (hierarchy[activeMain] ?? <String>[]);

                                return Row(
                                  children: [
                                    // Left Panel: Main Categories (Fixed Width 200)
                                    SizedBox(
                                      width: 200,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF8FAFC),
                                          border: Border(right: BorderSide(color: AppTheme.borderColor)),
                                        ),
                                        child: ListView.builder(
                                          padding: const EdgeInsets.symmetric(vertical: 6),
                                          itemCount: mainCategories.length,
                                          itemBuilder: (context, index) {
                                            final mainCat = mainCategories[index];
                                            final isHovered = activeMain == mainCat;
                                            final hasSubs = mainCat != 'Semua Kategori' &&
                                                (hierarchy[mainCat]?.length ?? 0) > 1;

                                            return MouseRegion(
                                              onEnter: (_) {
                                                setState(() {
                                                  _hoveredMainCategory = mainCat;
                                                });
                                              },
                                              child: InkWell(
                                                onTap: () {
                                                  if (mainCat == 'Semua Kategori') {
                                                    _selectCategory('Semua Kategori');
                                                  } else {
                                                    setState(() {
                                                      _hoveredMainCategory = mainCat;
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 10,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: isHovered
                                                        ? Colors.white
                                                        : Colors.transparent,
                                                    border: isHovered
                                                        ? const Border(
                                                            left: BorderSide(
                                                              color: AppTheme.primaryColor,
                                                              width: 3,
                                                            ),
                                                          )
                                                        : null,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          mainCat,
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight: isHovered
                                                                ? FontWeight.bold
                                                                : FontWeight.w500,
                                                            color: isHovered
                                                                ? AppTheme.primaryColor
                                                                : AppTheme.textPrimary,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      if (hasSubs)
                                                        const Icon(
                                                          LucideIcons.chevronRight,
                                                          size: 14,
                                                          color: AppTheme.textMuted,
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),

                                    // Right Panel: Subcategories (Expanded to fill remaining 350px)
                                    Expanded(
                                      child: Container(
                                        color: Colors.white,
                                        child: activeMain == 'Semua Kategori'
                                            ? ListView(
                                                padding: const EdgeInsets.symmetric(vertical: 6),
                                                children: [
                                                  ListTile(
                                                    dense: true,
                                                    leading: const Icon(
                                                      LucideIcons.checkCircle2,
                                                      size: 16,
                                                      color: AppTheme.primaryColor,
                                                    ),
                                                    title: const Text(
                                                      'Tampilkan Semua Kategori',
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppTheme.primaryColor,
                                                      ),
                                                    ),
                                                    onTap: () => _selectCategory('Semua Kategori'),
                                                  ),
                                                  const Divider(height: 1),
                                                  for (final key in hierarchy.keys)
                                                    ListTile(
                                                      dense: true,
                                                      leading: const Icon(
                                                        LucideIcons.folder,
                                                        size: 14,
                                                        color: AppTheme.textSecondary,
                                                      ),
                                                      title: Text(
                                                        key,
                                                        style: const TextStyle(
                                                          fontSize: 12.5,
                                                          color: AppTheme.textPrimary,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        setState(() {
                                                          _hoveredMainCategory = key;
                                                        });
                                                      },
                                                    ),
                                                ],
                                              )
                                            : ListView(
                                                padding: const EdgeInsets.symmetric(vertical: 6),
                                                children: [
                                                  // Option to select all under this main category
                                                  ListTile(
                                                    dense: true,
                                                    leading: const Icon(
                                                      LucideIcons.folder,
                                                      size: 16,
                                                      color: AppTheme.primaryColor,
                                                    ),
                                                    title: Text(
                                                      'Semua "$activeMain"',
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppTheme.primaryColor,
                                                      ),
                                                    ),
                                                    onTap: () => _selectCategory('$activeMain (Semua)'),
                                                  ),
                                                  const Divider(height: 1),

                                                  // Subcategory Items
                                                  for (final subCat in subCategories) ...[
                                                    ListTile(
                                                      dense: true,
                                                      title: Text(
                                                        subCat.contains(' - ')
                                                            ? subCat.split(' - ').sublist(1).join(' - ')
                                                            : subCat,
                                                        style: TextStyle(
                                                          fontSize: 12.5,
                                                          fontWeight: widget.controller.selectedCategoryFilter.value == subCat
                                                              ? FontWeight.bold
                                                              : FontWeight.normal,
                                                          color: widget.controller.selectedCategoryFilter.value == subCat
                                                              ? AppTheme.primaryColor
                                                              : AppTheme.textPrimary,
                                                        ),
                                                      ),
                                                      trailing: widget.controller.selectedCategoryFilter.value == subCat
                                                          ? const Icon(LucideIcons.check, size: 14, color: AppTheme.primaryColor)
                                                          : null,
                                                      onTap: () => _selectCategory(subCat),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        child: InkWell(
          onTap: _toggleOverlay,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderColor),
              boxShadow: AppTheme.softShadow,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.filter, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Obx(() {
                  final selected = widget.controller.selectedCategoryFilter.value;
                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 160),
                    child: Text(
                      selected,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
                const SizedBox(width: 8),
                const Icon(LucideIcons.chevronDown, size: 16, color: AppTheme.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
