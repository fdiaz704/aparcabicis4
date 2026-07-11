import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import 'package:aparcabicis4/l10n/l10n.dart';
import '../../providers/reservations_provider.dart';
import '../../providers/parkings_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../services/navigation_service.dart';

class ActiveReservationScreen extends StatefulWidget {
  const ActiveReservationScreen({super.key});

  @override
  State<ActiveReservationScreen> createState() => _ActiveReservationScreenState();
}

class _ActiveReservationScreenState extends State<ActiveReservationScreen> {
  bool _showFinishModal = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ReservationsProvider>(
      builder: (context, reservationsProvider, child) {
        // If no active reservation, navigate back to main
        if (!reservationsProvider.hasActiveReservation) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            NavigationService.pushNamedAndClearStack(AppRoutes.main);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final parking = reservationsProvider.activeReservation!;
        final isReserved = reservationsProvider.reservationState == ReservationState.reserved;
        final isInUse = reservationsProvider.reservationState == ReservationState.inUse;

        return Scaffold(
          body: Stack(
            children: [
              // Main Content
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFEFF6FF), Colors.white],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Header Map
                      _buildHeaderMap(parking, isReserved, isInUse),
                      
                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            children: [
                              // Parking Info
                              _buildParkingInfo(parking),
                              
                              const SizedBox(height: AppSpacing.xl),
                              
                              // Timer Section
                              if (isReserved)
                                _buildReservationTimer(reservationsProvider)
                              else if (isInUse)
                                _buildUsageTimer(reservationsProvider),
                              
                              const SizedBox(height: AppSpacing.xl),
                              
                              // Instructions
                              _buildInstructions(isReserved, isInUse),
                              
                              const SizedBox(height: AppSpacing.xl),
                              
                              // Action Buttons
                              _buildActionButtons(
                                reservationsProvider,
                                isReserved,
                                isInUse,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Finish Modal
              if (_showFinishModal)
                _buildFinishModal(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderMap(dynamic parking, bool isReserved, bool isInUse) {
    // Get all parkings to show nearby ones
    final parkingsProvider = Provider.of<ParkingsProvider>(context, listen: false);

    final Set<Marker> markers = parkingsProvider.parkings.map((s) {
      final isTargetParking = s.id == parking.id;

      // Determine marker hue
      double markerHue;
      if (isTargetParking) {
        markerHue = BitmapDescriptor.hueBlue; // Reserved/Target
      } else if (s.availableSpots > 0) {
        markerHue = BitmapDescriptor.hueGreen; // Available
      } else {
        markerHue = BitmapDescriptor.hueRed; // Unavailable
      }

      return Marker(
        markerId: MarkerId(s.id),
        position: LatLng(s.lat, s.lng),
        icon: BitmapDescriptor.defaultMarkerWithHue(markerHue),
      );
    }).toSet();

    return SizedBox(
      height: AppDimensions.mapHeight,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(parking.lat, parking.lng),
              zoom: 15, // Close enough to see nearby context
            ),
            markers: markers,
            zoomControlsEnabled: false,
            zoomGesturesEnabled: false, // Disabled as requested
            scrollGesturesEnabled: false, // Disabled as requested
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            mapToolbarEnabled: false,
          ),
          
          // Status Badge Overlay
          Positioned(
            top: AppSpacing.md,
            right: AppSpacing.md,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isReserved ? Colors.grey[600] : AppColors.primary,
                borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                isReserved ? context.l10n.activeStatusReserved : context.l10n.activeStatusInUse,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParkingInfo(dynamic parking) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              parking.name,
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    parking.address,
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReservationTimer(ReservationsProvider reservationsProvider) {
    final timeLeft = reservationsProvider.reservationTimeLeft;
    final progress = timeLeft / AppConstants.reservationTimeoutSeconds;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(
              context.l10n.activeReservationTimeLeft,
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Timer Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.clock, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  reservationsProvider.formatTime(timeLeft),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Progress Bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                timeLeft <= 300 ? Colors.red : AppColors.primary, // Red when <= 5 min
              ),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageTimer(ReservationsProvider reservationsProvider) {
    final usageTime = reservationsProvider.usageTime;
    final progress = usageTime / AppConstants.maxUsageTimeSeconds;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Text(
              context.l10n.activeUsageTime,
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Timer Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.clock, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  reservationsProvider.formatTime(usageTime),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            Text(
              context.l10n.activeMaxTime(reservationsProvider.formatTime(AppConstants.maxUsageTimeSeconds)),
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
            ),
            
            const SizedBox(height: AppSpacing.md),
            
            // Progress Bar
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.8 ? Colors.orange : AppColors.primary, // Orange when > 80%
              ),
              minHeight: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions(bool isReserved, bool isInUse) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info,
            color: Colors.blue[700],
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              isReserved
                  ? context.l10n.activeInstructionsReserved
                  : context.l10n.activeInstructionsInUse,
              style: TextStyle(
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    ReservationsProvider reservationsProvider,
    bool isReserved,
    bool isInUse,
  ) {
    return Column(
      children: [
        // Open Door Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () => _handleOpenDoor(reservationsProvider),
            icon: const Icon(Icons.lock_open, size: 24),
            label: Text(
              context.l10n.activeOpenDoor,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        
        const SizedBox(height: AppSpacing.md),
        
        // Secondary Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: isReserved
                ? () => _handleCancelReservation(reservationsProvider)
                : () => _handleFinishUsage(),
            style: OutlinedButton.styleFrom(
              foregroundColor: isReserved ? Colors.red : AppColors.primary,
              side: BorderSide(
                color: isReserved ? Colors.red : AppColors.primary,
              ),
            ),
            child: Text(
              isReserved ? context.l10n.activeCancelReservation : context.l10n.activeFinishUsage,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinishModal() {
    return GestureDetector(
      onTap: _closeFinishModal,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: GestureDetector(
            onTap: _closeFinishModal,
            child: Card(
              margin: const EdgeInsets.all(AppSpacing.xl),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.activeFinalInstructions,
                      style: AppTextStyles.heading2,
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Instructions List
                    _buildInstructionItem(1, context.l10n.activeInstructionRemoveBelongings),
                    const SizedBox(height: AppSpacing.lg),
                    _buildInstructionItem(2, context.l10n.activeInstructionCloseDoor),
                    const SizedBox(height: AppSpacing.lg),
                    _buildInstructionItem(3, context.l10n.activeInstructionSpotAvailable),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    Text(
                      context.l10n.activeTapToContinue,
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(int number, String text) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body,
          ),
        ),
      ],
    );
  }

  void _handleOpenDoor(ReservationsProvider reservationsProvider) {
    // Open door functionality
    reservationsProvider.openDoor();
    
    // Show success message
    AppHelpers.showSuccessSnackBar(context, context.l10n.activeDoorOpenedSuccess);
  }

  Future<void> _handleCancelReservation(ReservationsProvider reservationsProvider) async {
    // Cancelar reserva directamente sin modal de confirmación

    try {
      // Restore parking availability
      final parkingsProvider = context.read<ParkingsProvider>();
      final parking = reservationsProvider.activeReservation!;
      parkingsProvider.updateParkingAvailability(parking.id, parking.availableSpots + 1);

      // Cancel reservation
      await reservationsProvider.cancelReservation();

      if (mounted) {
        AppHelpers.showInfoSnackBar(context, context.l10n.activeReservationCancelled);
        NavigationService.pushNamedAndClearStack(AppRoutes.main);
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showErrorSnackBar(context, context.l10n.activeCancelReservationError);
      }
    }
  }

  void _handleFinishUsage() {
    setState(() {
      _showFinishModal = true;
    });
  }

  Future<void> _closeFinishModal() async {
    setState(() {
      _showFinishModal = false;
    });

    try {
      // Restore parking availability
      final reservationsProvider = context.read<ReservationsProvider>();
      final parkingsProvider = context.read<ParkingsProvider>();
      final parking = reservationsProvider.activeReservation!;
      
      parkingsProvider.updateParkingAvailability(parking.id, parking.availableSpots + 1);

      // Finish usage
      await reservationsProvider.finishUsage();

      if (mounted) {
        AppHelpers.showSuccessSnackBar(context, context.l10n.activeUsageFinishedSuccess);
        NavigationService.pushNamedAndClearStack(AppRoutes.main);
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showErrorSnackBar(context, context.l10n.activeFinishUsageError);
      }
    }
  }
}


