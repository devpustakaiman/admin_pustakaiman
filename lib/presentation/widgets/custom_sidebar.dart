import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../controllers/main_layout_controller.dart';

class CustomSidebar extends StatefulWidget {
  const CustomSidebar({super.key});

  @override
  State<CustomSidebar> createState() => _CustomSidebarState();
}

class _CustomSidebarState extends State<CustomSidebar> {
  late final ScrollController _sidebarScrollController;

  @override
  void initState() {
    super.initState();
    _sidebarScrollController = ScrollController();
  }

  @override
  void dispose() {
    _sidebarScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainLayoutController>();

    final dashboardItem = _NavItemData('Dashboard', LucideIcons.layoutDashboard, 0);

    final kelolaDataSubItems = [
      _NavItemData('Katalog Buku', LucideIcons.bookOpen, 1),
      _NavItemData('Pesanan Pre-Order', LucideIcons.shoppingBag, 2),
      _NavItemData('Naskah Masuk', LucideIcons.inbox, 3),
      _NavItemData('Data Penulis', LucideIcons.users, 4),
      _NavItemData('Artikel & Berita', LucideIcons.fileText, 5),
      _NavItemData('Video Media', LucideIcons.video, 6),
    ];

    final kelolaHalamanSubItems = [
      _NavItemData('Beranda & Hero', LucideIcons.home, 7),
      _NavItemData('Katalog Buku', Icons.auto_stories_outlined, 8),
      _NavItemData('Pre-Order', LucideIcons.receipt, 9),
      _NavItemData('Tentang Kami', LucideIcons.info, 10),
      _NavItemData('Kontak & Layanan', LucideIcons.headphones, 11),
      _NavItemData('Kirim Naskah', LucideIcons.bookOpen, 12),
    ];

    final bottomNavItems = [
      _NavItemData('Keranjang Sampah', LucideIcons.trash2, 13),
    ];

    Widget buildNavItem(_NavItemData item, {bool isSubItem = false}) {
      return Obx(() {
        final selectedIndex = controller.selectedIndex.value;
        final isSelected = selectedIndex == item.index;

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: isSubItem ? const EdgeInsets.only(left: 14) : EdgeInsets.zero,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                controller.changePage(item.index);
                if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                  Navigator.of(context).pop();
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withValues(alpha: 0.18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: isSelected
                      ? Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          width: 1,
                        )
                      : Border.all(color: Colors.transparent),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: isSubItem ? 18 : 20,
                      color: isSelected
                          ? AppTheme.primaryLight
                          : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF94A3B8),
                          fontSize: isSubItem ? 13 : 14,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      });
    }

    Widget buildExpandableTile({
      required String title,
      required IconData icon,
      required RxBool isExpandedRx,
      required int minRangeIndex,
      required int maxRangeIndex,
      required VoidCallback onTap,
      required List<_NavItemData> subItems,
    }) {
      return Obx(() {
        final isExpanded = isExpandedRx.value;
        final selectedIndex = controller.selectedIndex.value;
        final isGroupSelected = selectedIndex >= minRangeIndex && selectedIndex <= maxRangeIndex;

        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          child: Column(
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isGroupSelected && !isExpanded
                          ? AppTheme.primaryColor.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          icon,
                          size: 20,
                          color: isGroupSelected
                              ? AppTheme.primaryLight
                              : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: isGroupSelected
                                  ? Colors.white
                                  : const Color(0xFF94A3B8),
                              fontSize: 14,
                              fontWeight: isGroupSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(
                          isExpanded
                              ? LucideIcons.chevronDown
                              : LucideIcons.chevronRight,
                          size: 16,
                          color: const Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    children: subItems
                        .map((subItem) => buildNavItem(subItem, isSubItem: true))
                        .toList(),
                  ),
                ),
            ],
          ),
        );
      });
    }

    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: AppTheme.sidebarColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Logo & Branding
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 6,
                        spreadRadius: 0,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    LucideIcons.shieldCheck,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PUSTAKA ILMAN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Admin Portal',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: Color(0xFF1E293B), height: 1),
          ),
          const SizedBox(height: 20),

          // Section Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'NAVIGASI UTAMA',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          // Menu items list with visible Scrollbar (No global Obx rebuilds)
          Expanded(
            child: Theme(
              data: Theme.of(context).copyWith(
                scrollbarTheme: ScrollbarThemeData(
                  thumbColor: WidgetStateProperty.all(const Color(0xFF475569)),
                  trackColor: WidgetStateProperty.all(const Color(0xFF1E293B)),
                  thickness: WidgetStateProperty.all(4.0),
                  radius: const Radius.circular(4),
                ),
              ),
              child: Scrollbar(
                controller: _sidebarScrollController,
                thumbVisibility: true,
                trackVisibility: true,
                interactive: true,
                child: ListView(
                  controller: _sidebarScrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    // Dashboard Item
                    buildNavItem(dashboardItem),

                    // Kelola Data & Toko Expandable Tile
                    buildExpandableTile(
                      title: 'Kelola Data & Toko',
                      icon: LucideIcons.boxes,
                      isExpandedRx: controller.isKelolaDataExpanded,
                      minRangeIndex: 1,
                      maxRangeIndex: 6,
                      onTap: () => controller.toggleKelolaData(),
                      subItems: kelolaDataSubItems,
                    ),

                    // Kelola Halaman Expandable Tile
                    buildExpandableTile(
                      title: 'Kelola Halaman',
                      icon: LucideIcons.layers,
                      isExpandedRx: controller.isKelolaHalamanExpanded,
                      minRangeIndex: 7,
                      maxRangeIndex: 12,
                      onTap: () => controller.toggleKelolaHalaman(),
                      subItems: kelolaHalamanSubItems,
                    ),

                    // Bottom Items (Keranjang Sampah)
                    ...bottomNavItems.map((item) => buildNavItem(item)),
                  ],
                ),
              ),
            ),
          ),

          // User info and Logout section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Divider(color: Color(0xFF1E293B), height: 1),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.primaryColor,
                    child: Icon(LucideIcons.user, size: 18, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Supabase.instance.client.auth.currentUser?.email ??
                              'Administrator',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Online',
                          style: TextStyle(
                            color: AppTheme.primaryLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.logOut, size: 18, color: Colors.redAccent),
                    tooltip: 'Keluar Portal',
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                      Get.offAllNamed(AppRoutes.login);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItemData {
  final String title;
  final IconData icon;
  final int index;

  _NavItemData(this.title, this.icon, this.index);
}
