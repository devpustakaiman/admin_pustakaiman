import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../entities/category.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<Category>>> getCategories();
  Future<Either<Failure, void>> addCategory(String name, String slug, {String? parentId});
  Future<Either<Failure, void>> updateCategory(String id, String name, String slug, {String? parentId});
  Future<Either<Failure, void>> deleteCategory(String id);
}
