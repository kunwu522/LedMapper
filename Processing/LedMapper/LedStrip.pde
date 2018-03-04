
static float LED_WIDTH = 10;

int totalStripsNum = 0;

LedStrip[] strips = new LedStrip[NUM_STRIPS];

void setupStrips() {
  int interval = floor(SCREEN_WIDTH / (NUM_STRIPS + 1));
  for (int i = 0; i < NUM_STRIPS; i++) {
    strips[i] = new LedStrip(i, NUM_LEDS_PER_STRIP, interval + (interval * i));
  }
}

void drawStrips() {
  //for (LedStrip strip : strips) {
  //  strip.drawStrip(canvas);
  //}
  for (Teensy teensy : teensys) {
    for (LedStrip strip : teensy.ledStrips) {
      strip.drawStrip(canvas);
    }
  }
}


class LedStrip {
  int id;
  int ledNum;
  int offset;
  
  public LedStrip(int id, int ledNum, int offset) {
    this.id = id;
    this.ledNum = ledNum;
    this.offset = offset;
  }
  
  public void drawStrip(PGraphics canvas) {
    canvas.noFill();
    canvas.stroke(0, 0, 0);
    canvas.strokeWeight(2);
    canvas.line(offset, 0, offset, SCREEN_HEIGHT);
  }
  
  private boolean isEqualColorWithThreshold(color c1, color c2) {
    int r1 = c1 >> 16 & 0xFF;
    int g1 = c1 >> 8 & 0xFF;
    int b1 = c1 & 0xFF;
    int r2 = c2 >> 16 & 0xFF;
    int g2 = c2 >> 8 & 0xFF;
    int b2 = c2 & 0xFF;
    
    if (r1 != g1 || r1 != b1 || b1 != g1) {
      println("Error, invalid color: " + r1 + "-" + g1 + "-" + b1);
      return true;
    }
    
    if (r2 != g2 || r2 != b2 || g2 != b2) {
      println("Error, invalid color: " + r2 + "-" + g2 + "-" + b2);
      return true;
    }
    
    if (abs(r2 - r1) > 30) {
      return false;
    } else {
      return true;
    }
  }
  
  
  private int compareColors(color c1, color c2) {
    int r1 = c1 >> 16 & 0xFF;
    int g1 = c1 >> 8 & 0xFF;
    int b1 = c1 & 0xFF;
    int r2 = c2 >> 16 & 0xFF;
    int g2 = c2 >> 8 & 0xFF;
    int b2 = c2 & 0xFF;
    
    if (r1 == r2 && g1 == g2 && b1 == b2) {
      return 0;
    } else if (r1 > r2 || g1 > g2 || b1 > b2) {
      return 1;
    } else {
      return -1;
    }
  }
}