import 'package:flutter/material.dart';
import '../models/sensor_data.dart';
import '../services/supabase_service.dart';
import 'dart:async';

class SensorProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  SensorData? _latestData;
  List<SensorData> _historyData = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _realtimeSubscription;

  SensorData? get latestData => _latestData;
  List<SensorData> get historyData => _historyData;
  Map<String, dynamic> get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Start realtime updates
  void startRealtimeUpdates() {
    // Cancel existing subscription
    _realtimeSubscription?.cancel();

    // Subscribe to realtime updates
    _realtimeSubscription = _supabaseService.streamSensorData().listen(
      (data) {
        if (data != null) {
          _latestData = data;
          notifyListeners();
        }
      },
      onError: (error) {
        _error = error.toString();
        notifyListeners();
      },
    );

    // Initial data fetch
    refreshData();
  }

  // Stop realtime updates
  void stopRealtimeUpdates() {
    _realtimeSubscription?.cancel();
  }

  // Refresh all data
  Future<void> refreshData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch latest data
      final latest = await _supabaseService.getLatestSensorData();
      if (latest != null) {
        _latestData = latest;
      }

      // Fetch history (last 7 days to ensure we get data)
      final now = DateTime.now();
      final lastWeek = now.subtract(const Duration(days: 7));
      _historyData = await _supabaseService.getSensorHistory(
        startDate: lastWeek,
        endDate: now,
        limit: 500, // Get more data for better chart
      );

      print(
        '[SensorProvider] History data fetched: ${_historyData.length} items',
      );
      if (_historyData.isEmpty) {
        print('[SensorProvider] No history data available from Supabase');
      }

      // Fetch statistics
      _statistics = await _supabaseService.getStatistics(
        startDate: lastWeek,
        endDate: now,
      );

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch history with custom date range
  Future<void> fetchHistory({DateTime? startDate, DateTime? endDate}) async {
    try {
      _historyData = await _supabaseService.getSensorHistory(
        startDate: startDate,
        endDate: endDate,
        limit: 1000,
      );
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }
}
