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
    // Store in lib/DB directory
    final dbDir = Directory('lib/DB');
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }
    final path = join(dbDir.absolute.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      singleInstance: true,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const dateType = 'TEXT NOT NULL';
    const decimalType = 'REAL NOT NULL';
    const decimalType5_2 = 'REAL NOT NULL';

    // Create users table
    await db.execute('''
    CREATE TABLE users (
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

    // Create videos table
    await db.execute('''
    CREATE TABLE videos (
      video_id $idType,
      user_id $textType,
      video_name $textType,
      views $intType,
      subs $intType,
      revenue $decimalType,
      comments $intType,
      watchtime $intType,
      creation_date $dateType,
      FOREIGN KEY (user_id) REFERENCES users (user_id)
    )
    ''');

    // Create video_metrics table
    await db.execute('''
    CREATE TABLE video_metrics (
      metric_id $idType,
      video_id $textType,
      day $dateType,
      day_views $intType,
      impressions $intType,
      ctr $decimalType5_2,
      watchtime $intType,
      FOREIGN KEY (video_id) REFERENCES videos (video_id)
    )
    ''');
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
