import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../dashboard/line_graph.dart';

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

Widget video_statistics_graphs(BuildContext context) {

        //HARDCODED VALUES  --------------------------------------------------------------------------------------------------

  int totalDays = 30;
  List<int> views1 = generateRandomList(totalDays, 5000);
  List<int> views2 = generateRandomList(totalDays, 134);
  List<int> views3 = generateRandomList(totalDays, 500);
  List<int> views4 = generateRandomList(totalDays, 90);

  List<String>  dates1 = generateRandomDates(totalDays);
  List<String>  dates2 = generateRandomDates(totalDays);
  List<String>  dates3 = generateRandomDates(totalDays);
  List<String>  dates4 = generateRandomDates(totalDays);

        //HARDCODED VALUES END --------------------------------------------------------------------------------------------------

  double chartHeight = MediaQuery.of(context).size.height > 600 ? 300 : 200;

  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 2),  // Changed to black and increased border width
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
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

class video_list_widget extends StatefulWidget {
  const video_list_widget({super.key});

  @override
  State<video_list_widget> createState() => _video_list_widgetState();
}

class _video_list_widgetState extends State<video_list_widget> {
  bool isHovered = false;
  List<int> clickedIndexes = []; // Track the indexes where videos are clicked

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

        const baseColor = Color.fromARGB(255, 241, 241, 241);
        final clickedColor = baseColor.withOpacity(0.7); // Increased opacity for more noticeable click effect
        final hoverColor = baseColor.withOpacity(0.94);

              //HARDCODED VALUES --------------------------------------------------------------------------------------------------

        List<String> imgPaths = [
          "imgs/thumbnail_1.jpg",
          "imgs/thumbnail_2.jpg",
          "imgs/thumbnail_3.jpg",
          "imgs/thumbnail_4.jpg",
          "imgs/thumbnail_3.jpg",

        ];

        List<String> imgNames = [
          "this is a placeholder. only here to simulate",
          "bro this sum gud shit",
          "this is a placeholder. only here to simulate, replace this with actual names",
          "ala larkey, mja aagya lmaoooo",
          "this is a placeholder. only here to simulate, replace this with actual video names",
        ];

        List<String> imgDates = [
          "2025-04-01",
          "2025-04-05",
          "2025-04-10",
          "2025-05-10",
          "2025-04-10",
        ];

        String comments_subs_rev_HARDCODED="100"; //this is supposed to be an array, im just displaying the same thing, so using just 1 variable for all
        String Watch_time="100 hrs";  //this is supposed to be an array, im just displaying the same thing, so using just 1 variable for all

              //HARDCODED VALUES END --------------------------------------------------------------------------------------------------

        List<Widget> imgWidgets = [];

        for (int i = 0; i < imgPaths.length; i++) {
          imgWidgets.add(
            GestureDetector(
              onTap: () {
                onVideoTap(context, i, imgNames[i]);
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300), // Smooth transition on click
                margin: EdgeInsets.symmetric(vertical: spacing / 2),
                padding: videoPadding,
                decoration: BoxDecoration(
                  color: clickedIndexes.contains(i) ? clickedColor : Colors.white, // More noticeable click effect
                  border: Border.all(color: const Color.fromARGB(255, 0, 0, 0), width: 2),
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
                    Image.asset(
                      imgPaths[i],
                      fit: BoxFit.cover,
                      height: imageHeight,
                      width: imageHeight * 1.6,
                    ),
                    SizedBox(width: spacing),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            imgNames[i],
                            style: TextStyle(
                              fontSize: nameFontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              Icon(Icons.date_range, size: 16, color: Colors.grey[600]),
                              SizedBox(width: 6),
                              Text(
                                imgDates[i],
                                style: TextStyle(
                                  fontSize: dateFontSize,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(width: 30), // More horizontal space
                              Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                              SizedBox(width: 6),
                              Text(
                                comments_subs_rev_HARDCODED,
                                style: TextStyle(
                                  fontSize: dateFontSize,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(width: 30),
                              Icon(Icons.people, size: 16, color: Colors.grey[600]),
                              SizedBox(width: 6),
                              Text(
                               comments_subs_rev_HARDCODED,
                                style: TextStyle(
                                  fontSize: dateFontSize,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(width: 30),
                              Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                              SizedBox(width: 6),
                              Text(
                              comments_subs_rev_HARDCODED,
                                style: TextStyle(
                                  fontSize: dateFontSize,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(width: 30),
                              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                              SizedBox(width: 6),
                              Text(
                                Watch_time,
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

          // If the current video is clicked, add the video_statistics_graphs widget below it
          if (clickedIndexes.contains(i)) {
            imgWidgets.add(
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0), // Padding between video and graph
                child: Center(
                  child: Container(
                    width: screenWidth / 2, // Half the screen width
                    child: AnimatedOpacity(
                      duration: Duration(milliseconds: 800), // Smoother fade-in for overview widget
                      opacity: clickedIndexes.contains(i) ? 1.0 : 0.0, // Fade in when clicked
                      child: video_statistics_graphs(context),
                    ),
                  ),
                ),
              ),
            );
          }
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
                children: imgWidgets,
              ),
            ),
          ),
        );
      },
    );
  }
}
