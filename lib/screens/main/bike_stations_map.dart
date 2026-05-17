import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../models/bike_station.dart';
import '../../providers/stations_provider.dart';
import '../../providers/reservations_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../services/navigation_service.dart';

class BikeStationsMap extends StatefulWidget {
  const BikeStationsMap({super.key});

  @override
  State<BikeStationsMap> createState() => _BikeStationsMapState();
}

class _BikeStationsMapState extends State<BikeStationsMap> {
  BikeStation? _selectedStation;
  GoogleMapController? _mapController;
  
  // Madrid center (Puerta del Sol)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(40.4168, -3.7038),
    zoom: 13,
  );

  @override
  Widget build(BuildContext context) {
    return Consumer2<StationsProvider, ReservationsProvider>(
      builder: (context, stationsProvider, reservationsProvider, child) {
        return Stack(
          children: [
            // Google Map
            // Google Map
            GoogleMap(
              initialCameraPosition: _initialPosition,
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: false, // Custom button used below
              zoomControlsEnabled: false, // We use custom buttons
              zoomGesturesEnabled: true,
              scrollGesturesEnabled: false,
              mapToolbarEnabled: false,
              gestureRecognizers: {
                Factory<OneSequenceGestureRecognizer>(
                  () => ScaleGestureRecognizer(),
                ),
              },
              markers: _createMarkers(stationsProvider, reservationsProvider),
              onTap: (_) => _closeSelectedStation(),
            ),
            
            // Geolocation Button
            Positioned(
              top: AppSpacing.md,
              right: AppSpacing.md,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'location_btn',
                    onPressed: _moveToUserLocation,
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    child: const Icon(LucideIcons.navigation),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FloatingActionButton.small(
                    heroTag: 'zoom_in_btn',
                    onPressed: _zoomIn,
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FloatingActionButton.small(
                    heroTag: 'zoom_out_btn',
                    onPressed: _zoomOut,
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    child: const Icon(Icons.remove),
                  ),
                ],
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

  Set<Marker> _createMarkers(
    StationsProvider stationsProvider,
    ReservationsProvider reservationsProvider,
  ) {
    return stationsProvider.stations.map((station) {
      final hasAvailableSpots = station.availableSpots > 0;
      final isActiveReservation = reservationsProvider.activeReservation?.id == station.id;
      
      // Determine marker hue based on status
      double markerHue;
      if (isActiveReservation) {
        markerHue = BitmapDescriptor.hueBlue; // Reserved
      } else if (hasAvailableSpots) {
        markerHue = BitmapDescriptor.hueGreen; // Available
      } else {
        markerHue = BitmapDescriptor.hueRed; // Unavailable
      }

      return Marker(
        markerId: MarkerId(station.id),
        position: LatLng(station.lat, station.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
        infoWindow: InfoWindow(
          title: station.name,
          snippet: '${station.availableSpots} plazas libres',
        ),
        onTap: () => _selectStation(station),
      );
    }).toSet();
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
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite ? AppColors.favorite : Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: () => _closeSelectedStation(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            // Address
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
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
    
    // Animate camera to selected station
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(station.lat, station.lng)),
    );
  }

  void _closeSelectedStation() {
    setState(() {
      _selectedStation = null;
    });
  }

  Future<void> _moveToUserLocation() async {
    // In a real app, we would get the user's location here.
    // For now, we'll just center back on Madrid or show a message
    // since we enabled myLocationEnabled in the map widget which handles the blue dot.
    // But to move the camera we need the location.
    
    // Since we don't have the geolocator logic fully implemented in this file 
    // (it was just a toggle before), we will reset to initial position for now
    // or rely on the map's built-in button if we enabled it.
    // But we disabled the built-in button to use our custom one.
    
    // Let's just reset to Madrid center for this demo if we can't get location easily
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(_initialPosition),
    );
    
    AppHelpers.showInfoSnackBar(context, 'Centrando en Madrid');
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

  Future<void> _zoomIn() async {
    final currentZoom = await _mapController?.getZoomLevel();
    if (currentZoom != null) {
      _mapController?.animateCamera(CameraUpdate.zoomTo(currentZoom + 1));
    }
  }

  Future<void> _zoomOut() async {
    final currentZoom = await _mapController?.getZoomLevel();
    if (currentZoom != null) {
      _mapController?.animateCamera(CameraUpdate.zoomTo(currentZoom - 1));
    }
  }
}
