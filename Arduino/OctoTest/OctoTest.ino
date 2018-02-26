#include <OctoWS2811.h>

#define LED_WIDTH 16
#define LED_HEIGHT 8
#define LED_LAYOUT 0

const int ledsPerStrip = 32;

DMAMEM int displayMemory[ledsPerStrip * 6];
int drawingMemory[ledsPerStrip * 6];
elapsedMicros elapsedUsecSinceLastFrameSync = 0;

const int config = WS2811_GRB | WS2811_800kHz;

OctoWS2811 leds(ledsPerStrip, displayMemory, drawingMemory, config);

void setup() {
  Serial.setTimeout(50);
  leds.begin();
  leds.show();
}

void loop() {
  int startChar = Serial.read();

  if (startChar == '*') {
    unsigned int startAt = micros();
    unsigned int usecUntilFrameSync = 0;

    int count = Serial.readBytes((char *)&usecUntilFrameSync, 2);
    if (count != 2) {
      return;
    }

    count = Serial.readBytes((char *)drawingMemory, sizeof(drawingMemory));
    if (count == sizeof(drawingMemory)) {
      unsigned int endAt = micros();
      unsigned int usToWaitBeforeSyncOutput = 100;
      if (endAt - startAt < usecUntilFrameSync) {
        usToWaitBeforeSyncOutput = usecUntilFrameSync - (endAt - startAt);
      }
      digitalWrite(12, HIGH);
      pinMode(12, OUTPUT);

      delayMicroseconds(usToWaitBeforeSyncOutput);
      digitalWrite(12, LOW);

      digitalWrite(13, HIGH);
      leds.show();
      digitalWrite(13, LOW);
    }
  } else if (startChar == '$') {
    // TODO: Sync frame code will be write here.
    
  } else if (startChar == '%') {
    // TODO: slave sync frame code
  } else if (startChar == '@') {
    elapsedUsecSinceLastFrameSync = 0;
  } else if (startChar == '?') {
    Serial.print(LED_WIDTH);
    Serial.write(',');
    Serial.print(LED_HEIGHT);
    Serial.write(',');
    Serial.print(LED_LAYOUT);
    Serial.write(',');
    Serial.print(0);
    Serial.write(',');
    Serial.print(0);
    Serial.write(',');
    Serial.print('0');
    Serial.write(',');
    Serial.print('0');
    Serial.write(',');
    Serial.print('0');
    Serial.write(',');
    Serial.print('0');
    Serial.write(',');
    Serial.print(0);
    Serial.write(',');
    Serial.print(0);
    Serial.write(',');
    Serial.print(0);
    Serial.println();
  } else {
    // Discard
  }

}
