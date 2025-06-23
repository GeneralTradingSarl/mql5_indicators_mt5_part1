//+------------------------------------------------------------------+
//|                                              SF_MA_Cross_RSI.mq5 |
//|                                     Copyright 2023, MetaQuotes Ltd. |
//|                                            https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"

// For the RSI in separate window
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_label1  "RSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrLimeGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- input parameters
input int InpFastMAPeriod = 7;
input int InpSlowMAPeriod = 21;
input int InpRSIPeriod = 14;
input ENUM_APPLIED_PRICE InpPriceType = PRICE_CLOSE;

//--- indicator buffers (only RSI needs buffer for the separate window)
double rsi_Buffer[];

//--- handles for all indicators
int ma_Handle;      // Fast MA (on chart)
int sma_Handle;     // Slow MA (on chart)
int rsi_Handle;     // RSI (in separate window)

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- Create MA indicators that will be shown on the chart
   ma_Handle = iMA(_Symbol, _Period, InpFastMAPeriod, 0, MODE_EMA, InpPriceType);
   sma_Handle = iMA(_Symbol, _Period, InpSlowMAPeriod, 0, MODE_EMA, InpPriceType);
   
   //--- Set up the RSI buffer for the separate window
   SetIndexBuffer(0, rsi_Buffer, INDICATOR_DATA);
   PlotIndexSetString(0, PLOT_LABEL, "RSI (" + string(InpRSIPeriod) + ")");
   
   //--- Create RSI indicator
   rsi_Handle = iRSI(_Symbol, _Period, InpRSIPeriod, InpPriceType);

   //--- Check if all handles are valid
   if(ma_Handle == INVALID_HANDLE || sma_Handle == INVALID_HANDLE || rsi_Handle == INVALID_HANDLE)
   {
      Alert("Error creating indicator handles - error: ", GetLastError());
      return(INIT_FAILED);
   }
   
   //--- Add MAs to the chart window (not the indicator window)
   ChartIndicatorAdd(0, 0, ma_Handle);
   ChartIndicatorAdd(0, 0, sma_Handle);
   
   //--- Set RSI display properties
   IndicatorSetInteger(INDICATOR_DIGITS, 2);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   
   //--- Set the RSI levels (30 and 70 are standard for RSI)
   IndicatorSetInteger(INDICATOR_LEVELS, 2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, 30.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 1, 70.0);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR, 0, clrSilver);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR, 1, clrSilver);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE, 0, STYLE_DOT);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE, 1, STYLE_DOT);

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
   //--- Check if all handles are valid
   if(ma_Handle == INVALID_HANDLE || sma_Handle == INVALID_HANDLE || rsi_Handle == INVALID_HANDLE)
      return(0);

   //--- Get the number of available data
   int to_copy;
   if(prev_calculated > rates_total || prev_calculated <= 0)
      to_copy = rates_total;
   else
      to_copy = rates_total - prev_calculated + 1;

   //--- We only need to copy RSI values to our buffer (MAs are handled automatically)
   if(CopyBuffer(rsi_Handle, 0, 0, to_copy, rsi_Buffer) <= 0) return(0);

   //--- For debugging, print occasionally (not every tick)
   static int last_print = 0;
   if(TimeCurrent() - last_print > 60) // Print once per minute
   {
      double ma_val[1], sma_val[1], rsi_val[1];
      CopyBuffer(ma_Handle, 0, 0, 1, ma_val);
      CopyBuffer(sma_Handle, 0, 0, 1, sma_val);
      Print("Fast MA(", InpFastMAPeriod, ") = ", ma_val[0], 
            " | Slow MA(", InpSlowMAPeriod, ") = ", sma_val[0],
            " | RSI(", InpRSIPeriod, ") = ", rsi_Buffer[0]);
      last_print = TimeCurrent();
   }

   return(rates_total);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //--- Release indicator handles
   if(ma_Handle != INVALID_HANDLE) IndicatorRelease(ma_Handle);
   if(sma_Handle != INVALID_HANDLE) IndicatorRelease(sma_Handle);
   if(rsi_Handle != INVALID_HANDLE) IndicatorRelease(rsi_Handle);
   
   //--- Remove indicators from chart
   ChartIndicatorDelete(0, 0, "Moving Average (" + string(InpFastMAPeriod) + ")");
   ChartIndicatorDelete(0, 0, "Moving Average (" + string(InpSlowMAPeriod) + ")");
}
//+------------------------------------------------------------------+