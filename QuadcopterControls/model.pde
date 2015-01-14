class Model{
  
  final String serialPort = "COM3";
  
  double xInput, yInput, zInput, turnInput;
  int serialConnection, gamepadConnection;
  String outputText;
  boolean isEnabled;
  boolean isRequested, isAcked, isIncomingAcked;
  int numIncoming, numReceived;
  int[] tmpInput, input;
  
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
    isIncomingAcked = false;
    numIncoming = 0;
    numReceived = 0;
    tmpInput = new int[4];
    input = new int[4];
    gamepadRefreshTimer = millis();
    serialSendTimer = millis();
    
  }
  
  /*
   * This implements a custom multi-bit serial protocol. Here are the particulars
   *
   * When a machine wants to send a message, it begins by sending a request.
   * A request is a byte containing 128 + [number of bytes of information contained in the message]
   * A request may be sent repeatedly to ensure it is received.
   *
   * Once the other machine receives the request, the receiving machine will clear its serial buffer  
   * in preparation for receiving the rest of the message.
   * It will then ack (acknowlege) the request by sending a single byte containing 128.
   *
   * Once the sending machine receives the ack, it stops sending requests and begins sending the main message.
   * Data in the main message must be < 128, any byte greater than 128 will be interpreted as either a request or an ack.
   *
   */
  
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
        if(data == 128){
          if(isRequested){
            isAcked = true;
            isRequested = false;
          }
        }
        else if(data > 128){
          // Request from quadcopter
          // TODO: might need to flush the serial buffer here. Probably not because garunteed there are no <128 bytes
          serial.write(128); // Ack it
          isIncomingAcked = true;
          numIncoming = data & 127;
          numReceived = 0;
        }
        else{
          if(isIncomingAcked){
            tmpInput[numReceived] = convert7B2CToInt(data);
            numReceived++;
            if(numReceived >= numIncoming){
              for(int i = 0; i < numReceived; i++){
                input[i] = tmpInput[i];
              }
              isAcked = false;
              numIncoming = 0;
              numReceived = 0;
            }
            
          }
        }
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
  
  // Converts a 7-bit 2's compliment [-64,63] to an int
  int convert7B2CToInt(int input){
    if(input < 64){
      return input;
    }
    else{
      return input - 128;
    }
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

