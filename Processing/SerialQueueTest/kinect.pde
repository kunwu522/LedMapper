import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;

PImage background;
PImage smoothImage;

ArrayList<Blob> blobs = new ArrayList<Blob>();

void setupKinect() {
  kinect2 = new Kinect2(this);
  if (kinect2.getNumKinects() == 0) {
    exit();
    return;
  }

  kinect2.initDepth();
  kinect2.initDevice();

  if (kinect2.depthWidth != KINECT_DEPTH_WIDTH
    || kinect2.depthHeight != KINECT_DEPTH_HEIGHT) {
    println("Error, Kinect depth size do not match");
    exit();
    return;
  }

  background = loadImage("image/background.jpg");
  if (background == null) {
    background = createImage(KINECT_DEPTH_WIDTH, KINECT_DEPTH_HEIGHT, RGB);
  }
  smoothImage = createImage(KINECT_DEPTH_WIDTH, KINECT_DEPTH_HEIGHT, RGB);
}
