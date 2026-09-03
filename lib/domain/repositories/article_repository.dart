import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../entities/article.dart';

abstract class ArticleRepository {
  Future<Either<Failure, List<Article>>> getArticles({int page = 0, int pageSize = 15});
  Future<Either<Failure, Article?>> getArticleById(String id);
  Future<Either<Failure, int>> getArticlesCount();
  Future<Either<Failure, List<Article>>> getDeletedArticles();
  Future<Either<Failure, void>> addArticle(Article article);
  Future<Either<Failure, void>> updateArticle(Article article);
  Future<Either<Failure, void>> deleteArticle(String id);
  Future<Either<Failure, void>> restoreArticles(List<String> ids);
  Future<Either<Failure, void>> permanentlyDeleteArticles(List<String> ids);
}
