//+------------------------------------------------------------------+
//|                                                 DCC_Piercing.mq5 |
//|                                      Rajesh Nait, Copyright 2023 |
//|                  https://www.mql5.com/en/users/rajeshnait/seller |
//+------------------------------------------------------------------+
#property copyright "Rajesh Nait, Copyright 2023"
#property link      "https://www.mql5.com/en/users/rajeshnait/seller"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

//--- plot Bullish Marubozu
#property indicator_label1  "+DCCP"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrSnow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Bearish Marubozu
#property indicator_label2  "-DCCP"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrSnow
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1


//--- input parameters
input group             "Bearish"
input uchar               InpBullishDCCPCode              = 217;         // BullishDCCP: code for style DRAW_ARROW (font Wingdings)
input int                 InpBullishDCCPShift             = 10;          // BullishDCCP: vertical shift of arrows in pixels
input group             "Bullish"
input uchar               InpBearishDCCPCode              = 218;         // BearishDCCP: code for style DRAW_ARROW (font Wingdings)
input int                 InpBearishDCCPShift             =10;           // BearishDCCP: vertical shift of arrows in pixels
//--- indicator buffers
double   BullishDCCPBuffer[];
double   BearishDCCPBuffer[];
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
   min_rates_total=2;
//--- indicator buffers mapping
   SetIndexBuffer(0,BullishDCCPBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,BearishDCCPBuffer,INDICATOR_DATA);

   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);

   PlotIndexSetInteger(0,PLOT_ARROW,InpBullishDCCPCode);
   PlotIndexSetInteger(1,PLOT_ARROW,InpBearishDCCPCode);

   ArraySetAsSeries(BullishDCCPBuffer,true);
   ArraySetAsSeries(BearishDCCPBuffer,true);

//--- set the vertical shift of arrows in pixels
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,InpBullishDCCPShift);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-InpBearishDCCPShift);
//--- set as an empty value 0.0
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
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
   if(rates_total<min_rates_total)
      return(0);

   int limit;

   if(prev_calculated>rates_total || prev_calculated<=0) {
      limit=rates_total-min_rates_total;
   } else {
      limit=rates_total-prev_calculated;
   }
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---

   for(int i=limit; i>=0 && !IsStopped(); i--) {
      BullishDCCPBuffer[i]=0.0;
      BearishDCCPBuffer[i]=0.0;


      BearishDCCPBuffer[0]=0.0;
      if(open[i]>close[i] && open[i+1]<close[i+1] && open[i]>close[i+1])
         BearishDCCPBuffer[i]=high[i];

      BullishDCCPBuffer[0]=0.0;
      if(open[i]<close[i] && open[i+1]>close[i+1] && open[i]<close[i+1])
         BullishDCCPBuffer[i]=low[i];

   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
