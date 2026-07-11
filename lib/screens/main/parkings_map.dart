import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'package:aparcabicis4/l10n/l10n.dart';
import '../../config/city_config.dart';
import '../../models/parking.dart';
import '../../providers/parkings_provider.dart';
import '../../providers/reservations_provider.dart';
import '../../repositories/repository_exception.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../services/navigation_service.dart';

class ParkingsMap extends StatefulWidget {
  const ParkingsMap({super.key});

  @override
  State<ParkingsMap> createState() => _ParkingsMapState();
}

class _ParkingsMapState extends State<ParkingsMap> {
  Parking? _selectedParking;
  GoogleMapController? _mapController;

  // Posición inicial y nombre de la ciudad, derivados del flavor (CityConfig).
  late CameraPosition _initialPosition;
  late String _cityName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final city = context.read<CityConfig>();
    _initialPosition = CameraPosition(
      target: LatLng(city.mapCenterLat, city.mapCenterLng),
      zoom: city.mapZoom,
    );
    _cityName = city.name;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ParkingsProvider, ReservationsProvider>(
      builder: (context, parkingsProvider, reservationsProvider, child) {
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
              scrollGesturesEnabled: false,
              mapToolbarEnabled: false,
              gestureRecognizers: {
                Factory<OneSequenceGestureRecognizer>(
                  () => ScaleGestureRecognizer(),
                ),
              },
              markers: _createMarkers(parkingsProvider, reservationsProvider),
              onTap: (_) => _closeSelectedParking(),
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
            
            // Selected Parking Card
            if (_selectedParking != null)
              Positioned(
                bottom: AppSpacing.md,
                left: AppSpacing.md,
                right: AppSpacing.md,
                child: _buildSelectedParkingCard(
                  _selectedParking!,
                  parkingsProvider,
                  reservationsProvider,
                ),
              ),
          ],
        );
      },
    );
  }

  Set<Marker> _createMarkers(
    ParkingsProvider parkingsProvider,
    ReservationsProvider reservationsProvider,
  ) {
    return parkingsProvider.parkings.map((parking) {
      final hasAvailableSpots = parking.availableSpots > 0;
      final isActiveReservation = reservationsProvider.activeReservation?.id == parking.id;

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
        markerId: MarkerId(parking.id),
        position: LatLng(parking.lat, parking.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
        infoWindow: InfoWindow(
          title: parking.name,
          snippet: context.l10n.mapFreeSpots(parking.availableSpots),
        ),
        onTap: () => _selectParking(parking),
      );
    }).toSet();
  }

  Widget _buildSelectedParkingCard(
    Parking parking,
    ParkingsProvider parkingsProvider,
    ReservationsProvider reservationsProvider,
  ) {
    final isFavorite = parkingsProvider.isFavorite(parking.id);
    final hasAvailableSpots = parking.availableSpots > 0;
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
                    parking.name,
                    style: AppTextStyles.heading3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => _toggleFavorite(parkingsProvider, parking),
                  icon: Icon(
                    isFavorite ? Icons.star : Icons.star_border,
                    color: isFavorite ? AppColors.favorite : Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: () => _closeSelectedParking(),
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
                    parking.address,
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
                    context.l10n.mapSpotsAvailable(parking.availableSpots, parking.totalSpots),
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
                  onPressed: canReserve ? () => _handleReserve(parking, parkingsProvider, reservationsProvider) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canReserve ? AppColors.primary : Colors.grey,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(80, 32),
                  ),
                  child: Text(
                    canReserve ? context.l10n.mapReserve : context.l10n.mapNotAvailable,
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

  void _selectParking(Parking parking) {
    setState(() {
      _selectedParking = parking;
    });

    // Animate camera to selected parking
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(parking.lat, parking.lng)),
    );
  }

  void _closeSelectedParking() {
    setState(() {
      _selectedParking = null;
    });
  }

  Future<void> _moveToUserLocation() async {
    // La geolocalización real (geolocator + permisos) se implementa en la
    // fase 2. Por ahora recentramos en el centro de la ciudad del flavor.
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(_initialPosition),
    );

    AppHelpers.showInfoSnackBar(context, context.l10n.mapCenteringOn(_cityName));
  }

  void _toggleFavorite(ParkingsProvider parkingsProvider, Parking parking) {
    parkingsProvider.toggleFavorite(parking.id);
    
    final isFavorite = parkingsProvider.isFavorite(parking.id);
    final message = isFavorite
        ? context.l10n.mapAddedToFavorites(parking.name)
        : context.l10n.mapRemovedFromFavorites(parking.name);

    AppHelpers.showInfoSnackBar(context, message);
  }

  Future<void> _handleReserve(
    Parking parking,
    ParkingsProvider parkingsProvider,
    ReservationsProvider reservationsProvider,
  ) async {
    if (parking.availableSpots <= 0) {
      AppHelpers.showErrorSnackBar(context, context.l10n.mapNoSpotsAvailable);
      return;
    }

    if (reservationsProvider.hasActiveReservation) {
      AppHelpers.showErrorSnackBar(context, context.l10n.mapAlreadyActiveReservation);
      return;
    }

    // La ocupación de plazas la calcula el backend: solo resincronizamos.
    final errorCode = await reservationsProvider.createReservation(parking);
    await parkingsProvider.refresh();

    if (!mounted) return;

    if (errorCode == null) {
      AppHelpers.showSuccessSnackBar(
        context,
        context.l10n.mapReservationCreated(parking.name),
      );
      _closeSelectedParking();
      NavigationService.pushNamedAndClearStack(AppRoutes.activeReservation);
    } else {
      AppHelpers.showErrorSnackBar(context, _reserveErrorMessage(errorCode));
    }
  }

  /// Traduce el código de error del contrato al mensaje de UI.
  String _reserveErrorMessage(String code) {
    return switch (code) {
      RepositoryErrorCodes.parkingFull => context.l10n.mapNoSpotsAvailable,
      RepositoryErrorCodes.reservationConflict =>
        context.l10n.mapAlreadyActiveReservation,
      _ => context.l10n.mapReservationError,
    };
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
