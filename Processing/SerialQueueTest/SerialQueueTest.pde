import processing.serial.*;

final int NUM_STRIPS = 8;
final int NUM_LEDS = 16;

final String portName = "/dev/cu.usbmodem107"; 
Serial port;

void setup() {
  size(400, 200);
  
  String[] list = Serial.list();
  delay(50);
  println("Serial Ports List:");
  printArray(list);
  println();
  
  port = new Serial(this, portName, 921600);
  if (port == null) {
    println("Error, Serial port " + portName + " does not exist.");
    exit();
    return;
  }
  port.write('?');
  
  delay(100);
  String line = port.readStringUntil(10);
  if (line == null) {
    println("Error, SErial port " + portName + " was not responding.");
    exit();
    return;
  }
}

void draw() {
  background(0);
}

int whiteLine = 0;
void mousePressed() {
  byte[] data = new byte[NUM_STRIPS * 3 + 1];
  data[0] = '*';
  int offset = 1;
  for (int i = 0; i < NUM_STRIPS; i++) {
    if (i == whiteLine) {
      data[offset++] = (byte)(255 & 0xFF);
      data[offset++] = (byte)(255 & 0xFF);
      data[offset++] = (byte)(255 & 0xFF);
    } else {
      data[offset++] = (byte)(0 & 0xFF);
      data[offset++] = (byte)(0 & 0xFF);
      data[offset++] = (byte)(0 & 0xFF);
    }
  }
  port.write(data);
  println("Send data: " + bytesToHex(data));
  if (whiteLine < 8) {
    whiteLine++;
  } else {
    whiteLine = 0;
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