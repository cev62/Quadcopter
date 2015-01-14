import processing.serial.*;
import de.hardcode.jxinput.*;
import de.hardcode.jxinput.directinput.*;
import de.hardcode.jxinput.event.*;
import de.hardcode.jxinput.j3d.*;
import de.hardcode.jxinput.j3d.test.*;
import de.hardcode.jxinput.keyboard.*;
import de.hardcode.jxinput.test.*;
import de.hardcode.jxinput.util.*;
import de.hardcode.jxinput.virtual.*;

final int DISCONNECTED = 0;
final int CONNECTING = 1;
final int CONNECTED = 2;

View view;
Model model;

void setup(){
  
  view = new View();
  model = new Model();
  
}

void draw(){
  model.updateGamepad();
  model.updateSerial();
  view.clearScreen();
  view.updateJoystickDisplay(model.getXInput(), model.getYInput(), model.getZInput(), model.getTurnInput());
  view.updateGamepadIndicator(model.getGamepadConnection());
  view.updateSerialIndicator(model.getSerialConnection(), model.getSerialPort());
  view.updateTextOutput(model.getOutputText());
}

void mousePressed(){
  if(dist((float)mouseX, (float)mouseY, 37.0, 287.0) < 10){
    // Gamepad button pressed
    model.refreshGamepad();
  }
  if(dist((float)mouseX, (float)mouseY, 37.0, 262.0) < 10){
    // Serial button pressed
    model.toggleSerial();
  }
}

void startSerial(){
  try{
    model.serial = new Serial(this, model.getSerialPort(), 9600);
    model.serialConnection = CONNECTED;
    model.isAcked = false;
    model.isRequested = false;
  }
  catch(Exception e){
    model.failSerial();
    println(e);
  }
}



