import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_toast.dart';
import '../../controllers/web_settings_controller.dart';
import '../../widgets/cms_page_header.dart';

class AboutSettingsPage extends StatelessWidget {
  const AboutSettingsPage({super.key});

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
              // Page Header Title & Primary Action
              CmsPageHeader(
                title: 'Kelola Halaman > Tentang Kami',
                subtitle: 'Kelola profil penerbit, visi, misi, serta 4 angka statistik pencapaian',
                isSaving: controller.isSavingAboutInfo.value,
                onSave: () async {
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
              ),

              const SizedBox(height: 24),

              // Card: About Settings
              _buildAboutSettingsCard(context, controller),
            ],
          ),
        );
      }),
    );
  }

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

          // 1. Headline Tentang Kami
          const Text(
            'Judul / Tagline Profil',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller.aboutHeadlineController,
            decoration: InputDecoration(
              hintText: 'Misal: Penerbitan Bermakna, Menginspirasi Peradaban',
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          const SizedBox(height: 16),

          // 2. Deskripsi Utama Tentang Kami
          const Text(
            'Deskripsi Ringkas Penerbit',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller.aboutDescriptionController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Tuliskan profil penerbit secara singkat...',
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          const SizedBox(height: 16),

          // 3. Visi & Misi Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 650;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Visi Utama',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: controller.aboutVisionController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Pernyataan visi...',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Misi Utama',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: controller.aboutMissionController,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: 'Poin-poin misi...',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Visi Utama',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: controller.aboutVisionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Pernyataan visi...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Misi Utama',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: controller.aboutMissionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Poin-poin misi...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
          const Divider(color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),

          // 4. Stat Counter Editors (4 Points)
          const Text(
            '4 Angka Statistik Pencapaian',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Sesuaikan angka statistik pencapaian penerbit yang akan tampil di halaman Tentang Kami.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;

              Widget buildStatRow(int i) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 90,
                        child: TextFormField(
                          controller: controller.statValueControllers[i],
                          decoration: InputDecoration(
                            labelText: 'Nilai/Angka',
                            hintText: '2001',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: controller.statLabelControllers[i],
                          decoration: InputDecoration(
                            labelText: 'Label Keterangan',
                            hintText: 'Tahun Berdiri',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (isWide) {
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


        ],
      ),
    );
  }
}
