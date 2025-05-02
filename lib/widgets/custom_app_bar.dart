import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_settings_dialog.dart';
import 'profile_picture.dart';

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
                channelName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                channelDescription,
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
                    onPressed: () => _showProfileSettings(context),
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
      onProfileUpdate(
        tempName,
        tempDescription,
        tempImageUrl,
      );
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
          icon: const Icon(Icons.help_outline),
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