#include "HX711.h"
#include "DHT.h"

// --- KONFIGURASI PIN (Sesuai Rakitan Tadi) ---
const int LOADCELL_DOUT_PIN = 16;
const int LOADCELL_SCK_PIN = 4;
const int DHT_PIN = 17;
const int BUZZER_PIN = 5;

#define DHTTYPE DHT11

HX711 scale;
DHT dht(DHT_PIN, DHTTYPE);

void setup() {
  Serial.begin(115200);
  Serial.println("\n\n--- MULAI TES HARDWARE & KALIBRASI ---");

  // 1. TES BUZZER
  pinMode(BUZZER_PIN, OUTPUT);
  Serial.println("1. Cek Buzzer... (Harus bunyi bip-bip)");
  digitalWrite(BUZZER_PIN, HIGH); delay(100);
  digitalWrite(BUZZER_PIN, LOW);  delay(100);
  digitalWrite(BUZZER_PIN, HIGH); delay(100);
  digitalWrite(BUZZER_PIN, LOW);

  // 2. TES DHT11
  dht.begin();
  Serial.println("2. Cek Sensor Suhu DHT11...");
  delay(2000); // DHT butuh waktu warm up
  float h = dht.readHumidity();
  float t = dht.readTemperature();
  if (isnan(h) || isnan(t)) {
    Serial.println("   [BAHAYA] Gagal baca DHT11! Periksa kabel GPIO 17!");
  } else {
    Serial.print("   [OK] Suhu: "); Serial.print(t);
    Serial.print(" C, Kelembaban: "); Serial.print(h); Serial.println(" %");
  }

  // 3. TES LOAD CELL
  Serial.println("3. Cek Load Cell (HX711)...");
  scale.begin(LOADCELL_DOUT_PIN, LOADCELL_SCK_PIN);
  
  if (scale.wait_ready_timeout(1000)) {
      Serial.println("   [OK] HX711 terdeteksi.");
  } else {
      Serial.println("   [BAHAYA] HX711 tidak merespon! Cek kabel DT(16)/SCK(4) atau VCC/GND.");
      while(1); // Stop di sini kalau rusak
  }

  scale.set_scale(); // Set skala mentah 1
  Serial.println("   Melakukan TARE (Nol-kan timbangan)... JANGAN TARUH APAPUN!");
  delay(2000);
  scale.tare();
  Serial.println("   TARE selesai. Timbangan dianggap 0.");
  
  Serial.println("\n--- CARA KALIBRASI (BACA BAIK-BAIK) ---");
  Serial.println("1. Siapkan benda yang kamu TAHU BERATNYA (Contoh: HP = 0.2 kg, Air 600ml = 0.6 kg).");
  Serial.println("2. Taruh benda itu di atas Load Cell.");
  Serial.println("3. Lihat angka 'Raw Value' yang muncul di Serial Monitor.");
  Serial.println("4. Hitung Rumus: FAKTOR = (Raw Value) / (Berat Asli dalam Kg)");
  Serial.println("   Contoh: Raw terbaca 42000. Berat benda 0.2 kg.");
  Serial.println("   Faktor = 42000 / 0.2 = 210000");
  Serial.println("-------------------------------------------");
}

void loop() {
  if (scale.is_ready()) {
    long reading = scale.get_units(10); // Rata-rata 10 bacaan
    Serial.print("Raw Value: ");
    Serial.println(reading);
  }
  delay(500);
}
