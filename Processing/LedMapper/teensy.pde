import processing.serial.*;

final int TEENSY_NUM_STRIPS = 8;
final int TEENSY_NUM_LEDS = 16;
final int BAUD_RATE = 921600;

Teensy[] teensys = new Teensy[1];

void setupTeensy() {
  println("Start to setup teensy...");
  String[] list = Serial.list();
  delay(50);
  println("Serial Ports List:");
  printArray(list);
  
  teensys[0] = new Teensy(this, "/dev/cu.usbmodem3071001");
  //teensys[0] = new Teensy(this, "/dev/cu.usbmodem3654571");
  
  println("Teensy setup done!");
  println();
}

class Teensy {
  int id;
  String name;
  Serial port;
  String portName;
  LedStrip[] ledStrips = new LedStrip[TEENSY_NUM_STRIPS];
  byte[] data = new byte[TEENSY_NUM_STRIPS * 3 + 1];
  
  SendDataThread sendThread;
  RecieveDataThread recieveThread;
  
  
  Teensy(PApplet parent, String name) {
    portName = name;
    try {
      port = new Serial(parent, portName, 921600);
      if (port == null) {
        println("Error, port is null.");
        throw new NullPointerException();
      }
      port.write('?');
    } catch (Throwable e) {
      println("Serial Port " + portName + " does not exist.");
      exit();
    }
    
    delay(100);
    String line = port.readStringUntil(10);
    if (line == null) {
      println("Error, Serial port " + portName + " is not responding");
      exit();
      return;
    }
    String param[] = line.split(",");
    if (param.length != 4) {
      println("Error, port " + portName + " invalid reponse: " + line);
      exit();
      return;
    }
    println("Response: " + line);
    id = Integer.parseInt(param[0]);
    name = param[1];
    int stripsNum = Integer.parseInt(param[2]);
    int ledsNum = Integer.parseInt(param[3].trim());
    if (stripsNum != TEENSY_NUM_STRIPS || ledsNum != TEENSY_NUM_LEDS) {
      println("Error -- teensy: " + name + ", the number of leds and strips is not match.");
      exit();
      return;
    }
    
    int interval = floor(SCREEN_WIDTH / (TEENSY_NUM_STRIPS + 1));
    for (int i = 0; i < ledStrips.length; i++) {
      ledStrips[i] = new LedStrip(i, ledsNum, interval + interval * i);
    }
    
    sendThread = new SendDataThread(name + "_send_thread", port);
    sendThread.start();
    
    recieveThread = new RecieveDataThread(name + "_recieve_thread", port);
    recieveThread.start();
    
    println(name + " setup.");
    println();
  }
  
  void send(PImage image) {
    update(image);
    data[0] = '*';
    sendThread.send(data);
  }
  
  void update(PImage image) {
    int offset = 1;
    for (LedStrip strip : ledStrips) {
      color c = image.pixels[strip.offset];
      data[offset++] = (byte)(c >> 16 & 0xFF);
      data[offset++] = (byte)(c >> 8 & 0xFF);
      data[offset++] = (byte)(c & 0xFF);
    }
  }
}