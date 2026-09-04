import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/video_controller.dart';

class VideoManagementPage extends GetView<VideoController> {
  const VideoManagementPage({super.key});

  Widget _buildCategoryBadge(String category) {
    Color bg;
    Color text;
    switch (category.toUpperCase()) {
      case 'LIPUTAN UTAMA':
        bg = Colors.red.shade50;
        text = Colors.red.shade700;
        break;
      case 'WAWANCARA':
        bg = Colors.blue.shade50;
        text = Colors.blue.shade700;
        break;
      case 'BEDAH BUKU':
        bg = Colors.purple.shade50;
        text = Colors.purple.shade700;
        break;
      case 'DOKUMENTER':
        bg = Colors.amber.shade50;
        text = Colors.amber.shade900;
        break;
      case 'CERITA DALAM SOROTAN':
        bg = Colors.teal.shade50;
        text = Colors.teal.shade700;
        break;
      default:
        bg = Colors.grey.shade100;
        text = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: text.withValues(alpha: 0.2)),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Kelola Video Media / Warta',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kelola galeri video "Cerita dalam Sorotan", liputan khusus, dan narasumber Warta',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => controller.openFormDialog(),
                  icon: const Icon(LucideIcons.plus, size: 18),
                  label: const Text(
                    'Tambah Video',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Two-Tier Action Bar (Search & Filters)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.borderColor),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                children: [
                  // Tier 1: Search & Main Actions
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (val) => controller.searchQuery.value = val,
                          decoration: InputDecoration(
                            hintText: 'Cari judul video, narasumber, atau kategori...',
                            prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppTheme.textSecondary),
                            suffixIcon: Obx(() {
                              if (controller.searchQuery.value.isEmpty) {
                                return const SizedBox.shrink();
                              }
                              return IconButton(
                                icon: const Icon(LucideIcons.x, size: 16, color: AppTheme.textSecondary),
                                onPressed: () {
                                  controller.searchQuery.value = '';
                                },
                              );
                            }),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            filled: true,
                            fillColor: AppTheme.inputFillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () => controller.fetchVideos(),
                        icon: const Icon(LucideIcons.refreshCw, size: 18),
                        tooltip: 'Refresh Data',
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppTheme.borderColor),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Tier 2: Category Filter Chips
                  Obx(() {
                    final currentCat = controller.selectedCategoryFilter.value;
                    final categoryList = ['Semua Kategori', ...VideoController.categories];

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categoryList.map((cat) {
                          final isSelected = currentCat == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              onSelected: (_) {
                                controller.selectedCategoryFilter.value = cat;
                              },
                              selectedColor: AppTheme.primaryColor,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.textPrimary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12,
                              ),
                              backgroundColor: Colors.grey.shade100,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Video List Table / Cards
            Obx(() {
              if (controller.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.all(48),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final videoList = controller.filteredVideos;

              if (videoList.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(48),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(LucideIcons.videoOff, size: 48, color: AppTheme.textMuted),
                      const SizedBox(height: 16),
                      const Text(
                        'Tidak Ada Video Ditemukan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.searchQuery.value.isNotEmpty
                            ? 'Tidak ada video yang cocok dengan kata kunci pencarian Anda'
                            : 'Belum ada video media ditambahkan ke pustaka',
                        style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => controller.openFormDialog(),
                        icon: const Icon(LucideIcons.plus, size: 16),
                        label: const Text('Tambah Video Sekarang'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                  boxShadow: AppTheme.softShadow,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: videoList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.borderColor),
                  itemBuilder: (context, index) {
                    final video = videoList[index];
                    final thumbUrl = video.effectiveThumbnailUrl;

                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Thumbnail Preview Box
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 140,
                              height: 85,
                              color: Colors.black12,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (thumbUrl.isNotEmpty)
                                    CachedNetworkImage(
                                      imageUrl: thumbUrl,
                                      width: 140,
                                      height: 85,
                                      fit: BoxFit.cover,
                                      memCacheWidth: 350,
                                      memCacheHeight: 210,
                                      placeholder: (_, __) => Container(color: Colors.grey.shade200),
                                      errorWidget: (_, __, ___) => Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(LucideIcons.videoOff, color: AppTheme.textMuted),
                                      ),
                                    )
                                  else
                                    Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(LucideIcons.video, color: AppTheme.textMuted),
                                    ),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(LucideIcons.play, color: Colors.white, size: 14),
                                  ),
                                  if (video.duration.isNotEmpty)
                                    Positioned(
                                      bottom: 6,
                                      right: 6,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.75),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          video.duration,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Video Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    _buildCategoryBadge(video.category),
                                    if (video.isFeatured) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Colors.amber, Colors.orangeAccent],
                                          ),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(LucideIcons.star, size: 12, color: Colors.white),
                                            SizedBox(width: 4),
                                            Text(
                                              'UTAMA (FEATURED)',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  video.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    if (video.speakerName.isNotEmpty) ...[
                                      const Icon(LucideIcons.user, size: 14, color: AppTheme.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        video.speakerName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                    ],
                                    const Icon(LucideIcons.link, size: 14, color: AppTheme.textMuted),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        video.youtubeUrl,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.primaryColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Toggle Featured & Action Buttons
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Video Utama:',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Switch(
                                    value: video.isFeatured,
                                    activeThumbColor: AppTheme.primaryColor,
                                    onChanged: (_) => controller.toggleFeatured(video),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () => controller.openFormDialog(video: video),
                                    icon: const Icon(LucideIcons.edit3, size: 14),
                                    label: const Text('Edit'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () => controller.deleteVideo(video),
                                    icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.redAccent),
                                    tooltip: 'Pindahkan ke Sampah',
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.red.shade50,
                                      padding: const EdgeInsets.all(8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
