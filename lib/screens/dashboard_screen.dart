import 'package:flutter/material.dart';
import '../widgets/profile_picture.dart';
import '../widgets/dashboard/analytics_card.dart';
import '../widgets/dashboard/overview_graphs.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../login/user_session.dart';

class DashboardScreen extends StatefulWidget {
  final String? initialChannelName;
  final String? initialChannelDescription;
  final String? initialProfileImageUrl;

  const DashboardScreen({
    super.key,
    this.initialChannelName,
    this.initialChannelDescription,
    this.initialProfileImageUrl,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final int _selectedIndex = 0;
  late String _channelName;
  late String _channelDescription;
  late String _profileImageUrl;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _channelName = widget.initialChannelName ?? 'My Channel';
    _channelDescription =
        widget.initialChannelDescription ?? 'Welcome to my YouTube channel!';
    _profileImageUrl = widget.initialProfileImageUrl ?? '';
    _userId = UserSession().currentUserId ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawerEdgeDragWidth: 0,
      appBar: CustomAppBar(
        channelName: _channelName,
        channelDescription: _channelDescription,
        profileImageUrl: _profileImageUrl,
        scaffoldKey: _scaffoldKey,
        onProfileUpdate: (name, description, imageUrl) {
          if (!mounted) return;
          setState(() {
            _channelName = name;
            _channelDescription = description;
            _profileImageUrl = imageUrl;
          });
        },
      ),
      drawer: CustomDrawer(
        channelName: _channelName,
        channelDescription: _channelDescription,
        profileImageUrl: _profileImageUrl,
        selectedIndex: _selectedIndex,
        userId: _userId,
        onProfileUpdate: (name, description, imageUrl) {
          if (!mounted) return;
          setState(() {
            _channelName = name;
            _channelDescription = description;
            _profileImageUrl = imageUrl;
          });
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            ProfilePicture(
              imageUrl: _profileImageUrl,
              size: 150,
              channelName: _channelName,
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Channel Overview',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
            const SizedBox(height: 32),
            over_view_widget(_channelName, _channelDescription, _profileImageUrl, userId: _userId),
          ],
        ),
      ),
    );
  }
}
