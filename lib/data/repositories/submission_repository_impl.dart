import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/submission.dart';
import '../../domain/repositories/submission_repository.dart';
import '../datasources/supabase_remote_data_source.dart';
import '../models/submission_model.dart';

class SubmissionRepositoryImpl implements SubmissionRepository {
  final SupabaseRemoteDataSource remoteDataSource;

  SubmissionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Submission>>> getSubmissions() async {
    try {
      final data = await remoteDataSource.getSubmissions();
      final submissions = data.map((json) => SubmissionModel.fromJson(json)).toList();
      return Right(submissions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Submission>>> getDeletedSubmissions() async {
    try {
      final data = await remoteDataSource.getDeletedSubmissions();
      final submissions = data.map((json) => SubmissionModel.fromJson(json)).toList();
      return Right(submissions);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSubmission(String id) async {
    try {
      await remoteDataSource.deleteSubmission(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateSubmissionStatus(String id, String status) async {
    try {
      await remoteDataSource.updateSubmissionStatus(id, status);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> restoreSubmissions(List<String> ids) async {
    try {
      await remoteDataSource.restoreSubmissions(ids);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> permanentlyDeleteSubmissions(List<String> ids) async {
    try {
      await remoteDataSource.permanentlyDeleteSubmissions(ids);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
