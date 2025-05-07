import '../DB/controllers/database_helper.dart';
import '../screens/dashboard_screen.dart';
import '../widgets/dashboard/overview_graphs.dart';
import '../DB/API/Widget_database_utility.dart';

/// A class to manage user session information across the app
class UserSession {
  static final UserSession _instance = UserSession._internal();
  factory UserSession() => _instance;
  
  UserSession._internal();
  
  String? _currentUserId;
  String? _currentUsername;
  
  /// Set the current user's ID and username
  void setCurrentUser(String userId, String username) {
    _currentUserId = userId;
    _currentUsername = username;
  }
  
  /// Get the current user's ID
  String? get currentUserId => _currentUserId;
  
  /// Get the current user's username
  String? get currentUsername => _currentUsername;
  
  /// Clear the current user session
  void clearSession() {
    _currentUserId = null;
    _currentUsername = null;
    
    // Reset all singleton instances
    Userdata().reset();
    Videos().reset();
    Metrics().reset();
  }
  
  /// Get user ID from username
  Future<String?> getUserIdFromUsername(String username) async {
    try {
      final users = await DatabaseHelper.instance.getAllUsers();
      for (final user in users) {
        if (user['user_name'] == username) {
          return user['user_id'] as String;
        }
      }
      return null;
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }
} 