//+------------------------------------------------------------------+
//|                            Bollinger Bands with Post Smoothing   |
//|                                                          phade   |
//|                                                fxcalculator.io   |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "phade"
#property link      "fxcalculator.io"
#property description "Bollinger Bands with optional outer band smoothing"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   3

// Plot properties for the Bollinger Bands
#property indicator_label1  "Bands upper"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSilver
#property indicator_width1  2

#property indicator_label2  "Bands lower"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrSilver
#property indicator_width2  2

#property indicator_label3  "Bands middle"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBisque

#include <MovingAverages.mqh>

// Input parameters
input int BB_Period = 20; // BB Period
input double BB_Deviation = 2.0; // Standard deviation multiplier
input ENUM_MA_METHOD ma_method = MODE_SMA; // MA type
input int MA_Period_1 = 14; // Upper band MA smoothing period
input int MA_Period_2 = 14; // Lower band MA smoothing period

// Indicator buffers
double BBUpperBuffer[];
double BBLowerBuffer[];
double BBMainBuffer[];
double BBCalcBuffer[];
double ma_buf_a[];
double ma_buf_b[];
double upperband_pre[];
double lowerband_pre[];

// Moving Average handles
int handle;
int handle_2;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, BBUpperBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, BBLowerBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, BBMainBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, BBCalcBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, upperband_pre, INDICATOR_CALCULATIONS);
   SetIndexBuffer(5, lowerband_pre, INDICATOR_CALCULATIONS);
     
   handle = iMA(NULL, 0, BB_Period, 0, ma_method, PRICE_CLOSE);
   handle_2 = iMA(NULL, 0, BB_Period, 0, ma_method, PRICE_CLOSE);

   IndicatorSetString(INDICATOR_SHORTNAME, "Bollinger Bands with post smoothing");

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   IndicatorRelease(handle);
   IndicatorRelease(handle_2);
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
   if(rates_total < BB_Period)
      return 0;

   int calculated = BarsCalculated(handle);
   if(calculated < rates_total)
   {
      Print("Not all data of handle is calculated (", calculated, " bars). Error ", GetLastError());
      return 0;
   }

   calculated = BarsCalculated(handle_2);
   if(calculated < rates_total)
   {
      Print("Not all data of handle_2 is calculated (", calculated, " bars). Error ", GetLastError());
      return 0;
   }

   int to_copy = (prev_calculated > rates_total || prev_calculated < 0) ? rates_total : rates_total - prev_calculated;
   if(prev_calculated > 0)
      to_copy++;

   if(IsStopped()) return 0;
   if(CopyBuffer(handle, 0, 0, to_copy, BBMainBuffer) <= 0)
   {
      Print("Getting main MA failed! Error ", GetLastError());
      return 0;
   }

   if(IsStopped()) return 0;
   if(CopyBuffer(handle_2, 0, 0, to_copy, BBCalcBuffer) <= 0)
   {
      Print("Getting calculation MA failed! Error ", GetLastError());
      return 0;
   }

   int limit = (prev_calculated == 0) ? 0 : prev_calculated - 1;

   for(int i = limit; i < rates_total && !IsStopped(); i++)
   {
      double stdDev = iDeviation(close, BBCalcBuffer, BB_Period, i);
      upperband_pre[i] = BBMainBuffer[i] + BB_Deviation * stdDev;
      lowerband_pre[i] = BBMainBuffer[i] - BB_Deviation * stdDev;
   }

   SimpleMAOnBuffer(rates_total, prev_calculated, BB_Period, MA_Period_1, upperband_pre, BBUpperBuffer);
   SimpleMAOnBuffer(rates_total, prev_calculated, BB_Period, MA_Period_2, lowerband_pre, BBLowerBuffer);   

   return rates_total;
}

//+------------------------------------------------------------------+
//| Function to calculate standard deviation                         |
//+------------------------------------------------------------------+
double iDeviation(const double &price[], const double &ma_price[], int period, int pos)
{
   double dSum = 0;

   for(int i = 0; i < period && pos >= 0; i++)
   {
      int index = pos - i;

      if(index >= 0 && index < ArraySize(price) && index < ArraySize(ma_price))
         dSum += MathPow(price[index] - ma_price[pos], 2);
   }

   return MathSqrt(dSum / period);
}
