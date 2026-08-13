import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import '../../domain/entities/article.dart';
import '../../domain/usecases/add_article_usecase.dart';
import '../../domain/usecases/delete_article_usecase.dart';
import '../../domain/usecases/get_articles_usecase.dart';
import '../../domain/usecases/update_article_usecase.dart';

class ArticleController extends GetxController {
  final GetArticlesUseCase getArticlesUseCase;
  final AddArticleUseCase addArticleUseCase;
  final UpdateArticleUseCase updateArticleUseCase;
  final DeleteArticleUseCase deleteArticleUseCase;

  ArticleController({
    required this.getArticlesUseCase,
    required this.addArticleUseCase,
    required this.updateArticleUseCase,
    required this.deleteArticleUseCase,
  });

  final RxList<Article> articles = <Article>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString editingArticleId = ''.obs;

  // Form Controllers
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final imageUrlController = TextEditingController();
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // Quill Controller for Rich Text Content
  late QuillController quillController;

  @override
  void onInit() {
    super.onInit();
    quillController = QuillController.basic();
    fetchArticles();
  }

  @override
  void onClose() {
    titleController.dispose();
    authorController.dispose();
    imageUrlController.dispose();
    quillController.dispose();
    super.onClose();
  }

  void clearForm() {
    titleController.clear();
    authorController.clear();
    imageUrlController.clear();
    selectedDate.value = DateTime.now();
    quillController.document = Document();
  }

  void setContent(String content) {
    if (content.trim().isEmpty) {
      quillController.document = Document();
      return;
    }

    try {
      final json = jsonDecode(content);
      if (json is List) {
        quillController.document = Document.fromJson(json);
        return;
      }
    } catch (_) {}

    // Fallback: load as plain text
    final doc = Document();
    doc.insert(0, content);
    quillController.document = doc;
  }

  String getContentAsString() {
    final deltaJson = quillController.document.toDelta().toJson();
    return jsonEncode(deltaJson);
  }

  void openFormDialog({Article? article}) {
    if (article != null) {
      editingArticleId.value = article.id;
      titleController.text = article.title;
      authorController.text = article.author;
      imageUrlController.text = article.imageUrl;
      selectedDate.value = article.date;
      setContent(article.content);
    } else {
      editingArticleId.value = '';
      clearForm();
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 700,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    editingArticleId.value.isEmpty
                        ? 'Tambah Artikel Baru'
                        : 'Edit Artikel',
                    style: Get.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul Artikel',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: authorController,
                              decoration: const InputDecoration(
                                labelText: 'Penulis',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Obx(
                              () => InkWell(
                                onTap: () => pickDate(),
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: 'Tanggal Artikel',
                                    border: OutlineInputBorder(),
                                    suffixIcon: Icon(Icons.calendar_today),
                                  ),
                                  child: Text(
                                    selectedDate.value
                                        .toString()
                                        .split(' ')
                                        .first,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'URL Gambar Header',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Konten Artikel (Rich Text Editor):',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            QuillSimpleToolbar(
                              controller: quillController,
                            ),
                            const Divider(height: 1),
                            Container(
                              height: 250,
                              padding: const EdgeInsets.all(12),
                              child: QuillEditor.basic(
                                controller: quillController,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => saveArticle(),
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  Future<void> fetchArticles() async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await getArticlesUseCase.call();
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (data) {
        articles.assignAll(data);
        isLoading.value = false;
      },
    );
  }

  Future<void> saveArticle() async {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Judul artikel tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (Get.isDialogOpen ?? false) Get.back();
    isLoading.value = true;
    errorMessage.value = '';

    if (editingArticleId.value.isEmpty) {
      await addArticle();
    } else {
      await updateArticle();
    }
  }

  Future<void> addArticle() async {
    final newArticle = Article(
      id: '',
      title: titleController.text.trim(),
      content: getContentAsString(),
      date: selectedDate.value,
      author: authorController.text.trim(),
      imageUrl: imageUrlController.text.trim(),
      createdAt: DateTime.now(),
    );

    final result = await addArticleUseCase.call(newArticle);
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        Get.snackbar(
          'Gagal',
          failure.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
      (_) async {
        clearForm();
        await fetchArticles();
        Get.snackbar(
          'Sukses',
          'Artikel berhasil ditambahkan',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      },
    );
  }

  Future<void> updateArticle() async {
    final updatedArticle = Article(
      id: editingArticleId.value,
      title: titleController.text.trim(),
      content: getContentAsString(),
      date: selectedDate.value,
      author: authorController.text.trim(),
      imageUrl: imageUrlController.text.trim(),
      createdAt: DateTime.now(),
    );

    final result = await updateArticleUseCase.call(updatedArticle);
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        Get.snackbar(
          'Gagal',
          failure.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
      (_) async {
        clearForm();
        editingArticleId.value = '';
        await fetchArticles();
        Get.snackbar(
          'Sukses',
          'Artikel berhasil diperbarui',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      },
    );
  }

  Future<void> deleteArticle(String id) async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await deleteArticleUseCase.call(id);
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        Get.snackbar(
          'Gagal',
          failure.message,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
      (_) async {
        await fetchArticles();
        Get.snackbar(
          'Sukses',
          'Artikel berhasil dihapus',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      },
    );
  }
}
