import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final RxString errorMessage = ''.obs;
  final RxString editingBookId = ''.obs;

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
    } else {
      editingBookId.value = '';
      clearForm();
    }

    Get.dialog(
      AlertDialog(
        title: Text(editingBookId.value.isEmpty ? 'Tambah Buku Baru' : 'Edit Buku'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                const SizedBox(height: 8),
                TextField(
                  controller: coverUrlController,
                  decoration: const InputDecoration(labelText: 'URL Cover'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: pdfPreviewUrlController,
                  decoration: const InputDecoration(labelText: 'URL Preview PDF'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: mizanstoreUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Link Pembelian MMU/Mizanstore',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => saveBook(),
            child: const Text('Simpan'),
          ),
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
    if (Get.isDialogOpen ?? false) Get.back();
    isLoading.value = true;
    errorMessage.value = '';

    if (editingBookId.value.isEmpty) {
      await addBook();
    } else {
      await updateBook();
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
