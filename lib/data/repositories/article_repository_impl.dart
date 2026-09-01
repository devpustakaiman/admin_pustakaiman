import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/article_repository.dart';
import '../datasources/supabase_remote_data_source.dart';
import '../models/article_model.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final SupabaseRemoteDataSource remoteDataSource;

  ArticleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Article>>> getArticles() async {
    try {
      final data = await remoteDataSource.getArticles();
      final articles = data.map((json) => ArticleModel.fromJson(json)).toList();
      return Right(articles);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Article>>> getDeletedArticles() async {
    try {
      final data = await remoteDataSource.getDeletedArticles();
      final articles = data.map((json) => ArticleModel.fromJson(json)).toList();
      return Right(articles);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addArticle(Article article) async {
    try {
      final articleModel = ArticleModel.fromEntity(article);
      final articleMap = articleModel.toJson();
      if (article.id.isEmpty) {
        articleMap.remove('id');
      }
      await remoteDataSource.insertArticle(articleMap);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateArticle(Article article) async {
    try {
      final articleModel = ArticleModel.fromEntity(article);
      await remoteDataSource.updateArticle(articleModel.toJson());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteArticle(String id) async {
    try {
      await remoteDataSource.deleteArticle(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> restoreArticles(List<String> ids) async {
    try {
      await remoteDataSource.restoreArticles(ids);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> permanentlyDeleteArticles(List<String> ids) async {
    try {
      await remoteDataSource.permanentlyDeleteArticles(ids);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
