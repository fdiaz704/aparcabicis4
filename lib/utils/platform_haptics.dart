import 'package:flutter/services.dart';
import 'dart:io';

/// Platform-adaptive haptic feedback system
class PlatformHaptics {
  
  /// Light haptic feedback for subtle interactions
  static Future<void> lightImpact() async {
    if (Platform.isIOS) {
      await HapticFeedback.lightImpact();
    }
    // Android doesn't have equivalent light haptic, so we skip it
  }

  /// Medium haptic feedback for standard interactions
  static Future<void> mediumImpact() async {
    if (Platform.isIOS) {
      await HapticFeedback.mediumImpact();
    } else {
      // Android fallback to vibration
      await HapticFeedback.vibrate();
    }
  }

  /// Heavy haptic feedback for important interactions
  static Future<void> heavyImpact() async {
    if (Platform.isIOS) {
      await HapticFeedback.heavyImpact();
    } else {
      // Android fallback to vibration
      await HapticFeedback.vibrate();
    }
  }

  /// Selection feedback for picker/selector interactions
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Success feedback for completed actions
  static Future<void> success() async {
    if (Platform.isIOS) {
      // iOS has specific success feedback
      await HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 50));
      await HapticFeedback.lightImpact();
    } else {
      await HapticFeedback.vibrate();
    }
  }

  /// Warning feedback for cautionary actions
  static Future<void> warning() async {
    if (Platform.isIOS) {
      await HapticFeedback.mediumImpact();
    } else {
      await HapticFeedback.vibrate();
    }
  }

  /// Error feedback for failed actions
  static Future<void> error() async {
    if (Platform.isIOS) {
      await HapticFeedback.heavyImpact();
    } else {
      await HapticFeedback.vibrate();
    }
  }

  /// Button tap feedback
  static Future<void> buttonTap() async {
    if (Platform.isIOS) {
      await HapticFeedback.lightImpact();
    }
    // Android buttons have their own ripple feedback
  }

  /// Switch toggle feedback
  static Future<void> switchToggle() async {
    await HapticFeedback.selectionClick();
  }

  /// Modal presentation feedback
  static Future<void> modalPresent() async {
    if (Platform.isIOS) {
      await HapticFeedback.lightImpact();
    }
  }

  /// Modal dismissal feedback
  static Future<void> modalDismiss() async {
    if (Platform.isIOS) {
      await HapticFeedback.lightImpact();
    }
  }

  /// Navigation feedback
  static Future<void> navigation() async {
    if (Platform.isIOS) {
      await HapticFeedback.lightImpact();
    }
  }

  /// Refresh feedback
  static Future<void> refresh() async {
    if (Platform.isIOS) {
      await HapticFeedback.mediumImpact();
    }
  }

  /// Long press feedback
  static Future<void> longPress() async {
    if (Platform.isIOS) {
      await HapticFeedback.mediumImpact();
    } else {
      await HapticFeedback.vibrate();
    }
  }

  /// Contextual feedback based on action type
  static Future<void> contextualFeedback(HapticContext context) async {
    switch (context) {
      case HapticContext.success:
        await success();
        break;
      case HapticContext.warning:
        await warning();
        break;
      case HapticContext.error:
        await error();
        break;
      case HapticContext.buttonTap:
        await buttonTap();
        break;
      case HapticContext.switchToggle:
        await switchToggle();
        break;
      case HapticContext.navigation:
        await navigation();
        break;
      case HapticContext.modalPresent:
        await modalPresent();
        break;
      case HapticContext.modalDismiss:
        await modalDismiss();
        break;
      case HapticContext.refresh:
        await refresh();
        break;
      case HapticContext.longPress:
        await longPress();
        break;
    }
  }
}

enum HapticContext {
  success,
  warning,
  error,
  buttonTap,
  switchToggle,
  navigation,
  modalPresent,
  modalDismiss,
  refresh,
  longPress,
}
