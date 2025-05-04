import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../dashboard/analytics_card.dart';
import '../dashboard/line_graph.dart';

List<int> generateRandomList(int numberOfValues, int max) {
  final random = Random();
  return List<int>.generate(numberOfValues, (_) => random.nextInt(max + 1));
}

List<String> Get_dates_onwards(String startDateStr) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  DateTime startDate = formatter.parse(startDateStr);
  List<String> sequentialDates = List.generate(30, (i) {
    DateTime date = startDate.add(Duration(days: i));
    return formatter.format(date);
  });

  return sequentialDates;
}

Widget overview_graphs(BuildContext context) {
  int totalDays = 30;
  List<int> CTR = generateRandomList(totalDays, 5000);
  List<int> impressions = generateRandomList(totalDays, 134);

  List<String> dates1 = Get_dates_onwards("2024-10-23");
  List<String> dates2 = Get_dates_onwards("2024-10-23");

  double chartHeight = MediaQuery.of(context).size.height > 600 ? 300 : 200;
  double chartWidth = MediaQuery.of(context).size.width * 0.4; // adjust as needed

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 25.0),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black87, width: 2),
      borderRadius: BorderRadius.circular(12),
      color: Color.fromARGB(255, 175, 215, 255)   ,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center, // Center graphs horizontally
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: chartWidth,
          child: buildLineChart(
              totalDays, CTR, dates1, "Day", "CTR", "CTR", chartHeight),
        ),
        const SizedBox(width: 16), // Space between graphs
        SizedBox(
          width: chartWidth,
          child: buildLineChart(totalDays, impressions, dates2, "Day",
              "Impressions", "Impressions", chartHeight),
        ),
      ],
    ),
  );
}



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
  final String impressions = '1.2M';
  final String ctr = '39%';
  final String commentsTotal = '45.3K';

  final List<VideoData> videos = [
    VideoData(
      videoId: 'vid1',
      videoName: 'Flutter Tutorial - Beginner to Advanced',
      views: 120000,
      subscribers: 1500,
      revenue: 230.50,
      comments: 230,
      watchtime: 12400,
      creationDate: '2024-05-01',
      thumbnailPath: 'imgs/thumbnail_1.jpg',
    ),
    VideoData(
      videoId: 'vid2',
      videoName: 'Building a Chat App with Firebase',
      views: 85000,
      subscribers: 1100,
      revenue: 180.00,
      comments: 190,
      watchtime: 9800,
      creationDate: '2024-05-10',
      thumbnailPath: 'imgs/thumbnail_2.jpg',
    ),
    VideoData(
      videoId: 'vid3',
      videoName: 'Dart Tips and Tricks',
      views: 43000,
      subscribers: 700,
      revenue: 95.75,
      comments: 85,
      watchtime: 5400,
      creationDate: '2024-05-15',
      thumbnailPath: 'imgs/thumbnail_3.jpg',
    ),
    VideoData(
      videoId: 'vid4',
      videoName: 'State Management with Provider',
      views: 67000,
      subscribers: 950,
      revenue: 142.25,
      comments: 178,
      watchtime: 8200,
      creationDate: '2024-04-28',
      thumbnailPath: 'imgs/thumbnail_1.jpg',
    ),
    VideoData(
      videoId: 'vid5',
      videoName: 'Creating Beautiful UI Animations',
      views: 93500,
      subscribers: 1250,
      revenue: 197.80,
      comments: 210,
      watchtime: 10700,
      creationDate: '2024-04-20',
      thumbnailPath: 'imgs/thumbnail_1.jpg',
    ),
  ];

  final Set<String> expandedVideos = {};
  final Random _random = Random();

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
                      value: impressions,
                      icon: Icons.trending_up,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AnalyticsCard(
                      title: 'Click Through Rate',
                      value: ctr,
                      icon: Icons.bar_chart,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AnalyticsCard(
                      title: 'Comments',
                      value: commentsTotal,
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

        for (var video in videos) {
          contentWidgets.add(
            GestureDetector(
              onTap: () {
                setState(() {
                  if (expandedVideos.contains(video.videoId)) {
                    expandedVideos.remove(video.videoId);
                  } else {
                    expandedVideos.add(video.videoId);
                  }
                });
              },
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: spacing / 2),
                    padding: videoPadding,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 211, 233, 255)   ,
                      border: Border.all(color: Colors.black, width: 2),
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
                                        color: Color.fromARGB(255, 211, 233, 255)   ,)
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
                                              DateTime.parse(
                                                  video.creationDate)),
                                          dateFontSize,
                                        ),
                                        _infoItem(
                                            Icons.visibility,
                                            _formatNumber(video.views),
                                            dateFontSize),
                                        _infoItem(
                                            Icons.comment,
                                            _formatNumber(video.comments),
                                            dateFontSize),
                                        _infoItem(
                                            Icons.attach_money,
                                            '\$${video.revenue.toStringAsFixed(2)}',
                                            dateFontSize),
                                        _infoItem(
                                            Icons.access_time,
                                            _formatWatchTime(video.watchtime),
                                            dateFontSize),
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
                                    value: '${90000}',
                                    icon: Icons.trending_up,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: AnalyticsCard(
                                    title: 'CTR',
                                    value:
                                        '${( 20 + 20).toStringAsFixed(1)}%',
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
                  if (expandedVideos.contains(video.videoId))
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 12.0, bottom: 20.0),
                      child: Column(
                        children: [
                          overview_graphs(context), // Show graphs here
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
        }

        return MouseRegion(
          onEnter: (_) => setState(() {}),
          onExit: (_) => setState(() {}),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: baseColor,
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
        const SizedBox(width: 6),
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