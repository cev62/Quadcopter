#ifndef COMM_H
#define COMM_H

#include <SoftwareSerial.h>
#include "Arduino.h"


class Comm{
private:
  int numIncoming, numReceived;
  bool isAcked, isOutgoingAcked, isOutgoingRequested;
  int *tmpInput, *input;
  float *pseudoGyro;
  long int serialSendTimer;
  
  int convertFloatTo7B2C(float input);
  int convert7B2CToInt(int input);
  
public:
  Comm();
  void Update();
};

#endif
