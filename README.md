# KOOLEE - Smart Fridge Tracker

## 📖 Deskripsi Project

KOOLEE adalah aplikasi IoT untuk monitoring suhu, kelembaban, dan berat di dalam kulkas secara real-time dengan sistem notifikasi pintar. Project ini merupakan tugas akhir mata kuliah IoT yang mengintegrasikan hardware (ESP32, DHT11, HX711, Buzzer) dengan aplikasi mobile Flutter dan Supabase.

## 🏗️ Arsitektur System

```
┌─────────────────────────────┐
│   ESP32 + WiFi              │
│  ├─ DHT11 (Suhu & Humidity) │
│  ├─ HX711 (Load Cell/Berat) │
│  └─ Buzzer (Alarm)          │
└──────────┬──────────────────┘
           │
           │ POST: Telemetry Data (10s interval)
           │ GET: Control Commands (buzzer status)
           ↓
┌──────────────────────────────┐
│  SUPABASE                    │
│  ├─ PostgreSQL Database      │
│  │  ├─ telemetry (sensor)    │
│  │  ├─ control (buzzer)      │
│  │  └─ notifications (log)   │
│  ├─ Real-time Subscriptions  │
│  └─ Edge Functions           │
│     └─ push-notification     │  ← Logic Center
│        ├─ Check Thresholds   │
│        ├─ Update Buzzer      │
│        ├─ Send FCM           │
│        └─ Save Notification  │
└──────────┬───────────────────┘
           │
           ├─ REST API / Real-time ────→ Flutter App
           │
           └─ FCM via HTTP ─────────→ Firebase
                                      │
                                      ↓
┌──────────────────────────────────────────┐
│  FLUTTER APP (Android)                   │
│  ├─ Dashboard (Real-time monitoring)     │
│  ├─ Fridge Health (Status indicators)    │
│  ├─ Device Status (ESP32 online/offline) │
│  ├─ Buzzer Control (Auto/Manual)         │
│  ├─ Charts & History (Analytics)         │
│  └─ Notifications (Push + History)       │
└──────────────────────────────────────────┘
```

## ✨ Fitur Aplikasi

1. **Dashboard Real-time**

   - Monitor Temperature, Humidity, Weight dengan auto-refresh (500ms)
   - Warning banner untuk kondisi abnormal (multi-sensor detection)
   - Card sensors dengan visual yang clean & modern

2. **Fridge Health Status**

   - Cooling Stability (Excellent/Good/Poor)
   - Humidity Stability (Excellent/Good/Poor)
   - Weight Level (Empty/Low/Medium/High/Overload)
   - Color-coded indicators sinkron dengan threshold

3. **Device Status**

   - ESP32 Online/Offline detection (30s timeout)
   - Last Update timestamp dengan format readable
   - Real-time connection monitoring

4. **Buzzer Control System**

   - **Auto Mode**: Logic di Edge Function (server-side)
   - **Manual ON**: Buzzer nyala paksa
   - **Manual OFF**: Buzzer mati paksa
   - Mode indicator & status sync real-time

5. **Charts & Analytics**

   - Line chart dengan FL Chart (Temperature/Humidity/Weight)
   - Dynamic Y-axis dengan proper scaling
   - Data sampling untuk performance (max 100 points)
   - Date formatting (DD MMM HH:mm)
   - Tooltip dengan sensor info

6. **Push Notifications**

   - Firebase Cloud Messaging integration
   - Auto-notify untuk kondisi abnormal (temp/humidity/weight)
   - Notification history dengan read/unread status
   - Swipe to delete, tap to mark as read
   - Time ago format (5m ago, 2h ago, etc)

7. **History Page** (Coming Soon)
   - Filter by date range
   - Export data
   - Statistics & trends

## 🛠️ Teknologi Stack

### Hardware

- **ESP32** (WiFi Microcontroller)
- **DHT11** (Temperature & Humidity Sensor)
- **HX711** + Load Cell 5kg (Weight Sensor)
- **Buzzer** (Active Buzzer 5V)

### Backend

- **Supabase** (PostgreSQL Database + Real-time + Edge Functions)
- **Firebase** (Cloud Messaging untuk Push Notifications)
- **Deno** (Runtime untuk Edge Functions)

### Frontend

- **Flutter** 3.35.7 (Framework)
- **Dart** ^3.9.2 (Language)
- **Provider** ^6.1.2 (State Management)
- **FL Chart** ^0.69.2 (Data Visualization)
- **Supabase Flutter** ^2.8.0 (Database Client)
- **Firebase Core** ^3.8.1 (Firebase SDK)
- **Firebase Messaging** ^15.1.5 (Push Notifications)
- **Intl** ^0.20.1 (Date Formatting)
- **HTTP** ^1.2.2 (HTTP Requests)
- **Shared Preferences** ^2.3.4 (Local Storage)

## 🚀 Quick Start

```bash
# 1. Clone repository
git clone https://github.com/yourusername/KOOLEE-SmartFridgeTracker.git
cd KOOLEE-SmartFridgeTracker

# 2. Setup credentials (IMPORTANT!)
# Follow the detailed guide in CREDENTIALS_SETUP.md
# - Firebase: google-services.json & service-account.json
# - Supabase: Update app_config.dart
# - ESP32: Update WiFi & Supabase credentials

# 3. Install Flutter dependencies
cd koolee_app
flutter pub get

# 4. Setup Supabase
# - Create Supabase project at https://supabase.com
# - Run koolee_db.sql in SQL Editor to create tables
# - Deploy Edge Function: cd ../supabase && supabase functions deploy push-notification

# 5. Setup Firebase
# - Create Firebase project at https://console.firebase.google.com
# - Enable Cloud Messaging
# - Download credential files (see CREDENTIALS_SETUP.md)

# 6. Upload ESP32 firmware
# - Open koolee_esp32/koolee_esp32.ino in Arduino IDE
# - Update credentials (WiFi, Supabase)
# - Upload to ESP32

# 7. Run aplikasi
flutter run
```

> ⚠️ **Important**: Make sure to follow [CREDENTIALS_SETUP.md](CREDENTIALS_SETUP.md) for detailed credential configuration before running the app.

## 📊 Database Schema

Schema lengkap tersedia di `koolee_db.sql`. Berikut ringkasannya:

### Tables

**1. telemetry** - Sensor Data Storage

```sql
CREATE TABLE telemetry (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()) NOT NULL,
  temperature FLOAT NOT NULL,       -- Temperature in Celsius from DHT11
  humidity FLOAT NOT NULL,          -- Relative humidity % from DHT11
  weight FLOAT NOT NULL             -- Weight in grams from HX711 load cell
);
```

- Update Frequency: Every 10 seconds from ESP32
- Index: `idx_telemetry_created_at` untuk query performance

**2. control** - Buzzer Control

```sql
CREATE TABLE control (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  buzzer_active BOOLEAN DEFAULT false NOT NULL,
  buzzer_mode VARCHAR(20) DEFAULT 'auto' NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()) NOT NULL,
  CONSTRAINT buzzer_mode_check CHECK (buzzer_mode IN ('auto', 'manual_on', 'manual_off'))
);
```

- Modes: `auto` (Edge Function control), `manual_on`, `manual_off`
- Access: ESP32 reads every 10s, Flutter app updates, Edge Function updates

**3. notifications** - Push Notification History

```sql
CREATE TABLE notifications (
  id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB DEFAULT '{}',
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()) NOT NULL
);
```

- Index: `idx_notifications_created_at` untuk sorting
- Stores all sent notifications untuk history display

### Database Setup

1. **Import Schema**: Run `koolee_db.sql` di Supabase SQL Editor
2. **Setup Webhook**: Configure Database Webhook untuk trigger Edge Function
   - Table: `telemetry`
   - Event: `INSERT`
   - Target: Edge Function `push-notification`
3. **Enable Real-time**: Enable real-time subscriptions untuk:
   - `telemetry` (untuk dashboard auto-update)
   - `control` (untuk buzzer status sync)
   - `notifications` (untuk notification list)

## 🔔 Logic Control System

### Threshold Detection (Edge Function)

**Temperature**: 27-32°C

- < 27°C atau > 32°C → **Abnormal** → Buzzer ON (auto mode)

**Humidity**: 60-80%

- < 60% atau > 80% → **Abnormal** → Buzzer ON (auto mode)

**Weight**: 5-7000g

- < 5g (Empty) atau > 7000g (Overload) → **Abnormal** → Buzzer ON (auto mode)

### Auto Control Flow

```
1. ESP32 → POST data ke Supabase telemetry (tiap 10s)
2. Database Trigger → Call Edge Function (push-notification)
3. Edge Function:
   ├─ Check thresholds (temp/humidity/weight)
   ├─ IF abnormal & mode=auto:
   │  ├─ Update control.buzzer_active = true
   │  ├─ Send FCM notification
   │  └─ Save to notifications table
   └─ IF normal & mode=auto:
      └─ Update control.buzzer_active = false
4. ESP32 → GET control status → Update buzzer hardware
5. Flutter → Real-time subscribe → Update UI
```

### Manual Override

- **Manual ON**: Buzzer tetap nyala meski kondisi normal
- **Manual OFF**: Buzzer tetap mati meski kondisi abnormal
- Edge Function skip auto-control jika mode != 'auto'

## 🛠️ Development Commands

### Flutter App

```bash
# Navigate to Flutter directory
cd koolee_app

# Install dependencies
flutter pub get

# Run in debug mode
flutter run

# Hot reload (during development)
# Press 'r' in terminal or use Lightning button in VS Code

# Check for errors
flutter analyze

# Format code
flutter format .

# Clean build files
flutter clean

# Build APK for Android
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Run tests
flutter test
```

### Supabase Edge Function

```bash
# Navigate to Supabase directory
cd supabase

# Deploy Edge Function
supabase functions deploy push-notification --no-verify-jwt

# View Edge Function logs
supabase functions logs push-notification --follow

# Test Edge Function locally (optional)
supabase functions serve push-notification
```

### ESP32

```bash
# Open Arduino IDE
# File > Open > koolee_esp32/koolee_esp32.ino

# Install Required Libraries:
# - WiFi (built-in)
# - HTTPClient (built-in)
# - ArduinoJson (by Benoit Blanchon)
# - HX711 Arduino Library (by Bogdan Necula)
# - DHT sensor library (by Adafruit)

# Edit WiFi & Supabase credentials
# Upload to ESP32
```

## 📱 Supported Platforms

- ✅ **Android** (Tested on Samsung SM A556E)
- ⏳ **iOS** (Code ready, not tested yet)
- ⚠️ **Web** (Basic functionality works, Firebase Messaging requires additional setup)
- ⚠️ **Windows/macOS/Linux** (Desktop platforms - Push notifications not available, other features should work)

## 📝 Configuration & Constants

### App Config (`koolee_app/lib/config/app_config.dart`)

```dart
- supabaseUrl: 'https://kxajmamxcgcdhddhdaiq.supabase.co'
- supabaseAnonKey: 'your-anon-key-here'
- dataRefreshInterval: 500 ms (UI refresh untuk real-time dashboard)
```

### Threshold (Defined in Edge Function)

```typescript
// File: supabase/functions/push-notification/index.ts
TEMP_MIN = 27.0°C
TEMP_MAX = 32.0°C
HUMIDITY_MIN = 60.0%
HUMIDITY_MAX = 80.0%
WEIGHT_MIN = 5.0g
WEIGHT_MAX = 7000.0g (7kg)
```

**Note**: Edit threshold values di Edge Function, bukan di app atau ESP32

### ESP32 Config (`koolee_esp32/koolee_esp32.ino`)

```cpp
- WiFi SSID & Password
- Supabase URL & API Key
- Sensor Pins: DHT(17), HX711(16,4), Buzzer(5)
- Update Interval: 10 detik
- Calibration Factor: 19000.0
```

### Timing

- ESP32 send data: **10 seconds**
- Flutter UI refresh: **500 milliseconds**
- ESP32 online timeout: **30 seconds**
- Chart max points: **100 data points**

## ⚙️ Setup Requirements

1. **Supabase Project**

   - Create tables: telemetry, control, notifications
   - Setup webhook untuk Edge Function
   - Enable real-time subscriptions
   - Deploy Edge Function: `supabase functions deploy push-notification`

2. **Firebase Project**

   - Enable Cloud Messaging
   - Download `google-services.json` → `android/app/`
   - Download `service-account.json` untuk Edge Function
   - Subscribe app to topic "all"

3. **ESP32 Hardware**

   - WiFi connection
   - DHT11 connected to pin 17
   - HX711 connected to pins 16 (DOUT), 4 (SCK)
   - Buzzer connected to pin 5
   - Calibrate load cell (tare + calibration_factor)

4. **Flutter App**
   - Navigate to `koolee_app/` directory
   - Update `lib/config/app_config.dart` dengan Supabase credentials
   - Run `flutter pub get`
   - Build & install ke Android device dengan `flutter run`

## 🐛 Troubleshooting

### ESP32 tidak kirim data

- Cek WiFi credentials di `.ino`
- Cek Serial Monitor untuk error logs
- Pastikan Supabase URL & API Key benar

### Notifikasi tidak muncul

- Cek Firebase `google-services.json` di `android/app/`
- Pastikan app subscribe ke topic "all"
- Cek Edge Function logs: `supabase functions logs push-notification`
- Pastikan tabel `notifications` sudah dibuat

### Chart tidak muncul/error

- Cek data di tabel `telemetry` minimal 2 records
- Cek console logs untuk parsing errors
- Pastikan timestamp format ISO8601

### Buzzer tidak respon

- Cek mode di app (harus Auto untuk logic otomatis)
- Cek Edge Function apakah triggered
- Cek ESP32 interval GET control (tiap 10s)
- Test manual ON/OFF di app

### Real-time tidak update

- Cek Supabase real-time enabled
- Pastikan RLS policies allow read
- Restart app jika stuck

## 📂 Project Structure

```
KOOLEE-SmartFridgeTracker/
├── koolee_app/                       # Flutter Application
│   ├── lib/
│   │   ├── config/
│   │   │   ├── app_config.dart          # Supabase credentials
│   │   │   └── firebase_options.dart     # Firebase config (auto-generated)
│   │   ├── models/
│   │   │   ├── sensor_data.dart          # Temperature, humidity, weight model
│   │   │   └── control_data.dart         # Buzzer control model
│   │   ├── providers/
│   │   │   ├── sensor_provider.dart      # State management untuk sensor data
│   │   │   └── buzzer_provider.dart      # State management untuk buzzer control
│   │   ├── screens/
│   │   │   ├── dashboard_screen.dart     # Main dashboard
│   │   │   └── notification_screen.dart  # Push notification history
│   │   ├── services/
│   │   │   ├── supabase_service.dart              # Database operations
│   │   │   └── firebase_notification_service.dart # FCM integration
│   │   ├── widgets/
│   │   │   ├── temperature_card.dart     # Temperature display widget
│   │   │   ├── humidity_card.dart        # Humidity display widget
│   │   │   ├── weight_card.dart          # Weight display widget
│   │   │   ├── chart_widget.dart         # FL Chart implementation
│   │   │   ├── fridge_health_widget.dart # Health status indicators
│   │   │   ├── device_status_widget.dart # ESP32 online/offline
│   │   │   ├── buzzer_alert_section.dart # Buzzer control buttons
│   │   │   └── warning_banner.dart       # Abnormal condition banner
│   │   └── main.dart                     # App entry point
│   ├── android/
│   │   └── app/
│   │       ├── build.gradle.kts          # Android config
│   │       ├── google-services.json      # Firebase credentials
│   │       └── src/main/AndroidManifest.xml
│   ├── pubspec.yaml                      # Flutter dependencies
│   └── analysis_options.yaml
│
├── koolee_esp32/                     # ESP32 Firmware
│   └── koolee_esp32.ino              # Main Arduino sketch
│
├── supabase/                         # Supabase Backend
│   ├── config.toml                   # Supabase config
│   └── functions/
│       └── push-notification/
│           └── index.ts              # Edge Function (Logic Center)
│
├── google-services.json              # Firebase credentials (root)
├── service-account.json              # Firebase service account
├── koolee_db.sql                     # Database schema & migration
└── README.md                         # This file
```

## 🎯 Testing Checklist

### Hardware Testing

- [ ] ESP32 connects to WiFi
- [ ] DHT11 reads temperature & humidity correctly
- [ ] HX711 load cell reads weight accurately (calibration done)
- [ ] Buzzer responds to control commands
- [ ] Data sent to Supabase every 10 seconds
- [ ] ESP32 reads control status every 10 seconds

### Backend Testing

- [ ] Supabase tables created successfully
- [ ] Telemetry data stored in database
- [ ] Edge Function triggers on INSERT
- [ ] Edge Function detects threshold violations
- [ ] Control table updates correctly (auto mode)
- [ ] Notifications saved to database
- [ ] Real-time subscriptions work

### Frontend Testing

- [ ] Flutter app connects to Supabase
- [ ] Dashboard shows real-time sensor data
- [ ] Charts display historical data
- [ ] Device status shows online/offline correctly
- [ ] Manual buzzer control works (ON/OFF)
- [ ] Auto mode respects Edge Function logic
- [ ] Push notifications received on Android
- [ ] Notification history displays correctly
- [ ] Warning banner shows for abnormal conditions

### Integration Testing

- [ ] End-to-end flow: ESP32 → Supabase → Flutter
- [ ] Push notification flow: Threshold → Edge Function → FCM → Android
- [ ] Manual override: Flutter → Supabase → ESP32 → Buzzer

## 👥 Team

Project ini dibuat sebagai Tugas Akhir mata kuliah IoT

## 📄 License

Educational purposes only - Project Akhir IoT

---

**KOOLEE** - Keep Cool, Stay Smart! 🧊📱
