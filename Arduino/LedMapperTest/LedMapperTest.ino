#include "FastLED.h"

#define DW_LED_PACKET_HEADER 0xFF
#define DW_LED_DATA 0xBE

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

CRGB ledStrips[STRIPS_NUM][LEDS_NUM];

char data[STRIPS_NUM * (3 + 1)];

void setup() {
//  Serial.begin(9600);
  Serial.setTimeout(50);
  
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
}

void loop() {
  #ifdef TEST_MODE
    for (int i = 0; i < STRIPS_NUM; i++) {
      fill_solid(ledStrips[i], LEDS_NUM, CRGB::Red);
    }
    FastLED.setBrightness(128);
    FastLED.show();
  #else
    byte startByte = Serial.read();
  if (startByte == '*') {
//    fill_solid(ledStrips[7], LEDS_NUM, CRGB::Black);
//    FastLED.setBrightness(128);
//    FastLED.show();
    int count = Serial.readBytes((char *)data, sizeof(data));
    if (count == sizeof(data)) {
//      Serial.println(data[8]);
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
  #endif
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



