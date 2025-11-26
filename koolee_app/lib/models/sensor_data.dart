class SensorData {
  final String id;
  final double temperature;
  final double humidity;
  final double weight;
  final DateTime timestamp;
  final String? status;

  SensorData({
    required this.id,
    required this.temperature,
    required this.humidity,
    required this.weight,
    required this.timestamp,
    this.status,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      id: json['id'].toString(),
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      weight: (json['weight'] ?? 0).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] ?? json['created_at']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'temperature': temperature,
      'humidity': humidity,
      'weight': weight,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }

  bool get isTemperatureNormal => temperature >= -5 && temperature <= 5;
  bool get isWeightNormal => weight >= 0 && weight <= 5000; // max 5kg

  String get temperatureStatus {
    if (temperature < -5) return 'Terlalu Dingin';
    if (temperature > 5) return 'Terlalu Panas';
    return 'Normal';
  }
}
