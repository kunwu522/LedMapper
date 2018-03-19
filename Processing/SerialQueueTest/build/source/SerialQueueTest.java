import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.serial.*; 
import org.openkinect.freenect.*; 
import org.openkinect.freenect2.*; 
import org.openkinect.processing.*; 
import org.openkinect.tests.*; 
import java.util.*; 

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
final boolean LAUNCH_KINECT = false;

RecieveSerialThread thread1;
RecieveSerialThread thread2;

public void setup() {
  
  setupStrips();
  // setupKinectSimulator();
  if (LAUNCH_KINECT) setupKinect();
  if (LAUNCH_TEENSY) setupTeensys();
  //frameRate(30);
}

public void draw() {
  background(169, 169, 169);
  if (LAUNCH_KINECT) drawKinect();
  // drawStripsWithPos(objectX, objectY);
  drawBreathLine();
  if (LAUNCH_TEENSY) {
    PImage image = get();
    for (Teensy teensy : teensys) {
      teensy.sendCurrentColor(image);
    }
  }
  //image(kinect2.getDepthImage(), 512, 0);
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

//void mousePressed() {
//  for (Teensy teensy : teensys) {
//    teensy.colorfulStrips();
//  }
//}

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

boolean cmdPressed = false;
public void keyPressed() {
  if (key == CODED) {
    if (keyCode == 157) cmdPressed = true;
  } else {
    if (cmdPressed && key == 'b') {
      saveBackground = true;
    } else if (cmdPressed && key == 's') {
      //smoothImage.save("image/smooth" + millis() + ".jpg");
    } else if (cmdPressed && key == 'p') {
      //writeToFile();
    } else if (cmdPressed && key == 'e') {
      //printDepth = true;
    }
  }
}

public void saveBackgounndImage() {
  background = get(512, 0, 512, 424);
  background.save("image/background.jpg");
}
int x1;
int x2;

int objectX = 0;
int objectY = 0;

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







final int KINECT_DEPTH_WIDTH = 512;
final int KINECT_DEPTH_HEIGHT = 424;

Kinect2 kinect2;

PImage background;
// PImage smoothImage;
File[] dataFiles;
// ArrayList<Blob> blobs = new ArrayList<Blob>();

public void setupKinect() {
  kinect2 = new Kinect2(this);
  if (kinect2.getNumKinects() == 0) {
    exit();
    return;
  }

  kinect2.initDepth();
  kinect2.initDevice();

  if (kinect2.depthWidth != KINECT_DEPTH_WIDTH
    || kinect2.depthHeight != KINECT_DEPTH_HEIGHT) {
    println("Error, Kinect depth size do not match");
    exit();
    return;
  }

  background = loadImage("image/background.jpg");
  if (background == null) {
    background = createImage(KINECT_DEPTH_WIDTH, KINECT_DEPTH_HEIGHT, RGB);
  }
}

public void setupKinectSimulator() {
  int[] backgroundDepth = loadDepth("background.dat");
  if (backgroundDepth == null) {
    exit();
    return;
  }
  background = getDenoisedDepthImage(backgroundDepth);

  File directory = new File("/Users/tonywu/Desktop/SerialQueueTest/data");
  if (directory.isDirectory()) {
    dataFiles = directory.listFiles();
  } else {
    println("Error, invalid file path. " + directory.getAbsolutePath());
    exit();
    return;
  }
  println("Finished set up, " + dataFiles.length + " files are launched.");
}

boolean saveBackground = false;
public void drawKinect() {
  PImage smoothImage = getDenoisedDepthImage(kinect2.getRawDepth());
  detectBlob(smoothImage);
  if (saveBackground) {
    smoothImage.save("image/background.jpg");
    saveBackground = false;
  }
  image(smoothImage, 0, 620);
}

int fileOffset = 0;
public void drawKinectSimulator() {
  if (fileOffset >= dataFiles.length) {
      println("offset is over range of files, offset is " + fileOffset);
      exit();
      return;
    }
    String filePath = dataFiles[fileOffset].getAbsolutePath();
    int[] rawDepth = loadDepth(filePath);
    if (rawDepth == null) {
      exit();
      return;
    }
    // int t1 = millis();
    PImage smoothImage = getDenoisedDepthImage(rawDepth);
    // int t2 = millis();
    detectBlob(smoothImage);
    // int t3 = millis();
    // image(smoothImage, 0, 0);

    // fill(255);
    //println("Blob pos: " + averageX + "-" + averageY);
    // println("Time usage: step1----" + (t2 - t1) + ", step2----" + (t3 - t2));
    fileOffset++;
}

/*
 * Reading binary file, return depth int array
 *
 */
public int[] loadDepth(String filename) {
 byte[] data = loadBytes(filename);
 if (data == null || data.length == 0) {
   println("Can not read data from " + filename);
   exit();
   return null;
 }
 int[] depth = new int[data.length / 2];
 int index = 0;
 for (int i = 0; i < data.length; i+=2) {
   // if (offset < data.length / 2) {
     depth[index++] = ((data[i] & 0xFF) << 8) | (data[i + 1] & 0xFF);
   // }
 }
 return depth;
}

int innerBandThreshold = 3;
int outerBandThreshold = 5;
int avarageThreshold = 30;
public PImage getDenoisedDepthImage(int[] rawDepth) {
  // int[] smoothDepth = new int[rawDepth.length];
  PImage image = createImage(KINECT_DEPTH_WIDTH,KINECT_DEPTH_HEIGHT,RGB);
  int widthBound = KINECT_DEPTH_WIDTH - 1;
  int heightBound = KINECT_DEPTH_HEIGHT - 1;
  image.loadPixels();
  for (int x = 0; x < KINECT_DEPTH_WIDTH; x++) {
    for (int y = 0; y < KINECT_DEPTH_HEIGHT; y++) {
      int smoothDepth = 0;
      int offset = x + y * KINECT_DEPTH_WIDTH;
      if (rawDepth[offset] == 0) {
        Map<Integer, Integer> frequencyMap = new HashMap<Integer, Integer>();
        int innerBandCount = 0;
        int outerBandCount = 0;
        for (int i = -2; i < 3; i++) {
          for (int j = -2; j < 3; j++) {
            int nearX = x + i;
            int nearY = y + j;
            if (nearX >=0 && nearX <= widthBound
                && nearY >=0 && nearY <= heightBound) {
              int index = nearX + nearY * KINECT_DEPTH_WIDTH;
              if (rawDepth[index] != 0) {
                Integer depth = Integer.valueOf(rawDepth[index]);
                if (frequencyMap.containsKey(depth)) {
                  frequencyMap.put(depth, frequencyMap.get(depth) + 1);
                } else {
                  frequencyMap.put(depth, 1);
                }
                if (i != 2 && i != -2 && j != 2 && j != -2) {
                  innerBandCount++;
                } else {
                  outerBandCount++;
                }
              }
            }
          }
        }

        if (innerBandCount >= innerBandThreshold || outerBandCount >= outerBandThreshold) {
          int depth = 0;
          Object[] values = frequencyMap.values().toArray();
          Arrays.sort(values, new Comparator<Object>() {
              @Override
              public int compare(Object o1, Object o2) {
                  Integer i1 = (Integer)o1;
                  Integer i2 = (Integer)o2;
                  if (i1.intValue() > i2.intValue()) {
                      return -1;
                  } else {
                      return 1;
                  }
              }
          });
          for (Map.Entry<Integer, Integer> e : frequencyMap.entrySet()) {
              if (e.getValue().intValue() == ((Integer)values[0]).intValue()) {
                  depth = e.getKey().intValue();
                  break;
              }
          }
          smoothDepth = depth;
        }
      } else {
        smoothDepth = rawDepth[offset];
      }

      float rate = 0;
      if (smoothDepth != 0) {
        rate = PApplet.parseFloat(4500 - smoothDepth) / 4500.0f;
      }
      image.pixels[offset] = color(255 * rate, 255 * rate, 255 * rate);
    }
  }
  image.updatePixels();
  return image;
}


/******************************
*
*  Background subtraction
*
*
*******************************/
public void detectBlob(PImage image) {
  int sumX = 0;
  int sumY = 0;
  int count = 0;
  boolean foundBlob = false;
  for (int x = 0; x < KINECT_DEPTH_WIDTH; x++) {
    for (int y = 0; y < KINECT_DEPTH_HEIGHT; y++) {
      if (isBlobDiff(background, image, x, y, 5)) {
        sumX += x;
        sumY += y;
        count++;
        foundBlob = true;
      }
    }
  }
  if (foundBlob) {
    objectX = PApplet.parseInt(sumX / count);
    objectY = PApplet.parseInt(sumY / count);
  } else {
    objectX = -20;
    objectX = -20;
  }
}

public boolean isBlobDiff(PImage background, PImage image, int x, int y, int threshold) {
  if (background == null) {
    return false;
  }
  boolean isDiff = true;
  for (int i = -threshold; i <= threshold; i++) {
    for (int j = -threshold; j <= threshold; j++) {
      int nearX = x + i;
      int nearY = y + j;
      if (nearX >= 0 && nearX < KINECT_DEPTH_WIDTH
        && nearY >= 0 && nearY < KINECT_DEPTH_HEIGHT) {
        int nearIndex = nearX + nearY * KINECT_DEPTH_WIDTH;
        int bgColor = background.pixels[nearIndex];
        int currentColor = image.pixels[nearIndex];
        if (diffColor(bgColor, currentColor) < 30 * 30) {
          isDiff = false;
        }
      }
    }
  }
  return isDiff;
}

public int diffColor(int c1, int c2) {
  int r1 = c1 >> 16 & 0xFF;
  int g1 = c1 >> 8 & 0xFF;
  int b1 = c1 & 0xFF;

  int r2 = c2 >> 16 & 0xFF;
  int g2 = c2 >> 8 & 0xFF;
  int b2 = c2 & 0xFF;


  return (r2-r1)*(r2-r1) + (g2-g1)*(g2-g1) + (b2-b1)*(b2-b1);
}
final int NUM_LEDS_PER_STRIP = 620;

final int DIRECT_RIGHT = 0;
final int DIRECT_LEFT = 1;
final int DIRECT_STAY = 2;

Strip[] strips = new Strip[NUM_STRIPS];
Area[] areas = new Area[NUM_STRIPS + 1];

public void setupStrips() {
  int interval = TUNNEL_WIDTH / (NUM_STRIPS + 1);
  for (int i = 0; i < NUM_STRIPS; i++) {
    strips[i] = new Strip(i, interval * (i + 1));
  }

  for (int i = 0; i < areas.length; i++) {
    if (i == 0) {
      areas[i] = new Area(null, strips[0]);
    } else if (i == areas.length - 1) {
      areas[i] = new Area(strips[strips.length - 1], null);
    } else {
      areas[i] = new Area(strips[i - 1], strips[i]);
    }
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

int lastX = 0;
int lastY = 0;
int lastDirection = DIRECT_RIGHT;
public void drawStripsWithPos(int x, int y) {
  if (abs(x - lastX) < 46) {
    direction = DIRECT_STAY;
  } else if(x > lastX) {
    direction = DIRECT_LEFT;
  } else {
    direction = DIRECT_RIGHT;
  }
  for (int i = 0; i < strips.length; i++) {
    strips[i].draw(color(0,0,0));
  }
  for (Area area : areas) {
    if (area.inside(x)) {
      area.updateStripsColor(direction);
    }
  }
  lastX = x;
  lastY = y;
  lastDirection = direction;
}

int bright = 20;
public void drawBreathLine() {
  for (Strip strip : strips) {
    strip.draw(color(bright,bright,bright));
  }
  bright+=20;
  if (bright >= 255) {
    delay(500);
    bright = 20;
  } else {
    delay(50);
  }
}

int stripOffset = 0;
int c1 = randomColor();
int c2 = randomColor();
public void drawRoof() {
  for (int i = 0 ; i < strips.length; i++) {
    float inter = map(i, 0, strips.length, 0, 1);
    int c3 = lerpColor(c1,c2,inter);
    if (i <= stripOffset) {
      strips[i].draw(c3,206,416);
    } else {
      strips[i].draw(color(0));
    }
    // delay(10);
  }
  stripOffset++;
  if (stripOffset == strips.length) {
    stripOffset = 0;
  }
}

public void drawStripsRandom() {
  for (Strip strip : strips) {
    int random = (int)random(20);
    if (random > 10) {
      int r = (int)random(255);
      int g = (int)random(255);
      int b = (int)random(255);
      strip.draw(color(r, g, b));
    } else {
      strip.draw(color(0));
    }
  }
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

  public void draw(int c, int start, int end) {
    strokeWeight(2);
    stroke(0);
    line(offset, 0, offset, start);
    stroke(c);
    line(offset, start, offset, end);
    stroke(0);
    line(offset, end, offset, TUNNEL_HEIGHT);
  }
}

class Area {
  int minX;
  int maxX;
  Strip leftStrip;
  Strip rightStrip;

  public Area(Strip leftStrip, Strip rightStrip) {
    this.minX = leftStrip == null ? 0 : leftStrip.offset;
    this.maxX = rightStrip == null ? TUNNEL_WIDTH : rightStrip.offset;
    this.leftStrip = leftStrip;
    this.rightStrip = rightStrip;
  }

  public boolean inside(int x) {
    return x > minX && x < maxX;
  }

  public void updateStripsColor(int direction) {
    if (direction == DIRECT_RIGHT) {
      if (leftStrip == null) {
        return;
      }
      for (int i = 0; i < 3; i++) {
        if (leftStrip.id - i >= 0) {
          int c = PApplet.parseInt(255 * ((3 - i) / 3.0f));
          strips[leftStrip.id - i].draw(color(c, c, c));
        }
      }
    } else if (direction == DIRECT_LEFT) {
      if (rightStrip == null) {
        return;
      }
      for (int i = 0; i < 3; i++) {
        if (rightStrip.id + i < strips.length) {
          int c = PApplet.parseInt(255 * ((3 - i) / 3.0f));
          strips[rightStrip.id + i].draw(color(c,c,c));
        }
      }
    } else {
      if (leftStrip != null) leftStrip.draw(color(255));
      if (rightStrip != null) rightStrip.draw(color(255));
    }
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
public int randomColor() {
  int r = (int)random(255);
  int g = (int)random(255);
  int b = (int)random(255);
  return color(r,g,b);
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
