import 'package:flutter/material.dart';

// App Constants
class AppConstants {
  // App Info
  static const String appName = 'Aparcabicis';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Sistema móvil de reserva y control de plazas de aparcamiento inteligente para bicicletas';
  
  // Timer Constants
  static const int reservationTimeoutMinutes = 30;
  static const int reservationTimeoutSeconds = 1800; // 30 * 60
  static const int maxUsageTimeMinutes = 840; // 14 hours
  static const int maxUsageTimeSeconds = 50400; // 840 * 60
  static const int warningTimeSeconds = 300; // 5 minutes
  
  // Support
  static const String supportPhone = 'tel:+34900000000';
  
  // SharedPreferences Keys
  static const String prefKeyEmail = 'bikeParking_email';
  static const String prefKeyPassword = 'bikeParking_password';
  static const String prefKeyRememberMe = 'bikeParking_rememberMe';
  static const String prefKeyFavorites = 'bikeParking_favorites';
  static const String prefKeyHistory = 'bikeParking_history';
  
  // Validation Constants
  static const int minPasswordLength = 8;
  static const String deleteConfirmationText = 'ELIMINAR';
}

// App Colors
class AppColors {
  // Primary Color
  static const Color primary = Color(0xFF7AB782);
  
  // Semantic Colors
  static const Color success = Color(0xFF7AB782);
  static const Color error = Colors.red;
  static const Color warning = Colors.orange;
  static const Color info = Colors.blue;
  
  // Status Colors
  static const Color available = Color(0xFF7AB782);
  static const Color unavailable = Colors.red;
  static const Color reserved = Colors.blue;
  static const Color favorite = Colors.amber;
  
  // Background Gradients
  static const List<Color> loginGradient = [
    Color(0xFFEFF6FF), // from-blue-50
    Color(0xFFDBEAFE), // to-blue-100
  ];
  
  static const List<Color> profileGradient = [
    Color(0xFFEFF6FF), // from-blue-50
    Colors.white,      // to-background
  ];
  
  static const List<Color> mapGradient = [
    Color(0xFFDBEAFE), // from-blue-100
    Color(0xFFDCFCE7), // to-green-100
  ];
}

// App Text Styles
class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );
}

// App Spacing
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// App Dimensions
class AppDimensions {
  static const double borderRadius = 8.0;
  static const double cardElevation = 2.0;
  static const double buttonHeight = 48.0;
  static const double inputHeight = 56.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 60.0;
  static const double mapHeight = 192.0;
}

// Route Names
class AppRoutes {
  static const String login = '/login';
  static const String main = '/main';
  static const String activeReservation = '/active-reservation';
  static const String history = '/history';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String help = '/help';
  static const String createUser = '/create-user';
  static const String changePassword = '/change-password';
  static const String deleteUser = '/delete-user';
  static const String sendPassword = '/send-password';
}

// Animation Durations
class AppAnimations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration toast = Duration(seconds: 2);
  static const Duration success = Duration(milliseconds: 1500);
}
