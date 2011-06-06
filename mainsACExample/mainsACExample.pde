//----------------------------------------------------------------------------
// Mains AC Non Invasive 3
// Last revision 30 November 2009
// Licence: GNU GPL
// By Trystan Lea
//----------------------------------------------------------------------------

//----------------------------------------------------------------------------
// Load Energy Monitor library and create new instance
//----------------------------------------------------------------------------
#include "Emon.h"    //Load the library
EnergyMonitor emon;  //Create an instance

//----------------------------------------------------------------------------
// Setup
//----------------------------------------------------------------------------
void setup()
{  
  emon.setPins(4,3);                                 //Energy monitor analog pins
  emon.calibration( 1.116111611, 0.128401361, 2.3);  //Energy monitor calibration
  
  Serial.begin(9600);
}

//----------------------------------------------------------------------------
// Main loop
//----------------------------------------------------------------------------
void loop()
{

  emon.calc(20,2000);              //Energy Monitor calc function
  
  Serial.print(emon.realPower);    //Print energy monitor variables
  Serial.print(' ');
  Serial.print(emon.apparentPower);
  Serial.print(' ');
  Serial.print(emon.powerFactor);
  Serial.print(' ');
  Serial.print(emon.Vrms);
  Serial.print(' ');
  Serial.println(emon.Irms);
  
  delay(500);
}
//----------------------------------------------------------------------------


