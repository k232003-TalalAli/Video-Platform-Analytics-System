import 'package:flutter/material.dart';
import '../widgets/analytics_card.dart';
import '../widgets/profile_settings_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _channelName = 'My Channel';
  String _channelDescription = 'Welcome to my YouTube channel!';

  void _showProfileSettings() {
    showDialog(
      context: context,
      builder: (context) => ProfileSettingsDialog(
        initialName: _channelName,
        initialDescription: _channelDescription,
        onSave: (name, description) {
          setState(() {
            _channelName = name;
            _channelDescription = description;
          });
        },
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.white,
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Channel Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _channelName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _channelDescription,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _showProfileSettings,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Edit Profile'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black54,
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_channelName),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
          GestureDetector(
            onTap: _showProfileSettings,
            child: const CircleAvatar(
              radius: 16,
              child: Icon(Icons.person),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: NavigationDrawer(
        backgroundColor: Colors.black,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.pop(context);
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
            child: Text(
              _channelName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Channel Overview',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  return const Column(
                    children: [
                      AnalyticsCard(
                        title: 'Total Views',
                        value: '1.2M',
                        icon: Icons.visibility,
                      ),
                      SizedBox(height: 16),
                      AnalyticsCard(
                        title: 'Subscribers',
                        value: '50K',
                        icon: Icons.people,
                      ),
                      SizedBox(height: 16),
                      AnalyticsCard(
                        title: 'Total Videos',
                        value: '45',
                        icon: Icons.video_library,
                      ),
                    ],
                  );
                }
                return const Row(
                  children: [
                    Expanded(
                      child: AnalyticsCard(
                        title: 'Total Views',
                        value: '1.2M',
                        icon: Icons.visibility,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: AnalyticsCard(
                        title: 'Subscribers',
                        value: '50K',
                        icon: Icons.people,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: AnalyticsCard(
                        title: 'Total Videos',
                        value: '45',
                        icon: Icons.video_library,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 