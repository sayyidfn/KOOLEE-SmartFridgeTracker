import 'package:flutter/material.dart';
import '../models/control_data.dart';

class BuzzerAlertSection extends StatelessWidget {
  final BuzzerMode currentMode;
  final ValueChanged<BuzzerMode> onModeChanged;

  const BuzzerAlertSection({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  Color _getModeColor(BuzzerMode mode) {
    switch (mode) {
      case BuzzerMode.auto:
        return const Color(0xFF3B82F6); // Blue - consistent with app theme
      case BuzzerMode.manualOn:
        return const Color(0xFFEF4444); // Red
      case BuzzerMode.manualOff:
        return const Color(0xFF6B7280); // Gray
    }
  }

  IconData _getModeIcon(BuzzerMode mode) {
    switch (mode) {
      case BuzzerMode.auto:
        return Icons.settings_suggest_rounded; // Auto settings icon
      case BuzzerMode.manualOn:
        return Icons.volume_up_rounded; // Buzzer on
      case BuzzerMode.manualOff:
        return Icons.volume_off_rounded; // Buzzer off
    }
  }

  String _getModeStatusText(BuzzerMode mode) {
    switch (mode) {
      case BuzzerMode.auto:
        return 'Auto: Based on sensor conditions';
      case BuzzerMode.manualOn:
        return 'Manually activated';
      case BuzzerMode.manualOff:
        return 'Manually deactivated';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _getModeColor(currentMode),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getModeIcon(currentMode),
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Buzzer Control',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getModeStatusText(currentMode),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildModeButton(BuzzerMode.auto),
                _buildModeButton(BuzzerMode.manualOn),
                _buildModeButton(BuzzerMode.manualOff),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(BuzzerMode mode) {
    final isSelected = currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => onModeChanged(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            mode.displayName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? _getModeColor(currentMode) : Colors.white,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }
}
