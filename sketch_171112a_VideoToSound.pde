
import processing.video.*;
import processing.sound.*;
import gab.opencv.*;

Movie video;
OpenCV opencv;
SinOsc sine;

// 16:9 aspect ratio https://www.digitalcitizen.life/what-screen-resolution-or-aspect-ratio-what-do-720p-1080i-1080p-mean
final int ASP_WIDTH = 16;
final int ASP_HEIGHT = 9;
final int ASP_SCALE = 30;
final int FRAME_SINGLE_WIDTH = ASP_WIDTH * ASP_SCALE;
final int FRAME_SINGLE_HEIGHT = ASP_HEIGHT * ASP_SCALE;


void setup() {
  
  // Set size
  size(640, 480); // initial
  surface.setSize(FRAME_SINGLE_WIDTH * 2, FRAME_SINGLE_HEIGHT); // programatic resize requires this
  
  // Create manipulation objects for movie and opencv
  video = new Movie(this, "2017_1114_184929_016.MOV");
  opencv = new OpenCV(this, FRAME_SINGLE_WIDTH, FRAME_SINGLE_HEIGHT);
  
  // Call background subtraction tracking
  opencv.startBackgroundSubtraction(5,3,0.5);
  
  // Set video playback
  video.loop();
  video.play();
  
}

void draw()
{
  //image(video, 0, 0, width, height);

  if(video.width > 0 && video.height > 0)
  {
    // Get frame from video and resize
    PImage orig = video.get(0,0, video.width, video.height);
    orig.resize(FRAME_SINGLE_WIDTH, FRAME_SINGLE_HEIGHT);
    image(orig,0,0);
    
    
    
    
    //opencv.loadImage(video);
    //PImage original = opencv.getSnapshot();
    //println(original.width + " " + original.height);
    //image(original, 0, 0, width, height);

  }
  
  
  //opencv.updateBackground();

  
  
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}