import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

class GetDeletedBooksUseCase {
  final BookRepository repository;

  GetDeletedBooksUseCase(this.repository);

  Future<Either<Failure, List<Book>>> call() async {
    return await repository.getDeletedBooks();
  }
}
