import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
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
  final RxInt currentPage = 0.obs;
  final RxInt totalBooksCount = 0.obs;
  final int pageSize = 15;

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
  final RxString coverUrl = ''.obs;

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
  final Rxn<DateTime> promoEndDate = Rxn<DateTime>();

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
    coverUrl.value = '';
    pdfPreviewUrlController.clear();
    mizanstoreUrlController.clear();
    categoryController.clear();
    priceController.clear();
    promoPriceController.clear();
    promoPercentageController.clear();
    isRecommended.value = false;
    isPromo.value = false;
    promoEndDate.value = null;
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
      errorMessage.value = 'Gagal memilih file gambar: $e';
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
      errorMessage.value = 'Gagal memilih file PDF: $e';
    }
  }

  Future<void> pickGalleryImages() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();
      if (images.isNotEmpty) {
        selectedGalleryFiles.addAll(images);
      }
    } catch (e) {
      errorMessage.value = 'Gagal memilih gambar galeri: $e';
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
    final extension = file.extension ?? (bucket == 'naskah' ? 'pdf' : 'jpg');
    final sanitizedName = file.name
        .replaceAll(RegExp(r'[^a-zA-Z0-9\._-]'), '_')
        .toLowerCase();
    final path = '$timestamp-$sanitizedName';

    final contentType = bucket == 'naskah'
        ? 'application/pdf'
        : 'image/${extension == "png" ? "png" : (extension == "webp" ? "webp" : "jpeg")}';

    final supabase = Supabase.instance.client;
    try {
      await supabase.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: contentType,
            ),
          );
      return supabase.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      if (bucket != 'pustaka-assets') {
        try {
          await supabase.storage.from('pustaka-assets').uploadBinary(
                path,
                bytes,
                fileOptions: FileOptions(
                  upsert: true,
                  contentType: contentType,
                ),
              );
          return supabase.storage.from('pustaka-assets').getPublicUrl(path);
        } catch (_) {}
      }
      rethrow;
    }
  }

  void openFormDialog({Book? book}) {
    if (book != null) {
      editingBookId.value = book.id;
      titleController.text = book.title;
      authorController.text = book.author;
      synopsisController.text = book.synopsis;
      coverUrlController.text = book.coverUrl;
      coverUrl.value = book.coverUrl;
      pdfPreviewUrlController.text = book.pdfPreviewUrl;
      mizanstoreUrlController.text = book.mizanstoreUrl;
      categoryController.text = book.category;
      priceController.text = book.price > 0 ? book.price.toString() : '';
      isRecommended.value = book.isRecommended;
      isPromo.value = book.isPromo;
      promoEndDate.value = book.promoEndDate;
      promoPriceController.text = book.promoPrice != null ? book.promoPrice.toString() : '';
      promoPercentageController.text = book.promoPercentage != null ? book.promoPercentage.toString() : '';
      selectedCoverFile.value = null;
      selectedPdfFile.value = null;
      existingGalleryUrls.assignAll(book.galleryUrls);
      selectedGalleryFiles.clear();

      Get.dialog(
        BookFormDialog(controller: this),
        barrierDismissible: false,
      );

      // On-demand: Fetch full book row (cover_url, synopsis, gallery, preview PDF) if omitted from list query
      Get.find<BookRepository>().getBookById(book.id).then((res) {
        res.fold((_) {}, (full) {
          if (full != null) {
            if (full.coverUrl.isNotEmpty) {
              coverUrlController.text = full.coverUrl;
              coverUrl.value = full.coverUrl;
            }
            if (full.synopsis.isNotEmpty) synopsisController.text = full.synopsis;
            if (full.pdfPreviewUrl.isNotEmpty) pdfPreviewUrlController.text = full.pdfPreviewUrl;
            if (full.mizanstoreUrl.isNotEmpty) mizanstoreUrlController.text = full.mizanstoreUrl;
            if (full.galleryUrls.isNotEmpty) existingGalleryUrls.assignAll(full.galleryUrls);
          }
        });
      });
    } else {
      editingBookId.value = '';
      clearForm();
      Get.dialog(
        BookFormDialog(controller: this),
        barrierDismissible: false,
      );
    }
  }

  Future<void> fetchBooks({int? page}) async {
    if (page != null) currentPage.value = page;
    isLoading.value = true;
    errorMessage.value = '';

    // Server-side exact count
    final countResult = await Get.find<BookRepository>().getBooksCount();
    countResult.fold((_) {}, (cnt) => totalBooksCount.value = cnt);

    // 15-item lazy loading / pagination
    final result = await getBooksUseCase.call(page: currentPage.value, pageSize: pageSize);
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

  void nextPage() {
    if ((currentPage.value + 1) * pageSize < totalBooksCount.value) {
      fetchBooks(page: currentPage.value + 1);
    }
  }

  void prevPage() {
    if (currentPage.value > 0) {
      fetchBooks(page: currentPage.value - 1);
    }
  }

  Future<void> saveBook() async {
    isLoading.value = true;
    isUploading.value = true;
    errorMessage.value = '';

    try {
      // 1. Upload Cover Image if selected
      if (selectedCoverFile.value != null) {
        uploadStatusMessage.value = 'Mengunggah Cover Gambar...';
        final uploadedCoverUrl = await uploadFileToStorage(
          bucket: 'book-covers',
          file: selectedCoverFile.value!,
        );
        if (uploadedCoverUrl != null && uploadedCoverUrl.isNotEmpty) {
          coverUrlController.text = uploadedCoverUrl;
          coverUrl.value = uploadedCoverUrl;
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

          String? galleryUrl;
          try {
            await supabase.storage.from('book-covers').uploadBinary(
                  path,
                  bytes,
                  fileOptions: FileOptions(
                    upsert: true,
                    contentType: contentType,
                  ),
                );
            galleryUrl = supabase.storage.from('book-covers').getPublicUrl(path);
          } catch (_) {
            await supabase.storage.from('pustaka-assets').uploadBinary(
                  path,
                  bytes,
                  fileOptions: FileOptions(
                    upsert: true,
                    contentType: contentType,
                  ),
                );
            galleryUrl = supabase.storage.from('pustaka-assets').getPublicUrl(path);
          }

          if (galleryUrl.isNotEmpty) {
            uploadedGalleryUrls.add(galleryUrl);
          }
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
      errorMessage.value = 'Gagal mengunggah file atau menyimpan buku: $e';
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
      promoEndDate: isPromo.value ? promoEndDate.value : null,
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
      promoEndDate: isPromo.value ? promoEndDate.value : null,
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
