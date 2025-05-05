import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_settings_dialog.dart';
import 'profile_picture.dart';
import '../login/user_session.dart';
import '../DB/repositories/user_repository.dart';
import '../DB/models/user.dart';
import '../screens/dashboard_screen.dart';
import '../theme/app_theme.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String channelName;
  final String channelDescription;
  final String profileImageUrl;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function(String, String, String) onProfileUpdate;

  const CustomAppBar({
    Key? key,
    required this.channelName,
    required this.channelDescription,
    required this.profileImageUrl,
    required this.scaffoldKey,
    required this.onProfileUpdate,
  }) : super(key: key);

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: AppTheme.surfaceColor,
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
                  Text(
                    'Channel Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryTextColor,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppTheme.secondaryTextColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                channelName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                channelDescription,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.secondaryTextColor,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
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

  void _showProfileSettings(BuildContext context) async {
    String tempImageUrl = profileImageUrl;
    String tempName = channelName;
    String tempDescription = channelDescription;
    final ImagePicker picker = ImagePicker();

    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ProfileSettingsDialog(
        initialName: channelName,
        initialDescription: channelDescription,
        profileImageUrl: tempImageUrl,
        onChangePhoto: () async {
          final XFile? image = await picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 80,
          );
          if (image != null) {
            tempImageUrl = image.path;
            return image.path;
          }
          return null;
        },
        onRemovePhoto: () {
          tempImageUrl = '';
        },
        onSave: (name, description) {
          tempName = name;
          tempDescription = description;
          if (dialogContext.mounted) {
            Navigator.of(dialogContext).pop(true);
          }
        },
      ),
    );

    // Only update if save was pressed (result is true)
    if (result == true && context.mounted) {
      try {
        // Get current user ID
        final userId = UserSession().currentUserId;
        if (userId != null) {
          // Get the user repository
          final userRepository = UserRepository();
          
          // Get current user data
          final currentUser = await userRepository.getUserById(userId);
          
          if (currentUser != null) {
            // Create updated user object
            final updatedUser = User(
              userId: currentUser.userId,
              userName: currentUser.userName,
              channelCreationDate: currentUser.channelCreationDate,
              channelName: tempName,
              totalViews: currentUser.totalViews,
              totalSubs: currentUser.totalSubs,
              totalComments: currentUser.totalComments,
              totalWatchtime: currentUser.totalWatchtime,
              totalRevenue: currentUser.totalRevenue,
              channelImageLink: tempImageUrl,
              description: tempDescription,
            );
            
            // Save to database
            await userRepository.updateUser(updatedUser);
            
            // Update Userdata singleton for in-memory state
            Userdata userData = Userdata();
            userData.channelName = tempName;
            userData.description = tempDescription;
            userData.channelImageLink = tempImageUrl;
            
            // Update UI through callback
            onProfileUpdate(
              tempName,
              tempDescription,
              tempImageUrl,
            );
            
            print('Profile updated and saved to database successfully');
          }
        }
      } catch (e) {
        print('Error updating user profile: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(channelName),
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          scaffoldKey.currentState?.openDrawer();
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.info),
          onPressed: () => _showHelpDialog(context),
          tooltip: '',
        ),
        GestureDetector(
          onTap: () => _showProfileSettings(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ProfilePicture(
              imageUrl: profileImageUrl,
              size: 36,
              channelName: channelName,
            ),
          ),
        ),
        const SizedBox(width: 4),
      ],
    );
  }


  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 