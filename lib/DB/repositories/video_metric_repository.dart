import '../models/video_metric.dart';
import '../controllers/database_helper.dart';

class VideoMetricRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(VideoMetric metric) async {
    final db = await dbHelper.database;
    await db.insert('video_metrics', metric.toMap());
    return 1;
  }

  Future<VideoMetric?> getMetric(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'video_metrics',
      where: 'metric_id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return VideoMetric.fromMap(maps.first);
  }

  Future<List<VideoMetric>> getMetricsByVideo(String videoId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'video_metrics',
      where: 'video_id = ?',
      whereArgs: [videoId],
    );
    return maps.map((map) => VideoMetric.fromMap(map)).toList();
  }

  Future<List<VideoMetric>> getMetricsByDay(DateTime day) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'video_metrics',
      where: 'day = ?',
      whereArgs: [day.toIso8601String()],
    );
    return maps.map((map) => VideoMetric.fromMap(map)).toList();
  }

  Future<List<VideoMetric>> getAllMetrics() async {
    final db = await dbHelper.database;
    final maps = await db.query('video_metrics');
    return maps.map((map) => VideoMetric.fromMap(map)).toList();
  }

  Future<int> update(VideoMetric metric) async {
    final db = await dbHelper.database;
    return await db.update(
      'video_metrics',
      metric.toMap(),
      where: 'metric_id = ?',
      whereArgs: [metric.metricId],
    );
  }

  Future<int> delete(String id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'video_metrics',
      where: 'metric_id = ?',
      whereArgs: [id],
    );
  }
}
