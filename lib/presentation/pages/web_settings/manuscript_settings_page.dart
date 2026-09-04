import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_toast.dart';
import '../../controllers/web_settings_controller.dart';
import '../../widgets/cms_page_header.dart';

class ManuscriptSettingsPage extends StatelessWidget {
  const ManuscriptSettingsPage({super.key});

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
            title: 'Kelola Halaman > Kirim Naskah',
            subtitle: 'Kelola alur pengiriman naskah, kriteria kelayakan, deskripsi bantuan redaksi, dan kontak WhatsApp redaksi',
            isSaving: controller.isSavingManuscriptInfo.value,
            onSave: () async {
              final success = await controller.saveManuscriptInfo();
              if (context.mounted) {
                if (success) {
                  AppToast.showSuccess(
                    context,
                    'Pengaturan Kirim Naskah berhasil disimpan!',
                  );
                } else {
                  AppToast.showError(
                    context,
                    controller.errorMessage.value.isNotEmpty
                        ? controller.errorMessage.value
                        : 'Gagal menyimpan pengaturan kirim naskah.',
                  );
                }
              }
            },
          ),

          const SizedBox(height: 24),

          // Card: Manuscript Settings
          _buildManuscriptSettingsCard(context, controller),
        ],
      ),
    );
  }

  Widget _buildManuscriptSettingsCard(BuildContext context, WebSettingsController controller) {
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
                  LucideIcons.fileText,
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
                      'Panduan & Redaksi Kirim Naskah',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Kelola alur pengiriman naskah, kriteria kelayakan, deskripsi bantuan redaksi, dan kontak WhatsApp redaksi.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- 1. ALUR PENERBITAN (manuscript_steps) ---
          const Text(
            'Alur & Langkah Pengiriman Naskah',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Atur baris alur langkah penerbitan naskah yang akan ditampilkan di halaman Kirim Naskah.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),

          Obx(() {
            return Column(
              children: [
                for (int i = 0; i < controller.manuscriptSteps.length; i++) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Langkah ${i + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => controller.removeManuscriptStep(i),
                              icon: const Icon(LucideIcons.trash2, size: 16, color: Color(0xFFEF4444)),
                              tooltip: 'Hapus Langkah',
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: controller.manuscriptSteps[i].titleController,
                          decoration: InputDecoration(
                            labelText: 'Judul Langkah',
                            hintText: 'Misal: Kirim Berkas & Sinopsis',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: controller.manuscriptSteps[i].descriptionController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Deskripsi Langkah',
                            hintText: 'Penjelasan singkat alur langkah...',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () => controller.addManuscriptStep(),
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: const Text('Tambah Langkah Alur'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 24),
          const Divider(color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),

          // --- 2. KRITERIA NASKAH (manuscript_criteria) ---
          const Text(
            'Poin-poin Kriteria Naskah',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 4),
          const Text(
            'Daftar syarat dan kriteria kelayakan naskah yang harus dipenuhi.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),

          Obx(() {
            return Column(
              children: [
                for (int i = 0; i < controller.manuscriptCriteriaControllers.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller.manuscriptCriteriaControllers[i],
                            decoration: InputDecoration(
                              hintText: 'Misal: Naskah orisinal (bukan plagiasi)',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => controller.removeManuscriptCriterion(i),
                          icon: const Icon(LucideIcons.trash2, size: 18, color: Color(0xFFEF4444)),
                          tooltip: 'Hapus Kriteria',
                        ),
                      ],
                    ),
                  ),
                ],
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () => controller.addManuscriptCriterion(),
                    icon: const Icon(LucideIcons.plus, size: 16),
                    label: const Text('Tambah Kriteria'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 24),
          const Divider(color: Color(0xFFE2E8F0)),
          const SizedBox(height: 16),

          // --- 3. KONTAK & DESKRIPSI REDAKSI ---
          const Text(
            'Informasi Bantuan Meja Redaksi',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 12),

          const Text(
            'Deskripsi Bantuan Meja Redaksi',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller.manuscriptContactDescController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Tuliskan deskripsi bantuan untuk calon penulis yang ingin berkonsultasi...',
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Nomor WhatsApp Khusus Redaksi',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller.manuscriptWhatsappController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Contoh: 6281234567890 atau 081234567890',
              prefixIcon: const Icon(LucideIcons.messageSquare, size: 18, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),


        ],
      ),
    );
  }
}
