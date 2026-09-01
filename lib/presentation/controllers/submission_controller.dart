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
  final RxString statusFilter = 'Semua Status'.obs;
  final RxString sortBy = 'date'.obs; // 'date', 'name'
  final RxBool isAscending = false.obs; // false = newest first by default

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

  Future<bool> deleteSubmission(String id) async {
    isLoading.value = true;
    errorMessage.value = '';
    final result = await submissionRepository.deleteSubmission(id);
    return result.fold(
      (failure) {
        errorMessage.value = failure.message;
        isLoading.value = false;
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
        return false;
      },
      (_) async {
        await fetchSubmissions();
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
