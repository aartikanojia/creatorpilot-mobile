/// Domain entity for the top-performing video.
class TopVideo {
  const TopVideo({
    this.videoId,
    this.title,
    this.thumbnailUrl,
    this.views = 0,
    this.growthPercentage = 0.0,
  });

  final String? videoId;
  final String? title;
  final String? thumbnailUrl;
  final int views;
  final double growthPercentage;

  /// Whether we have a valid top video to display.
  bool get isAvailable => videoId != null && videoId!.isNotEmpty;

  factory TopVideo.fromJson(Map<String, dynamic> json) {
    return TopVideo(
      videoId: json['video_id'] as String?,
      title: json['title'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      views: json['views'] as int? ?? 0,
      growthPercentage: (json['growth_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
