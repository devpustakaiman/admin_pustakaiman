import 'package:get/get.dart';
import '../../core/utils/url_helper.dart';

class MainLayoutController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  final RxBool isKelolaDataExpanded = false.obs;
  final RxBool isKelolaHalamanExpanded = false.obs;

  static const List<String> indexToRoute = [
    '/dashboard',               // 0
    '/kelola-data/buku',          // 1
    '/kelola-data/kategori',      // 2
    '/kelola-data/preorder',      // 3
    '/kelola-data/naskah',        // 4
    '/kelola-data/penulis',       // 5
    '/kelola-data/artikel',       // 6
    '/kelola-data/video',         // 7
    '/kelola-halaman/hero',       // 8
    '/kelola-halaman/katalog',    // 9
    '/kelola-halaman/preorder',   // 10
    '/kelola-halaman/tentang-kami',// 11
    '/kelola-halaman/kontak',     // 12
    '/kelola-halaman/kirim-naskah',// 13
    '/kelola-halaman/footer',     // 14
    '/keranjang-sampah',         // 15
  ];

  @override
  void onInit() {
    super.onInit();
    restoreActiveRoute();
    initUrlPopStateListener((path) {
      syncWithRoute(path);
    });
  }

  void restoreActiveRoute() {
    String? currentRoute;
    try {
      final base = Uri.base;
      if (base.fragment.isNotEmpty) {
        currentRoute = base.fragment;
      } else if (base.path.isNotEmpty && base.path != '/') {
        currentRoute = base.path;
      }
    } catch (_) {}

    currentRoute ??= getSavedRoute();

    if (currentRoute != null && currentRoute.isNotEmpty) {
      syncWithRoute(currentRoute);
    } else {
      updateIndexAndExpansion(0);
    }
  }

  void syncWithRoute(String route) {
    final cleanRoute = route.split('?').first;
    final index = routeToIndex(cleanRoute);
    updateIndexAndExpansion(index);
  }

  int routeToIndex(String route) {
    final cleanRoute = route.split('?').first;
    switch (cleanRoute) {
      case '/dashboard':
        return 0;
      case '/kelola-data/buku':
      case '/book-management':
        return 1;
      case '/kelola-data/kategori':
        return 2;
      case '/kelola-data/preorder':
        return 3;
      case '/kelola-data/naskah':
      case '/submission-management':
        return 4;
      case '/kelola-data/penulis':
        return 5;
      case '/kelola-data/artikel':
        return 6;
      case '/kelola-data/video':
        return 7;
      case '/kelola-halaman/hero':
        return 8;
      case '/kelola-halaman/katalog':
        return 9;
      case '/kelola-halaman/preorder':
        return 10;
      case '/kelola-halaman/tentang-kami':
        return 11;
      case '/kelola-halaman/kontak':
        return 12;
      case '/kelola-halaman/kirim-naskah':
        return 13;
      case '/kelola-halaman/footer':
        return 14;
      case '/keranjang-sampah':
        return 15;
      default:
        return 0;
    }
  }

  void updateIndexAndExpansion(int index) {
    selectedIndex.value = index;
    if (index >= 1 && index <= 7) {
      isKelolaDataExpanded.value = true;
      isKelolaHalamanExpanded.value = false;
    } else if (index >= 8 && index <= 14) {
      isKelolaDataExpanded.value = false;
      isKelolaHalamanExpanded.value = true;
    } else {
      isKelolaDataExpanded.value = false;
      isKelolaHalamanExpanded.value = false;
    }
  }

  void changePage(int index, {bool updateUrl = true}) {
    updateIndexAndExpansion(index);
    if (index >= 0 && index < indexToRoute.length) {
      final targetRoute = indexToRoute[index];
      if (updateUrl) {
        updateBrowserUrl(targetRoute);
      }
    }
  }

  void toggleKelolaData() {
    isKelolaDataExpanded.value = !isKelolaDataExpanded.value;
    if (isKelolaDataExpanded.value) {
      isKelolaHalamanExpanded.value = false;
    }
  }

  void toggleKelolaHalaman() {
    isKelolaHalamanExpanded.value = !isKelolaHalamanExpanded.value;
    if (isKelolaHalamanExpanded.value) {
      isKelolaDataExpanded.value = false;
    }
  }
}
