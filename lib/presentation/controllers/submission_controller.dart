import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/submission.dart';
import '../../domain/repositories/submission_repository.dart';
import '../../domain/usecases/get_submissions_usecase.dart';

class SubmissionController extends GetxController {
  final GetSubmissionsUseCase getSubmissionsUseCase;
  final SubmissionRepository submissionRepository;

  SubmissionController({
    required this.getSubmissionsUseCase,
    SubmissionRepository? repository,
  }) : submissionRepository = repository ?? Get.find<SubmissionRepository>();

  final RxList<Submission> submissions = <Submission>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSubmissions();
  }

  Future<void> fetchSubmissions() async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await getSubmissionsUseCase.call();
    result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
      },
      (data) {
        submissions.assignAll(data);
        isLoading.value = false;
      },
    );
  }

  Future<void> deleteSubmission(String id) async {
    Get.defaultDialog(
      title: 'Hapus Submission',
      middleText: 'Apakah Anda yakin ingin menghapus submission ini?',
      textCancel: 'Batal',
      textConfirm: 'Hapus',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        isLoading.value = true;
        final result = await submissionRepository.deleteSubmission(id);
        result.fold(
          (failure) {
            Get.snackbar(
              'Error',
              'Gagal menghapus submission: ${failure.message}',
              snackPosition: SnackPosition.BOTTOM,
            );
            isLoading.value = false;
          },
          (_) async {
            Get.snackbar(
              'Sukses',
              'Submission berhasil dihapus',
              snackPosition: SnackPosition.BOTTOM,
            );
            await fetchSubmissions();
          },
        );
      },
    );
  }

  Future<void> updateStatus(String id, String newStatus) async {
    isLoading.value = true;
    final result = await submissionRepository.updateSubmissionStatus(id, newStatus);
    result.fold(
      (failure) {
        Get.snackbar(
          'Error',
          'Gagal memperbarui status: ${failure.message}',
          snackPosition: SnackPosition.BOTTOM,
        );
        isLoading.value = false;
      },
      (_) async {
        Get.snackbar(
          'Sukses',
          'Status submission diperbarui menjadi $newStatus',
          snackPosition: SnackPosition.BOTTOM,
        );
        await fetchSubmissions();
      },
    );
  }

  Future<void> previewPdf(String url) async {
    if (url.trim().isEmpty) {
      Get.snackbar(
        'Peringatan',
        'URL dokumen PDF tidak tersedia',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(
        uri,
        webOnlyWindowName: '_blank',
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal membuka preview PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> downloadPdf(String url) async {
    if (url.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'URL dokumen PDF tidak tersedia',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal membuka PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
