class VideoMetric {
  final String metricId;
  final String videoId;
  final DateTime day;
  final int dayViews;
  final int impressions;
  final double ctr;
  final int watchtime;

  VideoMetric({
    required this.metricId,
    required this.videoId,
    required this.day,
    required this.dayViews,
    required this.impressions,
    required this.ctr,
    required this.watchtime,
  });

  Map<String, dynamic> toMap() {
    return {
      'metric_id': metricId,
      'video_id': videoId,
      'day': day.toIso8601String(),
      'day_views': dayViews,
      'impressions': impressions,
      'ctr': ctr,
      'watchtime': watchtime,
    };
  }

  factory VideoMetric.fromMap(Map<String, dynamic> map) {
    return VideoMetric(
      metricId: map['metric_id'],
      videoId: map['video_id'],
      day: DateTime.parse(map['day']),
      dayViews: map['day_views'],
      impressions: map['impressions'],
      ctr: map['ctr'],
      watchtime: map['watchtime'],
    );
  }
}
