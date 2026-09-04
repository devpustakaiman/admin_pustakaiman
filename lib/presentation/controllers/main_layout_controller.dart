import 'package:get/get.dart';

class MainLayoutController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  final RxBool isKelolaDataExpanded = true.obs;
  final RxBool isKelolaHalamanExpanded = false.obs;

  void changePage(int index) {
    selectedIndex.value = index;
    if (index >= 1 && index <= 6) {
      isKelolaDataExpanded.value = true;
      isKelolaHalamanExpanded.value = false;
    } else if (index >= 7 && index <= 12) {
      isKelolaHalamanExpanded.value = true;
      isKelolaDataExpanded.value = false;
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
