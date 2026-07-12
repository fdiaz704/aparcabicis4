import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'package:aparcabicis4/l10n/l10n.dart';
import '../../config/city_config.dart';
import '../../config/route_config.dart';
import '../../providers/session_provider.dart';
import '../../services/location_service.dart';
import '../../services/route_service.dart';
import '../../utils/parking_marker_factory.dart';
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

  // Posición inicial del mapa, derivada del flavor (CityConfig).
  late CameraPosition _initialPosition;

  /// Markers propios (assets/parking.svg) coloreados por disponibilidad (RF-2.2).
  final ParkingMarkerFactory _markers = ParkingMarkerFactory();

  final LocationService _location = GeolocatorLocationService();
  bool _locating = false;

  /// Ruta hasta el aparcamiento seleccionado (RF-2.6).
  final RouteService _routes = resolveRouteService();
  RouteInfo? _route;
  bool _routing = false;

  /// Rasteriza los markers una vez y repinta el mapa ya con ellos.
  Future<void> _preloadMarkers() async {
    await _markers.preload(
      devicePixelRatio: View.of(context).devicePixelRatio,
    );
    if (mounted) setState(() {});
  }

  bool _markersRequested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_markersRequested) {
      _markersRequested = true;
      _preloadMarkers();
    }

    final city = context.read<CityConfig>();
    _initialPosition = CameraPosition(
      target: LatLng(city.mapCenterLat, city.mapCenterLng),
      zoom: city.mapZoom,
    );
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
              // Zoom por gestos: pinch y doble toque (RF-2.3).
              zoomControlsEnabled: false, // Botones propios más abajo
              mapToolbarEnabled: false,
              // El mapa reclama todos los gestos: si no, al estar dentro del
              // TabBarView el doble toque y el arrastre no le llegan (RF-2.3).
              gestureRecognizers: {
                const Factory<OneSequenceGestureRecognizer>(
                  EagerGestureRecognizer.new,
                ),
              },
              markers: _createMarkers(parkingsProvider, reservationsProvider),
              polylines: _buildPolylines(),
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
                    onPressed: _locating ? null : _moveToUserLocation,
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    child: _locating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(LucideIcons.navigation),
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
              )
            // Panel de aparcamientos más cercanos (RF-2.5). Solo cuando ya se
            // conoce la ubicación y no hay ninguno seleccionado.
            else if (parkingsProvider.userLocation != null)
              Positioned(
                bottom: AppSpacing.md,
                left: 0,
                right: 0,
                child: _buildNearbyPanel(parkingsProvider),
              ),
          ],
        );
      },
    );
  }

  /// Markers propios (assets/parking.svg), coloreados por disponibilidad
  /// (RF-2.2): verde ≥60 % libre · ámbar ≥20 % y <60 % · rojo <20 %.
  Set<Marker> _createMarkers(
    ParkingsProvider parkingsProvider,
    ReservationsProvider reservationsProvider,
  ) {
    return parkingsProvider.parkings.map((parking) {
      return Marker(
        markerId: MarkerId(parking.id),
        position: LatLng(parking.lat, parking.lng),
        icon: _markers.markerFor(parking),
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
            
            // Ruta: ETA y distancia hasta el aparcamiento (RF-2.6).
            _buildRouteInfo(),

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
      _route = null;
    });

    // Animate camera to selected parking
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(parking.lat, parking.lng)),
    );

    _traceRouteTo(parking);
  }

  /// Traza la ruta desde la posición del usuario hasta el aparcamiento elegido
  /// (RF-2.6). Requiere conocer la ubicación: si no, no se pinta nada.
  Future<void> _traceRouteTo(Parking parking) async {
    final origin = context.read<ParkingsProvider>().userLocation;
    if (origin == null) return;

    setState(() => _routing = true);

    final route = await _routes.getRoute(
      origin: LatLng(origin.lat, origin.lng),
      destination: LatLng(parking.lat, parking.lng),
    );

    if (!mounted) return;
    setState(() {
      _routing = false;
      _route = route;
    });
  }

  /// Panel de aparcamientos más cercanos, ordenados por distancia (RF-2.5).
  ///
  /// Al tocar uno se selecciona y se traza la ruta hasta él.
  Widget _buildNearbyPanel(ParkingsProvider parkingsProvider) {
    final nearest = parkingsProvider.nearestParkings.take(5).toList();
    if (nearest.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
            ),
            child: Text(
              context.l10n.mapNearbyTitle,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 92,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            itemCount: nearest.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final parking = nearest[index];
              final meters = parkingsProvider.distanceTo(parking);
              return _buildNearbyCard(parking, meters);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyCard(Parking parking, double? meters) {
    final level = AvailabilityLevel.of(parking);

    return SizedBox(
      width: 190,
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () => _selectParking(parking),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  parking.name,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: level.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      context.l10n.mapFreeSpots(parking.availableSpots),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                if (meters != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppHelpers.getDistanceText(meters),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Fila con el tiempo estimado y la distancia de la ruta (RF-2.6).
  ///
  /// Si aún no se conoce la ubicación del usuario, invita a activarla; mientras
  /// se calcula la ruta muestra un indicador.
  Widget _buildRouteInfo() {
    final hasLocation = context.read<ParkingsProvider>().userLocation != null;

    if (!hasLocation) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Text(
          context.l10n.mapRouteNeedsLocation,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
        ),
      );
    }

    if (_routing) {
      return const Padding(
        padding: EdgeInsets.only(top: AppSpacing.sm),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final route = _route;
    if (route == null) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.sm),
        child: Text(
          context.l10n.mapRouteUnavailable,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.directions_bike, size: 16, color: AppColors.primary),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              // El ETA es una estimación (no hay ruta por calles), y se dice.
              context.l10n.mapRouteEtaEstimated(
                route.eta.inMinutes,
                AppHelpers.getDistanceText(route.distanceMeters.toDouble()),
              ),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Polyline de la ruta activa.
  Set<Polyline> _buildPolylines() {
    final route = _route;
    if (route == null || route.points.isEmpty) return const <Polyline>{};

    return {
      Polyline(
        polylineId: const PolylineId('route'),
        points: route.points,
        color: AppColors.primary,
        width: 5,
      ),
    };
  }

  void _closeSelectedParking() {
    setState(() {
      _selectedParking = null;
      _route = null;
    });
  }

  /// Botón "mi ubicación" (RF-2.4): geolocalización real y centrado del mapa,
  /// con gestión de permiso denegado y de la ubicación desactivada.
  Future<void> _moveToUserLocation() async {
    if (_locating) return;
    setState(() => _locating = true);

    final result = await _location.getCurrentLocation();
    if (!mounted) return;
    setState(() => _locating = false);

    if (result.isGranted) {
      final position = result.location!;
      // La comparte con el provider para poder ordenar por distancia (RF-2.5).
      context.read<ParkingsProvider>().setUserLocation(position);
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(position.lat, position.lng), zoom: 15),
        ),
      );
      return;
    }

    _showLocationProblem(result.status);
  }

  /// Explica al usuario por qué no se pudo obtener su ubicación y, si el
  /// permiso está bloqueado, le ofrece abrir los ajustes del sistema.
  void _showLocationProblem(LocationStatus status) {
    final message = switch (status) {
      LocationStatus.denied => context.l10n.mapLocationDenied,
      LocationStatus.deniedForever => context.l10n.mapLocationDeniedForever,
      LocationStatus.serviceDisabled => context.l10n.mapLocationServiceDisabled,
      _ => context.l10n.mapLocationUnavailable,
    };

    final needsSettings = status == LocationStatus.deniedForever ||
        status == LocationStatus.serviceDisabled;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 6),
        action: needsSettings
            ? SnackBarAction(
                label: context.l10n.mapOpenSettings,
                onPressed: openAppSettings,
              )
            : null,
      ),
    );
  }

  void _toggleFavorite(ParkingsProvider parkingsProvider, Parking parking) {
    parkingsProvider.toggleFavorite(parking.id);
    
    final isFavorite = parkingsProvider.isFavorite(parking.id);
    final message = isFavorite
        ? context.l10n.mapAddedToFavorites(parking.name)
        : context.l10n.mapRemovedFromFavorites(parking.name);

    AppHelpers.showInfoSnackBar(context, message);
  }

  /// Si el tiempo estimado de llegada supera la ventana de reserva, se avisa
  /// antes de confirmar (HU-4, RF-2.6). Devuelve true si se debe seguir.
  Future<bool> _confirmEtaFitsWindow() async {
    final route = _route;
    if (route == null) return true;

    // La ventana de reserva la sirve el backend (RF-B.2), no se hardcodea.
    final windowMin = context.read<SessionProvider>().params.reservationWindowMin;
    final etaMin = route.eta.inMinutes;
    if (etaMin <= windowMin) return true;

    final proceed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.mapEtaWarningTitle),
        content: Text(
          dialogContext.l10n.mapEtaWarningMessage(etaMin, windowMin),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(dialogContext.l10n.mapEtaWarningCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(dialogContext.l10n.mapEtaWarningReserve),
          ),
        ],
      ),
    );

    return proceed ?? false;
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

    // Aviso si no da tiempo a llegar dentro de la ventana de reserva (HU-4).
    if (!await _confirmEtaFitsWindow()) return;
    if (!mounted) return;

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
