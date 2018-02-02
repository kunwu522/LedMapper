import codeanticode.syphon.*;

SyphonServer syphonServer;

static int STRIPS_NUM = 8;
static int SCREEN_WIDTH = 512;
static int SCREEN_HEIGHT = 424;
static int GRADIENT = 5;

color[] grey = {color(95, 95, 95), 
                color(128, 128, 128),
                color(169, 169, 169),
                color(203, 203, 203),
                color(255)};

float x1;
float x2;

PGraphics canvas;

void setup() {
  size(512, 424, P3D);
  canvas = createGraphics(512, 424, P3D);
  syphonServer = new SyphonServer(this, "Body Movement Simulation");
}

void draw() {
  
  canvas.beginDraw();
  canvas.background(169, 169, 169);
  drawStrips();
  
  drawCursor();
  canvas.endDraw();
  image(canvas, 0, 0);
  syphonServer.sendImage(canvas);
}

void drawStrips() {
  float gapWidth = SCREEN_WIDTH / (STRIPS_NUM + 1);
  canvas.fill(0);
  canvas.noStroke();
  for (int i = 0; i < STRIPS_NUM; i++) {
    canvas.rectMode(CENTER);
    if (i == 0) {
      canvas.rect(gapWidth, 212, 10, 424);
    } else {
      canvas.rect(gapWidth * i + gapWidth, 212, 10, 424);
    }
  }
}

void drawCursor() {
  x1 = lerp(x1, mouseX, 0.1);
  x2 = lerp(x2, x1, 0.05);
  
  float w = abs(x1 - x2) > 20 ? abs(x1 - x2) : 20;
  float gradientWidth = w / GRADIENT;  
  
  noStroke();
  for (int i = 0; i < GRADIENT; i++) {
    canvas.rectMode(CORNER);
    canvas.fill(grey[i]);
    if (x1 > x2) {
      canvas.rect(x2 + i * gradientWidth, 0, gradientWidth, 424); 
    } else {
      canvas.rect(x1 - i * gradientWidth, 0, gradientWidth, 424);
    }
  }
}