import 'dart:math';
import 'package:flutter/material.dart';
import 'package:splittr/core/theme/app_colors.dart';

class ProfileImage extends StatelessWidget {
  final String id;
  final double size;

  const ProfileImage({
    super.key,
    required this.id,
    this.size = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    final String trimmed = id.trim();

    final String firstLetter =
        trimmed.isNotEmpty ? trimmed.characters.first.toUpperCase() : '?';

    final Color baseColor = _generateColor(trimmed);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: baseColor.withOpacity(0.1),
        border: Border.all(
          color: baseColor.withOpacity(0.28),
          width: 1.2,
        ),
      ),
      child: Center(
        child: Text(
          firstLetter,
          style: TextStyle(
            color: baseColor,
            fontSize: size * 0.42,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Color _generateColor(String seed) {
    final int hash = seed.hashCode;

    final double hue = (hash % 360).toDouble();

    return HSVColor.fromAHSV(
      1,
      hue,
      0.65,
      0.85,
    ).toColor();
  }
}
