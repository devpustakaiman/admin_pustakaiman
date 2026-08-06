import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../repositories/book_repository.dart';

class DeleteBookUseCase {
  final BookRepository repository;

  DeleteBookUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteBook(id);
  }
}
