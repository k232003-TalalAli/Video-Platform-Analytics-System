import 'package:flutter/material.dart';
import 'dart:math';
import '../../screens/content_screen.dart'; // import ContentScreen
import 'package:intl/intl.dart';
import '../../login/user_session.dart';

import 'line_graph.dart';

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

Widget overview_graphs(BuildContext context) {
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

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildLineChart(totalDays, views1,dates1, "Date", "Views", "Views", chartHeight),
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
  );
}

// Updated TopVideosWidget with dynamic parameters
class TopVideosWidget extends StatefulWidget {
  final String channelName;
  final String channelDescription;
  final String profileImageUrl;
  final String? userId;

  const TopVideosWidget(
    this.channelName, 
    this.channelDescription, 
    this.profileImageUrl, 
    {super.key, this.userId}
  );

  @override
  State<TopVideosWidget> createState() => _TopVideosWidgetState();
}

class _TopVideosWidgetState extends State<TopVideosWidget> {
  bool isHovered = false;
  late String _userId;

  @override
  void initState() {
    super.initState();
    _userId = widget.userId ?? UserSession().currentUserId ?? 'b4fc101f-a404-49e3-a7f7-4f83bc0e38e8';
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
      "imgs/thumbnail_4.jpg"
    ];

    List<String> imgNames = [
      "this is a placeholder. only here to simulate",
      "bro this sum gud shit",
      "this is a placeholder. only here to simulate, replace this with actual names",
      "ala larkey, mja aagya lmaoooo",
      "this is a placeholder. only here to simulate, replace this with actual video names",
      "bro this sum gud shit",
    ];

    List<String> imgDates = [
      "2025-04-01",
      "2025-04-05",
      "2025-04-10",
      "2025-05-10",
      "2025-04-10",
      "2025-04-05",
    ];

    
    String commentsRevHardcoded="100";
    String watchTime="100 hrs";
    String Views="120K";

      //HARDCODED VALUES END --------------------------------------------------------------------------------------------------

    List<Widget> imgWidgets = [];

    imgWidgets.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Text(
          "Top Videos",
          style: TextStyle(fontSize: nameFontSize + 4, fontWeight: FontWeight.bold),
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
                      imgNames[i],
                      style: TextStyle(fontSize: nameFontSize, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Row(
                            children: [
                              Icon(Icons.date_range, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text(
                                imgDates[i],
                                style: TextStyle(
                                  fontSize: dateFontSize,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 30), // More horizontal space
                              Icon(Icons.visibility, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text(
                                Views,
                                style: TextStyle(
                                  fontSize: dateFontSize,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 30),
                              Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text(
                               commentsRevHardcoded,
                                style: TextStyle(
                                  fontSize: dateFontSize,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 30),
                              Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text(
                              commentsRevHardcoded,
                                style: TextStyle(
                                  fontSize: dateFontSize,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(width: 30),
                              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text(
                                watchTime,
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

Widget over_view_widget(String channelName, String channelDescription, String profileImageUrl, {String? userId}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      bool isWideScreen = constraints.maxWidth > 800;

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 16.0, right: 16.0, bottom: 16.0), // Removed left padding
          child: isWideScreen
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: overview_graphs(context)),
                    const SizedBox(width: 32),
                    Expanded(child: TopVideosWidget(channelName, channelDescription, profileImageUrl, userId: userId)),
                  ],
                )
              : Column(
                  children: [
                    overview_graphs(context),
                    const SizedBox(height: 32),
                    TopVideosWidget(channelName, channelDescription, profileImageUrl, userId: userId),
                  ],
                ),
        ),
      );
    },
  );
}