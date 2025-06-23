//+------------------------------------------------------------------+
//|                                                Candle_ZigZag.mq5 |
//|                                Copyright 2024, Rajesh Kumar Nait |
//|                  https://www.mql5.com/en/users/rajeshnait/seller |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Rajesh Kumar Nait"
#property link      "https://www.mql5.com/en/users/rajeshnait/seller"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1

#property indicator_label1  "ZigZag Lowest;ZigZag Highest"
#property indicator_type1   DRAW_COLOR_ZIGZAG
#property indicator_color1  clrDeepPink,clrAliceBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

input int InpPeriod = 1;           // Candlestick period
input bool modeclose=false;         // Close Mode?

double LowestBuffer[],HighestBuffer[],ZigZagColors[];
int  minRates;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping
   minRates = InpPeriod;
   SetIndexBuffer(0, LowestBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, HighestBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, ZigZagColors, INDICATOR_COLOR_INDEX);

//---
   for ( int i = 0; i < 1; i++ ) {
      PlotIndexSetInteger(i, PLOT_DRAW_BEGIN, minRates);
      PlotIndexSetInteger(i, PLOT_SHIFT, 0);
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0.0);
   }
//---
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
//---
   IndicatorSetString(INDICATOR_SHORTNAME, "Candle ZigZag ("+(string)InpPeriod+")");
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
                const int &spread[]) {
//---

   int startBar;
   int lastHighPos, lastLowPos;
   static int _lastHighPos, _lastLowPos;
   double highValue, lowValue;
   static double _highValue, _lowValue;
   bool up;
   static bool _up;
//---
   if ( rates_total < minRates ) {
      Print("Not enough data to calculate");
      return(0);
   }
//---
   if ( prev_calculated > rates_total || prev_calculated <= 0 ) {
      startBar = minRates;

   } else {
      startBar = prev_calculated - 1;
   }
//---
   up = _up;
   highValue = _highValue;
   lowValue = _lowValue;
   lastHighPos = _lastHighPos;
   lastLowPos = _lastLowPos;

   for ( int bar = startBar; bar < rates_total && !IsStopped(); bar++ ) {

      //--- ZigZag 
      if ( rates_total != prev_calculated && bar == rates_total - 1 ) {
         _up = up;
         _highValue = highValue;
         _lowValue = lowValue;
         _lastHighPos = lastHighPos;
         _lastLowPos = lastLowPos;
      }
      //---
      if ( up ) {
         ZigZagColors[bar] = 1;
         if ( high[bar] > highValue && close[bar] > open[bar]) {
            HighestBuffer[lastHighPos] = 0.0;
            if(modeclose)
               HighestBuffer[bar] = highValue = close[bar];
            else
               HighestBuffer[bar] = highValue = high[bar];
            lastHighPos = bar;
            LowestBuffer[bar] = 0.0;
         } else if ( close[bar] < open[bar]  ) {
            up = false;
            if(modeclose)
               LowestBuffer[bar] = lowValue = close[bar];
            else
               LowestBuffer[bar] = lowValue = low[bar];
            lastLowPos = bar;
            HighestBuffer[bar] = 0.0;
            ZigZagColors[bar] = 0;
         } else {
            HighestBuffer[bar] = 0.0;
            LowestBuffer[bar] = 0.0;
         }
      } else {
         ZigZagColors[bar] = 0;
         if ( low[bar] < lowValue && close[bar] < open[bar]) {
            LowestBuffer[lastLowPos] = 0.0;
            if(modeclose)
               LowestBuffer[bar] = lowValue = close[bar];
            else
               LowestBuffer[bar] = lowValue = low[bar];
            lastLowPos = bar;
            HighestBuffer[bar] = 0.0;
         } else if ( close[bar] > open[bar] ) {
            up = true;
            if(modeclose)
               HighestBuffer[bar] = highValue = close[bar];
            else
               HighestBuffer[bar] = highValue = high[bar];
            lastHighPos = bar;
            LowestBuffer[bar] = 0.0;
            ZigZagColors[bar] = 1;
         } else {
            HighestBuffer[bar] = 0.0;
            LowestBuffer[bar] = 0.0;
         }
      }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
