import java.util.*;
import java.io.*;

//SyphonServer syphonServer;
//Serial port;

final int SCREEN_WIDTH = 512;
final int SCREEN_HEIGHT = 424;
final int NUM_STRIPS = 10;
final int NUM_LEDS_PER_STRIP = 620;

final boolean launchKinect = true;

float x1;
float x2;

PGraphics canvas;

void setup() {
  size(512, 424, P3D);
  canvas = createGraphics(SCREEN_WIDTH, 424, P3D);
  setupStrips();
  setupTeensy();
  if (launchKinect) {
    setupKinect();
  }
  //syphonServer = new SyphonServer(this, "Body Movement Simulation");
  //frameRate(15);
}

void draw() {
  canvas.beginDraw();
  canvas.background(169, 169, 169);
  drawStrips();
  drawCursor();
  canvas.endDraw();
  if (launchKinect) {
    drawKinect();
  }
  image(canvas, 0, 0);
  
  PImage display = get();
  for (Teensy teensy : teensys) {
    teensy.send(display);
  }
}

void drawCursor() {
  int x = launchKinect ? averageX : mouseX;
  x1 = lerp(x1, x, 0.1);
  x2 = lerp(x2, x1, 0.2);
  
  float tempWidth = abs(x1 - x2) > 20 ? abs(x1 - x2) : 20;
  if (x1 > x2) {
    setGradient((int)x2, 0, tempWidth, SCREEN_HEIGHT, color(128, 128, 128), color(255), X_AXIS);
  } else {
    setGradient((int)x1, 0, tempWidth, SCREEN_HEIGHT, color(255), color(128, 128, 128), X_AXIS);
  }
  //for (int i = 0; i < tempWidth; i++) {
  //  stroke(255 - gradient * i, 255 - gradient * i, 255 - gradient * i);
  //  if (x1 > x2) {
  //    line(x1 - i, 0, x1 - i, 424);
  //  } else {
  //    line(x1 + i, 0, x1 + i, 424);
  //  }
  //}
}

final int Y_AXIS = 1;
final int X_AXIS = 2;
void setGradient(int x, int y, float w, float h, color c1, color c2, int axis) {

  canvas.noFill();

  if (axis == Y_AXIS) {  // Top to bottom gradient
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      canvas.stroke(c);
      canvas.line(x, i, x+w, i);
    }
  }  
  else if (axis == X_AXIS) {  // Left to right gradient
    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      color c = lerpColor(c1, c2, inter);
      canvas.stroke(c);
      canvas.line(i, y, i, y+h);
    }
  }
}