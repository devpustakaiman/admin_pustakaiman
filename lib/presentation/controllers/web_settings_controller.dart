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

  final contactAddressController = TextEditingController();
  final contactPhoneController = TextEditingController();
  final contactWhatsappController = TextEditingController();
  final contactEmailsController = TextEditingController();

  // About Us Profile & Stats Controllers
  final aboutHeadlineController = TextEditingController();
  final aboutDescriptionController = TextEditingController();
  final aboutVisionController = TextEditingController();
  final aboutMissionController = TextEditingController();

  final List<TextEditingController> statValueControllers = List.generate(4, (_) => TextEditingController());
  final List<TextEditingController> statLabelControllers = List.generate(4, (_) => TextEditingController());

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
  final RxBool isSavingContactInfo = false.obs;
  final RxBool isSavingAboutInfo = false.obs;
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
    contactAddressController.dispose();
    contactPhoneController.dispose();
    contactWhatsappController.dispose();
    contactEmailsController.dispose();

    aboutHeadlineController.dispose();
    aboutDescriptionController.dispose();
    aboutVisionController.dispose();
    aboutMissionController.dispose();
    for (var c in statValueControllers) {
      c.dispose();
    }
    for (var c in statLabelControllers) {
      c.dispose();
    }
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

      final defaultStats = [
        {'value': '2001', 'label': 'Tahun Berdiri'},
        {'value': '500+', 'label': 'Judul Buku Terbit'},
        {'value': '200+', 'label': 'Penulis Mitra'},
        {'value': '1 Juta+', 'label': 'Pembaca Setia'},
      ];

      if (settings != null) {
        headlineController.text = settings['hero_headline']?.toString() ?? defaultHeadline;
        subheadlineController.text = settings['hero_subheadline']?.toString() ?? defaultSubheadline;
        bannerUrl.value = settings['hero_banner_url']?.toString() ?? '';
        selectedFeaturedBookId.value = settings['featured_book_id']?.toString();

        contactAddressController.text = settings['contact_address']?.toString() ?? '';
        contactPhoneController.text = settings['contact_phone']?.toString() ?? '';
        contactWhatsappController.text = settings['contact_whatsapp']?.toString() ?? '';
        contactEmailsController.text = settings['contact_emails']?.toString() ?? '';

        aboutHeadlineController.text = settings['about_headline']?.toString() ?? 'Penerbitan Bermakna, Menginspirasi Peradaban';
        aboutDescriptionController.text = settings['about_description']?.toString() ??
            'Didirikan sejak tahun 2001, Pustaka Iman hadir sebagai rumah penerbitan profesional yang mendedikasikan diri untuk mencerdaskan kehidupan bangsa melalui literasi berkualitas tinggi, baik karya penulis tanah air maupun karya terjemahan dari Bahasa Arab dan Inggris.';
        aboutVisionController.text = settings['about_vision']?.toString() ??
            'Menjadi pilar utama dalam menghadirkan karya-karya bermutu yang mencerahkan jiwa, memperluas wawasan keislaman dan kebangsaan, serta menginspirasi kemajuan peradaban.';
        aboutMissionController.text = settings['about_mission']?.toString() ??
            '1. Menerbitkan buku-buku islam kontemporer, spiritualitas, dan wawasan kebangsaan berkualitas tinggi.\n2. Mendorong penulis lokal dan menerjemahkan karya-karya masterpieces berbobot.\n3. Menyediakan bacaan yang mempererat ukhuwah dan nilai-nilai kebaikan universal.';

        List<dynamic>? rawStats;
        if (settings['about_stats'] != null && settings['about_stats'] is List) {
          rawStats = settings['about_stats'] as List<dynamic>;
        }

        for (int i = 0; i < 4; i++) {
          Map<String, dynamic>? item;
          if (rawStats != null && i < rawStats.length && rawStats[i] is Map) {
            item = Map<String, dynamic>.from(rawStats[i] as Map);
          }
          final fallback = defaultStats[i];
          statValueControllers[i].text = item?['value']?.toString() ?? fallback['value']!;
          statLabelControllers[i].text = item?['label']?.toString() ?? fallback['label']!;
        }
      } else {
        headlineController.text = defaultHeadline;
        subheadlineController.text = defaultSubheadline;
        bannerUrl.value = '';
        selectedFeaturedBookId.value = null;

        contactAddressController.text = '';
        contactPhoneController.text = '';
        contactWhatsappController.text = '';
        contactEmailsController.text = '';

        aboutHeadlineController.text = 'Penerbitan Bermakna, Menginspirasi Peradaban';
        aboutDescriptionController.text =
            'Didirikan sejak tahun 2001, Pustaka Iman hadir sebagai rumah penerbitan profesional yang mendedikasikan diri untuk mencerdaskan kehidupan bangsa melalui literasi berkualitas tinggi.';
        aboutVisionController.text = 'Menjadi pilar utama dalam menghadirkan karya-karya bermutu yang mencerahkan jiwa.';
        aboutMissionController.text = '1. Menerbitkan buku berkualitas tinggi.\n2. Mendorong penulis lokal.';

        for (int i = 0; i < 4; i++) {
          final fallback = defaultStats[i];
          statValueControllers[i].text = fallback['value']!;
          statLabelControllers[i].text = fallback['label']!;
        }
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

  Future<bool> saveContactInfo() async {
    isSavingContactInfo.value = true;
    errorMessage.value = '';

    try {
      final payload = {
        'id': 'default',
        'contact_address': contactAddressController.text.trim(),
        'contact_phone': contactPhoneController.text.trim(),
        'contact_whatsapp': contactWhatsappController.text.trim(),
        'contact_emails': contactEmailsController.text.trim(),
      };

      await remoteDataSource.updateSiteSettings(payload);
      isSavingContactInfo.value = false;
      return true;
    } catch (e) {
      isSavingContactInfo.value = false;
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<bool> saveAboutInfo() async {
    isSavingAboutInfo.value = true;
    errorMessage.value = '';

    try {
      final List<Map<String, String>> statsList = [];
      for (int i = 0; i < 4; i++) {
        statsList.add({
          'value': statValueControllers[i].text.trim(),
          'label': statLabelControllers[i].text.trim(),
        });
      }

      final payload = {
        'id': 'default',
        'about_headline': aboutHeadlineController.text.trim(),
        'about_description': aboutDescriptionController.text.trim(),
        'about_vision': aboutVisionController.text.trim(),
        'about_mission': aboutMissionController.text.trim(),
        'about_stats': statsList,
      };

      await remoteDataSource.updateSiteSettings(payload);
      isSavingAboutInfo.value = false;
      return true;
    } catch (e) {
      isSavingAboutInfo.value = false;
      errorMessage.value = e.toString();
      return false;
    }
  }
}


