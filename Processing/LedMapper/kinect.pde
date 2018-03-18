import org.openkinect.freenect.*;
import org.openkinect.freenect2.*;
import org.openkinect.processing.*;
import org.openkinect.tests.*;

import java.util.*;

Kinect2 kinect2;

PImage background;
PImage smoothImage;
PImage display;
PImage previous;

final int KINECT_WIDTH = 512;
final int KINECT_HEIGHT = 424;

int averageX = 0;
int averageY = 0;

void setupKinect() {
  kinect2 = new Kinect2(this);
  kinect2.initDepth();
  kinect2.initDevice();
  
  background = loadImage("image/background.jpg");
  if (background == null) {
    background = createImage(KINECT_WIDTH, KINECT_HEIGHT, RGB);
  }
  display = createImage(KINECT_WIDTH, KINECT_HEIGHT, RGB);
  smoothImage = createImage(KINECT_WIDTH, KINECT_HEIGHT, RGB);
}

void drawKinect() {
  smoothImage.loadPixels();
  int[] smoothDepth = filterRawDepthArray(kinect2.getRawDepth());
  for (int x = 0; x < kinect2.depthWidth; x++) {
    for (int y = 0; y < kinect2.depthHeight; y++) {
      int index = x + y * kinect2.depthWidth;
      int depth = smoothDepth[index];
      float rate = 0;
      if (depth != 0) {
        rate = float(4500 - depth) / 4500.0;
      }
      smoothImage.pixels[index] = color( 255 * rate, 255 * rate, 255 * rate);
    }
  }
  smoothImage.updatePixels();
  //image(smoothImage, 0, 620);
  buildDisplayImage(smoothImage);
  //image(display, 512, 620);
  
  blobDetection(display);
  
  //fill(0, 255, 0);
  //ellipse(averageX + 512, averageY + 620, 20, 20);
}

/******************************
*  
*  Smooth depth image (denoise depth image)
*
*
*******************************/
int innerBandThreshold = 3;
int outerBandThreshold = 5;
int avarageThreshold = 30;

int[] filterRawDepthArray(int[] rawDepth) {
  int[] smoothDepth = new int[rawDepth.length];
    int widthBound = kinect2.depthWidth - 1;
    int heightBound = kinect2.depthHeight - 1;
    
    for (int x = 0; x < kinect2.depthWidth; x++) {
        for (int y = 0; y < kinect2.depthHeight; y++) {
            int offset = x + y * kinect2.depthWidth;
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
                            int index = nearX + nearY * kinect2.depthWidth;
                            if (rawDepth[index] != 0) {
                                Integer depth = Integer.valueOf(rawDepth[index]);
                                if (frequencyMap.containsKey(depth)) {
                                    frequencyMap.put(depth, frequencyMap.get(depth) + 1);
                                } else {
                                    frequencyMap.put(depth, 1);
                                }
                                
                                 if (i != 2 && i != -2 && j != -2 && j != -2) {
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
                    smoothDepth[offset] = depth;
                }
                //println("################ Finish to smooth");
            } else {
                smoothDepth[offset] = rawDepth[offset];
            }
        }
    }
    return smoothDepth;
}

/******************************
*  
*  Background subtraction
*
*
*******************************/
void buildDisplayImage(PImage image) {
  display.loadPixels();
  for (int x = 0; x < KINECT_WIDTH; x++) {
    for (int y = 0; y < KINECT_HEIGHT; y++) {
      int offset = x + y * KINECT_WIDTH;
      if (isBlobDiff(background, image, x, y, 5)) {
        display.pixels[offset] = color(255);
        //sumX += x;
        //sumY += y;
        //count++;
        //boolean found = false;
        //for (Blob b : blobs) {
        //  if (b.isNear(x, y)) {
        //    b.add(x, y);
        //    found = true;
        //    break;
        //  }
        //}
        //if (!found) {
        //  Blob b = new Blob(x, y);
        //  blobs.add(b);
        //}
      } else {
        display.pixels[offset] = 0;
      }
    }
  }
  //println("############ Blob num:" + blobs.size());
  display.updatePixels();
  //averageX = sumX / count;
  //averageY = sumY / count;
}

void blobDetection(PImage image) {
  int sumX = 0;
  int sumY = 0;
  float count = 0;
  boolean foundBlob = false;
  for (int x = 0; x < kinect2.depthWidth; x++) {
    for (int y = 0; y < kinect2.depthHeight; y++) {
      int index = x + y * kinect2.depthWidth;
      color c = image.pixels[index];
      if (c == color(255)) {
        sumX += x;
        sumY += y;
        count++;
        foundBlob = true;
        //println("fasdfasdf");
      }
    }
  }
  
  if (foundBlob) {
    averageX = int(sumX / count);
    averageY = int(sumY / count);
  } else {
    averageX = -20;
    averageY = -20;
  }
}

boolean isBlobDiff(PImage background, PImage image, int x, int y, int threshold) {
  boolean isDiff = true;
  
  for (int i = -threshold; i <= threshold; i++) {
    for (int j = -threshold; j <= threshold; j++) {
      int nearX = x + i;
      int nearY = y + j;
      if (nearX >= 0 && nearX < KINECT_WIDTH 
        && nearY >= 0 && nearY < KINECT_HEIGHT) {
        int nearIndex = nearX + nearY * KINECT_WIDTH;
        color bgColor = background.pixels[nearIndex];  
        color currentColor = image.pixels[nearIndex];
        if (diffColor(bgColor, currentColor) < 30 * 30) {
          isDiff = false;
        }
      }
    }
  }
  
  //int diff =  diffColor(color(sumRedBg / count, sumGreenBg / count, sumBlueBg / count), 
  //                color(sumRedC / count, sumGreenC / count, sumBlueC / count));
  //println("diff color is " + diff);
  return isDiff;
}

/*************************
 *
 *  Common Functions 
 *
 *************************/
int diffColor(color c1, color c2) {
  int r1 = c1 >> 16 & 0xFF;
  int g1 = c1 >> 8 & 0xFF;
  int b1 = c1 & 0xFF;
  
  int r2 = c2 >> 16 & 0xFF;
  int g2 = c2 >> 8 & 0xFF;
  int b2 = c2 & 0xFF;
  
  
  return (r2-r1)*(r2-r1) + (g2-g1)*(g2-g1) + (b2-b1)*(b2-b1);
}