import processing.serial.*;

final int NUM_STRIPS = 10;
final int NUM_LEDS = 620;

final int TUNNEL_WIDTH = 512;
final int TUNNEL_HEIGHT = 620;

final boolean LAUNCH_TEENSY = true;

RecieveSerialThread thread1;
RecieveSerialThread thread2;



void setup() {
  size(512, 620);
  setupStrips();
  if (LAUNCH_TEENSY) setupTeensys();
  //frameRate(30);
}

void draw() {
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

void mousePressed() {
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