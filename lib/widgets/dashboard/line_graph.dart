import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

Widget buildLineChart(
  int totalDays,
  List<int> viewsPerDay,
  List<String> dates,
  String xAxisHeading,
  String yAxisHeading,
  String graphHeading,
  double chartHeight,
) {
  List<FlSpot> spots = [];
  double maxY = 0;

  for (int i = 0; i < totalDays && i < viewsPerDay.length; i++) {
    double y = viewsPerDay[i].toDouble();
    spots.add(FlSpot(i.toDouble(), y));
    if (y > maxY) maxY = y;
  }

  double yInterval = ((maxY / 5).ceilToDouble()).clamp(1, double.infinity);

  // Ensure valid label indexes (start, middle, end)
  List<int> labelIndexes = [];
  if (dates.length >= 3) {
    labelIndexes = [0, (dates.length - 1) ~/ 2, dates.length - 1];
  } else {
    labelIndexes = List.generate(dates.length, (index) => index);
  }

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(12, 12, 35, 12),
    decoration: const BoxDecoration(
      color: Color.fromARGB(255, 255, 255, 255),
      borderRadius: BorderRadius.all(Radius.circular(12)),
      border: Border(
        bottom: BorderSide(color: Colors.grey, width: 1.5),
        left: BorderSide(color: Colors.grey, width: 1.5),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          offset: Offset(0, 2),
          blurRadius: 4,
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 30),
          child: Text(
            graphHeading,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SizedBox(
            height: chartHeight - 40,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: totalDays.toDouble() - 1,
                minY: 0,
                maxY: maxY + yInterval,
                backgroundColor: Color.fromARGB(255, 255, 255, 255),
                clipData: const FlClipData.all(),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        int index = value.round();
                        if (labelIndexes.contains(index) && index < dates.length) {
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            space: 8,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12), // <- Added padding
                              child: SizedBox(
                                width: 60,
                                child: Text(
                                  dates[index],
                                  style: const TextStyle(fontSize: 10),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: yInterval,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            '${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          ),
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
                gridData: const FlGridData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: false,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                    color: Colors.blue,
                    barWidth: 2.5,
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.black87,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        int index = spot.x.round();
                        String date = (index >= 0 && index < dates.length)
                            ? dates[index]
                            : 'N/A';
                        return LineTooltipItem(
                          '$xAxisHeading: $date\n$yAxisHeading: ${spot.y.toInt()}',
                          const TextStyle(color: Colors.white, fontSize: 12),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
