//+------------------------------------------------------------------+
//|                                                      BB_OsMA.mq5 |
//|                                  Copyright 2016, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//|                              https://www.mql5.com/en/users/3rjfx |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2016, MetaQuotes Ltd. ~ By 3rjfx ~ Created: 2016/01/25"
#property link        "https://www.mql5.com"
#property link        "https://www.mql5.com/en/users/3rjfx"
#property version     "1.00"
//--
#property description "BB_OsMA indicator is the Forex indicators for MT5."
#property description "BB_OsMA indicator is the OsMA indicator in the form of spheroid,"
#property description "with a deviation as the upper and lower bands."
/*
The program has not been updated for too long and is no longer working properly.
Update: version "1.00" @ 2024/02/19
*/
//--
#include <MovingAverages.mqh>
//--
#property indicator_separate_window
//--
#property indicator_buffers 11
#property indicator_plots   4
//--
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrAqua
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  2
#property indicator_label1  "OsMAUps"
//--
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrYellow
#property indicator_style2  STYLE_SOLID 
#property indicator_width2  2
#property indicator_label2  "OsMADown"
//--
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDodgerBlue
#property indicator_style3  STYLE_SOLID 
#property indicator_width3  1
#property indicator_label3  "UpperBand"
//--
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID 
#property indicator_width4  1
#property indicator_label4  "LowerBand"
//--
#property indicator_type5   DRAW_NONE
#property indicator_type6   DRAW_NONE
#property indicator_type7   DRAW_NONE
//--
#property indicator_type8   DRAW_NONE
#property indicator_type9   DRAW_NONE
#property indicator_type10  DRAW_NONE
#property indicator_type11  DRAW_NONE
//--
//---
input ENUM_APPLIED_PRICE  eprice = PRICE_WEIGHTED;  // Select MA Applied price
input int            OsMAFastEMA = 12;              // Fast EMA Period
input int            OsMASlowEMA = 26;              // Slow EMA Period
input int          OsMASignalEMA = 9;               // Signal EMA Period
input double              StdDev = 2.0;             // Standard Deviation
//--
//--- buffers
double OsMABuffer[];
double exOsMAMacd[];
double exOsMASign[];
double OsMABuffUp[];
double OsMABuffDn[];
double OsMAUpBand[];
double OsMALoBand[];
double OsMAStdDev[];
double OsMAFastBuffers[];
double OsMASlowBuffers[];
double OsMAAvg[];
//--
int OsAvgPeriod=20;
int arrcode=159;
//--- MA handles
int OsMAFast;
int OsMASlow;
int hStdDev;
//--
//----
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator property
   //--
   SetIndexBuffer(0,OsMABuffUp,INDICATOR_DATA);
   SetIndexBuffer(1,OsMABuffDn,INDICATOR_DATA);
   SetIndexBuffer(2,OsMAUpBand,INDICATOR_DATA);
   SetIndexBuffer(3,OsMALoBand,INDICATOR_DATA);
   SetIndexBuffer(4,OsMABuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,exOsMAMacd,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,exOsMASign,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,OsMAStdDev,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,OsMAAvg,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,OsMAFastBuffers,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,OsMASlowBuffers,INDICATOR_CALCULATIONS);
   //--- indicator drawing
   PlotIndexSetInteger(0,PLOT_ARROW,arrcode);
   PlotIndexSetInteger(1,PLOT_ARROW,arrcode);
   //--
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,OsAvgPeriod);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,OsAvgPeriod);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,OsAvgPeriod);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,OsAvgPeriod);
   //--
   string shortname="BB_OsMA("+string(OsMAFastEMA)+","+string(OsMASlowEMA)+","+string(OsMASignalEMA)+")";
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   //--
   if(OsMAFastEMA>=OsMASlowEMA) return(INIT_FAILED);
   //---
   OsMAFast=iMA(Symbol(),PERIOD_CURRENT,OsMAFastEMA,0,MODE_EMA,eprice);
   if(OsMAFast==INVALID_HANDLE)
     {
       printf("Error creating indicator OsMAFastEMA for ",Symbol());
       return(INIT_FAILED);
     }
   //--
   OsMASlow=iMA(Symbol(),PERIOD_CURRENT,OsMASlowEMA,0,MODE_EMA,eprice);
   if(OsMASlow==INVALID_HANDLE)
     {
       printf("Error creating indicator OsMASlowEMA for ",Symbol());
       return(INIT_FAILED);
     }
   
   //--
   hStdDev=iStdDev(Symbol(),0,OsAvgPeriod,0,MODE_SMA,eprice);
   //---
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//---
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   //--
   ObjectsDeleteAll(ChartID(),0,-1);
   GlobalVariablesDeleteAll();
   //--
//----
   return;
  }
//----
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//--- Set Last error value to Zero
   ResetLastError();
   //--
//---  
   int x,xlimit;
   double OsMADiv=OsMASlowEMA/OsMAFastEMA;
//---
   if(rates_total<=OsMASignalEMA) return(0);
//--
//--- not all data may be calculated
   int calculated=BarsCalculated(OsMAFast);
   if(calculated<rates_total)
     {
      Print("Not all data of OsMAFast is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
//--
   calculated=BarsCalculated(OsMASlow);
   if(calculated<rates_total)
     {
      Print("Not all data of OsMASlow is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
//--
//--- we can copy not all data
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0)
     {
      to_copy=rates_total;
     }
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }
//--
//--- get OsMAFast buffers
   if(IsStopped()) return(0); //Checking for stop flag
   if(CopyBuffer(OsMAFast,0,0,to_copy,OsMAFastBuffers)<0)
     {
      Print("Getting ExtMaFastHandle buffers is failed! Error",GetLastError());
      return(0);
     }
//--- get OsMASlow buffer
   if(IsStopped()) return(0); //Checking for stop flag
   if(CopyBuffer(OsMASlow,0,0,to_copy,OsMASlowBuffers)<0)
     {
      Print("Getting ExtMaSlowHandle buffers is failed! Error",GetLastError());
      return(0);
     }
   if(CopyBuffer(hStdDev,0,0,to_copy,OsMAStdDev)<0)
     {
      Print("Getting OsMAStdDev buffers is failed! Error",GetLastError());
      return(0);
     }
//--
//--- last counted bar will be recounted
   if(prev_calculated==0)
      xlimit=0;
   else xlimit=prev_calculated-2;
//--- macd counted in the 1-st buffer
   for(x=calculated-1; x>=0; x--)
     {exOsMAMacd[x]=OsMAFastBuffers[x]-OsMASlowBuffers[x];}
//--
//--- signal line counted in the 2-nd buffer
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,OsMASignalEMA,exOsMAMacd,exOsMASign);
//---
//--- main loop
   for(x=calculated-1; x>=0; x--)
     {OsMABuffer[x]=(exOsMAMacd[x]-exOsMASign[x])*OsMADiv;}
//--
   SimpleMAOnBuffer(rates_total,prev_calculated,0,OsAvgPeriod,OsMABuffer,OsMAAvg);
//--
   ArraySetAsSeries(OsMAFastBuffers,true);
   ArraySetAsSeries(OsMASlowBuffers,true);
   ArraySetAsSeries(exOsMAMacd,true);
   ArraySetAsSeries(exOsMASign,true);
   ArraySetAsSeries(OsMAUpBand,true);
   ArraySetAsSeries(OsMALoBand,true);
   ArraySetAsSeries(OsMABuffUp,true);
   ArraySetAsSeries(OsMABuffDn,true);
   ArraySetAsSeries(OsMAAvg,true);
   ArraySetAsSeries(OsMABuffer,true);
   ArraySetAsSeries(OsMAStdDev,true);
//----
   for(x=calculated-2; x>=0; x--)
     {
      if(OsMABuffer[x]>OsMABuffer[x+1]) {OsMABuffUp[x]=OsMABuffer[x]; OsMABuffDn[x]=EMPTY_VALUE;}
      //----
      if(OsMABuffer[x]<OsMABuffer[x+1]) {OsMABuffDn[x]=OsMABuffer[x]; OsMABuffUp[x]=EMPTY_VALUE;}
      //----
      OsMAUpBand[x]=OsMAAvg[x]+(StdDev*OsMAStdDev[x]);
      OsMALoBand[x]=OsMAAvg[x]-(StdDev*OsMAStdDev[x]);
     }
   //--- done
//--- return value of prev_calculated for next call
   return(rates_total);
//---
  }
//---------//