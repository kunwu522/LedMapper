import processing.serial.*;
import codeanticode.syphon.*;
import java.util.*;

SyphonServer syphonServer;
Serial port;

static int STRIPS_NUM = 8;
static int LEDS_NUM = 16;
static int SCREEN_WIDTH = 512;
static int SCREEN_HEIGHT = 424;
static int GRADIENT = 5;

color[] grey = {color(95, 95, 95), 
                color(128, 128, 128),
                color(169, 169, 169),
                color(203, 203, 203),
                color(255)};

float x1;
float x2;

PGraphics canvas;

List<LedStrip> strips = new ArrayList<LedStrip>();

void setup() {
  size(512, 424, P3D);
  canvas = createGraphics(512, 424, P3D);
  syphonServer = new SyphonServer(this, "Body Movement Simulation");
  printArray(Serial.list());
  if (Serial.list().length > 0) {
    port = new Serial(this, Serial.list()[0]);
  }
}

void draw() {
  canvas.beginDraw();
  canvas.background(0);
  initStrips();
  drawCursor();
  canvas.endDraw();
  
  image(canvas, 0, 0);
  syphonServer.sendImage(canvas);
}

static float LED_WIDTH = 10;
void initStrips() {
  createStrips();
  drawStrips();
}

void createStrips() {
  float interval = SCREEN_WIDTH / (STRIPS_NUM + 1);
  for (int i = 0; i < STRIPS_NUM; i++) {
    LedStrip strip;
    if (i == 0) {
      strip = new LedStrip(i, LEDS_NUM, new PVector(interval - LED_WIDTH / 2, float(0)), LED_WIDTH, SCREEN_HEIGHT);
    } else {
      strip = new LedStrip(i, LEDS_NUM, new PVector(interval * (i + 1) - (LED_WIDTH / 2), 0.0), LED_WIDTH, SCREEN_HEIGHT);
    }
    strips.add(strip);
  }
}

void drawStrips() {
  for (LedStrip strip : strips) {
    strip.drawStrip(canvas);
  }
}

void drawCursor() {
  x1 = lerp(x1, mouseX, 0.1);
  x2 = lerp(x2, x1, 0.1);
  
  canvas.noStroke();
  float gradient = 2;
  float tempWidth = abs(x1 - x2) > 20 ? abs(x1 - x2) : 20;
  for (int i = 0; i < tempWidth; i++) {
    stroke(255 - gradient * i, 255 - gradient * i, 255 - gradient * i);
    if (x1 > x2) {
      line(x1 - i, 0, x1 - i, 424);
    } else {
      line(x1 + i, 0, x1 + i, 424);
    }
  }
}