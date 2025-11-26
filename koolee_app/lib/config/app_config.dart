class AppConfig {
  // Supabase Configuration
  // GANTI dengan URL dan Key Supabase Anda
  static const String supabaseUrl = 'https://kxajmamxcgcdhddhdaiq.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt4YWptYW14Y2djZGhkZGhkYWlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM3MDU2ODMsImV4cCI6MjA3OTI4MTY4M30.Vp3oTNunMqsmFv5ai83k-imcIaxA5Y8GE5cfevrnPPU';

  // Firebase Configuration
  // Firebase akan otomatis menggunakan google-services.json (Android)
  // dan GoogleService-Info.plist (iOS)

  // App Settings
  static const int dataRefreshInterval = 500; // milliseconds

  // NOTE: Threshold values (min/max temperature, humidity, weight) are
  // managed in Supabase Edge Function (push-notification/index.ts)
  // to ensure centralized control logic and prevent client-side tampering
}
