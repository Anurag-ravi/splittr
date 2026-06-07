import 'package:flutter/material.dart';

class NeonGlow extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;
  final double spread;
  final double glowOpacity;
  final double? width;
  final double? height;

  const NeonGlow({
    super.key,
    required this.child,
    required this.color,
    this.radius = 80,
    this.spread = 20,
    this.glowOpacity = 0.25,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // OUTER GLOW

          Container(
            width: radius * 1.8,
            height: radius * 1.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(glowOpacity),
                  blurRadius: radius,
                  spreadRadius: spread,
                ),
                BoxShadow(
                  color: color.withOpacity(glowOpacity * 0.5),
                  blurRadius: radius * 1.6,
                  spreadRadius: spread * 1.5,
                ),
              ],
            ),
          ),

          // INNER LIGHT

          Container(
            width: radius * 1.2,
            height: radius * 1.2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withOpacity(glowOpacity),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // CHILD

          child,
        ],
      ),
    );
  }
}
