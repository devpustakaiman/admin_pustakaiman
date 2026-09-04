import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/datasources/supabase_remote_data_source.dart';
import '../../data/models/preorder_model.dart';
import '../../data/models/bank_account_model.dart';
import '../../core/utils/app_toast.dart';

class PreorderController extends GetxController {
  final SupabaseRemoteDataSource remoteDataSource;

  PreorderController({SupabaseRemoteDataSource? dataSource})
      : remoteDataSource = dataSource ?? Get.find<SupabaseRemoteDataSource>();

  final emailController = TextEditingController();
  final searchController = TextEditingController();

  final RxList<PreorderModel> preorders = <PreorderModel>[].obs;
  final RxList<PreorderModel> filteredPreorders = <PreorderModel>[].obs;
  final RxList<BankAccountModel> bankAccounts = <BankAccountModel>[].obs;

  final RxBool isLoading = true.obs;
  final RxBool isSavingEmail = false.obs;
  final RxBool isSavingBankAccount = false.obs;
  final RxString selectedStatusFilter = 'semua'.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadData();
    });
  }

  @override
  void onClose() {
    emailController.dispose();
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        remoteDataSource.getPreorderNotificationEmail(),
        remoteDataSource.getPreorders(),
        remoteDataSource.getBankAccounts(),
      ]);

      final savedEmail = results[0] as String;
      final rawPreorders = results[1] as List<Map<String, dynamic>>;
      final rawBankAccounts = results[2] as List<Map<String, dynamic>>;

      emailController.text = savedEmail;
      preorders.value = rawPreorders.map((json) => PreorderModel.fromJson(json)).toList();
      bankAccounts.value = rawBankAccounts.map((json) => BankAccountModel.fromJson(json)).toList();
      applyFilters();
    } catch (e) {
      if (Get.context != null) {
        AppToast.showError(Get.context!, 'Gagal memuat data pre-order: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void filterByStatus(String status) {
    selectedStatusFilter.value = status;
    applyFilters();
  }

  void filterByQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void applyFilters() {
    List<PreorderModel> result = List.from(preorders);

    final status = selectedStatusFilter.value.toLowerCase();
    if (status != 'semua') {
      result = result.where((p) => p.status.toLowerCase() == status).toList();
    }

    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((p) {
        return p.customerName.toLowerCase().contains(query) ||
            p.email.toLowerCase().contains(query) ||
            p.phone.toLowerCase().contains(query) ||
            p.bookTitle.toLowerCase().contains(query);
      }).toList();
    }

    filteredPreorders.value = result;
  }

  Future<void> saveNotificationEmail() async {
    final newEmail = emailController.text.trim();
    if (newEmail.isEmpty || !GetUtils.isEmail(newEmail)) {
      if (Get.context != null) {
        AppToast.showError(Get.context!, 'Masukkan alamat email yang valid');
      }
      return;
    }

    isSavingEmail.value = true;
    try {
      await remoteDataSource.updatePreorderNotificationEmail(newEmail);
      if (Get.context != null) {
        AppToast.showSuccess(Get.context!, 'Email penerima notifikasi berhasil diperbarui');
      }
    } catch (e) {
      if (Get.context != null) {
        AppToast.showError(Get.context!, 'Gagal memperbarui email: $e');
      }
    } finally {
      isSavingEmail.value = false;
    }
  }

  Future<void> updateStatus(String preorderId, String newStatus) async {
    try {
      await remoteDataSource.updatePreorderStatus(preorderId, newStatus);

      final index = preorders.indexWhere((p) => p.id == preorderId);
      if (index != -1) {
        preorders[index] = preorders[index].copyWith(status: newStatus);
        applyFilters();
      }

      if (Get.context != null) {
        AppToast.showSuccess(
          Get.context!,
          'Status pemesanan berhasil diubah menjadi "${newStatus.toUpperCase()}"',
        );
      }
    } catch (e) {
      if (Get.context != null) {
        AppToast.showError(Get.context!, 'Gagal memperbarui status: $e');
      }
    }
  }

  Future<void> openWhatsApp(String rawPhone) async {
    if (rawPhone.trim().isEmpty) {
      if (Get.context != null) {
        AppToast.showError(Get.context!, 'Nomor telepon/WhatsApp tidak tersedia');
      }
      return;
    }

    String cleanDigits = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (cleanDigits.startsWith('0')) {
      cleanDigits = '62${cleanDigits.substring(1)}';
    } else if (!cleanDigits.startsWith('62')) {
      cleanDigits = '62$cleanDigits';
    }

    final url = Uri.parse('https://wa.me/$cleanDigits');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (Get.context != null) {
        AppToast.showError(Get.context!, 'Tidak dapat membuka tautan WhatsApp');
      }
    }
  }

  Future<void> deletePreorder(PreorderModel item) async {
    try {
      await remoteDataSource.deletePreorder(item.id);
      preorders.removeWhere((p) => p.id == item.id);
      applyFilters();

      if (Get.context != null) {
        AppToast.showSuccess(
          Get.context!,
          'Pesanan pre-order berhasil dipindahkan ke Keranjang Sampah',
        );
      }
    } catch (e) {
      if (Get.context != null) {
        AppToast.showError(Get.context!, 'Gagal menghapus pesanan: $e');
      }
    }
  }

  Future<void> saveBankAccount(BankAccountModel account) async {
    isSavingBankAccount.value = true;
    try {
      final updatedList = List<BankAccountModel>.from(bankAccounts);
      final index = updatedList.indexWhere((a) => a.id == account.id);
      final bool isEdit = index != -1;

      if (isEdit) {
        updatedList[index] = account;
      } else {
        updatedList.add(account);
      }

      final payload = updatedList.map((a) => a.toJson()).toList();
      await remoteDataSource.updateBankAccounts(payload);

      bankAccounts.value = updatedList;

      if (Get.context != null) {
        AppToast.showSuccess(
          Get.context!,
          isEdit
              ? 'Rekening bank ${account.bankName} berhasil diperbarui'
              : 'Rekening bank ${account.bankName} berhasil ditambahkan',
        );
      }
    } catch (e) {
      if (Get.context != null) {
        AppToast.showError(Get.context!, 'Gagal menyimpan rekening bank: $e');
      }
    } finally {
      isSavingBankAccount.value = false;
    }
  }

  Future<void> deleteBankAccount(String accountId) async {
    isSavingBankAccount.value = true;
    try {
      final accountToDelete = bankAccounts.firstWhereOrNull((a) => a.id == accountId);
      final updatedList = bankAccounts.where((a) => a.id != accountId).toList();
      final payload = updatedList.map((a) => a.toJson()).toList();

      await remoteDataSource.updateBankAccounts(payload);
      bankAccounts.value = updatedList;

      if (Get.context != null) {
        AppToast.showSuccess(
          Get.context!,
          accountToDelete != null
              ? 'Rekening bank ${accountToDelete.bankName} berhasil dihapus'
              : 'Rekening bank berhasil dihapus',
        );
      }
    } catch (e) {
      if (Get.context != null) {
        AppToast.showError(Get.context!, 'Gagal menghapus rekening bank: $e');
      }
    } finally {
      isSavingBankAccount.value = false;
    }
  }
}


