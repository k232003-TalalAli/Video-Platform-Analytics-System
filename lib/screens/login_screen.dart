/// Allows users to log in or register, verifying credentials against the login database.
/// On successful signup, also adds the user to the analytics database.
import 'package:flutter/material.dart';
import '../login/login_database_helper.dart';
import '../DB/repositories/user_repository.dart';
import '../DB/models/user.dart';
import '../login/user_session.dart';
import '../theme/app_theme.dart';
import 'package:uuid/uuid.dart';
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
  String? _usernameError;
  String? _passwordError;
  bool _obscurePassword = true;

  /// Validates username format
  /// - No special characters other than underscore (_)
  /// - Cannot start with a number
  String? _validateUsername(String username) {
    if (username.isEmpty) {
      return 'Username cannot be empty';
    }

    // Check if username starts with a number
    if (RegExp(r'^[0-9]').hasMatch(username)) {
      return 'Username cannot start with a number';
    }

    // Check for special characters other than underscore
    if (!RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*$').hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscore';
    }

    return null; // Valid username
  }

  /// Validates password format
  /// - At least 8 characters long
  /// - At least 1 uppercase letter
  /// - At least 1 lowercase letter
  /// - At least 1 number
  /// - At least 1 special character
  String? _validatePassword(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters long';
    }

    // Check for uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for number
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Password must contain at least one number';
    }

    // Check for special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Password must contain at least one special character';
    }

    return null; // Valid password
  }

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
  /// Validates username and password format according to requirements.
  Future<void> _handleSignUp() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // Reset validation errors
    setState(() {
      _usernameError = null;
      _passwordError = null;
      _errorMessage = null;
    });

    // Validate username and password format
    final usernameError = _validateUsername(username);
    final passwordError = _validatePassword(password);

    if (usernameError != null || passwordError != null) {
      setState(() {
        _usernameError = usernameError;
        _passwordError = passwordError;
      });
      return;
    }

    // Check if username already exists
    final exists = await _loginDb.userExists(username);
    if (exists) {
      setState(() {
        _usernameError = 'Username already exists';
      });
      return;
    }

    // Register the user
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
        _usernameError = null;
        _passwordError = null;
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
        child: SingleChildScrollView(
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
                    prefixIcon: Icon(Icons.person_outline,
                        color: AppTheme.primaryColor),
                    hintText: 'Enter your username',
                    errorText: _usernameError,
                    helperText: !_isLogin
                        ? 'Letters, numbers, and underscore only. Cannot start with a number.'
                        : null,
                    helperMaxLines: 2,
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
                    prefixIcon:
                        Icon(Icons.lock_outline, color: AppTheme.primaryColor),
                    hintText: 'Enter your password',
                    errorText: _passwordError,
                    helperText: !_isLogin
                        ? 'Min 8 chars with 1 uppercase, 1 lowercase, 1 number & 1 special char'
                        : null,
                    helperMaxLines: 2,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: AppTheme.backgroundColor,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
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
                      _usernameError = null;
                      _passwordError = null;
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
      ),
    );
  }
}
