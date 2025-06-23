//+------------------------------------------------------------------+
//|                                                      BB_OsMA.mq5 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                              https://www.mql5.com/en/users/3rjfx |
//+------------------------------------------------------------------+
#property copyright "2016, MetaQuotes Software Corp. ~ By 3rjfx ~ Created: 2016/01/25"
#property link      "https://www.mql5.com/en/users/3rjfx"
#property version   "1.10"
//--
#property description "BB_OsMA indicator is the Forex indicators for MT5."
#property description "BB_OsMA indicator is the OsMA indicator in the form of spheroid,"
#property description "with a deviation as the upper and lower bands."
//--
#include <MovingAverages.mqh>
//--
#property indicator_separate_window
//--
#property indicator_buffers 11
#property indicator_plots   11
//--
#property indicator_type1   DRAW_NONE
//--
#property indicator_type2   DRAW_NONE
//--
#property indicator_type3   DRAW_NONE
//--
#property indicator_type4   DRAW_ARROW
#property indicator_style4  STYLE_SOLID 
#property indicator_width4  1
#property indicator_label4  "OsMAUps"
//--
#property indicator_type5   DRAW_ARROW
#property indicator_style5  STYLE_SOLID 
#property indicator_width5  1
#property indicator_label5  "OsMADown"
//--
#property indicator_type6   DRAW_LINE
#property indicator_style6  STYLE_SOLID 
#property indicator_width6  1
#property indicator_label6  "UpperBand"
//--
#property indicator_type7   DRAW_LINE
#property indicator_style7  STYLE_SOLID 
#property indicator_width7  1
#property indicator_label7  "LowerBand"
//--
#property indicator_type8   DRAW_NONE
//--
#property indicator_type9   DRAW_NONE
//--
#property indicator_type10   DRAW_NONE
//--
#property indicator_type11   DRAW_NONE
//--
//---
input int       OsMAFastEMA = 26;   // Fast EMA Period
input int       OsMASlowEMA = 130;  // Slow EMA Period
input int     OsMASignalEMA = 13;   // Signal SMA Period
input double         StdDev = 2.0;  // Standard Deviation
input color OsMAColorArrowUp = clrBlue;  // Arrow Up
input color OsMAColorArrowDn = clrRed;   // Arrow Down
input color OsMAColorLineUp  = clrBlue;  // Line Up
input color OsMAColorLineDn  = clrNONE;   // Line Down
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
//--- MA handles
int OsMAFast;
int OsMASlow;
//--
//----
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator property
//--
   SetIndexBuffer(0,OsMABuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(1,exOsMAMacd,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,exOsMASign,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,OsMABuffUp,INDICATOR_DATA);
   SetIndexBuffer(4,OsMABuffDn,INDICATOR_DATA);
   SetIndexBuffer(5,OsMAUpBand,INDICATOR_DATA);
   SetIndexBuffer(6,OsMALoBand,INDICATOR_DATA);
   SetIndexBuffer(7,OsMAStdDev,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,OsMAAvg,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,OsMAFastBuffers,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,OsMASlowBuffers,INDICATOR_CALCULATIONS);
//--- indicator drawing
   PlotIndexSetInteger(3,PLOT_ARROW,108);
   PlotIndexSetInteger(4,PLOT_ARROW,108);
//--
   PlotIndexSetInteger(3,PLOT_LINE_COLOR,OsMAColorArrowUp);
   PlotIndexSetInteger(4,PLOT_LINE_COLOR,OsMAColorArrowDn);
   PlotIndexSetInteger(5,PLOT_LINE_COLOR,OsMAColorLineUp);
   PlotIndexSetInteger(6,PLOT_LINE_COLOR,OsMAColorLineDn);
//--
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,OsAvgPeriod);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,OsAvgPeriod);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,OsAvgPeriod);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,OsAvgPeriod);
//--
   string shortname="BB_OsMA("+string(OsMAFastEMA)+","+string(OsMASlowEMA)+","+string(OsMASignalEMA)+")";
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--
//---
   OsMAFast=iMA(_Symbol,PERIOD_CURRENT,OsMAFastEMA,0,MODE_EMA,PRICE_WEIGHTED);
   if(OsMAFast==INVALID_HANDLE)
     {
      printf("Error creating indicator OsMAFastEMA for ",_Symbol);
      return(INIT_FAILED);
     }
//--
   OsMASlow=iMA(_Symbol,PERIOD_CURRENT,OsMASlowEMA,0,MODE_EMA,PRICE_WEIGHTED);
   if(OsMASlow==INVALID_HANDLE)
     {
      printf("Error creating indicator OsMASlowEMA for ",_Symbol);
      return(INIT_FAILED);
     }
//--
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
//----
//---   
   int x,xlimit;
   double OsMADiv=OsMASlowEMA/OsMAFastEMA;
//---
   if(rates_total<=OsMASignalEMA) return(0);
//--- Set Last error value to Zero
   ResetLastError();
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
//--
//--- last counted bar will be recounted
   if(prev_calculated==0)
      xlimit=0;
   else xlimit=prev_calculated-1;
//--- macd counted in the 1-st buffer
   for(x=calculated-1; x>=xlimit; x--)
     {exOsMAMacd[x]=OsMAFastBuffers[x]-OsMASlowBuffers[x];}
//--
//--- signal line counted in the 2-nd buffer
   ExponentialMAOnBuffer(rates_total,prev_calculated,0,OsMASignalEMA,exOsMAMacd,exOsMASign);
//---
//--- main loop
   for(x=calculated-1; x>=xlimit; x--)
     {OsMABuffer[x]=(exOsMAMacd[x]-exOsMASign[x])*OsMADiv;}
//--
   SimpleMAOnBuffer(rates_total,prev_calculated,0,OsAvgPeriod,OsMABuffer,OsMAAvg);
//--
   for(x=calculated-1; x>=xlimit; x--)
     {OsMAStdDev[x]=iStdDevOnArray(OsMABuffer,OsAvgPeriod,x);}
//-
//----
   for(x=calculated-1; x>xlimit; x--)
     {
      OsMAUpBand[x]=OsMAAvg[x]+(StdDev*OsMAStdDev[x]);
      OsMALoBand[x]=OsMAAvg[x]-(StdDev*OsMAStdDev[x]);
      OsMABuffUp[x]=OsMABuffer[x];  // OsMA Uptrend
      OsMABuffDn[x]=OsMABuffer[x];  // OsMA Downtrend
      //----
      if(OsMABuffer[x]>OsMABuffer[x-1])
         OsMABuffDn[x]=EMPTY_VALUE;
      //----
      if(OsMABuffer[x]<OsMABuffer[x-1])
         OsMABuffUp[x]=EMPTY_VALUE;
     }
//---- done
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//----
//+------------------------------------------------------------------+
//| Calculate Standard Deviation                                     |
//+------------------------------------------------------------------+
double iStdDevOnArray(const double &MAprice[],int period,int position)
  {
   double dTmp=0.0;
//--- save as_series flags
   bool as_series_buffer=ArrayGetAsSeries(MAprice);
   if(as_series_buffer) ArraySetAsSeries(MAprice,false);
   if(position<period) return(dTmp);
//--
   for(int i=0; i<period; i++) dTmp+=MathPow(MAprice[position-i]-MAprice[position],2);
   dTmp=MathSqrt(dTmp/period);
   if(as_series_buffer) ArraySetAsSeries(MAprice,true);
   return(dTmp);
  }
//+------------------------------------------------------------------+
