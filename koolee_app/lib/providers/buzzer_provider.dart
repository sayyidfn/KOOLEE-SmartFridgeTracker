import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/control_data.dart';
import 'dart:async';

class BuzzerProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();

  bool _isBuzzerActive = false;
  BuzzerMode _buzzerMode = BuzzerMode.auto;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _buzzerSubscription;
  bool _isRealtimeActive = false;

  bool get isBuzzerActive => _isBuzzerActive;
  BuzzerMode get buzzerMode => _buzzerMode;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isRealtimeActive => _isRealtimeActive;

  // Fetch current buzzer status
  Future<void> fetchBuzzerStatus() async {
    try {
      print('[BuzzerProvider] Fetching buzzer status...');
      final controlData = await _supabaseService.getBuzzerStatus();
      if (controlData != null) {
        _isBuzzerActive = controlData.buzzerActive;
        _buzzerMode = controlData.buzzerMode;
        print(
          '[BuzzerProvider] Current status: $_isBuzzerActive, mode: ${_buzzerMode.value}',
        );
      }
      notifyListeners();
    } catch (e) {
      print('[BuzzerProvider ERROR] fetchBuzzerStatus failed: $e');
      _error = e.toString();
      notifyListeners();
    }
  }

  // Start real-time listener for buzzer control changes
  void startRealtimeListener() {
    if (_isRealtimeActive) {
      print('[BuzzerProvider] Realtime already active, skipping...');
      return;
    }

    print('[BuzzerProvider] Starting realtime listener for control table...');

    _buzzerSubscription = _supabaseService.streamBuzzerControl().listen(
      (controlData) {
        if (controlData != null) {
          print(
            '[BuzzerProvider] Realtime update: buzzer = ${controlData.buzzerActive}, mode = ${controlData.buzzerMode.value}',
          );
          _isBuzzerActive = controlData.buzzerActive;
          _buzzerMode = controlData.buzzerMode;
          notifyListeners();
        }
      },
      onError: (error) {
        print('[BuzzerProvider ERROR] Realtime stream error: $error');
        _error = 'Real-time connection error';
        notifyListeners();
      },
    );

    _isRealtimeActive = true;
  }

  // Stop real-time listener
  void stopRealtimeListener() {
    print('[BuzzerProvider] Stopping realtime listener...');
    _buzzerSubscription?.cancel();
    _buzzerSubscription = null;
    _isRealtimeActive = false;
  }

  // Set buzzer mode (Auto/Manual ON/Manual OFF)
  Future<void> setBuzzerMode(BuzzerMode mode) async {
    print('[BuzzerProvider] Setting buzzer mode to: ${mode.value}');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final controlData = await _supabaseService.setBuzzerMode(mode);
      if (controlData != null) {
        _isBuzzerActive = controlData.buzzerActive;
        _buzzerMode = controlData.buzzerMode;
        _error = null;
        print(
          '[BuzzerProvider] Mode set SUCCESS! Mode: ${_buzzerMode.value}, Active: $_isBuzzerActive',
        );
      } else {
        _error = 'Gagal mengubah mode buzzer';
        print('[BuzzerProvider] Mode set FAILED! Error: $_error');
      }
    } catch (e) {
      _error = e.toString();
      print('[BuzzerProvider ERROR] setBuzzerMode exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Legacy method - for backward compatibility
  Future<void> toggleBuzzer(bool value) async {
    final mode = value ? BuzzerMode.manualOn : BuzzerMode.manualOff;
    await setBuzzerMode(mode);
  }

  @override
  void dispose() {
    stopRealtimeListener();
    super.dispose();
  }
}
