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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28.0),
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
}
