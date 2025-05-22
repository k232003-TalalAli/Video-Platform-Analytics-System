import 'package:flutter/material.dart';
import 'dart:io'; // For checking platform
import 'package:window_size/window_size.dart';
import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('Login');
    setWindowMaxSize(Size.infinite); // Allow window to be maximized to any size
    setWindowMinSize(const Size(800, 600)); // Optional: Set a minimum size
    getCurrentScreen().then((screen) {
      if (screen != null) {
        final screenFrame = screen.visibleFrame;
        setWindowFrame(screenFrame); // Maximize the window to screen size
      }
    });
  }

  runApp(const YouTubeStudio());
}

class YouTubeStudio extends StatelessWidget {
  const YouTubeStudio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          secondary: Colors.black87,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          toolbarHeight: 72,
          iconTheme: IconThemeData(
            color: Colors.white,
            size: 28,
          ),
          actionsIconTheme: IconThemeData(
            color: Colors.white,
            size: 28,
          ),
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        navigationDrawerTheme: const NavigationDrawerThemeData(
          backgroundColor: Colors.white,
          elevation: 1,
          indicatorColor: Color.fromARGB(255, 42, 76, 134),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
        tooltipTheme: const TooltipThemeData(
          showDuration: Duration.zero,
          waitDuration: Duration(days: 1),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
