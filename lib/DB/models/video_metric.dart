/// A model class representing daily metrics for a YouTube video.
///
/// This class contains the performance metrics for a video on a specific day,
/// including views, impressions, and engagement metrics.
class VideoMetric {
  /// Unique identifier for the metric
  final String metricId;

  /// Date for which these metrics are recorded
  final DateTime day;

  /// Number of views on this day
  final int dayViews;

  /// Number of impressions on this day
  final int impressions;

  /// Click-through rate (percentage of impressions that resulted in views)
  final double ctr;

  /// Watch time in minutes on this day
  final int watchtime;

  /// Creates a new VideoMetric instance.
  ///
  /// All parameters are required and cannot be null.
  VideoMetric({
    required this.metricId,
    required this.day,
    required this.dayViews,
    required this.impressions,
    required this.ctr,
    required this.watchtime,
  });

  /// Converts the VideoMetric object to a Map for database storage.
  ///
  /// Returns a Map containing all metric data with appropriate keys.
  Map<String, dynamic> toMap() {
    return {
      'metric_id': metricId,
      'day': day.toIso8601String(),
      'day_views': dayViews,
      'impressions': impressions,
      'ctr': ctr,
      'watchtime': watchtime,
    };
  }

  /// Creates a VideoMetric instance from a Map.
  ///
  /// [map] should contain all required metric data with appropriate keys.
  /// Returns a new VideoMetric instance with data from the map.
  factory VideoMetric.fromMap(Map<String, dynamic> map) {
    return VideoMetric(
      metricId: map['metric_id'],
      day: DateTime.parse(map['day']),
      dayViews: map['day_views'],
      impressions: map['impressions'],
      ctr: map['ctr'],
      watchtime: map['watchtime'],
    );
  }
}
