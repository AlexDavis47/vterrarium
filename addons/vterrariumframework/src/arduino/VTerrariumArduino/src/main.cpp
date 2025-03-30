#include <Arduino.h>
#include <DHT.h>

// Pin definitions
const int PHOTODIODE_PIN = A0; // Analog pin connected to the photodiode
const int DHT_PIN = 2;         // Digital pin connected to the DHT sensor

// DHT sensor configuration
#define DHT_TYPE DHT11 // DHT11 (blue sensor)
DHT dht(DHT_PIN, DHT_TYPE);

// Variables for reading and sending sensor values
int photodiodeValue = 0;
float photodiodeValueCompensated = 0.0;
float temperature = 0.0;
float humidity = 0.0;
unsigned long lastSendTime = 0;
const int sendInterval = 16; // Send data every 0.016 seconds

void setup()
{
  // Initialize serial communication
  Serial.begin(9600);

  // Set the built-in LED pin as output
  pinMode(LED_BUILTIN, OUTPUT);

  // Initialize the photodiode pin as an input
  pinMode(PHOTODIODE_PIN, INPUT);

  // Initialize DHT sensor
  dht.begin();

  // Print initial message
  Serial.println("Arduino sensor system started");
}

void loop()
{
  // Read the photodiode value
  photodiodeValue = analogRead(PHOTODIODE_PIN);

  // Invert the reading for more intuitive values (higher = more light)
  photodiodeValue = 1023 - photodiodeValue;

  // Apply sqrt to the photodiode value
  photodiodeValueCompensated = sqrt(photodiodeValue);

  // Return the value to the full range of 0-1023
  photodiodeValueCompensated = map(photodiodeValueCompensated, 0, 23, 0, 1023);

  // Check if it's time to send the values
  unsigned long currentTime = millis();

  if (currentTime - lastSendTime >= sendInterval)
  {
    // Read temperature and humidity from DHT sensor
    humidity = dht.readHumidity();
    temperature = dht.readTemperature();

    // Check if readings are valid
    if (!isnan(humidity) && !isnan(temperature))
    {
      // Send all sensor values to serial port in CSV format: photodiode,temperature,humidity
      Serial.print(photodiodeValue);
      Serial.print(",");
      Serial.print(temperature);
      Serial.print(",");
      Serial.println(humidity);

      // Blink LED to indicate data was sent
      digitalWrite(LED_BUILTIN, HIGH);
      delay(5);
      digitalWrite(LED_BUILTIN, LOW);
    }

    // Update last send time
    lastSendTime = currentTime;
  }
}