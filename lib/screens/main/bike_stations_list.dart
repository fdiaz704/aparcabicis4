import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../providers/stations_provider.dart';
import '../../providers/reservations_provider.dart';
import '../../models/bike_station.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/platform_widgets.dart';
import '../../services/navigation_service.dart';
import '../../widgets/bike_station_card.dart';

class BikeStationsList extends StatefulWidget {
  const BikeStationsList({super.key});

  @override
  State<BikeStationsList> createState() => _BikeStationsListState();
}

class _BikeStationsListState extends State<BikeStationsList> {
  final _searchController = TextEditingController();
  bool _showOnlyAvailable = false;
  bool _showOnlyFavorites = false;
  String _sortBy = 'none'; // 'none', 'name', 'availability'
  bool _isFilterOpen = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<StationsProvider, ReservationsProvider>(
      builder: (context, stationsProvider, reservationsProvider, child) {
        final filteredStations = stationsProvider.getFilteredStations(
          searchQuery: _searchController.text,
          showOnlyAvailable: _showOnlyAvailable,
          showOnlyFavorites: _showOnlyFavorites,
          sortBy: _sortBy,
        );

        final activeFilterCount = stationsProvider.getActiveFilterCount(
          _showOnlyAvailable,
          _showOnlyFavorites,
        );

        return Column(
          children: [
            // Search and Filter Bar
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: Colors.white,
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar estaciones...',
                      prefixIcon: const Icon(LucideIcons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                });
                              },
                              icon: const Icon(Icons.clear),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  
                  const SizedBox(height: AppSpacing.sm),
                  
                  // Filter Button
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showFilterSheet(context),
                          icon: Stack(
                            children: [
                              const Icon(Icons.tune),
                              if (activeFilterCount > 0)
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      activeFilterCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          label: Text(
                            activeFilterCount > 0 
                                ? 'Filtros ($activeFilterCount)'
                                : 'Filtros',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Results Info
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              color: Colors.grey[50],
              child: Row(
                children: [
                  Text(
                    '${filteredStations.length} estación${filteredStations.length != 1 ? 'es' : ''} encontrada${filteredStations.length != 1 ? 's' : ''}',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
                  ),
                  if (reservationsProvider.hasActiveReservation) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.info,
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                      ),
                      child: const Text(
                        'Reserva activa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Stations List
            Expanded(
              child: filteredStations.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: filteredStations.length,
                      itemBuilder: (context, index) {
                        final station = filteredStations[index];
                        return BikeStationCard(
                          station: station,
                          onReserve: () {
                            // Refresh the list after reservation
                            setState(() {});
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.search,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No se encontraron estaciones',
              style: AppTextStyles.heading3.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Intenta ajustar los filtros de búsqueda',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton(
              onPressed: _clearAllFilters,
              child: const Text('Limpiar filtros'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildFilterDialog(),
    );
  }

  Widget _buildFilterDialog() {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
              minWidth: 300,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              // Header
              Row(
                children: [
                  const Text(
                    'Filtros',
                    style: AppTextStyles.heading2,
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () {
                      setDialogState(() {
                        _showOnlyAvailable = false;
                        _showOnlyFavorites = false;
                        _sortBy = 'none';
                      });
                      setState(() {});
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Limpiar todo',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Scrollable content
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Available Filter
                      PlatformWidgets.buildAdaptiveSwitch(
                        title: 'Solo disponibles',
                        subtitle: 'Mostrar solo estaciones con plazas libres',
                        value: _showOnlyAvailable,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setDialogState(() {
                            _showOnlyAvailable = value;
                          });
                          setState(() {});
                        },
                      ),
                      
                      // Favorites Filter
                      PlatformWidgets.buildAdaptiveSwitch(
                        title: 'Solo favoritos',
                        subtitle: 'Mostrar solo estaciones marcadas como favoritas',
                        value: _showOnlyFavorites,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setDialogState(() {
                            _showOnlyFavorites = value;
                          });
                          setState(() {});
                        },
                      ),
                      
                      const SizedBox(height: AppSpacing.md),
                      
                      // Sort Options
                      const Text(
                        'Ordenar por',
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      
                      RadioListTile<String>(
                        title: const Text('Sin ordenar'),
                        value: 'none',
                        groupValue: _sortBy,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setDialogState(() {
                            _sortBy = value!;
                          });
                          setState(() {});
                        },
                      ),
                      
                      RadioListTile<String>(
                        title: const Text('Nombre (A-Z)'),
                        value: 'name',
                        groupValue: _sortBy,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setDialogState(() {
                            _sortBy = value!;
                          });
                          setState(() {});
                        },
                      ),
                      
                      RadioListTile<String>(
                        title: const Text('Disponibilidad (más a menos)'),
                        value: 'availability',
                        groupValue: _sortBy,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setDialogState(() {
                            _sortBy = value!;
                          });
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.lg),
              
              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Aplicar filtros'),
                ),
              ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _showOnlyAvailable = false;
      _showOnlyFavorites = false;
      _sortBy = 'none';
    });
  }
}
