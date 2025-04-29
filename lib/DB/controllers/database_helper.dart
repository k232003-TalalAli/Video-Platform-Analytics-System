import 'package:path/path.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('youtube_analytics.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbDir = Directory('lib/DB');
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }
    final path = join(dbDir.absolute.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: (db) async {
        // Check if all_users table exists
        final tables = await db.query('sqlite_master',
            where: 'type = ? AND name = ?', whereArgs: ['table', 'all_users']);

        if (tables.isEmpty) {
          await _createDB(db, 1);
        }
      },
      singleInstance: true,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const dateType = 'TEXT NOT NULL';
    const decimalType = 'REAL NOT NULL';

    // Create all_users table for overall stats
    await db.execute('''
    CREATE TABLE IF NOT EXISTS all_users (
      user_id $idType,
      user_name $textType,
      channel_creation_date $dateType,
      channel_name $textType,
      total_views $intType,
      total_subs $intType,
      total_comments $intType,
      total_watchtime $intType,
      total_revenue $decimalType,
      channel_image_link $textType,
      description $textType
    )
    ''');
  }

  // Create a new user's table
  Future<void> createUserTable(String userId) async {
    final db = await database;
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const dateType = 'TEXT NOT NULL';
    const decimalType = 'REAL NOT NULL';

    // Replace hyphens with underscores in the table name
    final safeUserId = userId.replaceAll('-', '_');
    await db.execute('''
    CREATE TABLE IF NOT EXISTS user_$safeUserId (
      video_id $idType,
      video_name $textType,
      views $intType,
      subs $intType,
      revenue $decimalType,
      comments $intType,
      watchtime $intType,
      creation_date $dateType
    )
    ''');
  }

  // Create a new video's metrics table
  Future<void> createVideoMetricsTable(String videoId) async {
    final db = await database;
    const idType = 'TEXT PRIMARY KEY';
    const dateType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const decimalType = 'REAL NOT NULL';

    // Replace hyphens with underscores in the table name
    final safeVideoId = videoId.replaceAll('-', '_');
    await db.execute('''
    CREATE TABLE IF NOT EXISTS video_metrics_$safeVideoId (
      metric_id $idType,
      day $dateType,
      day_views $intType,
      impressions $intType,
      ctr $decimalType,
      watchtime $intType
    )
    ''');
  }

  // Get all users
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('all_users');
  }

  // Get specific user's videos
  Future<List<Map<String, dynamic>>> getUserVideos(String userId) async {
    final db = await database;
    final safeUserId = userId.replaceAll('-', '_');
    return await db.query('user_$safeUserId');
  }

  // Get specific video's metrics
  Future<List<Map<String, dynamic>>> getVideoMetrics(String videoId) async {
    final db = await database;
    final safeVideoId = videoId.replaceAll('-', '_');
    return await db.query('video_metrics_$safeVideoId');
  }

  // Add new user
  Future<void> addUser(Map<String, dynamic> userData) async {
    final db = await database;
    await db.insert('all_users', userData);
    await createUserTable(userData['user_id']);
  }

  // Add new video to user's table
  Future<void> addVideo(String userId, Map<String, dynamic> videoData) async {
    final db = await database;
    final safeUserId = userId.replaceAll('-', '_');
    await db.insert('user_$safeUserId', videoData);
    await createVideoMetricsTable(videoData['video_id']);
  }

  // Add daily metrics for a video
  Future<void> addVideoMetrics(
      String videoId, Map<String, dynamic> metricsData) async {
    final db = await database;
    final safeVideoId = videoId.replaceAll('-', '_');
    await db.insert('video_metrics_$safeVideoId', metricsData);
  }

  // Update user's overall stats
  Future<void> updateUserStats(
      String userId, Map<String, dynamic> stats) async {
    final db = await database;
    await db.update(
      'all_users',
      stats,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // Update video stats in user's table
  Future<void> updateVideoStats(
      String userId, String videoId, Map<String, dynamic> stats) async {
    final db = await database;
    final safeUserId = userId.replaceAll('-', '_');
    await db.update(
      'user_$safeUserId',
      stats,
      where: 'video_id = ?',
      whereArgs: [videoId],
    );
  }

  // Update specific day's metrics for a video
  Future<void> updateVideoMetrics(
      String videoId, String metricId, Map<String, dynamic> metrics) async {
    final db = await database;
    final safeVideoId = videoId.replaceAll('-', '_');
    await db.update(
      'video_metrics_$safeVideoId',
      metrics,
      where: 'metric_id = ?',
      whereArgs: [metricId],
    );
  }

  // Delete user and all associated data
  Future<void> deleteUser(String userId) async {
    final db = await database;
    final safeUserId = userId.replaceAll('-', '_');

    // Start a transaction to ensure all operations succeed or fail together
    await db.transaction((txn) async {
      // Get all videos for this user
      final videos = await txn.query('user_$safeUserId');

      // Delete all metrics tables for each video
      for (final video in videos) {
        final safeVideoId = (video['video_id'] as String).replaceAll('-', '_');
        await txn.execute('DROP TABLE IF EXISTS video_metrics_$safeVideoId');
      }

      // Delete the user's videos table
      await txn.execute('DROP TABLE IF EXISTS user_$safeUserId');

      // Delete the user from all_users table
      await txn.delete(
        'all_users',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    });
  }

  // Delete video and its metrics
  Future<void> deleteVideo(String userId, String videoId) async {
    final db = await database;
    final safeUserId = userId.replaceAll('-', '_');
    final safeVideoId = videoId.replaceAll('-', '_');

    await db.transaction((txn) async {
      // Delete the video's metrics table
      await txn.execute('DROP TABLE IF EXISTS video_metrics_$safeVideoId');

      // Delete the video from user's table
      await txn.delete(
        'user_$safeUserId',
        where: 'video_id = ?',
        whereArgs: [videoId],
      );
    });
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
