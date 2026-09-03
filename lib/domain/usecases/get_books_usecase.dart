import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../entities/book.dart';
import '../repositories/book_repository.dart';

class GetBooksUseCase {
  final BookRepository repository;

  GetBooksUseCase(this.repository);

  Future<Either<Failure, List<Book>>> call({int page = 0, int pageSize = 15}) async {
    return await repository.getBooks(page: page, pageSize: pageSize);
  }
}
