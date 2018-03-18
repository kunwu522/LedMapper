final int DIRECT_RIGHT = 0;
final int DIRECT_LEFT = 1;
final int DIRECT_STAY = 3;

Strip[] strips = new Strip[NUM_STRIPS];

void setupStrips() {
  int interval = TUNNEL_WIDTH / (NUM_STRIPS + 1);
  for (int i = 0; i < NUM_STRIPS; i++) {
    strips[i] = new Strip(i, interval * (i + 1));
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

int lastMouseX = 0;
int lastMouseY = 0;
int lastDirection = DIRECT_RIGHT;
void drawStripsWithMouse() {
  // if (lastMouseX == mouseX && lastMouseY == mouseY) {
  //   return;
  // }
  // direction = mouseX - lastMouseX > 0 ? DIRECT_RIGHT : DIRECT_LEFT;
  if (mouseX > lastMouseX) {
    direction = DIRECT_RIGHT;
  } else if(mouseX < lastMouseX) {
    direction = DIRECT_LEFT;
  } else {
    direction = lastDirection;
  }

  Strip leftStrip = null;
  Strip rightStrip = null;
  for (int i = 0; i < strips.length; i++) {
    strips[i].draw(color(0));
    if (i == strips.length - 1) {
      break;
    }
    if (strips[i].offset < mouseX && strips[i + 1].offset > mouseX) {
      leftStrip = strips[i];
      rightStrip = strips[i + 1];
    }
  }
  if (leftStrip == null || rightStrip == null) {
    return;
  }
  if (direction == DIRECT_RIGHT) {
    for (int i = 0; i < 3; i++) {
      if (leftStrip.id - i >= 0) {
        int c = int(255 * ((3 - i) / 3.0));
        strips[leftStrip.id - i].draw(color(c, c, c));
      }
    }
  } else {
    for (int i = 0; i < 3; i++) {
      if (rightStrip.id + i < strips.length) {
        int c = int(255 * ((3 - i) / 3.0));
        strips[rightStrip.id + i].draw(color(c,c,c));
      }
    }
  }
  lastMouseX = mouseX;
  lastMouseY = mouseY;
  lastDirection = direction;
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
}
