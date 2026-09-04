import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/datasources/supabase_remote_data_source.dart';
import '../../data/models/preorder_model.dart';
import '../../domain/entities/article.dart';
import '../../domain/entities/author.dart';
import '../../domain/entities/book.dart';
import '../../domain/entities/submission.dart';
import '../../domain/repositories/article_repository.dart';
import '../../domain/repositories/author_repository.dart';
import '../../domain/repositories/book_repository.dart';
import '../../domain/repositories/submission_repository.dart';
import 'article_controller.dart';
import 'author_controller.dart';
import 'book_controller.dart';
import 'preorder_controller.dart';
import 'submission_controller.dart';

enum TrashCategory { books, authors, articles, submissions, preorders }

class TrashController extends GetxController {
  final BookRepository bookRepository;
  final AuthorRepository authorRepository;
  final ArticleRepository articleRepository;
  final SubmissionRepository submissionRepository;
  final SupabaseRemoteDataSource remoteDataSource;

  TrashController({
    required this.bookRepository,
    required this.authorRepository,
    required this.articleRepository,
    required this.submissionRepository,
    SupabaseRemoteDataSource? dataSource,
  }) : remoteDataSource = dataSource ?? Get.find<SupabaseRemoteDataSource>();

  final Rx<TrashCategory> activeCategory = TrashCategory.books.obs;
  final RxList<Book> deletedBooks = <Book>[].obs;
  final RxList<Author> deletedAuthors = <Author>[].obs;
  final RxList<Article> deletedArticles = <Article>[].obs;
  final RxList<Submission> deletedSubmissions = <Submission>[].obs;
  final RxList<PreorderModel> deletedPreorders = <PreorderModel>[].obs;

  final RxSet<String> selectedIds = <String>{}.obs;
  final RxBool isLoading = false.obs;
  final RxBool isProcessing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllDeleted();
  }

  void changeCategory(TrashCategory category) {
    activeCategory.value = category;
    selectedIds.clear();
    fetchCurrentCategory();
  }

  Future<void> fetchAllDeleted() async {
    isLoading.value = true;
    errorMessage.value = '';
    await Future.wait([
      _fetchDeletedBooks(),
      _fetchDeletedAuthors(),
      _fetchDeletedArticles(),
      _fetchDeletedSubmissions(),
      _fetchDeletedPreorders(),
    ]);
    isLoading.value = false;
  }

  Future<void> fetchCurrentCategory() async {
    isLoading.value = true;
    errorMessage.value = '';
    switch (activeCategory.value) {
      case TrashCategory.books:
        await _fetchDeletedBooks();
        break;
      case TrashCategory.authors:
        await _fetchDeletedAuthors();
        break;
      case TrashCategory.articles:
        await _fetchDeletedArticles();
        break;
      case TrashCategory.submissions:
        await _fetchDeletedSubmissions();
        break;
      case TrashCategory.preorders:
        await _fetchDeletedPreorders();
        break;
    }
    isLoading.value = false;
  }

  Future<void> _fetchDeletedBooks() async {
    final result = await bookRepository.getDeletedBooks();
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (data) {
        deletedBooks.assignAll(data);
        if (activeCategory.value == TrashCategory.books) {
          final validIds = data.map((b) => b.id).toSet();
          selectedIds.retainWhere((id) => validIds.contains(id));
        }
      },
    );
  }

  Future<void> _fetchDeletedAuthors() async {
    final result = await authorRepository.getDeletedAuthors();
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (data) {
        deletedAuthors.assignAll(data);
        if (activeCategory.value == TrashCategory.authors) {
          final validIds = data.map((a) => a.id).toSet();
          selectedIds.retainWhere((id) => validIds.contains(id));
        }
      },
    );
  }

  Future<void> _fetchDeletedArticles() async {
    final result = await articleRepository.getDeletedArticles();
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (data) {
        deletedArticles.assignAll(data);
        if (activeCategory.value == TrashCategory.articles) {
          final validIds = data.map((a) => a.id).toSet();
          selectedIds.retainWhere((id) => validIds.contains(id));
        }
      },
    );
  }

  Future<void> _fetchDeletedSubmissions() async {
    final result = await submissionRepository.getDeletedSubmissions();
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (data) {
        deletedSubmissions.assignAll(data);
        if (activeCategory.value == TrashCategory.submissions) {
          final validIds = data.map((s) => s.id).toSet();
          selectedIds.retainWhere((id) => validIds.contains(id));
        }
      },
    );
  }

  Future<void> _fetchDeletedPreorders() async {
    try {
      final rawData = await remoteDataSource.getDeletedPreorders();
      final data = rawData.map((j) => PreorderModel.fromJson(j)).toList();
      deletedPreorders.assignAll(data);
      if (activeCategory.value == TrashCategory.preorders) {
        final validIds = data.map((p) => p.id).toSet();
        selectedIds.retainWhere((id) => validIds.contains(id));
      }
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  // Filtered items getter
  List<dynamic> get currentFilteredList {
    final query = searchQuery.value.toLowerCase().trim();
    switch (activeCategory.value) {
      case TrashCategory.books:
        if (query.isEmpty) return deletedBooks;
        return deletedBooks.where((b) {
          return b.title.toLowerCase().contains(query) ||
              b.author.toLowerCase().contains(query) ||
              b.category.toLowerCase().contains(query);
        }).toList();
      case TrashCategory.authors:
        if (query.isEmpty) return deletedAuthors;
        return deletedAuthors.where((a) {
          return a.name.toLowerCase().contains(query) ||
              a.bio.toLowerCase().contains(query);
        }).toList();
      case TrashCategory.articles:
        if (query.isEmpty) return deletedArticles;
        return deletedArticles.where((a) {
          return a.title.toLowerCase().contains(query) ||
              a.author.toLowerCase().contains(query) ||
              a.content.toLowerCase().contains(query);
        }).toList();
      case TrashCategory.submissions:
        if (query.isEmpty) return deletedSubmissions;
        return deletedSubmissions.where((s) {
          return s.senderName.toLowerCase().contains(query) ||
              s.email.toLowerCase().contains(query) ||
              s.synopsis.toLowerCase().contains(query);
        }).toList();
      case TrashCategory.preorders:
        if (query.isEmpty) return deletedPreorders;
        return deletedPreorders.where((p) {
          return p.customerName.toLowerCase().contains(query) ||
              p.email.toLowerCase().contains(query) ||
              p.phone.toLowerCase().contains(query) ||
              p.bookTitle.toLowerCase().contains(query);
        }).toList();
    }
  }

  bool get isAllSelected {
    final list = currentFilteredList;
    if (list.isEmpty) return false;
    return list.every((item) => selectedIds.contains(_getItemId(item)));
  }

  bool get isPartiallySelected {
    final list = currentFilteredList;
    if (list.isEmpty) return false;
    final selectedCount = list.where((item) => selectedIds.contains(_getItemId(item))).length;
    return selectedCount > 0 && selectedCount < list.length;
  }

  String _getItemId(dynamic item) {
    if (item is Book) return item.id;
    if (item is Author) return item.id;
    if (item is Article) return item.id;
    if (item is Submission) return item.id;
    if (item is PreorderModel) return item.id;
    return '';
  }

  void toggleSelectItem(String id, bool? value) {
    if (value == true) {
      selectedIds.add(id);
    } else {
      selectedIds.remove(id);
    }
  }

  void toggleSelectAll(bool? value) {
    final list = currentFilteredList;
    if (value == true) {
      selectedIds.addAll(list.map((item) => _getItemId(item)));
    } else {
      for (final item in list) {
        selectedIds.remove(_getItemId(item));
      }
    }
  }

  void clearSelection() {
    selectedIds.clear();
  }

  Future<void> restoreSelectedItems() async {
    if (selectedIds.isEmpty) return;

    isProcessing.value = true;
    errorMessage.value = '';
    final idsToRestore = selectedIds.toList();

    switch (activeCategory.value) {
      case TrashCategory.books:
        final result = await bookRepository.restoreBooks(idsToRestore);
        _handleRestoreResult(result, idsToRestore, 'Buku', () {
          if (Get.isRegistered<BookController>()) {
            Get.find<BookController>().fetchBooks();
          }
        });
        break;
      case TrashCategory.authors:
        final result = await authorRepository.restoreAuthors(idsToRestore);
        _handleRestoreResult(result, idsToRestore, 'Penulis', () {
          if (Get.isRegistered<AuthorController>()) {
            Get.find<AuthorController>().fetchAuthors();
          }
        });
        break;
      case TrashCategory.articles:
        final result = await articleRepository.restoreArticles(idsToRestore);
        _handleRestoreResult(result, idsToRestore, 'Artikel', () {
          if (Get.isRegistered<ArticleController>()) {
            Get.find<ArticleController>().fetchArticles();
          }
        });
        break;
      case TrashCategory.submissions:
        final result = await submissionRepository.restoreSubmissions(idsToRestore);
        _handleRestoreResult(result, idsToRestore, 'Naskah', () {
          if (Get.isRegistered<SubmissionController>()) {
            Get.find<SubmissionController>().fetchSubmissions();
          }
        });
        break;
      case TrashCategory.preorders:
        try {
          await remoteDataSource.restorePreorders(idsToRestore);
          isProcessing.value = false;
          selectedIds.removeAll(idsToRestore);
          await fetchCurrentCategory();
          if (Get.isRegistered<PreorderController>()) {
            Get.find<PreorderController>().loadData();
          }
        } catch (e) {
          isProcessing.value = false;
          errorMessage.value = e.toString();
        }
        break;
    }
  }

  void _handleRestoreResult(
    dynamic result,
    List<String> ids,
    String label,
    VoidCallback onRefreshActive,
  ) {
    isProcessing.value = false;
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
      },
      (_) async {
        selectedIds.removeAll(ids);
        await fetchCurrentCategory();
        onRefreshActive();
      },
    );
  }

  Future<void> permanentlyDeleteSelectedItems() async {
    if (selectedIds.isEmpty) return;

    isProcessing.value = true;
    errorMessage.value = '';
    final idsToDelete = selectedIds.toList();

    switch (activeCategory.value) {
      case TrashCategory.books:
        final result = await bookRepository.permanentlyDeleteBooks(idsToDelete);
        _handlePermanentDeleteResult(result, idsToDelete, 'Buku');
        break;
      case TrashCategory.authors:
        final result = await authorRepository.permanentlyDeleteAuthors(idsToDelete);
        _handlePermanentDeleteResult(result, idsToDelete, 'Penulis');
        break;
      case TrashCategory.articles:
        final result = await articleRepository.permanentlyDeleteArticles(idsToDelete);
        _handlePermanentDeleteResult(result, idsToDelete, 'Artikel');
        break;
      case TrashCategory.submissions:
        final result = await submissionRepository.permanentlyDeleteSubmissions(idsToDelete);
        _handlePermanentDeleteResult(result, idsToDelete, 'Naskah');
        break;
      case TrashCategory.preorders:
        try {
          await remoteDataSource.permanentlyDeletePreorders(idsToDelete);
          isProcessing.value = false;
          selectedIds.removeAll(idsToDelete);
          await fetchCurrentCategory();
        } catch (e) {
          isProcessing.value = false;
          errorMessage.value = e.toString();
        }
        break;
    }
  }

  void _handlePermanentDeleteResult(
    dynamic result,
    List<String> ids,
    String label,
  ) {
    isProcessing.value = false;
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
      },
      (_) async {
        selectedIds.removeAll(ids);
        await fetchCurrentCategory();
      },
    );
  }
}

