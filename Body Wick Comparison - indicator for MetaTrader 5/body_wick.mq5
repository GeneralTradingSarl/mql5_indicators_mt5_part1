//+------------------------------------------------------------------+
//|                                                     BodyWick.mq5 |
//|                                      Rajesh Nait, Copyright 2023 |
//|                  https://www.mql5.com/en/users/rajeshnait/seller |
//+------------------------------------------------------------------+
#property copyright "Rajesh Nait, Copyright 2023"
#property link      "https://www.mql5.com/en/users/rajeshnait/seller"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

//--- plot Bullish BodyWick
#property indicator_label1  "+BW"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrSnow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Bearish BodyWick
#property indicator_label2  "-BW"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrSnow
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- input parameters
input group             "Bullish BodyWick"
sinput uchar               InpBullishBodyWickCode       = 167;         // Bullish BodyWick: code for style DRAW_ARROW (font Wingdings)
input int                 InpBullishBodyWickShift             = 0;          // Bullish BodyWick: vertical shift of arrows in pixels
input group             "Bearish BodyWick"
sinput uchar               InpBearishBodyWickCode       = 167;         // Bearish BodyWick: code for style DRAW_ARROW (font Wingdings)
input int                 InpBearishBodyWickShift             = 0;          // Bearish BodyWick: vertical shift of arrows in pixels
//--- indicator buffers
double   BullishBodyWickBuffer[];
double   BearishBodyWickBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping
//--- indicator buffers mapping
   SetIndexBuffer(0,BullishBodyWickBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,BearishBodyWickBuffer,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,InpBullishBodyWickCode);
   PlotIndexSetInteger(1,PLOT_ARROW,InpBearishBodyWickCode);
//--- set the vertical shift of arrows in pixels
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,InpBullishBodyWickShift);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-InpBearishBodyWickShift);
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
   if(rates_total<3)
      return(0);
//---
   int limit=prev_calculated-1;
   if(prev_calculated==0) {
      limit=1;
      BullishBodyWickBuffer[0]=0.0;
      BearishBodyWickBuffer[0]=0.0;
   }
   for(int i=limit; i<rates_total; i++) {
      BullishBodyWickBuffer[i]=0.0;
      BearishBodyWickBuffer[i]=0.0;
      if(i>0) {


         if(open[i]>close[i]) { //bear
            if((open[i]-close[i]<close[i]-low[i]) || (open[i]-close[i]<high[i]-open[i]))
               BearishBodyWickBuffer[i]=high[i];
         }

         else { //bull
            if((close[i]-open[i]<open[i]-low[i]) || (close[i]-open[i]<high[i]-close[i]))
               BullishBodyWickBuffer[i]=low[i];

         }


      }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
