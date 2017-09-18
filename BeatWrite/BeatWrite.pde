/**
  * This sketch demonstrates how to use the BeatDetect object in FREQ_ENERGY mode.<br />
  * You can use <code>isKick</code>, <code>isSnare</code>, </code>isHat</code>, <code>isRange</code>, 
  * and <code>isOnset(int)</code> to track whatever kind of beats you are looking to track, they will report 
  * true or false based on the state of the analysis. To "tick" the analysis you must call <code>detect</code> 
  * with successive buffers of audio. You can do this inside of <code>draw</code>, but you are likely to miss some 
  * audio buffers if you do this. The sketch implements an <code>AudioListener</code> called <code>BeatListener</code> 
  * so that it can call <code>detect</code> on every buffer of audio processed by the system without repeating a buffer 
  * or missing one.
  * <p>
  * This sketch plays an entire song so it may be a little slow to load.
  */

import processing.serial.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import cc.arduino.*;

Minim minim;
AudioPlayer song;
BeatDetect beat;
BeatListener bl;
Arduino arduino;
long lowIn;
long pause = 10000;
boolean lockLow = true;
boolean takeLowTime;
boolean isPlaying = false;
int pirPin = 2;      // PIR motion sensor connected to pin 2
int ledPin1 = 3;    // LED connected to digital pin 12
int ledPin2 = 4;    // LED connected to digital pin 1
int ledPin3 = 6;    // LED connected to digital pin 0
int ledPin4 = 7;
int ledPin5 = 8;
int ledPin6 = 9;
int ledPin7 = 11;
int ledPin8 = 12;



float kickSize, snareSize, hatSize;

void setup() {
  size(512, 200, P3D);
  arduino = new Arduino(this, Arduino.list()[1], 57600);
  arduino.pinMode(pirPin, Arduino.INPUT);
  arduino.digitalWrite(pirPin, Arduino.LOW);
  minim = new Minim(this);

  
  song = minim.loadFile("Christmas.mp3", 2048);
  //song.play();
  // a beat detection object that is FREQ_ENERGY mode that 
  // expects buffers the length of song's buffer size
  // and samples captured at songs's sample rate
  beat = new BeatDetect(song.bufferSize(), song.sampleRate());
  // set the sensitivity to 300 milliseconds
  // After a beat has been detected, the algorithm will wait for 300 milliseconds 
  // before allowing another beat to be reported. You can use this to dampen the 
  // algorithm if it is giving too many false-positives. The default value is 10, 
  // which is essentially no damping. If you try to set the sensitivity to a negative value, 
  // an error will be reported and it will be set to 10 instead. 
  beat.setSensitivity(100);  
  kickSize = snareSize = hatSize = 16;
  // make a new beat listener, so that we won't miss any buffers for the analysis
  bl = new BeatListener(beat, song);  
  textFont(createFont("Helvetica", 16));
  textAlign(CENTER);
  
  arduino.pinMode(ledPin1, Arduino.OUTPUT);    
  arduino.pinMode(ledPin2, Arduino.OUTPUT);  
  arduino.pinMode(ledPin3, Arduino.OUTPUT);  
  arduino.pinMode(ledPin4, Arduino.OUTPUT);    
  arduino.pinMode(ledPin5, Arduino.OUTPUT);  
  arduino.pinMode(ledPin6, Arduino.OUTPUT);     
  arduino.pinMode(ledPin7, Arduino.OUTPUT);  
  arduino.pinMode(ledPin8, Arduino.OUTPUT);  
}

void draw() {
  
    background(0);
    fill(255);
    int pirPinRead = arduino.digitalRead(pirPin);
    //Check if there is motion and song is not playing, starts song
  if (pirPinRead == Arduino.HIGH && isPlaying == false && millis() > 1000) {
    song.play();
    isPlaying = true;
    println("PLAY!");
    if(lockLow){
      lockLow = false;
      delay(50);
    }
    takeLowTime = true;
  }  

  //Check if there is motion and song is playing, pauses song
  if(pirPinRead == Arduino.LOW && isPlaying == true){
    if(takeLowTime){
      lowIn = millis();
      takeLowTime = false;
    }
    if(!lockLow && millis() - lowIn > pause){
      lockLow = true;
       song.pause();
       isPlaying = false;
       println("PAUSE!");
    }
    
  } 
 
  
  if(beat.isKick()) {
      arduino.digitalWrite(ledPin1, Arduino.HIGH);   // set the LED on
      arduino.digitalWrite(ledPin2, Arduino.HIGH);
     // arduino.digitalWrite(ledPin3, Arduino.HIGH);
      kickSize = 32;
  }
  if(beat.isSnare()) {
      arduino.digitalWrite(ledPin3, Arduino.HIGH);
      arduino.digitalWrite(ledPin4, Arduino.HIGH);
      arduino.digitalWrite(ledPin5, Arduino.HIGH);
      arduino.digitalWrite(ledPin6, Arduino.HIGH);
      snareSize = 32;
  }
  if(beat.isHat()) {
      arduino.digitalWrite(ledPin7, Arduino.HIGH);   // set the LED on
      arduino.digitalWrite(ledPin8, Arduino.HIGH);
      hatSize = 32;
  }
  arduino.digitalWrite(ledPin1, Arduino.LOW);    // set the LED off
  arduino.digitalWrite(ledPin2, Arduino.LOW);    // set the LED off
  arduino.digitalWrite(ledPin3, Arduino.LOW);    // set the LED off
  arduino.digitalWrite(ledPin4, Arduino.LOW);    // set the LED off
  arduino.digitalWrite(ledPin5, Arduino.LOW);    // set the LED off
  arduino.digitalWrite(ledPin6, Arduino.LOW);    // set the LED off
  arduino.digitalWrite(ledPin7, Arduino.LOW);    // set the LED off
  arduino.digitalWrite(ledPin8, Arduino.LOW);    // set the LED off
  textSize(kickSize);
  text("KICK", width/4, height/2);
  textSize(snareSize);
  text("SNARE", width/2, height/2);
  textSize(hatSize);
  text("HAT", 3*width/4, height/2);
  kickSize = constrain(kickSize * 0.95, 16, 32);
  snareSize = constrain(snareSize * 0.95, 16, 32);
  hatSize = constrain(hatSize * 0.95, 16, 32);
 /* if(pirPinRead == Arduino.HIGH && isPlaying == true){
    song.pause();
    isPlaying = false; 
  } */
}

void stop() {
  // always close Minim audio classes when you are finished with them
  song.close();
  // always stop Minim before exiting
  minim.stop();
  // this closes the sketch
  super.stop();
}