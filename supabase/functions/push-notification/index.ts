import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

// ==================================================================================
// 🔧 KONFIGURASI EDGE FUNCTION (CENTRALIZED LOGIC)
// ==================================================================================

// 1. FIREBASE SERVICE ACCOUNT (Untuk Notifikasi Android)
// Pastikan ini sesuai dengan file JSON yang kamu punya jika ada perubahan.
// @ts-ignore
const serviceAccount = {
  type: "service_account",
  project_id: "koolee-notif",
  private_key_id: "495e2555ce6c91b23366a7413a1bf751523fadfe",
  private_key: "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCvLJ7jbnrsAzkl\npOXlYV/uHbsgHVkaYj3t/1OgORq0HCTIyDMbBj83h60M+2dQiyJun8k/o9Xo+dCW\nZRm/nbJMnB744cDebPyGKQ4W9U9a54sUASAZBMpH/jM3UrXTq9SXyj8zty52aUcl\nO1yxbkBlltTpBYfaxC2dMdTmWbhogj4iZAikFIbQffPIGKlMpE0xBa4Cqtu2CR6i\nKwnl6EyQyueJBqrhrbT0iNYZf9p/vdaMNOGgQryIPG1lnfJ6ZTagTCRPYmjfCsSQ\n/Db+ZcX0O+tLWs9tC2dg8USlco+VuoRg3gytoTCIn8dEL5KPk+xLu08v6ucolmtG\nNgHLv5B1AgMBAAECggEAELr7AN8+I7jqFheR8m6yphAWXWqYJj4wSoEKiGCz1XRj\nqf5+7QuTcZcGdtkzBJ0JQJYHt0mLRllHq/mDdErYKtt1VNFg5Y10r86Pfy9WMSkw\nngw+d80+kZIsa5H9djYw0394OlT6PcpvxlVNVM/iHCHD+25xC3qVnbAS9J4oj+iK\nF1xvs/YQPX2OQNrFKTI5tzduGfBjscbmY0+XNNbcNDbZi6FluytTNWsgRdZcm9ZA\ntnteLlOIEcNwOIfk+l15MPotkcFGH/6CJ8tzpeFBsVRx6gNmwBKWIrj7S3Kgiqar\nZsPD2rdHPLPnTLSEwZhUyGp2UF+d1X87YvaoTe+QyQKBgQDYWxoF06ui3Oh9Y3bG\n7Jxg3O67QAdWMKmhOiDC9tdIHiaHlt17SaPJqahR1LMAfwEIVN/hhH7y1XTSyD68\namQXOXN0kYncgLq/WneEKFuJJNL2xOQfmonmEgqc0bMArReVcrx1eoQ6yUWqcpm/\nZWobGscb3xpDhYjUg0Y8KSs1PQKBgQDPRcJlXZVz0CxZ4S41sE+fn7eOxtTSBuCX\nr5g6a+YvAspB7TGlxStEdB7kCU5xmU71LwlPLfyu7YVwgo6/CNF7khpb4UVwFe99\n0sU4Rwn1YDA/kTeuPQ5Aip6hgtT1lfB3YjztUxIVJhiPlAIg1AFKcBUa2rM+lHWh\ntuurzaGrmQKBgDzjhrNVGty+5v9C2s6pEGmCQ/2Wy3nKQDMLtOSpq3S0Z4uJPdPQ\nqbO7d49wGOBu3c+Gc2t4anHU+QfJKz7Dgl+233NS8kWIRQZNY41h/kDeiDDCwKDU\nUTLaqPnxWjs6e4SnwboePNB+jIinr/VZiT8PjjGd3DpcfmGwgDe2Ll7RAoGAAruI\ntI1nSv+TlhvB4DNS2Wfho6A7bglpLJbECwEhJ72BrRzTarwOtfhR7++veQ/sWo8k\nMEcK7cNz3ufZuesD1/01G8D8iV3Aqof80aEeIH4EJNJlSYbEiVVKghaXeCVh5jEF\nXJubwWufJ0VsQcKJwdF4dcIsWsbaRieDM+CiIQECgYBnhQhd/P9aBphJlokXsrKm\nBvHQwe0KY8oQ1AHyxZxkPX2DLtcn/maGG8eprET252Q1N0TO7wAVYRpsZH/r/D5+\ncfXubuqXHWZSF/v7lSD61wZLcScNx3LUaARnjvKGl7SqPAcS1+PHxSOjk4yThpfZ\nf8FWaX7XXPp24+GtDBaYrg==\n-----END PRIVATE KEY-----\n",
  client_email: "firebase-adminsdk-fbsvc@koolee-notif.iam.gserviceaccount.com",
  client_id: "112596995580563626486",
  auth_uri: "https://accounts.google.com/o/oauth2/auth",
  token_uri: "https://oauth2.googleapis.com/token",
  auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
  client_x509_cert_url: "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40koolee-notif.iam.gserviceaccount.com",
  universe_domain: "googleapis.com"
};

// 2. SUPABASE CREDENTIALS (UNTUK UPDATE DATABASE)
// Ini dipakai server untuk mengubah status buzzer di tabel 'control'
const SUPABASE_URL = "https://kxajmamxcgcdhddhdaiq.supabase.co";
const SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imt4YWptYW14Y2djZGhkZGhkYWlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM3MDU2ODMsImV4cCI6MjA3OTI4MTY4M30.Vp3oTNunMqsmFv5ai83k-imcIaxA5Y8GE5cfevrnPPU";

console.log("Function 'push-notification' + 'logic-control' up and running!");

// --- HELPER: Get Google Access Token ---
async function getAccessToken(client_email, private_key) {
  const header = { alg: "RS256", typ: "JWT" };
  const now = Math.floor(Date.now() / 1000);
  const claim = {
    iss: client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    exp: now + 3600,
    iat: now
  };
  const sHeader = JSON.stringify(header);
  const sClaim = JSON.stringify(claim);
  const sHeader64 = btoa(sHeader).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
  const sClaim64 = btoa(sClaim).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
  const unsignedToken = `${sHeader64}.${sClaim64}`;
  const key = private_key.replace(/\\n/g, "\n");
  const binaryKey = await crypto.subtle.importKey("pkcs8", str2ab(atob(key.replace("-----BEGIN PRIVATE KEY-----", "").replace("-----END PRIVATE KEY-----", "").replace(/\s/g, ""))), {
    name: "RSASSA-PKCS1-v1_5",
    hash: "SHA-256"
  }, false, ["sign"]);
  const signature = await crypto.subtle.sign("RSASSA-PKCS1-v1_5", binaryKey, new TextEncoder().encode(unsignedToken));
  const signature64 = btoa(String.fromCharCode(...new Uint8Array(signature))).replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/, "");
  const jwt = `${unsignedToken}.${signature64}`;
  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`
  });
  const data = await res.json();
  return data.access_token;
}

function str2ab(str) {
  const buf = new ArrayBuffer(str.length);
  const bufView = new Uint8Array(buf);
  for(let i = 0, strLen = str.length; i < strLen; i++){
    bufView[i] = str.charCodeAt(i);
  }
  return buf;
}

// --- LOGIKA UTAMA ---
serve(async (req)=>{
  try {
    // 1. Ambil Data Telemetry yang baru masuk (via Webhook)
    const { record } = await req.json();
    
    // Jika testing manual tanpa data
    if (!record) {
        return new Response(JSON.stringify({ message: "No record data found" }), {
            headers: { "Content-Type": "application/json" }
        });
    }

    console.log("Data masuk:", record);
    const currentWeight = record.weight;
    const currentTemp = record.temperature;
    const currentHumidity = record.humidity;
    
    // ======================================================================
    // LOGIC CENTER: Tentukan nasib Buzzer di sini!
    // ======================================================================
    // THRESHOLD VALUES (Batas Normal)
    const WEIGHT_MIN = 20.0;       // Berat minimum (gram)
    const WEIGHT_MAX = 7000.0;     // Berat maksimum (gram)
    const TEMP_MIN = 0.0;          // Suhu minimum kulkas (°C)
    const TEMP_MAX = 32.0;          // Suhu maksimum kulkas (°C)
    const HUMIDITY_MIN = 60.0;     // Kelembapan minimum (%)
    const HUMIDITY_MAX = 80.0;     // Kelembapan maksimum (%)
    
    // CHECK CONDITIONS
    const isStockAbnormal = currentWeight < WEIGHT_MIN || currentWeight > WEIGHT_MAX;
    const isTempAbnormal = currentTemp < TEMP_MIN || currentTemp > TEMP_MAX;
    const isHumidityAbnormal = currentHumidity < HUMIDITY_MIN || currentHumidity > HUMIDITY_MAX;
    
    // Buzzer aktif jika SALAH SATU kondisi tidak normal
    const shouldActivateBuzzer = isStockAbnormal || isTempAbnormal || isHumidityAbnormal;
    
    // Buat pesan detail untuk log dan notifikasi
    const problems = [];
    if (isStockAbnormal) problems.push(`Stok abnormal (${currentWeight}g)`);
    if (isTempAbnormal) problems.push(`Suhu abnormal (${currentTemp}°C)`);
    if (isHumidityAbnormal) problems.push(`Kelembapan abnormal (${currentHumidity}%)`);
    
    console.log(`LOGIC DECISION: 
      - Berat: ${currentWeight}g ${isStockAbnormal ? '❌ ABNORMAL' : '✅ OK'}
      - Suhu: ${currentTemp}°C ${isTempAbnormal ? '❌ ABNORMAL' : '✅ OK'}
      - Kelembapan: ${currentHumidity}% ${isHumidityAbnormal ? '❌ ABNORMAL' : '✅ OK'}
      - Buzzer: ${shouldActivateBuzzer ? '🔴 AKTIF' : '🟢 NONAKTIF'}
      - Masalah: ${problems.join(', ') || 'Tidak ada'}`);

    // 2. CHECK BUZZER MODE - Respect manual override
    console.log('Checking current buzzer mode...');
    const controlUrl = `${SUPABASE_URL}/rest/v1/control?id=eq.1&select=buzzer_mode,buzzer_active`;
    const controlResponse = await fetch(controlUrl, {
      headers: {
        "apikey": SUPABASE_KEY,
        "Authorization": `Bearer ${SUPABASE_KEY}`
      }
    });
    const controlData = await controlResponse.json();
    const currentMode = controlData[0]?.buzzer_mode || 'auto';
    const currentBuzzerStatus = controlData[0]?.buzzer_active || false;

    console.log(`Current mode: ${currentMode}, Current buzzer: ${currentBuzzerStatus}`);

    // 3. UPDATE DATABASE (Only if mode is 'auto')
    // Jika mode manual, skip auto control
    if (currentMode !== 'auto') {
      console.log(`⚠️ SKIPPING AUTO CONTROL - Mode is ${currentMode} (manual override active)`);
      return new Response(JSON.stringify({
        message: "Manual mode active - Auto control skipped",
        current_mode: currentMode,
        buzzer_status: currentBuzzerStatus,
        conditions_would_trigger: shouldActivateBuzzer,
        problems: problems
      }), {
        headers: { "Content-Type": "application/json" }
      });
    }

    // Mode is 'auto', proceed with automatic control
    console.log('✅ AUTO MODE - Proceeding with automatic control');
    const updateUrl = `${SUPABASE_URL}/rest/v1/control?id=eq.1`;
    const updatePayload = { 
      buzzer_active: shouldActivateBuzzer,
      buzzer_mode: 'auto' // Ensure mode stays auto
    };

    console.log(`Updating DB: buzzer_active = ${shouldActivateBuzzer}`);
    
    await fetch(updateUrl, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "apikey": SUPABASE_KEY,
        "Authorization": `Bearer ${SUPABASE_KEY}`,
        "Prefer": "return=minimal"
      },
      body: JSON.stringify(updatePayload)
    });

    // 4. KIRIM NOTIFIKASI (Jika ada masalah dan mode auto)
    let fcmResult = null;
    if (shouldActivateBuzzer) {
      console.log("Mengirim Notifikasi ke HP...");
      
      const accessToken = await getAccessToken(serviceAccount.client_email, serviceAccount.private_key);
      const fcmUrl = `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`;
      
      // Buat notifikasi yang informatif
      const notifTitle = "⚠️ PERINGATAN KULKAS!";
      const notifBody = problems.length > 0 
        ? `Terdeteksi masalah: ${problems.join(', ')}.` 
        : "Kondisi kulkas tidak normal!";
      
      const payload = {
        message: {
          topic: "all",
          notification: {
            title: notifTitle,
            body: notifBody
          },
          data: {
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            weight: currentWeight.toString(),
            temperature: currentTemp.toString(),
            humidity: currentHumidity.toString(),
            problems: JSON.stringify(problems)
          }
        }
      };
      const response = await fetch(fcmUrl, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json"
        },
        body: JSON.stringify(payload)
      });
      fcmResult = await response.json();
      
      // 5. SIMPAN NOTIFIKASI KE DATABASE (untuk history)
      console.log("Menyimpan notifikasi ke database...");
      try {
        const notifInsertUrl = `${SUPABASE_URL}/rest/v1/notifications`;
        await fetch(notifInsertUrl, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "apikey": SUPABASE_KEY,
            "Authorization": `Bearer ${SUPABASE_KEY}`,
            "Prefer": "return=minimal"
          },
          body: JSON.stringify({
            title: notifTitle,
            body: notifBody,
            data: {
              weight: currentWeight,
              temperature: currentTemp,
              humidity: currentHumidity,
              problems: problems
            },
            is_read: false
          })
        });
        console.log("✅ Notifikasi berhasil disimpan ke database");
      } catch (saveError) {
        console.error("❌ Error menyimpan notifikasi:", saveError);
        // Continue execution even if saving fails
      }
    }

    return new Response(JSON.stringify({
      message: "Logic Executed Successfully",
      buzzer_status_set_to: shouldActivateBuzzer,
      conditions_checked: {
        weight: { value: currentWeight, threshold: WEIGHT_MAX, abnormal: isStockAbnormal },
        temperature: { value: currentTemp, range: `${TEMP_MIN}-${TEMP_MAX}`, abnormal: isTempAbnormal },
        humidity: { value: currentHumidity, range: `${HUMIDITY_MIN}-${HUMIDITY_MAX}`, abnormal: isHumidityAbnormal }
      },
      problems: problems,
      fcm_response: fcmResult
    }), {
      headers: { "Content-Type": "application/json" }
    });

  } catch (error) {
    console.error(error);
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { "Content-Type": "application/json" }
    });
  }
});