import 'package:flutter/material.dart';

class FridgeHealthWidget extends StatelessWidget {
  final double temperature;
  final double humidity;
  final double weight;

  const FridgeHealthWidget({
    super.key,
    required this.temperature,
    required this.humidity,
    required this.weight,
  });

  String _getCoolingStatus() {
    // Threshold sesuai Edge Function: 27-32°C
    if (temperature >= 2 && temperature <= 30) {
      return 'Excellent';
    } else if (temperature >= 1 && temperature <= 32) {
      return 'Good';
    } else {
      return 'Poor';
    }
  }

  Color _getCoolingColor() {
    final status = _getCoolingStatus();
    if (status == 'Excellent') return Colors.green;
    if (status == 'Good') return Colors.blue;
    return Colors.red;
  }

  String _getHumidityStatus() {
    // Threshold sesuai Edge Function: 60-80%
    if (humidity >= 62 && humidity <= 68) {
      return 'Excellent';
    } else if (humidity >= 60 && humidity <= 80) {
      return 'Good';
    } else {
      return 'Poor';
    }
  }

  Color _getHumidityColor() {
    final status = _getHumidityStatus();
    if (status == 'Excellent') return Colors.green;
    if (status == 'Good') return Colors.blue;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Fridge Condition',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 14),
          _buildHealthItem(
            icon: Icons.ac_unit_rounded,
            color: _getCoolingColor(),
            title: 'Cooling Stability',
            status: _getCoolingStatus(),
          ),
          const SizedBox(height: 8),
          _buildHealthItem(
            icon: Icons.water_drop_rounded,
            color: _getHumidityColor(),
            title: 'Humidity Stability',
            status: _getHumidityStatus(),
          ),
          const SizedBox(height: 8),
          _buildHealthItem(
            icon: Icons.line_weight,
            color: _getWeightColor(),
            title: 'Weight Level',
            status: _getWeightStatus(),
          ),
        ],
      ),
    );
  }

  String _getWeightStatus() {
    // Threshold sesuai Edge Function: 20-7000g
    if (weight < 20 || weight > 7000) {
      return 'Empty (Abnormal)';
    } else if (weight > 7000) {
      return 'Overload (Abnormal)';
    } else if (weight < 1000) {
      return 'Low';
    } else if (weight < 3000) {
      return 'Medium';
    } else {
      return 'High';
    }
  }

  Color _getWeightColor() {
    // Threshold sesuai Edge Function: 20-7000g
    if (weight < 20 || weight > 7000) {
      return Colors.red; // Poor/Abnormal
    }
    final status = _getWeightStatus();
    if (status == 'Low') return Colors.orange;
    if (status == 'Medium') return Colors.blue;
    return Colors.green; // High
  }

  Widget _buildHealthItem({
    required IconData icon,
    required Color color,
    required String title,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                    fontFamily: 'Inter',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
