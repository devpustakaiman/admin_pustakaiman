import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/datasources/supabase_remote_data_source.dart';

class FeaturedBookItem {
  final String id;
  final String title;
  final String author;
  final int price;
  final int? discountPrice;
  final String coverUrl;

  const FeaturedBookItem({
    required this.id,
    required this.title,
    this.author = '',
    required this.price,
    this.discountPrice,
    this.coverUrl = '',
  });

  factory FeaturedBookItem.fromJson(Map<String, dynamic> json) {
    int parsedPrice = 0;
    final rawPrice = json['price'];
    if (rawPrice is num) {
      parsedPrice = rawPrice.toInt();
    } else if (rawPrice is String) {
      parsedPrice = int.tryParse(rawPrice) ?? 0;
    }

    int? parsedDiscount;
    final rawDiscount = json['discount_price'] ?? json['promo_price'] ?? json['promoPrice'];
    if (rawDiscount is num) {
      parsedDiscount = rawDiscount.toInt();
    } else if (rawDiscount is String) {
      parsedDiscount = int.tryParse(rawDiscount);
    }

    final cover = json['cover_url'] ?? json['coverUrl'] ?? '';
    final authorStr = json['author'] ?? json['penulis'] ?? '';

    return FeaturedBookItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      author: authorStr?.toString() ?? '',
      price: parsedPrice,
      discountPrice: parsedDiscount,
      coverUrl: cover?.toString() ?? '',
    );
  }
}

class WebSettingsController extends GetxController {
  final SupabaseRemoteDataSource remoteDataSource;

  WebSettingsController({SupabaseRemoteDataSource? dataSource})
      : remoteDataSource = dataSource ?? Get.find<SupabaseRemoteDataSource>();

  final headlineController = TextEditingController();
  final subheadlineController = TextEditingController();

  final RxString bannerUrl = ''.obs;
  final Rx<PlatformFile?> selectedBannerFile = Rx<PlatformFile?>(null);

  // Books List for Dropdown & Featured Book
  final RxList<FeaturedBookItem> booksList = <FeaturedBookItem>[].obs;
  final RxnString selectedFeaturedBookId = RxnString();
  final RxBool isLoadingBooks = false.obs;

  FeaturedBookItem? get selectedFeaturedBook {
    if (selectedFeaturedBookId.value == null) return null;
    return booksList.firstWhereOrNull((b) => b.id == selectedFeaturedBookId.value);
  }

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxString uploadStatusMessage = ''.obs;
  final RxString errorMessage = ''.obs;

  static const String defaultHeadline = 'Temukan Bacaan Bermakna untuk Jiwa';
  static const String defaultSubheadline =
      'Jelajahi karya-karya terbaik dari penulis terkemuka Indonesia untuk memperkaya wawasan, ketenangan batin, dan spiritualitas Anda.';

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  @override
  void onClose() {
    headlineController.dispose();
    subheadlineController.dispose();
    super.onClose();
  }

  Future<void> fetchBooksForDropdown() async {
    isLoadingBooks.value = true;
    try {
      final rawList = await remoteDataSource.getBooksForDropdown();
      booksList.value = rawList.map((m) => FeaturedBookItem.fromJson(m)).toList();
    } catch (_) {
      booksList.clear();
    } finally {
      isLoadingBooks.value = false;
    }
  }

  Future<void> loadSettings() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Run settings load and books fetch concurrently
      final results = await Future.wait([
        remoteDataSource.getSiteSettings(),
        remoteDataSource.getBooksForDropdown(),
      ]);

      final settings = results[0] as Map<String, dynamic>?;
      final rawBooks = results[1] as List<Map<String, dynamic>>? ?? [];

      booksList.value = rawBooks.map((m) => FeaturedBookItem.fromJson(m)).toList();

      if (settings != null) {
        headlineController.text = settings['hero_headline']?.toString() ?? defaultHeadline;
        subheadlineController.text = settings['hero_subheadline']?.toString() ?? defaultSubheadline;
        bannerUrl.value = settings['hero_banner_url']?.toString() ?? '';
        selectedFeaturedBookId.value = settings['featured_book_id']?.toString();
      } else {
        headlineController.text = defaultHeadline;
        subheadlineController.text = defaultSubheadline;
        bannerUrl.value = '';
        selectedFeaturedBookId.value = null;
      }
    } catch (e) {
      headlineController.text = defaultHeadline;
      subheadlineController.text = defaultSubheadline;
    } finally {
      isLoading.value = false;
    }
  }

  void setFeaturedBook(String? bookId) {
    selectedFeaturedBookId.value = bookId;
  }

  Future<void> pickBannerImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        selectedBannerFile.value = result.files.first;
      }
    } catch (e) {
      errorMessage.value = 'Gagal memilih berkas gambar: $e';
    }
  }

  void removeSelectedBanner() {
    selectedBannerFile.value = null;
  }

  Future<bool> saveSettings() async {
    if (headlineController.text.trim().isEmpty) {
      errorMessage.value = 'Headline utama tidak boleh kosong';
      return false;
    }

    isSaving.value = true;
    uploadStatusMessage.value = 'Menyiapkan data...';
    errorMessage.value = '';

    try {
      String currentBannerUrl = bannerUrl.value;

      // 1. Upload new banner if selected
      if (selectedBannerFile.value != null) {
        uploadStatusMessage.value = 'Mengunggah banner ke public_assets...';
        final file = selectedBannerFile.value!;

        Uint8List? bytes = file.bytes;
        if (bytes == null && file.path != null) {
          bytes = await File(file.path!).readAsBytes();
        }

        if (bytes != null) {
          final uploadedUrl = await remoteDataSource.uploadSiteBanner(
            bytes,
            file.name,
          );
          currentBannerUrl = uploadedUrl;
          bannerUrl.value = uploadedUrl;
          selectedBannerFile.value = null;
        }
      }

      // 2. Upsert to Supabase site_settings table including featured_book_id
      uploadStatusMessage.value = 'Menyimpan konfigurasi situs...';
      final payload = {
        'id': 'default',
        'hero_headline': headlineController.text.trim(),
        'hero_subheadline': subheadlineController.text.trim(),
        'hero_banner_url': currentBannerUrl,
        'featured_book_id': selectedFeaturedBookId.value,
      };

      await remoteDataSource.updateSiteSettings(payload);

      isSaving.value = false;
      uploadStatusMessage.value = '';
      return true;
    } catch (e) {
      isSaving.value = false;
      uploadStatusMessage.value = '';
      errorMessage.value = e.toString();
      return false;
    }
  }
}
