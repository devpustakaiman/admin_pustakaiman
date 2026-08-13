import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../entities/author.dart';
import '../repositories/author_repository.dart';

class AddAuthorUseCase {
  final AuthorRepository repository;

  AddAuthorUseCase(this.repository);

  Future<Either<Failure, void>> call(Author author) async {
    return await repository.addAuthor(author);
  }
}
