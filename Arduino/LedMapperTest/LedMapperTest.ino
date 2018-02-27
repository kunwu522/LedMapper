#include "FastLED.h"


#define NUM_LEDS  16
#define NUM_STRIPS  8

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

CRGB leds[NUM_STRIPS][NUM_LEDS];

//char data[NUM_STRIPS * (3 + 1)];
const int maxQueueSize = (NUM_STRIPS * 3 + 1) * 3;
char dataQueue[maxQueueSize];
int front = -1, rear = -1;

int mode = 0;

void setup() {
  Serial.setTimeout(100);

  #ifdef TEST_MODE
    Serial.begin(115200);
  #endif
  
  FastLED.addLeds<WS2812B, DATA_PIN0, RGB>(leds[0], NUM_LEDS);
  FastLED.addLeds<WS2812B, DATA_PIN1, RGB>(leds[1], NUM_LEDS);
  FastLED.addLeds<WS2812B, DATA_PIN2, RGB>(leds[2], NUM_LEDS);
  FastLED.addLeds<WS2812B, DATA_PIN3, RGB>(leds[3], NUM_LEDS);
  FastLED.addLeds<WS2812B, DATA_PIN4, RGB>(leds[4], NUM_LEDS);
  FastLED.addLeds<WS2812B, DATA_PIN5, RGB>(leds[5], NUM_LEDS);
  FastLED.addLeds<WS2812B, DATA_PIN6, RGB>(leds[6], NUM_LEDS);
  FastLED.addLeds<WS2812B, DATA_PIN7, RGB>(leds[7], NUM_LEDS);
//  FastLED.addLeds<WS2812B, DATA_PIN8, RGB>(leds[8], NUM_LEDS);
//  FastLED.addLeds<WS2812B, DATA_PIN9, RGB>(leds[9], NUM_LEDS);
//  FastLED.addLeds<WS2812B, DATA_PIN10, RGB>(leds[10], NUM_LEDS);
//  FastLED.addLeds<WS2812B, DATA_PIN11, RGB>(leds[11], NUM_LEDS);
//  FastLED.addLeds<WS2812B, DATA_PIN12, RGB>(leds[12], NUM_LEDS);
//  FastLED.addLeds<WS2812B, DATA_PIN13, RGB>(leds[13], NUM_LEDS);
//  FastLED.addLeds<WS2812B, DATA_PIN14, RGB>(leds[14], NUM_LEDS);
//  FastLED.addLeds<WS2812B, DATA_PIN15, RGB>(leds[15], NUM_LEDS);
//  FastLED.addLeds<WS2812B, DATA_PIN16, RGB>(leds[16], NUM_LEDS);
//  FastLED.addLeds<WS2812B, DATA_PIN17, RGB>(leds[17], NUM_LEDS);
//  FastLED.addLeds<WS2812B, DATA_PIN18, RGB>(leds[18], NUM_LEDS);
//  FastLED.addLeds<WS2812B, DATA_PIN19, RGB>(leds[19], NUM_LEDS);
//  FastLED.addLeds<WS2812B, DATA_PIN20, RGB>(leds[20], NUM_LEDS);
//  FastLED.addLeds<WS2812B, DATA_PIN21, RGB>(leds[21], NUM_LEDS);

  for (int i = 0; i < NUM_STRIPS; i++) {
    fill_solid(leds[i], NUM_LEDS, CRGB::Black);
  }
  FastLED.show();
}

void loop() {
  while(Serial.available() > 0 && queueSize() < maxQueueSize) {
    enqueue(Serial.read());
  }

//  if (dataQueue[0] == '?') {
//    char startByte;
//    dequeue(&startByte);
//    response();
//  }

  if (queueSize() > 0) {
//    Serial.print("Queue buffer size: ");
//    Serial.print(queueSize());
//    Serial.print("-----");
    char data;
    while (dequeue(&data)) {
      Serial.print(data, HEX);
    }
    Serial.print('\n');
  } else {
    Serial.print("Front is ");
    Serial.print(front);
    Serial.print(", Rear is ");
    Serial.print(rear);
    Serial.print('\n');
  }

//
//  if (queueSize() > NUM_STRIPS * 3 + 1) {
//    processQueue();  
//  }
}

void response() {
  Serial.print(NUM_STRIPS);
  Serial.write(',');
  Serial.print(DATA_PIN0);
  Serial.write(',');
  Serial.print(NUM_LEDS);
  Serial.write(',');
  Serial.print(DATA_PIN1);
  Serial.write(',');
  Serial.print(NUM_LEDS);
  Serial.write(',');
  Serial.print(DATA_PIN2);
  Serial.write(',');
  Serial.print(NUM_LEDS);
  Serial.write(',');
  Serial.print(DATA_PIN3);
  Serial.write(',');
  Serial.print(NUM_LEDS);
  Serial.write(',');
  Serial.print(DATA_PIN4);
  Serial.write(',');
  Serial.print(NUM_LEDS);
  Serial.write(',');
  Serial.print(DATA_PIN5);
  Serial.write(',');
  Serial.print(NUM_LEDS);
  Serial.write(',');
  Serial.print(DATA_PIN6);
  Serial.write(',');
  Serial.print(NUM_LEDS);
  Serial.write(',');
  Serial.print(DATA_PIN7);
  Serial.write(',');
  Serial.print(NUM_LEDS);
  Serial.print('\n');
}

void showLeds(char data[]) {
  char *dataPtr = data;
  for (int i = 0; i < NUM_STRIPS; i++) {
    CRGB color = CRGB(dataPtr[1], dataPtr[2], dataPtr[3]);
    fill_solid(leds[i], NUM_LEDS, color);
    dataPtr += 3;
  }
  FastLED.setBrightness(128);
  FastLED.show();
}

void processQueue() {
  #ifdef TEST_MODE
    Serial.println("Standard Running, waiting data...");
  #endif
  char startByte;
  if (!dequeue(&startByte)) return;
  if (startByte == '*') {
    char data[NUM_STRIPS * 3];
    while (bunchDequeue(data, NUM_STRIPS * 3)) {
      showLeds(data);
    }
  }
}

/*
 * For Queue Buffer
 */

void enqueue(char value) {
  if (rear == maxQueueSize - 1) {
    #ifdef TEST_MODE
      Serial.println("Error: Queue is Full!");
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
    #ifdef TEST_MODE
      Serial.println("Error: Queue is empty!");
    #endif
    return 0;
  } else {
    *c = dataQueue[front];
    front++;
    if (front == rear) {
      front = -1;
      rear = -1;
    }
    return 1;
  }
}

int queueSize() {
  return rear - front + 1;
}

boolean bunchDequeue(char *ptr, int size) {
  if (rear - front >= size) {
    if (memcpy(ptr, &dataQueue[front], size)) {
      front += size;
      if (front == rear) {
        front = -1;
        rear = -1;
      }
      return 1;
    } else {
      Serial.write("Memcpy failed...");
    }
  } else {
    Serial.print("Queue size ");
    Serial.print(rear - front);
    Serial.print(", need copy size: ");
    Serial.print(size);
  }
  return 0;
}





