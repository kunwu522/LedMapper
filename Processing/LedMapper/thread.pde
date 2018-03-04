class SendDataThread extends Thread {
  String name;
  Serial  port;
  int send_time;
  boolean running;
  boolean sendData;
  byte[] data;

  SendDataThread(String name, Serial port) {
    this.port = port;
    this.name = name;
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
        //println(name + " send data: " + bytesToHex(data));
        int stime = millis();
        sendData = false;
        port.write(data);  // send data over serial to teensy
        send_time = millis() - stime;
      } else {
        yield();
      }
    }
  }
  
  private final  char[] hexArray = "0123456789ABCDEF".toCharArray();
  public String bytesToHex(byte[] bytes) {
    char[] hexChars = new char[bytes.length * 2];
    for ( int j = 0; j < bytes.length; j++ ) {
        int v = bytes[j] & 0xFF;
        hexChars[j * 2] = hexArray[v >>> 4];
        hexChars[j * 2 + 1] = hexArray[v & 0x0F];
    }
    return new String(hexChars);
  }
}

class RecieveDataThread extends Thread {
  String name;
  Serial port;
  boolean running;
  
  RecieveDataThread(String name, Serial port) {
    this.name = name;
    this.port = port;
  }
  
  void start() {
    running = true;
    super.start();
  }
  
  void done() {
    running = false;
  }
  
  void run() {
    while(running) {
      if (port.available() > 0) {
        String response = port.readStringUntil('\n');
        if (response != null) {
          println(name + " response: " + response);
        }
      }
      delay(100);
    }
  }
}