//+------------------------------------------------------------------+
//|                                                  Custom_MACD.mq5  |
//|                        Copyright 2025, Your Name                 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, Your Name"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   3

//--- Plot MACD Line
#property indicator_label1  "MACD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//--- Plot Signal Line
#property indicator_label2  "Signal"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- Plot Histogram
#property indicator_label3  "Histogram"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrLimeGreen
#property indicator_width3  2

//--- Input parameters
input int InpFastEMA   = 12;   // Fast EMA period
input int InpSlowEMA   = 26;   // Slow EMA period
input int InpSignalSMA = 9;    // Signal SMA period
input bool ShowAlerts  = true; // Show alerts for signals

//--- Indicator buffers
double MACDBuffer[];
double SignalBuffer[];
double HistogramBuffer[];
double FastEMABuffer[];
double SlowEMABuffer[];

//--- Global variables
int fast_ema_handle, slow_ema_handle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Assign buffers
   SetIndexBuffer(0, MACDBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, SignalBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, HistogramBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, FastEMABuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, SlowEMABuffer, INDICATOR_CALCULATIONS);

   //--- Set plot labels
   IndicatorSetString(INDICATOR_SHORTNAME, "Custom MACD (" + IntegerToString(InpFastEMA) + "," + 
                      IntegerToString(InpSlowEMA) + "," + IntegerToString(InpSignalSMA) + ")");
   
   //--- Create EMA handles
   fast_ema_handle = iMA(NULL, 0, InpFastEMA, 0, MODE_EMA, PRICE_CLOSE);
   slow_ema_handle = iMA(NULL, 0, InpSlowEMA, 0, MODE_EMA, PRICE_CLOSE);

   if(fast_ema_handle == INVALID_HANDLE || slow_ema_handle == INVALID_HANDLE)
   {
      Print("Failed to create EMA handles");
      return(INIT_FAILED);
   }

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(fast_ema_handle != INVALID_HANDLE) IndicatorRelease(fast_ema_handle);
   if(slow_ema_handle != INVALID_HANDLE) IndicatorRelease(slow_ema_handle);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                               |
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
   //--- Check for sufficient bars
   if(rates_total < InpSlowEMA + InpSignalSMA) return(0);

   //--- Copy EMA data
   if(CopyBuffer(fast_ema_handle, 0, 0, rates_total, FastEMABuffer) <= 0 ||
      CopyBuffer(slow_ema_handle, 0, 0, rates_total, SlowEMABuffer) <= 0)
   {
      Print("Failed to copy EMA data");
      return(0);
   }

   //--- Calculate MACD
   for(int i = 0; i < rates_total; i++)
   {
      MACDBuffer[i] = FastEMABuffer[i] - SlowEMABuffer[i];
   }

   //--- Calculate Signal Line
   for(int i = InpSignalSMA - 1; i < rates_total; i++)
   {
      double sum = 0.0;
      for(int j = 0; j < InpSignalSMA; j++)
         sum += MACDBuffer[i - j];
      SignalBuffer[i] = sum / InpSignalSMA;
   }

   //--- Calculate Histogram
   for(int i = 0; i < rates_total; i++)
   {
      HistogramBuffer[i] = MACDBuffer[i] - SignalBuffer[i];
   }

   //--- Generate alerts for crossovers
   if(ShowAlerts && prev_calculated > 0 && rates_total > InpSignalSMA)
   {
      for(int i = prev_calculated - 1; i < rates_total - 1; i++)
      {
         // Bullish crossover (MACD crosses above Signal)
         if(MACDBuffer[i] > SignalBuffer[i] && MACDBuffer[i - 1] <= SignalBuffer[i - 1])
         {
            Alert("MACD Bullish Crossover at bar ", i, ": Buy Signal");
         }
         // Bearish crossover (MACD crosses below Signal)
         if(MACDBuffer[i] < SignalBuffer[i] && MACDBuffer[i - 1] >= SignalBuffer[i - 1])
         {
            Alert("MACD Bearish Crossover at bar ", i, ": Sell Signal");
         }
      }
   }

   return(rates_total);
}
//+------------------------------------------------------------------+