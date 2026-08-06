import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../entities/book.dart';

abstract class BookRepository {
  Future<Either<Failure, List<Book>>> getBooks();
  Future<Either<Failure, void>> addBook(Book book);
  Future<Either<Failure, void>> updateBook(Book book);
  Future<Either<Failure, void>> deleteBook(String id);
}
