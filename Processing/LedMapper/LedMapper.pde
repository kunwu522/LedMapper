import java.util.*;
import java.io.*;

//SyphonServer syphonServer;
//Serial port;

final int STRIPS_NUM = 5;
final int LEDS_NUM = 620;
final int SCREEN_WIDTH = 273;
final int SCREEN_HEIGHT = 424;

final int MAX_BRIGHTNESS = 128;

float x1;
float x2;

PGraphics canvas;

List<LedStrip> strips = new ArrayList<LedStrip>();

void setup() {
  size(273, 424, P3D);
  canvas = createGraphics(SCREEN_WIDTH, 424, P3D);
  setupTeensy();
  //setupStrip();
  //syphonServer = new SyphonServer(this, "Body Movement Simulation");
  //frameRate(15);
}

void draw() {
  canvas.beginDraw();
  canvas.background(169,169,169);
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

void mousePressed() {
  int x = teensys[0].ledStrips[0].offset;
  println("offset of " + x);
  
  println(bytesToHex(teensys[0].data));
}

final  char[] hexArray = "0123456789ABCDEF".toCharArray();
public String bytesToHex(byte[] bytes) {
  char[] hexChars = new char[bytes.length * 2];
  for ( int j = 0; j < bytes.length; j++ ) {
      int v = bytes[j] & 0xFF;
      hexChars[j * 2] = hexArray[v >>> 4];
      hexChars[j * 2 + 1] = hexArray[v & 0x0F];
  }
  return new String(hexChars);
}