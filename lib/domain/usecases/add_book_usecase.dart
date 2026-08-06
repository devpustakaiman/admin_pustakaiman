import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

class AddBookUseCase {
  final BookRepository repository;

  AddBookUseCase(this.repository);

  Future<Either<Failure, void>> call(Book book) async {
    return await repository.addBook(book);
  }
}
