import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/supabase_remote_data_source.dart';
import '../models/book_model.dart';

class BookRepositoryImpl implements BookRepository {
  final SupabaseRemoteDataSource remoteDataSource;

  BookRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Book>>> getBooks() async {
    try {
      final data = await remoteDataSource.getBooks();
      final books = data.map((json) => BookModel.fromJson(json)).toList();
      return Right(books);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addBook(Book book) async {
    try {
      final bookModel = BookModel(
        id: book.id,
        title: book.title,
        author: book.author,
        synopsis: book.synopsis,
        coverUrl: book.coverUrl,
        pdfPreviewUrl: book.pdfPreviewUrl,
        mizanstoreUrl: book.mizanstoreUrl,
        category: book.category,
        galleryUrls: book.galleryUrls,
        price: book.price,
      );
      final bookMap = bookModel.toJson();
      if (book.id.isEmpty) {
        bookMap.remove('id');
      }
      await remoteDataSource.addBook(bookMap);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBook(Book book) async {
    try {
      final bookModel = BookModel(
        id: book.id,
        title: book.title,
        author: book.author,
        synopsis: book.synopsis,
        coverUrl: book.coverUrl,
        pdfPreviewUrl: book.pdfPreviewUrl,
        mizanstoreUrl: book.mizanstoreUrl,
        category: book.category,
        galleryUrls: book.galleryUrls,
        price: book.price,
      );
      await remoteDataSource.updateBook(bookModel.toJson());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBook(String id) async {
    try {
      await remoteDataSource.deleteBook(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
