import 'package:flutter/material.dart';

abstract final class AppRadius {
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 14.0;
  static const double xl = 20.0;
  static const double full = 999.0;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
}
