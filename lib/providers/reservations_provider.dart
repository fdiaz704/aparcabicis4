import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../models/bike_station.dart';
import '../models/reservation_record.dart';
import '../utils/constants.dart';

enum ReservationState { reserved, inUse }

class ReservationsProvider with ChangeNotifier {
  BikeStation? _activeReservation;
  DateTime? _reservationStartTime;
  ReservationState _reservationState = ReservationState.reserved;
  List<ReservationRecord> _reservationHistory = [];
  
  // Timer variables
  Timer? _reservationTimer;
  int _reservationTimeLeft = AppConstants.reservationTimeoutSeconds; // 30 minutes in seconds
  int _usageTime = 0; // Usage time in seconds
  
  // Getters
  BikeStation? get activeReservation => _activeReservation;
  DateTime? get reservationStartTime => _reservationStartTime;
  ReservationState get reservationState => _reservationState;
  List<ReservationRecord> get reservationHistory => _reservationHistory;
  int get reservationTimeLeft => _reservationTimeLeft;
  int get usageTime => _usageTime;
  bool get hasActiveReservation => _activeReservation != null;

  // Initialize and load history
  Future<void> initialize() async {
    await _loadReservationHistory();
  }

  // Create a new reservation
  Future<bool> createReservation(BikeStation station) async {
    try {
      if (station.availableSpots <= 0) {
        return false;
      }

      if (_activeReservation != null) {
        return false; // Already has an active reservation
      }

      _activeReservation = station;
      _reservationStartTime = DateTime.now();
      _reservationState = ReservationState.reserved;
      _reservationTimeLeft = AppConstants.reservationTimeoutSeconds; // 30 minutes
      _usageTime = 0;

      _startReservationTimer();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Create reservation error: $e');
      return false;
    }
  }

  // Cancel active reservation
  Future<void> cancelReservation() async {
    try {
      if (_activeReservation == null || _reservationStartTime == null) {
        return;
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(_reservationStartTime!).inMinutes;
      
      // Create reservation record
      final record = ReservationRecord(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        stationName: _activeReservation!.name,
        stationAddress: _activeReservation!.address,
        startTime: _reservationStartTime!,
        endTime: endTime,
        duration: duration,
        status: duration > 0 ? ReservationStatus.completed : ReservationStatus.cancelled,
      );

      // Add to history (at the beginning)
      _reservationHistory.insert(0, record);
      await _saveReservationHistory();

      // Clear active reservation
      _clearActiveReservation();
      notifyListeners();
    } catch (e) {
      debugPrint('Cancel reservation error: $e');
    }
  }

  // Open door (transition from reserved to in-use if first time)
  void openDoor() {
    try {
      if (_activeReservation == null) return;

      if (_reservationState == ReservationState.reserved) {
        // First time opening door - transition to in-use
        _reservationState = ReservationState.inUse;
        _stopReservationTimer();
        _startUsageTimer();
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Open door error: $e');
    }
  }

  // Finish usage
  Future<void> finishUsage() async {
    await cancelReservation(); // Same logic as cancel
  }

  // Get reservation statistics for history
  Map<String, dynamic> getReservationStatistics() {
    final total = _reservationHistory.length;
    final completed = _reservationHistory.where((r) => r.status == ReservationStatus.completed).length;
    
    final completedReservations = _reservationHistory.where((r) => r.status == ReservationStatus.completed);
    final totalMinutes = completedReservations.fold<int>(0, (sum, r) => sum + r.duration);
    final averageDuration = completedReservations.isNotEmpty ? (totalMinutes / completedReservations.length).round() : 0;

    return {
      'total': total,
      'completed': completed,
      'averageDuration': averageDuration,
    };
  }

  // Get user profile statistics
  Map<String, dynamic> getUserStatistics() {
    final total = _reservationHistory.length;
    
    final completedReservations = _reservationHistory.where((r) => r.status == ReservationStatus.completed);
    final totalMinutes = completedReservations.fold<int>(0, (sum, r) => sum + r.duration);
    
    // Find most frequent station
    final stationFrequency = <String, int>{};
    for (final reservation in _reservationHistory) {
      stationFrequency[reservation.stationName] = (stationFrequency[reservation.stationName] ?? 0) + 1;
    }
    
    String favoriteStation = 'Ninguna aún';
    if (stationFrequency.isNotEmpty) {
      favoriteStation = stationFrequency.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }

    return {
      'totalReservations': total,
      'totalTimeMinutes': totalMinutes,
      'favoriteStation': favoriteStation,
    };
  }

  // Format time helper
  String formatTime(int seconds) {
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
  String formatDurationMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0) {
      return '${hours}h ${mins}m';
    } else {
      return '${mins}m';
    }
  }

  // Private methods
  void _startReservationTimer() {
    _reservationTimer?.cancel();
    _reservationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_reservationTimeLeft > 0) {
        _reservationTimeLeft--;
        notifyListeners();
        
        // Warning at 5 minutes remaining
        if (_reservationTimeLeft == AppConstants.warningTimeSeconds) {
          // TODO: Show warning notification
          debugPrint('Warning: 5 minutes remaining');
        }
      } else {
        // Time expired - cancel reservation automatically
        timer.cancel();
        cancelReservation();
      }
    });
  }

  void _startUsageTimer() {
    _reservationTimer?.cancel();
    _reservationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_usageTime < AppConstants.maxUsageTimeSeconds) { // 14 hours maximum
        _usageTime++;
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  void _stopReservationTimer() {
    _reservationTimer?.cancel();
  }

  void _clearActiveReservation() {
    _activeReservation = null;
    _reservationStartTime = null;
    _reservationState = ReservationState.reserved;
    _reservationTimeLeft = AppConstants.reservationTimeoutSeconds;
    _usageTime = 0;
    _stopReservationTimer();
  }

  Future<void> _loadReservationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('bikeParking_history');
      
      if (historyJson != null) {
        final List<dynamic> historyList = jsonDecode(historyJson);
        _reservationHistory = historyList.map((json) => ReservationRecord.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Load reservation history error: $e');
    }
  }

  Future<void> _saveReservationHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(_reservationHistory.map((r) => r.toJson()).toList());
      await prefs.setString('bikeParking_history', historyJson);
    } catch (e) {
      debugPrint('Save reservation history error: $e');
    }
  }

  // Get statistics from reservation history
  Map<String, dynamic> getStatistics() {
    final totalReservations = _reservationHistory.length;
    final completedReservations = _reservationHistory.where((r) => r.status == ReservationStatus.completed).length;
    final cancelledReservations = _reservationHistory.where((r) => r.status == ReservationStatus.cancelled).length;
    final expiredReservations = _reservationHistory.where((r) => r.status == ReservationStatus.expired).length;
    
    final totalUsageTime = _reservationHistory
        .where((r) => r.endTime != null)
        .fold<int>(0, (sum, r) => sum + r.endTime!.difference(r.startTime).inSeconds);
    
    final averageUsageTime = completedReservations > 0 
        ? totalUsageTime ~/ completedReservations 
        : 0;
    
    final completionRate = totalReservations > 0 
        ? ((completedReservations / totalReservations) * 100).round()
        : 0;
    
    final cancellationRate = totalReservations > 0 
        ? ((cancelledReservations / totalReservations) * 100).round()
        : 0;
    
    // Calculate savings (assuming €2 per hour saved vs public transport)
    final totalSavings = (totalUsageTime / 3600) * 2.0;
    
    // Find best month (simplified - just return current count)
    final bestMonth = totalReservations;
    
    return {
      'totalReservations': totalReservations,
      'completedReservations': completedReservations,
      'cancelledReservations': cancelledReservations,
      'expiredReservations': expiredReservations,
      'totalUsageTime': totalUsageTime,
      'averageUsageTime': averageUsageTime,
      'completionRate': completionRate,
      'cancellationRate': cancellationRate,
      'totalSavings': totalSavings,
      'bestMonth': bestMonth,
    };
  }

  @override
  void dispose() {
    _stopReservationTimer();
    super.dispose();
  }
}
