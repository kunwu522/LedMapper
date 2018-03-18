import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class SerialQueueTest extends PApplet {



final int NUM_STRIPS = 10;
final int NUM_LEDS = 620;

final int TUNNEL_WIDTH = 512;
final int TUNNEL_HEIGHT = 620;

final boolean LAUNCH_TEENSY = false;

RecieveSerialThread thread1;
RecieveSerialThread thread2;



public void setup() {
  
  setupStrips();
  if (LAUNCH_TEENSY) setupTeensys();
  //frameRate(30);
}

public void draw() {
  background(169, 169, 169);
  drawStripsWithMouse();
  // drawStrips();
  // drawLine();
  if (LAUNCH_TEENSY) {
    PImage image = get();
    for (Teensy teensy : teensys) {
      teensy.sendCurrentColor(image);
    }
  }
  // delay(1000);
}

/* int litStrip = 0;
int litDirection = 0;
void forthAndBack() {
  for (int port = 0; port < ports.length; port++) {
    byte[] data = new byte[(NUM_STRIPS / 2) *  NUM_LEDS * 3 + 1];
    data[0] = '*';
    int offset = 1;
    for (int strip = 0; strip < NUM_STRIPS / 2; strip++) {
      int c = 0;
      if (litStrip == strip) {
        c = 255;
      }
      for(int i = 0; i < NUM_LEDS; i++) {
        data[offset++] = (byte)(c & 0xFF);
        data[offset++] = (byte)(c & 0xFF);
        data[offset++] = (byte)(c & 0xFF);
      }
    }
    //println(millis() + ", Sent data: " + bytesToHex(data));
    ports[port].write(data);
  }

  if (litDirection == 0) {
    litStrip++;
  } else {
    litStrip--;
  }
  if (litStrip == NUM_STRIPS) {
    litDirection = 1;
  } else if (litStrip == -1) {
    litDirection = 0;
  }
} */

public void mousePressed() {
  for (Teensy teensy : teensys) {
    teensy.colorfulStrips();
  }
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
int x1;
int x2;

public void drawGradient() {
  int x = mouseX;
  x1 = (int)lerp(x1, x, 0.05f); //<>//
  //println("blob x: " + averageX);
  x2 = (int)lerp(x2, x1, 0.1f);

  noStroke();
  //float gradient = 2;
  float tempWidth = abs(x1 - x2) > 20 ? abs(x1 - x2) : 20;
  if (x1 > x2) {
    setGradient(x2, 0, tempWidth, (float)TUNNEL_HEIGHT, color(128, 128, 128), color(255), X_AXIS);
  } else {
    setGradient(x1, 0, tempWidth, (float)TUNNEL_HEIGHT, color(255), color(128, 128, 128), X_AXIS);
  }
}

public void drawLine() {
  int x = mouseX;
  rectMode(CENTER);
  fill(255);
  noStroke();
  rect(x, TUNNEL_HEIGHT / 2, 40, TUNNEL_HEIGHT);
}


int Y_AXIS = 1;
int X_AXIS = 2;
public void setGradient(int x, int y, float w, float h, int c1, int c2, int axis ) {
  noFill();

  if (axis == Y_AXIS) {  // Top to bottom gradient
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      int c = lerpColor(c1, c2, inter);
      stroke(c);
      line(x, i, x+w, i);
    }
  } else if (axis == X_AXIS) {  // Left to right gradient
    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      int c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
  }
}
final int DIRECT_RIGHT = 0;
final int DIRECT_LEFT = 1;
final int DIRECT_STAY = 3;

Strip[] strips = new Strip[NUM_STRIPS];

public void setupStrips() {
  int interval = TUNNEL_WIDTH / (NUM_STRIPS + 1);
  for (int i = 0; i < NUM_STRIPS; i++) {
    strips[i] = new Strip(i, interval * (i + 1));
  }
}


int lightStrip = 0;
int direction = DIRECT_RIGHT;
int tailCount = 2;
public void drawStrips() {
  for (int i = 0; i < strips.length; i++) {
    int c = color(0);
    if (i == lightStrip) {
      c = color(random(255), random(255), random(255));
    }
    if (direction == DIRECT_RIGHT && lightStrip - i > 0 && lightStrip - i <= tailCount) {
      int tempC = (int)(255 * (0.6f / (lightStrip - i)));
      c = color(random(255), random(255), random(255));
    } else if (direction == DIRECT_LEFT && i - lightStrip > 0 && i - lightStrip < tailCount) {
      int tempC = (int)(255 * (0.6f / (i - lightStrip)));
      c = color(random(255), random(255), random(255));
    }
    strips[i].draw(c);
  }
  // for (Strip strip : strips) {
  //   color c = color(0);
  //   if (strip.id == lightStrip) {
  //     c = color(255);
  //   } else {
  //     c = color(0);
  //   }
  //   strip.draw(c);
  // }
  if (direction == DIRECT_RIGHT) {
    lightStrip++;
  } else {
    lightStrip--;
  }

  if (lightStrip == NUM_STRIPS) {
    direction = DIRECT_LEFT;
  } else if (lightStrip == -1) {
    direction = DIRECT_RIGHT;
  }
}

int lastMouseX = 0;
int lastMouseY = 0;
int lastDirection = DIRECT_RIGHT;
public void drawStripsWithMouse() {
  // if (lastMouseX == mouseX && lastMouseY == mouseY) {
  //   return;
  // }
  // direction = mouseX - lastMouseX > 0 ? DIRECT_RIGHT : DIRECT_LEFT;
  if (mouseX > lastMouseX) {
    direction = DIRECT_RIGHT;
  } else if(mouseX < lastMouseX) {
    direction = DIRECT_LEFT;
  } else {
    direction = lastDirection;
  }

  Strip leftStrip = null;
  Strip rightStrip = null;
  for (int i = 0; i < strips.length; i++) {
    strips[i].draw(color(0));
    if (i == strips.length - 1) {
      break;
    }
    if (strips[i].offset < mouseX && strips[i + 1].offset > mouseX) {
      leftStrip = strips[i];
      rightStrip = strips[i + 1];
    }
  }
  if (leftStrip == null || rightStrip == null) {
    return;
  }
  if (direction == DIRECT_RIGHT) {
    for (int i = 0; i < 3; i++) {
      if (leftStrip.id - i >= 0) {
        int c = PApplet.parseInt(255 * ((3 - i) / 3.0f));
        strips[leftStrip.id - i].draw(color(c, c, c));
      }
    }
  } else {
    for (int i = 0; i < 3; i++) {
      if (rightStrip.id + i < strips.length) {
        int c = PApplet.parseInt(255 * ((3 - i) / 3.0f));
        strips[rightStrip.id + i].draw(color(c,c,c));
      }
    }
  }
  lastMouseX = mouseX;
  lastMouseY = mouseY;
  lastDirection = direction;
}

class Strip {
  int id;
  int offset;
  int ledsNum;

  public Strip(int id, int offset) {
    this.id = id;
    this.offset = offset;
  }

  public void draw() {
    stroke(0);
    strokeWeight(2);
    line(offset,0,offset,TUNNEL_HEIGHT);
  }

  public void draw(int c) {
    stroke(c);
    strokeWeight(2);
    line(offset,0,offset,TUNNEL_HEIGHT);
  }
}
final String portName1 = "/dev/cu.usbmodem3162511";
final String portName2 = "/dev/cu.usbmodem2885451";

Teensy[] teensys = new Teensy[2];

public void setupTeensys() {
  String[] list = Serial.list();
  delay(50);
  println("Serial Ports List:");
  printArray(list);
  println();

  teensys[0] = new Teensy(this, portName1);
  teensys[1] = new Teensy(this, portName2);

  int allStrips = 0;
  for (Teensy teeny : teensys) {
    allStrips += teeny.stripsNum;
  }
  if (allStrips != NUM_STRIPS) {
    println("Error, All teensys only launched " + allStrips + " strips, expects " + NUM_STRIPS);
    exit();
    return;
  }
  int offset = 0;
  for (Teensy teensy : teensys) {
    for (int i = 0; i < teensy.stripsNum; i++) {
      if (offset >= NUM_STRIPS) {
        println("Error, strips over range.");
        exit();
        return;
      }
      teensy.stripsPerTeensy[i] = strips[offset++];
    }
  }

  println("Info, finished setup Teensys.");
}

class Teensy {
  Serial port;
  int id;
  int stripsNum;
  int ledsNum;
  Strip[] stripsPerTeensy;
  RecieveSerialThread thread;
  byte[] data;

  public Teensy(PApplet applet, String portName) {
    port = new Serial(applet, portName, 921600);
    if (port == null) {
      println("Error, Serial port " + portName + " does not exist.");
      exit();
      return;
    }
    port.write('?');
    delay(50);

    String info = port.readStringUntil('\n');
    if (info == null) {
      println("Error, Serial port " + portName + " responsed null.");
      exit();
      return;
    }

    String[] param = info.split(",");
    if (param.length != 3) {
      println("Error, Serial port " + portName + "responsed invalid value, " + info);
      exit();
      return;
    }

    this.id = Integer.parseInt(param[0]);
    this.stripsNum = Integer.parseInt(param[1]);
    this.ledsNum = Integer.parseInt(param[2].trim());
    if (ledsNum != NUM_LEDS) {
      println("Error, Serial port " + portName + "s leds number does not match.");
      exit();
      return;
    }

    stripsPerTeensy = new Strip[this.stripsNum];
    data = new byte[this.stripsNum * this.ledsNum * 3 + 1];

    //thread = new RecieveSerialThread(port, portName);
    //thread.start();

    println("Info, Set up teensy" + id + ", " + info);
  }

  public void sendCurrentColor(PImage image) {
    data[0] = '*';
    int offset = 1;
    for (Strip strip : stripsPerTeensy) {
      for (int y = 0; y < TUNNEL_HEIGHT; y++) {
        int index = strip.offset + y * TUNNEL_WIDTH;
        int c = image.pixels[index];
        data[offset++] = (byte)(c >> 16 & 0xFF);
        data[offset++] = (byte)(c >> 8 & 0xFF);
        data[offset++] = (byte)(c & 0xFF);
      }
    }

    port.write(data);
  }

  public void randomWhiteLine() {
    byte[] data = new byte[stripsNum * ledsNum * 3 + 1];
    data[0] = '*';
    int offset = 1;
    for (Strip strip : stripsPerTeensy) {
      int r, g, b;
      if (random(15) < 5) {
        r = 255;
        g = 255;
        b = 255;
      } else {
        r = 0;
        g = 0;
        b = 0;
      }
      for (int j = 0; j < ledsNum; j++) {
        data[offset++] = (byte)(r & 0xFF);
        data[offset++] = (byte)(g & 0xFF);
        data[offset++] = (byte)(b & 0xFF);
      }
    }
    port.write(data);
  }

  public void colorfulStrips() {
    byte[] data = new byte[stripsNum * ledsNum * 3 + 1];
    data[0] = '*';
    int offset = 1;
    for (int i = 0; i < stripsNum; i++) {
      int r = (int)random(255);
      int g = (int)random(255);
      int b = (int)random(255);
      for (int j = 0; j < ledsNum; j++) {
        data[offset++] = (byte)(r & 0xFF);
        data[offset++] = (byte)(g & 0xFF);
        data[offset++] = (byte)(b & 0xFF);
      }
    }
    port.write(data);
  }
}
class RecieveSerialThread extends Thread {
  Serial port;
  String name;
  boolean running;
  
  RecieveSerialThread(Serial port, String name) {
    this.port = port;
    this.name = name;
    println("Create thread to recieving data");
  }
  
  public void start() {
    running = true;
    super.start();
  }
  
  public void done() {
    running = false;
  }
  
  public void run() {
    while(running) {
      if (port.available() > 0) {
        String response = port.readStringUntil('\n');
        if (response != null) {
          println(millis() + name + " responses: " + response);
        }
      }
      delay(100);
    }
  }
}
  public void settings() {  size(512, 620); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "SerialQueueTest" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
