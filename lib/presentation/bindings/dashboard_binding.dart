import 'package:get/get.dart';
import '../../data/datasources/supabase_remote_data_source.dart';
import '../../data/repositories/book_repository_impl.dart';
import '../../data/repositories/submission_repository_impl.dart';
import '../../domain/repositories/book_repository.dart';
import '../../domain/repositories/submission_repository.dart';
import '../../domain/usecases/add_book_usecase.dart';
import '../../domain/usecases/delete_book_usecase.dart';
import '../../domain/usecases/get_books_usecase.dart';
import '../../domain/usecases/get_submissions_usecase.dart';
import '../../domain/usecases/update_book_usecase.dart';
import '../controllers/book_controller.dart';
import '../controllers/main_layout_controller.dart';
import '../controllers/submission_controller.dart';

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

    // Use Cases
    Get.lazyPut(() => GetBooksUseCase(Get.find()));
    Get.lazyPut(() => AddBookUseCase(Get.find()));
    Get.lazyPut(() => UpdateBookUseCase(Get.find()));
    Get.lazyPut(() => DeleteBookUseCase(Get.find()));
    Get.lazyPut(() => GetSubmissionsUseCase(Get.find()));

    // Controllers
    Get.lazyPut(() => MainLayoutController());
    Get.lazyPut(
      () => BookController(
        getBooksUseCase: Get.find(),
        addBookUseCase: Get.find(),
        updateBookUseCase: Get.find(),
        deleteBookUseCase: Get.find(),
      ),
    );
    Get.lazyPut(
      () => SubmissionController(
        getSubmissionsUseCase: Get.find(),
      ),
    );
  }
}
