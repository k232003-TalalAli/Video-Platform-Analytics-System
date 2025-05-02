import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';

class FeedbackScreen extends StatefulWidget {
  final String channelName;
  final String channelDescription;
  final String profileImageUrl;
  final Function(String, String, String) onProfileUpdate;

  const FeedbackScreen({
    Key? key,
    required this.channelName,
    required this.channelDescription,
    required this.profileImageUrl,
    required this.onProfileUpdate,
  }) : super(key: key);

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  late String _channelName;
  late String _channelDescription;
  late String _profileImageUrl;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _channelName = widget.channelName;
    _channelDescription = widget.channelDescription;
    _profileImageUrl = widget.profileImageUrl;
  }

  void _handleProfileUpdate(String name, String description, String imageUrl) {
    if (!mounted) return;
    setState(() {
      _channelName = name;
      _channelDescription = description;
      _profileImageUrl = imageUrl;
    });
    widget.onProfileUpdate(name, description, imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        channelName: _channelName,
        channelDescription: _channelDescription,
        profileImageUrl: _profileImageUrl,
        scaffoldKey: _scaffoldKey,
        onProfileUpdate: _handleProfileUpdate,
      ),
      drawer: CustomDrawer(
        channelName: _channelName,
        channelDescription: _channelDescription,
        profileImageUrl: _profileImageUrl,
        selectedIndex: 2, // Feedback page index
        onProfileUpdate: _handleProfileUpdate,
      ),
      drawerEdgeDragWidth: 0,
      body: Center(
        child: Text(
          'Feedback Page',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
} 