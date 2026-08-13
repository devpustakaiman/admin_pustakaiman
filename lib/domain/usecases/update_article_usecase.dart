import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../entities/article.dart';
import '../repositories/article_repository.dart';

class UpdateArticleUseCase {
  final ArticleRepository repository;

  UpdateArticleUseCase(this.repository);

  Future<Either<Failure, void>> call(Article article) async {
    return await repository.updateArticle(article);
  }
}
