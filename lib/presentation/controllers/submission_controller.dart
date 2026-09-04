import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/submission.dart';
import '../../domain/repositories/submission_repository.dart';
import '../../domain/usecases/get_submissions_usecase.dart';
import '../../core/utils/app_toast.dart';

class SubmissionController extends GetxController {
  final GetSubmissionsUseCase getSubmissionsUseCase;
  final SubmissionRepository submissionRepository;

  SubmissionController({
    required this.getSubmissionsUseCase,
    SubmissionRepository? repository,
  }) : submissionRepository = repository ?? Get.find<SubmissionRepository>();

  final RxList<Submission> submissions = <Submission>[].obs;
  final RxString statusFilter = 'Semua Status'.obs;
  final RxString sortBy = 'date'.obs; // 'date', 'name'
  final RxBool isAscending = false.obs; // false = newest first by default

  final RxInt currentPage = 0.obs;
  final RxInt totalSubmissionsCount = 0.obs;
  final int pageSize = 15;

  List<Submission> get filteredSubmissions {
    List<Submission> result = List.from(submissions);

    if (statusFilter.value != 'Semua Status') {
      final targetStatus = statusFilter.value.toLowerCase();
      result = result.where((sub) => sub.status.toLowerCase() == targetStatus).toList();
    }

    result.sort((a, b) {
      int comparison = 0;
      if (sortBy.value == 'name') {
        comparison = a.senderName.toLowerCase().compareTo(b.senderName.toLowerCase());
      } else {
        comparison = a.createdAt.compareTo(b.createdAt);
      }
      return isAscending.value ? comparison : -comparison;
    });

    return result;
  }

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchSubmissions();
    });
  }

  Future<void> fetchSubmissions({int? page}) async {
    if (page != null) currentPage.value = page;
    isLoading.value = true;
    errorMessage.value = '';

    // Server-side exact count
    final countRes = await submissionRepository.getSubmissionsCount(
      status: statusFilter.value == 'Semua Status' ? null : statusFilter.value,
    );
    countRes.fold((_) {}, (cnt) => totalSubmissionsCount.value = cnt);

    // 15-item lazy loading / pagination
    final result = await getSubmissionsUseCase.call(
      page: currentPage.value,
      pageSize: pageSize,
      status: statusFilter.value == 'Semua Status' ? null : statusFilter.value,
    );
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

  void nextPage() {
    if ((currentPage.value + 1) * pageSize < totalSubmissionsCount.value) {
      fetchSubmissions(page: currentPage.value + 1);
    }
  }

  void prevPage() {
    if (currentPage.value > 0) {
      fetchSubmissions(page: currentPage.value - 1);
    }
  }

  Future<bool> deleteSubmission(String id) async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await submissionRepository.deleteSubmission(id);
    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        if (Get.context != null) {
          AppToast.showError(Get.context!, 'Gagal memindahkan naskah: ${failure.message}');
        }
        return false;
      },
      (_) async {
        await fetchSubmissions();
        return true;
      },
    );
  }

  Future<bool> updateStatus(String id, String newStatus) async {
    isLoading.value = true;
    final result = await submissionRepository.updateSubmissionStatus(id, newStatus);
    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
        if (Get.context != null) {
          AppToast.showError(Get.context!, 'Gagal mengubah status naskah: ${failure.message}');
        }
        return false;
      },
      (_) async {
        await fetchSubmissions();
        if (Get.context != null) {
          AppToast.showSuccess(
            Get.context!,
            'Status naskah berhasil diubah menjadi "${newStatus.toUpperCase()}"',
          );
        }
        return true;
      },
    );
  }

  Future<void> previewPdf(String url) async {
    if (url.trim().isEmpty) return;
    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(
        uri,
        webOnlyWindowName: '_blank',
      );
    } catch (_) {}
  }

  Future<void> downloadPdf(String url) async {
    if (url.isEmpty) return;
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (_) {}
  }
}
