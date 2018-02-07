import processing.serial.*;

Teensy[] teensys = new Teensy[1];

void setupTeensy() {
  println("Start to setup teensy...");
  String[] list = Serial.list();
  delay(20);
  println("Serial Ports List:");
  println(list);
  
  teensys[0] = new Teensy(this, "/dev/cu.usbmodem3071001");
  
  println("Teensy setup done!");
  println();
}

class Teensy {
  byte[] data;
  Serial port;
  String port_name;
  LedStrip[] ledStrips;
  
  
  Teensy(PApplet parent, String name) {
    port_name = name;
    try {
      port = new Serial(parent, port_name, 921600);
      if (port == null) {
        println("Error, port is null.");
        throw new NullPointerException();
      }
      port.write('?');
    } catch (Throwable e) {
      println("Serial Port " + port_name + " does not exist.");
      exit();
    }
    
    delay(20);
    String line = port.readStringUntil(10);
    if (line == null) {
      println("Error, Serial port " + port_name + " is not responding");
      exit();
    }
    String param[] = line.split(",");
    if (param.length == 0) {
      println("Error, port " + port_name + " did not respond LED information.");
      exit();
    }
    int stripsNum = Integer.parseString(param[0]);
    
    
    data = new byte[];
  }
  
  void send(PImage image) {
    update(image);
    data[0] = '*';
    port.write(data);
  }
  
  void update(PImage image) {
    
  }
}