import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../dashboard/line_graph.dart';
import '../../DB/controllers/database_helper.dart';

List<int> generateRandomList(int numberOfValues, int max) {
  final random = Random();
  return List<int>.generate(numberOfValues, (_) => random.nextInt(max + 1));
}

List<String> generateRandomDates(int n) {
  final Random random = Random();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');

  // Pick a random starting date within the past 90 days
  final DateTime now = DateTime.now();
  final int daysAgo = random.nextInt(90);
  DateTime startDate = now.subtract(Duration(days: daysAgo));

  // Generate sequential dates
  List<String> sequentialDates = List.generate(n, (i) {
    DateTime date = startDate.add(Duration(days: i));
    return formatter.format(date);
  });

  return sequentialDates;
}

Widget videoStatisticsGraphs(BuildContext context) {
  int totalDays = 30;
  List<int> views1 = generateRandomList(totalDays, 5000);
  List<int> views2 = generateRandomList(totalDays, 134);
  List<int> views3 = generateRandomList(totalDays, 500);
  List<int> views4 = generateRandomList(totalDays, 90);

  List<String>  dates1 = generateRandomDates(totalDays);
  List<String>  dates2 = generateRandomDates(totalDays);
  List<String>  dates3 = generateRandomDates(totalDays);
  List<String>  dates4 = generateRandomDates(totalDays);

  double chartHeight = MediaQuery.of(context).size.height > 600 ? 300 : 200;

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(128, 128, 128, 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildLineChart(totalDays, views1, dates1, "Date", "Views", "Views", chartHeight),
                const SizedBox(height: 24),
                buildLineChart(totalDays, views3, dates2, "Date", "Wt (hrs)", "Watch Time", chartHeight),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                buildLineChart(totalDays, views2, dates3, "Date", "Subscribers", "Subscribers", chartHeight),
                const SizedBox(height: 24),
                buildLineChart(totalDays, views4, dates4, "Date", "\$ Earned", "Estimated Revenue", chartHeight),
              ],
            ),
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

enum SortCriteria {
  views,
  revenue,
  watchtime,
  subscribers,
  date
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
    this.thumbnailPath = "imgs/thumbnail_1.jpg", // Default thumbnail
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
      
      // Convert database data to VideoData objects
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
          // Randomly select one of the available thumbnails for demonstration
          thumbnailPath: "imgs/thumbnail_${Random().nextInt(4) + 1}.jpg",
        );
      }).toList();

      // Sort initially by views (descending)
      _sortVideos(loadedVideos, SortCriteria.views, false);

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

  void _sortVideos(List<VideoData> videoList, SortCriteria criteria, bool asc) {
    switch (criteria) {
      case SortCriteria.views:
        videoList.sort((a, b) => asc ? a.views.compareTo(b.views) : b.views.compareTo(a.views));
        break;
      case SortCriteria.revenue:
        videoList.sort((a, b) => asc ? a.revenue.compareTo(b.revenue) : b.revenue.compareTo(a.revenue));
        break;
      case SortCriteria.watchtime:
        videoList.sort((a, b) => asc ? a.watchtime.compareTo(b.watchtime) : b.watchtime.compareTo(a.watchtime));
        break;
      case SortCriteria.subscribers:
        videoList.sort((a, b) => asc ? a.subscribers.compareTo(b.subscribers) : b.subscribers.compareTo(a.subscribers));
        break;
      case SortCriteria.date:
        videoList.sort((a, b) => asc ? a.creationDate.compareTo(b.creationDate) : b.creationDate.compareTo(a.creationDate));
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

  String _formatWatchTime(int seconds) {
    int hours = seconds ~/ 3600;
    return '$hours hrs';
  }

  Widget _buildSortButton(SortCriteria criteria, String text, IconData icon) {
    final bool isSelected = currentSortCriteria == criteria;
    
    return StatefulBuilder(
      builder: (context, setState) {
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
                  color: isSelected ? Colors.black : (isHovering ? Colors.grey.shade100 : Colors.white),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isHovering ? Colors.grey.shade400 : Colors.grey.shade300
                  ),
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
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      text,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: isHovering || isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
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
                  _buildSortButton(SortCriteria.views, 'Views', Icons.visibility),
                  const SizedBox(width: 8),
                  _buildSortButton(SortCriteria.subscribers, 'Subscribers', Icons.people),
                  const SizedBox(width: 8),
                  _buildSortButton(SortCriteria.watchtime, 'Watch Time', Icons.access_time),
                  const SizedBox(width: 8),
                  _buildSortButton(SortCriteria.revenue, 'Revenue', Icons.attach_money),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          StatefulBuilder(
            builder: (context, setState) {
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
                        color: isHovering ? Colors.grey.shade100 : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isHovering ? Colors.grey.shade400 : Colors.grey.shade300
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, isPressed ? 0.02 : 0.05),
                            spreadRadius: isPressed ? 0 : 1,
                            blurRadius: isPressed ? 1 : 2,
                            offset: Offset(0, isPressed ? 0 : 1),
                          ),
                        ],
                      ),
                      child: Icon(
                        ascending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              );
            }
          ),
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
        final clickedColor = const Color.fromARGB(255, 245, 245, 245);

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (errorMessage.isNotEmpty) {
          return Center(child: Text(errorMessage, style: const TextStyle(color: Colors.red)));
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
                  color: clickedIndexes.contains(i) ? clickedColor : Colors.white,
                  border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.1), width: 1),
                  borderRadius: BorderRadius.circular(borderRadius),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
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
                          child: const Icon(Icons.video_library, color: Colors.white),
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
                              const Icon(Icons.date_range, size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                DateFormat('yyyy-MM-dd').format(DateTime.parse(video.creationDate)),
                                style: TextStyle(
                                  fontSize: dateFontSize,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 30),
                              const Icon(Icons.visibility, size: 16, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text(
                                _formatNumber(video.views),
                                style: TextStyle(
                                  fontSize: dateFontSize,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 30),
                              Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text(
                                _formatNumber(video.comments),
                                style: TextStyle(
                                  fontSize: dateFontSize,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 30),
                              Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text(
                                '\$${video.revenue.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: dateFontSize,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 30),
                              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
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
                      opacity: clickedIndexes.contains(i) ? 1.0 : 0.0,
                      child: videoStatisticsGraphs(context),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.1), width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
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
