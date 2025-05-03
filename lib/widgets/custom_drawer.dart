import 'package:flutter/material.dart';
import 'profile_picture.dart';
import '../screens/content_screen.dart';
import '../screens/feedback_screen.dart';
import '../screens/dashboard_screen.dart';
import '../login/user_session.dart';

class CustomDrawer extends StatelessWidget {
  final String channelName;
  final String channelDescription;
  final String profileImageUrl;
  final int selectedIndex;
  final String? userId;
  final Function(String, String, String) onProfileUpdate;

  const CustomDrawer({
    Key? key,
    required this.channelName,
    required this.channelDescription,
    required this.profileImageUrl,
    required this.selectedIndex,
    this.userId,
    required this.onProfileUpdate,
  }) : super(key: key);

  void _navigateToPage(BuildContext context, int index) async {
    // Close drawer first and wait for it to complete
    Navigator.pop(context);

    // Don't navigate if already on the page
    if (index == selectedIndex) return;

    // Get the current user ID from the session if not provided
    final currentUserId = userId ?? UserSession().currentUserId ?? 'b4fc101f-a404-49e3-a7f7-4f83bc0e38e8';

    // Add a small delay to ensure the drawer is closed
    await Future.delayed(const Duration(milliseconds: 100));

    if (!context.mounted) return;

    switch (index) {
      case 0: // Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              initialChannelName: channelName,
              initialChannelDescription: channelDescription,
              initialProfileImageUrl: profileImageUrl,
            ),
          ),
        );
        break;
      case 1: // Content
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ContentScreen(
              channelName: channelName,
              channelDescription: channelDescription,
              profileImageUrl: profileImageUrl,
              userId: currentUserId, // Use the current user ID
              onProfileUpdate: onProfileUpdate,
            ),
          ),
        );
        break;
      case 2: // Feedback
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FeedbackScreen(
              channelName: channelName,
              channelDescription: channelDescription,
              profileImageUrl: profileImageUrl,
              userId: currentUserId, // Use the current user ID
              onProfileUpdate: onProfileUpdate,
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NavigationDrawer(
      backgroundColor: Colors.black,
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) => _navigateToPage(context, index),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Row(
            children: [
              ProfilePicture(
                imageUrl: profileImageUrl,
                size: 56,
                channelName: channelName,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channelName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      channelDescription,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 10),
          child: Divider(color: Colors.white24),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.dashboard_outlined, color: Colors.white),
          selectedIcon: Icon(Icons.dashboard, color: Colors.white),
          label: Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.video_library_outlined, color: Colors.white),
          selectedIcon: Icon(Icons.video_library, color: Colors.white),
          label: Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text(
              'Content',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.feedback_outlined, color: Colors.white),
          selectedIcon: Icon(Icons.feedback, color: Colors.white),
          label: Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text(
              'Feedback',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
} 