class View{
  
  // Joystick Display Parameters
  final int joystickDisplayCenterX = 137;
  final int joystickDisplayCenterY = 137;
  final int joystickDisplayOuterDiameter = 175;
  final int joystickDisplayKnobDiameter = 50;
  final int joystickDisplayStroke = 0;
  final int joystickDisplayKnobStroke = 0;
  final int joystickDisplayKnobFill = 200;
  final int joystickDisplayOuterFill = 255;
  
  final int joystickDisplayBoxCornerX = 25;
  final int joystickDisplayBoxCornerY = 50;
  final int joystickDisplayBoxWidth = 225;
  final int joystickDisplayBoxHeight = 225;
  final int joystickDisplayFill = 255;
  
  // Throttle Display Parameters
  final int throttleDisplayBoxCornerX = 260;
  final int throttleDisplayBoxCornerY = 50;
  final int throttleDisplayBoxWidth = 40;
  final int throttleDisplayBoxHeight = 175;
  final int throttleDisplayKnobHeight = 10;
  final int throttleDisplayBoxFill = 255;
  final int throttleDisplayKnobFill = 200;
  final int throttleDisplayStroke = 0;
  
  // Turn Display Parameters
  final int turnDisplayRadius = 105;
  final int turnDisplayKnobDiameter = 20;
  final int turnDisplayKnobFill = 200;
  final int turnDisplayKnobStroke = 0;
  
  // Indicator Light Parameters
  
  
  // Text Output Parameters
  final int textOutputBoxCornerX = 25;
  final int textOutputBoxCornerY = 350;
  final int textOutputBoxWidth = 275;
  final int textOutputBoxHeight = 50;
  final int textOutputSize = 16;
  final int textOutputFill = 0;
  final int textOutputBoxFill = 230;
  final int textOutputBoxStroke = 255;
  
  color green = color(0, 255, 0);
  color red = color(255, 0, 0);
  color yellow = color(255, 255, 0);
  
  View(){
    // Initialize Display
    size(325, 450);
    background(255);
  }
  
  void clearScreen(){
    background(255);
    
    stroke(255);
    for(int i = 0; i < 350; i += 25){
      line(i, 0, i, 450);
    }
    for(int i = 0; i < 450; i += 25){
      line(0, i, 350, i);
    }
  }
  
  void updateJoystickDisplay(double x, double y, double z, double turn){
    
    // Joystick Display
    stroke(joystickDisplayStroke);
    fill(joystickDisplayOuterFill);
    ellipse(joystickDisplayCenterX, 
            joystickDisplayCenterY, 
            joystickDisplayOuterDiameter, 
            joystickDisplayOuterDiameter);
            
    int joystickKnobBound = (joystickDisplayOuterDiameter - joystickDisplayKnobDiameter) / 2;
    int joystickKnobX = (int)(x * joystickKnobBound);
    int joystickKnobY = (int)(-y * joystickKnobBound);
    if(joystickKnobX * joystickKnobX + joystickKnobY * joystickKnobY > joystickKnobBound * joystickKnobBound){
      float r = joystickKnobBound;
      float theta = atan2((float)joystickKnobY,(float)joystickKnobX);
      joystickKnobX = (int)(r * cos(theta));
      joystickKnobY = (int)(r * sin(theta));
    }
    
    stroke(joystickDisplayKnobStroke);
    fill(joystickDisplayKnobFill);
    ellipse(joystickDisplayCenterX + joystickKnobX, 
            joystickDisplayCenterY + joystickKnobY, 
            joystickDisplayKnobDiameter,
            joystickDisplayKnobDiameter);
            
    // New Joystick Display
    //fill(joystickDisplayFill);
    //noFill();
    //rect(joystickDisplayBoxCornerX, joystickDisplayBoxCornerY, joystickDisplayBoxWidth, joystickDisplayBoxHeight);
    //stroke(0);
    //fill(0);
    
    
            
    // Throttle Display        
    stroke(throttleDisplayStroke);
    fill(throttleDisplayBoxFill);
    rect(throttleDisplayBoxCornerX, throttleDisplayBoxCornerY, throttleDisplayBoxWidth, throttleDisplayBoxHeight);
    fill(throttleDisplayKnobFill);
    rect(throttleDisplayBoxCornerX, 
         throttleDisplayBoxCornerY + round((float)((1 - z) * (throttleDisplayBoxHeight - throttleDisplayKnobHeight))), 
         throttleDisplayBoxWidth, 
         throttleDisplayKnobHeight);
    
    // Turn Display
    stroke(turnDisplayKnobStroke);
    fill(turnDisplayKnobFill);
    ellipse(joystickDisplayCenterX + (int)(cos((float)(3.14159 / 2.0 + -turn * 3.14159 / 2.0)) * turnDisplayRadius),
            joystickDisplayCenterY - (int)(sin((float)(3.14159 / 2.0 + -turn * 3.14159 / 2.0)) * turnDisplayRadius),
            turnDisplayKnobDiameter,
            turnDisplayKnobDiameter);
            
  }
  
  void updateGyroDisplay(double x, double y, double turn){
    stroke(0);
    
    int gyroBound = (joystickDisplayOuterDiameter - joystickDisplayKnobDiameter) / 2;
    int gyroX = (int)(x * gyroBound);
    int gyroY = (int)(-y * gyroBound);
    if(gyroX * gyroX + gyroY * gyroY > gyroBound * gyroBound){
      float r = gyroBound;
      float theta = atan2((float)gyroY,(float)gyroX);
      gyroX = (int)(r * cos(theta));
      gyroY = (int)(r * sin(theta));
    }
    
    line(joystickDisplayCenterX + gyroX, 
         joystickDisplayCenterY + gyroY + joystickDisplayKnobDiameter / 2, 
         joystickDisplayCenterX + gyroX, 
         joystickDisplayCenterY + gyroY - joystickDisplayKnobDiameter / 2
         );
    
    line(joystickDisplayCenterX + gyroX + joystickDisplayKnobDiameter / 2, 
         joystickDisplayCenterY + gyroY, 
         joystickDisplayCenterX + gyroX - joystickDisplayKnobDiameter / 2, 
         joystickDisplayCenterY + gyroY
         );
         
    // Gyro turn
    line(joystickDisplayCenterX + (int)(cos((float)(3.14159 / 2.0 + -turn * 3.14159 / 2.0)) * turnDisplayRadius),
         joystickDisplayCenterY - (int)(sin((float)(3.14159 / 2.0 + -turn * 3.14159 / 2.0)) * turnDisplayRadius) + turnDisplayKnobDiameter / 2,
         joystickDisplayCenterX + (int)(cos((float)(3.14159 / 2.0 + -turn * 3.14159 / 2.0)) * turnDisplayRadius),
         joystickDisplayCenterY - (int)(sin((float)(3.14159 / 2.0 + -turn * 3.14159 / 2.0)) * turnDisplayRadius) - turnDisplayKnobDiameter / 2);
 
     line(joystickDisplayCenterX + (int)(cos((float)(3.14159 / 2.0 + -turn * 3.14159 / 2.0)) * turnDisplayRadius) + turnDisplayKnobDiameter / 2,
         joystickDisplayCenterY - (int)(sin((float)(3.14159 / 2.0 + -turn * 3.14159 / 2.0)) * turnDisplayRadius),
         joystickDisplayCenterX + (int)(cos((float)(3.14159 / 2.0 + -turn * 3.14159 / 2.0)) * turnDisplayRadius) - turnDisplayKnobDiameter / 2,
         joystickDisplayCenterY - (int)(sin((float)(3.14159 / 2.0 + -turn * 3.14159 / 2.0)) * turnDisplayRadius));
         
  }

  
  void updateGamepadIndicator(int gamepadConnection){
    if(gamepadConnection == DISCONNECTED){
      fill(red);
    }
    else if(gamepadConnection == CONNECTED){
      fill(green);
    }
    else if(gamepadConnection == CONNECTING){
      fill(yellow);
      println("yellow");
    }
    stroke(200);
    ellipse(37, 287, 21, 21); 
    fill(0);
    textSize(textOutputSize);
    text("Gamepad", 55, 295);
  }
  
  void updateSerialIndicator(int serialConnection, String serialPort){
    if(serialConnection == DISCONNECTED){
      fill(red);
    }
    else if(serialConnection == CONNECTED){
      fill(green);
    }
    else{
      fill(yellow);
    }
    stroke(200);
    ellipse(37,262, 21, 21); fill(0);
    textSize(textOutputSize);
    text("Serial: " + serialPort, 55, 270);
  }
  
  void updateTextOutput(String text){
    fill(textOutputBoxFill);
    stroke(textOutputBoxStroke);
    
    rect(textOutputBoxCornerX, textOutputBoxCornerY, textOutputBoxWidth, textOutputBoxHeight);
    
    fill(textOutputFill);
    textSize(textOutputSize);
    text(text, textOutputBoxCornerX, textOutputBoxCornerY, textOutputBoxWidth, textOutputBoxHeight);
    
  }
  
  
  

  
}

