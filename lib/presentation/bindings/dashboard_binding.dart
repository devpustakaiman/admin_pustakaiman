import 'package:get/get.dart';
import '../../data/datasources/supabase_remote_data_source.dart';
import '../../data/repositories/article_repository_impl.dart';
import '../../data/repositories/author_repository_impl.dart';
import '../../data/repositories/book_repository_impl.dart';
import '../../data/repositories/submission_repository_impl.dart';
import '../../data/repositories/video_repository_impl.dart';
import '../../domain/repositories/article_repository.dart';
import '../../domain/repositories/author_repository.dart';
import '../../domain/repositories/book_repository.dart';
import '../../domain/repositories/submission_repository.dart';
import '../../domain/repositories/video_repository.dart';
import '../../domain/usecases/add_article_usecase.dart';
import '../../domain/usecases/add_author_usecase.dart';
import '../../domain/usecases/add_book_usecase.dart';
import '../../domain/usecases/delete_article_usecase.dart';
import '../../domain/usecases/delete_author_usecase.dart';
import '../../domain/usecases/delete_book_usecase.dart';
import '../../domain/usecases/get_articles_usecase.dart';
import '../../domain/usecases/get_authors_usecase.dart';
import '../../domain/usecases/get_books_usecase.dart';
import '../../domain/usecases/get_deleted_books_usecase.dart';
import '../../domain/usecases/get_submissions_usecase.dart';
import '../../domain/usecases/permanently_delete_books_usecase.dart';
import '../../domain/usecases/restore_books_usecase.dart';
import '../../domain/usecases/update_article_usecase.dart';
import '../../domain/usecases/update_author_usecase.dart';
import '../../domain/usecases/update_book_usecase.dart';
import '../controllers/article_controller.dart';
import '../controllers/author_controller.dart';
import '../controllers/book_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/main_layout_controller.dart';
import '../controllers/preorder_controller.dart';
import '../controllers/submission_controller.dart';
import '../controllers/trash_controller.dart';
import '../controllers/video_controller.dart';
import '../controllers/web_settings_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Data Sources
    Get.lazyPut<SupabaseRemoteDataSource>(
      () => SupabaseRemoteDataSourceImpl(),
    );

    // Repositories
    Get.lazyPut<BookRepository>(
      () => BookRepositoryImpl(remoteDataSource: Get.find()),
    );
    Get.lazyPut<SubmissionRepository>(
      () => SubmissionRepositoryImpl(remoteDataSource: Get.find()),
    );
    Get.lazyPut<AuthorRepository>(
      () => AuthorRepositoryImpl(remoteDataSource: Get.find()),
    );
    Get.lazyPut<ArticleRepository>(
      () => ArticleRepositoryImpl(remoteDataSource: Get.find()),
    );
    Get.lazyPut<VideoRepository>(
      () => VideoRepositoryImpl(remoteDataSource: Get.find()),
    );

    // Use Cases
    Get.lazyPut(() => GetBooksUseCase(Get.find()));
    Get.lazyPut(() => AddBookUseCase(Get.find()));
    Get.lazyPut(() => UpdateBookUseCase(Get.find()));
    Get.lazyPut(() => DeleteBookUseCase(Get.find()));
    Get.lazyPut(() => GetDeletedBooksUseCase(Get.find()));
    Get.lazyPut(() => RestoreBooksUseCase(Get.find()));
    Get.lazyPut(() => PermanentlyDeleteBooksUseCase(Get.find()));
    Get.lazyPut(() => GetSubmissionsUseCase(Get.find()));

    Get.lazyPut(() => GetAuthorsUseCase(Get.find()));
    Get.lazyPut(() => AddAuthorUseCase(Get.find()));
    Get.lazyPut(() => UpdateAuthorUseCase(Get.find()));
    Get.lazyPut(() => DeleteAuthorUseCase(Get.find()));

    Get.lazyPut(() => GetArticlesUseCase(Get.find()));
    Get.lazyPut(() => AddArticleUseCase(Get.find()));
    Get.lazyPut(() => UpdateArticleUseCase(Get.find()));
    Get.lazyPut(() => DeleteArticleUseCase(Get.find()));

    // Controllers
    Get.lazyPut(() => MainLayoutController());
    Get.lazyPut(
      () => DashboardController(
        dataSource: Get.find<SupabaseRemoteDataSource>(),
        subRepository: Get.find<SubmissionRepository>(),
      ),
    );
    Get.lazyPut(
      () => BookController(
        getBooksUseCase: Get.find(),
        addBookUseCase: Get.find(),
        updateBookUseCase: Get.find(),
        deleteBookUseCase: Get.find(),
      ),
    );
    Get.lazyPut(
      () => TrashController(
        bookRepository: Get.find(),
        authorRepository: Get.find(),
        articleRepository: Get.find(),
        submissionRepository: Get.find(),
      ),
    );
    Get.lazyPut(
      () => SubmissionController(
        getSubmissionsUseCase: Get.find(),
      ),
    );
    Get.lazyPut(
      () => AuthorController(
        getAuthorsUseCase: Get.find(),
        addAuthorUseCase: Get.find(),
        updateAuthorUseCase: Get.find(),
        deleteAuthorUseCase: Get.find(),
      ),
    );
    Get.lazyPut(
      () => ArticleController(
        getArticlesUseCase: Get.find(),
        addArticleUseCase: Get.find(),
        updateArticleUseCase: Get.find(),
        deleteArticleUseCase: Get.find(),
      ),
    );
    Get.lazyPut(
      () => VideoController(
        videoRepository: Get.find(),
      ),
    );
    Get.lazyPut(
      () => WebSettingsController(
        dataSource: Get.find<SupabaseRemoteDataSource>(),
      ),
    );
    Get.lazyPut(
      () => PreorderController(
        dataSource: Get.find<SupabaseRemoteDataSource>(),
      ),
    );
  }
}
