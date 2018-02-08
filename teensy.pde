import processing.serial.*;

Teensy[] teensys = new Teensy[1];

void setupTeensy() {
  println("Start to setup teensy...");
  String[] list = Serial.list();
  delay(20);
  println("Serial Ports List:");
  printArray(list);
  println();
  
  teensys[0] = new Teensy(this, "/dev/cu.usbmodem3071001");
  
  for (Teensy teensy : teensys) {
    totalStripsNum += teensy.ledStrips.size();
  }
  println("Teensy setup done!");
  println();
}

class Teensy {
  byte[] data;
  Serial port;
  String portName;
  List<LedStrip> ledStrips;
  
  
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
    
    delay(20);
    String line = port.readStringUntil(10);
    if (line == null) {
      println("Error, Serial port " + portName + " is not responding");
      exit();
    }
    String param[] = line.split(",");
    if (param.length == 0) {
      println("Error, port " + portName + " did not respond LED information.");
      exit();
    }
    
    int stripsNum = Integer.parseInt(param[0]);
    if (stripsNum > 0 && param.length == (stripsNum * 2 + 1)) {
      ledStrips = new ArrayList();
      for (int i = 1; i < param.length; i+=2) {
        int id = Integer.parseInt(param[i].trim());
        int ledNum = Integer.parseInt(param[i+1].trim());
        LedStrip strip = new LedStrip(id, ledNum);
        ledStrips.add(strip);
      }
    } else {
      println("Error, port " + portName + " did not respond valid LED strip number." 
              + "StripsNum: " + stripsNum + ", param length: " + param.length);
      exit();
    }
    
    int dataSize =1;
    for (LedStrip strip : ledStrips) {
      dataSize++; // For Led Strip brightness
      dataSize += strip.ledNum * 3;
    }
    data = new byte[dataSize];
    
    print("Info, Found " + ledStrips.size() + " strips, with " + ((LedStrip)ledStrips.get(0)).ledNum + " Leds. ");
    println("Totle byte size is " + dataSize + ".");
    
    println(portName + " setup.");
    println();
  }
  
  void send(PImage image) {
    update(image);
    data[0] = '*';
    port.write(data);
    
    delay(50);
    //String line = port.readStringUntil(10);
    //println("Response: " + line);
  }
  
  void update(PImage image) {
    int offset = 1;
    for (LedStrip strip : ledStrips) {
      strip.update(image);
      data[offset++] = (byte)strip.brightness;
      data[offset++] = (byte)(strip.c >> 16 & 0xFF);
      data[offset++] = (byte)(strip.c >> 8 & 0xFF);
      data[offset++] = (byte)(strip.c & 0xFF);
    }
  }
}