import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../providers/parkings_provider.dart';
import '../../providers/reservations_provider.dart';
import '../../utils/constants.dart';
import '../../utils/platform_widgets.dart';
import '../../widgets/parking_card.dart';

class ParkingsList extends StatefulWidget {
  const ParkingsList({super.key});

  @override
  State<ParkingsList> createState() => _ParkingsListState();
}

class _ParkingsListState extends State<ParkingsList> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize search controller with stored query
    final parkingsProvider = Provider.of<ParkingsProvider>(context, listen: false);
    _searchController.text = parkingsProvider.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ParkingsProvider, ReservationsProvider>(
      builder: (context, parkingsProvider, reservationsProvider, child) {

        final filteredParkings = parkingsProvider.getFilteredParkings();
        final activeFilterCount = parkingsProvider.getActiveFilterCount();

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
                      hintText: 'Buscar aparcamientos...',
                      prefixIcon: const Icon(LucideIcons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  parkingsProvider.setSearchQuery('');
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
                      parkingsProvider.setSearchQuery(value);
                    },
                  ),
                  
                  const SizedBox(height: AppSpacing.sm),
                  
                  // Filter Button
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showFilterSheet(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                            ),
                          ),
                          icon: Stack(
                            children: [
                              const Icon(Icons.tune, color: Colors.white),
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
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
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
                    '${filteredParkings.length} aparcamiento${filteredParkings.length != 1 ? 'es' : ''} encontrada${filteredParkings.length != 1 ? 's' : ''}',
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
            
            // Parkings List
            Expanded(
              child: filteredParkings.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: filteredParkings.length,
                      itemBuilder: (context, index) {
                        final parking = filteredParkings[index];
                        return ParkingCard(
                          parking: parking,
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
              'No se encontraron aparcamientos',
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
    return Consumer<ParkingsProvider>(
      builder: (context, parkingsProvider, child) {
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
                          parkingsProvider.resetFilters();
                          // Update local search controller if needed, though resetFilters clears query too
                          _searchController.clear();
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
                            subtitle: 'Mostrar solo aparcamientos con plazas libres',
                            value: parkingsProvider.showOnlyAvailable,
                            activeColor: AppColors.primary,
                            onChanged: (value) {
                              parkingsProvider.setFilters(showOnlyAvailable: value);
                            },
                          ),

                          // Favorites Filter
                          PlatformWidgets.buildAdaptiveSwitch(
                            title: 'Solo favoritos',
                            subtitle: 'Mostrar solo aparcamientos marcadas como favoritas',
                            value: parkingsProvider.showOnlyFavorites,
                            activeColor: AppColors.primary,
                            onChanged: (value) {
                              parkingsProvider.setFilters(showOnlyFavorites: value);
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
                            groupValue: parkingsProvider.sortBy,
                            activeColor: AppColors.primary,
                            onChanged: (value) {
                              parkingsProvider.setFilters(sortBy: value);
                            },
                          ),

                          RadioListTile<String>(
                            title: const Text('Nombre (A-Z)'),
                            value: 'name',
                            groupValue: parkingsProvider.sortBy,
                            activeColor: AppColors.primary,
                            onChanged: (value) {
                              parkingsProvider.setFilters(sortBy: value);
                            },
                          ),

                          RadioListTile<String>(
                            title: const Text('Disponibilidad (más a menos)'),
                            value: 'availability',
                            groupValue: parkingsProvider.sortBy,
                            activeColor: AppColors.primary,
                            onChanged: (value) {
                              parkingsProvider.setFilters(sortBy: value);
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
    _searchController.clear();
    context.read<ParkingsProvider>().resetFilters();
  }
}
