import '../models/user.dart';
import '../controllers/database_helper.dart';

/// Repository class for managing User data in the database.
///
/// This class provides methods for CRUD operations on User objects.
class UserRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// Retrieves all users from the database.
  ///
  /// Returns:
  ///   List(User): A list of all users in the database.
  Future<List<User>> getAllUsers() async {
    final users = await _dbHelper.getAllUsers();
    return users.map((map) => User.fromMap(map)).toList();
  }

  /// Retrieves a specific user by their ID.
  ///
  /// Args:
  ///   userId (String): The unique identifier of the user to retrieve.
  ///
  /// Returns:
  ///   User?: The user if found, null otherwise.
  Future<User?> getUserById(String userId) async {
    final users = await _dbHelper.getAllUsers();
    final userMap = users.firstWhere(
      (map) => map['user_id'] == userId,
      orElse: () => {},
    );
    return userMap.isEmpty ? null : User.fromMap(userMap);
  }

  /// Adds a new user to the database.
  ///
  /// Args:
  ///   user (User): The user object to add to the database.
  ///
  /// Returns:
  ///   void
  Future<void> addUser(User user) async {
    await _dbHelper.addUser(user.toMap());
  }

  /// Updates an existing user in the database.
  ///
  /// Args:
  ///   user (User): The updated user object.
  ///
  /// Returns:
  ///   void
  Future<void> updateUser(User user) async {
    await _dbHelper.updateUserStats(user.userId, user.toMap());
  }

  /// Deletes a user and all associated data from the database.
  ///
  /// Args:
  ///   userId (String): The unique identifier of the user to delete.
  ///
  /// Returns:
  ///   void
  Future<void> deleteUser(String userId) async {
    await _dbHelper.deleteUser(userId);
  }
}
