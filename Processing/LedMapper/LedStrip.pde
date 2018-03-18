
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
}