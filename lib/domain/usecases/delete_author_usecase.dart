import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../repositories/author_repository.dart';

class DeleteAuthorUseCase {
  final AuthorRepository repository;

  DeleteAuthorUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteAuthor(id);
  }
}
