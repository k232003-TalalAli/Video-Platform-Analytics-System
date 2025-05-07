import '../models/video_metric.dart';
import 'db_api.dart';

class Metrics {
  // Holds the data: 5 videos, each with 30 days of metrics
  final List<List<VideoMetric>> videoMetrics = List.generate(5, (_) => []);

  Metrics._privateConstructor();

  static final Metrics _instance = Metrics._privateConstructor();

  factory Metrics() {
    return _instance;
  }

  /// Call this once to load metrics for the given video IDs
  Future<void> loadMetrics(List<String> videoIds) async {
    if (videoIds.length != 5) {
      throw ArgumentError('Exactly 5 video IDs must be provided.');
    }

    for (int i = 0; i < videoIds.length; i++) {
      final List<VideoMetric> videoData = await fetchVideoMetrics(videoIds[i]);
      // Assuming Video contains a method `.toMetric()` to convert it
      videoMetrics[i] = videoData.map((v) => VideoMetric.fromMap(v.toMap())).toList();
    }
  }

  /// Access video i's data on day j: metrics.video[i][j]
  List<List<VideoMetric>> get video => videoMetrics;

  /// Method to reset the singleton state
  void reset() {
    for (int i = 0; i < videoMetrics.length; i++) {
      videoMetrics[i].clear();
    }
  }
}

List<int> sumDailyViews() {
  int totalDays = 30; // You mentioned there are 30 days
  List<int> totalViewsPerDay = List.filled(totalDays, 0); // Initialize a list with 30 zeros
  
  // Loop through each video (assuming there are 5 videos)
  for (int videoIndex = 0; videoIndex < 5; videoIndex++) {
    // Loop through each day (up to 30 days)
    for (int dayIndex = 0; dayIndex < totalDays; dayIndex++) {
      // Check if the current video has data for this day
      if (dayIndex < Metrics().video[videoIndex].length) {
        totalViewsPerDay[dayIndex] += Metrics().video[videoIndex][dayIndex].dayViews;
      }
    }
  }

  return totalViewsPerDay;
}

List<int> sumDailyWatchTime() {
  int totalDays = 30; // Number of days
  List<int> totalWatchTimePerDay = List.filled(totalDays, 0); // Initialize list to store daily total watchtime
  
  // Loop through each video (5 videos)
  for (int videoIndex = 0; videoIndex < 5; videoIndex++) {
    // Loop through each day (30 days)
    for (int dayIndex = 0; dayIndex < totalDays; dayIndex++) {
      // Check if the current video has data for this day
      if (dayIndex < Metrics().video[videoIndex].length) {
         totalWatchTimePerDay[dayIndex] += Metrics().video[videoIndex][dayIndex].watchtime.toInt();
      }
    }
  }

  return totalWatchTimePerDay;
}



List<int> sumDailyCTR() {
  int totalDays = 30;
  List<int> totalCTRPerDay = List.filled(totalDays, 0);

  for (int videoIndex = 0; videoIndex < 5; videoIndex++) {
    for (int dayIndex = 0; dayIndex < totalDays; dayIndex++) {
      if (dayIndex < Metrics().video[videoIndex].length) {
        // Multiply by 100 to convert fraction to percentage before converting to int
        totalCTRPerDay[dayIndex] += (Metrics().video[videoIndex][dayIndex].ctr * 10).round();
      }
    }
  }

  return totalCTRPerDay;
}

List<int> getDailyCTRForVideo(int videoIndex) {
  int totalDays = 30;
  List<int> dailyCTR = List.filled(totalDays, 0);

  if (videoIndex < 0 || videoIndex >= Metrics().video.length) {
    throw RangeError("Invalid video index: $videoIndex");
  }

  for (int dayIndex = 0; dayIndex < totalDays; dayIndex++) {
    if (dayIndex < Metrics().video[videoIndex].length) {
      // Multiply by 10 to convert fraction to % and round
      dailyCTR[dayIndex] =
          (Metrics().video[videoIndex][dayIndex].ctr * 100).round();
    }
  }

  return dailyCTR;
}


List<int> sumDailyImpressions() {
  int totalDays = 30; // Number of days
  List<int> totalImpressionsPerDay = List.filled(totalDays, 0); // Initialize list to store daily total impressions
  
  // Loop through each video (5 videos)
  for (int videoIndex = 0; videoIndex < 5; videoIndex++) {
    // Loop through each day (30 days)
    for (int dayIndex = 0; dayIndex < totalDays; dayIndex++) {
      // Check if the current video has data for this day
      if (dayIndex < Metrics().video[videoIndex].length) {
        totalImpressionsPerDay[dayIndex] += Metrics().video[videoIndex][dayIndex].impressions;
      }
    }
  }

  return totalImpressionsPerDay;
}

List<int> getDailyImpressionsForVideo(int videoIndex) {
  int totalDays = 30;
  List<int> dailyImpressions = List.filled(totalDays, 0);

  if (videoIndex < 0 || videoIndex >= Metrics().video.length) {
    throw RangeError("Invalid video index: $videoIndex");
  }

  for (int dayIndex = 0; dayIndex < totalDays; dayIndex++) {
    if (dayIndex < Metrics().video[videoIndex].length) {
      dailyImpressions[dayIndex] =
          Metrics().video[videoIndex][dayIndex].impressions;
    }
  }

  return dailyImpressions;
}


double calculateChannelCTR() {
  double totalCTR = 0;
  int numberOfVideos = 5;

  for (int videoIndex = 0; videoIndex < numberOfVideos; videoIndex++) {
    totalCTR += calculateVideoCTR(videoIndex);
  }

  double averageCTR = totalCTR / numberOfVideos;
  return double.parse(averageCTR.toStringAsFixed(2));
}

double calculateVideoCTR(int videoIndex) {
  double totalCTR = 0;

  for (int dayIndex = 0; dayIndex < Metrics().video[videoIndex].length; dayIndex++) {
    totalCTR += Metrics().video[videoIndex][dayIndex].ctr;
  }

  return double.parse((totalCTR).toStringAsFixed(2));
}



int calculateTotalImpressions() {
  int totalImpressions = 0;

  for (int videoIndex = 0; videoIndex < 5; videoIndex++) {
    for (int dayIndex = 0; dayIndex < Metrics().video[videoIndex].length; dayIndex++) {
      totalImpressions += Metrics().video[videoIndex][dayIndex].impressions;
    }
  }

  return totalImpressions;
}

int sumTotalImpressionsForVideo(int videoIndex) {
  int totalImpressions = 0;

  // Ensure the videoIndex is valid
  if (videoIndex < 0 || videoIndex >= Metrics().video.length) {
    throw RangeError("Invalid video index: $videoIndex");
  }

  // Loop through each day's impressions
  for (int dayIndex = 0; dayIndex < Metrics().video[videoIndex].length; dayIndex++) {
    totalImpressions += Metrics().video[videoIndex][dayIndex].impressions;
  }

  return totalImpressions;
}

