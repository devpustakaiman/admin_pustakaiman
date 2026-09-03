import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/media_video.dart';
import '../../domain/repositories/video_repository.dart';
import '../datasources/supabase_remote_data_source.dart';
import '../models/media_video_model.dart';

class VideoRepositoryImpl implements VideoRepository {
  final SupabaseRemoteDataSource remoteDataSource;

  VideoRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<MediaVideo>>> getVideos({int page = 0, int pageSize = 30}) async {
    try {
      final data = await remoteDataSource.getMediaVideos(page: page, pageSize: pageSize);
      final videos = data.map((json) => MediaVideoModel.fromJson(json)).toList();
      return Right(videos);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, MediaVideo?>> getVideoById(String id) async {
    try {
      final data = await remoteDataSource.getMediaVideoById(id);
      if (data == null) return const Right(null);
      return Right(MediaVideoModel.fromJson(data));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getVideosCount() async {
    try {
      final count = await remoteDataSource.getMediaVideosCount();
      return Right(count);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addVideo(MediaVideo video) async {
    try {
      final videoModel = MediaVideoModel(
        id: video.id,
        title: video.title,
        youtubeUrl: video.youtubeUrl,
        thumbnailUrl: video.thumbnailUrl,
        duration: video.duration,
        category: video.category,
        speakerName: video.speakerName,
        isFeatured: video.isFeatured,
        orderIndex: video.orderIndex,
        createdAt: video.createdAt,
        updatedAt: video.updatedAt,
      );
      final videoMap = videoModel.toJson();
      if (video.id.isEmpty) {
        videoMap.remove('id');
      }
      await remoteDataSource.addMediaVideo(videoMap);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateVideo(MediaVideo video) async {
    try {
      final videoModel = MediaVideoModel(
        id: video.id,
        title: video.title,
        youtubeUrl: video.youtubeUrl,
        thumbnailUrl: video.thumbnailUrl,
        duration: video.duration,
        category: video.category,
        speakerName: video.speakerName,
        isFeatured: video.isFeatured,
        orderIndex: video.orderIndex,
        updatedAt: video.updatedAt,
      );
      final videoMap = videoModel.toJson();
      await remoteDataSource.updateMediaVideo(videoMap);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVideo(String id) async {
    try {
      await remoteDataSource.deleteMediaVideo(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setFeaturedVideo(String id) async {
    try {
      await remoteDataSource.setFeaturedMediaVideo(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
