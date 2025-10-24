import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/bike_station.dart';
import '../../providers/stations_provider.dart';
import '../../providers/reservations_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/platform_icons.dart';
import '../../services/navigation_service.dart';

class BikeStationsMap extends StatefulWidget {
  const BikeStationsMap({super.key});

  @override
  State<BikeStationsMap> createState() => _BikeStationsMapState();
}

class _BikeStationsMapState extends State<BikeStationsMap> {
  BikeStation? _selectedStation;
  Map<String, double>? _userLocation;

  @override
  Widget build(BuildContext context) {
    return Consumer2<StationsProvider, ReservationsProvider>(
      builder: (context, stationsProvider, reservationsProvider, child) {
        return Stack(
          children: [
            // Map Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.mapGradient,
                ),
              ),
              child: CustomPaint(
                painter: _GridPainter(),
                child: Stack(
                  children: [
                    // User Location
                    if (_userLocation != null)
                      Positioned(
                        left: _userLocation!['x']! - 8,
                        top: _userLocation!['y']! - 8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.info,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.info.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            PlatformIcons.locationFill,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    
                    // Station Markers
                    ...stationsProvider.stations.asMap().entries.map((entry) {
                      final index = entry.key;
                      final station = entry.value;
                      return _buildStationMarker(
                        station,
                        index,
                        reservationsProvider,
                        stationsProvider,
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
            
            // Geolocation Button
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: FloatingActionButton.small(
                onPressed: _toggleUserLocation,
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                child: Icon(
                  _userLocation != null ? PlatformIcons.location : PlatformIcons.location,
                ),
              ),
            ),
            
            // Selected Station Card
            if (_selectedStation != null)
              Positioned(
                bottom: AppSpacing.md,
                left: AppSpacing.md,
                right: AppSpacing.md,
                child: _buildSelectedStationCard(
                  _selectedStation!,
                  stationsProvider,
                  reservationsProvider,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildStationMarker(
    BikeStation station,
    int index,
    ReservationsProvider reservationsProvider,
    StationsProvider stationsProvider,
  ) {
    // Calculate position based on index (grid distribution)
    final double left = 20 + (index % 5) * 60.0;
    final double top = 60 + (index ~/ 5) * 80.0;
    
    final hasAvailableSpots = station.availableSpots > 0;
    final isActiveReservation = reservationsProvider.activeReservation?.id == station.id;
    final isSelected = _selectedStation?.id == station.id;

    Color markerColor;
    if (isActiveReservation) {
      markerColor = AppColors.reserved;
    } else if (hasAvailableSpots) {
      markerColor = AppColors.available;
    } else {
      markerColor = AppColors.unavailable;
    }

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () => _selectStation(station),
        child: AnimatedContainer(
          duration: AppAnimations.medium,
          width: isSelected ? 44 : 36,
          height: isSelected ? 44 : 36,
          decoration: BoxDecoration(
            color: markerColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: isSelected ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: markerColor.withOpacity(0.3),
                blurRadius: isSelected ? 12 : 8,
                spreadRadius: isSelected ? 3 : 1,
              ),
            ],
          ),
          child: Icon(
            PlatformIcons.locationFill,
            color: Colors.white,
            size: isSelected ? 24 : 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedStationCard(
    BikeStation station,
    StationsProvider stationsProvider,
    ReservationsProvider reservationsProvider,
  ) {
    final isFavorite = stationsProvider.isFavorite(station.id);
    final hasAvailableSpots = station.availableSpots > 0;
    final canReserve = hasAvailableSpots && !reservationsProvider.hasActiveReservation;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    station.name,
                    style: AppTextStyles.heading3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => _toggleFavorite(stationsProvider, station),
                  icon: Icon(
                    isFavorite ? PlatformIcons.star : PlatformIcons.starBorder,
                    color: isFavorite ? AppColors.favorite : Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: () => _closeSelectedStation(),
                  icon: Icon(PlatformIcons.close),
                ),
              ],
            ),
            
            // Address
            Row(
              children: [
                Icon(PlatformIcons.location, size: 16, color: Colors.grey),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    station.address,
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Availability and Actions
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: hasAvailableSpots ? AppColors.available : AppColors.unavailable,
                    borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                  ),
                  child: Text(
                    '${station.availableSpots} de ${station.totalSpots} disponibles',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                // Reserve Button
                ElevatedButton(
                  onPressed: canReserve ? () => _handleReserve(station, stationsProvider, reservationsProvider) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canReserve ? AppColors.primary : Colors.grey,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(80, 32),
                  ),
                  child: Text(
                    canReserve ? 'Reservar' : 'No disponible',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _selectStation(BikeStation station) {
    setState(() {
      _selectedStation = station;
    });
  }

  void _closeSelectedStation() {
    setState(() {
      _selectedStation = null;
    });
  }

  void _toggleUserLocation() {
    setState(() {
      if (_userLocation == null) {
        // Simulate user location in center of map
        _userLocation = {
          'x': MediaQuery.of(context).size.width / 2,
          'y': MediaQuery.of(context).size.height / 2,
        };
        AppHelpers.showInfoSnackBar(context, 'Ubicación activada');
      } else {
        _userLocation = null;
        AppHelpers.showInfoSnackBar(context, 'Ubicación desactivada');
      }
    });
  }

  void _toggleFavorite(StationsProvider stationsProvider, BikeStation station) {
    stationsProvider.toggleFavorite(station.id);
    
    final isFavorite = stationsProvider.isFavorite(station.id);
    final message = isFavorite 
        ? '${station.name} añadido a favoritos'
        : '${station.name} eliminado de favoritos';
    
    AppHelpers.showInfoSnackBar(context, message);
  }

  Future<void> _handleReserve(
    BikeStation station,
    StationsProvider stationsProvider,
    ReservationsProvider reservationsProvider,
  ) async {
    if (station.availableSpots <= 0) {
      AppHelpers.showErrorSnackBar(context, 'No hay plazas disponibles en esta estación');
      return;
    }

    if (reservationsProvider.hasActiveReservation) {
      AppHelpers.showErrorSnackBar(context, 'Ya tienes una reserva activa');
      return;
    }

    // Reservar directamente sin modal de confirmación

    try {
      // Update station availability
      stationsProvider.updateStationAvailability(station.id, station.availableSpots - 1);

      // Create reservation
      final success = await reservationsProvider.createReservation(station);

      if (success) {
        AppHelpers.showSuccessSnackBar(
          context, 
          'Reserva creada exitosamente en ${station.name}',
        );
        
        // Close selected station card
        _closeSelectedStation();
        
        // Navigate to active reservation screen
        NavigationService.pushNamedAndClearStack(AppRoutes.activeReservation);
      } else {
        // Restore station availability if reservation failed
        stationsProvider.updateStationAvailability(station.id, station.availableSpots + 1);
        AppHelpers.showErrorSnackBar(context, 'Error al crear la reserva');
      }
    } catch (e) {
      // Restore station availability on error
      stationsProvider.updateStationAvailability(station.id, station.availableSpots + 1);
      AppHelpers.showErrorSnackBar(context, 'Error al crear la reserva');
    }
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    const gridSize = 20.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
