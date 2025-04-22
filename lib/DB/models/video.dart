class Video {
  final String videoId;
  final String userId;
  final String videoName;
  final int views;
  final int subs;
  final double revenue;
  final int comments;
  final int watchtime;
  final DateTime creationDate;

  Video({
    required this.videoId,
    required this.userId,
    required this.videoName,
    required this.views,
    required this.subs,
    required this.revenue,
    required this.comments,
    required this.watchtime,
    required this.creationDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'video_id': videoId,
      'user_id': userId,
      'video_name': videoName,
      'views': views,
      'subs': subs,
      'revenue': revenue,
      'comments': comments,
      'watchtime': watchtime,
      'creation_date': creationDate.toIso8601String(),
    };
  }

  factory Video.fromMap(Map<String, dynamic> map) {
    return Video(
      videoId: map['video_id'],
      userId: map['user_id'],
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
