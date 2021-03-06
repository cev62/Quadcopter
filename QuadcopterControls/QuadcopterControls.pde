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
import java.io.*;
import java.net.*;

int CONNECTED = 0;
int CONNECTING = 1;
int DISCONNECTED = 2;

View view;
Model model;
Comm comm;

void setup(){
  
  view = new View();
  model = new Model();
  comm = new Comm(model);
  
}

void draw(){
  model.updateGamepad();
  comm.update();
  
  //println("Gyro: " + model.getGyroX() + ", " + comm.dataIn + ", " + comm.dataOut);
  
  view.clearScreen();
  view.updateJoystickDisplay(model.getXInput(), model.getYInput(), model.getZInput(), model.getTurnInput());
  view.updateGyroDisplay(model.getGyroX(), model.getGyroY(), model.getGyroTurn());
  view.updateGamepadIndicator(model.getGamepadConnection());
  view.updateSerialIndicator(comm.isConnected());
  view.updateTextOutput(model.getOutputText());
}

void mousePressed(){
  if(dist((float)mouseX, (float)mouseY, 37.0, 287.0) < 10){
    // Gamepad button pressed
    model.refreshGamepad();
  }
  if(dist((float)mouseX, (float)mouseY, 37.0, 262.0) < 10){
    // Serial button pressed
    comm.toggleConnection();
  }
}


