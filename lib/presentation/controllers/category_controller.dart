import 'package:get/get.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../core/utils/app_toast.dart';

class CategoryController extends GetxController {
  final CategoryRepository categoryRepository;

  CategoryController({required this.categoryRepository});

  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  // Expansion state for Main Categories
  final RxSet<String> expandedCategoryIds = <String>{}.obs;

  void toggleExpand(String categoryId) {
    if (expandedCategoryIds.contains(categoryId)) {
      expandedCategoryIds.remove(categoryId);
    } else {
      expandedCategoryIds.add(categoryId);
    }
  }

  bool isExpanded(String categoryId) => expandedCategoryIds.contains(categoryId);

  void expandCategory(String categoryId) {
    expandedCategoryIds.add(categoryId);
  }

  void collapseCategory(String categoryId) {
    expandedCategoryIds.remove(categoryId);
  }

  List<Category> get mainCategories {
    return categories
        .where((c) => c.parentId == null || c.parentId!.trim().isEmpty)
        .toList();
  }

  List<String> get mainCategoryNames {
    return mainCategories.map((c) => c.name).toList();
  }

  List<Category> getSubCategories(String parentId) {
    if (parentId.trim().isEmpty) return [];
    return categories
        .where((c) => c.parentId == parentId || c.parentId?.toLowerCase() == parentId.toLowerCase())
        .toList();
  }

  List<String> getSubCategoryNames(String parentId) {
    return getSubCategories(parentId).map((c) => c.name).toList();
  }

  List<Category> getSubCategoriesByParentName(String parentName) {
    if (parentName.trim().isEmpty) return [];
    final parent = mainCategories.firstWhereOrNull(
      (c) => c.name.trim().toLowerCase() == parentName.trim().toLowerCase(),
    );
    if (parent == null) return [];
    return getSubCategories(parent.id);
  }

  List<String> getSubCategoryNamesByParentName(String parentName) {
    return getSubCategoriesByParentName(parentName).map((c) => c.name).toList();
  }

  List<String> get categoryNames {
    return categories.map((c) => c.name).toList();
  }

  List<Category> get filteredCategories {
    if (searchQuery.value.trim().isEmpty) return categories;
    final q = searchQuery.value.toLowerCase().trim();
    return categories
        .where((c) => c.name.toLowerCase().contains(q) || c.slug.toLowerCase().contains(q))
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchCategories(isInitial: true);
  }

  Future<void> fetchCategories({bool isInitial = false}) async {
    if (isInitial && categories.isEmpty) {
      isLoading.value = true;
    }
    errorMessage.value = '';
    final result = await categoryRepository.getCategories();
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (data) {
        categories.assignAll(data);
        // On initial load, expand all main categories by default
        if (isInitial) {
          final mainIds = data
              .where((c) => c.parentId == null || c.parentId!.trim().isEmpty)
              .map((c) => c.id);
          expandedCategoryIds.addAll(mainIds);
        }
        isLoading.value = false;
      },
    );
  }

  String generateSlug(String name, {String? parentName}) {
    final prefix = (parentName != null && parentName.trim().isNotEmpty)
        ? '${parentName.trim()}-'
        : '';
    final raw = '$prefix$name';
    var slug = raw.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    if (slug.startsWith('-')) slug = slug.substring(1);
    if (slug.endsWith('-')) slug = slug.substring(0, slug.length - 1);
    return slug;
  }

  Future<bool> addCategory(String name, {String? customSlug, String? parentId, String? parentName}) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return false;

    // 1. Check locally first if the trimmed name already exists under the same parent (case-insensitive)
    final existingCategory = categories.firstWhereOrNull(
      (c) => c.name.trim().toLowerCase() == trimmedName.toLowerCase() &&
          ((parentId == null && (c.parentId == null || c.parentId!.isEmpty)) ||
           (parentId != null && c.parentId == parentId)),
    );
    if (existingCategory != null) {
      if (parentId != null && parentId.trim().isNotEmpty) {
        expandCategory(parentId);
      }
      if (Get.context != null) {
        AppToast.showInfo(Get.context!, 'Kategori "${existingCategory.name}" sudah ada.');
      }
      return true; // Return true so auto-select selects this category and closes dialog cleanly
    }

    final slug = customSlug?.trim().isNotEmpty == true
        ? customSlug!.trim()
        : generateSlug(trimmedName, parentName: parentName);

    // Auto-expand parent category if adding a sub-category
    if (parentId != null && parentId.trim().isNotEmpty) {
      expandCategory(parentId);
    }

    final result = await categoryRepository.addCategory(trimmedName, slug, parentId: parentId);
    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        if (failure.code == '23505' || failure.message.contains('sudah ada')) {
          if (Get.context != null) {
            AppToast.showInfo(Get.context!, 'Kategori "$trimmedName" sudah ada.');
          }
          return true;
        } else {
          if (Get.context != null) {
            AppToast.showError(Get.context!, 'Gagal menambah kategori: ${failure.message}');
          }
          return false;
        }
      },
      (newCat) async {
        await fetchCategories(isInitial: false);
        if (Get.context != null) {
          AppToast.showSuccess(Get.context!, 'Kategori "$trimmedName" berhasil ditambahkan.');
        }
        return true;
      },
    );
  }

  Future<bool> updateCategory(String id, String name, String slug, {String? parentId}) async {
    if (name.trim().isEmpty) return false;

    // Auto-expand parent category if updating parentId
    if (parentId != null && parentId.trim().isNotEmpty) {
      expandCategory(parentId);
    }

    final result = await categoryRepository.updateCategory(
      id,
      name.trim(),
      slug.trim(),
      parentId: parentId,
    );
    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        if (Get.context != null) {
          AppToast.showError(Get.context!, 'Gagal memperbarui kategori: ${failure.message}');
        }
        return false;
      },
      (_) async {
        await fetchCategories(isInitial: false);
        if (Get.context != null) {
          AppToast.showSuccess(Get.context!, 'Kategori berhasil diperbarui.');
        }
        return true;
      },
    );
  }

  Future<bool> deleteCategory(String id, String name) async {
    final result = await categoryRepository.deleteCategory(id);
    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        String displayMsg = failure.message;
        if (failure.code == '23503' || failure.message.contains('23503') || failure.message.contains('foreign key')) {
          displayMsg = 'Kategori "$name" masih digunakan oleh data lain / sub-kategori.';
        }
        if (Get.context != null) {
          AppToast.showError(Get.context!, 'Gagal menghapus kategori: $displayMsg');
        }
        return false;
      },
      (_) async {
        expandedCategoryIds.remove(id);
        await fetchCategories(isInitial: false);
        if (Get.context != null) {
          AppToast.showSuccess(Get.context!, 'Kategori "$name" berhasil dihapus.');
        }
        return true;
      },
    );
  }
}
