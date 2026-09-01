import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../repositories/book_repository.dart';

class PermanentlyDeleteBooksUseCase {
  final BookRepository repository;

  PermanentlyDeleteBooksUseCase(this.repository);

  Future<Either<Failure, void>> call(List<String> ids) async {
    return await repository.permanentlyDeleteBooks(ids);
  }
}
