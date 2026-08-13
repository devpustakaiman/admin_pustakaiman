import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../repositories/article_repository.dart';

class DeleteArticleUseCase {
  final ArticleRepository repository;

  DeleteArticleUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteArticle(id);
  }
}
