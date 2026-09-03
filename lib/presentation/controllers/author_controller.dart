import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/author.dart';
import '../../domain/usecases/add_author_usecase.dart';
import '../../domain/usecases/delete_author_usecase.dart';
import '../../domain/usecases/get_authors_usecase.dart';
import '../../domain/usecases/update_author_usecase.dart';
import '../../domain/repositories/author_repository.dart';

class AuthorController extends GetxController {
  final GetAuthorsUseCase getAuthorsUseCase;
  final AddAuthorUseCase addAuthorUseCase;
  final UpdateAuthorUseCase updateAuthorUseCase;
  final DeleteAuthorUseCase deleteAuthorUseCase;
  final AuthorRepository authorRepository;

  AuthorController({
    required this.getAuthorsUseCase,
    required this.addAuthorUseCase,
    required this.updateAuthorUseCase,
    required this.deleteAuthorUseCase,
    AuthorRepository? repository,
  }) : authorRepository = repository ?? Get.find<AuthorRepository>();

  final RxList<Author> authors = <Author>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString sortBy = 'name'.obs; // 'name', 'date'
  final RxBool isAscending = true.obs;

  List<Author> get filteredAuthors {
    List<Author> result = List.from(authors);

    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.toLowerCase().trim();
      result = result.where((author) {
        final nameMatch = author.name.toLowerCase().contains(query);
        final bioMatch = author.bio.toLowerCase().contains(query);
        return nameMatch || bioMatch;
      }).toList();
    }

    result.sort((a, b) {
      int comparison = 0;
      if (sortBy.value == 'date') {
        comparison = a.createdAt.compareTo(b.createdAt);
      } else {
        comparison = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      return isAscending.value ? comparison : -comparison;
    });

    return result;
  }

  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxString uploadStatusMessage = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxString editingAuthorId = ''.obs;
  final RxInt currentPage = 0.obs;
  final RxInt totalAuthorsCount = 0.obs;
  final int pageSize = 15;

  final Rx<PlatformFile?> selectedPhotoFile = Rx<PlatformFile?>(null);

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
    selectedPhotoFile.value = null;
    uploadStatusMessage.value = '';
    isUploading.value = false;
  }

  Future<void> pickPhotoFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        selectedPhotoFile.value = result.files.first;
      }
    } catch (e) {
      errorMessage.value = 'Gagal memilih file foto: $e';
    }
  }

  Future<String?> uploadPhotoToStorage(PlatformFile file) async {
    Uint8List? bytes = file.bytes;
    if (bytes == null && file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    }
    if (bytes == null) {
      throw Exception('Data file foto kosong');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = file.extension ?? 'jpg';
    final sanitizedName = file.name
        .replaceAll(RegExp(r'[^a-zA-Z0-9\._-]'), '_')
        .toLowerCase();
    final path = 'author-$timestamp-$sanitizedName';

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

  void openFormDialog({Author? author}) {
    if (author != null) {
      editingAuthorId.value = author.id;
      nameController.text = author.name;
      bioController.text = author.bio;
      photoUrlController.text = author.photoUrl;
      selectedPhotoFile.value = null;

      // On-demand: Fetch full author details (e.g. bio) if omitted from list query
      authorRepository.getAuthorById(author.id).then((res) {
        res.fold((_) {}, (fullAuthor) {
          if (fullAuthor != null && fullAuthor.bio.isNotEmpty) {
            bioController.text = fullAuthor.bio;
          }
        });
      });
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
              crossAxisAlignment: CrossAxisAlignment.start,
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
                const SizedBox(height: 16),
                const Text(
                  'Foto Penulis',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Obx(() {
                  final file = selectedPhotoFile.value;
                  final existingUrl = photoUrlController.text;
                  return Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: isUploading.value ? null : () => pickPhotoFile(),
                        icon: const Icon(Icons.person, size: 18),
                        label: const Text('Upload File Foto'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          file != null
                              ? 'File: ${file.name}'
                              : (existingUrl.isNotEmpty
                                  ? 'URL: ${existingUrl.length > 30 ? "${existingUrl.substring(0, 30)}..." : existingUrl}'
                                  : 'Belum ada foto dipilih'),
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
                                : 'Mengunggah foto ke Supabase Storage...',
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
              onPressed: (isLoading.value || isUploading.value)
                  ? null
                  : () => saveAuthor(),
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

  Future<void> fetchAuthors({int? page}) async {
    if (page != null) currentPage.value = page;
    isLoading.value = true;
    errorMessage.value = '';

    // Server-side exact count
    final countRes = await authorRepository.getAuthorsCount();
    countRes.fold((_) {}, (cnt) => totalAuthorsCount.value = cnt);

    // 15-item lazy loading / pagination
    final result = await getAuthorsUseCase.call(page: currentPage.value, pageSize: pageSize);
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

  void nextPage() {
    if ((currentPage.value + 1) * pageSize < totalAuthorsCount.value) {
      fetchAuthors(page: currentPage.value + 1);
    }
  }

  void prevPage() {
    if (currentPage.value > 0) {
      fetchAuthors(page: currentPage.value - 1);
    }
  }

  Future<bool> saveAuthor() async {
    if (nameController.text.trim().isEmpty) {
      errorMessage.value = 'Nama penulis tidak boleh kosong';
      return false;
    }

    isLoading.value = true;
    isUploading.value = true;
    errorMessage.value = '';

    try {
      if (selectedPhotoFile.value != null) {
        uploadStatusMessage.value = 'Mengunggah Foto Penulis...';
        final photoUrl = await uploadPhotoToStorage(selectedPhotoFile.value!);
        if (photoUrl != null) {
          photoUrlController.text = photoUrl;
        }
      }

      uploadStatusMessage.value = 'Menyimpan data penulis...';

      bool success = false;
      if (editingAuthorId.value.isEmpty) {
        success = await addAuthor();
      } else {
        success = await updateAuthor();
      }

      if (success && (Get.isDialogOpen ?? false)) Get.back();
      return success;
    } catch (e) {
      errorMessage.value = 'Gagal menyimpan penulis: $e';
      return false;
    } finally {
      isUploading.value = false;
      isLoading.value = false;
      uploadStatusMessage.value = '';
    }
  }

  Future<bool> addAuthor() async {
    final newAuthor = Author(
      id: '',
      name: nameController.text.trim(),
      bio: bioController.text.trim(),
      photoUrl: photoUrlController.text.trim(),
      createdAt: DateTime.now(),
    );

    final result = await addAuthorUseCase.call(newAuthor);
    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        return false;
      },
      (_) async {
        clearForm();
        await fetchAuthors();
        return true;
      },
    );
  }

  Future<bool> updateAuthor() async {
    final updatedAuthor = Author(
      id: editingAuthorId.value,
      name: nameController.text.trim(),
      bio: bioController.text.trim(),
      photoUrl: photoUrlController.text.trim(),
      createdAt: DateTime.now(),
    );

    final result = await updateAuthorUseCase.call(updatedAuthor);
    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        return false;
      },
      (_) async {
        clearForm();
        editingAuthorId.value = '';
        await fetchAuthors();
        return true;
      },
    );
  }

  Future<bool> deleteAuthor(String id) async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await deleteAuthorUseCase.call(id);
    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        return false;
      },
      (_) async {
        await fetchAuthors();
        return true;
      },
    );
  }
}
