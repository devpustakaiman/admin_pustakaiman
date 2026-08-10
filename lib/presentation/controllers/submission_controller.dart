import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/submission.dart';
import '../../domain/usecases/get_submissions_usecase.dart';

class SubmissionController extends GetxController {
  final GetSubmissionsUseCase getSubmissionsUseCase;

  SubmissionController({required this.getSubmissionsUseCase});

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
        // Fallback try to launch anyway if canLaunchUrl check fails on web/desktop
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
