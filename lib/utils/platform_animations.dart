import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

/// Platform-specific animations and transitions
class PlatformAnimations {
  
  /// Get platform-appropriate animation duration
  static Duration get fastDuration => Platform.isIOS 
      ? const Duration(milliseconds: 200) 
      : const Duration(milliseconds: 150);
  
  static Duration get mediumDuration => Platform.isIOS 
      ? const Duration(milliseconds: 300) 
      : const Duration(milliseconds: 250);
  
  static Duration get slowDuration => Platform.isIOS 
      ? const Duration(milliseconds: 500) 
      : const Duration(milliseconds: 400);

  /// Get platform-appropriate animation curve
  static Curve get standardCurve => Platform.isIOS 
      ? Curves.easeInOut 
      : Curves.fastOutSlowIn;
  
  static Curve get emphasizedCurve => Platform.isIOS 
      ? Curves.easeInOutCubic 
      : Curves.fastOutSlowIn;

  /// Create a platform-appropriate fade transition
  static Widget fadeTransition({
    required Animation<double> animation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }

  /// Create a platform-appropriate slide transition
  static Widget slideTransition({
    required Animation<double> animation,
    required Widget child,
    Offset? beginOffset,
  }) {
    final offset = beginOffset ?? (Platform.isIOS 
        ? const Offset(1.0, 0.0)  // iOS: slide from right
        : const Offset(0.0, 1.0)); // Android: slide from bottom
    
    return SlideTransition(
      position: Tween<Offset>(
        begin: offset,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: standardCurve,
      )),
      child: child,
    );
  }

  /// Create a platform-appropriate scale transition
  static Widget scaleTransition({
    required Animation<double> animation,
    required Widget child,
    double? beginScale,
  }) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: beginScale ?? (Platform.isIOS ? 0.9 : 0.8),
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: emphasizedCurve,
      )),
      child: child,
    );
  }

  /// Create a platform-appropriate modal transition
  static Widget modalTransition({
    required Animation<double> animation,
    required Widget child,
  }) {
    if (Platform.isIOS) {
      // iOS: Scale + fade combination
      return ScaleTransition(
        scale: Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        )),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    } else {
      // Android: Slide from bottom
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.fastOutSlowIn,
        )),
        child: child,
      );
    }
  }

  /// Create a platform-appropriate list item animation
  static Widget listItemAnimation({
    required Animation<double> animation,
    required Widget child,
    int index = 0,
  }) {
    final delay = Duration(milliseconds: index * 50);
    
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final delayedAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Interval(
            delay.inMilliseconds / mediumDuration.inMilliseconds,
            1.0,
            curve: standardCurve,
          ),
        ));

        return Transform.translate(
          offset: Offset(
            0,
            (1 - delayedAnimation.value) * 50,
          ),
          child: Opacity(
            opacity: delayedAnimation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Create a platform-appropriate button press animation
  static Widget buttonPressAnimation({
    required Widget child,
    required VoidCallback? onPressed,
    double? pressedScale,
  }) {
    if (Platform.isIOS) {
      // iOS: Scale down on press
      return GestureDetector(
        onTapDown: (_) {},
        onTapUp: (_) => onPressed?.call(),
        onTapCancel: () {},
        child: AnimatedScale(
          scale: 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: child,
        ),
      );
    } else {
      // Android: Use Material ripple
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: child,
        ),
      );
    }
  }

  /// Create a staggered animation for multiple children
  static List<Widget> staggeredChildren({
    required List<Widget> children,
    required Animation<double> animation,
    Duration? staggerDelay,
  }) {
    final delay = staggerDelay ?? const Duration(milliseconds: 100);
    
    return children.asMap().entries.map((entry) {
      final index = entry.key;
      final child = entry.value;
      
      return AnimatedBuilder(
        animation: animation,
        builder: (context, _) {
          final itemDelay = delay.inMilliseconds * index / mediumDuration.inMilliseconds;
          final itemAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Interval(
              itemDelay.clamp(0.0, 0.8),
              1.0,
              curve: standardCurve,
            ),
          ));

          return Transform.translate(
            offset: Offset(0, (1 - itemAnimation.value) * 30),
            child: Opacity(
              opacity: itemAnimation.value,
              child: child,
            ),
          );
        },
      );
    }).toList();
  }

  /// Create a platform-appropriate loading animation
  static Widget loadingAnimation({
    Color? color,
    double? size,
  }) {
    if (Platform.isIOS) {
      return CupertinoActivityIndicator(
        color: color,
        radius: size != null ? size / 2 : 10,
      );
    } else {
      return SizedBox(
        width: size ?? 20,
        height: size ?? 20,
        child: CircularProgressIndicator(
          color: color,
          strokeWidth: 2,
        ),
      );
    }
  }

  /// Create a platform-appropriate hero animation
  static Widget heroAnimation({
    required String tag,
    required Widget child,
    CreateRectTween? createRectTween,
  }) {
    return Hero(
      tag: tag,
      createRectTween: createRectTween ?? (Platform.isIOS 
          ? (begin, end) => RectTween(begin: begin, end: end)
          : null),
      child: child,
    );
  }

  /// Create a platform-appropriate page transition
  static PageRouteBuilder<T> createPageRoute<T>({
    required Widget page,
    RouteSettings? settings,
    Duration? transitionDuration,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      transitionDuration: transitionDuration ?? mediumDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (Platform.isIOS) {
          // iOS: Slide from right
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: child,
          );
        } else {
          // Android: Slide from bottom with fade
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.fastOutSlowIn,
            )),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        }
      },
    );
  }
}
