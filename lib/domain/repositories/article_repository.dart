import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../entities/article.dart';

abstract class ArticleRepository {
  Future<Either<Failure, List<Article>>> getArticles();
  Future<Either<Failure, void>> addArticle(Article article);
  Future<Either<Failure, void>> updateArticle(Article article);
  Future<Either<Failure, void>> deleteArticle(String id);
}
