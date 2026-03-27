import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kati_pilates/config/theme.dart';

class AvatarCircle extends StatelessWidget {
  /// URL of the avatar image. If null or empty, initials are shown.
  final String? imageUrl;

  /// Full name used to derive initials when no image is available.
  final String name;

  /// Diameter of the avatar circle. Defaults to 40.
  final double size;

  const AvatarCircle({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 40,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasImage ? null : AppColors.cardGradient,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage ? _buildImage() : _buildInitials(),
    );
  }

  Widget _buildImage() {
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: size,
      height: size,
      fit: BoxFit.cover,
      placeholder: (context, url) => _buildInitials(),
      errorWidget: (context, url, error) => _buildInitials(),
    );
  }

  Widget _buildInitials() {
    return Center(
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          height: 1,
        ),
      ),
    );
  }
}
