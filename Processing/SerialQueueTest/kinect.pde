import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;

import java.util.*;

final int KINECT_DEPTH_WIDTH = 512;
final int KINECT_DEPTH_HEIGHT = 424;

Kinect2 kinect2;

PImage background;
// PImage smoothImage;
File[] dataFiles;
// ArrayList<Blob> blobs = new ArrayList<Blob>();

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
}

void setupKinectSimulator() {
  int[] backgroundDepth = loadDepth("background.dat");
  if (backgroundDepth == null) {
    exit();
    return;
  }
  background = getDenoisedDepthImage(backgroundDepth);

  File directory = new File("/Users/tonywu/Desktop/SerialQueueTest/data");
  if (directory.isDirectory()) {
    dataFiles = directory.listFiles();
  } else {
    println("Error, invalid file path. " + directory.getAbsolutePath());
    exit();
    return;
  }
  println("Finished set up, " + dataFiles.length + " files are launched.");
}

boolean saveBackground = false;
void drawKinect() {
  PImage smoothImage = getDenoisedDepthImage(kinect2.getRawDepth());
  detectBlob(smoothImage);
  if (saveBackground) {
    smoothImage.save("image/background.jpg");
    saveBackground = false;
  }
  image(smoothImage, 0, 620);
}

int fileOffset = 0;
void drawKinectSimulator() {
  if (fileOffset >= dataFiles.length) {
      println("offset is over range of files, offset is " + fileOffset);
      exit();
      return;
    }
    String filePath = dataFiles[fileOffset].getAbsolutePath();
    int[] rawDepth = loadDepth(filePath);
    if (rawDepth == null) {
      exit();
      return;
    }
    // int t1 = millis();
    PImage smoothImage = getDenoisedDepthImage(rawDepth);
    // int t2 = millis();
    detectBlob(smoothImage);
    // int t3 = millis();
    // image(smoothImage, 0, 0);

    // fill(255);
    //println("Blob pos: " + averageX + "-" + averageY);
    // println("Time usage: step1----" + (t2 - t1) + ", step2----" + (t3 - t2));
    fileOffset++;
}

/*
 * Reading binary file, return depth int array
 *
 */
int[] loadDepth(String filename) {
 byte[] data = loadBytes(filename);
 if (data == null || data.length == 0) {
   println("Can not read data from " + filename);
   exit();
   return null;
 }
 int[] depth = new int[data.length / 2];
 int index = 0;
 for (int i = 0; i < data.length; i+=2) {
   // if (offset < data.length / 2) {
     depth[index++] = ((data[i] & 0xFF) << 8) | (data[i + 1] & 0xFF);
   // }
 }
 return depth;
}

int innerBandThreshold = 3;
int outerBandThreshold = 5;
int avarageThreshold = 30;
PImage getDenoisedDepthImage(int[] rawDepth) {
  // int[] smoothDepth = new int[rawDepth.length];
  PImage image = createImage(KINECT_DEPTH_WIDTH,KINECT_DEPTH_HEIGHT,RGB);
  int widthBound = KINECT_DEPTH_WIDTH - 1;
  int heightBound = KINECT_DEPTH_HEIGHT - 1;
  image.loadPixels();
  for (int x = 0; x < KINECT_DEPTH_WIDTH; x++) {
    for (int y = 0; y < KINECT_DEPTH_HEIGHT; y++) {
      int smoothDepth = 0;
      int offset = x + y * KINECT_DEPTH_WIDTH;
      if (rawDepth[offset] == 0) {
        Map<Integer, Integer> frequencyMap = new HashMap<Integer, Integer>();
        int innerBandCount = 0;
        int outerBandCount = 0;
        for (int i = -2; i < 3; i++) {
          for (int j = -2; j < 3; j++) {
            int nearX = x + i;
            int nearY = y + j;
            if (nearX >=0 && nearX <= widthBound
                && nearY >=0 && nearY <= heightBound) {
              int index = nearX + nearY * KINECT_DEPTH_WIDTH;
              if (rawDepth[index] != 0) {
                Integer depth = Integer.valueOf(rawDepth[index]);
                if (frequencyMap.containsKey(depth)) {
                  frequencyMap.put(depth, frequencyMap.get(depth) + 1);
                } else {
                  frequencyMap.put(depth, 1);
                }
                if (i != 2 && i != -2 && j != 2 && j != -2) {
                  innerBandCount++;
                } else {
                  outerBandCount++;
                }
              }
            }
          }
        }

        if (innerBandCount >= innerBandThreshold || outerBandCount >= outerBandThreshold) {
          int depth = 0;
          Object[] values = frequencyMap.values().toArray();
          Arrays.sort(values, new Comparator<Object>() {
              @Override
              public int compare(Object o1, Object o2) {
                  Integer i1 = (Integer)o1;
                  Integer i2 = (Integer)o2;
                  if (i1.intValue() > i2.intValue()) {
                      return -1;
                  } else {
                      return 1;
                  }
              }
          });
          for (Map.Entry<Integer, Integer> e : frequencyMap.entrySet()) {
              if (e.getValue().intValue() == ((Integer)values[0]).intValue()) {
                  depth = e.getKey().intValue();
                  break;
              }
          }
          smoothDepth = depth;
        }
      } else {
        smoothDepth = rawDepth[offset];
      }

      float rate = 0;
      if (smoothDepth != 0) {
        rate = float(4500 - smoothDepth) / 4500.0;
      }
      image.pixels[offset] = color(255 * rate, 255 * rate, 255 * rate);
    }
  }
  image.updatePixels();
  return image;
}


/******************************
*
*  Background subtraction
*
*
*******************************/
void detectBlob(PImage image) {
  int sumX = 0;
  int sumY = 0;
  int count = 0;
  boolean foundBlob = false;
  for (int x = 0; x < KINECT_DEPTH_WIDTH; x++) {
    for (int y = 0; y < KINECT_DEPTH_HEIGHT; y++) {
      if (isBlobDiff(background, image, x, y, 5)) {
        sumX += x;
        sumY += y;
        count++;
        foundBlob = true;
      }
    }
  }
  if (foundBlob) {
    objectX = int(sumX / count);
    objectY = int(sumY / count);
  } else {
    objectX = -20;
    objectX = -20;
  }
}

boolean isBlobDiff(PImage background, PImage image, int x, int y, int threshold) {
  if (background == null) {
    return false;
  }
  boolean isDiff = true;
  for (int i = -threshold; i <= threshold; i++) {
    for (int j = -threshold; j <= threshold; j++) {
      int nearX = x + i;
      int nearY = y + j;
      if (nearX >= 0 && nearX < KINECT_DEPTH_WIDTH
        && nearY >= 0 && nearY < KINECT_DEPTH_HEIGHT) {
        int nearIndex = nearX + nearY * KINECT_DEPTH_WIDTH;
        color bgColor = background.pixels[nearIndex];
        color currentColor = image.pixels[nearIndex];
        if (diffColor(bgColor, currentColor) < 30 * 30) {
          isDiff = false;
        }
      }
    }
  }
  return isDiff;
}

int diffColor(color c1, color c2) {
  int r1 = c1 >> 16 & 0xFF;
  int g1 = c1 >> 8 & 0xFF;
  int b1 = c1 & 0xFF;

  int r2 = c2 >> 16 & 0xFF;
  int g2 = c2 >> 8 & 0xFF;
  int b2 = c2 & 0xFF;


  return (r2-r1)*(r2-r1) + (g2-g1)*(g2-g1) + (b2-b1)*(b2-b1);
}