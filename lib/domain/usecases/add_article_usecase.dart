import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../entities/article.dart';
import '../repositories/article_repository.dart';

class AddArticleUseCase {
  final ArticleRepository repository;

  AddArticleUseCase(this.repository);

  Future<Either<Failure, void>> call(Article article) async {
    return await repository.addArticle(article);
  }
}
