/// A cozy, warm login and signup screen for user authentication.
///
/// Allows users to log in or register, verifying credentials against the login database.
/// On successful signup, also adds the user to the analytics database.
import 'package:flutter/material.dart';
import '../login/login_database_helper.dart';
import '../DB/repositories/user_repository.dart';
import '../DB/models/user.dart';
import '../login/user_session.dart';
import '../theme/app_theme.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'dashboard_screen.dart';

/// The main login/signup screen widget.
class LoginScreen extends StatefulWidget {
  /// Creates a new LoginScreen.
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// State for the LoginScreen, handling UI and authentication logic.
class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginDatabaseHelper _loginDb = LoginDatabaseHelper();
  final UserRepository _userRepo = UserRepository();
  bool _isLogin = true;
  String? _errorMessage;
  bool _obscurePassword = true;

  /// Handles user sign in by verifying credentials.
  ///
  /// On success, navigates to the dashboard.
  Future<void> _handleSignIn() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final valid = await _loginDb.verifyUser(username, password);
    setState(() {
      _errorMessage = valid ? null : 'Invalid username or password';
    });
    if (valid) {
      // Find user ID for the logged in user
      final userId = await UserSession().getUserIdFromUsername(username);
      if (userId != null) {
        // Set the current user in the session
        UserSession().setCurrentUser(userId, username);
      } else {
        print('Warning: Could not find user ID for username: $username');
      }

      // Navigate to dashboard
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DashboardScreen(),
          ),
        );
      }
    }
  }

  /// Handles user sign up by registering credentials and adding to analytics DB.
  ///
  /// Shows error messages for duplicate usernames or failed registration.
  Future<void> _handleSignUp() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both username and password';
      });
      return;
    }
    final exists = await _loginDb.userExists(username);
    if (exists) {
      setState(() {
        _errorMessage = 'Username already exists';
      });
      return;
    }
    final registered = await _loginDb.registerUser(username, password);
    if (registered) {
      // Add to all_users with placeholder/default values
      final user = User(
        userId: const Uuid().v4(),
        userName: username,
        channelCreationDate: DateTime.now(),
        channelName: 'New Channel',
        totalViews: 0,
        totalSubs: 0,
        totalComments: 0,
        totalWatchtime: 0,
        totalRevenue: 0.0,
        channelImageLink: '',
        description: '',
      );
      await _userRepo.addUser(user);
      setState(() {
        _isLogin = true;
        _errorMessage = 'Account created! Please sign in.';
      });
    } else {
      setState(() {
        _errorMessage = 'Signup failed. Try again.';
      });
    }
  }

  /// Builds the login/signup UI with a cozy, warm color scheme.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 196, 215, 242), 
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withAlpha(30),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                _isLogin ? 'Welcome Back' : 'Create Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Username',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTextColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryColor),
                  hintText: 'Enter your username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Password',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryTextColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppTheme.backgroundColor,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: AppTheme.secondaryTextColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: _errorMessage!.contains('created') 
                        ? AppTheme.secondaryColor 
                        : AppTheme.graphColors[3],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLogin ? _handleSignIn : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.surfaceColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  _isLogin ? 'Sign In' : 'Sign Up',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                    _errorMessage = null;
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                ),
                child: Text(
                  _isLogin
                      ? 'Don\'t have an account? Sign Up'
                      : 'Already have an account? Sign In',
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
