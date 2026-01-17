#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <math.h>

/* ================= WIFI ================= */
#define WIFI_SSID     "Gorkhas"
#define WIFI_PASSWORD "6577edrs"

/* =============== FIREBASE =============== */
#define API_KEY "AIzaSyBmaiOH5qBnvWf-LVNWFLCpRojH1KOuh3U"
#define DATABASE_URL "https://chethana-55ad9-default-rtdb.firebaseio.com/"

/* =============== HARDWARE =============== */
// Accelerometer (example: ADXL335)
#define X_PIN 34
#define Y_PIN 35
#define Z_PIN 32

#define BUZZER_PIN 18   // D18
#define BUTTON_PIN 19   // D19

#define FALL_THRESHOLD 3500

/* =============== FIREBASE OBJECTS =============== */
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

bool signupOK = false;
String lastStatus = "SAFE";

/* ================================================= */

void sendToFirebase(String status) {
  if (Firebase.RTDB.setString(&fbdo, "/thanal_device/status", status)) {
    Serial.println("Sent to Firebase: " + status);
  } else {
    Serial.print("Firebase Error: ");
    Serial.println(fbdo.errorReason());
  }
}

/* ================================================= */

void setup() {
  Serial.begin(115200);
  delay(2000);

  Serial.println("Booting ESP32...");

  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);

  pinMode(BUTTON_PIN, INPUT_PULLUP);

  /* -------- WIFI -------- */
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");

  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }
  Serial.println("\nWiFi Connected");

  /* -------- FIREBASE -------- */
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("Firebase SignUp OK");
    signupOK = true;
  } else {
    Serial.println("Firebase SignUp FAILED");
    Serial.println(config.signer.signupError.message.c_str());
  }

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  sendToFirebase("SAFE");
  Serial.println("System Ready");
}

/* ================================================= */

void loop() {
  if (!signupOK) return;

  int x = analogRead(X_PIN);
  int y = analogRead(Y_PIN);
  int z = analogRead(Z_PIN);

  long magnitude = sqrt((long)x * x + (long)y * y + (long)z * z);

  Serial.print("Magnitude: ");
  Serial.println(magnitude);

  /* ---------- FALL DETECTION ---------- */
  if (magnitude > FALL_THRESHOLD && lastStatus != "ALERT") {
    Serial.println("⚠ FALL DETECTED");

    digitalWrite(BUZZER_PIN, HIGH);
    sendToFirebase("ALERT");
    delay(9000);
    digitalWrite(BUZZER_PIN, LOW);

    lastStatus = "ALERT";
  }

  /* ---------- HELP BUTTON ---------- */
  if (digitalRead(BUTTON_PIN) == LOW && lastStatus != "HELP") {
    Serial.println("HELP BUTTON PRESSED");

    sendToFirebase("HELP");

    for (int i = 0; i < 3; i++) {
      digitalWrite(BUZZER_PIN, HIGH); delay(150);
      digitalWrite(BUZZER_PIN, LOW);  delay(150);
    }

    lastStatus = "HELP";
    delay(9000);
  }

  /* ---------- SAFE STATE ---------- */
  if (digitalRead(BUTTON_PIN) == HIGH && magnitude < FALL_THRESHOLD) {
    if (lastStatus != "SAFE") {
      sendToFirebase("SAFE");
      lastStatus = "SAFE";
      Serial.println("System SAFE");
    }
  }

  delay(500);
}
