/// A model class representing a YouTube channel user.
///
/// This class contains all the information about a YouTube channel,
/// including basic information and aggregated statistics.
class User {
  /// Unique identifier for the user
  final String userId;

  /// Display name of the user
  final String userName;

  /// Date when the channel was created
  final DateTime channelCreationDate;

  /// Name of the YouTube channel
  final String channelName;

  /// Total number of views across all videos
  final int totalViews;

  /// Total number of subscribers
  final int totalSubs;

  /// Total number of comments across all videos
  final int totalComments;

  /// Total watch time in minutes
  final int totalWatchtime;

  /// Total revenue earned in dollars
  final double totalRevenue;

  /// URL to the channel's profile image
  final String channelImageLink;

  /// Channel description
  final String description;

  /// Creates a new User instance.
  ///
  /// All parameters are required and cannot be null.
  User({
    required this.userId,
    required this.userName,
    required this.channelCreationDate,
    required this.channelName,
    required this.totalViews,
    required this.totalSubs,
    required this.totalComments,
    required this.totalWatchtime,
    required this.totalRevenue,
    required this.channelImageLink,
    required this.description,
  });

  /// Converts the User object to a Map for database storage.
  ///
  /// Returns a Map containing all user data with appropriate keys.
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'user_name': userName,
      'channel_creation_date': channelCreationDate.toIso8601String(),
      'channel_name': channelName,
      'total_views': totalViews,
      'total_subs': totalSubs,
      'total_comments': totalComments,
      'total_watchtime': totalWatchtime,
      'total_revenue': totalRevenue,
      'channel_image_link': channelImageLink,
      'description': description,
    };
  }

  /// Creates a User instance from a Map.
  ///
  /// [map] should contain all required user data with appropriate keys.
  /// Returns a new User instance with data from the map.
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'],
      userName: map['user_name'],
      channelCreationDate: DateTime.parse(map['channel_creation_date']),
      channelName: map['channel_name'],
      totalViews: map['total_views'],
      totalSubs: map['total_subs'],
      totalComments: map['total_comments'],
      totalWatchtime: map['total_watchtime'],
      totalRevenue: map['total_revenue'],
      channelImageLink: map['channel_image_link'],
      description: map['description'],
    );
  }
}
