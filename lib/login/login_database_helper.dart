import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

/// A helper class for managing the login database and user authentication.
///
/// Handles creation of the login_users table, user registration, and credential verification.
class LoginDatabaseHelper {
  /// Singleton instance of the helper.
  static final LoginDatabaseHelper _instance = LoginDatabaseHelper._internal();
  factory LoginDatabaseHelper() => _instance;
  LoginDatabaseHelper._internal();

  static Database? _db;

  /// Gets the database instance, initializing it if necessary.
  ///
  /// Returns:
  ///   [Database]: The SQLite database instance for login users.
  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  /// Initializes the login database and creates the login_users table if it doesn't exist.
  ///
  /// Returns:
  ///   [Database]: The opened SQLite database instance.
  Future<Database> _initDb() async {
    final directory = Directory(
      join(Directory.current.path, 'lib', 'login'),
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    final path = join(directory.path, 'login_users.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE login_users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT
          )
        ''');
      },
    );
  }

  /// Registers a new user in the login database.
  ///
  /// Args:
  ///   username (String): The username to register.
  ///   password (String): The password for the user.
  ///
  /// Returns:
  ///   [bool]: True if registration succeeded, false if username exists or error occurs.
  Future<bool> registerUser(String username, String password) async {
    final dbClient = await db;
    try {
      await dbClient.insert(
        'login_users',
        {'username': username, 'password': password},
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Verifies a user's credentials for login.
  ///
  /// Args:
  ///   username (String): The username to verify.
  ///   password (String): The password to verify.
  ///
  /// Returns:
  ///   [bool]: True if credentials are valid, false otherwise.
  Future<bool> verifyUser(String username, String password) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'login_users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }

  /// Checks if a username already exists in the login database.
  ///
  /// Args:
  ///   username (String): The username to check.
  ///
  /// Returns:
  ///   [bool]: True if the username exists, false otherwise.
  Future<bool> userExists(String username) async {
    final dbClient = await db;
    final result = await dbClient.query(
      'login_users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }
}
