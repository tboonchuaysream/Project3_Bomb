/*
@author Tommy Boonchuaysream
- this application reflects a tense situation where a bomb is about to explode
- the bomb defuser must attempt to figure out how to defuse the bomb
- there are 2 things that will cause the bomb to explode, the motion detecter (LDR) and the time
 */

// Importing the serial library to communicate with the Arduino 
import processing.serial.*;    
import processing.video.*;
import processing.sound.*;

// Initializing a vairable named 'myPort' for serial communication
Serial myPort;      

String[] data;

//values from hardware
int switchValue = 0;
int potValue = 0;
int ldrValue = 0;

int serialIndex = 0;

// mapping pot values
float minPotValue = 0;
float maxPotValue = 4095;

//value boundaries for potentiometer
float currentPotValue = 0;
float minPassword = 0;
float maxPassword = 4000;
int defaultTimerPerLine = 1500;

//setup()
PImage currentPinImg;
PImage insights;
PImage normalStatus;
PImage cautiousStatus;
PImage end;
PImage defuse;

//sounds
SoundFile beforeTwoSoundPath;
SoundFile afterTwoSoundPath;
SoundFile bombSoundSoundPath;
SoundFile boomSoundPath;
SoundFile defuseSoundSoundPath;
String beforeTwo = "data/beforeTwo.mp3";
String afterTwo = "data/afterTwo.mp3";
String bombSound = "data/bombSound.mp3";
String boom = "data/boom.mp3";
String defuseSound = "data/defuseSound.mp3";
String beforeTwoPath;
String afterTwoPath;
String bombSoundPath;
String boomPath;
String defuseSoundPath;

//setLockOne()
int password = 0;
int bombDefuseTime = 0;

//lockOne()
boolean firstLight = false;
boolean secondLight = false;
boolean thirdLight = false;
boolean fourthLight = false;
boolean allLights = false;

//setLockTwo()
int red;
int blue;
int green;

//time
int bombExplode = 300;

//checkTime()
boolean isAfterTwo = false;
int seconds;

//gameOver()
boolean hasExploded = false;

//bombIsDefused()
boolean hasDefused = false;

Movie video;

void setup ( ) {
  size (1200, 800);    

  // List all the available serial ports
  printArray(Serial.list());

  myPort  =  new Serial (this, Serial.list()[serialIndex], 115200); 

  //declaring video
  video = new Movie(this, "countdown.mp4");

  //declaring images
  currentPinImg = loadImage("data/currentPin.png");
  insights = loadImage("data/insights.png");
  normalStatus = loadImage("data/normalStatus.png");
  cautiousStatus = loadImage("data/cautiousStatus.png");
  end = loadImage("data/end.png");
  defuse = loadImage("data/defuse.png");

  //declaring sounds
  beforeTwoPath = sketchPath(beforeTwo);
  beforeTwoSoundPath = new SoundFile(this, beforeTwoPath);
  beforeTwoSoundPath.play();

  afterTwoPath = sketchPath(afterTwo);
  afterTwoSoundPath = new SoundFile(this, afterTwoPath);
  
  bombSoundPath = sketchPath(bombSound);
  bombSoundSoundPath = new SoundFile(this, bombSoundPath);

  defuseSoundPath = sketchPath(defuseSound);
  defuseSoundSoundPath = new SoundFile(this, defuseSoundPath);

  //SETTING UP THE BOMB ENVIRONMENT
  
  //show picture of bomb
  displayBomb();
  
  //5 lights at the top
  setLockOne();
  
  //motion detecter on the bottom
  setLockTwo();
  
  //insights from bomb squad
  image(insights, 885, 80, 270, 330);
  
  //status of the bomb
  image(normalStatus, 40, 240, 320, 130);
  
} 

void movieEvent(Movie video) {  
  video.read();
}

//call this to get the data 
void checkSerial() {
  while (myPort.available() > 0) {
    String inBuffer = myPort.readString();

    // This removes the end-of-line from the string
    inBuffer = (trim(inBuffer));

    // This function will make an array of TWO items, 1st item = switch value, 2nd item = potValue
    data = split(inBuffer, ',');

    if ( data.length >= 3 ) {
      switchValue = int(data[0]);           // first index = switch value 
      potValue = int(data[1]);               // second index = pot value
      ldrValue = int(data[2]);               // third index = LDR value
    }
  }
} 

void draw ( ) {  

  //play video of timer
  image(video, 488, 140, 229, 87);
  video.play();

  // every loop, look for serial information
  checkSerial();

  //check current time
  //used to change music and make bomb explode
  checkTime();

  //checking to see if password is correct
  lockOne();
  
  //checking to see if motion is detected
  lockTwo();

  //DIFFERENT OUTCOMES
  //all passwords are correct = defused
  //time is up = explode
  // motion is detected = explode
  
  if (allLights == true) {
    
    bombIsDefused();
    
  } else if (seconds >= 300) {

    gameOver();
    image(end, 0, 0, 1200, 800);
    
  } else if (red >= 255) {
    
    gameOver();
    image(end, 0, 0, 1200, 800);
    
  }
  
} 

void checkTime() {

  //get time
  int millie = millis();

  //store it as seconds
  seconds = millie/1000;

  //change bomb status to cautious if time is 2 mintues or less
  if ((seconds > 180) && (isAfterTwo == false)) {
    
    image(cautiousStatus, 40, 240, 320, 130);
    
    //change music
    beforeTwoSoundPath.stop();
    afterTwoSoundPath.play();

    //play bomb ticker sound
    bombSoundSoundPath.play();
    bombSoundSoundPath.loop();

    isAfterTwo = true;
    
  }
  
}


void displayBomb() {

  //load picture of bomb
  PImage bomb = loadImage("data/bomb.jpg");

  image(bomb, 0, 0);
  
}

void setLockOne() {

  //set password
  password = int(random(0, 4000));

  //first light
  fill(255, 0, 0);
  ellipse(494, 75, 15, 15);

  //second light
  fill(255, 0, 0);
  ellipse(525, 75, 15, 15);

  //third light
  fill(255, 0, 0);
  ellipse(558, 75, 15, 15);

  //fourth light
  fill(255, 0, 0);
  ellipse(590, 75, 15, 15);

  //final light
  fill(255, 0, 0);
  ellipse(435, 83, 37, 37);
  
}

void lockOne() {

  currentPotValue = map( potValue, minPotValue, maxPotValue, minPassword, maxPassword );

  //current password selection from user
  String currentPasswordSelection = str(int(currentPotValue));

  //backdrop for the current pin selected
  image(currentPinImg, 40, 80, 320, 130);
  
  //display current pin selection
  textSize(35);
  fill(255);
  text(currentPasswordSelection, 150, 180); 

  //CHECK IF PASSWORD IS CORRECT FOR EACH LIGHT
  //BOMB DEFUSE CONDITIONS
  //password is correct if the selected pin is within a 100 value range
  
  if ((currentPotValue > (password - 100)) && (currentPotValue < (password + 100)) && (firstLight == false)) {

    //first light
    fill(46, 204, 113);
    ellipse(494, 75, 15, 15);

    firstLight = true;
    password = int(random(0, 4000));
    
  }

  if ((currentPotValue > (password - 100)) && (currentPotValue < (password + 100)) && (firstLight == true) && (secondLight == false)) {

    //second light
    fill(46, 204, 113);
    ellipse(525, 75, 15, 15);

    secondLight = true;
    password = int(random(0, 4000));
    
  }

  if ((currentPotValue > (password - 100)) && (currentPotValue < (password + 100)) && (secondLight == true) && (thirdLight == false)) {

    //third light
    fill(46, 204, 113);
    ellipse(558, 75, 15, 15);

    thirdLight = true;
    password = int(random(0, 4000));
    
  }

  if ((currentPotValue > (password - 100)) && (currentPotValue < (password + 100)) && (thirdLight == true) && (fourthLight == false)) {

    //fourth light
    fill(46, 204, 113);
    ellipse(590, 75, 15, 15);

    fourthLight = true;
    password = int(random(0, 4000));
    
  }

  if ((firstLight == true) && (secondLight == true) && (thirdLight == true) && (fourthLight == true)) {

    fill(46, 204, 113);
    ellipse(435, 83, 37, 37);

    //all password has been bypassed
    allLights = true;

    if (hasDefused == false) {
      
      //use to show the bomb defused screen 3 seconds after the bomb has been defused
      bombDefuseTime = seconds;
      
    }
    
  }
  
}

void setLockTwo() {

  //initial value for lights
  red = 0;
  green = 255;
  blue = 0;

  //right motion detector light
  fill(red, green, blue);
  ellipse(669, 637, 16, 16);

  //left motion detector light
  fill(red, green, blue);
  ellipse(689, 637, 16, 16);
  
}

void lockTwo() {

  //if light value from LDR is brighter than 1000
  //increase value of red while decreasing the value of green
  
  if (ldrValue > 1000) {

    red++;
    green--;

    fill(red, green, blue);
    ellipse(669, 637, 16, 16);
    ellipse(689, 637, 16, 16);
    
  } else if (ldrValue <= 1000) {
    
    red--;
    green++;

    fill(red, green, blue);
    ellipse(669, 637, 16, 16);
    ellipse(689, 637, 16, 16);
    
  }
  
  //provides a warning if the motion detecter is about to trigger the bomb

  if (red > 150) {
    
    image(cautiousStatus, 40, 240, 320, 130);
    
  } else if (red < 150) {
    
    image(normalStatus, 40, 240, 320, 130);
    
  }
  
}

void gameOver() {

  //make the bomb explode
  //stop everything else and play the bomb exploding sound

  if (hasExploded == false) {

    //stop all previous sounds
    beforeTwoSoundPath.stop();
    afterTwoSoundPath.stop();
    bombSoundSoundPath.stop();

    //import and play bomb exploding sound
    boomPath = sketchPath(boom);
    boomSoundPath = new SoundFile(this, boomPath);
    boomSoundPath.play();

    //display bomb has exploded image
    image(end, 0, 0, 1200, 800);

    //set it to true so it only runs once
    hasExploded = true;
    
  }
  
}

void bombIsDefused() {

  if (hasDefused == false) {

    //stop all previous sounds
    beforeTwoSoundPath.stop();
    afterTwoSoundPath.stop();
    bombSoundSoundPath.stop();

    //play the sound of the bomb being defused
    defuseSoundSoundPath.play();
    
    //set it to true so it only runs once
    hasDefused = true;
    
  }

  if ((seconds - bombDefuseTime) > 3) {

    //display image showing that the bomb has been defused
    image(defuse, 0, 0, 1200, 800);
    
  }
  
}
