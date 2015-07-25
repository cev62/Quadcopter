class Comm{
  
  final String serialPort = "COM9";
  
  boolean isRequested, isAcked, isIncomingAcked;
  int numIncoming, numReceived;
  float[] tmpInput;
  
  int serialConnection;
  Serial serial;
  
  long serialSendTimer;
  int dataIn, dataOut;
  Model model;
  
  Comm(Model model){
    this.model = model;
    serialConnection = DISCONNECTED;

    isRequested = false;
    isAcked = false;
    isIncomingAcked = false;
    numIncoming = 0;
    numReceived = 0;
    dataIn = 0;
    dataOut = 0;
    tmpInput = new float[3];
    
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
          requestMessage();
          isRequested = true;
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
            //println("Data " + numIncoming + ": " + data);
            tmpInput[numReceived] = map((float)convert7B2CToInt(data), -64.0, 63.0, -1.0, 1.0);
            if(numReceived == 0){ dataIn = data; }
            numReceived++;
            if(numReceived >= numIncoming){
              loadInputIntoModel();
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
    serial.write(convertFloatTo7B2C((float)model.xInput));
    dataOut = convertFloatTo7B2C((float)model.xInput);
    serial.write(convertFloatTo7B2C((float)model.yInput));
    serial.write(convertFloatTo7B2C((float)model.zInput));
    serial.write(convertFloatTo7B2C((float)model.turnInput));
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
    if(serialConnection == CONNECTED) { 
      // Was just a return. Adding code to disconnect the serial port
      // return;
      
      serial.stop();
      serial = null;
      serialConnection = DISCONNECTED;
    }
    else if(serialConnection == CONNECTING) { return; }
    
    else if(serialConnection == DISCONNECTED){
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
  
  void loadInputIntoModel(){
    model.gyroX = tmpInput[0];
    model.gyroY = tmpInput[1];
    model.gyroTurn = tmpInput[2];
  }
  
  int getSerialConnection() { return serialConnection; }
  String getSerialPort() { return serialPort; }
  
}
