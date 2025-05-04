import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../dashboard/analytics_card.dart';
import '../dashboard/line_graph.dart';
import '../dashboard/overview_graphs.dart';
import '../../../DB/API/Widget_database_utility.dart';

List<String> Get_dates_onwards(String startDateStr) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  DateTime startDate = formatter.parse(startDateStr);
  List<String> sequentialDates = List.generate(30, (i) {
    DateTime date = startDate.add(Duration(days: i));
    return formatter.format(date);
  });

  return sequentialDates;
}

Widget overview_graphs(BuildContext context, String CreationDate, int video_index) {
  int totalDays = 30;
  List<int> CTR = getDailyCTRForVideo(video_index);
  List<int> impressions = getDailyImpressionsForVideo(video_index);

  List<String> dates = Get_dates_onwards(CreationDate);

  double chartHeight = MediaQuery.of(context).size.height > 600 ? 300 : 200;
  double chartWidth = MediaQuery.of(context).size.width * 0.4; // adjust as needed

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 25.0),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black87, width: 2),
      borderRadius: BorderRadius.circular(12),
      color: Color.fromARGB(255, 175, 215, 255),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center, // Center graphs horizontally
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: chartWidth,
          child: buildLineChart(
            totalDays,
            CTR,
            dates,
            "Day",
            "CTR (%)",
            "CTR",
            chartHeight,
          ),
        ),
        const SizedBox(width: 16), // Space between graphs
        SizedBox(
          width: chartWidth,
          child: buildLineChart(
            totalDays,
            impressions,
            dates,
            "Day",
            "Impressions",
            "Impressions",
            chartHeight,
          ),
        ),
      ],
    ),
  );
}

class VideoListWidget extends StatefulWidget {
  final String? userId;
  final String CreationDate;
  final int totalComments;

  const VideoListWidget({
    super.key,
    this.userId,
    required this.totalComments,
    required this.CreationDate,
  });

  @override
  State<VideoListWidget> createState() => _VideoListWidgetState();
}

List<String> imgPaths = [
  "imgs/thumbnail_1.jpg",
  "imgs/thumbnail_2.jpg",
  "imgs/thumbnail_3.jpg",
  "imgs/thumbnail_4.jpg",
  "imgs/thumbnail_3.jpg",
];

class _VideoListWidgetState extends State<VideoListWidget> {
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
                      value: _formatNumber(calculateTotalImpressions()),
                      icon: Icons.trending_up,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AnalyticsCard(
                      title: 'Click Through Rate',
                      value: calculateChannelCTR().toString() + "%",
                      icon: Icons.bar_chart,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AnalyticsCard(
                      title: 'Comments',
                      value: NumberFormat.compact().format(widget.totalComments),
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

        int index = -1;
        for (int i = 0; i < imgPaths.length; i++) {
          index++;
          contentWidgets.add(
            GestureDetector(
              onTap: () {
                setState(() {
                  String videoId = Videos().videoList[i].videoId;
                  if (expandedVideos.contains(videoId)) {
                    expandedVideos.remove(videoId);
                  } else {
                    expandedVideos.add(videoId);
                  }
                });
              },
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: spacing / 2),
                    padding: videoPadding,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 211, 233, 255),
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
                                imgPaths[i],
                                fit: BoxFit.cover,
                                height: imageHeight,
                                width: imageHeight * 1.6,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: imageHeight,
                                    width: imageHeight * 1.6,
                                    color: Colors.grey,
                                    child: const Icon(
                                      Icons.video_library,
                                      color: Color.fromARGB(255, 211, 233, 255),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(width: spacing),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Videos().videoList[i].videoName,
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
                                          Format_date(Videos()
                                              .videoList[i]
                                              .creationDate
                                              .toString()),
                                          dateFontSize,
                                        ),
                                        _infoItem(
                                          Icons.visibility,
                                          _formatNumber(Videos()
                                              .videoList[i]
                                              .views)
                                              .toString(),
                                          dateFontSize,
                                        ),
                                        _infoItem(
                                          Icons.comment,
                                          _formatNumber(Videos()
                                              .videoList[i]
                                              .comments)
                                              .toString(),
                                          dateFontSize,
                                        ),
                                        _infoItem(
                                          Icons.attach_money,
                                          Videos()
                                              .videoList[i]
                                              .revenue
                                              .toString(),
                                          dateFontSize,
                                        ),
                                        _infoItem(
                                          Icons.access_time,
                                          _formatWatchTime(Videos()
                                                  .videoList[i]
                                                  .watchtime)
                                              .toString(),
                                          dateFontSize,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: spacing * 2),
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
                                    value: _formatNumber(
                                        sumTotalImpressionsForVideo(index)),
                                    icon: Icons.trending_up,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: AnalyticsCard(
                                    title: 'CTR',
                                    value: calculateVideoCTR(index).toString() +
                                        "%",
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
                  if (expandedVideos.contains(Videos().videoList[i].videoId))
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 20.0),
                      child: Column(
                        children: [
                          overview_graphs(context, widget.CreationDate, index), // Show graphs here
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
