import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/video_controller.dart';

class VideoFormDialog extends StatelessWidget {
  final VideoController controller;

  const VideoFormDialog({super.key, required this.controller});

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 850),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Obx(() {
          final isBusy = controller.isLoading.value || controller.isUploading.value;
          final isEditing = controller.editingVideoId.value.isNotEmpty;

          return Stack(
            children: [
              Column(
                children: [
                  // Dialog Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      border: Border(bottom: BorderSide(color: AppTheme.borderColor)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isEditing ? LucideIcons.edit3 : LucideIcons.plusCircle,
                            color: AppTheme.primaryColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEditing ? 'Edit Video Media / Warta' : 'Tambah Video Media Baru',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isEditing
                                    ? 'Perbarui detail data video "Cerita dalam Sorotan"'
                                    : 'Isi formulir untuk menambahkan video ke galeri Warta',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(LucideIcons.x, color: AppTheme.textSecondary),
                          onPressed: isBusy ? null : () => Get.back(),
                        ),
                      ],
                    ),
                  ),

                  // Form Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SECTION 1: Informasi Utama Video
                          _buildCardContainer(
                            children: [
                              _buildSectionHeader('Informasi Utama Video', LucideIcons.youtube),
                              const SizedBox(height: 16),
                              TextField(
                                controller: controller.titleController,
                                decoration: const InputDecoration(
                                  labelText: 'Judul Video *',
                                  hintText: 'Misal: Liputan Khusus Bedah Buku Pustaka Iman',
                                  prefixIcon: Icon(LucideIcons.video, size: 18),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: controller.youtubeUrlController,
                                onChanged: (_) {
                                  // Trigger UI rebuild for live YouTube thumbnail preview
                                  controller.youtubeUrlController.text;
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Link YouTube *',
                                  hintText: 'https://www.youtube.com/watch?v=XXXXXX atau https://youtu.be/XXXXXX',
                                  prefixIcon: Icon(LucideIcons.link, size: 18),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: TextField(
                                      controller: controller.speakerNameController,
                                      decoration: const InputDecoration(
                                        labelText: 'Narasumber / Speaker',
                                        hintText: 'Misal: KH. Zulfa Mustofa',
                                        prefixIcon: Icon(LucideIcons.user, size: 18),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: controller.durationController,
                                      decoration: const InputDecoration(
                                        labelText: 'Durasi Video',
                                        hintText: '08:42',
                                        prefixIcon: Icon(LucideIcons.clock, size: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // SECTION 2: Kategori & Pengaturan Tampilan
                          _buildCardContainer(
                            children: [
                              _buildSectionHeader('Kategori & Pengaturan Tampilan', LucideIcons.sliders),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: DropdownButtonFormField<String>(
                                      initialValue: VideoController.categories.contains(controller.categoryController.text)
                                          ? controller.categoryController.text
                                          : VideoController.categories.first,
                                      decoration: const InputDecoration(
                                        labelText: 'Kategori Video',
                                        prefixIcon: Icon(LucideIcons.tag, size: 18),
                                      ),
                                      items: VideoController.categories.map((cat) {
                                        return DropdownMenuItem<String>(
                                          value: cat,
                                          child: Text(cat, style: const TextStyle(fontSize: 13)),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          controller.categoryController.text = val;
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextField(
                                      controller: controller.orderIndexController,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Urutan (Order Index)',
                                        hintText: '0',
                                        prefixIcon: Icon(LucideIcons.hash, size: 18),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Divider(),
                              const SizedBox(height: 12),

                              // Featured Switch
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Jadikan Video Utama (Featured)',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Text(
                                          'Video utama akan ditampilkan besar sebagai sorotan utama di halaman Warta Web',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Obx(() {
                                    return Switch(
                                      value: controller.isFeatured.value,
                                      activeThumbColor: AppTheme.primaryColor,
                                      onChanged: isBusy
                                          ? null
                                          : (val) => controller.isFeatured.value = val,
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // SECTION 3: Pratinjau Thumbnail Video
                          _buildCardContainer(
                            children: [
                              _buildSectionHeader('Pratinjau & Custom Thumbnail', LucideIcons.image),
                              const SizedBox(height: 16),
                              Obx(() {
                                final file = controller.selectedThumbnailFile.value;
                                final customUrl = controller.thumbnailUrlController.text.trim();
                                final yUrl = controller.youtubeUrlController.text.trim();
                                final yId = controller.extractYoutubeId(yUrl);

                                String effectiveUrl = customUrl;
                                if (effectiveUrl.isEmpty && yId.isNotEmpty) {
                                  effectiveUrl = 'https://img.youtube.com/vi/$yId/hqdefault.jpg';
                                }

                                Widget previewWidget;
                                if (file != null) {
                                  if (file.bytes != null) {
                                    previewWidget = Image.memory(
                                      file.bytes!,
                                      width: 160,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    );
                                  } else {
                                    previewWidget = Container(
                                      width: 160,
                                      height: 100,
                                      color: AppTheme.inputFillColor,
                                      child: const Icon(LucideIcons.image, color: AppTheme.textMuted),
                                    );
                                  }
                                } else if (effectiveUrl.isNotEmpty) {
                                  previewWidget = CachedNetworkImage(
                                    imageUrl: effectiveUrl,
                                    width: 160,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      width: 160,
                                      height: 100,
                                      color: AppTheme.inputFillColor,
                                      child: const Center(
                                        child: SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      width: 160,
                                      height: 100,
                                      color: AppTheme.inputFillColor,
                                      child: const Icon(LucideIcons.videoOff, color: AppTheme.textMuted),
                                    ),
                                  );
                                } else {
                                  previewWidget = Container(
                                    width: 160,
                                    height: 100,
                                    color: AppTheme.inputFillColor,
                                    child: const Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(LucideIcons.youtube, color: AppTheme.textMuted, size: 32),
                                        SizedBox(height: 4),
                                        Text('Masukkan Link YouTube', style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                                      ],
                                    ),
                                  );
                                }

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: AppTheme.borderColor),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            previewWidget,
                                            if (yId.isNotEmpty)
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(LucideIcons.play, color: Colors.white, size: 18),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          OutlinedButton.icon(
                                            onPressed: isBusy ? null : () => controller.pickThumbnailFile(),
                                            icon: const Icon(LucideIcons.uploadCloud, size: 16),
                                            label: const Text('Pilih Custom Thumbnail (Opsional)'),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            file != null
                                                ? 'File dipilih: ${file.name}'
                                                : (customUrl.isNotEmpty
                                                    ? 'Thumbnail Kustom Tersimpan'
                                                    : (yId.isNotEmpty
                                                        ? 'Otomatis menggunakan Thumbnail YouTube HQ'
                                                        : 'Belum ada gambar thumbnail')),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: (file != null || customUrl.isNotEmpty || yId.isNotEmpty)
                                                  ? AppTheme.primaryColor
                                                  : AppTheme.textSecondary,
                                            ),
                                          ),
                                          if (yId.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'YouTube Video ID: $yId',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Dialog Footer / Action Buttons
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
                      border: Border(top: BorderSide(color: AppTheme.borderColor)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: isBusy ? null : () => Get.back(),
                          child: const Text('Batal'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: isBusy ? null : () => controller.saveVideo(),
                          icon: isBusy
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(LucideIcons.check, size: 18),
                          label: Text(
                            isEditing ? 'Simpan Perubahan' : 'Tambah Video',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              if (controller.isUploading.value)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              controller.uploadStatusMessage.value.isNotEmpty
                                  ? controller.uploadStatusMessage.value
                                  : 'Memproses data...',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }
}
