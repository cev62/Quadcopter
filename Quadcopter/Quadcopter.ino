#include <SoftwareSerial.h>
#include "comm.h"


Comm *comm;

void setup(){
  comm = new Comm();
  pinMode(5, OUTPUT);
  digitalWrite(5, HIGH); // bluetooth VIN
  pinMode(4, OUTPUT);
  digitalWrite(4, LOW); // bluetooth GND
}

void loop(){
  comm->UpdateSS();
  if(!comm->IsFreshMessage()){
    //digitalWrite(13, LOW);
    //digitalWrite(13, HIGH);
  }
  else{
    //digitalWrite(13, LOW);
  }
  delay(5);
}


