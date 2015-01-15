int numIncoming, numReceived;
bool isAcked, isOutgoingAcked, isOutgoingRequested;
int *tmpInput, *input;
float *pseudoGyro;

int ledDelay = 0;
long int ledTimer = 0;
long int serialSendTimer = 0;
int ledState = LOW;

void setup(){
  Serial.begin(9600);
  Serial.println("H");
  isAcked = false;
  isOutgoingAcked = false;
  isOutgoingRequested = false;
  numIncoming = 0;
  numReceived = 0;
  pinMode(13, OUTPUT);
  digitalWrite(13, ledState);
  input = new int[4];
  input[0] = 0;
  input[1] = 0;
  input[2] = 0;
  input[3] = 0;
  tmpInput = new int[4];
  pseudoGyro = new float[4];
  pseudoGyro[0] = 0.0;
  pseudoGyro[1] = 0.1;
  pseudoGyro[2] = 0.2;
  pseudoGyro[3] = 0.3;
}

void loop(){
  if(millis() - ledTimer > input[0] + input[1] + input[2] + input[3]){
    if(ledState == HIGH) { ledState = LOW; }
    else { ledState = HIGH; }
    digitalWrite(13, ledState);
    ledTimer = millis();
  }
  
  if(millis() - serialSendTimer > 50){
   
    for(int i = 0; i < 4; i++){
      //pseudoGyro[i] = 0.5 * (pseudoGyro[i] + map((float)input[i], -64.0, 63.0, -1.0, 1.0));
    }
    
    if(isOutgoingAcked){
      //for(int i = 0; i < 4; i++){
      //  Serial.write(convertFloatTo7B2C(pseudoGyro[i]));
      //}
      Serial.write(convertFloatTo7B2C(pseudoGyro[0]));
      Serial.write(convertFloatTo7B2C(pseudoGyro[1]));
      Serial.write(convertFloatTo7B2C(pseudoGyro[2]));
      Serial.write(convertFloatTo7B2C(pseudoGyro[3]));
      isOutgoingAcked = false;
    }
    else{
      Serial.write(128 + 4);
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
          
        }
      }
    }
  }
}

// Converts a float from [-1.0,1.0] to 7-bit 2's compliment [-64,63]
int convertFloatTo7B2C(float input){
  //int output = (int)map(input, -1.0, 1.0, -64.0, 63.0);
  int output = 0;
  if(input >= 0){
    output = (int)round(input * 63);
  }
  else{
    output = (int)round)(input * 64);
  }
  if(output < 0){
    output += 128;
  }
  return output;
}

int convert7B2CToInt(int input){
  if(input < 64){
    return input;
  }
  else{
    return input - 128;
  }
}
