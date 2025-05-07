import 'package:flutter/material.dart';
import 'dart:io';
import '../theme/app_theme.dart';

class ProfilePicture extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String? channelName;
  final Color? backgroundColor;

  const ProfilePicture({
    super.key,
    this.imageUrl,
    this.size = 120,
    this.channelName,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.primaryColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withAlpha(40),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: imageUrl == null || imageUrl!.isEmpty
            ? _buildDefaultAvatar()
            : imageUrl!.startsWith('http')
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar();
                    },
                  )
                : Image.file(
                    File(imageUrl!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildDefaultAvatar();
                    },
                  ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    if (channelName != null && channelName!.isNotEmpty) {
      return Container(
        color: backgroundColor ?? AppTheme.primaryColor,
        child: Center(
          child: Text(
            channelName![0].toUpperCase(),
            style: TextStyle(
              color: AppTheme.surfaceColor,
              fontSize: size * 0.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    return Container(
      color: backgroundColor ?? AppTheme.darkSurfaceColor,
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: AppTheme.surfaceColor,
      ),
    );
  }
}