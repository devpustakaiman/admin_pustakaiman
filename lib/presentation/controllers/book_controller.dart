import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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

  static const List<String> mizanCategories = [
    'Agama & Filsafat - Agama Islam',
    'Agama & Filsafat - Filsafat',
    'Agama & Filsafat - Religi & Spiritual',
    'Al-Quran',
    'Bisnis & Ekonomi - Manajemen',
    'Bisnis & Ekonomi - Bisnis & Ekonomi',
    'Bisnis & Ekonomi - Investasi & Keuangan',
    'Buku Anak - Boardbook',
    'Buku Anak - Komik Anak',
    'Buku Anak - Cerita Anak',
    'Buku Anak - Aktivitas Anak',
    'Buku Anak - Pengetahuan & Sains Anak',
    'Diet & Health - Kesehatan, Kebugaran & Diet',
    'Diet & Health - Buku Resep & Makanan',
    'Fiksi - Action, Crime & Thrillers',
    'Fiksi - Fantasi',
    'Fiksi - Klasik',
    'Fiksi - Romansa',
    'Fiksi - Novel Sejarah & Filsafat',
    'Fiksi - Puisi, Prosa & Kumcer',
    'Fiksi - Novel Populer',
    'Fiksi - Sastra',
    'Fiksi - Komik',
    'Filsafat, Sejarah, Sastra Dan Budaya',
    'Lain-Lain',
    'Learning - Learning & Teaching',
    'Learning - Metode Pendidikan',
    'Mainan Edukatif - Boardgame',
    'Mainan Edukatif - Poster & Puzzle',
    'Mainan Edukatif - Flash Card',
    'Mainan Edukatif - Vcd Dan Aplikasi',
    'Mainan Edukatif - Merchandise',
    'Mainan Edukatif - Flip Card',
    'Non Fiksi',
    'Parenting & Child Development - Kehamilan Dan Kelahiran',
    'Parenting & Child Development - Bayi Dan Balita',
    'Parenting & Child Development - General Parenting',
    'Pengembangan Diri & Karier - Inspirasi & Motivasi',
    'Pengembangan Diri & Karier - Hobi',
    'Pengembangan Diri & Karier - Leadership',
    'Pengembangan Diri & Karier - Traveling',
    'Pengembangan Diri & Karier - Karier',
    'Psikologi - Psikologi Populer',
    'Psikologi - Self-Help',
    'Reference & Dictionary - Reference & Dictionary',
    'Reference & Dictionary - Ensiklopedia',
    'Schoolbook',
    'Social Science - Biografi',
    'Social Science - Memoar',
    'Social Science - Politik & Hukum',
    'Social Science - Bahasa',
    'Social Science - Sejarah & Sosial Budaya',
    'Social Science - Natural Science',
  ];

  final RxList<Book> books = <Book>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxString uploadStatusMessage = ''.obs;
  final RxString errorMessage = ''.obs;
  final RxString editingBookId = ''.obs;

  // Selected files for upload
  final Rx<PlatformFile?> selectedCoverFile = Rx<PlatformFile?>(null);
  final Rx<PlatformFile?> selectedPdfFile = Rx<PlatformFile?>(null);

  // Gallery multi-images
  final ImagePicker _imagePicker = ImagePicker();
  final RxList<String> existingGalleryUrls = <String>[].obs;
  final RxList<XFile> selectedGalleryFiles = <XFile>[].obs;

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
    existingGalleryUrls.clear();
    selectedGalleryFiles.clear();
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

  Future<void> pickGalleryImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        selectedGalleryFiles.addAll(images);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih gambar galeri: $e');
    }
  }

  void removeExistingGalleryUrl(int index) {
    if (index >= 0 && index < existingGalleryUrls.length) {
      existingGalleryUrls.removeAt(index);
    }
  }

  void removeSelectedGalleryFile(int index) {
    if (index >= 0 && index < selectedGalleryFiles.length) {
      selectedGalleryFiles.removeAt(index);
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
      existingGalleryUrls.assignAll(book.galleryUrls);
      selectedGalleryFiles.clear();
    } else {
      editingBookId.value = '';
      clearForm();
    }

    Get.dialog(
      Obx(() {
        final isBusy = isLoading.value || isUploading.value;
        return PopScope(
          canPop: !isBusy,
          child: Stack(
            children: [
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

                        // Smart Category Autocomplete
                        Autocomplete<String>(
                          initialValue: TextEditingValue(text: categoryController.text),
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return mizanCategories;
                            }
                            return mizanCategories.where((String option) {
                              return option
                                  .toLowerCase()
                                  .contains(textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: (String selection) {
                            categoryController.text = selection;
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Align(
                              alignment: Alignment.topLeft,
                              child: Material(
                                elevation: 4.0,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  constraints: const BoxConstraints(maxHeight: 220, maxWidth: 480),
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    shrinkWrap: true,
                                    itemCount: options.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      final String option = options.elementAt(index);
                                      return ListTile(
                                        dense: true,
                                        title: Text(option, style: const TextStyle(fontSize: 13)),
                                        onTap: () {
                                          onSelected(option);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          fieldViewBuilder:
                              (context, textController, focusNode, onFieldSubmitted) {
                            textController.addListener(() {
                              categoryController.text = textController.text;
                            });
                            return TextField(
                              controller: textController,
                              focusNode: focusNode,
                              decoration: const InputDecoration(
                                labelText: 'Kategori Buku',
                                hintText: 'Cari atau pilih kategori...',
                                suffixIcon: Icon(Icons.arrow_drop_down),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: synopsisController,
                          maxLines: 3,
                          decoration: const InputDecoration(labelText: 'Sinopsis'),
                        ),
                        const SizedBox(height: 16),

                        // Cover Image Visual Thumbnail Preview
                        const Text(
                          'Cover Buku (Gambar)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Obx(() {
                          final file = selectedCoverFile.value;
                          final existingUrl = coverUrlController.text.trim();

                          Widget previewContent;
                          if (file != null) {
                            if (file.bytes != null) {
                              previewContent = Image.memory(
                                file.bytes!,
                                width: 70,
                                height: 95,
                                fit: BoxFit.cover,
                              );
                            } else if (file.path != null) {
                              previewContent = Image.file(
                                File(file.path!),
                                width: 70,
                                height: 95,
                                fit: BoxFit.cover,
                              );
                            } else {
                              previewContent = Container(
                                width: 70,
                                height: 95,
                                color: Colors.grey[200],
                                child: const Icon(Icons.image, color: Colors.grey),
                              );
                            }
                          } else if (existingUrl.isNotEmpty &&
                              (existingUrl.startsWith('http://') || existingUrl.startsWith('https://'))) {
                            previewContent = Image.network(
                              existingUrl,
                              width: 70,
                              height: 95,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 70,
                                height: 95,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                            );
                          } else {
                            previewContent = Container(
                              width: 70,
                              height: 95,
                              color: Colors.grey[200],
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined, color: Colors.grey, size: 24),
                                  SizedBox(height: 4),
                                  Text(
                                    'Kosong',
                                    style: TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: previewContent,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: isBusy ? null : () => pickCoverFile(),
                                      icon: const Icon(Icons.image, size: 18),
                                      label: const Text('Pilih File Cover'),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
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
                                  ],
                                ),
                              ),
                            ],
                          );
                        }),
                        const SizedBox(height: 16),

                        // Multi-Image Gallery Picker Section
                        const Text(
                          'Galeri Foto Buku (Multi-Image)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          onPressed: isBusy ? null : () => pickGalleryImages(),
                          icon: const Icon(Icons.photo_library, size: 18),
                          label: const Text('Pilih Foto Galeri'),
                        ),
                        const SizedBox(height: 8),

                        // Gallery Preview Grid
                        Obx(() {
                          final hasExisting = existingGalleryUrls.isNotEmpty;
                          final hasSelected = selectedGalleryFiles.isNotEmpty;

                          if (!hasExisting && !hasSelected) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.0),
                              child: Text(
                                'Belum ada gambar galeri dipilih',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            );
                          }

                          return Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                // Existing Gallery Images (From URL)
                                for (int i = 0; i < existingGalleryUrls.length; i++)
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.network(
                                          existingGalleryUrls[i],
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            width: 80,
                                            height: 80,
                                            color: Colors.grey[300],
                                            child: const Icon(Icons.broken_image),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: InkWell(
                                          onTap: isBusy ? null : () => removeExistingGalleryUrl(i),
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                // Newly Selected Gallery Files (Local XFile)
                                for (int i = 0; i < selectedGalleryFiles.length; i++)
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: FutureBuilder<Uint8List>(
                                          future: selectedGalleryFiles[i].readAsBytes(),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              return Image.memory(
                                                snapshot.data!,
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              );
                                            }
                                            return Container(
                                              width: 80,
                                              height: 80,
                                              color: Colors.grey[200],
                                              child: const Center(
                                                child: SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child: CircularProgressIndicator(strokeWidth: 2),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      Positioned(
                                        top: 2,
                                        right: 2,
                                        child: InkWell(
                                          onTap: isBusy ? null : () => removeSelectedGalleryFile(i),
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
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
                                onPressed: isBusy ? null : () => pickPdfFile(),
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
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: isBusy ? null : () => Get.back(),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: isBusy ? null : () => saveBook(),
                    child: const Text('Simpan'),
                  ),
                ],
              ),

              // Loading Overlay during submission/upload
              if (isBusy)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32.0,
                            vertical: 24.0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              Text(
                                uploadStatusMessage.value.isNotEmpty
                                    ? uploadStatusMessage.value
                                    : 'Memproses data...',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
      barrierDismissible: false,
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

      // 3. Upload Gallery Images if selected
      List<String> uploadedGalleryUrls = [];
      if (selectedGalleryFiles.isNotEmpty) {
        final supabase = Supabase.instance.client;
        for (int i = 0; i < selectedGalleryFiles.length; i++) {
          uploadStatusMessage.value =
              'Mengunggah Gambar Galeri (${i + 1}/${selectedGalleryFiles.length})...';
          final file = selectedGalleryFiles[i];
          final bytes = await file.readAsBytes();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final extension = file.name.contains('.')
              ? file.name.split('.').last.toLowerCase()
              : 'jpg';
          final ext =
              ['jpg', 'jpeg', 'png', 'webp'].contains(extension) ? extension : 'jpg';
          final sanitizedName = file.name
              .replaceAll(RegExp(r'[^a-zA-Z0-9\._-]'), '_')
              .toLowerCase();
          final path = 'gallery/$timestamp-$i-$sanitizedName';
          final contentType =
              'image/${ext == "png" ? "png" : (ext == "webp" ? "webp" : "jpeg")}';

          await supabase.storage.from('pustaka-assets').uploadBinary(
                path,
                bytes,
                fileOptions: FileOptions(
                  upsert: true,
                  contentType: contentType,
                ),
              );

          final publicUrl =
              supabase.storage.from('pustaka-assets').getPublicUrl(path);
          uploadedGalleryUrls.add(publicUrl);
        }
      }

      final finalGalleryUrls = [...existingGalleryUrls, ...uploadedGalleryUrls];

      uploadStatusMessage.value = 'Menyimpan data buku...';

      if (editingBookId.value.isEmpty) {
        await addBook(finalGalleryUrls);
      } else {
        await updateBook(finalGalleryUrls);
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

  Future<void> addBook(List<String> galleryUrls) async {
    final newBook = Book(
      id: '',
      title: titleController.text.trim(),
      author: authorController.text.trim(),
      synopsis: synopsisController.text.trim(),
      coverUrl: coverUrlController.text.trim(),
      pdfPreviewUrl: pdfPreviewUrlController.text.trim(),
      mizanstoreUrl: mizanstoreUrlController.text.trim(),
      category: categoryController.text.trim(),
      galleryUrls: galleryUrls,
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

  Future<void> updateBook(List<String> galleryUrls) async {
    final updatedBook = Book(
      id: editingBookId.value,
      title: titleController.text.trim(),
      author: authorController.text.trim(),
      synopsis: synopsisController.text.trim(),
      coverUrl: coverUrlController.text.trim(),
      pdfPreviewUrl: pdfPreviewUrlController.text.trim(),
      mizanstoreUrl: mizanstoreUrlController.text.trim(),
      category: categoryController.text.trim(),
      galleryUrls: galleryUrls,
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
