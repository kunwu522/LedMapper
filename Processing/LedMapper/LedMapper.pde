import java.util.*;
import java.io.*;

//SyphonServer syphonServer;
//Serial port;

static int SCREEN_WIDTH = 300;
static int SCREEN_HEIGHT = 424;
final int NUM_STRIPS = 8;
final int NUM_LEDS_PER_STRIP = 620;

float x1;
float x2;

PGraphics canvas;

List<LedStrip> strips = new ArrayList<LedStrip>();

void setup() {
  size(300, 424, P3D);
  canvas = createGraphics(SCREEN_WIDTH, 424, P3D);
  setupTeensy();
  //syphonServer = new SyphonServer(this, "Body Movement Simulation");
  //frameRate(15);
}

void draw() {
  canvas.beginDraw();
  canvas.background(169, 169, 169);
  drawStrips();
  drawCursor();
  canvas.endDraw();
  
  image(canvas, 0, 0);
  
  PImage display = get();
  for (Teensy teensy : teensys) {
    teensy.send(display);
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