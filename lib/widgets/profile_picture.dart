import 'package:flutter/material.dart';
import 'dart:io';

class ProfilePicture extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String? channelName;

  const ProfilePicture({
    super.key,
    this.imageUrl,
    this.size = 120,
    this.channelName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
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
        color: Colors.grey[800],
        child: Center(
          child: Text(
            channelName![0].toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
    return Container(
      color: Colors.grey[800],
      child: Icon(
        Icons.person,
        size: size * 0.6,
        color: Colors.white,
      ),
    );
  }
}