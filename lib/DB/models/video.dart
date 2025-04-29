/// A model class representing a YouTube video.
///
/// This class contains all the information about a single YouTube video,
/// including its metadata and performance metrics.
class Video {
  /// Unique identifier for the video
  final String videoId;

  /// Name/title of the video
  final String videoName;

  /// Total number of views
  final int views;

  /// Number of subscribers gained from this video
  final int subs;

  /// Revenue earned from this video in dollars
  final double revenue;

  /// Number of comments on the video
  final int comments;

  /// Total watch time in minutes
  final int watchtime;

  /// Date when the video was published
  final DateTime creationDate;

  /// Creates a new Video instance.
  ///
  /// All parameters are required and cannot be null.
  Video({
    required this.videoId,
    required this.videoName,
    required this.views,
    required this.subs,
    required this.revenue,
    required this.comments,
    required this.watchtime,
    required this.creationDate,
  });

  /// Converts the Video object to a Map for database storage.
  ///
  /// Returns a Map containing all video data with appropriate keys.
  Map<String, dynamic> toMap() {
    return {
      'video_id': videoId,
      'video_name': videoName,
      'views': views,
      'subs': subs,
      'revenue': revenue,
      'comments': comments,
      'watchtime': watchtime,
      'creation_date': creationDate.toIso8601String(),
    };
  }

  /// Creates a Video instance from a Map.
  ///
  /// [map] should contain all required video data with appropriate keys.
  /// Returns a new Video instance with data from the map.
  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
      videoId: map['video_id'],
      videoName: map['video_name'],
      views: map['views'],
      subs: map['subs'],
      revenue: map['revenue'],
      comments: map['comments'],
      watchtime: map['watchtime'],
      creationDate: DateTime.parse(map['creation_date']),
    );
  }
}
