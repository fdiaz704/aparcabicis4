import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aparcabicis4/l10n/l10n.dart';
import '../models/parking.dart';
import '../providers/parkings_provider.dart';
import '../providers/reservations_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/platform_icons.dart';
import '../services/navigation_service.dart';

class ParkingCard extends StatelessWidget {
  final Parking parking;
  final VoidCallback? onReserve;

  const ParkingCard({
    super.key,
    required this.parking,
    this.onReserve,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Consumer2<ParkingsProvider, ReservationsProvider>(
      builder: (context, parkingsProvider, reservationsProvider, child) {
        final isFavorite = parkingsProvider.isFavorite(parking.id);
        final hasAvailableSpots = parking.availableSpots > 0;
        final canReserve = hasAvailableSpots && !reservationsProvider.hasActiveReservation;

        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Parking Name
                    Expanded(
                      child: Text(
                        parking.name,
                        style: AppTextStyles.heading3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Favorite Button
                    IconButton(
                      onPressed: () => _toggleFavorite(context, parkingsProvider),
                      icon: Icon(
                        isFavorite ? Icons.star : Icons.star_border,
                        color: isFavorite 
                            ? AppColors.favorite 
                            : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                      ),
                      tooltip: isFavorite ? context.l10n.parkingCardRemoveFavorite : context.l10n.parkingCardAddFavorite,
                    ),
                    
                    // Availability Badge
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
                        AppHelpers.getAvailabilityBadge(parking.availableSpots, parking.totalSpots),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.sm),
                
                // Address Row
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        parking.address,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? Colors.grey.shade200 : Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppSpacing.md),
                
                // Bottom Row
                Row(
                  children: [
                    // Availability Text
                    Row(
                      children: [
                        Icon(
                          PlatformIcons.bike,
                          size: 16,
                          color: hasAvailableSpots ? AppColors.available : AppColors.unavailable,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          AppHelpers.getAvailabilityText(parking.availableSpots, parking.totalSpots),
                          style: TextStyle(
                            color: hasAvailableSpots ? AppColors.available : AppColors.unavailable,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Reserve Button
                    ElevatedButton(
                      onPressed: canReserve ? () => _handleReserve(context, reservationsProvider) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canReserve ? AppColors.primary : Colors.grey,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(100, 36),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      ),
                      child: Text(
                        _getButtonText(context, canReserve, reservationsProvider.hasActiveReservation),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleFavorite(BuildContext context, ParkingsProvider parkingsProvider) {
    parkingsProvider.toggleFavorite(parking.id);
    
    final isFavorite = parkingsProvider.isFavorite(parking.id);
    final message = isFavorite
        ? context.l10n.parkingCardAddedToFavorites(parking.name)
        : context.l10n.parkingCardRemovedFromFavorites(parking.name);

    AppHelpers.showInfoSnackBar(context, message);
  }

  Future<void> _handleReserve(BuildContext context, ReservationsProvider reservationsProvider) async {
    if (parking.availableSpots <= 0) {
      AppHelpers.showErrorSnackBar(context, context.l10n.parkingCardNoSpotsAvailable);
      return;
    }

    if (reservationsProvider.hasActiveReservation) {
      AppHelpers.showErrorSnackBar(context, context.l10n.parkingCardAlreadyReserved);
      return;
    }

    // Reservar directamente sin modal de confirmación

    // Update parking availability
    final parkingsProvider = context.read<ParkingsProvider>();
    try {
      parkingsProvider.updateParkingAvailability(parking.id, parking.availableSpots - 1);

      // Create reservation
      final success = await reservationsProvider.createReservation(parking);

      if (success) {
        if (context.mounted) {
          AppHelpers.showSuccessSnackBar(
            context,
            context.l10n.parkingCardReservationCreated(parking.name),
          );
        }

        // Navigate to active reservation screen
        NavigationService.pushNamedAndClearStack(AppRoutes.activeReservation);
      } else {
        // Restore parking availability if reservation failed
        parkingsProvider.updateParkingAvailability(parking.id, parking.availableSpots + 1);
        if (context.mounted) {
          AppHelpers.showErrorSnackBar(context, context.l10n.parkingCardReservationError);
        }
      }
    } catch (e) {
      // Restore parking availability on error
      parkingsProvider.updateParkingAvailability(parking.id, parking.availableSpots + 1);
      if (context.mounted) {
        AppHelpers.showErrorSnackBar(context, context.l10n.parkingCardReservationError);
      }
    }

    // Call optional callback
    onReserve?.call();
  }

  String _getButtonText(BuildContext context, bool canReserve, bool hasActiveReservation) {
    if (hasActiveReservation) {
      return context.l10n.parkingCardActiveReservation;
    } else if (!canReserve) {
      return context.l10n.parkingCardNoSpots;
    } else {
      return context.l10n.parkingCardReserve;
    }
  }
}
