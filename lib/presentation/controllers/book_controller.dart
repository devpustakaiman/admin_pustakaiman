import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/book.dart';
import '../../domain/usecases/add_book_usecase.dart';
import '../../domain/usecases/delete_book_usecase.dart';
import '../../domain/usecases/get_books_usecase.dart';
import '../../domain/usecases/update_book_usecase.dart';
import '../widgets/book_form_dialog.dart';

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
  final RxString searchQuery = ''.obs;
  final RxString selectedCategoryFilter = 'Semua Kategori'.obs;
  final Rxn<bool> recommendedFilter = Rxn<bool>(); // null: Semua, true: Ya, false: Tidak
  final Rxn<bool> promoFilter = Rxn<bool>(); // null: Semua, true: Ya, false: Tidak
  final RxString sortBy = 'title'.obs; // 'title', 'author', 'price', 'category', 'date'
  final RxBool isAscending = true.obs;

  List<Book> get filteredBooks {
    List<Book> result = List.from(books);

    // 1. Text Search Filter
    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.toLowerCase().trim();
      result = result.where((book) {
        final titleMatch = book.title.toLowerCase().contains(query);
        final authorMatch = book.author.toLowerCase().contains(query);
        final categoryMatch = book.category.toLowerCase().contains(query);
        return titleMatch || authorMatch || categoryMatch;
      }).toList();
    }

    // 2. Category Filter Dropdown
    if (selectedCategoryFilter.value != 'Semua Kategori') {
      final selectedCat = selectedCategoryFilter.value;
      if (selectedCat.endsWith(' (Semua)')) {
        final mainGroup = selectedCat.replaceAll(' (Semua)', '').trim().toLowerCase();
        result = result
            .where((book) => book.category.toLowerCase().startsWith(mainGroup))
            .toList();
      } else {
        result = result
            .where((book) => book.category.toLowerCase() == selectedCat.toLowerCase())
            .toList();
      }
    }

    // 3. Recommended Filter (Tri-State)
    if (recommendedFilter.value != null) {
      result = result
          .where((book) => book.isRecommended == recommendedFilter.value)
          .toList();
    }

    // 4. Promo Filter (Tri-State)
    if (promoFilter.value != null) {
      result = result
          .where((book) => book.isPromo == promoFilter.value)
          .toList();
    }

    // 5. Sorting (Judul, Penulis, Harga, Kategori, Tanggal)
    result.sort((a, b) {
      int comparison = 0;
      switch (sortBy.value) {
        case 'date':
          comparison = a.id.compareTo(b.id);
          break;
        case 'author':
          comparison = a.author.toLowerCase().compareTo(b.author.toLowerCase());
          break;
        case 'price':
          final priceA = a.isPromo && a.promoPrice != null ? a.promoPrice! : a.price;
          final priceB = b.isPromo && b.promoPrice != null ? b.promoPrice! : b.price;
          comparison = priceA.compareTo(priceB);
          break;
        case 'category':
          comparison = a.category.toLowerCase().compareTo(b.category.toLowerCase());
          break;
        case 'title':
        default:
          comparison = a.title.toLowerCase().compareTo(b.title.toLowerCase());
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
  final priceController = TextEditingController();
  final promoPriceController = TextEditingController();
  final promoPercentageController = TextEditingController();
  final RxBool isRecommended = false.obs;
  final RxBool isPromo = false.obs;

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
    priceController.dispose();
    promoPriceController.dispose();
    promoPercentageController.dispose();
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
    priceController.clear();
    promoPriceController.clear();
    promoPercentageController.clear();
    isRecommended.value = false;
    isPromo.value = false;
    selectedCoverFile.value = null;
    selectedPdfFile.value = null;
    existingGalleryUrls.clear();
    selectedGalleryFiles.clear();
    uploadStatusMessage.value = '';
    isUploading.value = false;
  }

  void onPromoPercentageChanged(String val) {
    if (val.trim().isEmpty) {
      promoPriceController.clear();
      return;
    }
    final percentage = int.tryParse(val.trim());
    final mainPrice = int.tryParse(priceController.text.trim()) ?? 0;
    if (mainPrice > 0 && percentage != null) {
      final p = percentage.clamp(0, 100);
      final calculatedPrice = (mainPrice * (100 - p) / 100).round();
      promoPriceController.text = calculatedPrice.toString();
    }
  }

  void onPromoPriceChanged(String val) {
    if (val.trim().isEmpty) {
      promoPercentageController.clear();
      return;
    }
    final promoPrice = int.tryParse(val.trim());
    final mainPrice = int.tryParse(priceController.text.trim()) ?? 0;
    if (mainPrice > 0 && promoPrice != null) {
      final percentage = (((mainPrice - promoPrice) / mainPrice) * 100).round();
      promoPercentageController.text = percentage.clamp(0, 100).toString();
    }
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
      priceController.text = book.price > 0 ? book.price.toString() : '';
      isRecommended.value = book.isRecommended;
      isPromo.value = book.isPromo;
      promoPriceController.text = book.promoPrice != null ? book.promoPrice.toString() : '';
      promoPercentageController.text = book.promoPercentage != null ? book.promoPercentage.toString() : '';
      selectedCoverFile.value = null;
      selectedPdfFile.value = null;
      existingGalleryUrls.assignAll(book.galleryUrls);
      selectedGalleryFiles.clear();
    } else {
      editingBookId.value = '';
      clearForm();
    }

    Get.dialog(
      BookFormDialog(controller: this),
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
    final priceInt = int.tryParse(priceController.text.trim()) ?? 0;
    final promoPriceInt = isPromo.value ? int.tryParse(promoPriceController.text.trim()) : null;
    final promoPercentInt = isPromo.value ? int.tryParse(promoPercentageController.text.trim()) : null;

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
      price: priceInt,
      isPromo: isPromo.value,
      promoPrice: promoPriceInt,
      promoPercentage: promoPercentInt,
      isRecommended: isRecommended.value,
      updatedAt: DateTime.now(),
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
    final priceInt = int.tryParse(priceController.text.trim()) ?? 0;
    final promoPriceInt = isPromo.value ? int.tryParse(promoPriceController.text.trim()) : null;
    final promoPercentInt = isPromo.value ? int.tryParse(promoPercentageController.text.trim()) : null;

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
      price: priceInt,
      isPromo: isPromo.value,
      promoPrice: promoPriceInt,
      promoPercentage: promoPercentInt,
      isRecommended: isRecommended.value,
      updatedAt: DateTime.now(),
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
