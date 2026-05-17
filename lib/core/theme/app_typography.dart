import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const double _xs = 10.0;
  static const double _sm = 12.0;
  static const double _md = 15.0;
  static const double _lg = 16.0;
  static const double _xl = 18.0;
  static const double _xxl = 20.0;
  static const double _display = 28.0;

  static const TextStyle displayBold = TextStyle(
    fontSize: _display,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: _xxl,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: _xl,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: _lg,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: _md,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: _sm,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: _xs,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: _sm,
    fontWeight: FontWeight.normal,
    color: Colors.white,
  );
}
