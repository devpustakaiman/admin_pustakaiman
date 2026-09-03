import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/app_toast.dart';
import '../../data/datasources/supabase_remote_data_source.dart';
import '../../data/models/submission_model.dart';
import '../../domain/entities/submission.dart';
import '../../domain/repositories/submission_repository.dart';
import 'main_layout_controller.dart';

class DashboardMonthlyPoint {
  final String monthLabel;
  final int count;

  DashboardMonthlyPoint({required this.monthLabel, required this.count});
}

class DashboardController extends GetxController {
  final SupabaseRemoteDataSource remoteDataSource;
  final SubmissionRepository submissionRepository;

  DashboardController({
    SupabaseRemoteDataSource? dataSource,
    SubmissionRepository? subRepository,
  })  : remoteDataSource = dataSource ?? Get.find<SupabaseRemoteDataSource>(),
        submissionRepository = subRepository ?? Get.find<SubmissionRepository>();

  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  // Stat Metrics (Exact Server-Side Counts)
  final RxInt totalBooks = 0.obs;
  final RxInt pendingSubmissions = 0.obs;
  final RxInt totalAuthors = 0.obs;
  final RxInt activePromos = 0.obs;

  // Quick Action Priority Table: 5 Most Recent Unreviewed Submissions
  final RxList<Submission> recentSubmissions = <Submission>[].obs;

  // Trend Chart State ('books' or 'submissions')
  final RxString trendMode = 'books'.obs; // 'books' or 'submissions'
  final RxList<DashboardMonthlyPoint> bookTrendPoints = <DashboardMonthlyPoint>[].obs;
  final RxList<DashboardMonthlyPoint> submissionTrendPoints = <DashboardMonthlyPoint>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final metrics = await remoteDataSource.getDashboardMetrics();

      totalBooks.value = metrics['totalBooks'] as int? ?? 0;
      pendingSubmissions.value = metrics['pendingSubmissions'] as int? ?? 0;
      totalAuthors.value = metrics['totalAuthors'] as int? ?? 0;
      activePromos.value = metrics['activePromos'] as int? ?? 0;

      final recentRaw = metrics['recentSubmissions'] as List? ?? [];
      recentSubmissions.value = recentRaw
          .map((json) => SubmissionModel.fromJson(Map<String, dynamic>.from(json)))
          .toList();

      final List<DateTime> bookDates = metrics['bookDates'] as List<DateTime>? ?? [];
      final List<DateTime> subDates = metrics['submissionDates'] as List<DateTime>? ?? [];

      bookTrendPoints.value = _computeLast6MonthsPoints(bookDates);
      submissionTrendPoints.value = _computeLast6MonthsPoints(subDates);

      isLoading.value = false;
    } catch (e) {
      errorMessage.value = 'Gagal memuat metrik dashboard: $e';
      isLoading.value = false;
    }
  }

  List<DashboardMonthlyPoint> _computeLast6MonthsPoints(List<DateTime> dates) {
    final now = DateTime.now();
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];

    List<DashboardMonthlyPoint> points = [];

    for (int i = 5; i >= 0; i--) {
      // Go back i months
      int targetYear = now.year;
      int targetMonth = now.month - i;
      while (targetMonth <= 0) {
        targetMonth += 12;
        targetYear -= 1;
      }

      final label = monthNames[targetMonth - 1];
      final count = dates.where((d) => d.year == targetYear && d.month == targetMonth).length;

      points.add(DashboardMonthlyPoint(monthLabel: label, count: count));
    }

    return points;
  }

  void switchTrendMode(String mode) {
    trendMode.value = mode;
  }

  Future<void> updateSubmissionStatus(BuildContext context, String submissionId, String newStatus) async {
    final result = await submissionRepository.updateSubmissionStatus(submissionId, newStatus);
    result.fold(
      (failure) {
        AppToast.showError(context, 'Gagal memperbarui status: ${failure.message}');
      },
      (_) async {
        AppToast.showSuccess(context, 'Status naskah berhasil diperbarui: $newStatus');
        await fetchDashboardData();
      },
    );
  }

  void navigateToSubmissions() {
    if (Get.isRegistered<MainLayoutController>()) {
      Get.find<MainLayoutController>().changePage(2); // Naskah Masuk page index
    }
  }

  void navigateToBooks() {
    if (Get.isRegistered<MainLayoutController>()) {
      Get.find<MainLayoutController>().changePage(1); // Katalog Buku page index
    }
  }
}
