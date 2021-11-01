/*
 * Firebase ESP32
 * https://www.electroniclinic.com/
 */

#include <WiFi.h>
#include <FirebaseESP32.h>


#define FIREBASE_HOST "https://utkuhoca-bitirme-default-rtdb.firebaseio.com"
#define FIREBASE_AUTH "63jc3IZMtazqwQ9flbHVrLNiPGXLtfXN3q2f26g4"
#define WIFI_SSID "fmobey"
#define WIFI_PASSWORD "q1w2e3asd"
#define LED_BUILTIN 2
#define SENSOR  27

long currentMillis = 0;
long previousMillis = 0;
int interval = 1000;
boolean ledState = LOW;
float calibrationFactor = 4.5;
volatile byte pulseCount;
byte pulse1Sec = 0;
float flowRate;
unsigned int flowMilliLitres;
unsigned long totalMilliLitres;

void IRAM_ATTR pulseCounter()
{
  pulseCount++;
}



FirebaseData firebaseData;
FirebaseJson json;
FirebaseJson json1;

void setup()
{

  Serial.begin(115200);
 
pinMode(LED_BUILTIN, OUTPUT);
  pinMode(SENSOR, INPUT_PULLUP);

  pulseCount = 0;
  flowRate = 0.0;
  flowMilliLitres = 0;
  totalMilliLitres = 0;
  previousMillis = 0;

  attachInterrupt(digitalPinToInterrupt(SENSOR), pulseCounter, FALLING);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);


  Firebase.setReadTimeout(firebaseData, 1000 * 60);
  
  Firebase.setwriteSizeLimit(firebaseData, "tiny");



  Serial.println("------------------------------------");
  Serial.println("Connected...");
  
}

void loop()
{
      currentMillis = millis();
  if (currentMillis - previousMillis > interval) {
    
    pulse1Sec = pulseCount;
    pulseCount = 0;

    // Because this loop may not complete in exactly 1 second intervals we calculate
    // the number of milliseconds that have passed since the last execution and use
    // that to scale the output. We also apply the calibrationFactor to scale the output
    // based on the number of pulses per second per units of measure (litres/minute in
    // this case) coming from the sensor.
    flowRate = ((1000.0 / (millis() - previousMillis)) * pulse1Sec) / calibrationFactor;
    previousMillis = millis();

    // Divide the flow rate in litres/minute by 60 to determine how many litres have
    // passed through the sensor in this 1 second interval, then multiply by 1000 to
    // convert to millilitres.
    flowMilliLitres = (flowRate / 60) * 1000;

    // Add the millilitres passed in this second to the cumulative total
    totalMilliLitres += flowMilliLitres;
    
    // Print the flow rate for this second in litres / minute
    Serial.print("Flow rate: ");
    Serial.print(int(flowRate));  // Print the integer part of the variable
    Serial.print("L/min");
    Serial.print("\t");       // Print tab space

    // Print the cumulative total of litres flowed since starting
    Serial.print("Output Liquid Quantity: ");
    Serial.print(totalMilliLitres);
    Serial.print("mL / ");
    Serial.print(totalMilliLitres / 1000);
    Serial.println("L");
      json.set("/data", flowRate);
      json1.set("/data", totalMilliLitres);
  Firebase.updateNode(firebaseData,"/AnlikKullanim",json);
  Firebase.updateNode(firebaseData,"/ToplamKullanim",json1);  
  }
    /////////////////////////////////
 


}
