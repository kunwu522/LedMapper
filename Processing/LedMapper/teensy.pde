import processing.serial.*;

final int TEENSY_WIDTH = 16;
final int TEENSY_HEIGHT = 8;
final int BAUD_RATE = 921600;

final float RED_GAMMA = 2.1;
final float GREEN_GAMMA = 2.1;
final float BLUE_GAMMA = 2.1;

int[][] gammaTable;

Teensy[] teensys = new Teensy[1];

void setupTeensy() {
  println("Start to setup teensy...");
  String[] list = Serial.list();
  delay(50);
  println("Serial Ports List:");
  printArray(list);
  println();
  
  teensys[0] = new Teensy(this, "/dev/cu.usbmodem82");
  //teensys[0] = new Teensy(this, "/dev/cu.usbmodem3654571");
  
  println("Teensy setup done!");
  println();
}

void setupGamma() {
  gammaTable = new int [256][3];
  float d;
  for (int i = 0; i < 256; i++) {
    d =  i / 255.0;
    gammaTable[i][0] = floor(255 * pow(d, RED_GAMMA) + 0.5); // RED
    gammaTable[i][1] = floor(255 * pow(d, GREEN_GAMMA) + 0.5); // GREEN
    gammaTable[i][2] = floor(255 * pow(d, BLUE_GAMMA) + 0.5); // BLUE
  }
}

class Teensy {
  byte[] data;
  Serial port;
  String portName;
  //List<LedStrip> ledStrips;
  LedStrip[] ledStrips = new LedStrip[TEENSY_HEIGHT];
  SendDataThread thread;
  float   watts;
  
  int sendTime = 0;
  int maxSend = 0;
  
  Teensy(PApplet parent, String name) {
    println("Setting up teensy: " + name + "...");
    data = new byte[(TEENSY_WIDTH * TEENSY_HEIGHT * 6) + 3];
    portName = name;
    try {
      port = new Serial(parent, portName, BAUD_RATE);
      if (port == null) {
        println("Error, port is null.");
        throw new NullPointerException();
      }
      port.write('?');
    } catch (Throwable e) {
      println("Serial Port " + portName + " does not exist.");
      exit();
      return;
    }
    
    delay(100);
    String line = port.readStringUntil(10);
    if (line == null) {
      println("Error, Serial port " + portName + " is not responding");
      exit();
      return;
    }
    String param[] = line.split(",");
    if (param.length != 12) { // didn't get 12 back?  bad news...
      println("Error: port " + portName + " did not respond to LED config query");
      exit();
      return;
    }
    
    int interval = floor(SCREEN_WIDTH / (TEENSY_HEIGHT + 1));
    for (int i = 0; i < ledStrips.length; i++) {
      ledStrips[i] = new LedStrip(i, TEENSY_WIDTH, interval + interval * i);
    }
    
    
    //if (param.length == 0) {
    //  println("Error, port " + portName + " did not respond LED information.");
    //  exit();
    //  return;
    //}
    
    //int stripsNum = Integer.parseInt(param[0]);
    //if (stripsNum > 0 && param.length == (stripsNum * 2 + 1)) {
    //  ledStrips = new ArrayList();
    //  for (int i = 1; i < param.length; i+=2) {
    //    int id = Integer.parseInt(param[i].trim());
    //    int ledNum = Integer.parseInt(param[i+1].trim());
    //    LedStrip strip = new LedStrip(id, ledNum);
    //    ledStrips.add(strip);
    //  }
    //} else {
    //  println("Error, port " + portName + " did not respond valid LED strip number." 
    //          + "StripsNum: " + stripsNum + ", param length: " + param.length);
    //  exit();
    //}
    
    //int dataSize = 1;
    //for (LedStrip strip : ledStrips) {
    //  dataSize++; // For Led Strip brightness
    //  dataSize += 3;
    //}
    //data = new byte[dataSize];
    
    thread = new SendDataThread(port);
    thread.start();
    
    //print("Info, Found " + ledStrips.size() + " strips, with " + ((LedStrip)ledStrips.get(0)).ledNum + " Leds. ");
    //println("Totle byte size is " + dataSize + ".");
    
    println(portName + " setup.");
    println();
  }
  
  color updateColor(color c) {
    int r = (c >> 16) & 0xFF;  // get the red
    int g = (c >> 8) & 0xFF;   // get the green
    int b = c & 0xFF;          // get the blue 

    r = int( map( r, 0, 255, 0, MAX_BRIGHTNESS ) );  // map red to max LED brightness
    g = int( map( g, 0, 255, 0, MAX_BRIGHTNESS ) );  // map green to max LED brightness
    b = int( map( b, 0, 255, 0, MAX_BRIGHTNESS ) );  // map blue to max LED brightness

    r = gammaTable[r][0];  // map red to gamma correction table
    g = gammaTable[g][1];  // map green to gamma correction table
    b = gammaTable[b][2];  // map blue to gamma correction table

    float pixel_watts = map(r + g + b, 0, 768, 0, 0.24);  // get the wattage of the pixel
    watts += pixel_watts; // add pixel wattage to total wattage count (watts is added to WALL_WATTS in wall tab)

    return color(g, r, b, 255); // translate the 24 bit color from RGB to the actual order used by the LED wiring.  GRB is the most common.
  }
  
  void send(PImage image) {
    sendTime = 0;
    int stime = millis();
    update(image);

    data[0] = '*'; 
    data[1] = 0; 
    data[2] = 0;
    
    thread.send(data);
    sendTime = thread.getTime();
    
    sendTime = millis() - stime;
    maxSend = max(sendTime, maxSend);
  }
  
  void update(PImage image) {
    int offset = 3;
    for (int i = offset; i < data.length; i++) {
      data[i] = (byte)128;
      //if (i < 408) {
      //  color c = color(128, 128, 128);
      //  data[offset++] = (byte)(c >> 16 & 0xFF);
      //  data[offset++] = (byte)(c >> 8 & 0xFF);
      //  data[offset++] = (byte)(c & 0xFF);
      //} else {
      //  color c = color(0, 0, 0);
      //  data[offset++] = (byte)(c >> 16 & 0xFF);
      //  data[offset++] = (byte)(c >> 8 & 0xFF);
      //  data[offset++] = (byte)(c & 0xFF);
      //}
    }
    //for (int led = 0; led < TEENSY_WIDTH; led++) {
    //  for (LedStrip strip : ledStrips) {
    //    int y = int(map(led, 0, TEENSY_WIDTH, 0, SCREEN_HEIGHT));
    //    int index = strip.offset + y * SCREEN_WIDTH;
    //    color c = image.pixels[index];
    //    data[offset++] = (byte)(c >> 16 & 0xFF);
    //    data[offset++] = (byte)(c >> 8 & 0xFF);
    //    data[offset++] = (byte)(c & 0xFF);
    //  } 
    //}
  }
}

class SendDataThread extends Thread {
  Serial  port;
  int send_time;
  boolean running;
  boolean sendData;
  byte[] data;

  SendDataThread(Serial port) {
    this.port = port;
    //setDaemon(true);
    //setPriority(3);
    //println(getPriority());
    running = false;
    sendData = false;
    send_time = 0;
  }

  void start() {
    running = true;
    super.start();
  }

  synchronized void send(byte[] data) {
    this.data = data;
    sendData = true;
  }

  int getTime() {
    return send_time;
  }

  void done() {
    running = false;
  }

  void run() {
    while (running) {
      if (sendData) {
        println("Response: " + bytesToHex(data));
        int stime = millis();
        sendData = false;
        port.write(data);  // send data over serial to teensy
        send_time = millis() - stime;
      } else {
        yield();
      }
    }
  }
}