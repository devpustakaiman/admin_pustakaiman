import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../entities/submission.dart';

abstract class SubmissionRepository {
  Future<Either<Failure, List<Submission>>> getSubmissions();
  Future<Either<Failure, List<Submission>>> getDeletedSubmissions();
  Future<Either<Failure, void>> deleteSubmission(String id);
  Future<Either<Failure, void>> updateSubmissionStatus(String id, String status);
  Future<Either<Failure, void>> restoreSubmissions(List<String> ids);
  Future<Either<Failure, void>> permanentlyDeleteSubmissions(List<String> ids);
}
