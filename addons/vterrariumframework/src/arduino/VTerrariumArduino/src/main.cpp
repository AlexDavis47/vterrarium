#include <Arduino.h>

// Pin definitions
const int PHOTODIODE_PIN = A0; // Analog pin connected to the photodiode

// Variables for reading and sending the photodiode value
int photodiodeValue = 0;
unsigned long lastSendTime = 0;
const int sendInterval = 100; // Send data every 100ms (10 times per second)

void setup()
{
  // Initialize serial communication
  Serial.begin(9600);

  // Set the built-in LED pin as output
  pinMode(LED_BUILTIN, OUTPUT);

  // Enable internal pull-up resistor for the photodiode pin
  // Note: This is not ideal but may allow basic testing without an external resistor
  pinMode(PHOTODIODE_PIN, INPUT_PULLUP);

  // Print initial message
  Serial.println("Arduino photodiode sensor started (using internal pull-up)");
}

void loop()
{
  // Read the photodiode value
  photodiodeValue = analogRead(PHOTODIODE_PIN);

  // When using internal pull-up, the reading is inverted (higher light = lower value)
  // So we invert it back for more intuitive readings (higher value = more light)
  photodiodeValue = 1023 - photodiodeValue;

  // Check if it's time to send the value
  unsigned long currentTime = millis();

  if (currentTime - lastSendTime >= sendInterval)
  {
    // Send photodiode value to serial port
    Serial.println(photodiodeValue);

    // Blink LED to indicate data was sent
    digitalWrite(LED_BUILTIN, HIGH);
    delay(5); // Very short blink
    digitalWrite(LED_BUILTIN, LOW);

    // Update last send time
    lastSendTime = currentTime;
  }
}