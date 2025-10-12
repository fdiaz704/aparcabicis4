import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../models/reservation_record.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class HistoryCard extends StatelessWidget {
  final ReservationRecord record;
  final VoidCallback? onTap;

  const HistoryCard({
    super.key,
    required this.record,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(record.status);
    final statusIcon = _getStatusIcon(record.status);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Station Name
                  Expanded(
                    child: Text(
                      record.stationName,
                      style: AppTextStyles.heading3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          _getStatusText(record.status),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              // Date and Time
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    AppHelpers.formatDateTime(record.startTime),
                    style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
              
              const SizedBox(height: AppSpacing.sm),
              
              // Duration and Details
              Row(
                children: [
                  // Duration
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.clock,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        _getDurationText(),
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Cost (if applicable)
                  if (record.cost > 0) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                      ),
                      child: Text(
                        '€${record.cost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.completed:
        return AppColors.success;
      case ReservationStatus.cancelled:
        return AppColors.error;
      case ReservationStatus.expired:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.completed:
        return Icons.check_circle;
      case ReservationStatus.cancelled:
        return Icons.cancel;
      case ReservationStatus.expired:
        return Icons.access_time;
    }
  }

  String _getStatusText(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.completed:
        return 'Completada';
      case ReservationStatus.cancelled:
        return 'Cancelada';
      case ReservationStatus.expired:
        return 'Expirada';
    }
  }

  String _getDurationText() {
    if (record.endTime != null) {
      final duration = record.endTime!.difference(record.startTime);
      return AppHelpers.formatDuration(duration);
    } else {
      return 'Sin finalizar';
    }
  }
}
