import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sensor_data.dart';
import '../models/control_data.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  // Initialize Supabase
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  }

  // Get latest sensor data
  Future<SensorData?> getLatestSensorData() async {
    try {
      print('[SupabaseService] Fetching latest sensor data...');
      final response = await client
          .from('telemetry')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) {
        print('[SupabaseService] No data found');
        return null;
      }

      print('[SupabaseService] Latest data fetched: $response');
      return SensorData.fromJson(response);
    } catch (e) {
      print('[SupabaseService] Error getting latest data: $e');
      print('Error getting latest sensor data: $e');
      return null;
    }
  }

  // Get sensor data history with time range
  Future<List<SensorData>> getSensorHistory({
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) async {
    try {
      print('[SupabaseService] Fetching sensor history...');
      print('[SupabaseService] Start date: $startDate');
      print('[SupabaseService] End date: $endDate');
      print('[SupabaseService] Limit: $limit');

      var query = client.from('telemetry').select();

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query
          .order('created_at', ascending: false)
          .limit(limit);

      print('[SupabaseService] Raw response type: ${response.runtimeType}');
      print(
        '[SupabaseService] History response count: ${(response as List).length}',
      );

      final dataList = (response as List)
          .map((item) {
            try {
              return SensorData.fromJson(item as Map<String, dynamic>);
            } catch (e) {
              print('[SupabaseService] Error parsing item: $e');
              return null;
            }
          })
          .whereType<SensorData>()
          .toList();

      print('[SupabaseService] Parsed ${dataList.length} history records');
      return dataList;
    } catch (e) {
      print('[SupabaseService] Error getting sensor history: $e');
      return [];
    }
  }

  // Stream real-time sensor data
  Stream<SensorData?> streamSensorData() {
    print('[SupabaseService] Starting real-time stream for telemetry');
    return client
        .from('telemetry')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(1)
        .map((data) {
          if (data.isEmpty) {
            print('[SupabaseService] Stream data is empty');
            return null;
          }
          print('[SupabaseService] Stream update received: ${data.first}');
          return SensorData.fromJson(data.first);
        });
  }

  // Get buzzer control status
  Future<ControlData?> getBuzzerStatus() async {
    try {
      print('[DEBUG] Fetching buzzer status from control table...');
      final response = await client
          .from('control')
          .select()
          .eq('id', 1)
          .maybeSingle();

      if (response == null) {
        print(
          '[DEBUG] No control row found with id=1. Creating default row...',
        );
        // Jika belum ada row, buat row baru dengan id=1
        await client.from('control').insert({'id': 1, 'buzzer_active': false});
        return ControlData(id: '1', buzzerActive: false);
      }

      final controlData = ControlData.fromJson(response);
      print('[DEBUG] Buzzer status from DB: ${controlData.buzzerActive}');
      return controlData;
    } catch (e) {
      print('[ERROR] Error getting buzzer status: $e');
      return null;
    }
  }

  // Set buzzer mode (auto, manual_on, manual_off)
  Future<ControlData?> setBuzzerMode(BuzzerMode mode) async {
    try {
      print('[DEBUG] Setting buzzer mode to: ${mode.value}');

      // Tentukan buzzer_active berdasarkan mode
      final bool buzzerActive;
      switch (mode) {
        case BuzzerMode.manualOn:
          buzzerActive = true;
          break;
        case BuzzerMode.manualOff:
          buzzerActive = false;
          break;
        case BuzzerMode.auto:
          // Untuk auto, biarkan sistem yang tentukan
          // Ambil status terakhir dari database
          final current = await getBuzzerStatus();
          buzzerActive = current?.buzzerActive ?? false;
          break;
      }

      // Cek dulu apakah row dengan id=1 ada
      final existing = await client
          .from('control')
          .select()
          .eq('id', 1)
          .maybeSingle();

      final payload = {
        'buzzer_mode': mode.value,
        'buzzer_active': buzzerActive,
      };

      if (existing == null) {
        // Jika belum ada, insert row baru
        print('[DEBUG] Control row not found, inserting new row...');
        await client.from('control').insert({'id': 1, ...payload});
      } else {
        // Jika sudah ada, update
        print('[DEBUG] Updating existing control row...');
        await client.from('control').update(payload).eq('id', 1);
      }

      // Verifikasi update berhasil
      final verification = await client
          .from('control')
          .select()
          .eq('id', 1)
          .single();

      final controlData = ControlData.fromJson(verification);
      print(
        '[DEBUG] Verified - Mode: ${controlData.buzzerMode.value}, Active: ${controlData.buzzerActive}',
      );

      if (controlData.buzzerMode == mode) {
        print('[SUCCESS] Buzzer mode successfully set to: ${mode.value}');
        return controlData;
      } else {
        print(
          '[ERROR] Verification failed! Expected: ${mode.value}, Got: ${controlData.buzzerMode.value}',
        );
        return null;
      }
    } catch (e) {
      print('[ERROR] Error setting buzzer mode: $e');
      return null;
    }
  }

  // Legacy method - for backward compatibility
  Future<ControlData?> setBuzzerStatus(bool status) async {
    // Convert boolean to mode
    final mode = status ? BuzzerMode.manualOn : BuzzerMode.manualOff;
    return setBuzzerMode(mode);
  }

  // Stream real-time buzzer control changes
  Stream<ControlData?> streamBuzzerControl() {
    return client.from('control').stream(primaryKey: ['id']).eq('id', 1).map((
      data,
    ) {
      if (data.isEmpty) return null;
      try {
        return ControlData.fromJson(data.first);
      } catch (e) {
        print('[ERROR] Error parsing control data: $e');
        return null;
      }
    });
  }

  // Get statistics
  Future<Map<String, dynamic>> getStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final data = await getSensorHistory(
        startDate: startDate,
        endDate: endDate,
        limit: 1000,
      );

      if (data.isEmpty) {
        return {
          'avgTemperature': 0.0,
          'avgWeight': 0.0,
          'minTemperature': 0.0,
          'maxTemperature': 0.0,
          'minWeight': 0.0,
          'maxWeight': 0.0,
        };
      }

      final temperatures = data.map((d) => d.temperature).toList();
      final weights = data.map((d) => d.weight).toList();

      return {
        'avgTemperature':
            temperatures.reduce((a, b) => a + b) / temperatures.length,
        'avgWeight': weights.reduce((a, b) => a + b) / weights.length,
        'minTemperature': temperatures.reduce((a, b) => a < b ? a : b),
        'maxTemperature': temperatures.reduce((a, b) => a > b ? a : b),
        'minWeight': weights.reduce((a, b) => a < b ? a : b),
        'maxWeight': weights.reduce((a, b) => a > b ? a : b),
      };
    } catch (e) {
      print('Error getting statistics: $e');
      return {};
    }
  }

  // Insert test data (for development)
  Future<bool> insertSensorData({
    required double temperature,
    required double weight,
    double humidity = 50.0,
  }) async {
    try {
      await client.from('telemetry').insert({
        'temperature': temperature,
        'humidity': humidity,
        'weight': weight,
      });
      return true;
    } catch (e) {
      print('Error inserting sensor data: $e');
      return false;
    }
  }
}
