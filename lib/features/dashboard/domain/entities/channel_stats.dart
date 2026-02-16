/// Domain entity for channel analytics stats.
class ChannelStats {
  const ChannelStats({
    this.subscriberCount = 0,
    this.viewCount = 0,
    this.videoCount = 0,
    this.avgWatchTimeMinutes = 0.0,
    this.dailyViews = const [],
  });

  final int subscriberCount;
  final int viewCount;
  final int videoCount;
  final double avgWatchTimeMinutes;
  final List<DailyView> dailyViews;

  factory ChannelStats.fromJson(Map<String, dynamic> json) {
    final dailyViewsList = (json['dailyViews'] as List<dynamic>?)
            ?.map((e) => DailyView.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];

    return ChannelStats(
      subscriberCount: json['subscriberCount'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      videoCount: json['videoCount'] as int? ?? 0,
      avgWatchTimeMinutes: (json['avgWatchTimeMinutes'] as num?)?.toDouble() ?? 0.0,
      dailyViews: dailyViewsList,
    );
  }
}

/// A single day's view count for chart data.
class DailyView {
  const DailyView({required this.date, required this.views});

  final String date;
  final int views;

  factory DailyView.fromJson(Map<String, dynamic> json) {
    return DailyView(
      date: json['date'] as String? ?? '',
      views: json['views'] as int? ?? 0,
    );
  }
}
