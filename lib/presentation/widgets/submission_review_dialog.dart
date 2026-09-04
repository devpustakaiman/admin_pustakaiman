import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/supabase_remote_data_source.dart';
import '../../domain/entities/submission.dart';

class SubmissionReviewDialog extends StatefulWidget {
  final Submission submission;
  final Function(String newStatus) onStatusChanged;

  const SubmissionReviewDialog({
    super.key,
    required this.submission,
    required this.onStatusChanged,
  });

  @override
  State<SubmissionReviewDialog> createState() => _SubmissionReviewDialogState();
}

class _SubmissionReviewDialogState extends State<SubmissionReviewDialog> {
  late String _currentStatus;
  String _fullSynopsis = '';
  String _fullPdfUrl = '';
  bool _isLoadingDetails = true;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.submission.status;
    _fullSynopsis = widget.submission.synopsis;
    _fullPdfUrl = widget.submission.pdfDocumentUrl;

    _fetchFullDetails();
  }

  Future<void> _fetchFullDetails() async {
    // If synopsis or PDF URL is missing from list view, fetch single full row
    if (_fullSynopsis.isEmpty || _fullPdfUrl.isEmpty) {
      try {
        final ds = Get.find<SupabaseRemoteDataSource>();
        final detail = await ds.getSubmissionById(widget.submission.id);
        if (detail != null && mounted) {
          setState(() {
            _fullSynopsis = detail['synopsis']?.toString() ?? _fullSynopsis;
            _fullPdfUrl = detail['pdf_document_url']?.toString() ??
                detail['pdfDocumentUrl']?.toString() ??
                detail['pdf_url']?.toString() ??
                _fullPdfUrl;
            _isLoadingDetails = false;
          });
          return;
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _isLoadingDetails = false;
      });
    }
  }

  Future<void> _openPdf(String url) async {
    if (url.trim().isEmpty) return;
    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, webOnlyWindowName: '_blank');
    } catch (_) {}
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final month = months[local.month - 1];
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute WIB';
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

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(_currentStatus);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      elevation: 16,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 650, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dialog Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.fileText,
                    color: AppTheme.primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Review Pengajuan Naskah',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${widget.submission.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _currentStatus.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(LucideIcons.x, size: 20, color: AppTheme.textSecondary),
                  tooltip: 'Tutup',
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sender Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.inputFillColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.white,
                            child: Icon(LucideIcons.user, size: 22, color: AppTheme.primaryColor),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.submission.senderName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(LucideIcons.mail, size: 13, color: AppTheme.textSecondary),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.submission.email,
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                                    ),
                                    const SizedBox(width: 14),
                                    const Icon(LucideIcons.calendar, size: 13, color: AppTheme.textMuted),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatDate(widget.submission.createdAt),
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Synopsis Section
                    const Text(
                      'Sinopsis / Ringkasan Naskah',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: _isLoadingDetails
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor),
                              ),
                            )
                          : Text(
                              _fullSynopsis.isNotEmpty
                                  ? _fullSynopsis
                                  : 'Tidak ada sinopsis atau deskripsi yang disertakan pada naskah ini.',
                              style: const TextStyle(
                                fontSize: 13,
                                height: 1.6,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                    ),

                    const SizedBox(height: 20),

                    // PDF Attachment Section
                    const Text(
                      'Dokumen / Naskah PDF',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.inputFillColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.borderColor),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(LucideIcons.fileText, color: Colors.redAccent, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _fullPdfUrl.isNotEmpty
                                      ? 'Berkas Naskah (.pdf)'
                                      : 'Tidak ada berkas PDF terlampir',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _fullPdfUrl.isNotEmpty
                                      ? 'Klik tombol di kanan untuk membuka atau membaca naskah'
                                      : 'Pengirim tidak melampirkan berkas',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          if (_fullPdfUrl.isNotEmpty)
                            ElevatedButton.icon(
                              onPressed: () => _openPdf(_fullPdfUrl),
                              icon: const Icon(LucideIcons.externalLink, size: 15),
                              label: const Text('Buka PDF'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 20),

            // Footer Status Change Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Tutup Dialog'),
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _currentStatus = 'ditolak');
                        widget.onStatusChanged('ditolak');
                        Get.back();
                      },
                      icon: const Icon(LucideIcons.xCircle, size: 16, color: Colors.redAccent),
                      label: const Text('Tolak Naskah', style: TextStyle(color: Colors.redAccent)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.redAccent, width: 1.2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() => _currentStatus = 'diterima');
                        widget.onStatusChanged('diterima');
                        Get.back();
                      },
                      icon: const Icon(LucideIcons.checkCircle, size: 16),
                      label: const Text('Terima Naskah'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
