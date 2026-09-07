import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../entities/article.dart';
import '../repositories/article_repository.dart';

class GetArticlesUseCase {
  final ArticleRepository repository;

  GetArticlesUseCase(this.repository);

  Future<Either<Failure, List<Article>>> call({int? page, int? pageSize}) async {
    return await repository.getArticles(page: page, pageSize: pageSize);
  }
}
