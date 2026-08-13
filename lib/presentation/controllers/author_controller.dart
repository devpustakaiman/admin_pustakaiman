import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/entities/author.dart';
import '../../domain/usecases/add_author_usecase.dart';
import '../../domain/usecases/delete_author_usecase.dart';
import '../../domain/usecases/get_authors_usecase.dart';
import '../../domain/usecases/update_author_usecase.dart';

class AuthorController extends GetxController {
  final GetAuthorsUseCase getAuthorsUseCase;
  final AddAuthorUseCase addAuthorUseCase;
  final UpdateAuthorUseCase updateAuthorUseCase;
  final DeleteAuthorUseCase deleteAuthorUseCase;

  AuthorController({
    required this.getAuthorsUseCase,
    required this.addAuthorUseCase,
    required this.updateAuthorUseCase,
    required this.deleteAuthorUseCase,
  });

  final RxList<Author> authors = <Author>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString editingAuthorId = ''.obs;

  // Form Controllers
  final nameController = TextEditingController();
  final bioController = TextEditingController();
  final photoUrlController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchAuthors();
  }

  @override
  void onClose() {
    nameController.dispose();
    bioController.dispose();
    photoUrlController.dispose();
    super.onClose();
  }

  void clearForm() {
    nameController.clear();
    bioController.clear();
    photoUrlController.clear();
  }

  void openFormDialog({Author? author}) {
    if (author != null) {
      editingAuthorId.value = author.id;
      nameController.text = author.name;
      bioController.text = author.bio;
      photoUrlController.text = author.photoUrl;
    } else {
      editingAuthorId.value = '';
      clearForm();
    }

    Get.dialog(
      AlertDialog(
        title: Text(
          editingAuthorId.value.isEmpty ? 'Tambah Penulis Baru' : 'Edit Penulis',
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Penulis',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Biografi',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: photoUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL Foto',
                    border: OutlineInputBorder(),
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
            onPressed: () => saveAuthor(),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> fetchAuthors() async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await getAuthorsUseCase.call();
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (data) {
        authors.assignAll(data);
        isLoading.value = false;
      },
    );
  }

  Future<void> saveAuthor() async {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Nama penulis tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (Get.isDialogOpen ?? false) Get.back();
    isLoading.value = true;
    errorMessage.value = '';

    if (editingAuthorId.value.isEmpty) {
      await addAuthor();
    } else {
      await updateAuthor();
    }
  }

  Future<void> addAuthor() async {
    final newAuthor = Author(
      id: '',
      name: nameController.text.trim(),
      bio: bioController.text.trim(),
      photoUrl: photoUrlController.text.trim(),
      createdAt: DateTime.now(),
    );

    final result = await addAuthorUseCase.call(newAuthor);
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
        await fetchAuthors();
        Get.snackbar(
          'Sukses',
          'Penulis berhasil ditambahkan',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      },
    );
  }

  Future<void> updateAuthor() async {
    final updatedAuthor = Author(
      id: editingAuthorId.value,
      name: nameController.text.trim(),
      bio: bioController.text.trim(),
      photoUrl: photoUrlController.text.trim(),
      createdAt: DateTime.now(),
    );

    final result = await updateAuthorUseCase.call(updatedAuthor);
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
        editingAuthorId.value = '';
        await fetchAuthors();
        Get.snackbar(
          'Sukses',
          'Penulis berhasil diperbarui',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      },
    );
  }

  Future<void> deleteAuthor(String id) async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await deleteAuthorUseCase.call(id);
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
        await fetchAuthors();
        Get.snackbar(
          'Sukses',
          'Penulis berhasil dihapus',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      },
    );
  }
}
