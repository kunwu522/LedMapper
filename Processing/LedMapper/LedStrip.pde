
static float LED_WIDTH = 10;

int totalStripsNum = 0;

void setupStrip() {
  float interval = SCREEN_WIDTH / (totalStripsNum + 1);
  int stripsOffset = 0;
  for (Teensy teensy : teensys) {
    for (LedStrip strip : teensy.ledStrips) {
      if (stripsOffset == 0) {
        strip.corner = new PVector(interval - LED_WIDTH / 2, 0.0);
        strip.width = LED_WIDTH;
        strip.height = SCREEN_HEIGHT;
      } else {
        strip.corner = new PVector(interval * (stripsOffset + 1) - (LED_WIDTH / 2), 0.0);
        strip.width = LED_WIDTH;
        strip.height = SCREEN_HEIGHT;
      }
      stripsOffset++;
    }
  }
}

void drawStrips() {
  for (Teensy teensy : teensys) {
    for (LedStrip strip : teensy.ledStrips) {
      strip.drawStrip(canvas);
    }
  }
}


class LedStrip {
  int id;
  int ledNum;
  PVector corner;
  float width;
  float height;
  
  boolean isHorizontal;
  
  color c;
  int brightness;
  
  public LedStrip(int id, int ledNum) {
    this.id = id;
    this.ledNum = ledNum;
  }
  
  public LedStrip(int id, int ledNum, PVector corner, float width, float height) {
    this.id = id;
    this.ledNum = ledNum;
    this.corner = corner;
    this.width = width;
    this.height = height;
    this.isHorizontal = false;
  }
  
  public void drawStrip(PGraphics canvas) {
    canvas.noFill();
    canvas.stroke(0, 0, 255);
    canvas.strokeWeight(1);
    canvas.rect(corner.x, corner.y, width, height);
    //if (isHorizontal) {
    //  float spacing = width / ledNum;
    //  for (int i = 1; i < ledNum; i++) {
    //    canvas.line(corner.x + i * spacing, corner.y, corner.x + i * spacing, corner.y + height);
    //  }
    //} else {
    //  float spacing = height / ledNum;
    //  for (int i = 1; i < ledNum; i++) {
    //    canvas.line(corner.x, corner.y + i * spacing, corner.x + width, corner.y + i * spacing);
    //  }
    //}
  }
  
  //color lastColor = color(0);
  public void update(PImage image) {
    color brightest = color(0);
    for (int i = int(corner.x); i < corner.x + width; i++) {
      int index = i + 10 * 512;
      color c = image.pixels[index];
      int r = c >> 16 & 0xFF;
      int g = c >> 8 & 0xFF;
      int b = c & 0xFF;
      if (r != g || r != b || g != b) {
        continue;
      }
      if (compareColors(brightest, c) == -1) {
        brightest = c;
      }
    }
    c = brightest;
    brightness = brightest & 0xFF;
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