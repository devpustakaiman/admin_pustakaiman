import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'category_controller.dart';
import '../../core/utils/app_toast.dart';
import '../../data/datasources/supabase_remote_data_source.dart';
import '../../data/models/bank_account_model.dart';

String formatCoverUrl(String rawUrl) {
  final trimmed = rawUrl.trim();
  if (trimmed.isEmpty) return '';
  if (trimmed.startsWith('http://') ||
      trimmed.startsWith('https://') ||
      trimmed.startsWith('data:') ||
      trimmed.startsWith('blob:')) {
    return trimmed;
  }
  if (trimmed.startsWith('/')) {
    return 'https://bswcdqzgjitgpcekviuv.supabase.co$trimmed';
  }
  if (trimmed.startsWith('storage/')) {
    return 'https://bswcdqzgjitgpcekviuv.supabase.co/$trimmed';
  }
  return 'https://bswcdqzgjitgpcekviuv.supabase.co/storage/v1/object/public/pustaka-assets/$trimmed';
}

class FeaturedBookItem {
  final String id;
  final String title;
  final String author;
  final String category;
  final int price;
  final int? discountPrice;
  final String coverUrl;

  FeaturedBookItem({
    required this.id,
    required this.title,
    this.author = '',
    this.category = '',
    required this.price,
    this.discountPrice,
    String coverUrl = '',
  }) : coverUrl = formatCoverUrl(coverUrl);

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

    String cover = '';
    final coverKeys = ['coverUrl', 'cover_url', 'cover_image', 'image_url', 'cover'];
    for (final k in coverKeys) {
      final val = json[k]?.toString().trim();
      if (val != null && val.isNotEmpty && val != 'null') {
        cover = val;
        break;
      }
    }

    final authorStr = json['author'] ?? json['penulis'] ?? '';
    final categoryStr = json['category'] ?? json['category_name'] ?? json['categoryName'] ?? '';

    return FeaturedBookItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      author: authorStr?.toString() ?? '',
      category: categoryStr?.toString() ?? '',
      price: parsedPrice,
      discountPrice: parsedDiscount,
      coverUrl: cover,
    );
  }
}

class SupportingCategorySlot {
  final int slotIndex;
  final RxString category = ''.obs;
  final RxList<FeaturedBookItem?> books = <FeaturedBookItem?>[null, null].obs;

  SupportingCategorySlot({
    required this.slotIndex,
    String initialCategory = '',
    List<FeaturedBookItem?>? initialBooks,
  }) {
    category.value = initialCategory;
    if (initialBooks != null && initialBooks.length >= 2) {
      books.assignAll(initialBooks.sublist(0, 2));
    }
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
  final RxBool manuscriptWhatsappEnabled = true.obs;
  final manuscriptWhatsappNumberController = TextEditingController();
  final manuscriptConfirmationWaController = TextEditingController();
  final manuscriptRedaksiWaController = TextEditingController();
  final RxBool isSavingManuscriptInfo = false.obs;

  // Bank Accounts Settings
  final RxList<BankAccountModel> bankAccounts = <BankAccountModel>[].obs;
  final RxBool isSavingBankAccount = false.obs;

  // Preorder WhatsApp Confirmation Settings
  final RxBool preorderWaEnabled = true.obs;
  final preorderWaNumberController = TextEditingController();
  final RxBool isSavingPreorderWa = false.obs;

  // Catalog Page Settings
  final catalogTitleController = TextEditingController();
  final catalogSubtitleController = TextEditingController();
  final RxBool catalogPromoBannerActive = false.obs;
  final RxString catalogPromoBannerUrl = ''.obs;
  final Rx<PlatformFile?> selectedCatalogPromoFile = Rx<PlatformFile?>(null);
  final catalogPromoBannerLinkController = TextEditingController();
  final RxList<String> catalogFeaturedCategories = <String>[].obs;
  final RxBool isSavingCatalogInfo = false.obs;

  // Footer & Media Sosial Settings
  final footerFacebookController = TextEditingController();
  final footerXController = TextEditingController();
  final footerInstagramController = TextEditingController();
  final footerTiktokController = TextEditingController();
  final footerMizanstoreController = TextEditingController();
  final RxBool isSavingFooterInfo = false.obs;

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

  // Featured Categories Settings (Kustomisasi Kategori Pilihan di Beranda)
  final RxString featuredMainCategory = ''.obs;
  final RxList<FeaturedBookItem?> featuredMainBooks = <FeaturedBookItem?>[null, null, null].obs;
  final RxList<SupportingCategorySlot> featuredSupportingSlots = RxList.generate(
    4,
    (index) => SupportingCategorySlot(slotIndex: index + 2),
  );

  void setMainCategoryBook(int index, FeaturedBookItem? book) {
    if (index >= 0 && index < 3) {
      featuredMainBooks[index] = book;
      featuredMainBooks.refresh();
    }
  }

  void setSupportingCategoryBook(int slotIndex, int bookIndex, FeaturedBookItem? book) {
    if (slotIndex >= 0 && slotIndex < featuredSupportingSlots.length && bookIndex >= 0 && bookIndex < 2) {
      featuredSupportingSlots[slotIndex].books[bookIndex] = book;
      featuredSupportingSlots[slotIndex].books.refresh();
    }
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

  static const String defaultFacebookUrl = 'https://www.facebook.com/penerbit.imania/';
  static const String defaultXUrl = 'https://x.com/penerbitimania';
  static const String defaultInstagramUrl = 'https://www.instagram.com/penerbitimania/';
  static const String defaultTiktokUrl = 'https://www.tiktok.com/@penerbitimania';
  static const String defaultMizanstoreUrl = 'https://www.mizanstore.com/';

  static const List<String> defaultCatalogCategories = [
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

  List<String> get availableCatalogCategories {
    if (Get.isRegistered<CategoryController>()) {
      final catCtrl = Get.find<CategoryController>();
      final _ = catCtrl.categories.length;
      final names = catCtrl.mainCategoryNames;
      if (names.isNotEmpty) return names;
    }
    return defaultCatalogCategories;
  }

  @override
  void onInit() {
    super.onInit();
    headlineController.addListener(() {
      headlineText.value = headlineController.text;
    });
    subheadlineController.addListener(() {
      subheadlineText.value = subheadlineController.text;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadSettings();
    });
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
    manuscriptWhatsappNumberController.dispose();
    manuscriptConfirmationWaController.dispose();
    manuscriptRedaksiWaController.dispose();
    catalogTitleController.dispose();
    catalogSubtitleController.dispose();
    catalogPromoBannerLinkController.dispose();
    preorderWaNumberController.dispose();
    footerFacebookController.dispose();
    footerXController.dispose();
    footerInstagramController.dispose();
    footerTiktokController.dispose();
    footerMizanstoreController.dispose();
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
      // Run settings load, books fetch, bank accounts load, preorder WA, and footer settings load concurrently
      final results = await Future.wait([
        remoteDataSource.getSiteSettings(),
        remoteDataSource.getBooksForDropdown(),
        remoteDataSource.getBankAccounts(),
        remoteDataSource.getPreorderWaSettings(),
        remoteDataSource.getFooterSettings(),
      ]);

      final settings = results[0] as Map<String, dynamic>?;
      final rawBooks = results[1] as List<Map<String, dynamic>>? ?? [];
      final rawBankAccounts = results[2] as List<Map<String, dynamic>>? ?? [];
      final preorderWa = results[3] as Map<String, dynamic>? ?? {};
      final footerSettings = results[4] as Map<String, dynamic>?;

      booksList.value = rawBooks.map((m) => FeaturedBookItem.fromJson(m)).toList();
      bankAccounts.value = rawBankAccounts.map((json) => BankAccountModel.fromJson(json)).toList();
      preorderWaEnabled.value = preorderWa['preorder_wa_enabled'] ?? true;
      preorderWaNumberController.text = preorderWa['preorder_wa_number']?.toString() ?? '';

      // Populate Footer & Media Sosial settings
      final fbUrl = footerSettings?['facebook_url']?.toString() ?? settings?['facebook_url']?.toString();
      final xUrl = footerSettings?['x_url']?.toString() ?? footerSettings?['twitter_url']?.toString() ?? settings?['x_url']?.toString() ?? settings?['twitter_url']?.toString();
      final igUrl = footerSettings?['instagram_url']?.toString() ?? settings?['instagram_url']?.toString();
      final ttUrl = footerSettings?['tiktok_url']?.toString() ?? settings?['tiktok_url']?.toString();
      final msUrl = footerSettings?['mizanstore_url']?.toString() ?? settings?['mizanstore_url']?.toString();

      footerFacebookController.text = (fbUrl != null && fbUrl.isNotEmpty) ? fbUrl : defaultFacebookUrl;
      footerXController.text = (xUrl != null && xUrl.isNotEmpty) ? xUrl : defaultXUrl;
      footerInstagramController.text = (igUrl != null && igUrl.isNotEmpty) ? igUrl : defaultInstagramUrl;
      footerTiktokController.text = (ttUrl != null && ttUrl.isNotEmpty) ? ttUrl : defaultTiktokUrl;
      footerMizanstoreController.text = (msUrl != null && msUrl.isNotEmpty) ? msUrl : defaultMizanstoreUrl;

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
        manuscriptWhatsappEnabled.value = settings['manuscript_whatsapp_enabled'] != false;
        
        final confirmationWaRaw = settings['manuscript_confirmation_wa']?.toString() ??
            settings['manuscript_whatsapp_number']?.toString() ??
            settings['manuscript_whatsapp']?.toString() ??
            settings['whatsapp_naskah']?.toString() ??
            '6281234567890';

        final redaksiWaRaw = settings['manuscript_redaksi_wa']?.toString() ??
            settings['manuscript_whatsapp']?.toString() ??
            settings['whatsapp_naskah']?.toString() ??
            '6281234567890';

        manuscriptConfirmationWaController.text = formatWaNumber(confirmationWaRaw);
        manuscriptRedaksiWaController.text = formatWaNumber(redaksiWaRaw);
        manuscriptWhatsappNumberController.text = manuscriptConfirmationWaController.text;
        manuscriptWhatsappController.text = manuscriptRedaksiWaController.text;

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

        // Load Featured Categories (Kategori Pilihan Beranda)
        // Default 5-slot category names used when data is missing
        const defaultFeaturedCategoryNames = [
          'Agama & Filsafat',      // Slot 1 (main)
          'Fiksi & Novel',          // Slot 2
          'Buku Anak & Komik',      // Slot 3
          'Non Fiksi & Biografi',   // Slot 4
          'Pengembangan Diri',      // Slot 5
        ];

        if (settings['featured_categories'] != null && settings['featured_categories'] is Map) {
          final fcMap = Map<String, dynamic>.from(settings['featured_categories'] as Map);

          final mainData = fcMap['main'];
          if (mainData is Map) {
            featuredMainCategory.value = mainData['category']?.toString() ?? '';
            final mainBooksRaw = mainData['books'];
            if (mainBooksRaw is List) {
              final list = <FeaturedBookItem?>[null, null, null];
              for (int i = 0; i < 3 && i < mainBooksRaw.length; i++) {
                if (mainBooksRaw[i] is Map) {
                  list[i] = FeaturedBookItem.fromJson(Map<String, dynamic>.from(mainBooksRaw[i] as Map));
                }
              }
              featuredMainBooks.assignAll(list);
            }
          }

          final supportingRaw = fcMap['supporting'];
          if (supportingRaw is List) {
            for (int sIndex = 0; sIndex < 4 && sIndex < supportingRaw.length; sIndex++) {
              final item = supportingRaw[sIndex];
              if (item is Map) {
                final cat = item['category']?.toString() ?? '';
                featuredSupportingSlots[sIndex].category.value = cat;
                final booksRaw = item['books'];
                if (booksRaw is List) {
                  final sList = <FeaturedBookItem?>[null, null];
                  for (int bIndex = 0; bIndex < 2 && bIndex < booksRaw.length; bIndex++) {
                    if (booksRaw[bIndex] is Map) {
                      sList[bIndex] = FeaturedBookItem.fromJson(Map<String, dynamic>.from(booksRaw[bIndex] as Map));
                    }
                  }
                  featuredSupportingSlots[sIndex].books.assignAll(sList);
                }
              }
            }
          }
        }

        // Apply default category names to any slot that is still empty
        if (featuredMainCategory.value.isEmpty) {
          featuredMainCategory.value = defaultFeaturedCategoryNames[0];
        }
        for (int i = 0; i < featuredSupportingSlots.length; i++) {
          if (featuredSupportingSlots[i].category.value.isEmpty) {
            featuredSupportingSlots[i].category.value = defaultFeaturedCategoryNames[i + 1];
          }
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

  /// Picks an image file and uploads it to Supabase Storage for featured
  /// category cover slots. Returns the public URL or null if cancelled/failed.
  Future<String?> pickAndUploadFeaturedCoverImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = file.bytes;
        if (bytes != null) {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final ext = file.name.contains('.')
              ? file.name.split('.').last.toLowerCase()
              : 'jpg';
          final safeName = file.name
              .replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_')
              .toLowerCase();
          final path = 'featured-covers/$timestamp-$safeName';
          final mimeType = ext == 'png'
              ? 'image/png'
              : (ext == 'webp' ? 'image/webp' : 'image/jpeg');

          try {
            return await remoteDataSource.uploadStorageFile(
              bucket: 'public_assets',
              path: path,
              bytes: bytes,
              contentType: mimeType,
            );
          } catch (_) {
            return await remoteDataSource.uploadStorageFile(
              bucket: 'pustaka-assets',
              path: path,
              bytes: bytes,
              contentType: mimeType,
            );
          }
        }
      }
      return null;
    } catch (e) {
      errorMessage.value = 'Gagal mengunggah gambar cover: $e';
      return null;
    }
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

      // 2. Upsert to Supabase site_settings table including featured_book_id & featured_categories
      uploadStatusMessage.value = 'Menyimpan konfigurasi situs...';

      // Build featured_categories payload — no validation: null/empty fields are
      // saved as-is so the web frontend falls back to its own defaults automatically.
      final mainCat = featuredMainCategory.value.trim();

      final featuredCategoriesPayload = {
        'main': {
          'category': mainCat,
          'book_ids': featuredMainBooks.where((b) => b != null).map((b) => b!.id).toList(),
          'covers': featuredMainBooks.where((b) => b != null).map((b) => b!.coverUrl).toList(),
          'books': featuredMainBooks.where((b) => b != null).map((b) => {
            'id': b!.id,
            'title': b.title,
            'author': b.author,
            'price': b.price,
            'discount_price': b.discountPrice,
            'cover_url': b.coverUrl,
            'coverUrl': b.coverUrl,
          }).toList(),
        },
        'supporting': featuredSupportingSlots.map((slot) {
          return {
            'slot': slot.slotIndex,
            'category': slot.category.value.trim(),
            'book_ids': slot.books.where((b) => b != null).map((b) => b!.id).toList(),
            'covers': slot.books.where((b) => b != null).map((b) => b!.coverUrl).toList(),
            'books': slot.books.where((b) => b != null).map((b) => {
              'id': b!.id,
              'title': b.title,
              'author': b.author,
              'price': b.price,
              'discount_price': b.discountPrice,
              'cover_url': b.coverUrl,
              'coverUrl': b.coverUrl,
            }).toList(),
          };
        }).toList(),
      };

      final payload = {
        'id': 'default',
        'hero_headline': headlineController.text.trim(),
        'hero_subheadline': subheadlineController.text.trim(),
        'hero_banner_url': currentBannerUrl,
        'featured_book_id': selectedFeaturedBookId.value,
        'featured_categories': featuredCategoriesPayload,
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

  bool isValidUrl(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return true;
    final uri = Uri.tryParse(trimmed);
    return uri != null && uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Future<bool> saveFooterInfo() async {
    final fb = footerFacebookController.text.trim();
    final x = footerXController.text.trim();
    final ig = footerInstagramController.text.trim();
    final tt = footerTiktokController.text.trim();
    final ms = footerMizanstoreController.text.trim();

    if (!isValidUrl(fb)) {
      errorMessage.value = 'URL Facebook tidak valid. Harap sertakan http:// atau https://';
      return false;
    }
    if (!isValidUrl(x)) {
      errorMessage.value = 'URL X (Twitter) tidak valid. Harap sertakan http:// atau https://';
      return false;
    }
    if (!isValidUrl(ig)) {
      errorMessage.value = 'URL Instagram tidak valid. Harap sertakan http:// atau https://';
      return false;
    }
    if (!isValidUrl(tt)) {
      errorMessage.value = 'URL TikTok tidak valid. Harap sertakan http:// atau https://';
      return false;
    }
    if (!isValidUrl(ms)) {
      errorMessage.value = 'URL Mizanstore tidak valid. Harap sertakan http:// atau https://';
      return false;
    }

    isSavingFooterInfo.value = true;
    errorMessage.value = '';

    try {
      final payload = {
        'id': 'default',
        'facebook_url': fb,
        'x_url': x,
        'twitter_url': x,
        'instagram_url': ig,
        'tiktok_url': tt,
        'mizanstore_url': ms,
      };

      await remoteDataSource.updateFooterSettings(payload);
      isSavingFooterInfo.value = false;
      return true;
    } catch (e) {
      isSavingFooterInfo.value = false;
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

      final confirmationWa = formatWaNumber(manuscriptConfirmationWaController.text);
      final redaksiWa = formatWaNumber(manuscriptRedaksiWaController.text);

      manuscriptConfirmationWaController.text = confirmationWa;
      manuscriptRedaksiWaController.text = redaksiWa;
      manuscriptWhatsappNumberController.text = confirmationWa;
      manuscriptWhatsappController.text = redaksiWa;

      final payload = {
        'id': 'default',
        'manuscript_steps': stepsList,
        'manuscript_criteria': criteriaList,
        'manuscript_contact_desc': manuscriptContactDescController.text.trim(),
        'manuscript_whatsapp_enabled': manuscriptWhatsappEnabled.value,
        'manuscript_confirmation_wa': confirmationWa,
        'manuscript_redaksi_wa': redaksiWa,
        'manuscript_whatsapp_number': confirmationWa,
        'manuscript_whatsapp': redaksiWa,
        'whatsapp_naskah': redaksiWa,
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

  String formatWaNumber(String input) {
    String clean = input.replaceAll(RegExp(r'\D'), '');
    if (clean.startsWith('08')) {
      clean = '62${clean.substring(1)}';
    } else if (clean.startsWith('8')) {
      clean = '62$clean';
    }
    return clean;
  }

  Future<bool> savePreorderWaSettings() async {
    final enabled = preorderWaEnabled.value;
    final rawNumber = preorderWaNumberController.text.trim();
    final formattedNumber = formatWaNumber(rawNumber);

    if (enabled) {
      if (formattedNumber.isEmpty || formattedNumber.length < 10) {
        errorMessage.value = 'Nomor WhatsApp admin tidak valid. Masukkan nomor yang benar (misal: 08123456789 atau 628123456789).';
        return false;
      }
    }

    preorderWaNumberController.text = formattedNumber;
    isSavingPreorderWa.value = true;
    errorMessage.value = '';

    try {
      await remoteDataSource.updatePreorderWaSettings(
        enabled: enabled,
        number: formattedNumber,
      );
      isSavingPreorderWa.value = false;
      return true;
    } catch (e) {
      isSavingPreorderWa.value = false;
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


