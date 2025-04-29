import 'package:flutter/material.dart';
import 'dart:math';
import 'line_graph.dart';

List<int> generateRandomList(int numberOfValues, int max) {
  //function to simulate the datat coming from database
  final random = Random();
  return List<int>.generate(
    numberOfValues,
    (_) => random.nextInt(max + 1), // +1 to include `max` in the range
  );
}

Widget overview_graphs() {
  int totalDays = 40;
  List<int> views1 = generateRandomList(totalDays, 10007);
  List<int> views2 = generateRandomList(totalDays, 5000);
  List<int> views3 = generateRandomList(totalDays, 3000);
  List<int> views4 = generateRandomList(totalDays, 1500);

  return Padding(
    padding: const EdgeInsets.only(
      top: 16.0,
    ),
    child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildLineChart(totalDays, views1, "Day", "Views", "Views"),
            const SizedBox(height: 24),
            buildLineChart(totalDays, views3, "Day", "Wt (hrs)", "Watch Time"),
          ],
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildLineChart(
              totalDays,
              views2,
              "Day",
              "Subscribers",
              "Subscribers",
            ),
            const SizedBox(height: 24),
            buildLineChart(
              totalDays,
              views4,
              "Day",
              "Earned (\$)",
              "Estimated Revenue",
            ),
          ],
        ),
      ],
    ),
  );
}

Widget Top_videos_widget(
  int numImages,
  List<String> imgPaths,
  List<String> imgNames,
  List<String> imgDates,
) {
  List<Widget> imgWidgets = [];

  imgWidgets.add(
    Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        "Top Videos",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    ),
  );

  for (int i = 0; i < numImages; i++) {
    imgWidgets.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: 4,
              child: Image.asset(imgPaths[i], fit: BoxFit.cover, height: 35),
            ),
            const SizedBox(width: 12),
            Flexible(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    imgNames[i],
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    imgDates[i],
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  return Container(
    padding: const EdgeInsets.all(12), // Padding inside the container
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey), 
      borderRadius: BorderRadius.circular(12), 
      boxShadow: [

        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 6,
          offset: Offset(0, 4), // Shadow direction
        ),
      ],
    ),
    child: ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 280,
      ), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: imgWidgets,
      ),
    ),
  );
}

Widget over_view_widget() {
  return Center(
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Padding(
            padding: const EdgeInsets.only(right: 32.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: overview_graphs(),
            ),
          ),
          const SizedBox(width: 32),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Container(
              height: 816,
              child: Center(
                child: Top_videos_widget(
                  4,
                  [
                    "imgs/thumbnail_1.jpg",
                    "imgs/thumbnail_2.jpg",
                    "imgs/thumbnail_3.jpg",
                    "imgs/thumbnail_4.jpg",
                  ],
                  [
                    "Talal best no doubt",
                    "bro this sum gud shit",
                    "ala larkey, mja aagya",
                    "this is a placeholder",
                  ],
                  ["2025-04-01", "2025-04-05", "2025-04-10", "2025-05-10"],
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
