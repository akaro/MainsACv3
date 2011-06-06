//--------------------------------------------------------------------------------------
// Mains AC Non-Invasive Energy Monitor (2 channel) 
// Last revision 27th Oct 2010
// Licence: GNU GPL
// By Trystan Lea (updated to support two channel energy monitoring by Glyn Hudson)
//--------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------
// VARIABLE DECLERATION
//--------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------
// EMON
//--------------------------------------------------------------------------------------

int wavelengths = 50;                             //number of wavelengths to sample
int inPinV = 1;                                   //Analog input pin number that voltage signal is connected to
int inPinI_1 = 0;                                 //Analog input pin number that current signal is connected to. Channel 1
int inPinI_2 = 2;                                 //Analog input pin number that current signal is connected to. Channel 2 


//channel 1
double VCAL = 1.0537291954;                    //Voltage calibration scaler
double ICAL_1 = 0.149154781772;                //Current calibration scaler
double ICAL_2 = 0.15124516206064;

double PHASECAL = 2.3;                         //Shifts voltage relative to current, 
                                              //subtracting any phase shifting caused by components
    
int emon_timeout = 2000;                       //how long to wait ms if something goes wrong.


class Channel
{
  public:
    void emon_calc(int,double);                //create pulse function 
    double realPower,                          //Output variables
       apparentPower,
       powerFactor,
       Vrms,
       Irms, 
       whInc, 
       wh;

  private: // Variable declaration for emon_calc procedure
   int lastSampleV,sampleV;                          //sample_ holds the raw analog read value, lastSample_ holds the last sample_
    int lastSampleI,sampleI;                      

    double lastFilteredV,filteredV;                   //Filtered_ is the raw analog value minus the DC offset
    double lastFilteredI, filteredI;                  
    
    double phaseShiftedV;                             //Holds the calibrated phase shifted voltage.
    
    double sqV,sumV,sqI,sumI,instP,sumP;              //sq = squared, sum = Sum, inst = instantaneous
    
    int startV;                                       //Instantaneous voltage at start of sample window.
    
    boolean lastVCross, checkVCross;                  //Used to measure number of times threshold is crossed.
    int crossCount;                                   // ''
    
    unsigned long lwhtime, whtime;                    //used to calculate energy used.

};

Channel ch1,ch2;    //create two incidence of class channel for the two channels

//--------------------------------------------------------------------------------------
// SETUP
//--------------------------------------------------------------------------------------
void setup()
{
   Serial.begin(9600); 

}
unsigned long wtime;

//--------------------------------------------------------------------------------------
// MAIN LOOP
//--------------------------------------------------------------------------------------
void loop()
{ 
  //-------------------------------------------------------------------------------------------
  // 1) Calculate energy monitor values
  //-------------------------------------------------------------------------------------------
  ch1.emon_calc(inPinI_1,ICAL_1);                                       //Energy Monitor calc function for channel 1, pass Arduino analog in pin nummber and calibration coefficient 
  ch2.emon_calc(inPinI_2,ICAL_2);                                       //Energy Monitor calc function, for channel 2, pass Arduino analog in pin nummber and calibration coefficient
  
  //delay(2000);
  Serial.print("Channel 1 Real Power: "); Serial.println(ch1.realPower);
  Serial.println("");
  Serial.print("Channel 2 Real Power: "); Serial.println(ch2.realPower);
  
  ch1.wh = ch1.wh + ch1.whInc;                                          //Accumulate wh for channel 1 until ethernet send
  ch2.wh = ch2.wh + ch2.whInc;                                          //Accumulate wh for channel 2 until ethernet send
  
}
