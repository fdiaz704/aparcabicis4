enum ReservationStatus { completed, cancelled, expired }

class ReservationRecord {
  final String id;
  final String stationName;
  final String stationAddress;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration; // Duration in minutes
  final ReservationStatus status;
  final double cost; // Cost in euros

  ReservationRecord({
    required this.id,
    required this.stationName,
    required this.stationAddress,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.status,
    this.cost = 0.0,
  });

  ReservationRecord copyWith({
    String? id,
    String? stationName,
    String? stationAddress,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    ReservationStatus? status,
    double? cost,
  }) {
    return ReservationRecord(
      id: id ?? this.id,
      stationName: stationName ?? this.stationName,
      stationAddress: stationAddress ?? this.stationAddress,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      cost: cost ?? this.cost,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stationName': stationName,
      'stationAddress': stationAddress,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'duration': duration,
      'status': status.name,
      'cost': cost,
    };
  }

  factory ReservationRecord.fromJson(Map<String, dynamic> json) {
    return ReservationRecord(
      id: json['id'] as String,
      stationName: json['stationName'] as String,
      stationAddress: json['stationAddress'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      duration: json['duration'] as int,
      status: ReservationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReservationStatus.completed,
      ),
      cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReservationRecord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'ReservationRecord(id: $id, station: $stationName, duration: ${duration}m, status: ${status.name})';
  }
}
