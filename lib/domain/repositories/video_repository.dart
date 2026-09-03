import 'package:either_dart/either.dart';
import '../../core/error/failures.dart';
import '../entities/media_video.dart';

abstract class VideoRepository {
  Future<Either<Failure, List<MediaVideo>>> getVideos({int page = 0, int pageSize = 30});
  Future<Either<Failure, MediaVideo?>> getVideoById(String id);
  Future<Either<Failure, int>> getVideosCount();
  Future<Either<Failure, void>> addVideo(MediaVideo video);
  Future<Either<Failure, void>> updateVideo(MediaVideo video);
  Future<Either<Failure, void>> deleteVideo(String id);
  Future<Either<Failure, void>> setFeaturedVideo(String id);
}
