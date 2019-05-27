import processing.sound.*;
import SimpleOpenNI.*;

//Generate a SimpleOpenNI object
SimpleOpenNI kinect;

//FileReproducer declaration
SoundFile player;

//MusicBox declaration
MusicBox mb;

//Vectors used to calculate the center of the mass
PVector com = new PVector();
PVector com2d = new PVector();

int circle_level_first_row = 60;
int circle_level_bonus_row = 150;
int circle_level_lower_row = 400;

int[] noteCounter = {0, 0, 0, 0, 0, 0, 0, 0};

//variable for easter egg
boolean easter_egg = true;

//Up
float LeftshoulderAngle = 0;
float LeftelbowAngle = 0;
float RightshoulderAngle = 0;
float RightelbowAngle = 0;

//Legs
float RightLegAngle = 0;
float LeftLegAngle = 0;

//Timer variables
float a = 0;

void setup() {
        size(1280, 960);
        kinect = new SimpleOpenNI(this);
        mb = new MusicBox();
        mb.initialize();
        // nome file audio con estensione '.mp3'
        player = new SoundFile(this, "GoT.mp3");
        kinect.enableDepth();
        kinect.enableIR();
        kinect.enableUser();// because of the version this change
        //size(640, 480);
        fill(255, 0, 0);
        //size(kinect.depthWidth()+kinect.irWidth(), kinect.depthHeight());
        kinect.setMirror(false);
        
}

void draw() {
        kinect.update();
        //image(kinect.depthImage(), 0, 0);
        //image(kinect.irImage(),kinect.depthWidth(),0);
        PImage userImage = kinect.userImage();
        userImage.updatePixels();
        scale(2);
        image(userImage,0,0);
        //4 UPPER CIRCLES
        stroke(255, 255, 255);
        fill(0, 255, 0);
        circle(590, circle_level_first_row, 30);
        stroke(255, 255, 255);
        fill(255, 0, 0);
        circle(50, circle_level_first_row, 30);
        stroke(255, 255, 255);
        fill(255, 255, 0);
        circle(150, circle_level_first_row, 30);
        stroke(255, 255, 255);
        fill(255, 0, 255);
        circle(490, circle_level_first_row, 30);
        
        //2 CENTRAL CIRCLES
        stroke(255, 255, 255);
        fill(255, 165, 0, 127);
        circle(590, circle_level_bonus_row, 40);
        stroke(255, 255, 255);
        fill(0, 255, 255, 127);
        circle(50, circle_level_bonus_row, 40);
        
        //2 LOWER CIRCLES 
        stroke(255, 255, 255);
        fill(255, 165, 0);
        circle(540, circle_level_lower_row, 40);
        stroke(255, 255, 255);
        fill(0, 255, 255);
        circle(100, circle_level_lower_row, 40);
        
        
        IntVector userList = new IntVector();
        kinect.getUsers(userList);
        
        if (userList.size() > 0) {
                int userId = userList.get(0);
                //If we detect one user we have to draw it
                if( kinect.isTrackingSkeleton(userId)) {
                        //DrawSkeleton
                        drawSkeleton(userId);
                        //drawUpAngles
                        ArmsAngle(userId);
                        //Draw the user Mass
                        MassUser(userId);
                        //AngleLeg
                        LegsAngle(userId);
                }
        }
}
//Draw the skeleton
void drawSkeleton(int userId) {
        stroke(0);
        strokeWeight(5);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
        kinect.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_LEFT_HIP);
        //Hands coordinates
        PVector jointPos1 = new PVector();
        PVector convertedJoint1 = new PVector();
        kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, jointPos1);
        kinect.convertRealWorldToProjective(jointPos1, convertedJoint1);
        PVector jointPos2 = new PVector();
        PVector convertedJoint2 = new PVector();
        kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, jointPos2);
        kinect.convertRealWorldToProjective(jointPos2, convertedJoint2);
        
        //Easter Egg
        if(convertedJoint1.x >= 35 && convertedJoint1.x <= 65 && convertedJoint1.y >= 45 && convertedJoint1.y <= 75 && convertedJoint2.x >= 575 && convertedJoint2.x <= 605 && convertedJoint2.y >= 135 && convertedJoint2.y <= 165 && easter_egg){
          player.play();
          sleep(2000);
          player.pause();
        }
        // check for piano notes 
        else{
          if(convertedJoint1.x >= 35 && convertedJoint1.x <= 65 && convertedJoint1.y >= 45 && convertedJoint1.y <= 75){
            if(noteCounter[0]%5 == 0){
              mb.playNote(60,500);
              noteCounter[0] = noteCounter[0] + 1;
            }
            else{
                noteCounter[0] = noteCounter[0] + 1;
            } 
          }
          else{
            if(convertedJoint1.x >= 135 && convertedJoint1.x <= 165 && convertedJoint1.y >= 45 && convertedJoint1.y <= 75){
              if(noteCounter[1]%5 == 0){
                mb.playNote(62,500);
                noteCounter[1] = noteCounter[1] + 1;
              }
              else{
                  noteCounter[1] = noteCounter[1] + 1;
              } 
            }
          } 
          if(convertedJoint1.x >= 35 && convertedJoint1.x <= 65 && convertedJoint1.y >= 135 && convertedJoint1.y <= 165){
              if(noteCounter[2]%5 == 0){
                mb.playScale(70,71,72,73,74,75,76,77,500);
                noteCounter[2] = noteCounter[2] + 1;
              }
              else{
                  noteCounter[2] = noteCounter[2] + 1;
              } 
            }
            //CHECK RIGHT HAND
        
          if(convertedJoint2.x >= 575 && convertedJoint2.x <= 605 && convertedJoint2.y >= 45 && convertedJoint2.y <= 75){
            if(noteCounter[3]%5==0){
              mb.playNote(66,500);
              noteCounter[3] = noteCounter[3] + 1;
            }
            else{
                noteCounter[3] = noteCounter[3] + 1;
            } 
          }
          else{
            if(convertedJoint2.x >= 475 && convertedJoint2.x <= 505 && convertedJoint2.y >= 45 && convertedJoint2.y <= 75){
              if(noteCounter[4]%5 == 0){
                mb.playNote(64,500);
                noteCounter[4] = noteCounter[4] + 1;
              }
              else{
                  noteCounter[4] = noteCounter[4] + 1;
              } 
            }
          }
          if(convertedJoint2.x >= 575 && convertedJoint2.x <= 605 && convertedJoint2.y >= 135 && convertedJoint2.y <= 165){
            if(noteCounter[5]%5==0){
              mb.playScale(80,81,82,83,84,85,86,87,500);
              noteCounter[5] = noteCounter[5] + 1;
            }
            else{
                noteCounter[5] = noteCounter[5] + 1;
            } 
          }
        }
        
        //FEET COORDINATES
        PVector jointPos3 = new PVector();
        PVector convertedJoint3 = new PVector();
        kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_FOOT, jointPos3);
        kinect.convertRealWorldToProjective(jointPos3, convertedJoint3);
        PVector jointPos4 = new PVector();
        PVector convertedJoint4 = new PVector();
        kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_FOOT, jointPos4);
        kinect.convertRealWorldToProjective(jointPos4, convertedJoint4);
        
        if(convertedJoint3.x >= 80 && convertedJoint3.x <= 120 && convertedJoint3.y >= 380 && convertedJoint3.y <= 420){
          if(noteCounter[6]%3==0){
            mb.playNote(50,500);
            noteCounter[6] = noteCounter[6] + 1;
          }
          else{
              noteCounter[6] = noteCounter[6] + 1;
          } 
        }
        if(convertedJoint4.x >= 520 && convertedJoint4.x <= 560 && convertedJoint4.y >= 380 && convertedJoint4.y <= 420){
          if(noteCounter[7]%3==0){
            mb.playNote(51,500);
            noteCounter[7] = noteCounter[7] + 1;
          }
          else{
              noteCounter[7] = noteCounter[7] + 1;
          } 
        }
        
        noStroke();
        fill(255,0,0);
        drawJoint(userId, SimpleOpenNI.SKEL_HEAD);
        drawJoint(userId, SimpleOpenNI.SKEL_NECK);
        drawJoint(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER);
        drawJoint(userId, SimpleOpenNI.SKEL_LEFT_ELBOW);
        drawJoint(userId, SimpleOpenNI.SKEL_NECK);
        drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
        drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW);
        drawJoint(userId, SimpleOpenNI.SKEL_TORSO);
        drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);
        drawJoint(userId, SimpleOpenNI.SKEL_LEFT_KNEE);
        drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HIP);
        drawJoint(userId, SimpleOpenNI.SKEL_LEFT_FOOT);
        drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_KNEE);
        drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HIP);
        drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_FOOT);
        drawJoint(userId, SimpleOpenNI.SKEL_RIGHT_HAND);
        drawJoint(userId, SimpleOpenNI.SKEL_LEFT_HAND);
}


void drawJoint(int userId, int jointID) {
        PVector joint = new PVector();
        float confidence = kinect.getJointPositionSkeleton(userId, jointID,
                                                           joint);
        if(confidence < 0.5) {
                return;
        }
        PVector convertedJoint = new PVector();
        kinect.convertRealWorldToProjective(joint, convertedJoint);
        ellipse(convertedJoint.x, convertedJoint.y, 5, 5);
}
//Generate the angle
float angleOf(PVector one, PVector two, PVector axis) {
        PVector limb = PVector.sub(two, one);
        return degrees(PVector.angleBetween(limb, axis));
}

void sleep(int length) {
    try {
      Thread.sleep(length);
    }
    catch (Exception ex) {
    }
}

//Calibration not required

void onNewUser(SimpleOpenNI kinect, int userID) {
        println("Start skeleton tracking");
        kinect.startTrackingSkeleton(userID);
}

void onLostUser(SimpleOpenNI curContext, int userId) {
        println("onLostUser - userId: " + userId);
}

void MassUser(int userId) {
        if(kinect.getCoM(userId,com)) {
                kinect.convertRealWorldToProjective(com,com2d);
                stroke(100,255,240);
                strokeWeight(3);
                beginShape(LINES);
                vertex(com2d.x,com2d.y - 5);
                vertex(com2d.x,com2d.y + 5);
                vertex(com2d.x - 5,com2d.y);
                vertex(com2d.x + 5,com2d.y);
                endShape();
                fill(0,255,100);
                text(Integer.toString(userId),com2d.x,com2d.y);
        }
}

public void ArmsAngle(int userId){
        // get the positions of the three joints of our right arm
        PVector rightHand = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HAND,rightHand);
        PVector rightElbow = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_ELBOW,rightElbow);
        PVector rightShoulder = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_SHOULDER,rightShoulder);
        // we need right hip to orient the shoulder angle
        PVector rightHip = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HIP,rightHip);
        // get the positions of the three joints of our left arm
        PVector leftHand = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HAND,leftHand);
        PVector leftElbow = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_ELBOW,leftElbow);
        PVector leftShoulder = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_SHOULDER,leftShoulder);
        // we need left hip to orient the shoulder angle
        PVector leftHip = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HIP,leftHip);
        // reduce our joint vectors to two dimensions for right side
        PVector rightHand2D = new PVector(rightHand.x, rightHand.y);
        PVector rightElbow2D = new PVector(rightElbow.x, rightElbow.y);
        PVector rightShoulder2D = new PVector(rightShoulder.x,rightShoulder.y);
        PVector rightHip2D = new PVector(rightHip.x, rightHip.y);
        // calculate the axes against which we want to measure our angles
        PVector torsoOrientation = PVector.sub(rightShoulder2D, rightHip2D);
        PVector upperArmOrientation = PVector.sub(rightElbow2D, rightShoulder2D);
        // reduce our joint vectors to two dimensions for left side
        PVector leftHand2D = new PVector(leftHand.x, leftHand.y);
        PVector leftElbow2D = new PVector(leftElbow.x, leftElbow.y);
        PVector leftShoulder2D = new PVector(leftShoulder.x,leftShoulder.y);
        PVector leftHip2D = new PVector(leftHip.x, leftHip.y);
        // calculate the axes against which we want to measure our angles
        PVector torsoLOrientation = PVector.sub(leftShoulder2D, leftHip2D);
        PVector upperArmLOrientation = PVector.sub(leftElbow2D, leftShoulder2D);
        // calculate the angles between our joints for rightside
        RightshoulderAngle = angleOf(rightElbow2D, rightShoulder2D, torsoOrientation);
        RightelbowAngle = angleOf(rightHand2D,rightElbow2D,upperArmOrientation);
        // show the angles on the screen for debugging
        fill(255,0,0);
        scale(1);
        text("Right shoulder: " + int(RightshoulderAngle) + "\n" + " Right elbow: " + int(RightelbowAngle), 20, 20);
        // calculate the angles between our joints for leftside
        LeftshoulderAngle = angleOf(leftElbow2D, leftShoulder2D, torsoLOrientation);
        LeftelbowAngle = angleOf(leftHand2D,leftElbow2D,upperArmLOrientation);
        // show the angles on the screen for debugging
        fill(255,0,0);
        scale(1);
        text("Left shoulder: " + int(LeftshoulderAngle) + "\n" + " Left elbow: " + int(LeftelbowAngle), 20, 55);
}

void LegsAngle(int userId) {
        // get the positions of the three joints of our right leg
        PVector rightFoot = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_FOOT,rightFoot);
        PVector rightKnee = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_KNEE,rightKnee);
        PVector rightHipL = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_RIGHT_HIP,rightHipL);
        // reduce our joint vectors to two dimensions for right side
        PVector rightFoot2D = new PVector(rightFoot.x, rightFoot.y);
        PVector rightKnee2D = new PVector(rightKnee.x, rightKnee.y);
        PVector rightHip2DLeg = new PVector(rightHipL.x,rightHipL.y);
        // calculate the axes against which we want to measure our angles
        PVector RightLegOrientation = PVector.sub(rightKnee2D, rightHip2DLeg);
        // calculate the angles between our joints for rightside
        RightLegAngle = angleOf(rightFoot2D,rightKnee2D,RightLegOrientation);
        fill(255,0,0);
        scale(1);
        text("Right Knee: " + int(RightLegAngle), 500, 20);
        // get the positions of the three joints of our left leg
        PVector leftFoot = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_FOOT,leftFoot);
        PVector leftKnee = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_KNEE,leftKnee);
        PVector leftHipL = new PVector();
        kinect.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_LEFT_HIP,leftHipL);
        // reduce our joint vectors to two dimensions for left side
        PVector leftFoot2D = new PVector(leftFoot.x, leftFoot.y);
        PVector leftKnee2D = new PVector(leftKnee.x, leftKnee.y);
        PVector leftHip2DLeg = new PVector(leftHipL.x,leftHipL.y);
        // calculate the axes against which we want to measure our angles
        PVector LeftLegOrientation = PVector.sub(leftKnee2D, leftHip2DLeg);
        // calculate the angles between our joints for left side
        LeftLegAngle = angleOf(leftFoot2D,leftKnee2D,LeftLegOrientation);
        // show the angles on the screen for debugging
        fill(255,0,0);
        scale(1);
        text("Leftt Knee: " + int(LeftLegAngle), 500, 55);
}


//////////////////////////////////////////////////////////////////////////////////////////////////
//This is the MusicBox code
 
import java.util.Arrays;
import javax.sound.midi.*;
public class MusicBox {
   Synthesizer synthesizer;
   MidiChannel[] channels;
   boolean noSound = false;
 
  public void initialize() {
    try {
      if (!noSound) {
        synthesizer = MidiSystem.getSynthesizer();
        synthesizer.open();
 
        channels = synthesizer.getChannels();
 
        Instrument[] instr = synthesizer.getDefaultSoundbank()
          .getInstruments();
        synthesizer.loadInstrument(instr[0]);
        System.out.println(channels.length);
      }
    }
    catch (Exception ex) {
      System.out.println("Could not load the MIDI synthesizer.");
    }
  }
 
  public void cleanUp() {
    if (synthesizer != null)
      synthesizer.close();
  }
 
  public void playNote(final int note, final int milliseconds) {
    //System.out.print("Playing note" + note);
 
    Thread t = new Thread() {
      public void run() {
        try {
          if (!noSound && channels != null && channels.length > 0) {
            channels[0].noteOn(note, 120);
            sleep(milliseconds);
            channels[0].noteOff(note);
          }
        } 
        catch (Exception ex) {
          System.out.println("ERROR: " + ex);
        }
      }
    };
    t.start();
  }
 
  public void playChord(int note1, int note2, int note3, int milliseconds) {
    playChord(new int[] {note1, note2, note3}, milliseconds); 
  }
   
  public void playChord(final int[] notes, final int milliseconds) {
    System.out.println("");
 
    Thread t = new Thread() {
      public void run() {
        try {
          if (!noSound && channels != null && channels.length > 0) {
            int channel = 0;
            for (int n : notes) {
              channels[channel++].noteOn(n, 120);
            }
            sleep(milliseconds);
            for (channel = 0; channel < notes.length; channel++) {
              channels[channel].noteOff(notes[channel]);
            }
          }
        }
        catch (Exception ex) {
          System.out.println("ERROR:" + ex);
        }
      }
    };
    t.start();
  }
   
  public void playScale(int note1, int note2, int note3, int note4, int note5,
    int note6, int note7, int note8, int milliseconds) {
    playScale(new int[] {note1, note2, note3, note4, note5, note6, note7, note8}, milliseconds);      
  }
 
  public void playScale(final int[] notes, final int milliseconds) {
    Thread t = new Thread() {
      public void run() {
        try {
          if (!noSound && channels != null && channels.length > 0) {
            for (int n : notes) {
              channels[0].noteOn(n, 120);
              sleep(milliseconds);
              channels[0].noteOff(n);
            }
          }
        }
        catch (Exception ex) {
          System.out.println("ERROR:" + ex);
        }
      }
    };
    t.start();
  }
 
  private void sleep(int length) {
    try {
      Thread.sleep(length);
    }
    catch (Exception ex) {
    }
  }
}
