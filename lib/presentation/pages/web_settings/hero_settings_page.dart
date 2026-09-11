import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_toast.dart';
import '../../controllers/web_settings_controller.dart';
import '../../widgets/cms_page_header.dart';

class HeroSettingsPage extends StatelessWidget {
  const HeroSettingsPage({super.key});

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
      body: Obx(() => controller.isLoading.value
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : _buildContent(context, controller)),
    );
  }

  Widget _buildContent(BuildContext context, WebSettingsController controller) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16.0 : 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page Header Title & Primary Action
          CmsPageHeader(
            title: 'Kelola Halaman > Beranda & Hero',
            subtitle: 'Kustomisasi Teks Hero Banner, Visual Banner, Buku Pilihan Minggu Ini, dan Pratinjau Tampilan Hero Publik',
            isSaving: controller.isSaving.value,
            onSave: () async {
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
          ),

          const SizedBox(height: 24),

          // 2x2 Grid Segiempat for Hero Management
          LayoutBuilder(builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 1024;

                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _buildContentEditorCard(context, controller),
                            const SizedBox(height: 24),
                            _buildImageUploaderCard(context, controller),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Right Column
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            _buildLivePreviewCard(controller),
                            const SizedBox(height: 24),
                            _buildFeaturedBookSelectorCard(context, controller),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    _buildContentEditorCard(context, controller),
                    const SizedBox(height: 20),
                    _buildImageUploaderCard(context, controller),
                    const SizedBox(height: 20),
                    _buildFeaturedBookSelectorCard(context, controller),
                    const SizedBox(height: 20),
                    _buildLivePreviewCard(controller),
                  ],
                );
              }),

          const SizedBox(height: 28),

          // Section Card: Kustomisasi Kategori Pilihan di Halaman Beranda
          _buildFeaturedCategoriesCard(context, controller),
        ],
      ),
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
              ElevatedButton.icon(
                onPressed: () => controller.pickBannerImage(),
                icon: const Icon(LucideIcons.uploadCloud, size: 16),
                label: const Text('Pilih Berkas Gambar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Obx(() {
            final selectedFile = controller.selectedBannerFile.value;
            final currentUrl = controller.bannerUrl.value;

            if (selectedFile != null) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.fileImage, color: AppTheme.primaryColor, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedFile.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${(selectedFile.size / 1024).toStringAsFixed(1)} KB (Siap diunggah)',
                            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 18, color: Colors.redAccent),
                      onPressed: () => controller.removeSelectedBanner(),
                      tooltip: 'Batal Pilih',
                    ),
                  ],
                ),
              );
            }

            if (currentUrl.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: currentUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.imageOff, color: Colors.grey, size: 32),
                              SizedBox(height: 8),
                              Text(
                                'Gagal memuat gambar banner',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'URL Banner Aktif: $currentUrl',
                    style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            }

            return _buildBannerPlaceholder();
          }),
        ],
      ),
    );
  }

  // 3. Featured Book Selector Card
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
                  LucideIcons.star,
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
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Pilih buku utama yang ditampilkan secara eksklusif pada kartu Hero Banner',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Obx(() {
            if (controller.isLoadingBooks.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor),
                  ),
                ),
              );
            }

            final selectedBook = controller.selectedFeaturedBook;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedFeaturedBookId.value,
                      hint: const Text(
                        'Pilih Buku Pilihan (Opsional)...',
                        style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      ),
                      isExpanded: true,
                      icon: const Icon(LucideIcons.chevronDown, size: 18, color: Color(0xFF64748B)),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text(
                            '-- Tanpa Buku Pilihan --',
                            style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontStyle: FontStyle.italic),
                          ),
                        ),
                        ...controller.booksList.map((book) {
                          return DropdownMenuItem<String>(
                            value: book.id,
                            child: Row(
                              children: [
                                const Icon(LucideIcons.book, size: 16, color: AppTheme.primaryColor),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    '${book.title} ${book.author.isNotEmpty ? '• ${book.author}' : ''}',
                                    style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                      onChanged: (val) => controller.setFeaturedBook(val),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showBookPickerModal(context, controller),
                      icon: const Icon(LucideIcons.search, size: 15),
                      label: const Text('Cari & Pilih dari Katalog Modal'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    if (controller.selectedFeaturedBookId.value != null)
                      TextButton.icon(
                        onPressed: () => controller.setFeaturedBook(null),
                        icon: const Icon(LucideIcons.x, size: 14, color: Colors.redAccent),
                        label: const Text(
                          'Hapus Pilihan',
                          style: TextStyle(color: Colors.redAccent, fontSize: 12),
                        ),
                      ),
                  ],
                ),

                if (selectedBook != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 50,
                            height: 70,
                            child: selectedBook.coverUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: selectedBook.coverUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => Container(
                                      color: Colors.grey[300],
                                      child: const Icon(LucideIcons.book, size: 24, color: Colors.grey),
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: const Icon(LucideIcons.book, size: 24, color: Colors.grey),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedBook.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (selectedBook.author.isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  'Penulis: ${selectedBook.author}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                              ],
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  if (selectedBook.discountPrice != null && selectedBook.discountPrice! > 0) ...[
                                    Text(
                                      _formatPrice(selectedBook.discountPrice!),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _formatPrice(selectedBook.price),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF94A3B8),
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ] else
                                    Text(
                                      _formatPrice(selectedBook.price),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  void _showBookPickerModal(BuildContext context, WebSettingsController controller) {
    final searchController = TextEditingController();
    final RxString searchQuery = ''.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pilih Buku Pilihan Utama',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: searchController,
                onChanged: (val) => searchQuery.value = val.toLowerCase(),
                decoration: InputDecoration(
                  hintText: 'Cari berdasarkan judul atau penulis...',
                  prefixIcon: const Icon(LucideIcons.search, size: 18),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  final query = searchQuery.value.trim();
                  final filtered = controller.booksList.where((b) {
                    if (query.isEmpty) return true;
                    return b.title.toLowerCase().contains(query) || b.author.toLowerCase().contains(query);
                  }).toList();

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text(
                        'Buku tidak ditemukan',
                        style: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final book = filtered[index];
                      final isSelected = controller.selectedFeaturedBookId.value == book.id;

                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            width: 36,
                            height: 50,
                            child: book.coverUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: book.coverUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => Container(
                                      color: Colors.grey[200],
                                      child: const Icon(LucideIcons.book, size: 18, color: Colors.grey),
                                    ),
                                  )
                                : Container(
                                    color: Colors.grey[200],
                                    child: const Icon(LucideIcons.book, size: 18, color: Colors.grey),
                                  ),
                          ),
                        ),
                        title: Text(
                          book.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppTheme.primaryColor : const Color(0xFF1E293B),
                          ),
                        ),
                        subtitle: Text(
                          book.author.isNotEmpty ? book.author : 'Harga: ${_formatPrice(book.price)}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                        trailing: isSelected
                            ? const Icon(LucideIcons.checkCircle2, color: AppTheme.primaryColor)
                            : OutlinedButton(
                                onPressed: () {
                                  controller.setFeaturedBook(book.id);
                                  Navigator.of(ctx).pop();
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: const Text('Pilih', style: TextStyle(fontSize: 12)),
                              ),
                        onTap: () {
                          controller.setFeaturedBook(book.id);
                          Navigator.of(ctx).pop();
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBannerPlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(LucideIcons.image, size: 36, color: Color(0xFF94A3B8)),
          SizedBox(height: 8),
          Text(
            'Belum ada banner utama yang diunggah',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
          ),
          SizedBox(height: 2),
          Text(
            'Format yang didukung: JPG, PNG, WEBP (Rekomendasi rasio 16:9)',
            style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

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
                  LucideIcons.eye,
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
          const SizedBox(height: 20),

          // Mockup Browser Window Box
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Browser Dots Header Bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                    border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: const Row(
                            children: [
                              Icon(LucideIcons.lock, size: 10, color: Color(0xFF10B981)),
                              SizedBox(width: 6),
                              Text(
                                'https://pustakaiman.com',
                                style: TextStyle(
                                  color: Color(0xFF475569),
                                  fontSize: 10,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Mockup Body Preview (Clean White Inner Background + 2-Column Horizontal Row)
                Container(
                  padding: const EdgeInsets.all(18.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left Column (~50% width inside preview)
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Pill Badge: Red pill ★ PILIHAN UNTUKMU
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFFCA5A5)),
                              ),
                              child: const Text(
                                '★ PILIHAN UNTUKMU',
                                style: TextStyle(
                                  color: Color(0xFFDC2626),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Live Headline preview
                            Obx(() {
                              final headline = controller.headlineText.value.trim();
                              return Text(
                                headline.isNotEmpty ? headline : WebSettingsController.defaultHeadline,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  height: 1.25,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              );
                            }),
                            const SizedBox(height: 8),

                            // Live Subheadline preview
                            Obx(() {
                              final subheadline = controller.subheadlineText.value.trim();
                              return Text(
                                subheadline.isNotEmpty ? subheadline : WebSettingsController.defaultSubheadline,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 11,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              );
                            }),
                            const SizedBox(height: 14),

                            // Buttons Row (Wrap for responsive flow)
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                // Red filled button: JELAJAHI KOLEKSI →
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDC2626),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFDC2626).withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'JELAJAHI KOLEKSI',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(LucideIcons.arrowRight, color: Colors.white, size: 10),
                                    ],
                                  ),
                                ),

                                // Outline button: BUKU TERBARU
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFCBD5E1)),
                                  ),
                                  child: const Text(
                                    'BUKU TERBARU',
                                    style: TextStyle(
                                      color: Color(0xFF334155),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Right Column (~50% width inside preview)
                      Expanded(
                        flex: 1,
                        child: Obx(() {
                          final selectedFile = controller.selectedBannerFile.value;
                          final currentUrl = controller.bannerUrl.value;
                          final selectedBook = controller.selectedFeaturedBook;

                          Widget bannerContent;

                          if (selectedFile != null) {
                            bannerContent = Container(
                              height: 160,
                              width: double.infinity,
                              color: const Color(0xFFF1F5F9),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(LucideIcons.fileCheck, color: Color(0xFFDC2626), size: 28),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Berkas Siap Diunggah:\n${selectedFile.name}',
                                      style: const TextStyle(color: Color(0xFF334155), fontSize: 10, fontWeight: FontWeight.w600),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else if (currentUrl.isNotEmpty) {
                            bannerContent = SizedBox(
                              height: 160,
                              width: double.infinity,
                              child: CachedNetworkImage(
                                imageUrl: currentUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  color: const Color(0xFFF1F5F9),
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFDC2626)),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  color: const Color(0xFFF1F5F9),
                                  child: const Center(
                                    child: Icon(LucideIcons.imageOff, color: Colors.grey),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            bannerContent = Container(
                              height: 160,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFEF2F2), Color(0xFFFEE2E2)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(color: const Color(0xFFFCA5A5)),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.bookOpen, size: 28, color: Color(0xFFDC2626)),
                                    SizedBox(height: 6),
                                    Text(
                                      'Banner Hero Storefront',
                                      style: TextStyle(color: Color(0xFF991B1B), fontSize: 10, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Banner Image Box
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: bannerContent,
                              ),

                              // Floating Badge Overlay (Bottom-Right corner)
                              Positioned(
                                bottom: -6,
                                right: -6,
                                child: Container(
                                  width: 145,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
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
                                      Row(
                                        children: const [
                                          Icon(LucideIcons.star, size: 9, color: Color(0xFFDC2626)),
                                          SizedBox(width: 3),
                                          Text(
                                            'PILIHAN MINGGU INI',
                                            style: TextStyle(
                                              color: Color(0xFFDC2626),
                                              fontSize: 8,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: 0.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        selectedBook?.title ?? 'Tolong Bersabarlah',
                                        style: const TextStyle(
                                          color: Color(0xFF0F172A),
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        selectedBook?.author.isNotEmpty == true
                                            ? selectedBook!.author
                                            : 'Habiburrahman El Shirazy',
                                        style: const TextStyle(
                                          color: Color(0xFF64748B),
                                          fontSize: 8,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: const [
                                              Icon(Icons.star, size: 9, color: Color(0xFFF59E0B)),
                                              SizedBox(width: 2),
                                              Text(
                                                '4.9',
                                                style: TextStyle(
                                                  color: Color(0xFF0F172A),
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            selectedBook != null && selectedBook.price > 0
                                                ? 'Rp ${selectedBook.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'
                                                : 'Rp 85.000',
                                            style: const TextStyle(
                                              color: Color(0xFFDC2626),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 4. Kustomisasi Kategori Pilihan di Halaman Beranda
  Widget _buildFeaturedCategoriesCard(BuildContext context, WebSettingsController controller) {
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
          // Section Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  LucideIcons.layoutGrid,
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
                      'Kustomisasi Kategori Pilihan di Halaman Beranda',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Atur 1 Kategori Utama (Card Merah Besar + 3 cover 2D) & 4 Kategori Pendukung (Card Kecil + 2 cover 2D)',
                      style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Help / Guidance Alert Note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.info, size: 16, color: Color(0xFF1D4ED8)),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Catatan: Pilih buku dengan cover 2D (tampak depan datar) untuk hasil visual terbaik.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // PART 1: Kategori Utama (Card Merah Besar)
          _buildMainFeaturedCategoryCard(context, controller),

          const SizedBox(height: 24),

          // PART 2: Kategori Pendukung (4 Card Kecil)
          _buildSupportingFeaturedCategoriesGrid(context, controller),
        ],
      ),
    );
  }

  // PART 1: Kategori Utama (Card Merah / Marun Tipis)
  Widget _buildMainFeaturedCategoryCard(BuildContext context, WebSettingsController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.3)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris 1: Header kecil berlatar marun tipis dengan judul "Slot 1 - Kategori Utama" + badge "Wajib 3 Buku"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.crown, color: AppTheme.primaryColor, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Slot 1 - Kategori Utama',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFF59E0B)),
                ),
                child: const Text(
                  'Wajib 3 Buku',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Baris 2: Dropdown Kategori Utama
          const Text(
            'Kategori Utama',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 6),
          Obx(() {
            final categories = controller.availableCatalogCategories;
            final current = controller.featuredMainCategory.value;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: categories.contains(current) ? current : (categories.isNotEmpty ? categories.first : null),
                  hint: const Text('Pilih Kategori Utama...'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  onChanged: (val) {
                    if (val != null) {
                      controller.featuredMainCategory.value = val;
                    }
                  },
                  items: categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                ),
              ),
            );
          }),

          const SizedBox(height: 16),

          // Baris 3: Label kecil "Pilih 3 Buku (Cover 2D Datar)"
          const Text(
            'Pilih 3 Buku (Cover 2D Datar)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 10),

          // Baris 4: Daftar 3 Slot Buku — selalu berjejer horizontal
          Obx(() {
            final books = controller.featuredMainBooks;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(3, (index) {
                  return Padding(
                    padding: EdgeInsets.only(right: index < 2 ? 10.0 : 0),
                    child: _buildBookPickerTile(
                      context,
                      controller,
                      slotLabel: 'Buku ${index + 1}',
                      book: books[index],
                      onSelect: () => _showCoverSourcePicker(
                        context,
                        controller,
                        onImageUploaded: (url) => controller.setMainCategoryBook(
                          index,
                          FeaturedBookItem(id: '', title: 'Cover ${index + 1}', price: 0, coverUrl: url),
                        ),
                        onBookSelected: (b) => controller.setMainCategoryBook(index, b),
                      ),
                      onRemove: () => controller.setMainCategoryBook(index, null),
                    ),
                  );
                }),
              ),
            );
          }),
        ],
      ),
    );
  }

  // PART 2: Kategori Pendukung (4 Card Kecil Grid)
  Widget _buildSupportingFeaturedCategoriesGrid(BuildContext context, WebSettingsController controller) {
    final icons = [
      LucideIcons.bookOpen,
      LucideIcons.sparkles,
      LucideIcons.heart,
      LucideIcons.compass,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori Pendukung (4 Card Kecil)',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Masing-masing slot kategori pendukung memilih 1 nama Kategori dan tepat 2 Buku untuk cover 2D-nya.',
          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 16),

        LayoutBuilder(builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 768;
          final itemWidth = isDesktop ? (constraints.maxWidth - 16) / 2 : constraints.maxWidth;

          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: List.generate(4, (slotIdx) {
              final slot = controller.featuredSupportingSlots[slotIdx];
              final icon = icons[slotIdx % icons.length];

              return Container(
                width: itemWidth,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.borderColor),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(icon, size: 16, color: AppTheme.primaryColor),
                            const SizedBox(width: 8),
                            Text(
                              'Slot ${slotIdx + 2} - Kategori Pendukung',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            '2 Buku',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Category Selector Dropdown
                    Obx(() {
                      final categories = controller.availableCatalogCategories;
                      final current = slot.category.value;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.borderColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: categories.contains(current) ? current : (categories.isNotEmpty ? categories.first : null),
                            hint: const Text('Pilih Kategori...'),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                            onChanged: (val) {
                              if (val != null) {
                                slot.category.value = val;
                              }
                            },
                            items: categories.map((cat) {
                              return DropdownMenuItem<String>(
                                value: cat,
                                child: Text(cat, overflow: TextOverflow.ellipsis),
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 12),

                    const Text(
                      'Pilih 2 Buku (Cover 2D Datar)',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 8),

                    // 2 Book Pickers — selalu horizontal
                    Obx(() {
                      final books = slot.books;

                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBookPickerTile(
                              context,
                              controller,
                              slotLabel: 'Buku 1',
                              book: books[0],
                              onSelect: () => _showCoverSourcePicker(
                                context,
                                controller,
                                onImageUploaded: (url) => controller.setSupportingCategoryBook(
                                  slotIdx, 0,
                                  FeaturedBookItem(id: '', title: 'Cover 1', price: 0, coverUrl: url),
                                ),
                                onBookSelected: (b) => controller.setSupportingCategoryBook(slotIdx, 0, b),
                              ),
                              onRemove: () => controller.setSupportingCategoryBook(slotIdx, 0, null),
                            ),
                            const SizedBox(width: 10),
                            _buildBookPickerTile(
                              context,
                              controller,
                              slotLabel: 'Buku 2',
                              book: books[1],
                              onSelect: () => _showCoverSourcePicker(
                                context,
                                controller,
                                onImageUploaded: (url) => controller.setSupportingCategoryBook(
                                  slotIdx, 1,
                                  FeaturedBookItem(id: '', title: 'Cover 2', price: 0, coverUrl: url),
                                ),
                                onBookSelected: (b) => controller.setSupportingCategoryBook(slotIdx, 1, b),
                              ),
                              onRemove: () => controller.setSupportingCategoryBook(slotIdx, 1, null),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          );
        }),
      ],
    );
  }

  // Compact mini 2D Cover Book Picker Tile Widget (75px wide, 4:3 aspect ratio)
  Widget _buildBookPickerTile(
    BuildContext context,
    WebSettingsController controller, {
    required String slotLabel,
    required FeaturedBookItem? book,
    required VoidCallback onSelect,
    required VoidCallback onRemove,
    double width = 75,
  }) {
    const double coverHeight = 100.0; // ~4:3 ratio for 75px width

    if (book != null) {
      return SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                InkWell(
                  onTap: onSelect,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: width,
                    height: coverHeight,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.borderColor),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: book.coverUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: book.coverUrl,
                              width: width,
                              height: coverHeight,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Container(
                                color: AppTheme.inputFillColor,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.imageOff, size: 18, color: AppTheme.textMuted),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              color: AppTheme.inputFillColor,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(LucideIcons.book, size: 18, color: AppTheme.textMuted),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
                // X/remove button overlay — top-right
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.black.withValues(alpha: 0.60),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onRemove,
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(3),
                        child: Icon(LucideIcons.x, size: 10, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                // Change/edit button overlay — bottom-right
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Material(
                    color: AppTheme.primaryColor.withValues(alpha: 0.85),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: onSelect,
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(3),
                        child: Icon(LucideIcons.repeat, size: 10, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              book.title.isNotEmpty ? book.title : slotLabel,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Unselected state — placeholder cover tile with "Belum dipilih" hint
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Placeholder cover image background
                Container(
                  width: width,
                  height: coverHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2F7),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFCBD5E1),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.imageOff,
                          size: 20,
                          color: Colors.blueGrey.shade300,
                        ),
                      ],
                    ),
                  ),
                ),
                // Centered "+" add button overlay
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.plus, size: 13, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              slotLabel,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Cover Source Picker Dialog: Upload File OR Katalog Buku
  void _showCoverSourcePicker(
    BuildContext context,
    WebSettingsController controller, {
    required ValueChanged<String> onImageUploaded,
    required ValueChanged<FeaturedBookItem> onBookSelected,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pilih Sumber Cover',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(LucideIcons.x, size: 16, color: AppTheme.textSecondary),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pilih cara mendapatkan gambar cover 2D untuk slot ini.',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),

                // --- Option 1: Upload File ---
                InkWell(
                  onTap: () async {
                    Navigator.of(ctx).pop();
                    final url = await controller.pickAndUploadFeaturedCoverImage();
                    if (url != null) {
                      onImageUploaded(url);
                    }
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.uploadCloud, color: Color(0xFF16A34A), size: 22),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Upload Gambar dari File',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'JPG, PNG, WEBP — diunggah ke Supabase Storage',
                                style: TextStyle(fontSize: 11, color: Color(0xFF4ADE80)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // --- Option 2: Katalog Buku ---
                InkWell(
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showBookSearchDialog(context, controller, onSelected: onBookSelected);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.bookOpen, color: AppTheme.primaryColor, size: 22),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pilih dari Katalog Buku',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Ambil cover 2D dari buku yang ada di katalog',
                                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  // Book Search Modal Dialog
  void _showBookSearchDialog(
    BuildContext context,
    WebSettingsController controller, {
    required ValueChanged<FeaturedBookItem> onSelected,
  }) {
    final searchCtrl = TextEditingController();
    final RxString filterText = ''.obs;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 500,
            constraints: const BoxConstraints(maxHeight: 600),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pilih Buku (Cover 2D)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 18),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: searchCtrl,
                  autofocus: true,
                  onChanged: (val) => filterText.value = val,
                  decoration: const InputDecoration(
                    hintText: 'Cari judul buku atau penulis...',
                    prefixIcon: Icon(LucideIcons.search, size: 18),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Obx(() {
                    final query = filterText.value.toLowerCase().trim();
                    final allBooks = controller.booksList;
                    final filtered = query.isEmpty
                        ? allBooks
                        : allBooks.where((b) =>
                            b.title.toLowerCase().contains(query) ||
                            b.author.toLowerCase().contains(query)).toList();

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text('Buku tidak ditemukan', style: TextStyle(color: AppTheme.textMuted)),
                      );
                    }

                    return ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, idx) {
                        final item = filtered[idx];
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: item.coverUrl.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: item.coverUrl,
                                    width: 36,
                                    height: 50,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => Container(
                                      width: 36,
                                      height: 50,
                                      color: AppTheme.inputFillColor,
                                      child: const Icon(LucideIcons.book, size: 16),
                                    ),
                                  )
                                : Container(
                                    width: 36,
                                    height: 50,
                                    color: AppTheme.inputFillColor,
                                    child: const Icon(LucideIcons.book, size: 16),
                                  ),
                          ),
                          title: Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          subtitle: Text(item.author.isNotEmpty ? item.author : 'Penulis tidak diketahui', style: const TextStyle(fontSize: 11)),
                          onTap: () {
                            onSelected(item);
                            Navigator.of(dialogContext).pop();
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

