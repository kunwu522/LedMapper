import processing.serial.*;

final int NUM_STRIPS = 4;
final int NUM_LEDS = 16;

final String portName1 = "/dev/cu.usbmodem3162511"; 
final String portName2 = "/dev/cu.usbmodem3071001";

Serial[] ports = new Serial[2];
//Serial port1;
//Serial port2;
RecieveSerialThread thread1;
RecieveSerialThread thread2;

void setup() {
  size(400, 200);
  
  String[] list = Serial.list();
  delay(50);
  println("Serial Ports List:");
  printArray(list);
  println();
  
  ports[0] = new Serial(this, portName1, 921600);
  if (ports[0] == null) {
    println("Error, Serial port " + portName1 + " does not exist.");
    exit();
    return;
  }
  
  ports[1] = new Serial(this, portName2, 921600);
  if (ports[1] == null) {
    println("Error, Serial port " + portName2 + " does not exist.");
    exit();
    return;
  }
  
  thread1 = new RecieveSerialThread(ports[0], portName1);
  thread1.start();
  
  thread2 = new RecieveSerialThread(ports[1], portName2);
  thread2.start();
}

void draw() {
  background(0);
}

int whiteLine = 0;
void mousePressed() {
  byte[] data = new byte[NUM_STRIPS * 3 / 2 + 1];
  for (int strip = 0; strip < 2; strip++) {
    data[0] = '*';
    int offset = 1;
    for(int i = 0; i < 2; i++) {
      int r = (int)random(255);
      int g = (int)random(255);
      int b = (int)random(255);
      data[offset++] = (byte)(r & 0xFF);
      data[offset++] = (byte)(g & 0xFF);
      data[offset++] = (byte)(b & 0xFF);
    }
    ports[strip].write(data);
    println("Sent data: " + bytesToHex(data));
  }

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