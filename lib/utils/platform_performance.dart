import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';

/// Platform-specific performance optimizations
class PlatformPerformance {
  
  /// Initialize platform-specific performance settings
  static void initialize() {
    if (Platform.isIOS) {
      _initializeIOSOptimizations();
    } else {
      _initializeAndroidOptimizations();
    }
  }

  /// iOS-specific optimizations
  static void _initializeIOSOptimizations() {
    // Enable iOS-specific rendering optimizations
    debugRepaintRainbowEnabled = false;
    
    // Set iOS-appropriate frame rate
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // iOS devices typically handle 60fps well
      WidgetsBinding.instance.scheduleFrame();
    });
  }

  /// Android-specific optimizations
  static void _initializeAndroidOptimizations() {
    // Enable Android-specific rendering optimizations
    debugRepaintRainbowEnabled = false;
    
    // Android-specific memory optimizations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Schedule frame for Android
      WidgetsBinding.instance.scheduleFrame();
    });
  }

  /// Create a performance-optimized list view
  static Widget buildOptimizedListView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    ScrollController? controller,
    EdgeInsetsGeometry? padding,
    bool shrinkWrap = false,
    double? itemExtent,
    Widget Function(BuildContext, int)? separatorBuilder,
  }) {
    // Use itemExtent for better performance when items have fixed height
    if (itemExtent != null) {
      return ListView.builder(
        controller: controller,
        padding: padding,
        shrinkWrap: shrinkWrap,
        itemCount: itemCount,
        itemExtent: itemExtent,
        itemBuilder: itemBuilder,
        // Platform-specific optimizations
        cacheExtent: Platform.isIOS ? 250.0 : 200.0,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        addSemanticIndexes: true,
      );
    }

    if (separatorBuilder != null) {
      return ListView.separated(
        controller: controller,
        padding: padding,
        shrinkWrap: shrinkWrap,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        separatorBuilder: separatorBuilder,
        cacheExtent: Platform.isIOS ? 250.0 : 200.0,
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: true,
        addSemanticIndexes: true,
      );
    }

    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      cacheExtent: Platform.isIOS ? 250.0 : 200.0,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      addSemanticIndexes: true,
    );
  }

  /// Create a performance-optimized grid view
  static Widget buildOptimizedGridView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required SliverGridDelegate gridDelegate,
    ScrollController? controller,
    EdgeInsetsGeometry? padding,
    bool shrinkWrap = false,
  }) {
    return GridView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      gridDelegate: gridDelegate,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      // Platform-specific optimizations
      cacheExtent: Platform.isIOS ? 300.0 : 250.0,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      addSemanticIndexes: true,
    );
  }

  /// Wrap a widget with performance optimizations
  static Widget optimizeWidget(Widget child, {
    bool addRepaintBoundary = true,
    bool addSemanticBoundary = false,
  }) {
    Widget optimized = child;

    if (addRepaintBoundary) {
      optimized = RepaintBoundary(child: optimized);
    }

    if (addSemanticBoundary) {
      optimized = Semantics(
        container: true,
        child: optimized,
      );
    }

    return optimized;
  }

  /// Create a performance-optimized image widget
  static Widget buildOptimizedImage({
    required ImageProvider image,
    double? width,
    double? height,
    BoxFit? fit,
    Widget Function(BuildContext, Widget, int?, bool)? frameBuilder,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    return Image(
      image: image,
      width: width,
      height: height,
      fit: fit,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      // Performance optimizations
      gaplessPlayback: true,
      filterQuality: Platform.isIOS ? FilterQuality.medium : FilterQuality.low,
      isAntiAlias: Platform.isIOS,
    );
  }

  /// Create a performance-optimized cached network image placeholder
  static Widget buildOptimizedNetworkImage({
    required String url,
    double? width,
    double? height,
    BoxFit? fit,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      filterQuality: Platform.isIOS ? FilterQuality.medium : FilterQuality.low,
      isAntiAlias: Platform.isIOS,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? const CircularProgressIndicator();
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? const Icon(Icons.error);
      },
    );
  }

  /// Optimize animations for the current platform
  static AnimationController createOptimizedAnimationController({
    required Duration duration,
    required TickerProvider vsync,
    Duration? reverseDuration,
    double? value,
    double lowerBound = 0.0,
    double upperBound = 1.0,
  }) {
    // Adjust animation duration based on platform
    final optimizedDuration = Platform.isIOS 
        ? duration 
        : Duration(milliseconds: (duration.inMilliseconds * 0.8).round());

    return AnimationController(
      duration: optimizedDuration,
      reverseDuration: reverseDuration,
      value: value,
      lowerBound: lowerBound,
      upperBound: upperBound,
      vsync: vsync,
    );
  }

  /// Create a performance-optimized custom scroll view
  static Widget buildOptimizedCustomScrollView({
    required List<Widget> slivers,
    ScrollController? controller,
    Axis scrollDirection = Axis.vertical,
  }) {
    return CustomScrollView(
      controller: controller,
      scrollDirection: scrollDirection,
      slivers: slivers,
      // Performance optimizations
      cacheExtent: Platform.isIOS ? 300.0 : 250.0,
      semanticChildCount: slivers.length,
    );
  }

  /// Debounce function calls for performance
  static void debounce({
    required String key,
    required VoidCallback callback,
    Duration delay = const Duration(milliseconds: 300),
  }) {
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(delay, callback);
  }

  static final Map<String, Timer> _debounceTimers = {};

  /// Throttle function calls for performance
  static void throttle({
    required String key,
    required VoidCallback callback,
    Duration interval = const Duration(milliseconds: 100),
  }) {
    if (_throttleTimers.containsKey(key)) return;
    
    callback();
    _throttleTimers[key] = Timer(interval, () {
      _throttleTimers.remove(key);
    });
  }

  static final Map<String, Timer> _throttleTimers = {};

  /// Optimize memory usage by disposing resources
  static void disposeResources() {
    // Cancel all debounce timers
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();

    // Cancel all throttle timers
    for (final timer in _throttleTimers.values) {
      timer.cancel();
    }
    _throttleTimers.clear();
  }

  /// Get platform-appropriate cache extent
  static double get cacheExtent => Platform.isIOS ? 250.0 : 200.0;

  /// Get platform-appropriate filter quality
  static FilterQuality get filterQuality => Platform.isIOS 
      ? FilterQuality.medium 
      : FilterQuality.low;

  /// Check if the device is low-end and adjust accordingly
  static bool get isLowEndDevice {
    // This is a simplified check - in a real app you might want to
    // check actual device specifications
    return Platform.isAndroid;
  }

  /// Get optimized animation duration based on device performance
  static Duration getOptimizedDuration(Duration baseDuration) {
    if (isLowEndDevice) {
      return Duration(milliseconds: (baseDuration.inMilliseconds * 0.7).round());
    }
    return baseDuration;
  }
}
