# Setup Instructions for Credentials

## Required Credential Files

This project requires several credential files that are NOT included in the repository for security reasons. Follow these steps to set them up:

### 1. Firebase Credentials

#### `google-services.json`
- **Location**: 
  - `koolee_app/android/app/google-services.json`
  - Also copy to root: `google-services.json`
- **How to get**:
  1. Go to [Firebase Console](https://console.firebase.google.com/)
  2. Create or select your project
  3. Go to Project Settings > General
  4. Under "Your apps" section, click Android app
  5. Download `google-services.json`
  6. Place it in both locations mentioned above

#### `firebase_options.dart`
- **Location**: `koolee_app/lib/config/firebase_options.dart`
- **How to generate**:
  1. Install FlutterFire CLI: `dart pub global activate flutterfire_cli`
  2. Login to Firebase: `flutterfire configure`
  3. Select your Firebase project
  4. This will automatically generate `firebase_options.dart`
- **Alternative**: Copy `firebase_options.dart.example` to `firebase_options.dart` and fill in your credentials

#### `service-account.json`
- **Location**: `service-account.json` (root directory)
- **How to get**:
  1. Go to Firebase Console > Project Settings > Service Accounts
  2. Click "Generate new private key"
  3. Download the JSON file and rename it to `service-account.json`
  4. Place it in the root directory
- **Used for**: Edge Function to send push notifications

### 2. Supabase Configuration

#### Update `koolee_app/lib/config/app_config.dart`
```dart
class AppConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';
  // ... rest of the config
}
```

- **How to get**:
  1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
  2. Select your project
  3. Go to Settings > API
  4. Copy `Project URL` and `anon public` key

### 3. ESP32 Configuration

#### Update `koolee_esp32/koolee_esp32.ino`
```cpp
// WiFi credentials
const char* ssid = "YOUR_WIFI_SSID";
const char* password = "YOUR_WIFI_PASSWORD";

// Supabase credentials
const char* SUPABASE_URL = "YOUR_SUPABASE_URL";
const char* SUPABASE_KEY = "YOUR_SUPABASE_ANON_KEY";
```

### 4. Verify Setup

After adding all credentials, verify:
- [ ] `google-services.json` exists in `koolee_app/android/app/`
- [ ] `firebase_options.dart` exists in `koolee_app/lib/config/`
- [ ] `service-account.json` exists in root directory
- [ ] Supabase credentials updated in `app_config.dart`
- [ ] WiFi and Supabase credentials updated in ESP32 sketch
- [ ] Run `flutter pub get` to install dependencies
- [ ] Build and test the app

## Security Note

⚠️ **NEVER commit these credential files to version control!**

The `.gitignore` file is already configured to exclude these files:
- `google-services.json`
- `service-account.json`
- `firebase_options.dart`
- `local.properties`

## Regenerating Firebase Options

If you need to regenerate `firebase_options.dart`:

```bash
# Install FlutterFire CLI (if not installed)
dart pub global activate flutterfire_cli

# Navigate to Flutter app directory
cd koolee_app

# Configure Firebase (will regenerate firebase_options.dart)
flutterfire configure
```

This will create a new `firebase_options.dart` file with your Firebase credentials.
