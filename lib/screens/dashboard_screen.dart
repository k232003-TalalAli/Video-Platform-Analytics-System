import 'package:flutter/material.dart';
import '../widgets/profile_picture.dart';
import '../widgets/dashboard/analytics_card.dart';
import '../widgets/dashboard/overview_graphs.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../login/user_session.dart';
import '../../DB/API/db_api.dart';
import 'package:intl/intl.dart';

String _formatWatchTime(int seconds) {
    int hours = seconds ~/ 3600;
    return '$hours hrs';
  }

final numberFormatter = NumberFormat.compact();

class Userdata {
  // Singleton instance
  static final Userdata _instance = Userdata._internal();
  factory Userdata() => _instance;

  // Private constructor
  Userdata._internal();

  // Fields populated after loading user data
  late String userId;
  late String userName;
  late DateTime channelCreationDate;
  late String channelName;
  late int totalViews;
  late int totalSubs;
  late int totalComments;
  late int totalWatchtime;
  late double totalRevenue;
  late String channelImageLink;
  late String description;

  bool _isInitialized = false;

  // Method to initialize session
  Future<void> initialize(String userId) async {
    if (_isInitialized) return;

    final user = await fetchUserOverall(userId);
    if (user != null) {
      this.userId = user.userId;
      userName = user.userName;
      channelCreationDate = user.channelCreationDate;
      channelName = user.channelName;
      totalViews = user.totalViews;
      totalSubs = user.totalSubs;
      totalComments = user.totalComments;
      totalWatchtime = user.totalWatchtime;
      totalRevenue = user.totalRevenue;
      channelImageLink = user.channelImageLink;
      description = user.description;

      _isInitialized = true;
    } else {
      throw Exception("User not found for ID: $userId");
    }
  }
  
  // Method to reset the singleton state
  void reset() {
    _isInitialized = false;
  }
}

Future<void> setupSession(String userId) async {
  await Userdata().initialize(userId);
}

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _userId = '';
  bool _isLoading = true;

  // State fields previously from Userdata
  late String _channelName;
  late String _channelDescription;
  late String _profileImageUrl;
  late String _channelCreationDate;
  late int _totalViews;
  late int _totalSubs;
  late int _totalWatchtime;
  double _totalRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    _channelDescription =
        widget.initialChannelDescription ?? 'Welcome to my YouTube channel!';
    _profileImageUrl = widget.initialProfileImageUrl ?? '';
    _userId = UserSession().currentUserId ?? '';

    _loadUserData();
  }



  Future<void> _loadUserData() async {
    await setupSession(_userId);
    if (!mounted) return;

    setState(() {
      final user = Userdata();
      _channelName = user.channelName;
      _channelDescription = user.description;
      _profileImageUrl = user.channelImageLink;
      _channelCreationDate = user.channelCreationDate.toString();
      _totalViews = user.totalViews;
      _totalSubs = user.totalSubs;
      _totalWatchtime = user.totalWatchtime;

      _totalRevenue=user.totalRevenue;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color.fromARGB(255, 219, 238, 255),
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
                return Row(
  children: [
    Expanded(
      child: AnalyticsCard(
        title: 'Total Views',
        value: numberFormatter.format(_totalViews),
        icon: Icons.visibility,
      ),
    ),
    const SizedBox(width: 16),
    Expanded(
      child: AnalyticsCard(
        title: 'Subscribers',
        value: numberFormatter.format(_totalSubs),
        icon: Icons.people,
      ),
    ),
    const SizedBox(width: 16),
    Expanded(
      child: AnalyticsCard(
        title: 'Total Watchtime',
        value: _formatWatchTime(_totalWatchtime),
        icon: Icons.access_time,
      ),
    ),
    const SizedBox(width: 16),
    Expanded(
      child: AnalyticsCard(
        title: 'Revenue',
        value: '\$${_totalRevenue.toStringAsFixed(2)}',
        icon: Icons.attach_money,
      ),
    ),
  ],
);
              },
            ),
            const SizedBox(height: 32),
            over_view_widget(
              _channelName,
              _channelDescription,
              _profileImageUrl,
              _channelCreationDate,
              userId: _userId,
            ),
          ],
        ),
      ),
    );
  }
}
              

