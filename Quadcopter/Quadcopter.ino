int numIncoming, numReceived;
bool isAcked;
int *tmpInput, *input;

int ledDelay = 0;
long int ledTimer = 0;
int ledState = LOW;

void setup(){
  Serial.begin(9600);
  Serial.println("H");
  isAcked = false;
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
}

void loop(){
  if(millis() - ledTimer > input[0] + input[1] + input[2] + input[3]){
    if(ledState == HIGH) { ledState = LOW; }
    else { ledState = HIGH; }
    digitalWrite(13, ledState);
    ledTimer = millis();
  }
  while(Serial.available() > 0){
    int data = Serial.read();
    delay(10);
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
    if(data & 128){
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
  }
}

int convert7B2CToInt(int input){
  if(input < 64){
    return input;
  }
  else{
    return input - 128;
  }
}
