#define BLYNK_TEMPLATE_ID "Your_Template_ID"  // Optional
#define BLYNK_TEMPLATE_NAME "PF_monitor"      // Optional
#define BLYNK_AUTH_TOKEN "wookL7LZPFtManUEfFD_3SXrV0kjUjdh"

#include <WiFi.h>
#include <WiFiClient.h>
#include <BlynkSimpleEsp32.h>

char ssid[] = "Piku332";   
char pass[] = "hotspott"; 

String inputString = "";
bool stringComplete = false;

void setup() {
  Serial.begin(115200);
  delay(1000);

  Serial.println("Connecting to WiFi...");
  WiFi.begin(ssid, pass);

  int tries = 0;
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    tries++;
    if (tries > 20) {
      Serial.println("\n❌ WiFi Connection Failed.");
      return;
    }
  }

  Serial.println("\n✅ WiFi Connected!");
  Serial.print("IP Address: ");
  Serial.println(WiFi.localIP());

  Serial.println("Connecting to Blynk...");
  Blynk.begin(BLYNK_AUTH_TOKEN, ssid, pass);
  Serial.println("✅ Blynk Connection Started");
}
void loop() {
  Blynk.run();

  // Collect input from serial port
  while (Serial.available()) {
    char inChar = (char)Serial.read();
    if (inChar == '\n') {
      stringComplete = true;
      break;
    } else {
      inputString += inChar;
    }
  }

  if (stringComplete) {
    float pfValues[10];
    int pfIndex = 0;
    int startIndex = 0;
    int commaIndex = inputString.indexOf(',', startIndex);

    // Parse comma-separated values
    while (commaIndex >= 0 && pfIndex < 9) {  // parse first 9 commas
      String pfStr = inputString.substring(startIndex, commaIndex);
      pfValues[pfIndex] = pfStr.toFloat();
      pfIndex++;
      startIndex = commaIndex + 1;
      commaIndex = inputString.indexOf(',', startIndex);
    }

    // Capture the last value (after the final comma)
    if (pfIndex < 10 && startIndex < inputString.length()) {
      pfValues[pfIndex] = inputString.substring(startIndex).toFloat();
      pfIndex++;
    }

    // Send values to Blynk virtual pins V1 to V10
    for (int i = 0; i < pfIndex; i++) {
      Serial.print("PF");
      Serial.print(i + 1);
      Serial.print(": ");
      Serial.print(pfValues[i]);
      Serial.print(" | ");
      Blynk.virtualWrite(V1 + i, pfValues[i]);
    }
    Serial.println();

    // Reset input
    inputString = "";
    stringComplete = false;
  }
}
