import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

/// Platform-adaptive icons that provide native look and feel on both iOS and Android
class PlatformIcons {
  
  // Navigation Icons
  static IconData get back => Platform.isIOS ? CupertinoIcons.back : Icons.arrow_back;
  static IconData get close => Platform.isIOS ? CupertinoIcons.xmark : Icons.close;
  static IconData get menu => Platform.isIOS ? CupertinoIcons.list_bullet : Icons.menu;
  static IconData get more => Platform.isIOS ? CupertinoIcons.ellipsis : Icons.more_vert;
  static IconData get chevronRight => Platform.isIOS ? CupertinoIcons.chevron_right : Icons.chevron_right;
  static IconData get chevronLeft => Platform.isIOS ? CupertinoIcons.chevron_left : Icons.chevron_left;
  static IconData get chevronDown => Platform.isIOS ? CupertinoIcons.chevron_down : Icons.keyboard_arrow_down;
  static IconData get chevronUp => Platform.isIOS ? CupertinoIcons.chevron_up : Icons.keyboard_arrow_up;

  // Communication Icons
  static IconData get phone => Platform.isIOS ? CupertinoIcons.phone : Icons.phone;
  static IconData get mail => Platform.isIOS ? CupertinoIcons.mail : Icons.email;
  static IconData get message => Platform.isIOS ? CupertinoIcons.chat_bubble : Icons.message;

  // Action Icons
  static IconData get add => Platform.isIOS ? CupertinoIcons.add : Icons.add;
  static IconData get remove => Platform.isIOS ? CupertinoIcons.minus : Icons.remove;
  static IconData get edit => Platform.isIOS ? CupertinoIcons.pencil : Icons.edit;
  static IconData get delete => Platform.isIOS ? CupertinoIcons.delete : Icons.delete;
  static IconData get share => Platform.isIOS ? CupertinoIcons.share : Icons.share;
  static IconData get download => Platform.isIOS ? CupertinoIcons.cloud_download : Icons.download;
  static IconData get upload => Platform.isIOS ? CupertinoIcons.cloud_upload : Icons.upload;
  static IconData get refresh => Platform.isIOS ? CupertinoIcons.refresh : Icons.refresh;

  // Status Icons
  static IconData get checkmark => Platform.isIOS ? CupertinoIcons.checkmark : Icons.check;
  static IconData get checkmarkCircle => Platform.isIOS ? CupertinoIcons.checkmark_circle : Icons.check_circle;
  static IconData get error => Platform.isIOS ? CupertinoIcons.exclamationmark_circle : Icons.error;
  static IconData get warning => Platform.isIOS ? CupertinoIcons.exclamationmark_triangle : Icons.warning;
  static IconData get info => Platform.isIOS ? CupertinoIcons.info_circle : Icons.info;

  // Content Icons
  static IconData get search => Platform.isIOS ? CupertinoIcons.search : Icons.search;
  static IconData get filter => Platform.isIOS ? CupertinoIcons.line_horizontal_3_decrease : Icons.filter_list;
  static IconData get sort => Platform.isIOS ? CupertinoIcons.arrow_up_down : Icons.sort;
  static IconData get calendar => Platform.isIOS ? CupertinoIcons.calendar : Icons.calendar_today;
  static IconData get clock => Platform.isIOS ? CupertinoIcons.clock : Icons.access_time;
  static IconData get location => Platform.isIOS ? CupertinoIcons.location : Icons.location_on;
  static IconData get locationFill => Platform.isIOS ? CupertinoIcons.location_solid : Icons.location_on;

  // Settings Icons
  static IconData get settings => Platform.isIOS ? CupertinoIcons.settings : Icons.settings;
  static IconData get profile => Platform.isIOS ? CupertinoIcons.person : Icons.person;
  static IconData get help => Platform.isIOS ? CupertinoIcons.question : Icons.help_outline;
  static IconData get about => Platform.isIOS ? CupertinoIcons.info_circle : Icons.info_outline;
  static IconData get privacy => Platform.isIOS ? CupertinoIcons.lock : Icons.privacy_tip;
  static IconData get security => Platform.isIOS ? CupertinoIcons.lock : Icons.security;

  // App-specific Icons
  static IconData get bike => Icons.directions_bike;
  static IconData get parking => Platform.isIOS ? CupertinoIcons.car_detailed : Icons.local_parking;
  static IconData get station => Platform.isIOS ? CupertinoIcons.map_pin_ellipse : Icons.pin_drop_outlined;
  static IconData get reservation => calendar;
  static IconData get history => Platform.isIOS ? CupertinoIcons.clock : Icons.history;
  static IconData get favorite => Platform.isIOS ? CupertinoIcons.heart : Icons.favorite;
  static IconData get favoriteBorder => Platform.isIOS ? CupertinoIcons.heart : Icons.favorite_border;
  static IconData get star => Platform.isIOS ? CupertinoIcons.star : Icons.star;
  static IconData get starBorder => Platform.isIOS ? CupertinoIcons.star : Icons.star_border;

  // Visibility Icons
  static IconData get visibility => Platform.isIOS ? CupertinoIcons.eye : Icons.visibility;
  static IconData get visibilityOff => Platform.isIOS ? CupertinoIcons.eye_slash : Icons.visibility_off;

  // Media Icons
  static IconData get play => Platform.isIOS ? CupertinoIcons.play : Icons.play_arrow;
  static IconData get pause => Platform.isIOS ? CupertinoIcons.pause : Icons.pause;
  static IconData get stop => Platform.isIOS ? CupertinoIcons.stop : Icons.stop;

  // System Icons
  static IconData get home => Platform.isIOS ? CupertinoIcons.home : Icons.home;
  static IconData get notifications => Platform.isIOS ? CupertinoIcons.bell : Icons.notifications;
  static IconData get notificationsOff => Platform.isIOS ? CupertinoIcons.bell_slash : Icons.notifications_off;
  static IconData get language => Platform.isIOS ? CupertinoIcons.globe : Icons.language;
  static IconData get darkMode => Platform.isIOS ? CupertinoIcons.moon : Icons.dark_mode;
  static IconData get lightMode => Platform.isIOS ? CupertinoIcons.sun_max : Icons.light_mode;

  // Tab Bar Icons (commonly used in bottom navigation)
  static IconData get homeTab => Platform.isIOS ? CupertinoIcons.house : Icons.home_outlined;
  static IconData get homeTabFilled => Platform.isIOS ? CupertinoIcons.house_fill : Icons.home;
  static IconData get searchTab => Platform.isIOS ? CupertinoIcons.search : Icons.search_outlined;
  static IconData get searchTabFilled => Platform.isIOS ? CupertinoIcons.search : Icons.search;
  static IconData get profileTab => Platform.isIOS ? CupertinoIcons.person : Icons.person_outline;
  static IconData get profileTabFilled => Platform.isIOS ? CupertinoIcons.person_fill : Icons.person;
  static IconData get settingsTab => Platform.isIOS ? CupertinoIcons.settings : Icons.settings_outlined;
  static IconData get settingsTabFilled => Platform.isIOS ? CupertinoIcons.gear : Icons.settings;

  // Form Icons
  static IconData get textField => Platform.isIOS ? CupertinoIcons.text_cursor : Icons.text_fields;
  static IconData get password => Platform.isIOS ? CupertinoIcons.lock : Icons.lock_outline;
  static IconData get user => Platform.isIOS ? CupertinoIcons.person : Icons.person_outline;
  static IconData get key => Platform.isIOS ? CupertinoIcons.lock : Icons.key;

  // Status and Feedback Icons
  static IconData get success => Platform.isIOS ? CupertinoIcons.checkmark_circle_fill : Icons.check_circle;
  static IconData get errorFilled => Platform.isIOS ? CupertinoIcons.exclamationmark_circle_fill : Icons.error;
  static IconData get warningFilled => Platform.isIOS ? CupertinoIcons.exclamationmark_triangle_fill : Icons.warning_amber;
  static IconData get infoFilled => Platform.isIOS ? CupertinoIcons.info_circle_fill : Icons.info;


  /// Get platform-appropriate icon size for different contexts
  static double getIconSize(IconSize size) {
    switch (size) {
      case IconSize.small:
        return Platform.isIOS ? 16.0 : 18.0;
      case IconSize.medium:
        return Platform.isIOS ? 20.0 : 24.0;
      case IconSize.large:
        return Platform.isIOS ? 28.0 : 32.0;
      case IconSize.extraLarge:
        return Platform.isIOS ? 36.0 : 40.0;
    }
  }

  /// Get platform-appropriate icon color for different states
  static Color getIconColor(BuildContext context, IconColorType type) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    if (Platform.isIOS) {
      switch (type) {
        case IconColorType.primary:
          return CupertinoColors.systemBlue;
        case IconColorType.secondary:
          return isDark ? CupertinoColors.systemGrey : CupertinoColors.systemGrey2;
        case IconColorType.success:
          return CupertinoColors.systemGreen;
        case IconColorType.error:
          return CupertinoColors.systemRed;
        case IconColorType.warning:
          return CupertinoColors.systemOrange;
        case IconColorType.info:
          return CupertinoColors.systemBlue;
        case IconColorType.disabled:
          return isDark ? CupertinoColors.systemGrey2 : CupertinoColors.systemGrey3;
      }
    } else {
      switch (type) {
        case IconColorType.primary:
          return theme.primaryColor;
        case IconColorType.secondary:
          return theme.colorScheme.secondary;
        case IconColorType.success:
          return Colors.green;
        case IconColorType.error:
          return theme.colorScheme.error;
        case IconColorType.warning:
          return Colors.orange;
        case IconColorType.info:
          return Colors.blue;
        case IconColorType.disabled:
          return theme.disabledColor;
      }
    }
  }
}

enum IconSize {
  small,
  medium,
  large,
  extraLarge,
}

enum IconColorType {
  primary,
  secondary,
  success,
  error,
  warning,
  info,
  disabled,
}
