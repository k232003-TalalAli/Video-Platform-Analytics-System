import '../models/video.dart';
import '../controllers/database_helper.dart';

class VideoRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<int> insert(Video video) async {
    final db = await dbHelper.database;
    await db.insert('videos', video.toMap());
    return 1;
  }

  Future<Video?> getVideo(String id) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'videos',
      where: 'video_id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Video.fromMap(maps.first);
  }

  Future<List<Video>> getVideosByUser(String userId) async {
    final db = await dbHelper.database;
    final maps = await db.query(
      'videos',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    return maps.map((map) => Video.fromMap(map)).toList();
  }

  Future<List<Video>> getAllVideos() async {
    final db = await dbHelper.database;
    final maps = await db.query('videos');
    return maps.map((map) => Video.fromMap(map)).toList();
  }

  Future<int> update(Video video) async {
    final db = await dbHelper.database;
    return await db.update(
      'videos',
      video.toMap(),
      where: 'video_id = ?',
      whereArgs: [video.videoId],
    );
  }

  Future<int> delete(String id) async {
    final db = await dbHelper.database;
    return await db.delete(
      'videos',
      where: 'video_id = ?',
      whereArgs: [id],
    );
  }
}
