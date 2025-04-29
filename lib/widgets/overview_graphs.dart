import 'package:flutter/material.dart';
import 'dart:math';

import 'line_graph.dart';

List<int> generateRandomList(int numberOfValues, int max) {
  final random = Random();
  return List<int>.generate(numberOfValues, (_) => random.nextInt(max + 1));
}

Widget overview_graphs(BuildContext context) {
  int totalDays = 40;
  List<int> views1 = generateRandomList(totalDays, 5000);
  List<int> views2 = generateRandomList(totalDays, 134);
  List<int> views3 = generateRandomList(totalDays, 500);
  List<int> views4 = generateRandomList(totalDays, 90);

  double chartHeight = MediaQuery.of(context).size.height > 600 ? 300 : 200;

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildLineChart(totalDays, views1, "Day", "Views", "Views", chartHeight),
            const SizedBox(height: 24),
            buildLineChart(totalDays, views3, "Day", "Wt (hrs)", "Watch Time", chartHeight),
          ],
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildLineChart(totalDays, views2, "Day", "Subscribers", "Subscribers", chartHeight),
            const SizedBox(height: 24),
            buildLineChart(totalDays, views4, "Day", "\$ Earned", "Estimated Revenue", chartHeight),
          ],
        ),
      ),
    ],
  );
}

// This widget now handles internal state for hover
class TopVideosWidget extends StatefulWidget {
  const TopVideosWidget({super.key});

  @override
  State<TopVideosWidget> createState() => _TopVideosWidgetState();
}

class _TopVideosWidgetState extends State<TopVideosWidget> {
  bool isHovered = false;

  void onTopVideosTap() {
    print("This is suppose to take user to the content page.");
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double imageHeight = screenWidth > 600 ? 70 : 50;
    double nameFontSize = screenWidth > 600 ? 20 : 16;
    double dateFontSize = screenWidth > 600 ? 16 : 12;

    const baseColor = Color.fromARGB(255, 241, 241, 241);
    final hoverColor = baseColor.withOpacity(0.94);

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
                    Text(
                      imgDates[i],
                      style: TextStyle(fontSize: dateFontSize, color: Colors.grey),
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

Widget over_view_widget() {
  return LayoutBuilder(
    builder: (context, constraints) {
      bool isWideScreen = constraints.maxWidth > 800;

      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: isWideScreen
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: overview_graphs(context)),
                    const SizedBox(width: 32),
                    const Expanded(child: TopVideosWidget()),
                  ],
                )
              : Column(
                  children: [
                    overview_graphs(context),
                    const SizedBox(height: 32),
                    const TopVideosWidget(),
                  ],
                ),
        ),
      );
    },
  );
}
