import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../entities/author.dart';
import '../repositories/author_repository.dart';

class UpdateAuthorUseCase {
  final AuthorRepository repository;

  UpdateAuthorUseCase(this.repository);

  Future<Either<Failure, void>> call(Author author) async {
    return await repository.updateAuthor(author);
  }
}
