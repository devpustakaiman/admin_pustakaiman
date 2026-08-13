import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../entities/author.dart';
import '../repositories/author_repository.dart';

class GetAuthorsUseCase {
  final AuthorRepository repository;

  GetAuthorsUseCase(this.repository);

  Future<Either<Failure, List<Author>>> call() async {
    return await repository.getAuthors();
  }
}
