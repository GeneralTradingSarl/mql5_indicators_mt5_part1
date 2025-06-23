//+-------------------------------------------------------------------------------------+
//|                                                       Minions.3RulesMACD_Signal.mq5 |
//| (CC) Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License|
//|                                                          http://www.MinionsLabs.com |
//+-------------------------------------------------------------------------------------+




//+------------------------------------------------------------------+
//| Descriptors                                                      |
//+------------------------------------------------------------------+
#property copyright   "www.MinionsLabs.com"
#property link        "http://www.MinionsLabs.com"
#property version     "1.0"
#property description "Minions in the quest for ideal MACD Crossovers using 3 rules"
#property description " (BUY and SELL signals indicator)"
#property description " "
#property description "(CC) Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License"



//+------------------------------------------------------------------+
//| Indicator Settings                                               |
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   2

#property indicator_label1  "BUY" 
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "SELL"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1




//+------------------------------------------------------------------+
//| Inputs from User Interface                                       |
//+------------------------------------------------------------------+
input int      inpMAFast=12;      //Fast MA Period
input int      inpMASlow=26;      //Slow MA Period
input int      inpSignal=9;       //Signal Line Period


//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
int      bufferBuy_ID=0;       // put names on buffers!
int      bufferSell_ID=1;      //
int      bufferMACD_ID=2;      //
int      bufferSignal_ID=3;    //

double   bufferBuy[];          // buffers for holding the data...
double   bufferSell[];         //
double   bufferMACD[];         //
double   bufferSignal[];       //

int      hiMACD;               // handle for the iMACD...

bool     ruleBuy1=false;       // holds the rule #1 cross for BUY
bool     ruleBuy2=false;       // holds the rule #2 cross for BUY
bool     ruleSell1=false;      // holds the rule #1 cross for SELL
bool     ruleSell2=false;      // holds the rule #2 cross for SELL



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   SetIndexBuffer(bufferBuy_ID,    bufferBuy,    INDICATOR_DATA);
   SetIndexBuffer(bufferSell_ID,   bufferSell,   INDICATOR_DATA);
   SetIndexBuffer(bufferMACD_ID,   bufferMACD,   INDICATOR_DATA);
   SetIndexBuffer(bufferSignal_ID, bufferSignal, INDICATOR_DATA);

   // prepare the arrows for the entry signals...
   PlotIndexSetInteger(bufferSell_ID,PLOT_ARROW,234);
   PlotIndexSetInteger(bufferBuy_ID,PLOT_ARROW,233);

   PlotIndexSetInteger(bufferSell_ID,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(bufferBuy_ID,PLOT_ARROW_SHIFT,10);

   // create the signals... gets the handles for the indicators...
   hiMACD = iMACD( _Symbol, _Period, inpMAFast, inpMASlow, inpSignal, PRICE_CLOSE );

   if (hiMACD==INVALID_HANDLE) {
      // tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMACD for the symbol %s/%s, error code %d", _Symbol, EnumToString(_Period), GetLastError());
      return(INIT_FAILED);  //return as a failed operation...
   }

   return(INIT_SUCCEEDED);
}






//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,     // Total number of bars
                const int prev_calculated, // Previous calculated number of bars 
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])   {
   int i;
   int startFromWhere;

   if (prev_calculated==0) startFromWhere=1;    // First Time! Start from the start! 1 is because the calculations need to address i-1, otherwise it would be 0
   else startFromWhere = prev_calculated-1;     // set start equal to the last index in the arrays 


   // fill the iMACD array with values, but only the values NOT ALREADY processed...
   // if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation
   if (rates_total-prev_calculated > 0) {
      if (!FillArraysFromBuffers( bufferMACD, bufferSignal, hiMACD, (rates_total-prev_calculated))) {  return(0);   }
   }
   

   // processes the BUY and SELL signals
   for(i=startFromWhere; i<rates_total; i++)  {

      // start of the BUY signal - RULE #1...
      if ( (bufferMACD[i-1]>bufferSignal[i-1] && bufferMACD[i]<bufferSignal[i]) ) {  //MACD crosses below Signal 
         ruleBuy1=true; ruleBuy2=false; 
      }
      // RULE BUY #2...
      if ( (bufferMACD[i-1]>0 && bufferMACD[i]<0) && ruleBuy1) {  //MACD crosses below Zero Line
         ruleBuy2 = true;
      } 
      
      // start of the SELL signal - RULE #1...
      if ( (bufferMACD[i-1]<bufferSignal[i-1] && bufferMACD[i]>bufferSignal[i]) ) {  //MACD crosses above Signal 
         ruleSell1=true; ruleSell2=false; 
      }
      // RULE SELL #2...
      if ( (bufferMACD[i-1]<0 && bufferMACD[i]>0) && ruleSell1) {  //MACD crosses above Zero Line
         ruleSell2 = true;
      } 


      // Sets the BUY and SELL signal...
      if (bufferMACD[i-1]<bufferSignal[i-1] && bufferMACD[i]>bufferSignal[i] && ruleBuy1 && ruleBuy2) {
         bufferBuy[i]  = low[i];       //prints a BUY arrow, as if it is an "at Market order"
         bufferSell[i] = EMPTY_VALUE;  //do not print an arrow
         ruleBuy1 = ruleBuy2 = false;  //prepare to the next Buy signal
         
      } else if (bufferMACD[i-1]>bufferSignal[i-1] && bufferMACD[i]<bufferSignal[i] && ruleSell1 && ruleSell2) {
         bufferSell[i] = high[i];        //prints a SELL arrow, as if it is an "at Market order"
         bufferBuy[i]  = EMPTY_VALUE;    //do not print an arrow  
         ruleSell1 = ruleSell2 = false;  //prepare to the next Sell signal
         
      } else {
         bufferBuy[i]=bufferSell[i] = EMPTY_VALUE;  //do not print any arrow at all for the candle...
      }

   }


   // return the prev_calculated value for the next call
   return(rates_total);
}




//+------------------------------------------------------------------+
//| Filling indicator buffers from the iMACD indicator...            |
//+------------------------------------------------------------------+
bool FillArraysFromBuffers(double &bufMACD[],      // indicator buffer of MACD values
                           double &bufSignal[],    // indicator buffer of the Signal line of MACD 
                           int ind_handle,         // handle of the iMACD indicator
                           int amount              // number of copied values
                           )
  {

   ResetLastError();
   // fill a part of the iMACDBuffer array with values from the indicator buffer that has 0 index
   if(CopyBuffer(ind_handle,0,0,amount,bufMACD)<0)
     {
      // if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iMACD indicator, error code %d",GetLastError());
      // quit with zero result - it means that the indicator is considered as not calculated
      return(false);
     }
 
   // fill a part of the Signal Buffer array with values from the indicator buffer that has index 1
   if(CopyBuffer(ind_handle,1,0,amount,bufSignal)<0)
     {
      // if the copying fails, tell the error code
      PrintFormat("Failed to copy data from the iMACD indicator, error code %d",GetLastError());
      // quit with zero result - it means that the indicator is considered as not calculated
      return(false);
     }

   return(true);
  }




//+------------------------------------------------------------------+
//| indicator exit... freeing memory...                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   IndicatorRelease(hiMACD);
}

//+------------------------------------------------------------------+