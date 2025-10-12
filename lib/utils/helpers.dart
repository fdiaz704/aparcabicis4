import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:io';
import 'platform_widgets.dart';
import 'platform_icons.dart';

class AppHelpers {
  // Email validation
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Password validation
  static bool isValidPassword(String password) {
    return password.length >= 8;
  }

  // Format time from seconds to readable string
  static String formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else {
      return '${minutes}m ${secs}s';
    }
  }

  // Format duration in minutes to hours and minutes
  static String formatDurationMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0) {
      return '${hours}h ${mins}m';
    } else {
      return '${mins}m';
    }
  }

  // Format date for display
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'es_ES').format(date);
  }

  // Format date for display (short version)
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'es_ES').format(date);
  }

  // Format month and year
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'es_ES').format(date);
  }

  // Show adaptive snackbar/toast with message
  static void showSnackBar(BuildContext context, String message, {
    Color? backgroundColor,
    Duration? duration,
    SnackBarAction? action,
  }) {
    if (Platform.isIOS) {
      // Use iOS-style banner notification
      _showIOSBanner(context, message, backgroundColor, duration);
    } else {
      // Use Android SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: duration ?? const Duration(seconds: 2),
          action: action,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static void _showIOSBanner(BuildContext context, String message, Color? backgroundColor, Duration? duration) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: backgroundColor ?? CupertinoColors.systemBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              message,
              style: CupertinoTheme.of(context).textTheme.textStyle,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    
    Timer(duration ?? const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  // Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.green,
    );
  }

  // Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.red,
    );
  }

  // Show info snackbar
  static void showInfoSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.blue,
    );
  }

  // Show warning snackbar
  static void showWarningSnackBar(BuildContext context, String message) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.orange,
    );
  }

  // Show confirmation dialog (now adaptive)
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
    bool isDestructive = false,
  }) async {
    return await PlatformWidgets.showAdaptiveConfirmationDialog(
      context,
      title: title,
      content: content,
      confirmText: confirmText,
      cancelText: cancelText,
      isDestructive: isDestructive,
    );
  }

  // Launch phone call
  static Future<void> launchPhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri.parse(phoneNumber);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        throw 'No se puede realizar la llamada';
      }
    } catch (e) {
      debugPrint('Error launching phone call: $e');
      throw 'Error al intentar realizar la llamada';
    }
  }

  // Calculate progress percentage
  static double calculateProgress(int current, int total) {
    if (total <= 0) return 0.0;
    return (current / total).clamp(0.0, 1.0);
  }

  // Get availability color based on spots
  static Color getAvailabilityColor(int availableSpots) {
    return availableSpots > 0 ? Colors.green : Colors.red;
  }

  // Get availability text
  static String getAvailabilityText(int availableSpots, int totalSpots) {
    if (availableSpots > 0) {
      return '$availableSpots plazas disponibles';
    } else {
      return 'Sin plazas disponibles';
    }
  }

  // Get badge text for availability
  static String getAvailabilityBadge(int availableSpots, int totalSpots) {
    return '$availableSpots/$totalSpots';
  }

  // Debounce function for search
  static Timer? _debounceTimer;
  static void debounce(VoidCallback callback, {Duration delay = const Duration(milliseconds: 500)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  // Generate unique ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Get greeting based on time of day
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Buenos días';
    } else if (hour < 18) {
      return 'Buenas tardes';
    } else {
      return 'Buenas noches';
    }
  }

  // Check if string contains only numbers
  static bool isNumeric(String str) {
    return RegExp(r'^[0-9]+$').hasMatch(str);
  }

  // Truncate text with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  // Get distance text (mock implementation)
  static String getDistanceText(double distance) {
    if (distance < 1000) {
      return '${distance.round()}m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km';
    }
  }

  // Validate confirmation text for deletion
  static bool isValidDeletionConfirmation(String text) {
    return text.toLowerCase() == 'eliminar';
  }

  // Format large numbers with separators
  static String formatNumber(int number) {
    final formatter = NumberFormat('#,###', 'es_ES');
    return formatter.format(number);
  }

  // Get time ago text
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'hace un momento';
    }
  }

  // Format duration from Duration object
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  // Format date and time for display
  static String formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm', 'es_ES');
    return formatter.format(dateTime);
  }
}
