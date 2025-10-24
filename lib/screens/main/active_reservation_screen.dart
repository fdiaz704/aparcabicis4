import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/reservations_provider.dart';
import '../../providers/stations_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/platform_icons.dart';
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

        final station = reservationsProvider.activeReservation!;
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
                      _buildHeaderMap(station, isReserved, isInUse),
                      
                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            children: [
                              // Station Info
                              _buildStationInfo(station),
                              
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

  Widget _buildHeaderMap(dynamic station, bool isReserved, bool isInUse) {
    return Container(
      height: AppDimensions.mapHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.mapGradient,
        ),
      ),
      child: Stack(
        children: [
          // Grid Background
          CustomPaint(
            painter: _GridPainter(),
            size: Size.infinite,
          ),
          
          // Station Marker (centered)
          Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.reserved,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.reserved.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Icon(
                PlatformIcons.locationFill,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          
          // Status Badge
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
              ),
              child: Text(
                isReserved ? 'Reservada' : 'En uso',
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

  Widget _buildStationInfo(dynamic station) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              station.name,
              style: AppTextStyles.heading2,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    station.address,
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
              'Tiempo restante de reserva',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Timer Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PlatformIcons.clock, color: AppColors.primary),
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
              'Tiempo de uso',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Timer Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(PlatformIcons.clock, color: AppColors.primary),
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
              'Tiempo máximo: ${reservationsProvider.formatTime(AppConstants.maxUsageTimeSeconds)}',
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
                  ? 'Abre la puerta para comenzar a usar la plaza. Tienes 30 minutos para llegar.'
                  : 'Puedes abrir y cerrar la puerta tantas veces como necesites durante tu uso.',
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
            label: const Text(
              'Abrir puerta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              isReserved ? 'Cancelar reserva' : 'Finalizar uso',
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
        color: Colors.black.withOpacity(0.5),
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
                      'Instrucciones finales',
                      style: AppTextStyles.heading2,
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    // Instructions List
                    _buildInstructionItem(1, 'Retire todas sus pertenencias'),
                    const SizedBox(height: AppSpacing.lg),
                    _buildInstructionItem(2, 'Cierre la puerta'),
                    const SizedBox(height: AppSpacing.lg),
                    _buildInstructionItem(3, 'La plaza quedará disponible\npara otros usuarios'),
                    
                    const SizedBox(height: AppSpacing.xl),
                    
                    Text(
                      'Toca en cualquier parte para\ncontinuar',
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
    AppHelpers.showSuccessSnackBar(context, 'Puerta abierta correctamente');
  }

  Future<void> _handleCancelReservation(ReservationsProvider reservationsProvider) async {
    // Cancelar reserva directamente sin modal de confirmación

    try {
      // Restore station availability
      final stationsProvider = context.read<StationsProvider>();
      final station = reservationsProvider.activeReservation!;
      stationsProvider.updateStationAvailability(station.id, station.availableSpots + 1);

      // Cancel reservation
      await reservationsProvider.cancelReservation();

      if (mounted) {
        AppHelpers.showInfoSnackBar(context, 'Reserva cancelada');
        NavigationService.pushNamedAndClearStack(AppRoutes.main);
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showErrorSnackBar(context, 'Error al cancelar la reserva');
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
      // Restore station availability
      final reservationsProvider = context.read<ReservationsProvider>();
      final stationsProvider = context.read<StationsProvider>();
      final station = reservationsProvider.activeReservation!;
      
      stationsProvider.updateStationAvailability(station.id, station.availableSpots + 1);

      // Finish usage
      await reservationsProvider.finishUsage();

      if (mounted) {
        AppHelpers.showSuccessSnackBar(context, 'Uso finalizado correctamente');
        NavigationService.pushNamedAndClearStack(AppRoutes.main);
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showErrorSnackBar(context, 'Error al finalizar el uso');
      }
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
