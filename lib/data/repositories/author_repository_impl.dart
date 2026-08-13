import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/author.dart';
import '../../domain/repositories/author_repository.dart';
import '../datasources/supabase_remote_data_source.dart';
import '../models/author_model.dart';

class AuthorRepositoryImpl implements AuthorRepository {
  final SupabaseRemoteDataSource remoteDataSource;

  AuthorRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Author>>> getAuthors() async {
    try {
      final data = await remoteDataSource.getAuthors();
      final authors = data.map((json) => AuthorModel.fromJson(json)).toList();
      return Right(authors);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addAuthor(Author author) async {
    try {
      final authorModel = AuthorModel.fromEntity(author);
      final authorMap = authorModel.toJson();
      if (author.id.isEmpty) {
        authorMap.remove('id');
      }
      await remoteDataSource.insertAuthor(authorMap);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateAuthor(Author author) async {
    try {
      final authorModel = AuthorModel.fromEntity(author);
      await remoteDataSource.updateAuthor(authorModel.toJson());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAuthor(String id) async {
    try {
      await remoteDataSource.deleteAuthor(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
