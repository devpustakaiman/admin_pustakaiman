import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/app_toast.dart';
import '../../data/datasources/supabase_remote_data_source.dart';
import '../../data/models/bank_account_model.dart';

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

class ManuscriptStepItem {
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  ManuscriptStepItem({String title = '', String description = ''})
      : titleController = TextEditingController(text: title),
        descriptionController = TextEditingController(text: description);

  factory ManuscriptStepItem.fromJson(Map<String, dynamic> json) {
    return ManuscriptStepItem(
      title: json['title']?.toString() ?? json['judul']?.toString() ?? '',
      description: json['description']?.toString() ?? json['deskripsi']?.toString() ?? '',
    );
  }

  Map<String, String> toJson() => {
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
      };

  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
  }
}

class WebSettingsController extends GetxController {
  final SupabaseRemoteDataSource remoteDataSource;

  WebSettingsController({SupabaseRemoteDataSource? dataSource})
      : remoteDataSource = dataSource ?? Get.find<SupabaseRemoteDataSource>();

  final headlineController = TextEditingController();
  final subheadlineController = TextEditingController();
  final RxString headlineText = ''.obs;
  final RxString subheadlineText = ''.obs;

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

  // Manuscript Settings
  final RxList<ManuscriptStepItem> manuscriptSteps = <ManuscriptStepItem>[].obs;
  final RxList<TextEditingController> manuscriptCriteriaControllers = <TextEditingController>[].obs;
  final manuscriptContactDescController = TextEditingController();
  final manuscriptWhatsappController = TextEditingController();
  final RxBool isSavingManuscriptInfo = false.obs;

  // Bank Accounts Settings
  final RxList<BankAccountModel> bankAccounts = <BankAccountModel>[].obs;
  final RxBool isSavingBankAccount = false.obs;

  // Preorder Notification Email Settings
  final preorderEmailController = TextEditingController();
  final RxBool isSavingPreorderEmail = false.obs;

  // Catalog Page Settings
  final catalogTitleController = TextEditingController();
  final catalogSubtitleController = TextEditingController();
  final RxBool catalogPromoBannerActive = false.obs;
  final RxString catalogPromoBannerUrl = ''.obs;
  final Rx<PlatformFile?> selectedCatalogPromoFile = Rx<PlatformFile?>(null);
  final catalogPromoBannerLinkController = TextEditingController();
  final RxList<String> catalogFeaturedCategories = <String>[].obs;
  final RxBool isSavingCatalogInfo = false.obs;

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

  static const String defaultCatalogTitle = 'Katalog Buku Pustaka Iman';
  static const String defaultCatalogSubtitle =
      'Jelajahi koleksi buku Islam kontemporer, spiritualitas, wawasan kebangsaan, dan novel bermakna karya penulis terkemuka.';

  static const List<String> catalogCategoryOptions = [
    'Agama & Filsafat',
    'Al-Quran',
    'Bisnis & Ekonomi',
    'Buku Anak',
    'Diet & Health',
    'Fiksi',
    'Filsafat, Sejarah, Sastra Dan Budaya',
    'Lain-Lain',
    'Learning',
    'Mainan Edukatif',
    'Non Fiksi',
    'Parenting & Child Development',
    'Pengembangan Diri & Karier',
    'Psikologi',
    'Reference & Dictionary',
    'Schoolbook',
    'Social Science',
  ];

  static const List<String> availableCatalogCategories = catalogCategoryOptions;

  @override
  void onInit() {
    super.onInit();
    headlineController.addListener(() {
      headlineText.value = headlineController.text;
    });
    subheadlineController.addListener(() {
      subheadlineText.value = subheadlineController.text;
    });
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
    for (var step in manuscriptSteps) {
      step.dispose();
    }
    for (var criterionController in manuscriptCriteriaControllers) {
      criterionController.dispose();
    }
    manuscriptContactDescController.dispose();
    manuscriptWhatsappController.dispose();
    catalogTitleController.dispose();
    catalogSubtitleController.dispose();
    catalogPromoBannerLinkController.dispose();
    super.onClose();
  }

  void addManuscriptStep({String title = '', String description = ''}) {
    manuscriptSteps.add(ManuscriptStepItem(title: title, description: description));
  }

  void removeManuscriptStep(int index) {
    if (index >= 0 && index < manuscriptSteps.length) {
      final removed = manuscriptSteps.removeAt(index);
      removed.dispose();
    }
  }

  void addManuscriptCriterion({String text = ''}) {
    manuscriptCriteriaControllers.add(TextEditingController(text: text));
  }

  void removeManuscriptCriterion(int index) {
    if (index >= 0 && index < manuscriptCriteriaControllers.length) {
      final removed = manuscriptCriteriaControllers.removeAt(index);
      removed.dispose();
    }
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
      // Run settings load, books fetch, bank accounts load, and preorder email load concurrently
      final results = await Future.wait([
        remoteDataSource.getSiteSettings(),
        remoteDataSource.getBooksForDropdown(),
        remoteDataSource.getBankAccounts(),
        remoteDataSource.getPreorderNotificationEmail(),
      ]);

      final settings = results[0] as Map<String, dynamic>?;
      final rawBooks = results[1] as List<Map<String, dynamic>>? ?? [];
      final rawBankAccounts = results[2] as List<Map<String, dynamic>>? ?? [];
      final preorderEmail = results[3] as String? ?? 'admin@pustakaiman.com';

      booksList.value = rawBooks.map((m) => FeaturedBookItem.fromJson(m)).toList();
      bankAccounts.value = rawBankAccounts.map((json) => BankAccountModel.fromJson(json)).toList();
      preorderEmailController.text = preorderEmail;

      final defaultStats = [
        {'value': '2001', 'label': 'Tahun Berdiri'},
        {'value': '500+', 'label': 'Judul Buku Terbit'},
        {'value': '200+', 'label': 'Penulis Mitra'},
        {'value': '1 Juta+', 'label': 'Pembaca Setia'},
      ];

      if (settings != null) {
        headlineController.text = settings['hero_headline']?.toString() ?? defaultHeadline;
        subheadlineController.text = settings['hero_subheadline']?.toString() ?? defaultSubheadline;
        headlineText.value = headlineController.text;
        subheadlineText.value = subheadlineController.text;
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

        // Manuscript settings load
        for (var step in manuscriptSteps) {
          step.dispose();
        }
        manuscriptSteps.clear();
        for (var c in manuscriptCriteriaControllers) {
          c.dispose();
        }
        manuscriptCriteriaControllers.clear();

        if (settings['manuscript_steps'] != null && settings['manuscript_steps'] is List) {
          final rawSteps = settings['manuscript_steps'] as List;
          for (var item in rawSteps) {
            if (item is Map) {
              manuscriptSteps.add(ManuscriptStepItem.fromJson(Map<String, dynamic>.from(item)));
            }
          }
        }
        if (manuscriptSteps.isEmpty) {
          manuscriptSteps.addAll([
            ManuscriptStepItem(
              title: 'Kirim Berkas & Sinopsis',
              description: 'Kirimkan berkas naskah dalam format PDF/DOCX beserta sinopsis lengkap melalui formulir online.',
            ),
            ManuscriptStepItem(
              title: 'Kurasi & Evaluasi Redaksi',
              description: 'Tim kurator dan redaksi kami akan melakukan evaluasi substansi serta orisinalitas naskah (14–30 hari kerja).',
            ),
            ManuscriptStepItem(
              title: 'Pemberitahuan Kelayakan',
              description: 'Hasil evaluasi dan kelayakan terbit akan disampaikan langsung via email atau WhatsApp resmi redaksi.',
            ),
          ]);
        }

        if (settings['manuscript_criteria'] != null && settings['manuscript_criteria'] is List) {
          final rawCriteria = settings['manuscript_criteria'] as List;
          for (var item in rawCriteria) {
            if (item != null && item.toString().trim().isNotEmpty) {
              manuscriptCriteriaControllers.add(TextEditingController(text: item.toString().trim()));
            }
          }
        }
        if (manuscriptCriteriaControllers.isEmpty) {
          manuscriptCriteriaControllers.addAll([
            TextEditingController(text: 'Naskah orisinal (bukan plagiasi)'),
            TextEditingController(text: 'Format rapi (A4, 1.5 spasi, Font standar)'),
            TextEditingController(text: 'Menyertakan daftar isi dan bab pembuka'),
          ]);
        }

        manuscriptContactDescController.text = settings['manuscript_contact_desc']?.toString() ??
            'Punya pertanyaan seputar penerbitan, kerja sama, atau butuh panduan khusus naskah? Tim redaksi Pustaka Iman siap membantu Anda.';
        manuscriptWhatsappController.text = settings['manuscript_whatsapp']?.toString() ?? '6281234567890';

        // Catalog settings load
        catalogTitleController.text = settings['catalog_title']?.toString() ?? defaultCatalogTitle;
        catalogSubtitleController.text = settings['catalog_subtitle']?.toString() ?? defaultCatalogSubtitle;
        catalogPromoBannerActive.value = settings['catalog_promo_banner_active'] == true;
        catalogPromoBannerUrl.value = settings['catalog_promo_banner_url']?.toString() ?? '';
        catalogPromoBannerLinkController.text = settings['catalog_promo_banner_link']?.toString() ?? '';

        if (settings['catalog_featured_categories'] != null && settings['catalog_featured_categories'] is List) {
          final list = (settings['catalog_featured_categories'] as List).map((e) => e.toString()).toList();
          catalogFeaturedCategories.assignAll(list);
        } else {
          catalogFeaturedCategories.assignAll([
            'Agama & Filsafat',
            'Fiksi',
            'Pengembangan Diri & Karier',
            'Parenting & Child Development',
          ]);
        }
      } else {
        headlineController.text = defaultHeadline;
        subheadlineController.text = defaultSubheadline;
        headlineText.value = headlineController.text;
        subheadlineText.value = subheadlineController.text;
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

        for (var step in manuscriptSteps) {
          step.dispose();
        }
        manuscriptSteps.clear();
        manuscriptSteps.addAll([
          ManuscriptStepItem(
            title: 'Kirim Berkas & Sinopsis',
            description: 'Kirimkan berkas naskah dalam format PDF/DOCX beserta sinopsis lengkap melalui formulir online.',
          ),
          ManuscriptStepItem(
            title: 'Kurasi & Evaluasi Redaksi',
            description: 'Tim kurator dan redaksi kami akan melakukan evaluasi substansi serta orisinalitas naskah (14–30 hari kerja).',
          ),
          ManuscriptStepItem(
            title: 'Pemberitahuan Kelayakan',
            description: 'Hasil evaluasi dan kelayakan terbit akan disampaikan langsung via email atau WhatsApp resmi redaksi.',
          ),
        ]);

        for (var c in manuscriptCriteriaControllers) {
          c.dispose();
        }
        manuscriptCriteriaControllers.clear();
        manuscriptCriteriaControllers.addAll([
          TextEditingController(text: 'Naskah orisinal (bukan plagiasi)'),
          TextEditingController(text: 'Format rapi (A4, 1.5 spasi, Font standar)'),
          TextEditingController(text: 'Menyertakan daftar isi dan bab pembuka'),
        ]);

        manuscriptContactDescController.text =
            'Punya pertanyaan seputar penerbitan, kerja sama, atau butuh panduan khusus naskah? Tim redaksi Pustaka Iman siap membantu Anda.';
        manuscriptWhatsappController.text = '6281234567890';

        catalogTitleController.text = defaultCatalogTitle;
        catalogSubtitleController.text = defaultCatalogSubtitle;
        catalogPromoBannerActive.value = false;
        catalogPromoBannerUrl.value = '';
        catalogPromoBannerLinkController.text = '';
        catalogFeaturedCategories.assignAll([
          'Agama & Filsafat',
          'Fiksi',
          'Pengembangan Diri & Karier',
          'Parenting & Child Development',
        ]);
      }
    } catch (e) {
      headlineController.text = defaultHeadline;
      subheadlineController.text = defaultSubheadline;
      headlineText.value = headlineController.text;
      subheadlineText.value = subheadlineController.text;
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

  Future<bool> saveManuscriptInfo() async {
    isSavingManuscriptInfo.value = true;
    errorMessage.value = '';

    try {
      final stepsList = manuscriptSteps.map((step) => step.toJson()).toList();
      final criteriaList = manuscriptCriteriaControllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      final payload = {
        'id': 'default',
        'manuscript_steps': stepsList,
        'manuscript_criteria': criteriaList,
        'manuscript_contact_desc': manuscriptContactDescController.text.trim(),
        'manuscript_whatsapp': manuscriptWhatsappController.text.trim(),
      };

      await remoteDataSource.updateSiteSettings(payload);
      isSavingManuscriptInfo.value = false;
      return true;
    } catch (e) {
      isSavingManuscriptInfo.value = false;
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<void> saveBankAccount(BankAccountModel account) async {
    isSavingBankAccount.value = true;
    try {
      final updatedList = List<BankAccountModel>.from(bankAccounts);
      final index = updatedList.indexWhere((a) => a.id == account.id);
      if (index >= 0) {
        updatedList[index] = account;
      } else {
        updatedList.add(account);
      }
      final payload = updatedList.map((a) => a.toJson()).toList();
      await remoteDataSource.updateBankAccounts(payload);
      bankAccounts.value = updatedList;
      isSavingBankAccount.value = false;
      if (Get.context != null) {
        AppToast.showSuccess(Get.context!, 'Rekening bank berhasil disimpan');
      }
    } catch (e) {
      isSavingBankAccount.value = false;
      if (Get.context != null) {
        AppToast.showError(Get.context!, 'Gagal menyimpan rekening bank: $e');
      }
    }
  }

  Future<bool> savePreorderEmail() async {
    isSavingPreorderEmail.value = true;
    errorMessage.value = '';

    try {
      await remoteDataSource.updatePreorderNotificationEmail(preorderEmailController.text.trim());
      isSavingPreorderEmail.value = false;
      return true;
    } catch (e) {
      isSavingPreorderEmail.value = false;
      errorMessage.value = e.toString();
      return false;
    }
  }

  Future<void> deleteBankAccount(String accountId) async {
    isSavingBankAccount.value = true;
    try {
      final updatedList = bankAccounts.where((a) => a.id != accountId).toList();
      final payload = updatedList.map((a) => a.toJson()).toList();
      await remoteDataSource.updateBankAccounts(payload);
      bankAccounts.value = updatedList;
      isSavingBankAccount.value = false;
      if (Get.context != null) {
        AppToast.showSuccess(Get.context!, 'Rekening bank berhasil dihapus');
      }
    } catch (e) {
      isSavingBankAccount.value = false;
      if (Get.context != null) {
        AppToast.showError(Get.context!, 'Gagal menghapus rekening bank: $e');
      }
    }
  }

  Future<void> pickCatalogPromoBannerImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        selectedCatalogPromoFile.value = result.files.first;
      }
    } catch (e) {
      errorMessage.value = 'Gagal memilih berkas gambar banner katalog: $e';
    }
  }

  void removeSelectedCatalogPromoBanner() {
    selectedCatalogPromoFile.value = null;
  }

  void toggleFeaturedCategory(String category) {
    if (catalogFeaturedCategories.contains(category)) {
      catalogFeaturedCategories.remove(category);
    } else {
      catalogFeaturedCategories.add(category);
    }
  }

  Future<bool> saveCatalogInfo() async {
    isSavingCatalogInfo.value = true;
    errorMessage.value = '';

    try {
      String currentPromoBannerUrl = catalogPromoBannerUrl.value;

      if (selectedCatalogPromoFile.value != null) {
        final file = selectedCatalogPromoFile.value!;
        Uint8List? bytes = file.bytes;

        if (bytes != null) {
          final uploadedUrl = await remoteDataSource.uploadSiteBanner(
            bytes,
            'catalog_promo_${DateTime.now().millisecondsSinceEpoch}_${file.name}',
          );
          currentPromoBannerUrl = uploadedUrl;
          catalogPromoBannerUrl.value = uploadedUrl;
          selectedCatalogPromoFile.value = null;
        }
      }

      final payload = {
        'id': 'default',
        'catalog_title': catalogTitleController.text.trim(),
        'catalog_subtitle': catalogSubtitleController.text.trim(),
        'catalog_promo_banner_active': catalogPromoBannerActive.value,
        'catalog_promo_banner_url': currentPromoBannerUrl,
        'catalog_promo_banner_link': catalogPromoBannerLinkController.text.trim(),
        'catalog_featured_categories': catalogFeaturedCategories.toList(),
      };

      await remoteDataSource.updateSiteSettings(payload);
      isSavingCatalogInfo.value = false;

      if (Get.context != null) {
        AppToast.showSuccess(Get.context!, 'Pengaturan katalog berhasil disimpan');
      }
      return true;
    } catch (e) {
      isSavingCatalogInfo.value = false;
      errorMessage.value = e.toString();
      if (Get.context != null) {
        AppToast.showError(Get.context!, 'Gagal menyimpan pengaturan katalog: $e');
      }
      return false;
    }
  }
}


