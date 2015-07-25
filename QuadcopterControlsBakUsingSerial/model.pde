class Model{

  double xInput, yInput, zInput, turnInput;
  double gyroX, gyroY, gyroTurn;
  int gamepadConnection;
  String outputText;
  boolean isEnabled;
  
  JXInputDevice gamepad;
  long gamepadRefreshTimer;
  
  Model(){
    xInput = 0.0;
    yInput = 0.0;
    zInput = 0.0;
    turnInput = 0.0;
    gamepadConnection = DISCONNECTED;
    outputText = "";
    isEnabled = false;
    gamepadRefreshTimer = millis();    
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

      xInput = squareInput(gamepad.getAxis(0).getValue());
      yInput = squareInput(-gamepad.getAxis(1).getValue());
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
  double getGyroX(){ return gyroX; }
  double getGyroY(){ return gyroY; }
  double getGyroTurn(){ return gyroTurn; }
  int getGamepadConnection() { return gamepadConnection; }
  
  double squareInput(double input){
    if(input > 0){ return input * input; }
    else{ return -input * input; }
  }
  
}

