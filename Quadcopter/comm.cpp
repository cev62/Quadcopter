#include "comm.h"

Comm::Comm():
serial(3, 2) // RX, TX
{
  Serial.begin(9600);
  serial.begin(9600);
  isAcked = false;
  isOutgoingAcked = false;
  isOutgoingRequested = false;
  numIncoming = 0;
  numReceived = 0;
  input = new int[4];
  input[0] = 0;
  input[1] = 0;
  input[2] = 0;
  input[3] = 0;
  tmpInput = new int[4];
  pseudoGyro = new float[4];
  pseudoGyro[0] = 0.0;
  pseudoGyro[1] = 0.0;
  pseudoGyro[2] = 0.0;
  pseudoGyro[3] = 0.0;
  lastMessageReceivedTimer = 0;
}

void Comm::Update(){
  if(millis() - serialSendTimer > 50){
   
    for(int i = 0; i < 4; i++){
      float convertedInput = 0.0;
      if(input >= 0){ convertedInput = (float)input[i] / 63.0; }
      else { convertedInput = (float)input[i] / 64.0; }
      if(IsFreshMessage()){
        pseudoGyro[i] = 0.5 * (pseudoGyro[i] + convertedInput);
      }
    }
    
    if(isOutgoingAcked){
      //for(int i = 0; i < 4; i++){
      //  Serial.write(convertFloatTo7B2C(pseudoGyro[i]));
      //}
      Serial.write(convertFloatTo7B2C(pseudoGyro[0]));
      Serial.write(convertFloatTo7B2C(pseudoGyro[1]));
      //Serial.write(convertFloatTo7B2C(pseudoGyro[2]));
      Serial.write(convertFloatTo7B2C(pseudoGyro[3]));
      isOutgoingAcked = false;
    }
    else{
      Serial.write(128 + 3);
      isOutgoingRequested = true;
      isOutgoingAcked = false;
    }
    
    serialSendTimer = millis();
  }
  
  
  while(Serial.available() > 0){
    int data = Serial.read();
    delay(10);
    if(data == 128){
      if(isOutgoingRequested){
        isOutgoingAcked = true;
        isOutgoingRequested = false;
      }
    }
    else if(data > 128){
      // Request from controls
      // Data is a request: clear the rest of the buffer
      while(Serial.available() > 0) { int trash = Serial.read(); }
      delay(10);
      Serial.write(128);  // Ack the request
      isAcked = true;
      numIncoming = data & 127;
      numReceived = 0;
      if(numIncoming == 0){
        isAcked = false;
      }
    }
    else{
      if(isAcked){
        // data is actual data
        tmpInput[numReceived] = convert7B2CToInt(data);
        numReceived++;
        if(numReceived >= numIncoming){
          for(int i = 0; i < numReceived; i++){
            input[i] = tmpInput[i];
          }
          isAcked = false;
          numIncoming = 0;
          numReceived = 0;
          lastMessageReceivedTimer = millis();
        }
      }
    }
  }
}
void Comm::UpdateSS(){
  if(millis() - serialSendTimer > 50){
   
    for(int i = 0; i < 4; i++){
      float convertedInput = 0.0;
      if(input >= 0){ convertedInput = (float)input[i] / 63.0; }
      else { convertedInput = (float)input[i] / 64.0; }
      if(IsFreshMessage()){
        pseudoGyro[i] = 0.5 * (pseudoGyro[i] + convertedInput);
      }
    }
    
    if(isOutgoingAcked){
      //for(int i = 0; i < 4; i++){
      //  Serial.write(convertFloatTo7B2C(pseudoGyro[i]));
      //}
      serial.write(convertFloatTo7B2C(pseudoGyro[0]));
      serial.write(convertFloatTo7B2C(pseudoGyro[1]));
      //Serial.write(convertFloatTo7B2C(pseudoGyro[2]));
      serial.write(convertFloatTo7B2C(pseudoGyro[3]));
      isOutgoingAcked = false;
    }
    else{
      serial.write(128 + 3);
      isOutgoingRequested = true;
      isOutgoingAcked = false;
    }
    
    serialSendTimer = millis();
  }
  
  
  while(serial.available() > 0){
    int data = serial.read();
    delay(10);
    if(data == 128){
      if(isOutgoingRequested){
        isOutgoingAcked = true;
        isOutgoingRequested = false;
      }
    }
    else if(data > 128){
      // Request from controls
      // Data is a request: clear the rest of the buffer
      while(serial.available() > 0) { int trash = serial.read(); }
      delay(10);
      serial.write(128);  // Ack the request
      isAcked = true;
      numIncoming = data & 127;
      numReceived = 0;
      if(numIncoming == 0){
        isAcked = false;
      }
    }
    else{
      if(isAcked){
        // data is actual data
        tmpInput[numReceived] = convert7B2CToInt(data);
        numReceived++;
        if(numReceived >= numIncoming){
          for(int i = 0; i < numReceived; i++){
            input[i] = tmpInput[i];
          }
          isAcked = false;
          numIncoming = 0;
          numReceived = 0;
          lastMessageReceivedTimer = millis();
        }
      }
    }
  }
}


// Converts a float from [-1.0,1.0] to 7-bit 2's compliment [-64,63]
int Comm::convertFloatTo7B2C(float input){
  int output = 0;
  if(input >= 0){
    output = (int)(input * 63);
  }
  else{
    output = (int)(input * 64);
  }
  if(output < -64){output = -64;}
  if(output >  63){output = 63;}
  
  if(output < 0){
    output += 128;
  }
  return output;
}

int Comm::convert7B2CToInt(int input){
  if(input < 64){
    return input;
  }
  else{
    return input - 128;
  }
}

bool Comm::IsFreshMessage(){
  return millis() - lastMessageReceivedTimer < 150;
}
