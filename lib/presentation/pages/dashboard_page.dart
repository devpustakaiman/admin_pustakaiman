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

  String _formatPrice(num price) {
    if (price <= 0) return '0';
    final priceInt = price.toInt();
    final buffer = StringBuffer();
    final str = priceInt.toString();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildSkeletonLoading();
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
                // 1. Header Bar
                _buildHeader(context, controller),
                const SizedBox(height: 24),

                // 2. Metric Summary Grid (4 Stat Cards)
                _buildMetricSummaryGrid(controller),
                const SizedBox(height: 24),

                // 3. Trend Chart Section
                _buildTrendChartSection(controller),
                const SizedBox(height: 24),

                // 4. Split Activity Feed (2-Column Desktop Layout)
                LayoutBuilder(builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth >= 1024;

                  if (isDesktop) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column (~60%): Recent Pre-Orders & Stock Status
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              _buildRecentPreordersCard(context, controller),
                              const SizedBox(height: 24),
                              _buildStatusStokCard(context, controller),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Right Column (~40%): Recent Submissions & Quick Shortcuts
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              _buildRecentSubmissionsCard(context, controller),
                              const SizedBox(height: 24),
                              _buildQuickShortcutsCard(context, controller),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  // Mobile / Tablet Stacked Layout
                  return Column(
                    children: [
                      _buildRecentPreordersCard(context, controller),
                      const SizedBox(height: 24),
                      _buildStatusStokCard(context, controller),
                      const SizedBox(height: 24),
                      _buildRecentSubmissionsCard(context, controller),
                      const SizedBox(height: 24),
                      _buildQuickShortcutsCard(context, controller),
                    ],
                  );
                }),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ---------------- HEADER ----------------
  Widget _buildHeader(BuildContext context, DashboardController controller) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    final refreshButton = ElevatedButton.icon(
      onPressed: controller.fetchDashboardData,
      icon: const Icon(LucideIcons.refreshCw, size: 16),
      label: const Text('Perbarui Data'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Dashboard Utama',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ringkasan operasional real-time dari "Kelola Data & Toko"',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: refreshButton,
          ),
        ],
      );
    }

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
                'Ringkasan operasional real-time dari "Kelola Data & Toko" dan akselerasi aksi cepat',
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
        refreshButton,
      ],
    );
  }

  // ---------------- METRIC SUMMARY GRID (4 STAT CARDS) ----------------
  Widget _buildMetricSummaryGrid(DashboardController controller) {
    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 640;
      final isWide = constraints.maxWidth >= 1024;
      final crossAxisCount = isWide ? 4 : 2;

      return Obx(() {
        final cards = [
          // Card 1: Pre-Order
          _buildStatCard(
            title: 'Pesanan Pre-Order',
            value: '${controller.totalPreorders.value}',
            subtitle: 'Estimasi Omzet: Rp ${_formatPrice(controller.totalRevenue.value)}',
            icon: LucideIcons.shoppingBag,
            iconColor: const Color(0xFF059669),
            badgeText: controller.pendingPreorders.value > 0
                ? '${controller.pendingPreorders.value} Butuh Verifikasi'
                : 'Semua Terverifikasi',
            badgeColor: controller.pendingPreorders.value > 0 ? Colors.amber[800]! : const Color(0xFF059669),
            onTap: () => controller.navigateToPage(2),
          ),

          // Card 2: Katalog Buku
          _buildStatCard(
            title: 'Katalog Buku',
            value: '${controller.totalBooks.value}',
            subtitle: 'Koleksi judul buku terbit aktif',
            icon: LucideIcons.bookOpen,
            iconColor: AppTheme.primaryColor,
            badgeText: 'Katalog Aktif',
            badgeColor: AppTheme.primaryColor,
            onTap: () => controller.navigateToPage(1),
          ),

          // Card 3: Naskah Masuk
          _buildStatCard(
            title: 'Naskah Masuk',
            value: '${controller.totalSubmissions.value}',
            subtitle: 'Pengajuan karya dari calon penulis',
            icon: LucideIcons.inbox,
            iconColor: Colors.purple[600]!,
            badgeText: controller.pendingSubmissions.value > 0
                ? '${controller.pendingSubmissions.value} Pending Kurasi'
                : 'Semua Terbaca',
            badgeColor: controller.pendingSubmissions.value > 0 ? Colors.orange[800]! : Colors.purple[600]!,
            onTap: () => controller.navigateToPage(3),
          ),

          // Card 4: Penulis & Konten Media
          _buildStatCard(
            title: 'Penulis & Konten Media',
            value: '${controller.totalAuthors.value}',
            subtitle: '${controller.totalArticles.value} Artikel • ${controller.totalVideos.value} Video',
            icon: LucideIcons.users,
            iconColor: Colors.blue[600]!,
            badgeText: 'Mitra & Media',
            badgeColor: Colors.blue[600]!,
            onTap: () => controller.navigateToPage(4),
          ),
        ];

        if (isMobile) {
          return Column(
            children: cards
                .map((card) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: card,
                    ))
                .toList(),
          );
        }

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isWide ? 1.5 : 1.6,
          children: cards,
        );
      });
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: AppTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (badgeText != null && badgeColor != null)
                          Container(
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
                        const SizedBox(width: 6),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                      ],
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
        ),
      ),
    );
  }

  // ---------------- TREND CHART SECTION ----------------
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

          SizedBox(
            height: 220,
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

  // ---------------- LEFT COLUMN: RECENT PRE-ORDERS CARD ----------------
  Widget _buildRecentPreordersCard(BuildContext context, DashboardController controller) {
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
                        color: const Color(0xFF059669).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        LucideIcons.shoppingBag,
                        color: Color(0xFF059669),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pesanan Pre-Order Terbaru',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '5 transaksi pre-order teratas yang baru masuk',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => controller.navigateToPage(2),
                icon: const Icon(LucideIcons.arrowRight, size: 14),
                label: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Obx(() {
            final orders = controller.recentPreorders;

            if (orders.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppTheme.inputFillColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(LucideIcons.shoppingBag, color: Colors.grey, size: 32),
                    const SizedBox(height: 8),
                    const Text(
                      'Belum ada transaksi pre-order terbaru',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const Divider(height: 20),
              itemBuilder: (context, index) {
                final order = orders[index];
                final customerName = order['customer_name'] ?? order['name'] ?? order['pemesan'] ?? 'Pelanggan';
                final bookTitle = order['book_title'] ?? order['title'] ?? order['buku'] ?? 'Buku Pre-Order';
                final price = order['total_price'] ?? order['price'] ?? 0;
                final status = order['status']?.toString() ?? 'Menunggu';

                final isVerified = status.toLowerCase().contains('terverifikasi') || status.toLowerCase().contains('selesai');
                final isPending = status.toLowerCase().contains('menunggu') || status.toLowerCase().contains('pending');

                return Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                      child: const Icon(LucideIcons.user, size: 16, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customerName.toString(),
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            bookTitle.toString(),
                            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rp ${_formatPrice(price is num ? price : int.tryParse(price.toString()) ?? 0)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isVerified
                                ? const Color(0xFF059669).withValues(alpha: 0.1)
                                : (isPending ? Colors.amber.withValues(alpha: 0.12) : Colors.grey.withValues(alpha: 0.1)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isVerified
                                  ? const Color(0xFF059669)
                                  : (isPending ? Colors.amber[900] : Colors.grey[700]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          }),
        ],
      ),
    );
  }

  // ---------------- RIGHT COLUMN: RECENT SUBMISSIONS CARD ----------------
  Widget _buildRecentSubmissionsCard(BuildContext context, DashboardController controller) {
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
                        color: Colors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        LucideIcons.inbox,
                        color: Colors.purple,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Naskah Masuk Terbaru',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '5 pengajuan naskah terbaru',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => controller.navigateToPage(3),
                icon: const Icon(LucideIcons.arrowRight, size: 16),
                tooltip: 'Lihat Semua Naskah',
              ),
            ],
          ),
          const SizedBox(height: 16),

          Obx(() {
            final submissions = controller.recentSubmissions;

            if (submissions.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.inputFillColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(LucideIcons.checkCircle2, color: Color(0xFF059669), size: 30),
                    SizedBox(height: 6),
                    Text(
                      'Semua naskah telah direview!',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: submissions.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final sub = submissions[index];

                return InkWell(
                  onTap: () => _openReviewDialog(context, sub, controller),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sub.senderName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                sub.email,
                                style: TextStyle(fontSize: 11.5, color: Colors.grey[600]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatDate(sub.createdAt),
                              style: const TextStyle(fontSize: 10.5, color: AppTheme.textMuted),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'PENDING',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
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
        ],
      ),
    );
  }

  // ---------------- RIGHT COLUMN: QUICK SHORTCUTS CARD ----------------
  Widget _buildQuickShortcutsCard(BuildContext context, DashboardController controller) {
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
                  LucideIcons.sparkles,
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
                      'Shortcut Cepat Operasional',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Akses langsung modul aksi utama admin',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Column(
            children: [
              _buildShortcutTile(
                title: 'Tambah Buku Baru',
                subtitle: 'Buka dialog entri form produk buku',
                icon: LucideIcons.plusCircle,
                iconColor: AppTheme.primaryColor,
                onTap: () => controller.openNewBookForm(),
              ),
              const SizedBox(height: 12),
              _buildShortcutTile(
                title: 'Tinjau Naskah Masuk',
                subtitle: 'Kelola kurasi berkas naskah penulis',
                icon: LucideIcons.fileText,
                iconColor: Colors.purple,
                onTap: () => controller.navigateToPage(3),
              ),
              const SizedBox(height: 12),
              _buildShortcutTile(
                title: 'Update Pengaturan Hero',
                subtitle: 'Kustomisasi tampilan banner utama publik',
                icon: LucideIcons.layout,
                iconColor: Colors.blue,
                onTap: () => controller.navigateToPage(7),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.inputFillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor.withValues(alpha: 0.6)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- SLEEK SKELETON LOADING ----------------
  Widget _buildSkeletonLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 32,
            width: 220,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 16,
            width: 380,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: List.generate(
              4,
              (_) => Expanded(
                child: Container(
                  height: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.borderColor),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 260,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderColor),
            ),
          ),
        ],
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

  // ---------------- STATUS STOK & BUKU TERPOPULER CARD ----------------
  Widget _buildStatusStokCard(BuildContext context, DashboardController controller) {
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
                  Icons.auto_stories_outlined,
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
                      'Status Stok & Buku Terpopuler',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Pantau stok buku menipis dan buku yang sedang aktif',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Obx(() {
            final books = controller.topBooks;

            if (books.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppTheme.inputFillColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.auto_stories_outlined, color: Colors.grey, size: 32),
                    SizedBox(height: 8),
                    Text(
                      'Belum ada data buku di katalog',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: books.length > 4 ? 4 : books.length,
              separatorBuilder: (_, __) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final book = books[index];
                final title = book['title']?.toString() ?? 'Judul Buku';
                final category = book['category']?.toString() ?? 'Umum';
                final coverUrl = book['cover_url']?.toString() ?? book['coverUrl']?.toString() ?? '';
                final rawPrice = book['price'];
                num price = 0;
                if (rawPrice is num) price = rawPrice;
                if (rawPrice is String) price = num.tryParse(rawPrice) ?? 0;

                final rawStock = book['stock'] ?? book['stok'];
                int stock = 15;
                if (rawStock is num) stock = rawStock.toInt();
                if (rawStock is String) stock = int.tryParse(rawStock) ?? 15;

                final isLowStock = stock < 10;

                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: coverUrl.isNotEmpty
                          ? Image.network(
                              coverUrl,
                              width: 38,
                              height: 50,
                              cacheWidth: 114,
                              cacheHeight: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 38,
                                height: 50,
                                color: Colors.grey[200],
                                child: const Icon(LucideIcons.bookOpen, size: 18, color: Colors.grey),
                              ),
                            )
                          : Container(
                              width: 38,
                              height: 50,
                              color: Colors.grey[200],
                              child: const Icon(LucideIcons.bookOpen, size: 18, color: Colors.grey),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  category,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Rp ${_formatPrice(price)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isLowStock ? const Color(0xFFFFF7ED) : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isLowStock ? const Color(0xFFFFEDD5) : const Color(0xFFA7F3D0),
                        ),
                      ),
                      child: Text(
                        isLowStock ? 'Stok Menipis (< 10)' : 'Stok Tersedia',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isLowStock ? const Color(0xFFC2410C) : const Color(0xFF047857),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => controller.navigateToPage(1),
              icon: const Icon(LucideIcons.arrowRight, size: 14),
              label: const Text(
                'Lihat Semua di Katalog Buku →',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
