
import processing.video.*;
import processing.sound.*;
import gab.opencv.*;
//import blobscanner.*;

Movie video;
OpenCV opencv;
Histogram grayHist;
SinOsc sine;

// 16:9 aspect ratio https://www.digitalcitizen.life/what-screen-resolution-or-aspect-ratio-what-do-720p-1080i-1080p-mean
final int ASP_WIDTH = 16;
final int ASP_HEIGHT = 9;
final int ASP_SCALE = 40;
final int FRAME_SINGLE_WIDTH = ASP_WIDTH * ASP_SCALE;
final int FRAME_SINGLE_HEIGHT = ASP_HEIGHT * ASP_SCALE;

//// Adaptive Thresholding Constants
////int thresholdBlockSize = 489;
////int thresholdConstant = 45;
//int thresholdBlockSize = 29;
//int thresholdConstant = 60;

// Fixed Threshold parameters
int lightThreshold = 250;

// Store previous images for flicker reduction
ArrayList<PImage> prevImages = new ArrayList<PImage>();



void setup() {
  
  // Set size
  size(640, 480); // initial
  surface.setSize(FRAME_SINGLE_WIDTH * 2, FRAME_SINGLE_HEIGHT); // programatic resize requires this
  
  // Create manipulation objects for movie and opencv
  video = new Movie(this, "2017_1114_184929_016.MOV");
  opencv = new OpenCV(this, FRAME_SINGLE_WIDTH, FRAME_SINGLE_HEIGHT);
  
  //// Call background subtraction tracking
  //opencv.startBackgroundSubtraction(5,3,0.5);
  
  //// Thresholding block size must be odd and greater than 3
  //if (thresholdBlockSize%2 == 0)
  //{
  //  thresholdBlockSize++;
  //  println("thresholdBlockSize adjusted to " + thresholdBlockSize);
  //}
  //if (thresholdBlockSize < 3)
  //{
  //  thresholdBlockSize = 3;
  //  println("thresholdBlockSize adjusted to " + thresholdBlockSize);
  //}
  
  
  // Set video playback params
  video.loop();
  video.volume(0);
  //video.speed(0.1);
  video.play();
  
}

void draw()
{
  //image(video, 0, 0, width, height);

  if(video.width > 0 && video.height > 0)
  {
    // Get frame from video and resize
    PImage orig = video.get(0,0, video.width, video.height); // https://forum.processing.org/one/topic/how-to-make-images-from-a-video.html
    orig.resize(FRAME_SINGLE_WIDTH, FRAME_SINGLE_HEIGHT);
    image(orig, 0, 0);
    
    //  load into opencv object
    opencv.loadImage(orig);
    //dispCurrent();
    
    //// Perform adaptive thresholding
    //opencv.adaptiveThreshold(thresholdBlockSize, thresholdConstant);
    //opencv.invert();
    //dispCurrent();
    
    //// Get Histogam (and display)
    //grayHist = opencv.findHistogram(opencv.getGray(), 256);
    //fill(255,0,0);
    //noStroke();
    //grayHist.draw(320, 10, 310, 180);
    
    // Perform thresholding
    opencv.threshold(240);
    //dispCurrent();
    
    //// Perform background subtraction
    //opencv.updateBackground();
    ////dispCurrent();
    
    // Perform erosion
    opencv.erode();
    //dispCurrent();
    
    // Perform Dilation
    opencv.dilate();
    dispCurrent();
    
    
    //// Get and display Contours
    //ArrayList<Contour> contours;
    //contours = opencv.findContours();
    //stroke(255, 0, 0);
    //fill(0, 0); 
    //for (Contour contour : contours) // For each contour
    //{
      
    //  // Offset location to "After" Side and draw points
    //  ArrayList<PVector> ptsToDraw = contour.getPoints();
    //  beginShape();
    //  for(PVector pt : ptsToDraw)
    //  {
    //    vertex(pt.x + FRAME_SINGLE_WIDTH, pt.y);
    //  }
    //  endShape();
      
    //}
    
    

  }
  
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}



void dispCurrent()
{
  PImage current = opencv.getSnapshot();
  image(current, FRAME_SINGLE_WIDTH, 0);
}

void removeFlicker()
{
  int numImagesForFlickerReduction = 3;
  
  prevImages.add(opencv.getSnapshot());
  if(prevImages.size() > numImagesForFlickerReduction)
  {
    prevImages.remove(0);
  }
  
  PImage dum = new PImage(1080, 800);
  (127);
  
  
}