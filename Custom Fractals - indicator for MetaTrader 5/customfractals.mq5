//+------------------------------------------------------------------+
//|                                               CustomFractals.mq5 |
//|                           Copyright 2021, Tobias Johannes Zimmer |
//|                                 https://www.mql5.com/pennyhunter |
//+------------------------------------------------------------------+
#property copyright "2009-2020, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_ARROW
#property indicator_type2   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_color2  clrBlue
#property indicator_label1  "Fractal Up"
#property indicator_label2  "Fractal Down"
//--- indicator buffers
double ExtUpperBuffer[];
double ExtLowerBuffer[];
//--- 10 pixels upper from high price
int    ExtArrowShift = -10;
//---
int ExtWingding01 = 217;
int ExtWingding02 = 218;
//--- input
input int how_many = 2; //bars left and right
input int how_far_away = -10;
input int sign_size = 3;
input int wingding_num1 = 217;
input int wingding_num2 = 218;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit() {
//--- indicator buffers mapping
   SetIndexBuffer(0, ExtUpperBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, ExtLowerBuffer, INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

//---check if the characters are within wingdings characters
   if(wingding_num1 < 0 || wingding_num1 > 255) {
      ExtWingding01 = 217;
      Print("unicode character must be within 255+0");
   } else ExtWingding01 = wingding_num1;
   if(wingding_num2 < 0 || wingding_num2 > 255) {
      ExtWingding02 = 218;
      Print("unicode character must be within 255+0");
   } else ExtWingding02 = wingding_num2;
//--- sets arrow form from microsoft wingdings that will be drawn
   PlotIndexSetInteger(0, PLOT_ARROW, wingding_num1);
   PlotIndexSetInteger(1, PLOT_ARROW, wingding_num2);

//--- arrow shifts when drawing
   ExtArrowShift = how_far_away;
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, ExtArrowShift);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, -ExtArrowShift);
//--- sets drawing line empty value--
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
//--- sets sign size
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, sign_size);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, sign_size);

}
//+------------------------------------------------------------------+
//|  OnCalculate function                                            |
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
                
//if there are not enough bars
   if(rates_total < ((how_many * 2) + 1))
      return(0);

//--- preliminary settings
   int start;
   if(prev_calculated < ((how_many * 2) + 3)) {
      start = how_many;
   } else
      start = rates_total - ((how_many * 2) + 1);

//--- clean up arrays
   ArrayInitialize(ExtUpperBuffer, EMPTY_VALUE);
   ArrayInitialize(ExtLowerBuffer, EMPTY_VALUE);
//--- main cycle of calculations

//--- Upper Fractal
   for(int i = start; i < rates_total - (how_many + 1) && !IsStopped(); i++) {
      bool IsFractalUp = true;
      for(int j = 1; j <= how_many && IsFractalUp == true; j++) {
         IsFractalUp &= (high[i] > high[i + j]);
         IsFractalUp &= (high[i] > high[i - j]);
      }
      if(IsFractalUp) ExtUpperBuffer[i] = high[i];
      else
         ExtUpperBuffer[i] = EMPTY_VALUE;
   }
//--- Lower Fractal
   for(int i = start; i < rates_total - (how_many + 1) && !IsStopped(); i++) {
      bool IsFractalDn = true;
      for(int j = 1; j <= how_many && IsFractalDn == true; j++) {
         IsFractalDn &= (low[i] < low[i + j]);
         IsFractalDn &= (low[i] < low[i - j]);
      }
      if(IsFractalDn) ExtLowerBuffer[i] = low[i];
      else
         ExtLowerBuffer[i] = EMPTY_VALUE;
   }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
