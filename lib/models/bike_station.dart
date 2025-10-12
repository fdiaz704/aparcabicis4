class BikeStation {
  final String id;
  final String name;
  final String address;
  final int availableSpots;
  final int totalSpots;
  final double lat;
  final double lng;

  BikeStation({
    required this.id,
    required this.name,
    required this.address,
    required this.availableSpots,
    required this.totalSpots,
    required this.lat,
    required this.lng,
  });

  BikeStation copyWith({
    String? id,
    String? name,
    String? address,
    int? availableSpots,
    int? totalSpots,
    double? lat,
    double? lng,
  }) {
    return BikeStation(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      availableSpots: availableSpots ?? this.availableSpots,
      totalSpots: totalSpots ?? this.totalSpots,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'availableSpots': availableSpots,
      'totalSpots': totalSpots,
      'lat': lat,
      'lng': lng,
    };
  }

  factory BikeStation.fromJson(Map<String, dynamic> json) {
    return BikeStation(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      availableSpots: json['availableSpots'] as int,
      totalSpots: json['totalSpots'] as int,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BikeStation && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BikeStation(id: $id, name: $name, availableSpots: $availableSpots/$totalSpots)';
  }
}
