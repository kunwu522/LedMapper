#include "FastLED.h"

#define LEDS_NUM  16
#define STRIPS_NUM  8

//#define TEST_MODE

#define DATA_PIN0 0
#define DATA_PIN1 1
#define DATA_PIN2 2
#define DATA_PIN3 3
#define DATA_PIN4 4
#define DATA_PIN5 5
#define DATA_PIN6 6
#define DATA_PIN7 7
#define DATA_PIN8 8
#define DATA_PIN9 9
#define DATA_PIN10 10 
#define DATA_PIN11 11
#define DATA_PIN12 12
#define DATA_PIN13 13
#define DATA_PIN14 14
#define DATA_PIN15 15
#define DATA_PIN16 16
#define DATA_PIN17 17
#define DATA_PIN18 18
#define DATA_PIN19 19
#define DATA_PIN20 20
#define DATA_PIN21 21

CRGB ledStrips[STRIPS_NUM][LEDS_NUM];

char data[STRIPS_NUM * (3 + 1)];

int mode = 0;

void setup() {
  Serial.setTimeout(50);

  #ifdef TEST_MODE
    Serial.begin(115200);
  #endif
  
  FastLED.addLeds<WS2812B, DATA_PIN0, RGB>(ledStrips[0], LEDS_NUM);
  FastLED.addLeds<WS2812B, DATA_PIN1, RGB>(ledStrips[1], LEDS_NUM);
  FastLED.addLeds<WS2812B, DATA_PIN2, RGB>(ledStrips[2], LEDS_NUM);
  FastLED.addLeds<WS2812B, DATA_PIN3, RGB>(ledStrips[3], LEDS_NUM);
  FastLED.addLeds<WS2812B, DATA_PIN4, RGB>(ledStrips[4], LEDS_NUM);
  FastLED.addLeds<WS2812B, DATA_PIN5, RGB>(ledStrips[5], LEDS_NUM);
  FastLED.addLeds<WS2812B, DATA_PIN6, RGB>(ledStrips[6], LEDS_NUM);
  FastLED.addLeds<WS2812B, DATA_PIN7, RGB>(ledStrips[7], LEDS_NUM);
//  FastLED.addLeds<WS2812B, DATA_PIN8, RGB>(ledStrips[8], LEDS_NUM);
//  FastLED.addLeds<WS2812B, DATA_PIN9, RGB>(ledStrips[9], LEDS_NUM);
//  FastLED.addLeds<WS2812B, DATA_PIN10, RGB>(ledStrips[10], LEDS_NUM);
//  FastLED.addLeds<WS2812B, DATA_PIN11, RGB>(ledStrips[11], LEDS_NUM);
//  FastLED.addLeds<WS2812B, DATA_PIN12, RGB>(ledStrips[12], LEDS_NUM);
//  FastLED.addLeds<WS2812B, DATA_PIN13, RGB>(ledStrips[13], LEDS_NUM);
//  FastLED.addLeds<WS2812B, DATA_PIN14, RGB>(ledStrips[14], LEDS_NUM);
//  FastLED.addLeds<WS2812B, DATA_PIN15, RGB>(ledStrips[15], LEDS_NUM);
//  FastLED.addLeds<WS2812B, DATA_PIN16, RGB>(ledStrips[16], LEDS_NUM);
//  FastLED.addLeds<WS2812B, DATA_PIN17, RGB>(ledStrips[17], LEDS_NUM);
//  FastLED.addLeds<WS2812B, DATA_PIN18, RGB>(ledStrips[18], LEDS_NUM);
//  FastLED.addLeds<WS2812B, DATA_PIN19, RGB>(ledStrips[19], LEDS_NUM);
//  FastLED.addLeds<WS2812B, DATA_PIN20, RGB>(ledStrips[20], LEDS_NUM);
//  FastLED.addLeds<WS2812B, DATA_PIN21, RGB>(ledStrips[21], LEDS_NUM);

  FastLED.setDither(0);
}

void loop() {
  byte startByte = Serial.read();
  
  if (startByte == '#') { // Change Running Mode
    mode = Serial.read();
    #ifdef TEST_MODE
      Serial.println("########### Changed to %d mode successfully", mode);
    #endif
  }

  switch (mode) {
    case 0: // Normal Running
      processingLoop();
      break;
    case 1: // Test Leds
      testAllLeds();
      break;
    case 2:
      testSingleLed();
      break;
    case 3:
      testMultipleLeds();
      break;
    default:
      break;
  }
}

void showLed() {
  char *dataPtr = data;
  for (int i = 0; i < STRIPS_NUM; i++) {
    CRGB color = CRGB(dataPtr[1], dataPtr[2], dataPtr[3]);
    fill_solid(ledStrips[i], LEDS_NUM, color);
    FastLED[i].showLeds(data[0]);
    dataPtr += 4;
  }
}

void processingLoop() {
  #ifdef TEST_MODE
    Serial.println("Standard Running, waiting data...");
  #endif
  byte startByte = 0;
  while (Serial.available() > 0) {
    startByte = Serial.read();
  }
  if (startByte == '*') {
    int count = Serial.readBytes((char *)data, sizeof(data));
    if (count == sizeof(data)) {
      showLed();
    } else {
      fill_solid(ledStrips[7], LEDS_NUM, CRGB::Blue);
      FastLED.setBrightness(128);
      FastLED.show();
    }
  } else if (startByte == '?') {
    Serial.print(STRIPS_NUM);
    Serial.write(',');
    Serial.print(DATA_PIN0);
    Serial.write(',');
    Serial.print(LEDS_NUM);
    Serial.write(',');
    Serial.print(DATA_PIN1);
    Serial.write(',');
    Serial.print(LEDS_NUM);
    Serial.write(',');
    Serial.print(DATA_PIN2);
    Serial.write(',');
    Serial.print(LEDS_NUM);
    Serial.write(',');
    Serial.print(DATA_PIN3);
    Serial.write(',');
    Serial.print(LEDS_NUM);
    Serial.write(',');
    Serial.print(DATA_PIN4);
    Serial.write(',');
    Serial.print(LEDS_NUM);
    Serial.write(',');
    Serial.print(DATA_PIN5);
    Serial.write(',');
    Serial.print(LEDS_NUM);
    Serial.write(',');
    Serial.print(DATA_PIN6);
    Serial.write(',');
    Serial.print(LEDS_NUM);
    Serial.write(',');
    Serial.print(DATA_PIN7);
    Serial.write(',');
    Serial.print(LEDS_NUM);
    Serial.print('\n');
  } else {
//    fill_solid(ledStrips[7], LEDS_NUM, CRGB::Blue);
//    FastLED.setBrightness(128);
    FastLED.show();
  }
}

void testAllLeds() {
  #ifdef TEST_MODE
    Serial.println("Test All Leds...");
  #endif
  for (int i = 0; i < STRIPS_NUM; i++) {
    fill_solid(ledStrips[i], LEDS_NUM, CRGB::Red);
  }
  FastLED.setBrightness(128);
  FastLED.show();
}

void testSingleLed() {
  #ifdef TEST_MODE
    Serial.println("Test Single Led, waiting serial input");
  #endif
  byte dataLength = getFirstData();
  if (dataLength == 0) {
    return;
  }
  
  char newData[dataLength];
  int count = Serial.readBytes((char *)newData, sizeof(newData));
  if (count != dataLength) {
    #ifdef TEST_MODE
      Serial.println("Error, Input data lenght is not valid.");
    #endif
    return;
  }

  short id = data[0];
  short bright = data[1];
  CRGB c = CRGB(data[2], data[3], data[4]);
  fill_solid(ledStrips[id], LEDS_NUM, c);
  FastLED.setBrightness(bright);
  FastLED.show();
}

void testMultipleLeds() {
  #ifdef TEST_MODE
    Serial.println("Test Multiple LEDs, waiting serial input");
  #endif

  byte dataLength = getFirstData();
  if (dataLength == 0) {
    return;
  }

  char newData[dataLength];
  int count = Serial.readBytes((char *)newData, sizeof(newData));
  if (count != dataLength) {
    #ifdef TEST_MODE
      Serial.println("Error, Input data length is not valid");
    #endif
    return;
  }

  for (int i = 0; i < dataLength; i+=5) {
    short id = data[i];
    short bright = data[i + 1];
    CRGB c = CRGB(data[i + 2], data[i + 3], data[i + 4]);
    fill_solid(ledStrips[id], LEDS_NUM, c);
    FastLED[id].showLeds(bright);
  }
}

byte getFirstData() {
  if (Serial.available() > 0) {
    return Serial.read();
  } else {
    return 0;
  }
}



