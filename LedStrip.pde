class LedStrip {
  int id;
  int ledNum;
  PVector corner;
  float width;
  float height;
  
  boolean isHorizontal;
  
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
    canvas.stroke(128, 128, 128);
    //canvas.strokeWeight(1);
    canvas.rect(corner.x, corner.y, width, height);
    if (isHorizontal) {
      float spacing = width / ledNum;
      for (int i = 1; i < ledNum; i++) {
        canvas.line(corner.x + i * spacing, corner.y, corner.x + i * spacing, corner.y + height);
      }
    } else {
      float spacing = height / ledNum;
      for (int i = 1; i < ledNum; i++) {
        canvas.line(corner.x, corner.y + i * spacing, corner.x + width, corner.y + i * spacing);
      }
    }
  }
}