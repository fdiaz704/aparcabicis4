import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

/// Platform-specific scrolling behaviors and physics
class PlatformScrolling {
  
  /// Get platform-appropriate scroll physics
  static ScrollPhysics get defaultPhysics => Platform.isIOS 
      ? const BouncingScrollPhysics()
      : const ClampingScrollPhysics();

  /// Get platform-appropriate scroll physics for always scrollable content
  static ScrollPhysics get alwaysScrollablePhysics => Platform.isIOS 
      ? const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics())
      : const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics());

  /// Get platform-appropriate scroll physics for never scrollable content
  static ScrollPhysics get neverScrollablePhysics => const NeverScrollableScrollPhysics();

  /// Create a platform-appropriate scrollable widget
  static Widget buildAdaptiveScrollView({
    required List<Widget> children,
    ScrollController? controller,
    EdgeInsets? padding,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
    Axis scrollDirection = Axis.vertical,
  }) {
    return ListView(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics ?? defaultPhysics,
      scrollDirection: scrollDirection,
      children: children,
    );
  }

  /// Create a platform-appropriate custom scroll view
  static Widget buildAdaptiveCustomScrollView({
    required List<Widget> slivers,
    ScrollController? controller,
    ScrollPhysics? physics,
    Axis scrollDirection = Axis.vertical,
  }) {
    return CustomScrollView(
      controller: controller,
      physics: physics ?? defaultPhysics,
      scrollDirection: scrollDirection,
      slivers: slivers,
    );
  }

  /// Create a platform-appropriate refresh indicator
  static Widget buildAdaptiveRefreshIndicator({
    required Widget child,
    required Future<void> Function() onRefresh,
    Color? color,
  }) {
    if (Platform.isIOS) {
      return CustomScrollView(
        physics: alwaysScrollablePhysics,
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: onRefresh,
            builder: (context, refreshState, pulledExtent, refreshTriggerPullDistance, refreshIndicatorExtent) {
              return Container(
                alignment: Alignment.center,
                child: const CupertinoActivityIndicator(),
              );
            },
          ),
          SliverToBoxAdapter(child: child),
        ],
      );
    } else {
      return RefreshIndicator(
        onRefresh: onRefresh,
        color: color,
        child: child,
      );
    }
  }

  /// Create a platform-appropriate sliver app bar
  static Widget buildAdaptiveSliverAppBar({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool pinned = true,
    bool floating = false,
    double? expandedHeight,
    Widget? flexibleSpace,
    Color? backgroundColor,
  }) {
    if (Platform.isIOS) {
      return CupertinoSliverNavigationBar(
        largeTitle: Text(title),
        leading: leading,
        trailing: actions != null && actions.isNotEmpty
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: actions,
              )
            : null,
        backgroundColor: backgroundColor,
      );
    } else {
      return SliverAppBar(
        title: Text(title),
        actions: actions,
        leading: leading,
        pinned: pinned,
        floating: floating,
        expandedHeight: expandedHeight,
        flexibleSpace: flexibleSpace,
        backgroundColor: backgroundColor,
      );
    }
  }

  /// Create a platform-appropriate nested scroll view
  static Widget buildAdaptiveNestedScrollView({
    required Widget headerSliverBuilder,
    required Widget body,
    ScrollController? controller,
    ScrollPhysics? physics,
  }) {
    return NestedScrollView(
      controller: controller,
      physics: physics ?? defaultPhysics,
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        headerSliverBuilder,
      ],
      body: body,
    );
  }

  /// Create a platform-appropriate list view with separators
  static Widget buildAdaptiveListView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    Widget Function(BuildContext, int)? separatorBuilder,
    ScrollController? controller,
    EdgeInsets? padding,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
  }) {
    if (separatorBuilder != null) {
      return ListView.separated(
        controller: controller,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics ?? defaultPhysics,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
        separatorBuilder: separatorBuilder,
      );
    } else {
      return ListView.builder(
        controller: controller,
        padding: padding,
        shrinkWrap: shrinkWrap,
        physics: physics ?? defaultPhysics,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      );
    }
  }

  /// Create a platform-appropriate grid view
  static Widget buildAdaptiveGridView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required SliverGridDelegate gridDelegate,
    ScrollController? controller,
    EdgeInsets? padding,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
  }) {
    return GridView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics ?? defaultPhysics,
      gridDelegate: gridDelegate,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }

  /// Create a platform-appropriate page view
  static Widget buildAdaptivePageView({
    required List<Widget> children,
    PageController? controller,
    ScrollPhysics? physics,
    Axis scrollDirection = Axis.horizontal,
    void Function(int)? onPageChanged,
  }) {
    return PageView(
      controller: controller,
      physics: physics ?? (Platform.isIOS 
          ? const BouncingScrollPhysics()
          : const ClampingScrollPhysics()),
      scrollDirection: scrollDirection,
      onPageChanged: onPageChanged,
      children: children,
    );
  }

  /// Create a platform-appropriate single child scroll view
  static Widget buildAdaptiveSingleChildScrollView({
    required Widget child,
    ScrollController? controller,
    EdgeInsets? padding,
    ScrollPhysics? physics,
    Axis scrollDirection = Axis.vertical,
  }) {
    return SingleChildScrollView(
      controller: controller,
      padding: padding,
      physics: physics ?? defaultPhysics,
      scrollDirection: scrollDirection,
      child: child,
    );
  }

  /// Get platform-appropriate scroll behavior
  static ScrollBehavior get adaptiveScrollBehavior => Platform.isIOS 
      ? const CupertinoScrollBehavior()
      : const MaterialScrollBehavior();

  /// Create a platform-appropriate scrollbar
  static Widget buildAdaptiveScrollbar({
    required Widget child,
    ScrollController? controller,
    bool? thumbVisibility,
    bool? trackVisibility,
  }) {
    if (Platform.isIOS) {
      return CupertinoScrollbar(
        controller: controller,
        thumbVisibility: thumbVisibility,
        child: child,
      );
    } else {
      return Scrollbar(
        controller: controller,
        thumbVisibility: thumbVisibility,
        trackVisibility: trackVisibility,
        child: child,
      );
    }
  }

  /// Create a platform-appropriate reorderable list view
  static Widget buildAdaptiveReorderableListView({
    required List<Widget> children,
    required void Function(int, int) onReorder,
    ScrollController? controller,
    EdgeInsets? padding,
    ScrollPhysics? physics,
  }) {
    return ReorderableListView(
      onReorder: onReorder,
      scrollController: controller,
      padding: padding,
      physics: physics ?? defaultPhysics,
      children: children,
    );
  }
}
