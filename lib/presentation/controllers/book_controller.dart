import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/book.dart';
import '../../domain/usecases/add_book_usecase.dart';
import '../../domain/usecases/delete_book_usecase.dart';
import '../../domain/usecases/get_books_usecase.dart';
import '../../domain/usecases/update_book_usecase.dart';

class BookController extends GetxController {
  final GetBooksUseCase getBooksUseCase;
  final AddBookUseCase addBookUseCase;
  final UpdateBookUseCase updateBookUseCase;
  final DeleteBookUseCase deleteBookUseCase;

  BookController({
    required this.getBooksUseCase,
    required this.addBookUseCase,
    required this.updateBookUseCase,
    required this.deleteBookUseCase,
  });

  final RxList<Book> books = <Book>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxString uploadStatusMessage = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxString editingBookId = ''.obs;

  // Selected files for upload
  final Rx<PlatformFile?> selectedCoverFile = Rx<PlatformFile?>(null);
  final Rx<PlatformFile?> selectedPdfFile = Rx<PlatformFile?>(null);

  // Form Controllers
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final synopsisController = TextEditingController();
  final coverUrlController = TextEditingController();
  final pdfPreviewUrlController = TextEditingController();
  final mizanstoreUrlController = TextEditingController();
  final categoryController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchBooks();
  }

  @override
  void onClose() {
    titleController.dispose();
    authorController.dispose();
    synopsisController.dispose();
    coverUrlController.dispose();
    pdfPreviewUrlController.dispose();
    mizanstoreUrlController.dispose();
    categoryController.dispose();
    super.onClose();
  }

  void clearForm() {
    titleController.clear();
    authorController.clear();
    synopsisController.clear();
    coverUrlController.clear();
    pdfPreviewUrlController.clear();
    mizanstoreUrlController.clear();
    categoryController.clear();
    selectedCoverFile.value = null;
    selectedPdfFile.value = null;
    uploadStatusMessage.value = '';
    isUploading.value = false;
  }

  Future<void> pickCoverFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        selectedCoverFile.value = result.files.first;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih file gambar: $e');
    }
  }

  Future<void> pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        selectedPdfFile.value = result.files.first;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih file PDF: $e');
    }
  }

  Future<String?> uploadFileToStorage({
    required String bucket,
    required PlatformFile file,
  }) async {
    Uint8List? bytes = file.bytes;
    if (bytes == null && file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    }

    if (bytes == null) {
      throw Exception('Data file kosong atau tidak dapat dibaca');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = file.extension ?? (bucket == 'pustaka-assets' ? 'jpg' : 'pdf');
    final sanitizedName = file.name
        .replaceAll(RegExp(r'[^a-zA-Z0-9\._-]'), '_')
        .toLowerCase();
    final path = '$timestamp-$sanitizedName';

    final contentType = bucket == 'pustaka-assets'
        ? 'image/${extension == "png" ? "png" : "jpeg"}'
        : 'application/pdf';

    final supabase = Supabase.instance.client;
    await supabase.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: contentType,
          ),
        );

    final publicUrl = supabase.storage.from(bucket).getPublicUrl(path);
    return publicUrl;
  }

  void openFormDialog({Book? book}) {
    if (book != null) {
      editingBookId.value = book.id;
      titleController.text = book.title;
      authorController.text = book.author;
      synopsisController.text = book.synopsis;
      coverUrlController.text = book.coverUrl;
      pdfPreviewUrlController.text = book.pdfPreviewUrl;
      mizanstoreUrlController.text = book.mizanstoreUrl;
      categoryController.text = book.category;
      selectedCoverFile.value = null;
      selectedPdfFile.value = null;
    } else {
      editingBookId.value = '';
      clearForm();
    }

    Get.dialog(
      AlertDialog(
        title: Text(
          editingBookId.value.isEmpty ? 'Tambah Buku Baru' : 'Edit Buku',
        ),
        content: SizedBox(
          width: 550,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Judul Buku'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: authorController,
                  decoration: const InputDecoration(labelText: 'Penulis'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: synopsisController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Sinopsis'),
                ),
                const SizedBox(height: 16),

                // Cover Image File Upload Field
                const Text(
                  'Cover Buku (Gambar)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Obx(() {
                  final file = selectedCoverFile.value;
                  final existingUrl = coverUrlController.text;
                  return Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: isUploading.value ? null : () => pickCoverFile(),
                        icon: const Icon(Icons.image, size: 18),
                        label: const Text('Pilih File Cover'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          file != null
                              ? 'File: ${file.name}'
                              : (existingUrl.isNotEmpty
                                  ? 'URL: ${existingUrl.length > 35 ? "${existingUrl.substring(0, 35)}..." : existingUrl}'
                                  : 'Belum ada file dipilih'),
                          style: TextStyle(
                            fontSize: 12,
                            color: file != null ? Colors.deepPurple : Colors.grey[700],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 16),

                // PDF Preview File Upload Field
                const Text(
                  'Preview PDF (Naskah)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Obx(() {
                  final file = selectedPdfFile.value;
                  final existingUrl = pdfPreviewUrlController.text;
                  return Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: isUploading.value ? null : () => pickPdfFile(),
                        icon: const Icon(Icons.picture_as_pdf, size: 18),
                        label: const Text('Pilih File PDF'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          file != null
                              ? 'File: ${file.name}'
                              : (existingUrl.isNotEmpty
                                  ? 'URL: ${existingUrl.length > 35 ? "${existingUrl.substring(0, 35)}..." : existingUrl}'
                                  : 'Belum ada file dipilih'),
                          style: TextStyle(
                            fontSize: 12,
                            color: file != null ? Colors.deepPurple : Colors.grey[700],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 16),

                TextField(
                  controller: mizanstoreUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Link Pembelian MMU/Mizanstore',
                  ),
                ),

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
                                : 'Mengunggah file ke Supabase Storage...',
                            style: const TextStyle(fontSize: 12, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          Obx(() {
            return ElevatedButton(
              onPressed: (isLoading.value || isUploading.value) ? null : () => saveBook(),
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
    );
  }

  Future<void> fetchBooks() async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await getBooksUseCase.call();
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (data) {
        books.assignAll(data);
        isLoading.value = false;
      },
    );
  }

  Future<void> saveBook() async {
    isLoading.value = true;
    isUploading.value = true;
    errorMessage.value = '';

    try {
      // 1. Upload Cover Image if selected
      if (selectedCoverFile.value != null) {
        uploadStatusMessage.value = 'Mengunggah Cover Gambar...';
        final coverUrl = await uploadFileToStorage(
          bucket: 'pustaka-assets',
          file: selectedCoverFile.value!,
        );
        if (coverUrl != null) {
          coverUrlController.text = coverUrl;
        }
      }

      // 2. Upload Preview PDF if selected
      if (selectedPdfFile.value != null) {
        uploadStatusMessage.value = 'Mengunggah Preview PDF...';
        final pdfUrl = await uploadFileToStorage(
          bucket: 'naskah',
          file: selectedPdfFile.value!,
        );
        if (pdfUrl != null) {
          pdfPreviewUrlController.text = pdfUrl;
        }
      }

      uploadStatusMessage.value = 'Menyimpan data buku...';

      if (editingBookId.value.isEmpty) {
        await addBook();
      } else {
        await updateBook();
      }

      if (Get.isDialogOpen ?? false) Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengunggah file atau menyimpan buku: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploading.value = false;
      isLoading.value = false;
      uploadStatusMessage.value = '';
    }
  }

  Future<void> addBook() async {
    final newBook = Book(
      id: '',
      title: titleController.text.trim(),
      author: authorController.text.trim(),
      synopsis: synopsisController.text.trim(),
      coverUrl: coverUrlController.text.trim(),
      pdfPreviewUrl: pdfPreviewUrlController.text.trim(),
      mizanstoreUrl: mizanstoreUrlController.text.trim(),
      category: categoryController.text.trim(),
    );

    final result = await addBookUseCase.call(newBook);
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (_) async {
        clearForm();
        await fetchBooks();
      },
    );
  }

  Future<void> updateBook() async {
    final updatedBook = Book(
      id: editingBookId.value,
      title: titleController.text.trim(),
      author: authorController.text.trim(),
      synopsis: synopsisController.text.trim(),
      coverUrl: coverUrlController.text.trim(),
      pdfPreviewUrl: pdfPreviewUrlController.text.trim(),
      mizanstoreUrl: mizanstoreUrlController.text.trim(),
      category: categoryController.text.trim(),
    );

    final result = await updateBookUseCase.call(updatedBook);
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (_) async {
        clearForm();
        editingBookId.value = '';
        await fetchBooks();
      },
    );
  }

  Future<void> deleteBook(String id) async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await deleteBookUseCase.call(id);
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (_) async {
        await fetchBooks();
      },
    );
  }
}
