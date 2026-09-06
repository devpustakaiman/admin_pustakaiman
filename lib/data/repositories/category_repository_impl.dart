import 'package:either_dart/either.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/supabase_remote_data_source.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final SupabaseRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final data = await remoteDataSource.getCategories();
      final categories = data.map((json) => CategoryModel.fromJson(json)).toList();
      return Right(categories);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addCategory(String name, String slug, {String? parentId}) async {
    try {
      await remoteDataSource.insertCategory(name, slug, parentId: parentId);
      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message, code: e.code));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(String id, String name, String slug, {String? parentId}) async {
    try {
      await remoteDataSource.updateCategory(id, name, slug, parentId: parentId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await remoteDataSource.deleteCategory(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
