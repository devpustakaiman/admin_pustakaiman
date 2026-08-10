import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
        return Colors.green;
      case 'rejected':
      case 'ditolak':
        return Colors.red;
      case 'pending':
      case 'menunggu':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubmissionController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Submission Naskah'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.fetchSubmissions(),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Terjadi Kesalahan:\n${controller.errorMessage.value}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => controller.fetchSubmissions(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.submissions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Belum ada data submission naskah.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.fetchSubmissions(),
                  child: const Text('Muat Ulang'),
                ),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth > 700;

            if (isWideScreen) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                        ),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Tanggal Masuk',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Nama Penulis',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Email',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Status',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Aksi',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: controller.submissions.map((submission) {
                          return DataRow(
                            cells: [
                              DataCell(Text(_formatDate(submission.createdAt))),
                              DataCell(Text(submission.senderName)),
                              DataCell(Text(submission.email)),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(submission.status)
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: _getStatusColor(submission.status),
                                    ),
                                  ),
                                  child: Text(
                                    submission.status.toUpperCase(),
                                    style: TextStyle(
                                      color: _getStatusColor(submission.status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.download, color: Colors.blue),
                                  tooltip: 'Unduh Dokumen PDF',
                                  onPressed: () => controller.downloadPdf(
                                    submission.pdfDocumentUrl,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.submissions.length,
              itemBuilder: (context, index) {
                final submission = controller.submissions[index];
                final statusColor = _getStatusColor(submission.status);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              submission.senderName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: statusColor),
                              ),
                              child: Text(
                                submission.status.toUpperCase(),
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Email: ${submission.email}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tanggal Masuk: ${_formatDate(submission.createdAt)}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        if (submission.synopsis.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            submission.synopsis,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () => controller.downloadPdf(
                              submission.pdfDocumentUrl,
                            ),
                            icon: const Icon(Icons.download, size: 18),
                            label: const Text('Unduh PDF'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      }),
    );
  }
}
