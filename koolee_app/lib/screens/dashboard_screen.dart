import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:provider/provider.dart';
import '../providers/sensor_provider.dart';
import '../providers/buzzer_provider.dart';
import '../services/firebase_notification_service.dart';
import '../widgets/temperature_card.dart';
import '../widgets/weight_card.dart';
import '../widgets/humidity_card.dart';
import '../widgets/chart_widget.dart';
import '../widgets/warning_banner.dart';
import '../widgets/buzzer_alert_section.dart';
import '../widgets/fridge_health_widget.dart';
import '../widgets/device_status_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Start fetching data and real-time updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<SensorProvider>().startRealtimeUpdates();
      } catch (e) {
        print('[Dashboard] Error starting sensor updates: $e');
      }

      try {
        context.read<BuzzerProvider>().fetchBuzzerStatus();
        context.read<BuzzerProvider>().startRealtimeListener();
      } catch (e) {
        print('[Dashboard] Error starting buzzer updates: $e');
      }

      _setupNotifications();
    });
  }

  // Setup Firebase notifications (skip for desktop)
  Future<void> _setupNotifications() async {
    // Skip notification setup for desktop platforms
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      print('[Notification] Skipped - Desktop platform');
      return;
    }

    try {
      final notificationService = FirebaseNotificationService();
      await notificationService.initialize();
      await notificationService.subscribeToTopic('all');
      print('[Notification] ✅ Subscribed to topic: all');
    } catch (e) {
      print('[Notification] ❌ Setup failed: $e');
    }
  }

  @override
  void dispose() {
    context.read<BuzzerProvider>().stopRealtimeListener();
    super.dispose();
  }

  // Check if any conditions are abnormal (same threshold as edge function)
  bool _hasAbnormalConditions(data) {
    final temp = data.temperature;
    final humidity = data.humidity;
    final weight = data.weight;

    // Threshold sesuai Edge Function
    const tempMin = 0.0;
    const tempMax = 32.0;
    const humidityMin = 60.0;
    const humidityMax = 80.0;
    const weightMin = 20.0;
    const weightMax = 7000.0;

    return (temp < tempMin || temp > tempMax) ||
        (humidity < humidityMin || humidity > humidityMax) ||
        (weight < weightMin || weight > weightMax);
  }

  String _getWarningTitle(data) {
    final problems = <String>[];

    if (data.temperature < 27.0 || data.temperature > 32.0) {
      problems.add('Temperature');
    }
    if (data.humidity < 60.0 || data.humidity > 80.0) {
      problems.add('Humidity');
    }
    if (data.weight < 20.0) {
      problems.add('Weight');
    } else if (data.weight > 7000.0) {
      problems.add('Overload');
    }

    if (problems.isEmpty) return 'Fridge Alert';

    if (problems.length == 1) {
      if (problems[0] == 'Weight') return 'Your fridge is nearly empty';
      if (problems[0] == 'Overload') return 'Your fridge is overloaded';
      if (problems[0] == 'Temperature') return 'Temperature abnormal detected';
      if (problems[0] == 'Humidity') return 'Humidity level abnormal';
    }

    return '⚠️ Multiple issues detected';
  }

  String _getWarningSubtitle(data) {
    final problems = <String>[];

    if (data.temperature < 0.0) {
      problems.add('Temp too low (${data.temperature.toStringAsFixed(1)}°C)');
    } else if (data.temperature > 32.0) {
      problems.add('Temp too high (${data.temperature.toStringAsFixed(1)}°C)');
    }

    if (data.humidity < 60.0) {
      problems.add('Humidity low (${data.humidity.toStringAsFixed(0)}%)');
    } else if (data.humidity > 80.0) {
      problems.add('Humidity high (${data.humidity.toStringAsFixed(0)}%)');
    }

    if (data.weight < 20.0) {
      problems.add('Please place items inside');
    } else if (data.weight > 7000.0) {
      problems.add('Exceeded ${(data.weight / 1000).toStringAsFixed(1)}kg');
    }

    if (problems.isEmpty) return 'Please check your fridge';
    if (problems.length == 1) return problems[0];

    return problems.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildDashboard());
  }

  Widget _buildDashboard() {
    return Consumer<SensorProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.latestData == null) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade400, Colors.blue.shade700],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (provider.error != null) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade400, Colors.blue.shade700],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${provider.error}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.refreshData(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final data = provider.latestData;
        if (data == null) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade400, Colors.blue.shade700],
              ),
            ),
            child: const Center(
              child: Text(
                'No data available',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        return Container(
          decoration: const BoxDecoration(color: Color(0xFFF5F7FA)),
          child: RefreshIndicator(
            onRefresh: () => provider.refreshData(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header dengan background berwarna
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                    decoration: const BoxDecoration(
                      color: Color(0xFF3B82F6),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'KOOLEE',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Smart Fridge Tracker',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () {
                                Navigator.pushNamed(context, '/notifications');
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Sensor Cards Row
                        Row(
                          children: [
                            Expanded(
                              child: TemperatureCard(
                                temperature: data.temperature,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: HumidityCard(humidity: data.humidity),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: WeightCard(weight: data.weight)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Content dengan padding
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 0),

                        // Warning Banner (conditional) - Check all abnormal conditions
                        if (_hasAbnormalConditions(data)) ...[
                          WarningBanner(
                            title: _getWarningTitle(data),
                            subtitle: _getWarningSubtitle(data),
                            onTap: () {},
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Buzzer Alerts Section
                        Consumer<BuzzerProvider>(
                          builder: (context, buzzerProvider, child) {
                            return BuzzerAlertSection(
                              currentMode: buzzerProvider.buzzerMode,
                              onModeChanged: (mode) {
                                buzzerProvider.setBuzzerMode(mode);
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Sensor History Chart
                        Container(
                          width: double.infinity,
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
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'History',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111827),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  Text(
                                    '${provider.historyData.length} records',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade600,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (provider.historyData.isNotEmpty)
                                ChartWidget(data: provider.historyData)
                              else
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.analytics_outlined,
                                          size: 48,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'No history data',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Data will appear as sensors send readings',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade500,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Fridge Health
                        FridgeHealthWidget(
                          temperature: data.temperature,
                          humidity: data.humidity,
                          weight: data.weight,
                        ),

                        const SizedBox(height: 16),

                        // Device Status
                        DeviceStatusWidget(lastUpdate: data.timestamp),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
