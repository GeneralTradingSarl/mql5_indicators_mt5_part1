//+------------------------------------------------------------------+
//|                                                 A BETTER RSI.mq5 |
//|                                    Copyright 2023, ZOE HIGHTOWER |
//|                                         zoeinhightower@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, ZOE HIGHTOWER"
#property link      "zoeinhightower@gmail.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots  1
#property indicator_type1 DRAW_LINE
#property indicator_label1 "A BETTER RSI"
#property indicator_color1 clrFuchsia
#property indicator_width1 3
#property indicator_level1 4
#property indicator_level2 -4
#property indicator_level3 1
#property indicator_level4 -1
#property indicator_level5 0
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
#include <MovingAverages.mqh>

input int Signal_period = 22; // Signal Period
input int ROC_period = 10; // Rate of Change Period

//--- indicator buffer
double Deriv[];
double RMS[];
double Clip[];
double Z3[];
double Signal[];
double ROC[];
double Z3MA[];
double SignalMA[];


int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ROC,INDICATOR_DATA);
   SetIndexBuffer(1,RMS,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,Clip,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,Z3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,Signal,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,Deriv,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,Z3MA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,SignalMA,INDICATOR_CALCULATIONS);
   
   ArraySetAsSeries(Z3MA,true);
   ArraySetAsSeries(SignalMA,true);
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//---
   for(int i = 3; i < rates_total; i++){
   
      Deriv[i] = 0.0;
      RMS[i] = 0.0;
      Clip[i] = 0.0;
      Z3[i] = 0.0;
      Signal[i] = 0.0;
      ROC[i] = 0.0;   
   
      // Derivative of the price wave
      Deriv[i] = price[i] - price[i-2];
       
      
      // Normalize Degap to half RMS and hard limit at +/- 1
     // for(int count = 0; count < rates_total; count ++){
         
         RMS[i] = RMS[i] + Deriv[i] * Deriv[i];
      
      //}
               
      if(RMS[i] != 0){
          Clip[i] = 2 * Deriv[i] / MathSqrt(RMS[i] / 50);
          }
      
      if(Clip[i] > 1){
          Clip[i] = 1;
          }
      if(Clip[i] < -1){
          Clip[i] = -1;
          }
      
      // Zeros at Nyquist and 2*Nyquist, i.e. Z3 = (1 + Z^-1)*(1 + Z^-2) to integrate derivative
      Z3[i] = Clip[i] + Clip[i-1] + Clip[i-2] + Clip[i-3];
      
      //--- Z3 MA calculation   
      Z3MA[i] = SimpleMA(i,ROC_period,Z3);
      // Smooth Z3 for trading signal
      Signal[i] = Z3MA[i];
      
      //--- Signal MA calculation
      SignalMA[i] = SimpleMA(i,Signal_period,Signal);
      // Use Rate of Change to identify entry point
     ROC[i] = Signal[i] - SignalMA[i];


  
   }


   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
