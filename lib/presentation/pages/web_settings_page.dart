import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_toast.dart';
import '../controllers/web_settings_controller.dart';

class WebSettingsPage extends StatelessWidget {
  const WebSettingsPage({super.key});

  String _formatPrice(num price) {
    if (price <= 0) return 'Gratis';
    final priceInt = price.toInt();
    final buffer = StringBuffer();
    final str = priceInt.toString();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return 'Rp ${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WebSettingsController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Page Header Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pengaturan Web (Landing Page CMS)',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Kustomisasi konten Hero Section publik pada frontend Pustaka Ilman',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: controller.isSaving.value
                        ? null
                        : () async {
                            final success = await controller.saveSettings();
                            if (context.mounted) {
                              if (success) {
                                AppToast.showSuccess(
                                  context,
                                  'Pengaturan Hero Landing Page berhasil disimpan!',
                                );
                              } else {
                                AppToast.showError(
                                  context,
                                  controller.errorMessage.value.isNotEmpty
                                      ? controller.errorMessage.value
                                      : 'Gagal menyimpan pengaturan.',
                                );
                              }
                            }
                          },
                    icon: controller.isSaving.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(LucideIcons.save, size: 16),
                    label: Text(
                      controller.isSaving.value ? 'Menyimpan...' : 'Simpan Perubahan',
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Main Form & Live Preview Grid
              LayoutBuilder(builder: (context, constraints) {
                final isWide = constraints.maxWidth > 850;

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Editors (Headline, Subheadline, Image, Featured Book)
                    Expanded(
                      flex: isWide ? 6 : 10,
                      child: Column(
                        children: [
                          _buildContentEditorCard(context, controller),
                          const SizedBox(height: 20),
                          _buildImageUploaderCard(context, controller),
                          const SizedBox(height: 20),
                          _buildFeaturedBookSelectorCard(context, controller),
                          const SizedBox(height: 20),
                          _buildAboutSettingsCard(context, controller),
                          const SizedBox(height: 20),
                          _buildContactInfoCard(context, controller),
                        ],
                      ),
                    ),

                    if (isWide) ...[
                      const SizedBox(width: 24),
                      // Right Column: Live Landing Page Hero Preview
                      Expanded(
                        flex: 5,
                        child: _buildLivePreviewCard(controller),
                      ),
                    ],
                  ],
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  // 1. Content Editor Card (Headline & Subheadline)
  Widget _buildContentEditorCard(BuildContext context, WebSettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.type,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Teks Hero Banner',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Headline Editor
          const Text(
            'Hero Headline',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller.headlineController,
            decoration: const InputDecoration(
              hintText: 'Misal: Temukan Bacaan Bermakna untuk Jiwa',
              prefixIcon: Icon(LucideIcons.heading1, size: 18, color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Judul utama berukuran besar di bagian paling atas Landing Page.',
            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),

          const SizedBox(height: 20),

          // Subheadline Editor
          const Text(
            'Hero Subheadline / Deskripsi Pendukung',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller.subheadlineController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Tuliskan deskripsi singkat pendukung headline...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Penjelasan ringkas di bawah judul untuk memikat pengunjung membaca koleksi buku.',
            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  // 2. Banner Image Uploader Card
  Widget _buildImageUploaderCard(BuildContext context, WebSettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      LucideIcons.image,
                      color: AppTheme.primaryColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Visual Banner Hero',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: controller.pickBannerImage,
                icon: const Icon(LucideIcons.uploadCloud, size: 16),
                label: const Text('Pilih Berkas Gambar'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // File selected status
          Obx(() {
            final file = controller.selectedBannerFile.value;
            if (file != null) {
              final sizeKb = (file.size / 1024).toStringAsFixed(1);
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.checkCircle2, color: Color(0xFF10B981), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'File baru dipilih: ${file.name} ($sizeKb KB) - Siap diunggah ke bucket public_assets',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0F766E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 16, color: Colors.redAccent),
                      tooltip: 'Batal memilih berkas',
                      onPressed: controller.removeSelectedBanner,
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          }),

          // Current Banner Preview
          Obx(() {
            final file = controller.selectedBannerFile.value;
            final url = controller.bannerUrl.value;

            return Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppTheme.inputFillColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: file != null && file.bytes != null
                    ? Image.memory(
                        file.bytes!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : (url.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            placeholder: (_, __) => const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                            errorWidget: (_, __, ___) => _buildBannerPlaceholder(),
                          )
                        : _buildBannerPlaceholder()),
              ),
            );
          }),

          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(LucideIcons.info, size: 13, color: AppTheme.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Format didukung: JPG, PNG, WEBP. Resolusi rekomendasi: 1200x600 px.',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ),
            ],
          ),

          if (controller.isSaving.value && controller.uploadStatusMessage.value.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.inputFillColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    controller.uploadStatusMessage.value,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 3. Featured Book Selector Card (Hero Floating Badge)
  Widget _buildFeaturedBookSelectorCard(BuildContext context, WebSettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.award,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Buku Pilihan Minggu Ini (Hero Floating Badge)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Disematkan sebagai badge floating promo di samping Hero Section publik',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Selected Book Display or Empty Picker
          Obx(() {
            final selected = controller.selectedFeaturedBook;

            if (selected != null) {
              final hasDiscount = selected.discountPrice != null && selected.discountPrice! > 0;

              return LayoutBuilder(
                builder: (context, cardConstraints) {
                  final isCompact = cardConstraints.maxWidth < 460;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: isCompact
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: selected.coverUrl.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: selected.coverUrl,
                                            width: 48,
                                            height: 68,
                                            fit: BoxFit.cover,
                                            errorWidget: (_, __, ___) => Container(
                                              width: 48,
                                              height: 68,
                                              color: AppTheme.inputFillColor,
                                              child: const Icon(LucideIcons.book, size: 20, color: AppTheme.textMuted),
                                            ),
                                          )
                                        : Container(
                                            width: 48,
                                            height: 68,
                                            color: AppTheme.inputFillColor,
                                            child: const Icon(LucideIcons.book, size: 20, color: AppTheme.textMuted),
                                          ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            '★ AKTIF SEBAGAI FLOATING BADGE',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF10B981),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          selected.title,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            if (hasDiscount) ...[
                                              Text(
                                                _formatPrice(selected.discountPrice!),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF0F766E),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                _formatPrice(selected.price),
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: AppTheme.textMuted,
                                                  decoration: TextDecoration.lineThrough,
                                                ),
                                              ),
                                            ] else ...[
                                              Text(
                                                _formatPrice(selected.price),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.textPrimary,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => controller.setFeaturedBook(null),
                                    icon: const Icon(LucideIcons.trash2, size: 14, color: Colors.redAccent),
                                    label: const Text(
                                      'Hapus Pilihan',
                                      style: TextStyle(fontSize: 11, color: Colors.redAccent),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () => _showBookPickerModal(context, controller),
                                    icon: const Icon(LucideIcons.repeat, size: 14),
                                    label: const Text('Ganti Buku'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      textStyle: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: selected.coverUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: selected.coverUrl,
                                        width: 48,
                                        height: 68,
                                        fit: BoxFit.cover,
                                        errorWidget: (_, __, ___) => Container(
                                          width: 48,
                                          height: 68,
                                          color: AppTheme.inputFillColor,
                                          child: const Icon(LucideIcons.book, size: 20, color: AppTheme.textMuted),
                                        ),
                                      )
                                    : Container(
                                        width: 48,
                                        height: 68,
                                        color: AppTheme.inputFillColor,
                                        child: const Icon(LucideIcons.book, size: 20, color: AppTheme.textMuted),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        '★ AKTIF SEBAGAI FLOATING BADGE',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF10B981),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      selected.title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        if (hasDiscount) ...[
                                          Text(
                                            _formatPrice(selected.discountPrice!),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F766E),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _formatPrice(selected.price),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppTheme.textMuted,
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                        ] else ...[
                                          Text(
                                            _formatPrice(selected.price),
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () => _showBookPickerModal(context, controller),
                                    icon: const Icon(LucideIcons.repeat, size: 14),
                                    label: const Text('Ganti Buku'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      textStyle: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextButton.icon(
                                    onPressed: () => controller.setFeaturedBook(null),
                                    icon: const Icon(LucideIcons.trash2, size: 14, color: Colors.redAccent),
                                    label: const Text(
                                      'Hapus Pilihan',
                                      style: TextStyle(fontSize: 11, color: Colors.redAccent),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  );
                },
              );
            }

            return InkWell(
              onTap: () => _showBookPickerModal(context, controller),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.inputFillColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderColor, style: BorderStyle.solid),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.search, size: 18, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih Buku Pilihan Minggu Ini',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Klik di sini untuk mencari dan memilih dari seluruh katalog buku',
                          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Book Picker Search Dialog
  void _showBookPickerModal(BuildContext context, WebSettingsController controller) {
    final searchCtrl = TextEditingController();
    final RxString searchFilter = ''.obs;

    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        child: Container(
          width: 580,
          height: 600,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modal Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(LucideIcons.bookOpen, color: AppTheme.primaryColor, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Pilih Buku untuk Floating Badge',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18),
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Search Box
              TextField(
                controller: searchCtrl,
                onChanged: (v) => searchFilter.value = v.trim().toLowerCase(),
                decoration: InputDecoration(
                  hintText: 'Cari judul buku...',
                  prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppTheme.textSecondary),
                  suffixIcon: IconButton(
                    icon: const Icon(LucideIcons.x, size: 16),
                    onPressed: () {
                      searchCtrl.clear();
                      searchFilter.value = '';
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Books List
              Expanded(
                child: Obx(() {
                  final query = searchFilter.value;
                  final allBooks = controller.booksList;

                  final filtered = query.isEmpty
                      ? allBooks
                      : allBooks.where((b) => b.title.toLowerCase().contains(query)).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.bookX, size: 36, color: AppTheme.textMuted),
                          const SizedBox(height: 10),
                          Text(
                            query.isEmpty ? 'Belum ada data buku' : 'Tidak ada buku cocok dengan "$query"',
                            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (ctx, i) {
                      final book = filtered[i];
                      final isSelected = controller.selectedFeaturedBookId.value == book.id;
                      final hasDiscount = book.discountPrice != null && book.discountPrice! > 0;

                      return ListTile(
                        onTap: () {
                          controller.setFeaturedBook(book.id);
                          Navigator.of(dialogCtx).pop();
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: book.coverUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: book.coverUrl,
                                  width: 40,
                                  height: 56,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => Container(
                                    width: 40,
                                    height: 56,
                                    color: AppTheme.inputFillColor,
                                    child: const Icon(LucideIcons.book, size: 18, color: AppTheme.textMuted),
                                  ),
                                )
                              : Container(
                                  width: 40,
                                  height: 56,
                                  color: AppTheme.inputFillColor,
                                  child: const Icon(LucideIcons.book, size: 18, color: AppTheme.textMuted),
                                ),
                        ),
                        title: Text(
                          book.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            if (hasDiscount) ...[
                              Text(
                                _formatPrice(book.discountPrice!),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatPrice(book.price),
                                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, decoration: TextDecoration.lineThrough),
                              ),
                            ] else ...[
                              Text(
                                _formatPrice(book.price),
                                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              ),
                            ],
                          ],
                        ),
                        trailing: isSelected
                            ? Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: AppTheme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(LucideIcons.check, size: 14, color: Colors.white),
                              )
                            : null,
                      );
                    },
                  );
                }),
              ),
              const SizedBox(height: 12),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      controller.setFeaturedBook(null);
                      Navigator.of(dialogCtx).pop();
                    },
                    icon: const Icon(LucideIcons.xCircle, size: 16, color: Colors.redAccent),
                    label: const Text('Hapus Pilihan (Kosongkan)', style: TextStyle(color: Colors.redAccent)),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.of(dialogCtx).pop(),
                    child: const Text('Batal'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: AppTheme.softShadow,
            ),
            child: const Icon(LucideIcons.image, size: 28, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 10),
          const Text(
            'Belum ada banner hero yang aktif',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 2),
          Text(
            'Klik tombol "Pilih Berkas Gambar" di atas untuk mengunggah banner baru',
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  // 4. Live Preview Card (Mock Browser Hero Section)
  Widget _buildLivePreviewCard(WebSettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.layoutTemplate,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Simulasi Tampilan Hero Publik',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Mini browser frame
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Window Header Bar with 3 Mac Dots & URL Input Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(13),
                      topRight: Radius.circular(13),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(width: 9, height: 9, decoration: const BoxDecoration(color: Color(0xFFFF5F56), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Container(width: 9, height: 9, decoration: const BoxDecoration(color: Color(0xFFFFBD2E), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Container(width: 9, height: 9, decoration: const BoxDecoration(color: Color(0xFF27C93F), shape: BoxShape.circle)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF334155),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(LucideIcons.lock, size: 10, color: Color(0xFF94A3B8)),
                              SizedBox(width: 6),
                              Text(
                                'pustakaiman.com',
                                style: TextStyle(
                                  color: Color(0xFFE2E8F0),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Pure White Content Canvas
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(13),
                      bottomRight: Radius.circular(13),
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, canvasConstraints) {
                      final isCompact = canvasConstraints.maxWidth < 420;

                      final leftColumn = Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Red Pill Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.star, size: 11, color: Color(0xFFDC2626)),
                                SizedBox(width: 4),
                                Text(
                                  'PILIHAN UNTUKMU',
                                  style: TextStyle(
                                    color: Color(0xFFDC2626),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Live Headline Text
                          AnimatedBuilder(
                            animation: controller.headlineController,
                            builder: (context, _) {
                              final text = controller.headlineController.text.isNotEmpty
                                  ? controller.headlineController.text
                                  : WebSettingsController.defaultHeadline;
                              return Text(
                                text,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Serif',
                                  color: Color(0xFF1E293B),
                                  height: 1.25,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),

                          // Live Subheadline Text
                          AnimatedBuilder(
                            animation: controller.subheadlineController,
                            builder: (context, _) {
                              final text = controller.subheadlineController.text.isNotEmpty
                                  ? controller.subheadlineController.text
                                  : WebSettingsController.defaultSubheadline;
                              return Text(
                                text,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                  height: 1.4,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                          const SizedBox(height: 14),

                          // Action Buttons
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDC2626),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'JELAJAHI KOLEKSI',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(LucideIcons.arrowRight, color: Colors.white, size: 11),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFDC2626)),
                                ),
                                child: const Text(
                                  'BUKU TERBARU',
                                  style: TextStyle(
                                    color: Color(0xFFDC2626),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );

                      final rightColumn = Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Organic Decorative Background Container & Hero Image
                          Container(
                            width: double.infinity,
                            height: isCompact ? 160 : 180,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFFEE2E2)),
                            ),
                            child: Obx(() {
                              final file = controller.selectedBannerFile.value;
                              final url = controller.bannerUrl.value;

                              if (file != null && file.bytes != null) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.memory(
                                    file.bytes!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                );
                              }

                              if (url.isNotEmpty) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: CachedNetworkImage(
                                    imageUrl: url,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    placeholder: (_, __) => const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFFDC2626),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => _buildMockBookStackIllustration(),
                                  ),
                                );
                              }

                              return _buildMockBookStackIllustration();
                            }),
                          ),

                          // Floating Card at bottom-right
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Obx(() {
                              final featured = controller.selectedFeaturedBook;
                              final title = featured?.title ?? "Al-Hikam Al-'Athaiyyah";
                              final author = (featured != null && featured.author.isNotEmpty)
                                  ? featured.author
                                  : 'Ibnu Athaillah';
                              final priceStr = featured != null
                                  ? _formatPrice(featured.discountPrice ?? featured.price)
                                  : 'Rp170.000';

                              return Container(
                                padding: const EdgeInsets.all(10),
                                constraints: const BoxConstraints(maxWidth: 165),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.12),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Row(
                                      children: [
                                        Icon(LucideIcons.star, size: 10, color: Color(0xFFDC2626)),
                                        SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            'PILIHAN MINGGU INI',
                                            style: TextStyle(
                                              color: Color(0xFFDC2626),
                                              fontSize: 8,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.3,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      author,
                                      style: const TextStyle(
                                        fontSize: 8,
                                        color: Color(0xFF64748B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(LucideIcons.star, size: 10, color: Colors.amber),
                                            SizedBox(width: 2),
                                            Text(
                                              '4.9',
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1E293B),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          priceStr,
                                          style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFFDC2626),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ],
                      );

                      if (isCompact) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            leftColumn,
                            const SizedBox(height: 16),
                            rightColumn,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: leftColumn),
                          const SizedBox(width: 14),
                          Expanded(flex: 5, child: rightColumn),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockBookStackIllustration() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4, offset: const Offset(-2, 2)),
                  ],
                ),
                child: const Center(
                  child: Icon(LucideIcons.bookOpen, size: 14, color: Colors.white),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 36,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 3)),
                  ],
                ),
                child: const Center(
                  child: Icon(LucideIcons.book, size: 16, color: Colors.amber),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 32,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 4, offset: const Offset(2, 2)),
                  ],
                ),
                child: const Center(
                  child: Icon(LucideIcons.bookmark, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Visual Banner Hero',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Contact Info & Services Card
  Widget _buildContactInfoCard(BuildContext context, WebSettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.phoneCall,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Kontak & Layanan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Kelola alamat kantor, nomor kontak telepon, WhatsApp customer care, dan email resmi.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 1. Alamat Redaksi & Kantor
          const Text(
            'Alamat Redaksi & Kantor',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller.contactAddressController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Contoh: Jl. Ahmad Yani No. 123, Jakarta Pusat, DKI Jakarta 10110',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(LucideIcons.mapPin, size: 18, color: Color(0xFF94A3B8)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          const SizedBox(height: 16),

          // 2. Nomor Kontak Telepon
          const Text(
            'Nomor Kontak Telepon',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller.contactPhoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Contoh: (021) 555-1234 atau 0812-3456-7890',
              prefixIcon: const Icon(LucideIcons.phone, size: 18, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          const SizedBox(height: 16),

          // 3. Nomor WhatsApp Customer Care
          const Text(
            'Nomor WhatsApp Customer Care (link wa.me)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller.contactWhatsappController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Contoh: 081234567890 atau 6281234567890',
              prefixIcon: const Icon(LucideIcons.messageSquare, size: 18, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          const SizedBox(height: 16),

          // 4. Email Resmi
          const Text(
            'Email Resmi (bisa input multiline/dipisah koma)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller.contactEmailsController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Contoh: redaksi@pustakaiman.com, cs@pustakaiman.com',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Icon(LucideIcons.mail, size: 18, color: Color(0xFF94A3B8)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          const SizedBox(height: 24),

          // Save Button
          Align(
            alignment: Alignment.centerRight,
            child: Obx(() {
              return ElevatedButton.icon(
                onPressed: controller.isSavingContactInfo.value
                    ? null
                    : () async {
                        final success = await controller.saveContactInfo();
                        if (context.mounted) {
                          if (success) {
                            AppToast.showSuccess(
                              context,
                              'Informasi Kontak & Layanan berhasil disimpan!',
                            );
                          } else {
                            AppToast.showError(
                              context,
                              controller.errorMessage.value.isNotEmpty
                                  ? controller.errorMessage.value
                                  : 'Gagal menyimpan informasi kontak.',
                            );
                          }
                        }
                      },
                icon: controller.isSavingContactInfo.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(LucideIcons.save, size: 16),
                label: Text(
                  controller.isSavingContactInfo.value ? 'Menyimpan...' : 'Simpan Informasi Kontak',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // 5. About Us Page Settings Card
  Widget _buildAboutSettingsCard(BuildContext context, WebSettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.building2,
                  color: AppTheme.primaryColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengaturan Halaman Tentang Kami',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Kelola profil penerbit, visi, misi, serta 4 angka statistik pencapaian.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 1. Judul Utama Profil
          const Text(
            'Judul Utama Profil',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller.aboutHeadlineController,
            decoration: InputDecoration(
              hintText: 'Contoh: Penerbitan Bermakna, Menginspirasi Peradaban',
              prefixIcon: const Icon(LucideIcons.heading, size: 18, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          const SizedBox(height: 16),

          // 2. Deskripsi Singkat Profil
          const Text(
            'Deskripsi Singkat Profil',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller.aboutDescriptionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Tuliskan ringkasan profil penerbit...',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: Icon(LucideIcons.fileText, size: 18, color: Color(0xFF94A3B8)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          const SizedBox(height: 16),

          // 3. Visi & Misi Grid / Rows
          LayoutBuilder(
            builder: (context, constraints) {
              final isWideVision = constraints.maxWidth > 600;

              Widget visionField = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Visi Penerbit',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: controller.aboutVisionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Visi penerbit...',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Icon(LucideIcons.target, size: 18, color: Color(0xFF94A3B8)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              );

              Widget missionField = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Misi Penerbit',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: controller.aboutMissionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Misi penerbit...',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Icon(LucideIcons.listOrdered, size: 18, color: Color(0xFF94A3B8)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              );

              if (isWideVision) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: visionField),
                    const SizedBox(width: 16),
                    Expanded(child: missionField),
                  ],
                );
              }

              return Column(
                children: [
                  visionField,
                  const SizedBox(height: 16),
                  missionField,
                ],
              );
            },
          ),

          const SizedBox(height: 20),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),

          // 4. Editor List 4 Angka Statistik
          Row(
            children: const [
              Icon(LucideIcons.barChart2, size: 16, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text(
                'Angka Statistik Profil (4 Item)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWideStat = constraints.maxWidth > 550;

              Widget buildStatRow(int idx) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                        child: Text(
                          '${idx + 1}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 4,
                        child: TextFormField(
                          controller: controller.statValueControllers[idx],
                          decoration: InputDecoration(
                            hintText: 'Nilai (ex: 500+)',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 6,
                        child: TextFormField(
                          controller: controller.statLabelControllers[idx],
                          decoration: InputDecoration(
                            hintText: 'Label (ex: Judul Buku)',
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (isWideStat) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: buildStatRow(0)),
                        const SizedBox(width: 12),
                        Expanded(child: buildStatRow(1)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: buildStatRow(2)),
                        const SizedBox(width: 12),
                        Expanded(child: buildStatRow(3)),
                      ],
                    ),
                  ],
                );
              }

              return Column(
                children: List.generate(4, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: buildStatRow(i),
                  );
                }),
              );
            },
          ),

          const SizedBox(height: 24),

          // Save Button
          Align(
            alignment: Alignment.centerRight,
            child: Obx(() {
              return ElevatedButton.icon(
                onPressed: controller.isSavingAboutInfo.value
                    ? null
                    : () async {
                        final success = await controller.saveAboutInfo();
                        if (context.mounted) {
                          if (success) {
                            AppToast.showSuccess(
                              context,
                              'Profil Halaman Tentang Kami berhasil disimpan!',
                            );
                          } else {
                            AppToast.showError(
                              context,
                              controller.errorMessage.value.isNotEmpty
                                  ? controller.errorMessage.value
                                  : 'Gagal menyimpan profil tentang kami.',
                            );
                          }
                        }
                      },
                icon: controller.isSavingAboutInfo.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(LucideIcons.save, size: 16),
                label: Text(
                  controller.isSavingAboutInfo.value ? 'Menyimpan...' : 'Simpan Profil Tentang Kami',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}


