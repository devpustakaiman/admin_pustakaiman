import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/preorder_model.dart';
import '../controllers/preorder_controller.dart';

class PreorderManagementPage extends StatefulWidget {
  const PreorderManagementPage({super.key});

  @override
  State<PreorderManagementPage> createState() => _PreorderManagementPageState();
}

class _PreorderManagementPageState extends State<PreorderManagementPage> {
  late final ScrollController _horizontalScrollController;

  @override
  void initState() {
    super.initState();
    _horizontalScrollController = ScrollController();
  }

  @override
  void dispose() {
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PreorderController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.loadData,
          color: const Color(0xFF0F766E),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Page Title
                _buildHeader(controller),
                const SizedBox(height: 24),

                // Pre-Order Orders Section & Filters
                _buildTableControls(controller),
                const SizedBox(height: 16),

                // Pre-Order Orders Table
                _buildPreordersTable(context, controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(PreorderController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFCCFBF1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF99F6E4)),
                        ),
                        child: const Icon(
                          LucideIcons.shoppingBag,
                          color: Color(0xFF0F766E),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Flexible(
                        child: Text(
                          'Manajemen Pre-Order Buku',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Kelola pesanan pre-order buku, verifikasi bukti pembayaran, dan kirim konfirmasi WhatsApp.',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              onPressed: controller.loadData,
              icon: const Icon(LucideIcons.refreshCw, color: Color(0xFF64748B), size: 20),
              tooltip: 'Segarkan Data',
            ),
          ],
        );
      },
    );
  }

  // ---------------- TABLE CONTROLS (SEARCH & WRAP FILTERS) ----------------
  Widget _buildTableControls(PreorderController controller) {
    final statusList = ['semua', 'pending', 'verified', 'shipped', 'cancelled'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Input
        TextField(
          controller: controller.searchController,
          onChanged: controller.filterByQuery,
          style: const TextStyle(color: Color(0xFF0F172A), fontSize: 14),
          cursorColor: const Color(0xFF0F766E),
          decoration: InputDecoration(
            hintText: 'Cari pemesan, email, WA, atau judul buku...',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(LucideIcons.search, color: Color(0xFF64748B), size: 18),
            suffixIcon: controller.searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(LucideIcons.x, color: Color(0xFF64748B), size: 16),
                    onPressed: () {
                      controller.searchController.clear();
                      controller.filterByQuery('');
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Wrap Filter Chips for clean responsiveness on all screen widths
        Obx(() {
          final selected = controller.selectedStatusFilter.value;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: statusList.map((status) {
              final isSelected = selected == status;
              String label;
              switch (status) {
                case 'pending':
                  label = 'Pending';
                  break;
                case 'verified':
                  label = 'Verified (Terverifikasi)';
                  break;
                case 'shipped':
                  label = 'Shipped (Dikirim)';
                  break;
                case 'cancelled':
                  label = 'Cancelled (Batal)';
                  break;
                default:
                  label = 'Semua Status';
              }

              return ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (val) {
                  if (val) controller.filterByStatus(status);
                },
                selectedColor: const Color(0xFFF0FDFA),
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFF0F766E) : const Color(0xFF475569),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF14B8A6) : const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  // ---------------- 3. PRE-ORDERS ORDERS TABLE ----------------
  Widget _buildPreordersTable(BuildContext context, PreorderController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Container(
          height: 300,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF0F766E)),
              SizedBox(height: 16),
              Text(
                'Memuat daftar pesanan pre-order...',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
            ],
          ),
        );
      }

      final list = controller.filteredPreorders;
      if (list.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              const Icon(LucideIcons.inbox, color: Color(0xFF94A3B8), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Belum Ada Pesanan Pre-Order',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                controller.searchQuery.value.isNotEmpty || controller.selectedStatusFilter.value != 'semua'
                    ? 'Tidak ada pesanan yang sesuai dengan filter.'
                    : 'Pesanan pre-order yang dikirim oleh pengguna akan muncul di sini.',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
            ],
          ),
        );
      }

      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final targetWidth = math.max(constraints.maxWidth, 1100.0);

            return ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                },
              ),
              child: Scrollbar(
                controller: _horizontalScrollController,
                thumbVisibility: true,
                trackVisibility: true,
                interactive: true,
                child: SingleChildScrollView(
                  controller: _horizontalScrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: targetWidth),
                    child: DataTable(
                      horizontalMargin: 20,
                      columnSpacing: (targetWidth > 1200) ? ((targetWidth - 1050) / 9) : 20,
                      headingRowHeight: 48,
                      dataRowMaxHeight: 70,
                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                      columns: const [
                        DataColumn(
                          label: Text(
                            'TANGGAL',
                            style: TextStyle(color: Color(0xFF475569), fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'NAMA PEMESAN',
                            style: TextStyle(color: Color(0xFF475569), fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'EMAIL',
                            style: TextStyle(color: Color(0xFF475569), fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'NO HP / WHATSAPP',
                            style: TextStyle(color: Color(0xFF475569), fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'JUDUL BUKU',
                            style: TextStyle(color: Color(0xFF475569), fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'KUANTITI',
                            style: TextStyle(color: Color(0xFF475569), fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'BUKTI TRANSFER',
                            style: TextStyle(color: Color(0xFF475569), fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'STATUS PESANAN',
                            style: TextStyle(color: Color(0xFF475569), fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'AKSI',
                            style: TextStyle(color: Color(0xFF475569), fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                      rows: list.map((item) => _buildRow(context, item, controller)).toList(),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  DataRow _buildRow(BuildContext context, PreorderModel item, PreorderController controller) {
    final dateStr =
        '${item.createdAt.day.toString().padLeft(2, '0')}/${item.createdAt.month.toString().padLeft(2, '0')}/${item.createdAt.year} ${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}';

    return DataRow(
      cells: [
        // 1. Tanggal
        DataCell(
          Text(
            dateStr,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
        ),

        // 2. Nama Pemesan
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text(
              item.customerName,
              style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600, fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),

        // 3. Email
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 180),
            child: SelectableText(
              item.email,
              style: const TextStyle(color: Color(0xFF334155), fontSize: 13),
            ),
          ),
        ),

        // 4. No HP/WhatsApp (clickable direct link to wa.me)
        DataCell(
          InkWell(
            onTap: () => controller.openWhatsApp(item.phone),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1FAE5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.phone, color: Color(0xFF059669), size: 14),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.phone.isNotEmpty ? item.phone : '-',
                    style: const TextStyle(
                      color: Color(0xFF059669),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(LucideIcons.externalLink, color: Color(0xFF059669), size: 12),
                ],
              ),
            ),
          ),
        ),

        // 5. Judul Buku
        DataCell(
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 240),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: Text(
                item.bookTitle,
                style: const TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.w600, fontSize: 12),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
        ),

        // 6. Kuantiti
        DataCell(
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                '${item.quantity}x',
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),

        // 7. Bukti Transfer (Thumbnail with Modal Preview)
        DataCell(
          item.paymentProofUrl.isNotEmpty
              ? InkWell(
                  onTap: () => _showProofPreviewModal(context, item),
                  child: Tooltip(
                    message: 'Klik untuk perbesar bukti transfer',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        width: 44,
                        height: 44,
                        color: const Color(0xFFF1F5F9),
                        child: CachedNetworkImage(
                          imageUrl: item.paymentProofUrl,
                          fit: BoxFit.cover,
                          memCacheWidth: 120,
                          memCacheHeight: 120,
                          placeholder: (context, url) => const Center(
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0F766E)),
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            LucideIcons.image,
                            color: Color(0xFF94A3B8),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Tidak Ada',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                  ),
                ),
        ),

        // 8. Status Dropdown Changer
        DataCell(
          _buildStatusDropdown(context, item, controller),
        ),

        // 9. Aksi (Delete button)
        DataCell(
          IconButton(
            icon: const Icon(LucideIcons.trash2, color: Color(0xFFEF4444), size: 18),
            tooltip: 'Hapus Pesanan',
            onPressed: () => _confirmDeletePreorder(context, item, controller),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(BuildContext context, PreorderModel item, PreorderController controller) {
    Color bg;
    Color fg;
    Color border;

    switch (item.status.toLowerCase()) {
      case 'pending':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        border = const Color(0xFFFCD34D);
        break;
      case 'verified':
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0284C7);
        border = const Color(0xFF7DD3FC);
        break;
      case 'shipped':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF059669);
        border = const Color(0xFF6EE7B7);
        break;
      case 'cancelled':
        bg = const Color(0xFFFFE4E6);
        fg = const Color(0xFFE11D48);
        border = const Color(0xFFFDA4AF);
        break;
      default:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        border = const Color(0xFFFCD34D);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: item.status.toLowerCase(),
          dropdownColor: Colors.white,
          icon: Icon(LucideIcons.chevronDown, color: fg, size: 16),
          style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12),
          onChanged: (String? newStatus) {
            if (newStatus != null && newStatus != item.status.toLowerCase()) {
              controller.updateStatus(item.id, newStatus);
            }
          },
          items: const [
            DropdownMenuItem(
              value: 'pending',
              child: Row(
                children: [
                  Icon(LucideIcons.clock, color: Color(0xFFD97706), size: 14),
                  SizedBox(width: 8),
                  Text('Pending', style: TextStyle(color: Color(0xFFD97706))),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'verified',
              child: Row(
                children: [
                  Icon(LucideIcons.checkCircle2, color: Color(0xFF0284C7), size: 14),
                  SizedBox(width: 8),
                  Text('Verified', style: TextStyle(color: Color(0xFF0284C7))),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'shipped',
              child: Row(
                children: [
                  Icon(LucideIcons.truck, color: Color(0xFF059669), size: 14),
                  SizedBox(width: 8),
                  Text('Shipped', style: TextStyle(color: Color(0xFF059669))),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'cancelled',
              child: Row(
                children: [
                  Icon(LucideIcons.xCircle, color: Color(0xFFE11D48), size: 14),
                  SizedBox(width: 8),
                  Text('Cancelled', style: TextStyle(color: Color(0xFFE11D48))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProofPreviewModal(BuildContext context, PreorderModel item) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                            'Bukti Pembayaran / Transfer',
                            style: TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pemesan: ${item.customerName} (${item.bookTitle})',
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, color: Color(0xFF64748B)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(color: Color(0xFFE2E8F0), height: 24),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: InteractiveViewer(
                      child: CachedNetworkImage(
                        imageUrl: item.paymentProofUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(color: Color(0xFF0F766E)),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(LucideIcons.alertTriangle, color: Color(0xFFE11D48), size: 36),
                              SizedBox(height: 8),
                              Text('Gagal memuat gambar bukti transfer', style: TextStyle(color: Color(0xFF64748B))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(LucideIcons.check),
                    label: const Text('Tutup Preview'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeletePreorder(BuildContext context, PreorderModel item, PreorderController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(LucideIcons.alertTriangle, color: Color(0xFFEF4444), size: 22),
            SizedBox(width: 10),
            Text(
              'Hapus Pesanan',
              style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus pesanan pre-order dari "${item.customerName}"?',
          style: const TextStyle(color: Color(0xFF475569), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.deletePreorder(item);
            },
            icon: const Icon(LucideIcons.trash2, size: 16),
            label: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
