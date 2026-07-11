import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aparcabicis4/l10n/l10n.dart';
import '../../providers/reservations_provider.dart';
import '../../models/reservation_record.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/platform_icons.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
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
              color: isDark ? Theme.of(context).colorScheme.surface : Colors.grey[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.historyStatistics,
                    style: AppTextStyles.heading3.copyWith(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Stats Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    childAspectRatio: Platform.isIOS ? 1.0 : 1.2,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                    children: [
                      StatCard(
                        icon: PlatformIcons.bike,
                        title: context.l10n.historyTotalReservations,
                        value: stats['totalReservations'].toString(),
                        color: AppColors.primary,
                      ),
                      StatCard(
                        icon: PlatformIcons.checkmarkCircle,
                        title: context.l10n.historyCompleted,
                        value: stats['completedReservations'].toString(),
                        subtitle: context.l10n.historySuccessRate(stats['completionRate']),
                        color: AppColors.success,
                      ),
                      StatCard(
                        icon: PlatformIcons.clock,
                        title: context.l10n.historyTotalTime,
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
              color: isDark ? Theme.of(context).colorScheme.surface : Colors.white,
              child: Row(
                children: [
                  // Filter Dropdown
                  Flexible(
                    flex: 1,
                    child: DropdownButtonFormField<ReservationStatus?>(
                      value: _selectedFilter,
                      isDense: true,
                      decoration: InputDecoration(
                        labelText: context.l10n.historyStatus,
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        ),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 0,
                        ),
                      ),
                      items: [
                        DropdownMenuItem<ReservationStatus?>(
                          value: null,
                          child: Text(
                            context.l10n.historyAll,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        ...ReservationStatus.values.map((status) {
                          return DropdownMenuItem<ReservationStatus?>(
                            value: status,
                            child: Text(
                              _getStatusText(status),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
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
                      decoration: InputDecoration(
                        labelText: context.l10n.historySortLabel,
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        ),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 0,
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'date_desc',
                          child: Text(
                            context.l10n.historySortRecent,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'date_asc',
                          child: Text(
                            context.l10n.historySortOldest,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'duration_desc',
                          child: Text(
                            context.l10n.historySortDurationDesc,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'duration_asc',
                          child: Text(
                            context.l10n.historySortDurationAsc,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
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
              color: isDark ? Theme.of(context).colorScheme.surface : Colors.grey[50],
              child: Row(
                children: [
                  Text(
                    context.l10n.historyResultsCount(filteredHistory.length),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PlatformIcons.history,
              size: 64,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _selectedFilter != null
                  ? context.l10n.historyNoReservationsFiltered(_getStatusText(_selectedFilter!).toLowerCase())
                  : context.l10n.historyNoReservations,
              style: AppTextStyles.heading3.copyWith(
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _selectedFilter != null
                  ? context.l10n.historyTryChangeFilter
                  : context.l10n.historyReservationsWillAppear,
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              ),
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
                child: Text(context.l10n.historyShowAll),
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
        return context.l10n.historyStatusCompleted;
      case ReservationStatus.cancelled:
        return context.l10n.historyStatusCancelled;
      case ReservationStatus.expired:
        return context.l10n.historyStatusExpired;
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
                  context.l10n.historyReservationDetails,
                  style: AppTextStyles.heading2,
                ),
              ),
              PlatformWidgets.buildAdaptiveCloseButton(context),
            ],
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Parking Info
          _buildDetailRow(context.l10n.historyLabelParking, record.parkingName, PlatformIcons.bike),
          _buildDetailRow(context.l10n.historyLabelDate, AppHelpers.formatDateTime(record.startTime), PlatformIcons.calendar),

          if (duration != null)
            _buildDetailRow(context.l10n.historyLabelDuration, AppHelpers.formatDuration(duration), PlatformIcons.clock),

          if (record.cost > 0)
            _buildDetailRow(context.l10n.historyLabelCost, '€${record.cost.toStringAsFixed(2)}', Icons.euro),

          _buildDetailRow(context.l10n.historyStatus, _getStatusText(record.status), Icons.info),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Close Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.historyClose),
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
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '$label:',
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
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
