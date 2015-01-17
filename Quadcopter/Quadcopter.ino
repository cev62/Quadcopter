#include "comm.h"

Comm *comm;

void setup(){
  comm = new Comm();
}

void loop(){
  comm->Update();
  delay(5);
}


