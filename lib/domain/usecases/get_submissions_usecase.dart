import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../entities/submission.dart';
import '../repositories/submission_repository.dart';

class GetSubmissionsUseCase {
  final SubmissionRepository repository;

  GetSubmissionsUseCase(this.repository);

  Future<Either<Failure, List<Submission>>> call() async {
    return await repository.getSubmissions();
  }
}
