class User {
  final String userId;
  final String userName;
  final DateTime channelCreationDate;
  final String channelName;
  final int totalViews;
  final int totalSubs;
  final int totalComments;
  final int totalWatchtime;
  final double totalRevenue;
  final String channelImageLink;
  final String description;

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
