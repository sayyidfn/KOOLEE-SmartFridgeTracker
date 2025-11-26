enum BuzzerMode {
  auto('auto'),
  manualOn('manual_on'),
  manualOff('manual_off');

  final String value;
  const BuzzerMode(this.value);

  static BuzzerMode fromString(String value) {
    switch (value) {
      case 'manual_on':
        return BuzzerMode.manualOn;
      case 'manual_off':
        return BuzzerMode.manualOff;
      case 'auto':
      default:
        return BuzzerMode.auto;
    }
  }

  String get displayName {
    switch (this) {
      case BuzzerMode.auto:
        return 'Auto';
      case BuzzerMode.manualOn:
        return 'Manual ON';
      case BuzzerMode.manualOff:
        return 'Manual OFF';
    }
  }

  String get description {
    switch (this) {
      case BuzzerMode.auto:
        return 'System controlled based on sensors';
      case BuzzerMode.manualOn:
        return 'Force buzzer active';
      case BuzzerMode.manualOff:
        return 'Force buzzer inactive';
    }
  }
}

class ControlData {
  final String id;
  final bool buzzerActive;
  final BuzzerMode buzzerMode;
  final DateTime? updatedAt;

  ControlData({
    required this.id,
    required this.buzzerActive,
    this.buzzerMode = BuzzerMode.auto,
    this.updatedAt,
  });

  factory ControlData.fromJson(Map<String, dynamic> json) {
    return ControlData(
      id: json['id'].toString(),
      buzzerActive: json['buzzer_active'] ?? false,
      buzzerMode: BuzzerMode.fromString(json['buzzer_mode'] ?? 'auto'),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buzzer_active': buzzerActive,
      'buzzer_mode': buzzerMode.value,
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  // Helper method to create update payload
  Map<String, dynamic> toUpdatePayload() {
    return {
      'buzzer_active': buzzerActive,
      'buzzer_mode': buzzerMode.value,
    };
  }

  // Copy with method for immutability
  ControlData copyWith({
    String? id,
    bool? buzzerActive,
    BuzzerMode? buzzerMode,
    DateTime? updatedAt,
  }) {
    return ControlData(
      id: id ?? this.id,
      buzzerActive: buzzerActive ?? this.buzzerActive,
      buzzerMode: buzzerMode ?? this.buzzerMode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getter untuk cek apakah mode manual
  bool get isManualMode =>
      buzzerMode == BuzzerMode.manualOn || buzzerMode == BuzzerMode.manualOff;

  // Getter untuk cek apakah mode auto
  bool get isAutoMode => buzzerMode == BuzzerMode.auto;
}
