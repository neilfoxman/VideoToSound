import java.util.*;
import processing.video.*;
import processing.sound.*;
import gab.opencv.*;
import java.awt.Rectangle;
//import blobscanner.*;

Movie video;
//OpenCV opencv;
//Histogram grayHist;
SinOsc sine;

// 16:9 aspect ratio https://www.digitalcitizen.life/what-screen-resolution-or-aspect-ratio-what-do-720p-1080i-1080p-mean
final int ASP_WIDTH = 16;
final int ASP_HEIGHT = 9;
final int ASP_SCALE = 40;
final int FRAME_SINGLE_WIDTH = ASP_WIDTH * ASP_SCALE;
final int FRAME_SINGLE_HEIGHT = ASP_HEIGHT * ASP_SCALE;

// Fixed Threshold parameters
int lightThreshold = 240;

// Blob tracker
BlobTracker blobTracker;

// Movie navigation
float fRate = 30; // frames/sec
float fInt = 1/fRate; // Interval of frame (s)


void setup() {

  // Set size
  size(640, 480); // initial
  surface.setSize(FRAME_SINGLE_WIDTH * 2, FRAME_SINGLE_HEIGHT); // programatic resize requires this

  // Create manipulation objects
  video = new Movie(this, "2017_1114_184929_016.MOV");
  blobTracker = new BlobTracker(this);
  //opencv = new OpenCV(this, FRAME_SINGLE_WIDTH, FRAME_SINGLE_HEIGHT);


  // Set video playback params
  video.loop();
  video.frameRate(fRate);
  video.volume(0);
  //video.speed(0.1);
  video.play();
  //video.jump(frame);
  //video.pause();
}

void draw()
{
  background(127);
  //image(video, 0, 0, width, height);

  if (video.width > 0 && video.height > 0)
  {
    // Get frame from video and resize
    PImage orig = video.get(0, 0, video.width, video.height); // https://forum.processing.org/one/topic/how-to-make-images-from-a-video.html
    orig.resize(FRAME_SINGLE_WIDTH, FRAME_SINGLE_HEIGHT);
    image(orig, 0, 0);

    // Make modifiable image
    PImage modImg = orig.copy();

    // Perform thresholding
    modImg.filter(THRESHOLD, (float)lightThreshold/255);
    //dispCurrent(modImg);

    // Perform erosion
    modImg.filter(ERODE);
    //dispCurrent(modImg);

    // Perform Dilation
    modImg.filter(DILATE);
    //dispCurrent(modImg);

    // Run Blob tracking
    blobTracker.runTracker(modImg);

    // Draw blob identifiers
    dispCurrent(modImg);
    drawBlobsInPostFrame();
  }
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}



void dispCurrent(PImage current)
{
  //PImage current = opencv.getSnapshot();
  image(current, FRAME_SINGLE_WIDTH, 0);
}

void drawBlobsInPostFrame()
{
  ArrayList<Blob> arrayOfBlobs = blobTracker.getNewBlobs();
  for (Blob blob : arrayOfBlobs)
  {
    text(blob.finalId+","+blob.x+ ","+blob.y, blob.x + FRAME_SINGLE_WIDTH, blob.y);
  }
}

void mousePressed() {
  video.play(); // need to be playing to jump
  float fr = video.time() + fInt;
  video.jump(fr);
  video.pause();
  //println("jumped to " + video.time());
}