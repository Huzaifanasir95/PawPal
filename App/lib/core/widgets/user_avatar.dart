import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Reusable user avatar widget that displays profile picture or fallback icon
class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double? size;
  final IconData? fallbackIcon;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool showBorder;
  final Color? borderColor;
  final double? borderWidth;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.size,
    this.fallbackIcon,
    this.backgroundColor,
    this.iconColor,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth,
  });

  bool _isBase64DataUrl(String url) {
    return url.startsWith('data:image/');
  }

  Widget _buildImage(String url, double avatarSize, IconData icon, Color icColor) {
    // Handle base64 data URLs
    if (_isBase64DataUrl(url)) {
      try {
        final base64String = url.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            icon,
            size: avatarSize * 0.5,
            color: icColor,
          ),
        );
      } catch (e) {
        return Icon(
          icon,
          size: avatarSize * 0.5,
          color: icColor,
        );
      }
    }

    // Handle regular HTTP URLs
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      placeholder: (context, url) => Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(icColor),
        ),
      ),
      errorWidget: (context, url, error) => Icon(
        icon,
        size: avatarSize * 0.5,
        color: icColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final avatarSize = size ?? 40.w;
    final bgColor = backgroundColor ?? colorScheme.primary.withValues(alpha: 0.1);
    final icon = fallbackIcon ?? Icons.person;
    final icColor = iconColor ?? colorScheme.primary;

    return Container(
      width: avatarSize,
      height: avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: showBorder
            ? Border.all(
                color: borderColor ?? colorScheme.primary,
                width: borderWidth ?? 2.w,
              )
            : null,
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? _buildImage(imageUrl!, avatarSize, icon, icColor)
            : Icon(
                icon,
                size: avatarSize * 0.5,
                color: icColor,
              ),
      ),
    );
  }
}
