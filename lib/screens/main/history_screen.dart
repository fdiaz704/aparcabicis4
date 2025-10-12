import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../providers/reservations_provider.dart';
import '../../models/reservation_record.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/platform_widgets.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/history_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  ReservationStatus? _selectedFilter;
  String _sortBy = 'date_desc'; // 'date_desc', 'date_asc', 'duration_desc', 'duration_asc'

  @override
  Widget build(BuildContext context) {
    return Consumer<ReservationsProvider>(
      builder: (context, reservationsProvider, child) {
        final history = reservationsProvider.reservationHistory;
        final filteredHistory = _getFilteredHistory(history);
        final stats = reservationsProvider.getStatistics();

        return Column(
          children: [
            // Statistics Cards
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              color: Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estadísticas',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Stats Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                    children: [
                      StatCard(
                        icon: LucideIcons.bike,
                        title: 'Total reservas',
                        value: stats['totalReservations'].toString(),
                        color: AppColors.primary,
                      ),
                      StatCard(
                        icon: Icons.check_circle,
                        title: 'Completadas',
                        value: stats['completedReservations'].toString(),
                        subtitle: '${stats['completionRate']}% éxito',
                        color: AppColors.success,
                      ),
                      StatCard(
                        icon: LucideIcons.clock,
                        title: 'Tiempo total',
                        value: AppHelpers.formatDuration(
                          Duration(seconds: stats['totalUsageTime']),
                        ),
                        color: AppColors.info,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Filters and Sort
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 2,
              ),
              color: Colors.white,
              child: Row(
                children: [
                  // Filter Dropdown
                  Flexible(
                    flex: 1,
                    child: DropdownButtonFormField<ReservationStatus?>(
                      value: _selectedFilter,
                      isDense: true,
                      decoration: const InputDecoration(
                        labelText: 'Estado',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 0,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<ReservationStatus?>(
                          value: null,
                          child: Text('Todos'),
                        ),
                        ...ReservationStatus.values.map((status) {
                          return DropdownMenuItem<ReservationStatus?>(
                            value: status,
                            child: Text(_getStatusText(status)),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedFilter = value;
                        });
                      },
                    ),
                  ),
                  
                  const SizedBox(width: AppSpacing.xs),
                  
                  // Sort Dropdown
                  Flexible(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      value: _sortBy,
                      isDense: true,
                      decoration: const InputDecoration(
                        labelText: 'Ordenar',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 0,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'date_desc',
                          child: Text('Reciente'),
                        ),
                        DropdownMenuItem(
                          value: 'date_asc',
                          child: Text('Antiguo'),
                        ),
                        DropdownMenuItem(
                          value: 'duration_desc',
                          child: Text('+ Duración'),
                        ),
                        DropdownMenuItem(
                          value: 'duration_asc',
                          child: Text('- Duración'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sortBy = value!;
                        });
                      },
                    ),
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
                    '${filteredHistory.length} reserva${filteredHistory.length != 1 ? 's' : ''} encontrada${filteredHistory.length != 1 ? 's' : ''}',
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            
            // History List
            Expanded(
              child: filteredHistory.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: filteredHistory.length,
                      itemBuilder: (context, index) {
                        final record = filteredHistory[index];
                        return HistoryCard(
                          record: record,
                          onTap: () => _showReservationDetails(context, record),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  List<ReservationRecord> _getFilteredHistory(List<ReservationRecord> history) {
    var filtered = history;

    // Apply status filter
    if (_selectedFilter != null) {
      filtered = filtered.where((record) => record.status == _selectedFilter).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'date_desc':
          return b.startTime.compareTo(a.startTime);
        case 'date_asc':
          return a.startTime.compareTo(b.startTime);
        case 'duration_desc':
          final aDuration = a.endTime?.difference(a.startTime) ?? Duration.zero;
          final bDuration = b.endTime?.difference(b.startTime) ?? Duration.zero;
          return bDuration.compareTo(aDuration);
        case 'duration_asc':
          final aDuration = a.endTime?.difference(a.startTime) ?? Duration.zero;
          final bDuration = b.endTime?.difference(b.startTime) ?? Duration.zero;
          return aDuration.compareTo(bDuration);
        default:
          return b.startTime.compareTo(a.startTime);
      }
    });

    return filtered;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _selectedFilter != null
                  ? 'No hay reservas ${_getStatusText(_selectedFilter!).toLowerCase()}'
                  : 'No hay reservas en el historial',
              style: AppTextStyles.heading3.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _selectedFilter != null
                  ? 'Intenta cambiar el filtro para ver más reservas'
                  : 'Tus reservas aparecerán aquí una vez que las completes',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            if (_selectedFilter != null) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _selectedFilter = null;
                  });
                },
                child: const Text('Mostrar todas'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getStatusText(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.completed:
        return 'Completadas';
      case ReservationStatus.cancelled:
        return 'Canceladas';
      case ReservationStatus.expired:
        return 'Expiradas';
    }
  }

  void _showReservationDetails(BuildContext context, ReservationRecord record) {
    PlatformWidgets.showAdaptiveModalBottomSheet(
      context: context,
      isScrollControlled: true,
      child: _buildReservationDetailsSheet(record),
    );
  }

  Widget _buildReservationDetailsSheet(ReservationRecord record) {
    final duration = record.endTime?.difference(record.startTime);
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Detalles de la reserva',
                  style: AppTextStyles.heading2,
                ),
              ),
              PlatformWidgets.buildAdaptiveCloseButton(context),
            ],
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Station Info
          _buildDetailRow('Estación', record.stationName, LucideIcons.bike),
          _buildDetailRow('Fecha', AppHelpers.formatDateTime(record.startTime), Icons.calendar_today),
          
          if (duration != null)
            _buildDetailRow('Duración', AppHelpers.formatDuration(duration), LucideIcons.clock),
          
          if (record.cost > 0)
            _buildDetailRow('Coste', '€${record.cost.toStringAsFixed(2)}', Icons.euro),
          
          _buildDetailRow('Estado', _getStatusText(record.status), Icons.info),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Close Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ),
          
          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$label:',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
