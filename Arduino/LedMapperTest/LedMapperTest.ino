#include "FastLED.h"

#define TEENSY_ID "2"
#define TEENSY_NAME "teensy2"

#define NUM_LEDS  620
#define NUM_STRIPS 2

//#define DEBUG_MODE

CRGB leds[NUM_STRIPS][NUM_LEDS];

const int maxQueueSize = (NUM_STRIPS * 3 + 1) * 3;
char dataQueue[maxQueueSize];
int front = -1, rear = -1;

enum State {
  State_Init,
  State_ReadingFrame
};

State state = State_Init;

void setup() {
  Serial.setTimeout(50);
  
  FastLED.addLeds<WS2812B, 0, RGB>(leds[0], NUM_LEDS);
  FastLED.addLeds<WS2812B, 1, RGB>(leds[1], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 2, RGB>(leds[2], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 3, RGB>(leds[3], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 4, RGB>(leds[4], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 5, RGB>(leds[5], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 6, RGB>(leds[6], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 7, RGB>(leds[7], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 8, RGB>(leds[8], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 9, RGB>(leds[9], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 10, RGB>(leds[10], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 11, RGB>(leds[11], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 12, RGB>(leds[12], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 13, RGB>(leds[13], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 14, RGB>(leds[14], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 15, RGB>(leds[15], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 16, RGB>(leds[16], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 17, RGB>(leds[17], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 18, RGB>(leds[18], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 19, RGB>(leds[19], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 20, RGB>(leds[20], NUM_LEDS);
//  FastLED.addLeds<WS2812B, 21, RGB>(leds[21], NUM_LEDS);

  for (int i = 0; i < NUM_STRIPS; i++) {
    fill_solid(leds[i], NUM_LEDS, CRGB::Black);
  }
  FastLED.show();
}

void loop() {  
  while(Serial.available() > 0 && queueSize() < maxQueueSize) {
    enqueue(Serial.read());
  }

  if (state == State_Init) {
    char startByte;
    if (dequeue(&startByte)) {
      sendTeensyInfo();
      state = State_ReadingFrame;
    }
  } else if (state == State_ReadingFrame) {
    processQueue();
  }
}

void showLeds(char data[]) {
  char *dataPtr = data;
  for (int i = 0; i < NUM_STRIPS; i++) {
    CRGB color = CRGB(dataPtr[0], dataPtr[1], dataPtr[2]);
    fill_solid(leds[i], NUM_LEDS, color);
//    leds[i][9] = color;
    dataPtr += 3;
    FastLED[i].showLeds(128);
  }
//  FastLED.setBrightness(128);
//  FastLED.show();
}

void processQueue() {
  if (queueSize() < NUM_STRIPS * 3 + 1) {
    return;
  }
  char startByte;
  while (dequeue(&startByte) && startByte == '*') {
    char data[NUM_STRIPS * 3];
    if (bunchDequeue(data, NUM_STRIPS * 3)) {
      showLeds(data);
    } else {
      #ifdef DEBUG_MODE
        Serial.print("Error, bunch dequeue failed.");
      #endif
    }
  }
  #ifdef DEBUG_MODE
    Serial.print('\n');
  #endif
}

void sendTeensyInfo() {
  Serial.print(TEENSY_ID);
  Serial.write(',');
  Serial.print(TEENSY_NAME);
  Serial.write(',');
  Serial.print(NUM_STRIPS);
  Serial.write(',');
  Serial.print(NUM_LEDS);
  Serial.print('\n');
}

/*
 * For Queue Buffer
 */

void enqueue(char value) {
  if (rear == maxQueueSize - 1) {
    #ifdef DEBUG_MODE
      Serial.print("Error: Queue is Full!");
    #endif
    return;
  } else {
    if (front == -1) {
      front = 0;
    }
    rear++;
    dataQueue[rear] = value;
  }
}

boolean dequeue(char *c) {
  if (front == -1 || rear == -1) {
    return 0;
  } else {
    *c = dataQueue[front];
    front++;
    if (front - 1 == rear) {
      front = -1;
      rear = -1;
    }
    return 1;
  }
}

int queueSize() {
  if (rear == -1 && front == -1) {
    return 0;
  }

  return rear - front + 1;
}

boolean bunchDequeue(char *ptr, int size) {
  if (rear - front + 1 >= size) {
    if (memcpy(ptr, &dataQueue[front], size)) {
      front += size;
      if (front - 1 == rear) {
        front = -1;
        rear = -1;
      }
      return 1;
    } else {
      #ifdef DEBUG_MODE
      Serial.print("Memcpy failed...");
      #endif
    }
  }
  return 0;
}





