import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget buildLineChart(int totalDays, List<int> viewsPerDay, String X_axis_heading, String Y_axis_heading, String Graph_heading) {
  List<FlSpot> spots = [];
  double maxY = 0;

  for (int i = 0; i < totalDays && i < viewsPerDay.length; i++) {
    double y = viewsPerDay[i].toDouble();
    spots.add(FlSpot((i + 1).toDouble(), y));
    if (y > maxY) maxY = y;
  }

  int maxXLabels = 6;
  int xInterval = (totalDays / maxXLabels).ceil();
  double yInterval = (maxY / 5).ceilToDouble();

  return Container(  // this is what the function returns
    width: 700, 
    height: 600,
    padding: const EdgeInsets.all(16), //16 pixels padding on ALL sides
    decoration: BoxDecoration(    
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 50),
          child: Text(
            Graph_heading, //the content of the text
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 500,
              width: 500,
              child: LineChart(
                LineChartData(
                  minX: 0.5,
                  maxX: totalDays.toDouble() + 0.5, //added 0.5 to include upperlimit, but it still displays int so 0.5 doesnt effect the output
                  minY: 0,
                  maxY: maxY + yInterval,
                  backgroundColor: const Color.fromARGB(255, 241, 241, 241),
                  clipData: FlClipData.all(),
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),   //dont show the x and y axis labels on the top (already showing at bottom)
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: xInterval.toDouble(),
                        getTitlesWidget: (value, meta) {
                          if (value % xInterval == 0 && value <= totalDays + 0.5) {
                            return Text('${value.toInt()}');
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: yInterval,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Text('${value.toInt()}'),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: const Border(
                      left: BorderSide(),
                      bottom: BorderSide(),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: false,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                      color: Colors.blue,
                      barWidth: 3,
                    ),
                  ],
                  lineTouchData: LineTouchData( //when we hover over points on the graph, this is whats displayed
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.black87,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '$X_axis_heading ${spot.x.toInt()}\n$Y_axis_heading: ${spot.y.toInt()}',  //the txt thats displayed
                            const TextStyle(color: Colors.white),
                          );
                        }).toList();
                      },
                    ),
                    handleBuiltInTouches: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('X-Axis: $X_axis_heading', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Y-Axis: $Y_axis_heading', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
