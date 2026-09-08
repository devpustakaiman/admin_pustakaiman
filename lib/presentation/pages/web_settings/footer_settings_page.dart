import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_toast.dart';
import '../../controllers/web_settings_controller.dart';
import '../../widgets/cms_page_header.dart';

class FooterSettingsPage extends StatelessWidget {
  const FooterSettingsPage({super.key});

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
            title: 'Kelola Halaman > Kelola Footer & Media Sosial',
            subtitle: 'Kelola tautan media sosial resmi dan tautan toko online resmi (Mizanstore)',
            isSaving: controller.isSavingFooterInfo.value,
            onSave: () async {
              final success = await controller.saveFooterInfo();
              if (context.mounted) {
                if (success) {
                  AppToast.showSuccess(
                    context,
                    'Perubahan footer berhasil disimpan',
                  );
                } else {
                  AppToast.showError(
                    context,
                    controller.errorMessage.value.isNotEmpty
                        ? controller.errorMessage.value
                        : 'Gagal menyimpan perubahan footer.',
                  );
                }
              }
            },
          ),

          const SizedBox(height: 24),

          // Card: Footer & Social Media Links
          _buildFooterInfoCard(context, controller),
        ],
      ),
    );
  }

  Widget _buildFooterInfoCard(BuildContext context, WebSettingsController controller) {
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
                  LucideIcons.share2,
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
                      'Tautan Media Sosial & Toko Resmi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Atur tautan akun media sosial penerbit dan tautan pembelian toko resmi yang akan ditampilkan pada footer website.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 1. Facebook URL
          const Text(
            'Facebook URL',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller.footerFacebookController,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText: 'https://www.facebook.com/penerbit.imania/',
              prefixIcon: const Icon(LucideIcons.facebook, size: 18, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          const SizedBox(height: 16),

          // 2. X (Twitter) URL
          const Text(
            'X (Twitter) URL',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller.footerXController,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText: 'https://x.com/penerbitimania',
              prefixIcon: const Icon(LucideIcons.twitter, size: 18, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          const SizedBox(height: 16),

          // 3. Instagram URL
          const Text(
            'Instagram URL',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller.footerInstagramController,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText: 'https://www.instagram.com/penerbitimania/',
              prefixIcon: const Icon(LucideIcons.instagram, size: 18, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          const SizedBox(height: 16),

          // 4. TikTok URL
          const Text(
            'TikTok URL',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller.footerTiktokController,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText: 'https://www.tiktok.com/@penerbitimania',
              prefixIcon: const Icon(LucideIcons.video, size: 18, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          const SizedBox(height: 16),

          // 5. Mizanstore / Official Store URL
          const Text(
            'Mizanstore / Official Store URL',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller.footerMizanstoreController,
            keyboardType: TextInputType.url,
            decoration: InputDecoration(
              hintText: 'https://www.mizanstore.com/',
              prefixIcon: const Icon(LucideIcons.shoppingBag, size: 18, color: Color(0xFF94A3B8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),

          const SizedBox(height: 24),

          // Simpan Perubahan Button
          Align(
            alignment: Alignment.centerRight,
            child: Obx(
              () => ElevatedButton.icon(
                onPressed: controller.isSavingFooterInfo.value
                    ? null
                    : () async {
                        final success = await controller.saveFooterInfo();
                        if (context.mounted) {
                          if (success) {
                            AppToast.showSuccess(
                              context,
                              'Perubahan footer berhasil disimpan',
                            );
                          } else {
                            AppToast.showError(
                              context,
                              controller.errorMessage.value.isNotEmpty
                                  ? controller.errorMessage.value
                                  : 'Gagal menyimpan perubahan footer.',
                            );
                          }
                        }
                      },
                icon: controller.isSavingFooterInfo.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(LucideIcons.save, size: 16),
                label: Text(controller.isSavingFooterInfo.value ? 'Menyimpan...' : 'Simpan Perubahan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
