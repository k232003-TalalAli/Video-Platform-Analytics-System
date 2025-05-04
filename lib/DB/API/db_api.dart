import '../models/user.dart';
import '../models/video.dart';
import '../models/video_metric.dart';
import '../repositories/user_repository.dart';
import '../repositories/video_repository.dart';
import '../repositories/video_metric_repository.dart';

/// Fetches overall user data from the database
///
/// Args:
///   userId (String): The unique identifier of the user to fetch
///
/// Returns:
///   Future<User?>: The user object if found, null otherwise
Future<User?> fetchUserOverall(String userId) async {
  try {
    final userRepository = UserRepository();
    final user = await userRepository.getUserById(userId);
    return user;
  } catch (e) {
    print('Error fetching user overall data: $e');
    return null;
  }
}

/// Fetches all videos for a specific user from the database
///
/// Args:
///   userId (String): The unique identifier of the user whose videos to fetch
///
/// Returns:
///   Future<List<Video>>: A list of all videos belonging to the user
Future<List<Video>> fetchUserVideos(String userId) async {
  try {
    final videoRepository = VideoRepository();
    final videos = await videoRepository.getUserVideos(userId);
    return videos;
  } catch (e) {
    print('Error fetching user videos: $e');
    return [];
  }
}

/// Fetches daily metrics for a specific video from the database
///
/// Args:
///   videoId (String): The unique identifier of the video whose metrics to fetch
///
/// Returns:
///   Future<List<VideoMetric>>: A list of all metrics for the video
Future<List<VideoMetric>> fetchVideoMetrics(String videoId) async {
  try {
    final videoMetricRepository = VideoMetricRepository();
    final metrics = await videoMetricRepository.getVideoMetrics(videoId);
    return metrics;
  } catch (e) {
    print('Error fetching video metrics: $e');
    return [];
  }
}
