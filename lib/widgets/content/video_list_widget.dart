import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../dashboard/line_graph.dart';
import '../../DB/controllers/database_helper.dart';
import '../../theme/app_theme.dart'; // Import the theme

// Keep the utility functions
List<String> Get_dates_onwards(String startDateStr) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  // Parse the input date string to a DateTime object
  DateTime startDate = formatter.parse(startDateStr);

  // Generate 30 sequential dates starting from the given date
  List<String> sequentialDates = List.generate(30, (i) {
    DateTime date = startDate.add(Duration(days: i));
    return formatter.format(date);
  });

  return sequentialDates;
}

String _formatWatchTime(int seconds) {
  int hours = seconds ~/ 3600;

  if (hours >= 1000000) {
    return '${(hours / 1000000).toStringAsFixed(1)}M hrs';
  } else if (hours >= 1000) {
    return '${(hours / 1000).toStringAsFixed(1)}K hrs';
  } else {
    return '$hours hrs';
  }
}

// Fixed function to properly use database metrics and avoid random data generation
Widget videoStatisticsGraphsWithDates(BuildContext context, String videoId,
    Map<String, List<DayMetric>> videoMetricsMap) {
  double chartHeight = MediaQuery.of(context).size.height > 600 ? 300 : 200;

  String defaultStartDate = DateFormat('yyyy-MM-dd')
      .format(DateTime.now().subtract(Duration(days: 30)));
  String startDate = defaultStartDate;

  int totalDays = 30;
  List<int> views = List.filled(totalDays, 0);
  List<int> wchtime = List.filled(totalDays, 0);

  if (videoMetricsMap.containsKey(videoId) &&
      videoMetricsMap[videoId]!.isNotEmpty) {
    List<DayMetric> metrics = videoMetricsMap[videoId]!;
    metrics.sort((a, b) => a.date.compareTo(b.date));
    startDate = metrics.first.date;

    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    DateTime startDateTime = formatter.parse(startDate);

    for (DayMetric metric in metrics) {
      DateTime metricDate = formatter.parse(metric.date);
      int dayIndex = metricDate.difference(startDateTime).inDays;

      if (dayIndex >= 0 && dayIndex < totalDays) {
        views[dayIndex] = metric.views;
        wchtime[dayIndex] = metric.watchtime;
      }
    }
  }

  List<String> dates = Get_dates_onwards(startDate);

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 195, 214, 241),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(128, 128, 128, 0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: buildLineChart(dates.length, views, dates, "Date", "Views",
                "Views", chartHeight),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: buildLineChart(dates.length, wchtime, dates, "Date", "Wt (hrs)",
                "Watch Time", chartHeight),
          ),
        ],
      ),
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

enum SortCriteria { views, revenue, watchtime, subscribers, date }

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
    this.thumbnailPath = "imgs/thumbnail_1.jpg", // Default thumbnail
  });
}

class DayMetric {
  final String date;
  final int views;
  final int watchtime;

  DayMetric({
    required this.date,
    required this.views,
    required this.watchtime,
  });
}

class _VideoListWidgetState extends State<VideoListWidget> {
  List<int> clickedIndexes = []; // Track the indexes where videos are clicked
  List<VideoData> videos = [];
  bool isLoading = true;
  String currentUserId = '';
  String errorMessage = '';
  SortCriteria currentSortCriteria = SortCriteria.views;
  bool ascending = false;

  // Add this property to store video metrics
  Map<String, List<DayMetric>> videoMetrics = {};

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
        // Use the userId passed from the ContentScreen
        currentUserId = widget.userId!;
        await _loadVideos(currentUserId);
      } else {
        // Fallback to the first user if none is provided
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

      List<VideoData> loadedVideos = [];
      Map<String, List<DayMetric>> loadedVideoMetrics =
          {}; // Stores daily metrics for each video

      for (var video in userVideos) {
        final videoId = video['video_id'] as String;

        try {
          // Fetch daily metrics from the database
          List<Map<String, dynamic>> metrics = [];

          // Wrap the database call in a try-catch to handle any database errors
          try {
            metrics = await DatabaseHelper.instance.getVideoMetrics(videoId);
          } catch (dbError) {
            // If there's a database error, just log it and continue with empty metrics
            print(
                'Database error fetching metrics for video $videoId: $dbError');
            metrics = []; // Reset to empty list
          }

          // Process metrics if available
          if (metrics.isNotEmpty) {
            // Create a mutable copy of the metrics list first
            var mutableMetrics = List<Map<String, dynamic>>.from(metrics);

            // Sort metrics by date (ascending)
            mutableMetrics.sort(
                (a, b) => (a['day'] as String).compareTo(b['day'] as String));

            // Take last 30 entries or all if fewer than 30
            final last30 = mutableMetrics.length > 30
                ? mutableMetrics.sublist(mutableMetrics.length - 30)
                : mutableMetrics;

            // Convert raw metrics into DayMetric objects
            final List<DayMetric> dailyMetrics = [];

            for (var entry in last30) {
              dailyMetrics.add(DayMetric(
                date: entry['day'] as String,
                views: entry['day_views'] as int,
                watchtime: entry['watchtime'] as int,
              ));
            }

            loadedVideoMetrics[videoId] = dailyMetrics;
          } else {
            // If no metrics found, create an empty array instead of having no key
            loadedVideoMetrics[videoId] = [];
          }
        } catch (metricError) {
          // Just log the error and continue - we'll use an empty array for this video
          print('Failed to load metrics for video $videoId: $metricError');
          loadedVideoMetrics[videoId] = [];
        }

        // Create and add VideoData object to the list
        loadedVideos.add(VideoData(
          videoId: videoId,
          videoName: video['video_name'] as String,
          views: video['views'] as int,
          subscribers: video['subs'] as int,
          revenue: video['revenue'] as double,
          comments: video['comments'] as int,
          watchtime: video['watchtime'] as int,
          creationDate: video['creation_date'] as String,
          thumbnailPath: "imgs/thumbnail_${Random().nextInt(4) + 1}.jpg",
        ));
      }

      // Save state
      setState(() {
        videos = loadedVideos;
        videoMetrics = loadedVideoMetrics; // Store the metrics in state
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading videos: $e';
        isLoading = false;
      });
    }
  }

  void _sortVideos(List<VideoData> videoList, SortCriteria criteria, bool asc) {
    switch (criteria) {
      case SortCriteria.views:
        videoList.sort((a, b) =>
            asc ? a.views.compareTo(b.views) : b.views.compareTo(a.views));
        break;
      case SortCriteria.revenue:
        videoList.sort((a, b) => asc
            ? a.revenue.compareTo(b.revenue)
            : b.revenue.compareTo(a.revenue));
        break;
      case SortCriteria.watchtime:
        videoList.sort((a, b) => asc
            ? a.watchtime.compareTo(b.watchtime)
            : b.watchtime.compareTo(a.watchtime));
        break;
      case SortCriteria.subscribers:
        videoList.sort((a, b) => asc
            ? a.subscribers.compareTo(b.subscribers)
            : b.subscribers.compareTo(a.subscribers));
        break;
      case SortCriteria.date:
        videoList.sort((a, b) => asc
            ? a.creationDate.compareTo(b.creationDate)
            : b.creationDate.compareTo(a.creationDate));
        break;
    }
  }

  void onSortChanged(SortCriteria criteria) {
    setState(() {
      // If selecting the same criteria again, toggle the sort direction
      if (currentSortCriteria == criteria) {
        ascending = !ascending;
      } else {
        // New criteria selected, default to descending (false)
        currentSortCriteria = criteria;
        ascending = false;
      }
      _sortVideos(videos, currentSortCriteria, ascending);
    });
  }

  void onVideoTap(BuildContext context, int index, String videoName) {
    setState(() {
      if (clickedIndexes.contains(index)) {
        // If the video was clicked again, remove it from the list
        clickedIndexes.remove(index);
      } else {
        // If the video wasn't clicked yet, add it to the list
        clickedIndexes.add(index);
      }
    });
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  Widget _buildSortButton(SortCriteria criteria, String text, IconData icon) {
    final bool isSelected = currentSortCriteria == criteria;

    return StatefulBuilder(builder: (context, setState) {
      bool isHovering = false;
      bool isPressed = false;

      return MouseRegion(
        onEnter: (_) => setState(() => isHovering = true),
        onExit: (_) => setState(() => isHovering = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onSortChanged(criteria),
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) => setState(() => isPressed = false),
          onTapCancel: () => setState(() => isPressed = false),
          child: Transform.scale(
            scale: isPressed ? 0.97 : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Color.fromARGB(255, 42, 76, 134)
                    : (isHovering ? Color.fromARGB(255, 195, 214, 241) : Colors.white),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: isHovering
                        ? Color.fromARGB(255, 42, 76, 134)
                        : Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, isPressed ? 0.02 : 0.05),
                    spreadRadius: isPressed ? 0 : 1,
                    blurRadius: isPressed ? 1 : 2,
                    offset: Offset(0, isPressed ? 0 : 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isSelected ? Colors.white : Color.fromARGB(255, 42, 76, 134),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    text,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Color.fromARGB(255, 42, 76, 134),
                      fontWeight: isHovering || isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSortMenu() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          const Text(
            'Sort by:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortButton(
                      SortCriteria.views, 'Views', Icons.visibility),
                  const SizedBox(width: 8),
                  _buildSortButton(
                      SortCriteria.subscribers, 'Subscribers', Icons.people),
                  const SizedBox(width: 8),
                  _buildSortButton(
                      SortCriteria.watchtime, 'Watch Time', Icons.access_time),
                  const SizedBox(width: 8),
                  _buildSortButton(
                      SortCriteria.revenue, 'Revenue', Icons.attach_money),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          StatefulBuilder(builder: (context, setState) {
            bool isHovering = false;
            bool isPressed = false;

            return MouseRegion(
              onEnter: (_) => setState(() => isHovering = true),
              onExit: (_) => setState(() => isHovering = false),
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  this.setState(() {
                    ascending = !ascending;
                    _sortVideos(videos, currentSortCriteria, ascending);
                  });
                },
                onTapDown: (_) => setState(() => isPressed = true),
                onTapUp: (_) => setState(() => isPressed = false),
                onTapCancel: () => setState(() => isPressed = false),
                child: Transform.scale(
                  scale: isPressed ? 0.95 : 1.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 42, 76, 134),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: isHovering
                              ? Colors.grey.shade400
                              : Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Color.fromRGBO(0, 0, 0, isPressed ? 0.02 : 0.05),
                          spreadRadius: isPressed ? 0 : 1,
                          blurRadius: isPressed ? 1 : 2,
                          offset: Offset(0, isPressed ? 0 : 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      ascending ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;

        // Responsive sizing
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

        const baseColor = Colors.white;
        const clickedColor = Color.fromARGB(255, 245, 245, 245);

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

        List<Widget> contentWidgets = [
          _buildSortMenu(),
        ];

        for (int i = 0; i < videos.length; i++) {
          final video = videos[i];
          contentWidgets.add(
            GestureDetector(
              onTap: () {
                onVideoTap(context, i, video.videoName);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(vertical: spacing / 2),
                padding: videoPadding,
                decoration: BoxDecoration(
                  color:
                      clickedIndexes.contains(i) ? clickedColor : Colors.white,
                  border: Border.all(
                      color: const Color.fromRGBO(0, 0, 0, 0.1), width: 1),
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.05),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
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
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              const Icon(Icons.date_range,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                DateFormat('yyyy-MM-dd')
                                    .format(DateTime.parse(video.creationDate)),
                                style: TextStyle(
                                  fontSize: dateFontSize,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 30),
                              const Icon(Icons.visibility,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                _formatNumber(video.views),
                                style: TextStyle(
                                  fontSize: dateFontSize,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 30),
                              Icon(Icons.comment,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text(
                                _formatNumber(video.comments),
                                style: TextStyle(
                                  fontSize: dateFontSize,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 30),
                              Icon(Icons.attach_money,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text(
                                 _formatNumber(video.revenue.toInt()),
                                style: TextStyle(
                                  fontSize: dateFontSize,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 30),
                              Icon(Icons.access_time,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text(
                                _formatWatchTime(video.watchtime),
                                style: TextStyle(
                                  fontSize: dateFontSize,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

          // If the current video is clicked, add the videoStatisticsGraphs widget below it
          if (clickedIndexes.contains(i)) {
            contentWidgets.add(
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Center(
                  child: SizedBox(
                    width: screenWidth / 2,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 800),
                      opacity: 1.0,
                      // Pass the actual video metrics data from our state
                      child: videoStatisticsGraphsWithDates(
                          context, video.videoId, videoMetrics),
                    ),
                  ),
                ),
              ),
            );
          }
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 195, 214, 241),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: const Color.fromRGBO(0, 0, 0, 0.1), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: contentWidgets,
            ),
          ),
        );
      },
    );
  }
}
