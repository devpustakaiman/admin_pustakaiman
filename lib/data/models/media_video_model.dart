import '../../domain/entities/media_video.dart';

class MediaVideoModel extends MediaVideo {
  const MediaVideoModel({
    required super.id,
    required super.title,
    required super.youtubeUrl,
    super.thumbnailUrl = '',
    super.duration = '',
    super.category = 'LIPUTAN UTAMA',
    super.speakerName = '',
    super.isFeatured = false,
    super.orderIndex = 0,
    super.createdAt,
    super.updatedAt,
    super.deletedAt,
  });

  factory MediaVideoModel.fromJson(Map<String, dynamic> json) {
    int parseOptionalInt(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    DateTime? parseDateTime(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) {
        return DateTime.tryParse(val);
      }
      return null;
    }

    return MediaVideoModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      youtubeUrl: json['youtube_url'] as String? ?? json['youtubeUrl'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ?? json['thumbnailUrl'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      category: json['category'] as String? ?? 'LIPUTAN UTAMA',
      speakerName: json['speaker_name'] as String? ?? json['speakerName'] as String? ?? '',
      isFeatured: json['is_featured'] as bool? ?? json['isFeatured'] as bool? ?? false,
      orderIndex: parseOptionalInt(json['order_index'] ?? json['orderIndex']),
      createdAt: parseDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: parseDateTime(json['updated_at'] ?? json['updatedAt']),
      deletedAt: parseDateTime(json['deleted_at'] ?? json['deletedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'youtube_url': youtubeUrl,
      'thumbnail_url': thumbnailUrl,
      'duration': duration,
      'category': category,
      'speaker_name': speakerName,
      'is_featured': isFeatured,
      'order_index': orderIndex,
    };
    if (id.isNotEmpty) {
      map['id'] = id;
    }
    if (updatedAt != null) {
      map['updated_at'] = updatedAt!.toIso8601String();
    }
    if (createdAt != null) {
      map['created_at'] = createdAt!.toIso8601String();
    }
    if (deletedAt != null) {
      map['deleted_at'] = deletedAt!.toIso8601String();
    }
    return map;
  }
}
