class RecieveSerialThread extends Thread {
  Serial port;
  String name;
  boolean running;
  
  RecieveSerialThread(Serial port, String name) {
    this.port = port;
    this.name = name;
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
          println(name + " responses: " + response);
        }
      }
      delay(100);
    }
  }
}