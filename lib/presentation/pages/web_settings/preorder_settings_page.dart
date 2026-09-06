import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_toast.dart';
import '../../controllers/web_settings_controller.dart';
import '../../../data/models/bank_account_model.dart';
import '../../widgets/bank_account_dialog.dart';
import '../../widgets/cms_page_header.dart';

class PreorderSettingsPage extends StatelessWidget {
  const PreorderSettingsPage({super.key});

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
            title: 'Kelola Halaman > Pre-Order',
            subtitle: 'Kelola sistem konfirmasi WhatsApp pre-order dan daftar akun rekening bank penerima pembayaran',
            isSaving: controller.isSavingPreorderWa.value,
            onSave: () async {
              final success = await controller.savePreorderWaSettings();
              if (context.mounted) {
                if (success) {
                  AppToast.showSuccess(
                    context,
                    'Pengaturan konfirmasi WhatsApp pre-order berhasil disimpan!',
                  );
                } else {
                  AppToast.showError(
                    context,
                    controller.errorMessage.value.isNotEmpty
                        ? controller.errorMessage.value
                        : 'Gagal menyimpan pengaturan WhatsApp pre-order.',
                  );
                }
              }
            },
          ),

          const SizedBox(height: 24),

          // Card 1: Pre-Order WhatsApp Confirmation Setting
          _buildWhatsAppConfirmationCard(context, controller),

          const SizedBox(height: 24),

          // Card 2: Bank Accounts Management Card
          _buildBankAccountsCard(context, controller),
        ],
      ),
    );
  }

  Widget _buildWhatsAppConfirmationCard(BuildContext context, WebSettingsController controller) {
    final isEnabled = controller.preorderWaEnabled.value;

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
                  LucideIcons.messageSquare,
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
                      'Konfirmasi WhatsApp Pre-Order',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Atur konfirmasi langsung via WhatsApp untuk pemesan buku pre-order.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Toggle Switch Section
          Container(
            decoration: BoxDecoration(
              color: isEnabled ? AppTheme.primaryColor.withValues(alpha: 0.04) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isEnabled ? AppTheme.primaryColor.withValues(alpha: 0.2) : const Color(0xFFE2E8F0),
              ),
            ),
            child: SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              activeThumbColor: AppTheme.primaryColor,
              value: isEnabled,
              onChanged: (val) => controller.preorderWaEnabled.value = val,
              title: const Text(
                'Aktifkan Konfirmasi WhatsApp',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              subtitle: const Text(
                'Mengarahkan pemesan langsung ke WhatsApp setelah berhasil mengisi form pre-order.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Input Textfield Section
          Text(
            'Nomor WhatsApp Admin Tujuan',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isEnabled ? AppTheme.textPrimary : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Format nomor internasional (misal: 628xxxxxxxxxx) atau lokal (08xxxxxxxxxx)',
            style: TextStyle(
              fontSize: 11,
              color: isEnabled ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller.preorderWaNumberController,
            enabled: isEnabled,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
              fontSize: 14,
              color: isEnabled ? AppTheme.textPrimary : const Color(0xFF94A3B8),
            ),
            decoration: InputDecoration(
              hintText: 'Misal: 6281234567890 atau 081234567890',
              hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
              filled: !isEnabled,
              fillColor: !isEnabled ? const Color(0xFFF1F5F9) : Colors.white,
              prefixIcon: Icon(
                LucideIcons.phone,
                size: 18,
                color: isEnabled ? AppTheme.primaryColor : const Color(0xFFCBD5E1),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountsCard(BuildContext context, WebSettingsController controller) {
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
          // Header Row with Mobile Breakpoint support
          LayoutBuilder(
            builder: (context, constraints) {
              final isMobileHeader = constraints.maxWidth < 550;
              final addButton = ElevatedButton.icon(
                onPressed: () async {
                  final result = await showDialog<BankAccountModel>(
                    context: context,
                    builder: (ctx) => const BankAccountDialog(),
                  );
                  if (result != null) {
                    await controller.saveBankAccount(result);
                  }
                },
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('Tambah Rekening'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );

              if (isMobileHeader) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            LucideIcons.landmark,
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
                                'Rekening Pembayaran Pre-Order',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Daftar akun rekening bank aktif penerima transfer pembayaran untuk transaksi pre-order.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(width: double.infinity, child: addButton),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            LucideIcons.landmark,
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
                                'Rekening Pembayaran Pre-Order',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Daftar akun rekening bank aktif penerima transfer pembayaran untuk transaksi pre-order.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  addButton,
                ],
              );
            },
          ),
          const SizedBox(height: 20),

          // Content List Obx
          Obx(() {
            if (controller.bankAccounts.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: const [
                    Icon(LucideIcons.creditCard, size: 36, color: Color(0xFF94A3B8)),
                    SizedBox(height: 10),
                    Text(
                      'Belum ada rekening bank yang ditambahkan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Klik tombol "Tambah Rekening" untuk menambahkan akun rekening bank pertama.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;
                final crossAxisCount = isWide ? 3 : (constraints.maxWidth > 450 ? 2 : 1);

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: controller.bankAccounts.map((account) {
                    final itemWidth = crossAxisCount == 1
                        ? constraints.maxWidth
                        : (constraints.maxWidth - (16 * (crossAxisCount - 1))) / crossAxisCount;

                    return Container(
                      width: itemWidth,
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
                                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  account.bankName,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      final result = await showDialog<BankAccountModel>(
                                        context: context,
                                        builder: (ctx) => BankAccountDialog(initialAccount: account),
                                      );
                                      if (result != null) {
                                        await controller.saveBankAccount(result);
                                      }
                                    },
                                    icon: const Icon(LucideIcons.pencil, size: 14, color: Color(0xFF64748B)),
                                    tooltip: 'Edit Rekening',
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(4),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    onPressed: () => _confirmDeleteBank(context, controller, account),
                                    icon: const Icon(LucideIcons.trash2, size: 14, color: Color(0xFFEF4444)),
                                    tooltip: 'Hapus Rekening',
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(4),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            account.accountNumber,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'a.n. ${account.accountHolder}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  void _confirmDeleteBank(BuildContext context, WebSettingsController controller, BankAccountModel account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Rekening Bank'),
        content: Text('Apakah Anda yakin ingin menghapus rekening bank ${account.bankName} (${account.accountNumber})?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await controller.deleteBankAccount(account.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
