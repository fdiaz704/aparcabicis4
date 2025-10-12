import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'constants.dart';

/// Adaptive theme system that provides native theming for both iOS and Android
class AdaptiveTheme {
  
  /// Get the appropriate theme data for the current platform
  static ThemeData getMaterialTheme({bool isDark = false}) {
    final colorScheme = isDark 
        ? ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          )
        : ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? colorScheme.surface : AppColors.primary,
        foregroundColor: isDark ? colorScheme.onSurface : Colors.white,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: isDark 
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
        color: isDark ? colorScheme.surfaceVariant : Colors.white,
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          ),
          elevation: 2,
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          ),
          side: BorderSide(color: AppColors.primary),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        filled: true,
        fillColor: isDark ? colorScheme.surfaceVariant : Colors.grey[50],
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey[600],
        backgroundColor: isDark ? colorScheme.surface : Colors.white,
        elevation: 8,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return null;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary.withOpacity(0.5);
          }
          return null;
        }),
      ),
      
      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return null;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.primary;
          }
          return null;
        }),
      ),
      
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
        actionTextColor: AppColors.primary,
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        ),
        elevation: 8,
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: isDark ? Colors.grey[700] : Colors.grey[300],
        thickness: 1,
        space: 1,
      ),
    );
  }

  /// Get the appropriate Cupertino theme data for iOS
  static CupertinoThemeData getCupertinoTheme({bool isDark = false}) {
    return CupertinoThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: AppColors.primary,
      primaryContrastingColor: Colors.white,
      scaffoldBackgroundColor: isDark 
          ? CupertinoColors.systemBackground.darkColor
          : CupertinoColors.systemBackground.color,
      
      textTheme: CupertinoTextThemeData(
        primaryColor: AppColors.primary,
        textStyle: TextStyle(
          color: isDark ? CupertinoColors.label.darkColor : CupertinoColors.label.color,
          fontSize: 16,
        ),
        actionTextStyle: TextStyle(
          color: AppColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        tabLabelTextStyle: TextStyle(
          color: isDark ? CupertinoColors.label.darkColor : CupertinoColors.label.color,
          fontSize: 12,
        ),
        navTitleTextStyle: TextStyle(
          color: isDark ? CupertinoColors.label.darkColor : CupertinoColors.label.color,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        navLargeTitleTextStyle: TextStyle(
          color: isDark ? CupertinoColors.label.darkColor : CupertinoColors.label.color,
          fontSize: 34,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      barBackgroundColor: isDark 
          ? CupertinoColors.systemBackground.darkColor
          : CupertinoColors.systemBackground.color,
    );
  }

  /// Get system overlay style for status bar
  static SystemUiOverlayStyle getSystemOverlayStyle({bool isDark = false}) {
    if (Platform.isIOS) {
      return isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;
    } else {
      return SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: isDark ? Colors.black : Colors.white,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      );
    }
  }

  /// Apply platform-specific system UI overlay
  static void applySystemOverlay({bool isDark = false}) {
    SystemChrome.setSystemUIOverlayStyle(getSystemOverlayStyle(isDark: isDark));
  }

  /// Get adaptive colors that work on both platforms
  static AdaptiveColors getAdaptiveColors(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (Platform.isIOS) {
      return AdaptiveColors(
        primary: AppColors.primary,
        background: isDark 
            ? CupertinoColors.systemBackground.darkColor
            : CupertinoColors.systemBackground.color,
        surface: isDark 
            ? CupertinoColors.secondarySystemBackground.darkColor
            : CupertinoColors.secondarySystemBackground.color,
        onPrimary: Colors.white,
        onBackground: isDark 
            ? CupertinoColors.label.darkColor
            : CupertinoColors.label.color,
        onSurface: isDark 
            ? CupertinoColors.label.darkColor
            : CupertinoColors.label.color,
        secondary: isDark 
            ? CupertinoColors.secondaryLabel.darkColor
            : CupertinoColors.secondaryLabel.color,
        tertiary: isDark 
            ? CupertinoColors.tertiaryLabel.darkColor
            : CupertinoColors.tertiaryLabel.color,
        separator: isDark 
            ? CupertinoColors.separator.darkColor
            : CupertinoColors.separator.color,
      );
    } else {
      final colorScheme = Theme.of(context).colorScheme;
      return AdaptiveColors(
        primary: colorScheme.primary,
        background: colorScheme.background,
        surface: colorScheme.surface,
        onPrimary: colorScheme.onPrimary,
        onBackground: colorScheme.onBackground,
        onSurface: colorScheme.onSurface,
        secondary: colorScheme.secondary,
        tertiary: colorScheme.tertiary,
        separator: isDark ? Colors.grey[700]! : Colors.grey[300]!,
      );
    }
  }
}

/// Adaptive color scheme that works on both platforms
class AdaptiveColors {
  final Color primary;
  final Color background;
  final Color surface;
  final Color onPrimary;
  final Color onBackground;
  final Color onSurface;
  final Color secondary;
  final Color tertiary;
  final Color separator;

  const AdaptiveColors({
    required this.primary,
    required this.background,
    required this.surface,
    required this.onPrimary,
    required this.onBackground,
    required this.onSurface,
    required this.secondary,
    required this.tertiary,
    required this.separator,
  });
}
