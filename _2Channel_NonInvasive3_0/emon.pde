//-----------------------------------------------------------------------------------------------
// Energy monitor functions
//-----------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------
// Variable declaration for emon_calc procedure
//--------------------------------------------------------------------------------------
 
//--------------------------------------------------------------------------------------
// emon_calc procedure
// Calculates realPower,apparentPower,powerFactor,Vrms,Irms,kwh increment
// From a sample window of the mains AC voltage and current.
// The Sample window length is defined by the number of wavelengths we choose to measure.
//--------------------------------------------------------------------------------------
void Channel::emon_calc(int inPinI, double ICAL)
{

  int crossCount = 0;                             //Used to measure number of times threshold is crossed.
  int numberOfSamples = 0;                        //This is now incremented  

  //-------------------------------------------------------------------------------------------------------------------------
  // 1) Waits for the waveform to be close to 'zero' (500 adc) part in sin curve.
  //-------------------------------------------------------------------------------------------------------------------------
  boolean st=false;                                  //an indicator to exit the while loop
  while(st==false)                                   //the while loop...
  {
     startV = analogRead(inPinV);                    //using the voltage waveform
     if ((startV < 550) && (startV > 440)) st=true;  //check its within range
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  // 2) Main measurment loop
  //------------------------------------------------------------------------------------------------------------------------- 
  unsigned long start = millis();                 //millis()-start makes sure it doesnt get stuck in the loop if there is an error.
  while ((crossCount < wavelengths) && ((millis()-start)<emon_timeout)) 
  {
    numberOfSamples++;                            //Count number of times looped.

    lastSampleV=sampleV;                          //Used for digital high pass filter
    lastSampleI=sampleI;                          //Used for digital high pass filter
    
    lastFilteredV = filteredV;                    //Used for offset removal
    lastFilteredI = filteredI;                    //Used for offset removal   
    
    //-----------------------------------------------------------------------------
    // A) Read in raw voltage and current samples
    //-----------------------------------------------------------------------------
    sampleV = analogRead(inPinV);                 //Read in raw voltage signal
    sampleI = analogRead(inPinI);                 //Read in raw current signal

    //-----------------------------------------------------------------------------
    // B) Apply digital high pass filters to remove 2.5V DC offset (centered on 0V).
    //-----------------------------------------------------------------------------
    filteredV = 0.996*(lastFilteredV+sampleV-lastSampleV);
    filteredI = 0.996*(lastFilteredI+sampleI-lastSampleI);
   
    //-----------------------------------------------------------------------------
    // C) Root-mean-square method voltage
    //-----------------------------------------------------------------------------  
    sqV= filteredV * filteredV;                 //1) square voltage values
    sumV += sqV;                                //2) sum
    
    //-----------------------------------------------------------------------------
    // D) Root-mean-square method current
    //-----------------------------------------------------------------------------   
    sqI = filteredI * filteredI;                //1) square current values
    sumI += sqI;                                //2) sum 
    
    //-----------------------------------------------------------------------------
    // E) Phase calibration
    //-----------------------------------------------------------------------------
    phaseShiftedV = lastFilteredV + PHASECAL * (filteredV - lastFilteredV); 
    
    //-----------------------------------------------------------------------------
    // F) Instantaneous power calc
    //-----------------------------------------------------------------------------   
    instP = phaseShiftedV * filteredI;          //Instantaneous Power
    sumP +=instP;                               //Sum  
    
    //-----------------------------------------------------------------------------
    // G) Find the number of times the voltage has crossed the initial voltage
    //    - every 2 crosses we will have sampled 1 wavelength 
    //    - so this method allows us to sample an integer number of wavelengths which increases accuracy
    //-----------------------------------------------------------------------------       
    lastVCross = checkVCross;                     
    if (sampleV > startV) checkVCross = true; 
                     else checkVCross = false;
    if (numberOfSamples==1) lastVCross = checkVCross;                  
                     
    if (lastVCross != checkVCross) crossCount++;
  }
  
  //-------------------------------------------------------------------------------------------------------------------------
  // 3) Post loop calculations
  //------------------------------------------------------------------------------------------------------------------------- 
  //Calculation of the root of the mean of the voltage and current squared (rms)
  //Calibration coeficients applied. 
  Vrms = VCAL * sqrt(sumV / numberOfSamples); 
  Irms = ICAL * sqrt(sumI / numberOfSamples); 

  //Calculation power values
  realPower = VCAL * ICAL * sumP / numberOfSamples;
  apparentPower = Vrms * Irms;
  powerFactor = realPower / apparentPower;

  //if (millis()-wtime>10000) {realPower = realPower + 100.0; wtime = millis();}
  //delay(1000);
  lwhtime = whtime;
  whtime = millis();
  whInc = realPower * ((whtime-lwhtime)/3600000.0);
  //temp

  //Reset accumulators
  sumV = 0;
  sumI = 0;
  sumP = 0;
}
//--------------------------------------------------------------------------------------       
       
       
       
