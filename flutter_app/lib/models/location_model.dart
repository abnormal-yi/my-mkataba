class LocationModel {
  final int id;
  final int riderId;
  final String riderName;
  final double lat;
  final double lng;
  final String timestamp;

  LocationModel({
    required this.id, required this.riderId, required this.riderName,
    required this.lat, required this.lng, required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'riderId': riderId, 'riderName': riderName,
    'lat': lat, 'lng': lng, 'timestamp': timestamp,
  };

  factory LocationModel.fromMap(Map<String, dynamic> m) => LocationModel(
    id: m['id'] as int, riderId: m['riderId'] as int,
    riderName: m['riderName'] as String,
    lat: (m['lat'] as num).toDouble(),
    lng: (m['lng'] as num).toDouble(),
    timestamp: m['timestamp'] as String,
  );
}
