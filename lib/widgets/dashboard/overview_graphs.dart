import 'package:flutter/material.dart';
import 'line_graph.dart';
import '../../screens/content_screen.dart'; // import ContentScreen
import 'package:intl/intl.dart';
import '../../login/user_session.dart';
import '../../../DB/API/db_api.dart';
import '../../../DB/API/Widget_database_utility.dart';
import '../../../DB/models/video.dart'; //ONLY FOR VIDEO TYPE OBJECT

// Metrics().video[2][4].dayViews

class Videos {
  // Singleton instance
  static final Videos _instance = Videos._internal();
  factory Videos() => _instance;

  // Private constructor
  Videos._internal();

  // List to hold video data (up to 5 videos)
  late List<Video> videoList;

  bool _isInitialized = false;

  // Method to initialize the video data session
  Future<void> initialize(String userId) async {
    if (_isInitialized) return;

    // Fetch user videos using the provided userId
    final videos = await fetchUserVideos(userId);
    if (videos.isNotEmpty) {
      videoList = videos;

      // Ensure we have a maximum of 5 videos in the list
      if (videoList.length > 5) {
        videoList = videoList.sublist(0, 5);
      }

      _isInitialized = true;
    } else {
      throw Exception("No videos found for user ID: $userId");
    }
  }
}

// Updated TopVideosWidget with dynamic parameters
class TopVideosWidget extends StatefulWidget {
  final String channelName;
  final String channelDescription;
  final String profileImageUrl;
  final String? userId;

  const TopVideosWidget(
      this.channelName, this.channelDescription, this.profileImageUrl,
      {super.key, this.userId});

  @override
  State<TopVideosWidget> createState() => _TopVideosWidgetState();
}

class _TopVideosWidgetState extends State<TopVideosWidget> {
  bool isHovered = false;
  late String _userId;

  @override
  void initState() {
    super.initState();

    _userId = widget.userId ??
        UserSession().currentUserId ??
        'b4fc101f-a404-49e3-a7f7-4f83bc0e38e8';

    _loadVideos(); // <-- initialize the Videos singleton
  }

  Future<void> _loadVideos() async {
    try {
      await Videos().initialize(_userId);

      // Extract video IDs from the initialized video list
      final videoIds =
          Videos().videoList.map((video) => video.videoId).toList();

      // Ensure we pass exactly 5 videos (you already trimmed it earlier)
      if (videoIds.length == 5) {
        await Metrics().loadMetrics(videoIds);
      } else {
        throw Exception("Expected exactly 5 videos, got ${videoIds.length}");
      }

      setState(() {}); // Rebuild the widget after data is loaded
    } catch (e) {
      print('Error initializing videos and metrics: $e');
    }
  }

  void onTopVideosTap() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ContentScreen(
          channelName: widget.channelName,
          channelDescription: widget.channelDescription,
          profileImageUrl: widget.profileImageUrl,
          userId: _userId,
          onProfileUpdate: (name, desc, url) {
            // handle the update if needed
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double imageHeight = screenWidth > 600 ? 70 : 50;
    double nameFontSize = screenWidth > 600 ? 20 : 16;
    double dateFontSize = screenWidth > 600 ? 16 : 12;

    const baseColor = Color.fromARGB(255, 241, 241, 241);
    final hoverColor = baseColor.withOpacity(0.94);

    //HARDCODED VALUES --------------------------------------------------------------------------------------------------

    List<String> imgPaths = [
      "imgs/thumbnail_1.jpg",
      "imgs/thumbnail_2.jpg",
      "imgs/thumbnail_3.jpg",
      "imgs/thumbnail_4.jpg",
      "imgs/thumbnail_3.jpg",
    ];

    //HARDCODED VALUES END --------------------------------------------------------------------------------------------------

    List<Widget> imgWidgets = [];

    imgWidgets.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Text(
          "Top Videos",
          style: TextStyle(
              fontSize: nameFontSize + 4, fontWeight: FontWeight.bold),
        ),
      ),
    );

    for (int i = 0; i < imgPaths.length; i++) {
      imgWidgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                imgPaths[i],
                fit: BoxFit.cover,
                height: imageHeight,
                width: imageHeight * 1.6,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Videos().videoList[i].videoName,
                      style: TextStyle(
                          fontSize: nameFontSize, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.date_range,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          Format_date(
                              Videos().videoList[i].creationDate.toString()),
                          style: TextStyle(
                            fontSize: dateFontSize,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 30),
                        Icon(Icons.visibility,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          numberFormatter.format(Videos().videoList[i].views),
                          style: TextStyle(
                            fontSize: dateFontSize,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 30),
                        Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          numberFormatter
                              .format(Videos().videoList[i].comments),
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
                          numberFormatter.format(Videos().videoList[i].revenue),
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
                          _formatWatchTime(Videos().videoList[i].watchtime),
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
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Material(
        color: isHovered ? hoverColor : baseColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTopVideosTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.grey.withOpacity(0.3),
          highlightColor: Colors.grey.withOpacity(0.15),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: const Border(
                bottom: BorderSide(color: Colors.grey, width: 1.5),
                left: BorderSide(color: Colors.grey, width: 1.5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: imgWidgets,
            ),
          ),
        ),
      ),
    );
  }
}

final numberFormatter = NumberFormat.compact();

String Format_date(String Date) {
  final fullDate = DateTime.parse(Date);
  final dateString =
      '${fullDate.year}-${fullDate.month.toString().padLeft(2, '0')}-${fullDate.day.toString().padLeft(2, '0')}';
  return dateString;
}

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
  return '$hours hrs';
}

Widget overview_graphs(BuildContext context, String CreationDate) {
  int totalDays = 30;
  List<int> views1 = sumDailyViews();
  List<int> watchTime = sumDailyWatchTime();
  List<int> impressions = sumDailyImpressions();
  List<int> CTR = sumDailyCTR();
  List<String> dates = Get_dates_onwards(CreationDate);

  double chartHeight = MediaQuery.of(context).size.height > 600 ? 300 : 200;

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildLineChart(totalDays, views1, dates, "Date", "Views", "Views",
                chartHeight),
            const SizedBox(height: 24),
            buildLineChart(totalDays, impressions, dates, "Date", "Wt (hrs)",
                "Watch Time", chartHeight),
          ],
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildLineChart(totalDays, watchTime, dates, "Date", "Impressions",
                "Impressions", chartHeight),
            const SizedBox(height: 24),
            buildLineChart(totalDays, CTR, dates, "Date", "CTR (%)",
                "Click-Through Rate", chartHeight),
          ],
        ),
      ),
    ],
  );
}

Widget over_view_widget(String channelName, String channelDescription,
    String profileImageUrl, String CreationDate,
    {String? userId}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      bool isWideScreen = constraints.maxWidth > 800;

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
              top: 16.0, right: 16.0, bottom: 16.0), // Removed left padding
          child: isWideScreen
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: overview_graphs(context, CreationDate)),
                    const SizedBox(width: 32),
                    Expanded(
                        child: TopVideosWidget(
                            channelName, channelDescription, profileImageUrl,
                            userId: userId)),
                  ],
                )
              : Column(
                  children: [
                    overview_graphs(context, CreationDate),
                    const SizedBox(height: 32),
                    TopVideosWidget(
                        channelName, channelDescription, profileImageUrl,
                        userId: userId),
                  ],
                ),
        ),
      );
    },
  );
}
