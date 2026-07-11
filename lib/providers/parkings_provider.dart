import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/parking.dart';

class ParkingsProvider with ChangeNotifier {
  /// Aparcamientos semilla inyectados por el flavor (CityConfig). En fases
  /// posteriores se sustituyen por los servidos por la API.
  final List<Parking> _seedParkings;

  ParkingsProvider({List<Parking> seedParkings = const []})
      : _seedParkings = seedParkings;

  List<Parking> _parkings = [];
  List<String> _favoriteParkings = [];

  List<Parking> get parkings => _parkings;
  List<String> get favoriteParkings => _favoriteParkings;

  // Filter State
  String _searchQuery = '';
  bool _showOnlyAvailable = false;
  bool _showOnlyFavorites = false;
  String _sortBy = 'none';

  String get searchQuery => _searchQuery;
  bool get showOnlyAvailable => _showOnlyAvailable;
  bool get showOnlyFavorites => _showOnlyFavorites;
  String get sortBy => _sortBy;

  // Initialize with the seed parkings from the city flavor and load favorites
  Future<void> initialize() async {
    _parkings = List<Parking>.from(_seedParkings);
    await _loadFavorites();
  }

  // Toggle favorite parking
  Future<void> toggleFavorite(String parkingId) async {
    try {
      if (_favoriteParkings.contains(parkingId)) {
        _favoriteParkings.remove(parkingId);
      } else {
        _favoriteParkings.add(parkingId);
      }
      
      await _saveFavorites();
      notifyListeners();
    } catch (e) {
      debugPrint('Toggle favorite error: $e');
    }
  }

  // Check if parking is favorite
  bool isFavorite(String parkingId) {
    return _favoriteParkings.contains(parkingId);
  }

  // Update parking availability (when making a reservation)
  void updateParkingAvailability(String parkingId, int newAvailableSpots) {
    try {
      final parkingIndex = _parkings.indexWhere((parking) => parking.id == parkingId);
      if (parkingIndex != -1) {
        _parkings[parkingIndex] = _parkings[parkingIndex].copyWith(
          availableSpots: newAvailableSpots,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Update parking availability error: $e');
    }
  }

  // Get parking by ID
  Parking? getParkingById(String parkingId) {
    try {
      return _parkings.firstWhere((parking) => parking.id == parkingId);
    } catch (e) {
      return null;
    }
  }

  // Setters for filters
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilters({
    bool? showOnlyAvailable,
    bool? showOnlyFavorites,
    String? sortBy,
  }) {
    if (showOnlyAvailable != null) _showOnlyAvailable = showOnlyAvailable;
    if (showOnlyFavorites != null) _showOnlyFavorites = showOnlyFavorites;
    if (sortBy != null) _sortBy = sortBy;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _showOnlyAvailable = false;
    _showOnlyFavorites = false;
    _sortBy = 'none';
    notifyListeners();
  }

  // Filter parkings based on stored state
  List<Parking> getFilteredParkings() {
    List<Parking> filtered = List.from(_parkings);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((parking) {
        return parking.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               parking.address.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Apply availability filter
    if (_showOnlyAvailable) {
      filtered = filtered.where((parking) => parking.availableSpots > 0).toList();
    }

    // Apply favorites filter
    if (_showOnlyFavorites) {
      filtered = filtered.where((parking) => _favoriteParkings.contains(parking.id)).toList();
    }

    // Apply sorting
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'availability':
        filtered.sort((a, b) => b.availableSpots.compareTo(a.availableSpots));
        break;
      default:
        // No sorting
        break;
    }

    return filtered;
  }

  // Get active filter count
  int getActiveFilterCount() {
    int count = 0;
    if (_showOnlyAvailable) count++;
    if (_showOnlyFavorites) count++;
    return count;
  }

  // Private methods
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString('bikeParking_favorites');
      
      if (favoritesJson != null) {
        final List<dynamic> favoritesList = jsonDecode(favoritesJson);
        _favoriteParkings = favoritesList.cast<String>();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Load favorites error: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bikeParking_favorites', jsonEncode(_favoriteParkings));
    } catch (e) {
      debugPrint('Save favorites error: $e');
    }
  }
}
