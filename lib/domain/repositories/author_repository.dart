import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../entities/author.dart';

abstract class AuthorRepository {
  Future<Either<Failure, List<Author>>> getAuthors({int page = 0, int pageSize = 15});
  Future<Either<Failure, Author?>> getAuthorById(String id);
  Future<Either<Failure, int>> getAuthorsCount();
  Future<Either<Failure, List<Author>>> getDeletedAuthors();
  Future<Either<Failure, void>> addAuthor(Author author);
  Future<Either<Failure, void>> updateAuthor(Author author);
  Future<Either<Failure, void>> deleteAuthor(String id);
  Future<Either<Failure, void>> restoreAuthors(List<String> ids);
  Future<Either<Failure, void>> permanentlyDeleteAuthors(List<String> ids);
}
