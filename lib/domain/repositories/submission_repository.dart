import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../entities/submission.dart';

abstract class SubmissionRepository {
  Future<Either<Failure, List<Submission>>> getSubmissions();
}
