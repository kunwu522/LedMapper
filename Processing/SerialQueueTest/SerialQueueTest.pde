import processing.serial.*;

final int NUM_STRIPS = 8;
final int NUM_LEDS = 16;

final String portName = "/dev/tty.usbmodem3071001"; 

Serial port;
RecieveSerialThread thread;


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
  
  thread = new RecieveSerialThread(port);
  thread.start();
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
  println("Sent data: " + bytesToHex(data));
  
  //delay(500);
  //String response = port.readStringUntil('\n');
  //if (response == null) {
  //  println("Error: Teensy is not responding.");
  //} else {
  //  println(response);
  //}

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