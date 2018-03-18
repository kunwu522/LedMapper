int x1;
int x2;

void drawGradient() {
  int x = mouseX;
  x1 = (int)lerp(x1, x, 0.05); //<>//
  //println("blob x: " + averageX);
  x2 = (int)lerp(x2, x1, 0.1);

  noStroke();
  //float gradient = 2;
  float tempWidth = abs(x1 - x2) > 20 ? abs(x1 - x2) : 20;
  if (x1 > x2) {
    setGradient(x2, 0, tempWidth, (float)TUNNEL_HEIGHT, color(128, 128, 128), color(255), X_AXIS);
  } else {
    setGradient(x1, 0, tempWidth, (float)TUNNEL_HEIGHT, color(255), color(128, 128, 128), X_AXIS);
  }
}

void drawLine() {
  int x = mouseX;
  rectMode(CENTER);
  fill(255);
  noStroke();
  rect(x, TUNNEL_HEIGHT / 2, 40, TUNNEL_HEIGHT);
}


int Y_AXIS = 1;
int X_AXIS = 2;
void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {
  noFill();

  if (axis == Y_AXIS) {  // Top to bottom gradient
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(x, i, x+w, i);
    }
  } else if (axis == X_AXIS) {  // Left to right gradient
    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
  }
}
