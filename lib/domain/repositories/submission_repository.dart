import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../entities/submission.dart';

abstract class SubmissionRepository {
  Future<Either<Failure, List<Submission>>> getSubmissions({
    int page = 0,
    int pageSize = 15,
    String? status,
  });
  Future<Either<Failure, Submission?>> getSubmissionById(String id);
  Future<Either<Failure, int>> getSubmissionsCount({String? status});
  Future<Either<Failure, int>> getPendingSubmissionsCount();
  Future<Either<Failure, List<Submission>>> getRecentUnreviewedSubmissions({int limit = 5});
  Future<Either<Failure, List<Submission>>> getDeletedSubmissions();
  Future<Either<Failure, void>> deleteSubmission(String id);
  Future<Either<Failure, void>> updateSubmissionStatus(String id, String status);
  Future<Either<Failure, void>> restoreSubmissions(List<String> ids);
  Future<Either<Failure, void>> permanentlyDeleteSubmissions(List<String> ids);
}
