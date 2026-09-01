import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../repositories/book_repository.dart';

class RestoreBooksUseCase {
  final BookRepository repository;

  RestoreBooksUseCase(this.repository);

  Future<Either<Failure, void>> call(List<String> ids) async {
    return await repository.restoreBooks(ids);
  }
}
