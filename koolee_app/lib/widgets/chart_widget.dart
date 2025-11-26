import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sensor_data.dart';

class ChartWidget extends StatefulWidget {
  final List<SensorData> data;

  const ChartWidget({super.key, required this.data});

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  int _selectedTab = 0; // 0: Temp, 1: Humid, 2: Weight

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tabs
          Row(
            children: [
              _buildTab('Temp', 0),
              const SizedBox(width: 8),
              _buildTab('Humid', 1),
              const SizedBox(width: 8),
              _buildTab('Weight', 2),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(child: LineChart(_buildChartData())),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  double _getMinY() {
    if (widget.data.isEmpty) return 0;

    double minValue = double.infinity;
    for (var data in widget.data) {
      double value;
      switch (_selectedTab) {
        case 0:
          value = data.temperature;
          break;
        case 1:
          value = data.humidity;
          break;
        case 2:
          value = data.weight / 1000; // Convert to kg
          break;
        default:
          value = data.temperature;
      }
      if (value < minValue) minValue = value;
    }

    // Add padding (10% below minimum)
    return minValue - (minValue * 0.1);
  }

  double _getMaxY() {
    if (widget.data.isEmpty) return 100;

    double maxValue = double.negativeInfinity;
    for (var data in widget.data) {
      double value;
      switch (_selectedTab) {
        case 0:
          value = data.temperature;
          break;
        case 1:
          value = data.humidity;
          break;
        case 2:
          value = data.weight / 1000; // Convert to kg
          break;
        default:
          value = data.temperature;
      }
      if (value > maxValue) maxValue = value;
    }

    // Add padding (10% above maximum)
    return maxValue + (maxValue * 0.1);
  }

  double _getYAxisInterval() {
    final range = _getMaxY() - _getMinY();
    // Aim for about 5-6 labels to avoid crowding
    if (range <= 1) return 0.2; // For weight in kg (small values)
    if (range <= 3) return 1; // For small humidity ranges
    if (range <= 10) return 2;
    if (range <= 20) return 4;
    if (range <= 50) return 10;
    if (range <= 100) return 20;
    return 25;
  }

  List<SensorData> _sampleData(List<SensorData> data) {
    // If data is too dense, sample it to max 50 points
    if (data.length <= 50) return data;

    final sampledData = <SensorData>[];
    final step = data.length / 50;

    for (var i = 0; i < 50; i++) {
      final index = (i * step).floor();
      if (index < data.length) {
        sampledData.add(data[index]);
      }
    }

    return sampledData;
  }

  LineChartData _buildChartData() {
    // Reverse data to show oldest first
    final reversedData = _sampleData(widget.data.reversed.toList());

    // Prepare data based on selected tab
    final spots = <FlSpot>[];
    for (var i = 0; i < reversedData.length; i++) {
      double value;
      switch (_selectedTab) {
        case 0: // Temperature
          value = reversedData[i].temperature;
          break;
        case 1: // Humidity
          value = reversedData[i].humidity;
          break;
        case 2: // Weight (in kg)
          value = reversedData[i].weight / 1000;
          break;
        default:
          value = reversedData[i].temperature;
      }
      spots.add(FlSpot(i.toDouble(), value));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _getYAxisInterval(),
        getDrawingHorizontalLine: (value) {
          return FlLine(color: Colors.grey.shade200, strokeWidth: 1);
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 35,
            interval: reversedData.length > 5
                ? (reversedData.length / 5).ceilToDouble()
                : 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < reversedData.length) {
                final dateTime = reversedData[value.toInt()].timestamp;
                final now = DateTime.now();
                final isToday =
                    dateTime.year == now.year &&
                    dateTime.month == now.month &&
                    dateTime.day == now.day;

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    isToday
                        ? '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}'
                        : '${dateTime.day}/${dateTime.month}\n${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 9),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: _getYAxisInterval(),
            reservedSize: 45,
            getTitlesWidget: (value, meta) {
              // Show decimal for small values (Weight in kg)
              if (_selectedTab == 2 && value < 1) {
                return Text(
                  value.toStringAsFixed(2),
                  style: const TextStyle(fontSize: 10),
                );
              }
              return Text(
                value.toStringAsFixed(0),
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (reversedData.length - 1).toDouble(),
      minY: _getMinY(),
      maxY: _getMaxY(),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.blue,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 3,
                color: Colors.blue,
                strokeWidth: 0,
              );
            },
          ),
          belowBarData: BarAreaData(show: false),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final dataIndex = spot.x.toInt();
              if (dataIndex >= 0 && dataIndex < reversedData.length) {
                final sensorData = reversedData[dataIndex];
                // Show tooltip based on selected tab
                switch (_selectedTab) {
                  case 0: // Temperature
                    return LineTooltipItem(
                      'Temp: ${sensorData.temperature.toStringAsFixed(1)}°C',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  case 1: // Humidity
                    return LineTooltipItem(
                      'Humid: ${sensorData.humidity.toStringAsFixed(1)}%',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  case 2: // Weight
                    return LineTooltipItem(
                      'Weight: ${(sensorData.weight / 1000).toStringAsFixed(2)}kg',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  default:
                    return null;
                }
              }
              return null;
            }).toList();
          },
        ),
      ),
    );
  }
}
