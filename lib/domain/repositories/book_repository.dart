import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../entities/book.dart';

abstract class BookRepository {
  Future<Either<Failure, List<Book>>> getBooks({int page = 0, int pageSize = 15});
  Future<Either<Failure, Book?>> getBookById(String id);
  Future<Either<Failure, int>> getBooksCount();
  Future<Either<Failure, List<Book>>> getDeletedBooks();
  Future<Either<Failure, void>> addBook(Book book);
  Future<Either<Failure, void>> updateBook(Book book);
  Future<Either<Failure, void>> deleteBook(String id);
  Future<Either<Failure, void>> restoreBooks(List<String> ids);
  Future<Either<Failure, void>> permanentlyDeleteBooks(List<String> ids);
}
