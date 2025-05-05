import 'package:flutter/material.dart';
import 'profile_picture.dart';
import '../theme/app_theme.dart';

class ProfileSettingsDialog extends StatefulWidget {
  final String initialName;
  final String initialDescription;
  final Function(String, String) onSave;
  final String? profileImageUrl;
  final Function()? onChangePhoto;
  final Function()? onRemovePhoto;

  const ProfileSettingsDialog({
    super.key,
    required this.initialName,
    required this.initialDescription,
    required this.onSave,
    this.profileImageUrl,
    this.onChangePhoto,
    this.onRemovePhoto,
  });

  @override
  State<ProfileSettingsDialog> createState() => _ProfileSettingsDialogState();
}

class _ProfileSettingsDialogState extends State<ProfileSettingsDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late String? _currentImageUrl;
  String? _tempImageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController = TextEditingController(text: widget.initialDescription);
    _currentImageUrl = widget.profileImageUrl;
    _tempImageUrl = widget.profileImageUrl;
  }

  @override
  void didUpdateWidget(ProfileSettingsDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profileImageUrl != widget.profileImageUrl) {
      setState(() {
        _currentImageUrl = widget.profileImageUrl;
        _tempImageUrl = widget.profileImageUrl;
      });
    }
    if (oldWidget.initialName != widget.initialName) {
      _nameController.text = widget.initialName;
    }
    if (oldWidget.initialDescription != widget.initialDescription) {
      _descriptionController.text = widget.initialDescription;
    }
  }

  void _handleImageRemove() {
    setState(() {
      _tempImageUrl = '';
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
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
            Stack(
              alignment: Alignment.center,
              children: [
                ProfilePicture(
                  imageUrl: _tempImageUrl,
                  size: 120,
                  channelName: widget.initialName,
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: Container(
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.surfaceColor, width: 1.5),
                    ),
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        Icons.edit,
                        color: AppTheme.surfaceColor,
                        size: 16,
                      ),
                      onSelected: (value) async {
                        if (value == 'change') {
                          final result = await widget.onChangePhoto?.call();
                          if (result != null) {
                            setState(() {
                              _tempImageUrl = result;
                            });
                          }
                        } else if (value == 'remove') {
                          widget.onRemovePhoto?.call();
                          _handleImageRemove();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'change',
                          child: Row(
                            children: [
                              Icon(Icons.photo_camera, color: AppTheme.primaryColor),
                              const SizedBox(width: 8),
                              const Text('Change Photo'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'remove',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: AppTheme.accentColor),
                              const SizedBox(width: 8),
                              const Text('Remove Photo'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Channel Name',
                labelStyle: TextStyle(color: AppTheme.secondaryTextColor),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Channel Description',
                labelStyle: TextStyle(color: AppTheme.secondaryTextColor),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // Reset to original image when canceling
                    setState(() {
                      _tempImageUrl = _currentImageUrl;
                    });
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.secondaryTextColor,
                  ),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.onSave(
                      _nameController.text,
                      _descriptionController.text,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.surfaceColor,
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 