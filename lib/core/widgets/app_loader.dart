import 'package:flutter/material.dart';
import 'package:splittr/core/theme/app_colors.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.color = AppColors.primary});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: color),
    );
  }
}

/// Slim horizontal loading bar shown at the top of a list while refreshing.
class ApiLoader extends StatelessWidget {
  const ApiLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: LinearProgressIndicator(
        backgroundColor: Colors.transparent,
        color: AppColors.primary,
      ),
    );
  }
}
