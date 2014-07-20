
import processing.video.*; 
import java.util.Calendar;

// Variable for capture device
Capture video;
// Previous Frame
PImage slateImage;
PImage currentImage;
// How different must a pixel be to be a "motion" pixel
float threshold = 50;
color backgroundColor = color(0); 
boolean slateTaken = false;

float tileCount = 300;

PImage slateGridSection, currentGridSection;

void setup() { 
  size(800,600);
  
  video = new Capture(this, width, height, 30);
  // Create an empty image the same size as the video
  slateImage = createImage(video.width,video.height,RGB);
  video.start();
  
} 

void draw() {
  
  
  if(slateTaken){
    
    if (video.available()) {
      video.read();
    }
    
    //loadPixels();
    video.loadPixels();
    //slateImage.loadPixels();
    
    //loop through grid;
    pushMatrix();
    for(int gridY = 0; gridY < (tileCount); gridY++){
      for(int gridX = 0; gridX < (tileCount); gridX++){
        
        slateGridSection = slateImage.get((int)(gridX*(width/tileCount)),(int)(gridY*(height/tileCount)), (int)(width/tileCount),(int)(height/tileCount));
        currentGridSection = video.get((int)(gridX*(width/tileCount)),(int)(gridY*(height/tileCount)), (int)(width/tileCount),(int)(height/tileCount));
        if(isSectionDifferent(slateGridSection, currentGridSection)){
          fill(255,0,0);
        }
        else {
          fill(0,0,0);
        }
        
        
        rect((int)(gridX*(width/tileCount)),(int)(gridY*(height/tileCount)), (int)(width/tileCount),(int)(height/tileCount));
//        image(slateGridSection, (int)(gridX*(width/tileCount)),(int)(gridY*(height/tileCount)));
      }
    }
    popMatrix();
    
    video.updatePixels();
    
    if(second() %5 == 0){
      saveFrame("images/" + timestamp()+"_##.png");
    }
  }
  else {
   background(0); 
   fill(255,0,0);
   rect(0,0, 15,15);
  }
}

boolean isSectionDifferent(PImage slateSection, PImage newSection){
  
  int diffCounter = 0;
  //differnce cutoff is half different pixels
  int diffCutoff = (newSection.width*newSection.height)/2;
  
  // Begin loop to walk through every pixel
  for (int x = 0; x < newSection.width; x ++ ) {
    for (int y = 0; y < newSection.height; y ++ ) {
      
      int loc = x + y*newSection.width;            // Step 1, what is the 1D pixel location
      color currentColor = newSection.pixels[loc];      // Step 2, what is the current color
      color slateColor = slateSection.pixels[loc]; // Step 3, what is the previous color
      
      if(!colorsSimilar(currentColor, slateColor)) {
        diffCounter += 1;
      }
      
      
      if(diffCounter > diffCutoff) {
        return true;
      }
      //TODO add a condition to see if it is even mathematically possible to get a 
      //diff at this point in the loop.  to optimize, duh
    }
  }
  
  return false;
}

void mouseClicked() {
  
  //set slate image
  video.start();
  
  if (video.available()) {
    
    video.read();
    
    slateImage.copy(video,0,0,video.width,video.height,0,0,video.width,video.height);
    slateImage.updatePixels();
    
    slateTaken = true;
    println("click");
  }
}

boolean colorsSimilar(color baseColor, color compareColor) {
  
  float diff = dist(red(baseColor),green(baseColor),blue(baseColor),red(compareColor),green(compareColor),blue(compareColor));
  
  if (diff > threshold) { 
    if(alpha(compareColor) < alpha(baseColor) - threshold || alpha(compareColor) > alpha(baseColor) + threshold){
      return true;
    }
    return false;
  } else {
    return true;
  }
  
}

String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}
