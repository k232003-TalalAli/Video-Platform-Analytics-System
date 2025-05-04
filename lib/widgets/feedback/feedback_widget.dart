import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../../DB/controllers/database_helper.dart';
import '../dashboard/analytics_card.dart';

class VideoListWidget extends StatefulWidget {
  final String? userId;

  const VideoListWidget({
    super.key,
    this.userId,
  });

  @override
  State<VideoListWidget> createState() => _VideoListWidgetState();
}

class VideoData {
  final String videoId;
  final String videoName;
  final int views;
  final int subscribers;
  final double revenue;
  final int comments;
  final int watchtime;
  final String creationDate;
  final String thumbnailPath;

  VideoData({
    required this.videoId,
    required this.videoName,
    required this.views,
    required this.subscribers,
    required this.revenue,
    required this.comments,
    required this.watchtime,
    required this.creationDate,
    this.thumbnailPath = "imgs/thumbnail_1.jpg",
  });
}

class _VideoListWidgetState extends State<VideoListWidget> {
  bool isHovered = false;
  List<VideoData> videos = [];
  bool isLoading = true;
  String currentUserId = '';
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      if (widget.userId != null && widget.userId!.isNotEmpty) {
        currentUserId = widget.userId!;
        await _loadVideos(currentUserId);
      } else {
        final allUsers = await DatabaseHelper.instance.getAllUsers();
        if (allUsers.isEmpty) {
          setState(() {
            errorMessage = 'No users found in the database';
            isLoading = false;
          });
          return;
        }

        currentUserId = allUsers.first['user_id'] as String;
        await _loadVideos(currentUserId);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading user data: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadVideos(String userId) async {
    try {
      final userVideos = await DatabaseHelper.instance.getUserVideos(userId);
      List<VideoData> loadedVideos = userVideos.map((video) {
        return VideoData(
          videoId: video['video_id'] as String,
          videoName: video['video_name'] as String,
          views: video['views'] as int,
          subscribers: video['subs'] as int,
          revenue: video['revenue'] as double,
          comments: video['comments'] as int,
          watchtime: video['watchtime'] as int,
          creationDate: video['creation_date'] as String,
          thumbnailPath: "imgs/thumbnail_${Random().nextInt(4) + 1}.jpg",
        );
      }).toList();

      setState(() {
        videos = loadedVideos;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading videos: $e';
        isLoading = false;
      });
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _formatWatchTime(int seconds) {
    int hours = seconds ~/ 3600;
    return '$hours hrs';
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        double imageHeight = screenWidth > 800
            ? 90
            : screenWidth > 600
                ? 70
                : screenWidth > 400
                    ? 60
                    : 50;
        double nameFontSize = screenWidth > 800
            ? 22
            : screenWidth > 600
                ? 18
                : screenWidth > 400
                    ? 16
                    : 14;
        double dateFontSize = screenWidth > 800
            ? 16
            : screenWidth > 600
                ? 14
                : screenWidth > 400
                    ? 12
                    : 11;
        double spacing = screenWidth > 400 ? 16 : 8;
        double borderRadius = screenWidth > 400 ? 12 : 8;
        EdgeInsets videoPadding = screenWidth > 400
            ? const EdgeInsets.all(10)
            : const EdgeInsets.symmetric(horizontal: 8, vertical: 6);

        const baseColor = Color.fromARGB(255, 241, 241, 241);
        final hoverColor = baseColor.withOpacity(0.94);

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (errorMessage.isNotEmpty) {
          return Center(
              child: Text(errorMessage,
                  style: const TextStyle(color: Colors.red)));
        }

        if (videos.isEmpty) {
          return const Center(child: Text('No videos found for this user'));
        }

        List<Widget> contentWidgets = [];

        contentWidgets.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: AnalyticsCard(
                      title: 'Impressions',
                      value: '1.2M',
                      icon: Icons.trending_up,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: AnalyticsCard(
                      title: 'Click Through Rate',
                      value: '39%',
                      icon: Icons.bar_chart,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: AnalyticsCard(
                      title: 'Comments',
                      value: '45.3K',
                      icon: Icons.comment,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Stats per Video',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );

        for (int i = 0; i < videos.length; i++) {
          final video = videos[i];

          contentWidgets.add(
            Container(
              margin: EdgeInsets.symmetric(vertical: spacing / 2),
              padding: videoPadding,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                    color: const Color.fromARGB(255, 0, 0, 0), width: 2),
                borderRadius: BorderRadius.circular(borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.08),
                    blurRadius: 3,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT SIDE
                  Expanded(
                    flex: 2,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          video.thumbnailPath,
                          fit: BoxFit.cover,
                          height: imageHeight,
                          width: imageHeight * 1.6,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: imageHeight,
                              width: imageHeight * 1.6,
                              color: Colors.grey,
                              child: const Icon(Icons.video_library,
                                  color: Colors.white),
                            );
                          },
                        ),
                        SizedBox(width: spacing),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video.videoName,
                                style: TextStyle(
                                  fontSize: nameFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                runSpacing: 8,
                                spacing: 20,
                                children: [
                                  _infoItem(
                                      Icons.date_range,
                                      DateFormat('yyyy-MM-dd').format(
                                          DateTime.parse(video.creationDate)),
                                      dateFontSize),
                                  _infoItem(Icons.visibility,
                                      _formatNumber(video.views), dateFontSize),
                                  _infoItem(Icons.comment,
                                      _formatNumber(video.comments), dateFontSize),
                                  _infoItem(
                                      Icons.attach_money,
                                      '\$${video.revenue.toStringAsFixed(2)}',
                                      dateFontSize),
                                  _infoItem(Icons.access_time,
                                      _formatWatchTime(video.watchtime), dateFontSize),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: spacing * 2), // Extra spacing

                  // RIGHT SIDE
                  Flexible(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: AnalyticsCard(
                              title: 'Impressions',
                              value: '${Random().nextInt(9000) + 1000}',
                              icon: Icons.trending_up,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: AnalyticsCard(
                              title: 'CTR',
                              value:
                                  '${(Random().nextDouble() * 20 + 20).toStringAsFixed(1)}%',
                              icon: Icons.bar_chart,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isHovered ? hoverColor : baseColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.brown.shade300, width: 2),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: contentWidgets,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoItem(IconData icon, String value, double fontSize) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
