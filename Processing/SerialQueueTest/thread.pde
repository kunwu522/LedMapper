class RecieveSerialThread extends Thread {
  Serial port;
  boolean running;
  
  RecieveSerialThread(Serial port) {
    this.port = port;
    println("Create thread to recieving data");
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
          println("Response: " + response);
        }
      }
      delay(100);
    }
  }
}