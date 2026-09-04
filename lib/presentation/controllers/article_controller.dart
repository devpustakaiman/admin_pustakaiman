import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/article_repository.dart';
import '../../domain/usecases/add_article_usecase.dart';
import '../../domain/usecases/delete_article_usecase.dart';
import '../../domain/usecases/get_articles_usecase.dart';
import '../../domain/usecases/update_article_usecase.dart';
import '../../core/utils/app_toast.dart';

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
  final RxString searchQuery = ''.obs;
  final RxString sortBy = 'date'.obs; // 'date', 'title', 'author'
  final RxBool isAscending = false.obs; // false = newest first by default

  List<Article> get filteredArticles {
    List<Article> result = List.from(articles);

    // 1. Text Search Filter
    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.toLowerCase().trim();
      result = result.where((article) {
        final titleMatch = article.title.toLowerCase().contains(query);
        final authorMatch = article.author.toLowerCase().contains(query);
        return titleMatch || authorMatch;
      }).toList();
    }

    // 2. Sorting
    result.sort((a, b) {
      int comparison = 0;
      switch (sortBy.value) {
        case 'title':
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case 'author':
          comparison = a.author.toLowerCase().compareTo(b.author.toLowerCase());
          break;
        case 'date':
        default:
          comparison = a.date.compareTo(b.date);
          break;
      }
      return isAscending.value ? comparison : -comparison;
    });

    return result;
  }

  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxString uploadStatusMessage = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxString editingArticleId = ''.obs;
  final RxInt currentPage = 0.obs;
  final RxInt totalArticlesCount = 0.obs;
  final int pageSize = 15;

  final Rx<PlatformFile?> selectedHeaderImageFile = Rx<PlatformFile?>(null);

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
    selectedHeaderImageFile.value = null;
    uploadStatusMessage.value = '';
    isUploading.value = false;
  }

  Future<void> pickHeaderImageFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        selectedHeaderImageFile.value = result.files.first;
      }
    } catch (e) {
      errorMessage.value = 'Gagal memilih file gambar header: $e';
    }
  }

  Future<String?> uploadHeaderImageToStorage(PlatformFile file) async {
    Uint8List? bytes = file.bytes;
    if (bytes == null) {
      throw Exception('Data file gambar kosong');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = file.extension ?? 'jpg';
    final sanitizedName = file.name
        .replaceAll(RegExp(r'[^a-zA-Z0-9\._-]'), '_')
        .toLowerCase();
    final path = 'article-$timestamp-$sanitizedName';

    final contentType = 'image/${extension == "png" ? "png" : "jpeg"}';
    final supabase = Supabase.instance.client;
    await supabase.storage.from('pustaka-assets').uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: contentType,
          ),
        );

    return supabase.storage.from('pustaka-assets').getPublicUrl(path);
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
      selectedHeaderImageFile.value = null;

      // On-demand: Fetch full Quill content if omitted from list query
      Get.find<ArticleRepository>().getArticleById(article.id).then((res) {
        res.fold((_) {}, (full) {
          if (full != null && full.content.isNotEmpty) {
            setContent(full.content);
          }
        });
      });
    } else {
      editingArticleId.value = '';
      clearForm();
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 750),
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
                      const SizedBox(height: 16),

                      // Header Image Upload Button
                      const Text(
                        'Gambar Header Artikel',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Obx(() {
                        final file = selectedHeaderImageFile.value;
                        final existingUrl = imageUrlController.text;
                        return Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: isUploading.value
                                  ? null
                                  : () => pickHeaderImageFile(),
                              icon: const Icon(Icons.image, size: 18),
                              label: const Text('Upload File Gambar'),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                file != null
                                    ? 'File: ${file.name}'
                                    : (existingUrl.isNotEmpty
                                        ? 'URL: ${existingUrl.length > 35 ? "${existingUrl.substring(0, 35)}..." : existingUrl}'
                                        : 'Belum ada gambar dipilih'),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: file != null
                                      ? Colors.deepPurple
                                      : Colors.grey[700],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),

                      const SizedBox(height: 16),
                      Obx(() {
                        if (!isUploading.value) return const SizedBox.shrink();
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  uploadStatusMessage.value.isNotEmpty
                                      ? uploadStatusMessage.value
                                      : 'Mengunggah gambar header ke Supabase Storage...',
                                  style:
                                      const TextStyle(fontSize: 12, color: Colors.blue),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
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
                  Obx(() {
                    return ElevatedButton(
                      onPressed: (isLoading.value || isUploading.value)
                          ? null
                          : () => saveArticle(),
                      child: (isLoading.value || isUploading.value)
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Simpan'),
                    );
                  }),
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

  Future<void> fetchArticles({int? page}) async {
    if (page != null) currentPage.value = page;
    isLoading.value = true;
    errorMessage.value = '';

    // Server-side exact count
    final countRes = await Get.find<ArticleRepository>().getArticlesCount();
    countRes.fold((_) {}, (cnt) => totalArticlesCount.value = cnt);

    // 15-item lazy loading / pagination
    final result = await getArticlesUseCase.call(page: currentPage.value, pageSize: pageSize);
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

  void nextPage() {
    if ((currentPage.value + 1) * pageSize < totalArticlesCount.value) {
      fetchArticles(page: currentPage.value + 1);
    }
  }

  void prevPage() {
    if (currentPage.value > 0) {
      fetchArticles(page: currentPage.value - 1);
    }
  }

  Future<bool> saveArticle() async {
    if (titleController.text.trim().isEmpty) {
      errorMessage.value = 'Judul artikel tidak boleh kosong';
      return false;
    }

    isLoading.value = true;
    isUploading.value = true;
    errorMessage.value = '';

    try {
      if (selectedHeaderImageFile.value != null) {
        uploadStatusMessage.value = 'Mengunggah Gambar Header...';
        final imageUrl =
            await uploadHeaderImageToStorage(selectedHeaderImageFile.value!);
        if (imageUrl != null) {
          imageUrlController.text = imageUrl;
        }
      }

      uploadStatusMessage.value = 'Menyimpan artikel...';

      final isEdit = editingArticleId.value.isNotEmpty;
      final articleTitle = titleController.text.trim();
      bool success = false;
      if (!isEdit) {
        success = await addArticle();
      } else {
        success = await updateArticle();
      }

      if (success) {
        if (Get.isDialogOpen ?? false) Get.back();
        if (Get.context != null) {
          AppToast.showSuccess(
            Get.context!,
            isEdit ? 'Artikel "$articleTitle" berhasil diperbarui' : 'Artikel "$articleTitle" berhasil ditambahkan',
          );
        }
      } else {
        if (Get.context != null) {
          AppToast.showError(
            Get.context!,
            errorMessage.value.isNotEmpty ? errorMessage.value : 'Gagal menyimpan artikel',
          );
        }
      }
      return success;
    } catch (e) {
      errorMessage.value = 'Gagal menyimpan artikel: $e';
      if (Get.context != null) {
        AppToast.showError(Get.context!, errorMessage.value);
      }
      return false;
    } finally {
      isUploading.value = false;
      isLoading.value = false;
      uploadStatusMessage.value = '';
    }
  }

  Future<bool> addArticle() async {
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
    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        return false;
      },
      (_) async {
        clearForm();
        await fetchArticles();
        return true;
      },
    );
  }

  Future<bool> updateArticle() async {
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
    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        return false;
      },
      (_) async {
        clearForm();
        editingArticleId.value = '';
        await fetchArticles();
        return true;
      },
    );
  }

  Future<bool> deleteArticle(String id) async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await deleteArticleUseCase.call(id);
    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        if (Get.context != null) {
          AppToast.showError(Get.context!, 'Gagal memindahkan artikel: ${failure.message}');
        }
        return false;
      },
      (_) async {
        await fetchArticles();
        return true;
      },
    );
  }
}
