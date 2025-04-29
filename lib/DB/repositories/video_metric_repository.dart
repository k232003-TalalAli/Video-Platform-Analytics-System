import '../models/video_metric.dart';
import '../controllers/database_helper.dart';

/// Repository class for managing VideoMetric data in the database.
///
/// This class provides methods for CRUD operations on VideoMetric objects.
class VideoMetricRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Retrieves all metrics for a specific video.
  ///
  /// Args:
  ///   videoId (String): The unique identifier of the video whose metrics to retrieve.
  ///
  /// Returns:
  ///   List(VideoMetric): A list of all metrics for the video.
  Future<List<VideoMetric>> getVideoMetrics(String videoId) async {
    final metrics = await _dbHelper.getVideoMetrics(videoId);
    return metrics.map((map) => VideoMetric.fromMap(map)).toList();
  }

  /// Retrieves metrics for a video within a specific date range.
  ///
  /// Args:
  ///   videoId (String): The unique identifier of the video whose metrics to retrieve.
  ///   startDate (DateTime): The start date of the range (inclusive).
  ///   endDate (DateTime): The end date of the range (inclusive).
  ///
  /// Returns:
  ///   List(VideoMetric): A list of metrics within the specified date range.
  Future<List<VideoMetric>> getMetricsByDateRange(
      String videoId, DateTime startDate, DateTime endDate) async {
    final metrics = await _dbHelper.getVideoMetrics(videoId);
    return metrics
        .where((map) {
          final date = DateTime.parse(map['day'] as String);
          return date.isAfter(startDate) && date.isBefore(endDate);
        })
        .map((map) => VideoMetric.fromMap(map))
        .toList();
  }

  /// Adds a new metric for a video.
  ///
  /// Args:
  ///   videoId (String): The unique identifier of the video to add the metric to.
  ///   metric (VideoMetric): The metric object to add to the database.
  ///
  /// Returns:
  ///   void
  Future<void> addMetric(String videoId, VideoMetric metric) async {
    await _dbHelper.addVideoMetrics(videoId, metric.toMap());
  }

  /// Updates an existing metric in the database.
  ///
  /// Args:
  ///   videoId (String): The unique identifier of the video whose metric to update.
  ///   metric (VideoMetric): The updated metric object.
  ///
  /// Returns:
  ///   void
  Future<void> updateMetric(String videoId, VideoMetric metric) async {
    await _dbHelper.updateVideoMetrics(
        videoId, metric.metricId, metric.toMap());
  }
}
