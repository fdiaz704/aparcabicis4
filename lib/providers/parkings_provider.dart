import 'package:flutter/foundation.dart';

import '../models/parking.dart';
import '../repositories/parkings_repository.dart';

/// Aparcamientos, favoritos, filtros y orden.
///
/// No conoce la fuente de datos ni la persistencia: todo pasa por
/// [ParkingsRepository].
class ParkingsProvider with ChangeNotifier {
  ParkingsProvider({required ParkingsRepository parkingsRepository})
      : _parkingsRepository = parkingsRepository;

  final ParkingsRepository _parkingsRepository;

  List<Parking> _parkings = [];
  List<String> _favoriteParkings = [];

  List<Parking> get parkings => _parkings;
  List<String> get favoriteParkings => _favoriteParkings;

  // Estado de filtros
  String _searchQuery = '';
  bool _showOnlyAvailable = false;
  bool _showOnlyFavorites = false;
  String _sortBy = 'none';

  String get searchQuery => _searchQuery;
  bool get showOnlyAvailable => _showOnlyAvailable;
  bool get showOnlyFavorites => _showOnlyFavorites;
  String get sortBy => _sortBy;

  /// Carga aparcamientos y favoritos desde el repositorio.
  Future<void> initialize() async {
    await refresh();
  }

  /// Resincroniza con el repositorio (la ocupación la calcula el backend).
  Future<void> refresh() async {
    try {
      _parkings = await _parkingsRepository.getParkings();
      _favoriteParkings = await _parkingsRepository.getFavoriteIds();
      notifyListeners();
    } catch (e) {
      debugPrint('Refresh parkings error: $e');
    }
  }

  Future<void> toggleFavorite(String parkingId) async {
    try {
      final isNowFavorite = !_favoriteParkings.contains(parkingId);
      await _parkingsRepository.setFavorite(parkingId, favorite: isNowFavorite);
      _favoriteParkings = await _parkingsRepository.getFavoriteIds();
      notifyListeners();
    } catch (e) {
      debugPrint('Toggle favorite error: $e');
    }
  }

  bool isFavorite(String parkingId) => _favoriteParkings.contains(parkingId);

  Parking? getParkingById(String parkingId) {
    for (final parking in _parkings) {
      if (parking.id == parkingId) return parking;
    }
    return null;
  }

  // Filtros
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

  List<Parking> getFilteredParkings() {
    var filtered = List<Parking>.from(_parkings);

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((parking) =>
              parking.name.toLowerCase().contains(query) ||
              parking.address.toLowerCase().contains(query))
          .toList();
    }

    if (_showOnlyAvailable) {
      filtered = filtered.where((parking) => parking.availableSpots > 0).toList();
    }

    if (_showOnlyFavorites) {
      filtered = filtered
          .where((parking) => _favoriteParkings.contains(parking.id))
          .toList();
    }

    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
      case 'availability':
        filtered.sort((a, b) => b.availableSpots.compareTo(a.availableSpots));
      default:
        break;
    }

    return filtered;
  }

  int getActiveFilterCount() {
    var count = 0;
    if (_showOnlyAvailable) count++;
    if (_showOnlyFavorites) count++;
    return count;
  }
}
