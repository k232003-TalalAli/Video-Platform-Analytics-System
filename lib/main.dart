import 'package:flutter/material.dart';
import 'line_graph.dart'; // <-- make sure this matches your file name
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, //hide the debug banner (it was annoying)
      home: MyHomePage(),
    );
  }
}

List<int> generateRandomList(int numberOfValues, int max) { //function to simulate the datat coming from database
  final random = Random();
  return List<int>.generate(
    numberOfValues,
    (_) => random.nextInt(max + 1), // +1 to include `max` in the range
  );
}

class MyHomePage extends StatelessWidget {
  @override
Widget build(BuildContext context) {
  int totalDays = 40;
  List<int> views1 = generateRandomList(totalDays, 10007);
  // List<int> views2 = generateRandomList(totalDays, 5000);             UN-COMMENT THIS IF WANT TO DISPLAY SECOND GRAPH

    return Scaffold(
      appBar: AppBar(title: Text("")),
      body: SingleChildScrollView(     // makes it possible for widgets to be placed side by side
        child: SingleChildScrollView( // Horizontal scrolling 
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              buildLineChart(totalDays, views1, "Day", "Views", "Graph 1"), //function in line_graph.dart
              //dont need the lines below, just put it here to show that its possible to place 2 graphs in the same line

              // const SizedBox(width: 16), //padding
              // buildLineChart(totalDays, views2, "Day", "Views", "Graph 2"), 
            ],
          ),
        ),
      ),
    );
  }
}
