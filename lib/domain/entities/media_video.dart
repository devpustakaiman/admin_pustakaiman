class MediaVideo {
  final String id;
  final String title;
  final String youtubeUrl;
  final String thumbnailUrl;
  final String duration;
  final String category;
  final String speakerName;
  final bool isFeatured;
  final int orderIndex;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const MediaVideo({
    required this.id,
    required this.title,
    required this.youtubeUrl,
    this.thumbnailUrl = '',
    this.duration = '',
    this.category = 'LIPUTAN UTAMA',
    this.speakerName = '',
    this.isFeatured = false,
    this.orderIndex = 0,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  String get extractedYoutubeId {
    if (youtubeUrl.isEmpty) return '';
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(youtubeUrl);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }
    if (youtubeUrl.length == 11 && !youtubeUrl.contains('/')) {
      return youtubeUrl;
    }
    return '';
  }

  String get effectiveThumbnailUrl {
    if (thumbnailUrl.isNotEmpty &&
        (thumbnailUrl.startsWith('http://') || thumbnailUrl.startsWith('https://'))) {
      return thumbnailUrl;
    }
    final yId = extractedYoutubeId;
    if (yId.isNotEmpty) {
      return 'https://img.youtube.com/vi/$yId/hqdefault.jpg';
    }
    return '';
  }
}
