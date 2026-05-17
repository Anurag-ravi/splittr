import 'package:flutter/services.dart';

abstract final class Haptics {
  static void medium() {
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
  }
}
