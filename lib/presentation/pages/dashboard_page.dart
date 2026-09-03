import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/submission.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/submission_review_dialog.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchDashboardData,
          color: AppTheme.primaryColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Bar
                _buildHeader(context, controller),
                const SizedBox(height: 24),

                // 4 Stat Cards Grid
                _buildStatCardsGrid(controller),
                const SizedBox(height: 24),

                // Trend Chart Section
                _buildTrendChartSection(controller),
                const SizedBox(height: 24),

                // Priority Action Table: 5 Most Recent Unreviewed Submissions
                _buildPriorityTableSection(context, controller),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Header Bar with welcome text & refresh button
  Widget _buildHeader(BuildContext context, DashboardController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard Utama',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ringkasan metrik kinerja, naskah masuk prioritas, dan statistik Pustaka Ilman',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: controller.fetchDashboardData,
          icon: const Icon(LucideIcons.refreshCw, size: 16),
          label: const Text('Perbarui Data'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  // 4 Top Stat Cards Grid
  Widget _buildStatCardsGrid(DashboardController controller) {
    return LayoutBuilder(builder: (context, constraints) {
      final isWide = constraints.maxWidth > 950;
      final crossAxisCount = isWide ? 4 : (constraints.maxWidth > 580 ? 2 : 1);
      final aspectRatio = isWide ? 1.55 : (constraints.maxWidth > 580 ? 1.6 : 2.4);

      return GridView.count(
        crossAxisCount: crossAxisCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: aspectRatio,
        children: [
          // 1. Total Buku Terdaftar
          _buildStatCard(
            title: 'Total Buku Terdaftar',
            value: controller.totalBooks.value.toString(),
            subtitle: 'Katalog terbitan aktif',
            icon: LucideIcons.bookOpen,
            iconColor: const Color(0xFF0F766E),
            badgeText: null,
            badgeColor: null,
            onTap: controller.navigateToBooks,
          ),

          // 2. Naskah Masuk (Highlight unreviewed count)
          _buildStatCard(
            title: 'Naskah Masuk',
            value: controller.pendingSubmissions.value.toString(),
            subtitle: 'Pengajuan calon penulis',
            icon: LucideIcons.inbox,
            iconColor: Colors.orange,
            badgeText: controller.pendingSubmissions.value > 0
                ? '${controller.pendingSubmissions.value} Perlu Review'
                : 'Semua Terbaca',
            badgeColor: controller.pendingSubmissions.value > 0
                ? Colors.orangeAccent
                : const Color(0xFF10B981),
            onTap: controller.navigateToSubmissions,
          ),

          // 3. Penulis Terdaftar
          _buildStatCard(
            title: 'Penulis Terdaftar',
            value: controller.totalAuthors.value.toString(),
            subtitle: 'Kreator & penulis buku',
            icon: LucideIcons.users,
            iconColor: const Color(0xFF3B82F6),
            badgeText: null,
            badgeColor: null,
          ),

          // 4. Promo Aktif
          _buildStatCard(
            title: 'Promo Aktif',
            value: controller.activePromos.value.toString(),
            subtitle: 'Buku berdiskon khusus',
            icon: LucideIcons.tag,
            iconColor: const Color(0xFF10B981),
            badgeText: 'Diskon Berjalan',
            badgeColor: const Color(0xFF10B981),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    String? badgeText,
    Color? badgeColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.borderColor),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                if (badgeText != null && badgeColor != null)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Trend Chart Section (fl_chart)
  Widget _buildTrendChartSection(DashboardController controller) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tren Pertumbuhan & Aktivitas (6 Bulan Terakhir)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Perbandingan tren rilis buku dan pengajuan naskah masuk setiap bulan',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Trend Mode Toggle
              Obx(() {
                final isBooks = controller.trendMode.value == 'books';
                return Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.inputFillColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildToggleButton(
                        title: 'Buku',
                        isSelected: isBooks,
                        icon: LucideIcons.bookOpen,
                        onTap: () => controller.switchTrendMode('books'),
                      ),
                      const SizedBox(width: 4),
                      _buildToggleButton(
                        title: 'Naskah',
                        isSelected: !isBooks,
                        icon: LucideIcons.inbox,
                        onTap: () => controller.switchTrendMode('submissions'),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 28),

          // fl_chart container
          SizedBox(
            height: 240,
            child: Obx(() {
              final isBooks = controller.trendMode.value == 'books';
              final points = isBooks
                  ? controller.bookTrendPoints
                  : controller.submissionTrendPoints;

              if (points.isEmpty) {
                return const Center(
                  child: Text(
                    'Memuat visualisasi data tren...',
                    style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                );
              }

              // Compute max Y
              int maxY = 5;
              for (final p in points) {
                if (p.count > maxY) maxY = p.count;
              }
              final interval = (maxY / 4).ceilToDouble().clamp(1.0, 100.0);

              final spots = points.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.count.toDouble());
              }).toList();

              return LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (val) => FlLine(
                      color: AppTheme.borderColor.withValues(alpha: 0.7),
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: interval,
                        getTitlesWidget: (val, meta) {
                          return Text(
                            val.toInt().toString(),
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (val, meta) {
                          final idx = val.toInt();
                          if (idx >= 0 && idx < points.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                points[idx].monthLabel,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (points.length - 1).toDouble(),
                  minY: 0,
                  maxY: (maxY + interval).toDouble(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: isBooks ? AppTheme.primaryColor : Colors.orange,
                      barWidth: 3.5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                          radius: 5,
                          color: isBooks ? AppTheme.primaryColor : Colors.orange,
                          strokeWidth: 2.5,
                          strokeColor: Colors.white,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            (isBooks ? AppTheme.primaryColor : Colors.orange)
                                .withValues(alpha: 0.25),
                            (isBooks ? AppTheme.primaryColor : Colors.orange)
                                .withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (_) => AppTheme.sidebarColor,
                      tooltipRoundedRadius: 10,
                      tooltipPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((barSpot) {
                          final idx = barSpot.x.toInt();
                          final label = (idx >= 0 && idx < points.length)
                              ? points[idx].monthLabel
                              : '';
                          return LineTooltipItem(
                            '$label: ${barSpot.y.toInt()} ${isBooks ? "Buku" : "Naskah"}',
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String title,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Priority Table Section: 5 Most Recent Unreviewed Submissions
  Widget _buildPriorityTableSection(BuildContext context, DashboardController controller) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        LucideIcons.clock,
                        color: Colors.orangeAccent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Naskah Masuk Perlu Direview Segera',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '5 naskah pengajuan terbaru yang belum ditinjau oleh redaksi',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: controller.navigateToSubmissions,
                icon: const Icon(LucideIcons.arrowRight, size: 16),
                label: const Text('Buka Semua Naskah'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Table Content
          Obx(() {
            final submissions = controller.recentSubmissions;

            if (submissions.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.inputFillColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    const Icon(LucideIcons.checkCircle2, color: Color(0xFF10B981), size: 36),
                    const SizedBox(height: 10),
                    const Text(
                      'Semua Naskah Telah Direview!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tidak ada pengajuan naskah berstatus pending saat ini.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.borderColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: LayoutBuilder(
                  builder: (context, tableConstraints) {
                    const minWidth = 720.0;
                    final width = tableConstraints.maxWidth < minWidth
                        ? minWidth
                        : tableConstraints.maxWidth;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: width,
                        child: Table(
                          columnWidths: const {
                            0: FlexColumnWidth(2.2), // Pengirim
                            1: FlexColumnWidth(2.4), // Email
                            2: FlexColumnWidth(1.8), // Tanggal
                            3: FlexColumnWidth(1.2), // Status
                            4: FixedColumnWidth(145), // Aksi: Lihat Detail
                          },
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          children: [
                    // Table Header
                    TableRow(
                      decoration: const BoxDecoration(color: AppTheme.inputFillColor),
                      children: [
                        _buildTableHeaderCell('PENGIRIM'),
                        _buildTableHeaderCell('EMAIL'),
                        _buildTableHeaderCell('TANGGAL MASUK'),
                        _buildTableHeaderCell('STATUS'),
                        _buildTableHeaderCell('AKSI', align: TextAlign.end),
                      ],
                    ),

                    // Table Rows
                    ...submissions.map((sub) {
                      return TableRow(
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppTheme.borderColor, width: 0.8),
                          ),
                        ),
                        children: [
                          // Pengirim
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                                  child: const Icon(
                                    LucideIcons.user,
                                    size: 14,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    sub.senderName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Email
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Text(
                              sub.email,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Tanggal
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Text(
                              _formatDate(sub.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ),

                          // Status
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.orangeAccent.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: const Text(
                                  'PENDING',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.orangeAccent,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Aksi: Lihat Detail
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _openReviewDialog(context, sub, controller);
                                },
                                icon: const Icon(LucideIcons.eye, size: 13),
                                label: const Text('Lihat Detail'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }),
        ],
      ),
    );
  }

  Widget _buildTableHeaderCell(String text, {TextAlign align = TextAlign.start}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        text,
        textAlign: align,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppTheme.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  void _openReviewDialog(
    BuildContext context,
    Submission submission,
    DashboardController controller,
  ) {
    Get.dialog(
      SubmissionReviewDialog(
        submission: submission,
        onStatusChanged: (newStatus) {
          controller.updateSubmissionStatus(context, submission.id, newStatus);
        },
      ),
      barrierDismissible: false,
    );
  }
}
