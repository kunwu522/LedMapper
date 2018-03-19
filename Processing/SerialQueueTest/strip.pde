final int NUM_LEDS_PER_STRIP = 620;

final int DIRECT_RIGHT = 0;
final int DIRECT_LEFT = 1;
final int DIRECT_STAY = 2;

Strip[] strips = new Strip[NUM_STRIPS];
Area[] areas = new Area[NUM_STRIPS + 1];

void setupStrips() {
  int interval = TUNNEL_WIDTH / (NUM_STRIPS + 1);
  for (int i = 0; i < NUM_STRIPS; i++) {
    strips[i] = new Strip(i, interval * (i + 1));
  }

  for (int i = 0; i < areas.length; i++) {
    if (i == 0) {
      areas[i] = new Area(null, strips[0]);
    } else if (i == areas.length - 1) {
      areas[i] = new Area(strips[strips.length - 1], null);
    } else {
      areas[i] = new Area(strips[i - 1], strips[i]);
    }
  }
}


int lightStrip = 0;
int direction = DIRECT_RIGHT;
int tailCount = 2;
void drawStrips() {
  for (int i = 0; i < strips.length; i++) {
    color c = color(0);
    if (i == lightStrip) {
      c = color(random(255), random(255), random(255));
    }
    if (direction == DIRECT_RIGHT && lightStrip - i > 0 && lightStrip - i <= tailCount) {
      int tempC = (int)(255 * (0.6 / (lightStrip - i)));
      c = color(random(255), random(255), random(255));
    } else if (direction == DIRECT_LEFT && i - lightStrip > 0 && i - lightStrip < tailCount) {
      int tempC = (int)(255 * (0.6 / (i - lightStrip)));
      c = color(random(255), random(255), random(255));
    }
    strips[i].draw(c);
  }
  // for (Strip strip : strips) {
  //   color c = color(0);
  //   if (strip.id == lightStrip) {
  //     c = color(255);
  //   } else {
  //     c = color(0);
  //   }
  //   strip.draw(c);
  // }
  if (direction == DIRECT_RIGHT) {
    lightStrip++;
  } else {
    lightStrip--;
  }

  if (lightStrip == NUM_STRIPS) {
    direction = DIRECT_LEFT;
  } else if (lightStrip == -1) {
    direction = DIRECT_RIGHT;
  }
}

int lastX = 0;
int lastY = 0;
int lastDirection = DIRECT_RIGHT;
void drawStripsWithPos(int x, int y) {
  if (abs(x - lastX) < 46) {
    direction = DIRECT_STAY;
  } else if(x > lastX) {
    direction = DIRECT_LEFT;
  } else {
    direction = DIRECT_RIGHT;
  }
  for (int i = 0; i < strips.length; i++) {
    strips[i].draw(color(0,0,0));
  }
  for (Area area : areas) {
    if (area.inside(x)) {
      area.updateStripsColor(direction);
    }
  }
  lastX = x;
  lastY = y;
  lastDirection = direction;
}

int bright = 20;
void drawBreathLine() {
  for (Strip strip : strips) {
    strip.draw(color(bright,bright,bright));
  }
  bright+=20;
  if (bright >= 255) {
    delay(500);
    bright = 20;
  } else {
    delay(50);
  }
}

int stripOffset = 0;
color c1 = randomColor();
color c2 = randomColor();
void drawRoof() {
  for (int i = 0 ; i < strips.length; i++) {
    float inter = map(i, 0, strips.length, 0, 1);
    color c3 = lerpColor(c1,c2,inter);
    if (i <= stripOffset) {
      strips[i].draw(c3,206,416);
    } else {
      strips[i].draw(color(0));
    }
    // delay(10);
  }
  stripOffset++;
  if (stripOffset == strips.length) {
    stripOffset = 0;
  }
}

void drawStripsRandom() {
  for (Strip strip : strips) {
    int random = (int)random(20);
    if (random > 10) {
      int r = (int)random(255);
      int g = (int)random(255);
      int b = (int)random(255);
      strip.draw(color(r, g, b));
    } else {
      strip.draw(color(0));
    }
  }
}

class Strip {
  int id;
  int offset;
  int ledsNum;

  public Strip(int id, int offset) {
    this.id = id;
    this.offset = offset;
  }

  void draw() {
    stroke(0);
    strokeWeight(2);
    line(offset,0,offset,TUNNEL_HEIGHT);
  }

  void draw(color c) {
    stroke(c);
    strokeWeight(2);
    line(offset,0,offset,TUNNEL_HEIGHT);
  }

  void draw(color c, int start, int end) {
    strokeWeight(2);
    stroke(0);
    line(offset, 0, offset, start);
    stroke(c);
    line(offset, start, offset, end);
    stroke(0);
    line(offset, end, offset, TUNNEL_HEIGHT);
  }
}

class Area {
  int minX;
  int maxX;
  Strip leftStrip;
  Strip rightStrip;

  public Area(Strip leftStrip, Strip rightStrip) {
    this.minX = leftStrip == null ? 0 : leftStrip.offset;
    this.maxX = rightStrip == null ? TUNNEL_WIDTH : rightStrip.offset;
    this.leftStrip = leftStrip;
    this.rightStrip = rightStrip;
  }

  boolean inside(int x) {
    return x > minX && x < maxX;
  }

  void updateStripsColor(int direction) {
    if (direction == DIRECT_RIGHT) {
      if (leftStrip == null) {
        return;
      }
      for (int i = 0; i < 3; i++) {
        if (leftStrip.id - i >= 0) {
          int c = int(255 * ((3 - i) / 3.0));
          strips[leftStrip.id - i].draw(color(c, c, c));
        }
      }
    } else if (direction == DIRECT_LEFT) {
      if (rightStrip == null) {
        return;
      }
      for (int i = 0; i < 3; i++) {
        if (rightStrip.id + i < strips.length) {
          int c = int(255 * ((3 - i) / 3.0));
          strips[rightStrip.id + i].draw(color(c,c,c));
        }
      }
    } else {
      if (leftStrip != null) leftStrip.draw(color(255));
      if (rightStrip != null) rightStrip.draw(color(255));
    }
  }
}
