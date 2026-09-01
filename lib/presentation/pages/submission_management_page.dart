import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_toast.dart';
import '../../domain/entities/submission.dart';
import '../controllers/submission_controller.dart';

class SubmissionManagementPage extends StatelessWidget {
  const SubmissionManagementPage({super.key});

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
      case 'diterima':
      case 'approved':
        return const Color(0xFF10B981);
      case 'rejected':
      case 'ditolak':
        return Colors.redAccent;
      case 'pending':
      case 'menunggu':
      default:
        return Colors.orangeAccent;
    }
  }

  Widget _buildStatusBadge(
    BuildContext context,
    Submission submission,
    SubmissionController controller,
  ) {
    final color = _getStatusColor(submission.status);
    final statusText = submission.status.toUpperCase();

    return PopupMenuButton<String>(
      tooltip: 'Ubah Status Naskah',
      onSelected: (String newStatus) {
        controller.updateStatus(submission.id, newStatus);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'DITERIMA',
          child: Row(
            children: [
              Icon(LucideIcons.checkCircle, color: Color(0xFF10B981), size: 16),
              SizedBox(width: 8),
              Text('DITERIMA'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'DITOLAK',
          child: Row(
            children: [
              Icon(LucideIcons.xCircle, color: Colors.redAccent, size: 16),
              SizedBox(width: 8),
              Text('DITOLAK'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'PENDING',
          child: Row(
            children: [
              Icon(LucideIcons.clock, color: Colors.orangeAccent, size: 16),
              SizedBox(width: 8),
              Text('PENDING'),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              statusText,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 6),
            Icon(LucideIcons.chevronDown, color: color, size: 14),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubmissionController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Title
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Submission Naskah',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Kelola naskah buku yang dikirimkan oleh calon penulis',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Unified Filter & Action Bar
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Status Filter Dropdown (Height 44)
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderColor),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Obx(() {
                    const statuses = ['Semua Status', 'DITERIMA', 'DITOLAK', 'PENDING'];
                    return DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.statusFilter.value,
                        icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppTheme.textSecondary),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            controller.statusFilter.value = newValue;
                          }
                        },
                        items: statuses.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    );
                  }),
                ),

                const SizedBox(width: 12),

                // Sort By Dropdown (Height 44)
                Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderColor),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Obx(() {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.arrowUpDown, size: 16, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: controller.sortBy.value,
                            icon: const Icon(LucideIcons.chevronDown, size: 16, color: AppTheme.textSecondary),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                controller.sortBy.value = newValue;
                              }
                            },
                            items: const [
                              DropdownMenuItem(value: 'date', child: Text('Urut: Tanggal')),
                              DropdownMenuItem(value: 'name', child: Text('Urut: Nama Penulis')),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),

                const SizedBox(width: 12),

                // Asc / Desc Toggle Button (Height 44)
                Obx(() {
                  final isAsc = controller.isAscending.value;
                  return InkWell(
                    onTap: () => controller.isAscending.value = !isAsc,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderColor),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Icon(
                        isAsc ? LucideIcons.arrowUp : LucideIcons.arrowDown,
                        size: 18,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  );
                }),

                // Pushes Refresh Button to the far right!
                const Spacer(),

                // Refresh Button (IconButton, Height 44)
                IconButton(
                  onPressed: () => controller.fetchSubmissions(),
                  icon: const Icon(LucideIcons.refreshCw, size: 18),
                  tooltip: 'Segarkan Data',
                  style: IconButton.styleFrom(
                    fixedSize: const Size(44, 44),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppTheme.borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Content List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryColor),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.alertCircle, color: Colors.redAccent, size: 40),
                          const SizedBox(height: 12),
                          Text(
                            'Terjadi Kesalahan:\n${controller.errorMessage.value}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => controller.fetchSubmissions(),
                            icon: const Icon(LucideIcons.refreshCw, size: 16),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final displaySubmissions = controller.filteredSubmissions;

                if (displaySubmissions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.inbox,
                            size: 48,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Belum ada data submission naskah masuk.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: displaySubmissions.length,
                  itemBuilder: (context, index) {
                    final submission = displaySubmissions[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.borderColor),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppTheme.inputFillColor,
                                  child: Icon(LucideIcons.user, size: 20, color: AppTheme.primaryColor),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        submission.senderName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(LucideIcons.mail, size: 13, color: AppTheme.textSecondary),
                                          const SizedBox(width: 4),
                                          Text(
                                            submission.email,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          const Icon(LucideIcons.clock, size: 13, color: AppTheme.textMuted),
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatDate(submission.createdAt),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                _buildStatusBadge(context, submission, controller),
                              ],
                            ),

                            if (submission.synopsis.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: AppTheme.inputFillColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  submission.synopsis,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textPrimary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 16),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => controller.previewPdf(
                                    submission.pdfDocumentUrl,
                                  ),
                                  icon: const Icon(LucideIcons.eye, size: 16),
                                  label: const Text('Preview PDF'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton.icon(
                                  onPressed: () => controller.downloadPdf(
                                    submission.pdfDocumentUrl,
                                  ),
                                  icon: const Icon(LucideIcons.download, size: 16),
                                  label: const Text('Unduh PDF'),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.redAccent),
                                  tooltip: 'Hapus Submission',
                                  onPressed: () => _confirmDelete(context, controller, submission),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, SubmissionController controller, Submission submission) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Submission', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin memindahkan submission naskah dari "${submission.senderName}" ke Keranjang Sampah?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await controller.deleteSubmission(submission.id);
              if (context.mounted) {
                AppToast.showSuccess(context, 'Submission dari "${submission.senderName}" dipindahkan ke Keranjang Sampah.');
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
