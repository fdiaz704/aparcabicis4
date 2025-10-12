import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/bike_station.dart';

class StationsProvider with ChangeNotifier {
  List<BikeStation> _stations = [];
  List<String> _favoriteStations = [];

  List<BikeStation> get stations => _stations;
  List<String> get favoriteStations => _favoriteStations;

  // Initialize with mock data and load favorites
  Future<void> initialize() async {
    _loadMockStations();
    await _loadFavorites();
  }

  // Toggle favorite station
  Future<void> toggleFavorite(String stationId) async {
    try {
      if (_favoriteStations.contains(stationId)) {
        _favoriteStations.remove(stationId);
      } else {
        _favoriteStations.add(stationId);
      }
      
      await _saveFavorites();
      notifyListeners();
    } catch (e) {
      debugPrint('Toggle favorite error: $e');
    }
  }

  // Check if station is favorite
  bool isFavorite(String stationId) {
    return _favoriteStations.contains(stationId);
  }

  // Update station availability (when making a reservation)
  void updateStationAvailability(String stationId, int newAvailableSpots) {
    try {
      final stationIndex = _stations.indexWhere((station) => station.id == stationId);
      if (stationIndex != -1) {
        _stations[stationIndex] = _stations[stationIndex].copyWith(
          availableSpots: newAvailableSpots,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Update station availability error: $e');
    }
  }

  // Get station by ID
  BikeStation? getStationById(String stationId) {
    try {
      return _stations.firstWhere((station) => station.id == stationId);
    } catch (e) {
      return null;
    }
  }

  // Filter stations based on search criteria
  List<BikeStation> getFilteredStations({
    String? searchQuery,
    bool showOnlyAvailable = false,
    bool showOnlyFavorites = false,
    String sortBy = 'none', // 'none', 'name', 'availability'
  }) {
    List<BikeStation> filtered = List.from(_stations);

    // Apply search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filtered = filtered.where((station) {
        return station.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
               station.address.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }

    // Apply availability filter
    if (showOnlyAvailable) {
      filtered = filtered.where((station) => station.availableSpots > 0).toList();
    }

    // Apply favorites filter
    if (showOnlyFavorites) {
      filtered = filtered.where((station) => _favoriteStations.contains(station.id)).toList();
    }

    // Apply sorting
    switch (sortBy) {
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
  int getActiveFilterCount(bool showOnlyAvailable, bool showOnlyFavorites) {
    int count = 0;
    if (showOnlyAvailable) count++;
    if (showOnlyFavorites) count++;
    return count;
  }

  // Private methods
  void _loadMockStations() {
    _stations = [
      BikeStation(
        id: '1',
        name: 'Plaza Mayor',
        address: 'Calle Mayor, 1',
        availableSpots: 3,
        totalSpots: 10,
        lat: 40.4155,
        lng: -3.7074,
      ),
      BikeStation(
        id: '2',
        name: 'Estación Atocha',
        address: 'Plaza del Emperador Carlos V',
        availableSpots: 5,
        totalSpots: 15,
        lat: 40.4064,
        lng: -3.6910,
      ),
      BikeStation(
        id: '3',
        name: 'Retiro Park',
        address: 'Paseo del Prado, 8',
        availableSpots: 0,
        totalSpots: 8,
        lat: 40.4152,
        lng: -3.6844,
      ),
      BikeStation(
        id: '4',
        name: 'Gran Vía Centro',
        address: 'Gran Vía, 32',
        availableSpots: 2,
        totalSpots: 12,
        lat: 40.4200,
        lng: -3.7038,
      ),
      BikeStation(
        id: '5',
        name: 'Malasaña',
        address: 'Calle Fuencarral, 45',
        availableSpots: 7,
        totalSpots: 10,
        lat: 40.4267,
        lng: -3.7038,
      ),
      BikeStation(
        id: '6',
        name: 'Chueca',
        address: 'Plaza de Chueca, 3',
        availableSpots: 1,
        totalSpots: 6,
        lat: 40.4239,
        lng: -3.6968,
      ),
      BikeStation(
        id: '7',
        name: 'Sol',
        address: 'Puerta del Sol, 1',
        availableSpots: 4,
        totalSpots: 20,
        lat: 40.4168,
        lng: -3.7038,
      ),
      BikeStation(
        id: '8',
        name: 'Tribunal',
        address: 'Calle Tribunal, 15',
        availableSpots: 6,
        totalSpots: 10,
        lat: 40.4267,
        lng: -3.7008,
      ),
    ];
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString('bikeParking_favorites');
      
      if (favoritesJson != null) {
        final List<dynamic> favoritesList = jsonDecode(favoritesJson);
        _favoriteStations = favoritesList.cast<String>();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Load favorites error: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('bikeParking_favorites', jsonEncode(_favoriteStations));
    } catch (e) {
      debugPrint('Save favorites error: $e');
    }
  }
}
