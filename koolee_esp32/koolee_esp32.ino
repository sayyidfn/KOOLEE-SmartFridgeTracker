#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include "HX711.h"
#include "DHT.h"

// ==================================================================================
// 🔧 KONFIGURASI (DUMB NODE VERSION)
// ==================================================================================

// 1. WIFI 
const char* ssid = "UPNYK-Dosen"; // GANTI DENGAN WIFI KAMU
const char* password = "dos2021*#"; // GANTI PASSWORD

// 2. SUPABASE
const char* supabase_url = "https://kxajmamxcgcdhddhdaiq.supabase.co/rest/v1";
const char* supabase_key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt4YWptYW14Y2djZGhkZGhkYWlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM3MDU2ODMsImV4cCI6MjA3OTI4MTY4M30.Vp3oTNunMqsmFv5ai83k-imcIaxA5Y8GE5cfevrnPPU";

// 3. PIN
const int LOADCELL_DOUT_PIN = 16;
const int LOADCELL_SCK_PIN = 4;
const int DHT_PIN = 17; 
const int BUZZER_PIN = 5;

// 4. KALIBRASI
float calibration_factor = 15000.0; // Sesuaikan jika perlu

// ==================================================================================

#define DHTTYPE DHT11
HX711 scale;
DHT dht(DHT_PIN, DHTTYPE);

float last_weight_g = 0;
float last_temp = 0;
float last_hum = 0;
unsigned long last_loop_time = 0;

void setup() {
  Serial.begin(115200);
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW); 

  dht.begin();
  scale.begin(LOADCELL_DOUT_PIN, LOADCELL_SCK_PIN);
  scale.set_scale(calibration_factor);
  scale.tare(); 

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500); Serial.print(".");
  }
  Serial.println("\nWiFi Connected!");
  digitalWrite(BUZZER_PIN, HIGH); delay(100); digitalWrite(BUZZER_PIN, LOW);
}

void loop() {
  if (millis() - last_loop_time >= 10000) { // TIAP 10 DETIK
    last_loop_time = millis();

    // 1. BACA SENSOR
    if (scale.is_ready()) {
      float w_kg = scale.get_units(1); 
      last_weight_g = w_kg * 1000.0;
      if (last_weight_g < 2.0) last_weight_g = 0; 
    }
    float h = dht.readHumidity();
    float t = dht.readTemperature();
    if (!isnan(h) && !isnan(t)) { last_hum = h; last_temp = t; }

    Serial.print("DATA >> T:"); Serial.print(last_temp);
    Serial.print("| H:"); Serial.print(last_hum);
    Serial.print(" W:"); Serial.println(last_weight_g);

    if (WiFi.status() == WL_CONNECTED) {
      HTTPClient http;
      
      // KIRIM DATA (POST)
      http.begin(String(supabase_url) + "/telemetry");
      http.addHeader("Content-Type", "application/json");
      http.addHeader("apikey", supabase_key);
      http.addHeader("Authorization", String("Bearer ") + supabase_key);
      http.addHeader("Prefer", "return=minimal"); 
      
      StaticJsonDocument<200> doc;
      doc["temperature"] = last_temp;
      doc["humidity"] = last_hum;
      doc["weight"] = last_weight_g;
      String json; serializeJson(doc, json);
      http.POST(json);
      http.end();

      // AMBIL PERINTAH (GET)
      http.begin(String(supabase_url) + "/control?id=eq.1&select=buzzer_active");
      http.addHeader("apikey", supabase_key);
      http.addHeader("Authorization", String("Bearer ") + supabase_key);
      if (http.GET() > 0) {
        String payload = http.getString();
        StaticJsonDocument<200> doc2;
        deserializeJson(doc2, payload);
        bool buzz = doc2[0]["buzzer_active"];
        digitalWrite(BUZZER_PIN, buzz ? HIGH : LOW);
        Serial.println(buzz ? "   [CMD] BUZZER ON" : "   [CMD] BUZZER OFF");
      }
      http.end();
    }
  }
  delay(50);
}