/// A cozy, warm login and signup screen for user authentication.
///
/// Allows users to log in or register, verifying credentials against the login database.
/// On successful signup, also adds the user to the analytics database.
import 'package:flutter/material.dart';
import '../login/login_database_helper.dart';
import '../DB/repositories/user_repository.dart';
import '../DB/models/user.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:window_size/window_size.dart';
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
  /// On success, expands the window and navigates to the dashboard.
  Future<void> _handleSignIn() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    final valid = await _loginDb.verifyUser(username, password);
    setState(() {
      _errorMessage = valid ? null : 'Invalid username or password';
    });
    if (valid) {
      // Expand window for main app on desktop
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        setWindowMinSize(const Size(1200, 800));
        setWindowMaxSize(Size.infinite);
        getCurrentScreen().then((screen) {
          if (screen != null) {
            setWindowFrame(screen.visibleFrame);
          }
        });
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const DashboardScreen(),
        ),
      );
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
    // Cozy, warm color scheme
    final Color primaryColor = const Color(0xFF8D5524); // Warm brown
    final Color accentColor =
        const Color(0xFFFFA07A); // Light salmon (warm accent)
    final Color bgColor = const Color(0xFFF6E3C5); // Cozy warm tan background
    final Color cardColor = const Color(0xFFFFE0B2); // Light terracotta card

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withAlpha(20),
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
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Username',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person_outline, color: primaryColor),
                  hintText: 'Enter your username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: bgColor,
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Password',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: bgColor,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: primaryColor,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: _isLogin ? _handleSignIn : _handleSignUp,
                  child: Text(
                    _isLogin ? 'Sign in' : 'Sign up',
                    style: TextStyle(
                        fontSize: 18,
                        color: primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin
                        ? "Don't have an account? "
                        : 'Already have an account? ',
                    style: TextStyle(color: primaryColor),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _errorMessage = null;
                      });
                    },
                    child: Text(
                      _isLogin ? 'Sign up' : 'Sign in',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
