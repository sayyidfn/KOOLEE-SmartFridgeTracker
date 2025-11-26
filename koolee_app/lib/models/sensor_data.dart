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

  bool get isWeightNormal => weight >= 20 && weight <= 7000; // max 7kg
  bool get isTemperatureNormal => temperature >= 0 && temperature <= 32;
  bool get isHumidityNormal => humidity >= 60 && humidity <= 80;

  String get temperatureStatus {
    if (temperature < 0) return 'Terlalu Dingin';
    if (temperature > 32) return 'Terlalu Panas';
    return 'Normal';
  }

  String get weightStatus {
    if (weight < 20) return 'Berat Terlalu Ringan';
    if (weight > 7000) return 'Berat Terlalu Berat';
    return 'Normal';
  }
  String get humidityStatus {
    if (humidity < 60) return 'Kelembaban Terlalu Rendah';
    if (humidity > 80) return 'Kelembaban Terlalu Tinggi';
    return 'Normal';
  }
}