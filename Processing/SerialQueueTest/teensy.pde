final String portName1 = "/dev/cu.usbmodem3162511";
final String portName2 = "/dev/cu.usbmodem2885451";

Teensy[] teensys = new Teensy[2];

void setupTeensys() {
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

  void sendCurrentColor(PImage image) {
    data[0] = '*';
    int offset = 1;
    for (Strip strip : stripsPerTeensy) {
      for (int y = 0; y < TUNNEL_HEIGHT; y++) {
        int index = strip.offset + y * TUNNEL_WIDTH;
        color c = image.pixels[index];
        data[offset++] = (byte)(c >> 16 & 0xFF);
        data[offset++] = (byte)(c >> 8 & 0xFF);
        data[offset++] = (byte)(c & 0xFF);
      }
    }

    port.write(data);
  }

  void randomWhiteLine() {
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

  void colorfulStrips() {
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