import java.util.*;
import java.io.*;

//SyphonServer syphonServer;
//Serial port;

static int STRIPS_NUM = 8;
static int LEDS_NUM = 16;
static int SCREEN_WIDTH = 512;
static int SCREEN_HEIGHT = 424;

float x1;
float x2;

PGraphics canvas;

List<LedStrip> strips = new ArrayList<LedStrip>();

void setup() {
  size(512, 424, P3D);
  canvas = createGraphics(512, 424, P3D);
  setupTeensy();
  setupStrip();
  //syphonServer = new SyphonServer(this, "Body Movement Simulation");
  //frameRate(10);
}

void draw() {
  canvas.beginDraw();
  canvas.background(0);
  drawStrips();
  drawCursor();
  canvas.endDraw();
  
  image(canvas, 0, 0);
  
  PImage display = get();
  for (Teensy teensy : teensys) {
    teensy.send(display);
  }
  
  ////strips.get(0).updateStrip(get());
  //PImage display = get();
  //ByteArrayOutputStream out = new ByteArrayOutputStream();
  //DataOutputStream dataOut = new DataOutputStream(out);
  //try {
  //  dataOut.write('*');
  //} catch (Exception e) {
  //  e.printStackTrace();
  //}
  //for (LedStrip strip : strips) {
  //  color c = strip.updateStrip(display);
  //  int brightness = c & 0xFF;
  //  int r = c >> 16 & 0xFF;
  //  int g = c >> 8 & 0xFF;
  //  int b = c & 0xFF;
  //  try {
  //    dataOut.write(strip.id);
  //    dataOut.write(brightness);
  //    dataOut.write(r);
  //    dataOut.write(g);
  //    dataOut.write(b);
  //  } catch (Exception e) {
  //    e.printStackTrace();
  //  }
  //}
  //printArray(out.toByteArray());
  //noLoop();
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