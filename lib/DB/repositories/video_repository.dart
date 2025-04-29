import '../models/video.dart';
import '../controllers/database_helper.dart';

/// Repository class for managing Video data in the database.
///
/// This class provides methods for CRUD operations on Video objects.
class VideoRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Retrieves all videos for a specific user.
  ///
  /// Args:
  ///   userId (String): The unique identifier of the user whose videos to retrieve.
  ///
  /// Returns:
  ///   List(Video): A list of all videos belonging to the user.
  Future<List<Video>> getUserVideos(String userId) async {
    final videos = await _dbHelper.getUserVideos(userId);
    return videos.map((map) => Video.fromMap(map)).toList();
  }

  /// Retrieves a specific video by its ID.
  ///
  /// Args:
  ///   userId (String): The unique identifier of the user who owns the video.
  ///   videoId (String): The unique identifier of the video to retrieve.
  ///
  /// Returns:
  ///   Video?: The video if found, null otherwise.
  Future<Video?> getVideoById(String userId, String videoId) async {
    final videos = await _dbHelper.getUserVideos(userId);
    final videoMap = videos.firstWhere(
      (map) => map['video_id'] == videoId,
      orElse: () => {},
    );
    return videoMap.isEmpty ? null : Video.fromMap(videoMap);
  }

  /// Adds a new video to a user's collection.
  ///
  /// Args:
  ///   userId (String): The unique identifier of the user who owns the video.
  ///   video (Video): The video object to add to the database.
  ///
  /// Returns:
  ///   void
  Future<void> addVideo(String userId, Video video) async {
    await _dbHelper.addVideo(userId, video.toMap());
  }

  /// Updates an existing video in the database.
  ///
  /// Args:
  ///   userId (String): The unique identifier of the user who owns the video.
  ///   video (Video): The updated video object.
  ///
  /// Returns:
  ///   void
  Future<void> updateVideo(String userId, Video video) async {
    await _dbHelper.updateVideoStats(userId, video.videoId, video.toMap());
  }

  /// Deletes a video and its associated metrics from the database.
  ///
  /// Args:
  ///   userId (String): The unique identifier of the user who owns the video.
  ///   videoId (String): The unique identifier of the video to delete.
  ///
  /// Returns:
  ///   void
  ///
  /// Throws:
  ///   Exception: If the deletion fails.
  Future<void> deleteVideo(String userId, String videoId) async {
    try {
      await _dbHelper.deleteVideo(userId, videoId);
    } catch (e) {
      throw Exception('Failed to delete video: $e');
    }
  }
}
