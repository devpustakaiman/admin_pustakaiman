import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_toast.dart';
import '../../controllers/web_settings_controller.dart';
import '../../widgets/cms_page_header.dart';

class ContactSettingsPage extends StatelessWidget {
  const ContactSettingsPage({super.key});

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
                title: 'Kelola Halaman > Kontak & Layanan',
                subtitle: 'Kelola alamat kantor, nomor kontak telepon, WhatsApp customer care, dan email resmi',
                isSaving: controller.isSavingContactInfo.value,
                onSave: () async {
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
              ),

              const SizedBox(height: 24),

              // Card: Contact Info
              _buildContactInfoCard(context, controller),
            ],
          ),
        );
      }),
    );
  }

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


        ],
      ),
    );
  }
}
