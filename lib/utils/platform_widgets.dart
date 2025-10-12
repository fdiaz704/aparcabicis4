import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'constants.dart';
import 'platform_icons.dart';
import 'platform_haptics.dart';

/// Platform-adaptive widgets that provide native look and feel on both iOS and Android
class PlatformWidgets {
  
  /// Shows an adaptive modal that uses bottom sheet on Android and centered dialog on iOS
  static Future<T?> showAdaptiveModalBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = true,
  }) async {
    // Add haptic feedback for modal presentation
    await PlatformHaptics.modalPresent();
    
    if (Platform.isIOS) {
      // Use centered modal dialog for iOS
      return showDialog<T>(
        context: context,
        barrierDismissible: isDismissible,
        builder: (context) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: child,
          ),
        ),
      );
    } else {
      // Use bottom sheet for Android with better constraints
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: isScrollControlled,
        isDismissible: isDismissible,
        enableDrag: true,
        useSafeArea: true,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.borderRadius),
          ),
        ),
        builder: (context) => child,
      );
    }
  }

  /// Shows an adaptive confirmation dialog
  static Future<bool> showAdaptiveConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    bool isDestructive = false,
  }) async {
    if (Platform.isIOS) {
      final result = await showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(true),
              isDestructiveAction: isDestructive,
              child: Text(confirmText),
            ),
          ],
        ),
      );
      return result ?? false;
    } else {
      // Use Material AlertDialog for Android
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: isDestructive
                  ? TextButton.styleFrom(foregroundColor: Colors.red)
                  : null,
              child: Text(confirmText),
            ),
          ],
        ),
      );
      return result ?? false;
    }
  }

  /// Creates an adaptive switch widget
  static Widget buildAdaptiveSwitch({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? activeColor,
  }) {
    final color = activeColor ?? AppColors.primary;
    
    if (Platform.isIOS) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            CupertinoSwitch(
              value: value,
              onChanged: (newValue) {
                PlatformHaptics.switchToggle();
                onChanged(newValue);
              },
              activeColor: color,
            ),
          ],
        ),
      );
    } else {
      return SwitchListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        value: value,
        onChanged: (newValue) {
          PlatformHaptics.switchToggle();
          onChanged(newValue);
        },
        activeColor: color,
      );
    }
  }

  /// Creates an adaptive radio list tile
  static Widget buildAdaptiveRadioListTile<T>({
    required String title,
    String? subtitle,
    required T value,
    required T groupValue,
    required ValueChanged<T?> onChanged,
    Color? activeColor,
  }) {
    final color = activeColor ?? AppColors.primary;
    
    if (Platform.isIOS) {
      final isSelected = value == groupValue;
      return GestureDetector(
        onTap: () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  CupertinoIcons.checkmark,
                  color: color,
                  size: 20,
                ),
            ],
          ),
        ),
      );
    } else {
      return RadioListTile<T>(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: color,
      );
    }
  }

  /// Creates an adaptive list tile
  static Widget buildAdaptiveListTile({
    required String title,
    String? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    if (Platform.isIOS) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                leading,
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: AppSpacing.sm),
                trailing,
              ] else if (onTap != null) ...[
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ],
          ),
        ),
      );
    } else {
      return ListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle) : null,
        leading: leading,
        trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
        onTap: onTap,
      );
    }
  }

  /// Creates an adaptive close button for modals
  static Widget buildAdaptiveCloseButton(BuildContext context) {
    if (Platform.isIOS) {
      return IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(CupertinoIcons.xmark),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      );
    } else {
      return IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.close),
      );
    }
  }

  /// Creates an adaptive back button
  static Widget buildAdaptiveBackButton(BuildContext context) {
    if (Platform.isIOS) {
      return IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(PlatformIcons.back),
      );
    } else {
      return IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Icon(PlatformIcons.back),
      );
    }
  }

  /// Creates an adaptive app bar
  static PreferredSizeWidget buildAdaptiveAppBar({
    required BuildContext context,
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool automaticallyImplyLeading = true,
    Color? backgroundColor,
  }) {
    if (Platform.isIOS) {
      return CupertinoNavigationBar(
        middle: Text(title),
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: backgroundColor,
        trailing: actions != null && actions.isNotEmpty
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: actions,
              )
            : null,
      );
    } else {
      return AppBar(
        title: Text(title),
        actions: actions,
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: backgroundColor,
      );
    }
  }

  /// Creates an adaptive button
  static Widget buildAdaptiveButton({
    required String text,
    required VoidCallback? onPressed,
    bool isPrimary = true,
    bool isDestructive = false,
    EdgeInsetsGeometry? padding,
  }) {
    if (Platform.isIOS) {
      return CupertinoButton(
        onPressed: onPressed,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: isPrimary ? CupertinoColors.activeBlue : null,
        child: Text(
          text,
          style: TextStyle(
            color: isDestructive 
                ? CupertinoColors.destructiveRed 
                : isPrimary 
                    ? CupertinoColors.white 
                    : CupertinoColors.activeBlue,
          ),
        ),
      );
    } else {
      return isPrimary
          ? ElevatedButton(
              onPressed: onPressed,
              style: isDestructive
                  ? ElevatedButton.styleFrom(backgroundColor: Colors.red)
                  : null,
              child: Text(text),
            )
          : TextButton(
              onPressed: onPressed,
              style: isDestructive
                  ? TextButton.styleFrom(foregroundColor: Colors.red)
                  : null,
              child: Text(text),
            );
    }
  }

  /// Creates an adaptive text field
  static Widget buildAdaptiveTextField({
    required String placeholder,
    TextEditingController? controller,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? prefix,
    Widget? suffix,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    if (Platform.isIOS) {
      return CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        obscureText: obscureText,
        keyboardType: keyboardType,
        prefix: prefix != null ? Padding(
          padding: const EdgeInsets.only(left: 8),
          child: prefix,
        ) : null,
        suffix: suffix != null ? Padding(
          padding: const EdgeInsets.only(right: 8),
          child: suffix,
        ) : null,
        onChanged: onChanged,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: CupertinoColors.systemGrey4),
          borderRadius: BorderRadius.circular(8),
        ),
      );
    } else {
      return TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: placeholder,
          prefixIcon: prefix,
          suffixIcon: suffix,
        ),
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
      );
    }
  }

  /// Creates an adaptive loading indicator
  static Widget buildAdaptiveLoadingIndicator({
    Color? color,
    double? size,
  }) {
    if (Platform.isIOS) {
      return CupertinoActivityIndicator(
        color: color,
        radius: size != null ? size / 2 : 10,
      );
    } else {
      return CircularProgressIndicator(
        color: color,
        strokeWidth: 2,
      );
    }
  }

  /// Creates an adaptive refresh indicator
  static Widget buildAdaptiveRefreshIndicator({
    required Widget child,
    required Future<void> Function() onRefresh,
  }) {
    if (Platform.isIOS) {
      return CustomScrollView(
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: onRefresh,
          ),
          SliverToBoxAdapter(child: child),
        ],
      );
    } else {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: child,
      );
    }
  }

  /// Creates an adaptive segmented control
  static Widget buildAdaptiveSegmentedControl<T extends Object>({
    required Map<T, Widget> children,
    required T? groupValue,
    required ValueChanged<T?> onValueChanged,
  }) {
    if (Platform.isIOS) {
      return CupertinoSegmentedControl<T>(
        children: children,
        groupValue: groupValue,
        onValueChanged: onValueChanged,
      );
    } else {
      return ToggleButtons(
        isSelected: children.keys.map((key) => key == groupValue).toList(),
        onPressed: (index) {
          final key = children.keys.elementAt(index);
          onValueChanged(key);
        },
        children: children.values.toList(),
      );
    }
  }
}
