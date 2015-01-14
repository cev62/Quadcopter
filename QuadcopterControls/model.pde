class Model{
  
  final String serialPort = "COM3";
  
  double xInput, yInput, zInput, turnInput;
  int serialConnection, gamepadConnection;
  String outputText;
  boolean isEnabled;
  boolean isRequested, isAcked;
  
  JXInputDevice gamepad;
  Serial serial;
  long gamepadRefreshTimer, serialSendTimer;
  
  Model(){
    xInput = 0.0;
    yInput = 0.0;
    zInput = 0.0;
    turnInput = 0.0;
    serialConnection = DISCONNECTED;
    gamepadConnection = DISCONNECTED;
    outputText = "";
    isEnabled = false;
    isRequested = false;
    isAcked = false;
    gamepadRefreshTimer = millis();
    serialSendTimer = millis();
    
  }
  
  void updateSerial(){
    if(serialConnection == CONNECTED){
      if(millis() - serialSendTimer > 50){
        
        if( isAcked ){
          sendMessage();
          isAcked = false;
        }
        else{
          requestMessage();
          isRequested = true;
          isAcked = false;
        }
        
        serialSendTimer = millis();
        
      }
      
      while(serial.available() > 0){
        int data = serial.read();
        if(isRequested){
          if(data == 128){
            isAcked = true;
            isRequested = false;
          }
        }
        //print((char)data);
      }
    }
    
  }
  
  void sendMessage(){
    serial.write(convertFloatTo7B2C((float)xInput));
    serial.write(convertFloatTo7B2C((float)yInput));
    serial.write(convertFloatTo7B2C((float)zInput));
    serial.write(convertFloatTo7B2C((float)turnInput));
  }
  
  // Converts a float from [-1.0,1.0] to 7-bit 2's compliment [-64,63]
  int convertFloatTo7B2C(float input){
    int output = (int)map(input, -1.0, 1.0, -64.0, 63.0);
    if(output < 0){
      output += 128;
    }
    return output;
  }
  
  void requestMessage(){
    serial.write(128 + 4);
  }
  
  void toggleSerial(){
    if(serialConnection == CONNECTED) { return; }
    if(serialConnection == CONNECTING) { return; }
    
    if(serialConnection == DISCONNECTED){
      boolean isFound = false;
      for(int i = 0; i < Serial.list().length; i++){
        if(serialPort.equals(Serial.list()[i])){
          isFound = true;
          if(serial == null){
            serialConnection = CONNECTING;
            thread("startSerial");
          }
          else{
            println(serialPort + " is already Initialized");
          }
        }
      }
      if(!isFound){
        println(serialPort + " was not found.");
      }
    }
    
  }
  
  void failSerial(){
    serialConnection = DISCONNECTED;
  }
  
  void updateGamepad(){
    
    if(gamepadConnection == DISCONNECTED){
      JXInputManager.reset();
      for(int i = 0; i < JXInputManager.getNumberOfDevices(); i++){
        if(JXInputManager.getJXInputDevice(i).getName().equals("Controller (Gamepad F310)")){
          gamepad = JXInputManager.getJXInputDevice(i);
          gamepadConnection = CONNECTED;
          break;
        }
      }
    }

    if(gamepadConnection == CONNECTED){    
      JXInputManager.updateFeatures();        

      xInput = (gamepad.getAxis(0).getValue());
      yInput = (-gamepad.getAxis(1).getValue());
      zInput = abs((float)squareInput(-gamepad.getAxis(2).getValue()));
      if(zInput > 0.99) { zInput = 1.0; }
      if(zInput < -0.99) { zInput = -1.0; }
      turnInput = squareInput(gamepad.getAxis(3).getValue());
    }
    else{
      xInput = 0.0;
      yInput = 0.0;
      zInput = 0.0;
      turnInput = 0.0;
    }
  }
  
  void refreshGamepad(){
    JXInputManager.reset();
    gamepadConnection = DISCONNECTED;
  }
  
  String getOutputText(){
    outputText = "";
    if(gamepadConnection == DISCONNECTED){
      outputText = outputText + "Gamepad Disconnected.";
    }
    return outputText;
  }
  
  double getXInput(){ return xInput; }
  double getYInput(){ return yInput; }
  double getZInput(){ return zInput; }
  double getTurnInput(){ return turnInput; }
  int getGamepadConnection() { return gamepadConnection; }
  int getSerialConnection() { return serialConnection; }
  String getSerialPort() { return serialPort; }
  
  double squareInput(double input){
    if(input > 0){ return input * input; }
    else{ return -input * input; }
  }
  
}

