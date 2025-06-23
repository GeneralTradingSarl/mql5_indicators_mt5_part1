//+------------------------------------------------------------------+
//|                                              BearsBullsPower.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                              https://www.mql5.com/en/users/3rjfx |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link        "http://www.mql5.com"
#property link      "https://www.mql5.com/en/users/3rjfx"
#property version   "1.00"
#property indicator_separate_window
//--
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_label1 "BullsPower"
#property indicator_label2 "BearsPower"
//--- input parameters
input int    InpPeriod = 13; // Power Period
input color  BullsColor = clrAqua;    // Bulls Color
input color  BearsColor = clrYellow;  // Beasr Color
//--- indicator buffers
double    ExtBullsBuffer[];
double    ExtBearsBuffer[];
double    ExtBullBuffer1[];
double    ExtTempBuffer[];
//--- MA handle
int       ExtEmaHandle;
//---------//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtBullsBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtBearsBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtBullBuffer1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ExtTempBuffer,INDICATOR_CALCULATIONS);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpPeriod-1);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,InpPeriod-1);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,InpPeriod-1);
   //--
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,BullsColor);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,BearsColor);
   PlotIndexSetInteger(2,PLOT_LINE_COLOR,BullsColor);
//--- set accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- name for DataWindow and indicator subwindow label
   IndicatorSetString(INDICATOR_SHORTNAME,"BBPower("+(string)InpPeriod+")");
//--- get handle for MA
   ExtEmaHandle=iMA(NULL,0,InpPeriod,0,MODE_EMA,PRICE_CLOSE);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   int i,limit;
//--- check for bars count
   if(rates_total<InpPeriod)
      return(0);// not enough bars for calculation   
//--- not all data may be calculated
   int calculated=BarsCalculated(ExtEmaHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ExtEmaHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
//--- we can copy not all data
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }
//---- get ma buffers
   if(IsStopped()) return(0); //Checking for stop flag
   if(CopyBuffer(ExtEmaHandle,0,0,to_copy,ExtTempBuffer)<=0)
     {
      Print("getting ExtEmaHandle is failed! Error",GetLastError());
      return(0);
     }
//--- first calculation or number of bars was changed
   if(prev_calculated<InpPeriod)
      limit=InpPeriod;
   else limit=prev_calculated-1;
//--- the main loop of calculations
   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      ExtBullsBuffer[i]=high[i]-ExtTempBuffer[i];
      ExtBearsBuffer[i]=low[i]-ExtTempBuffer[i];
      if(ExtBullsBuffer[i]<0.0) ExtBullBuffer1[i]=ExtBullsBuffer[i];
      else ExtBullBuffer1[i]=EMPTY_VALUE;
     }
   //--
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
