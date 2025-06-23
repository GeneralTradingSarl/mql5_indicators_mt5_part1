//+------------------------------------------------------------------+
//|                                     Decision_Candles_Colored.mq5 |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Mohamed"
#property link      "https://www.mql5.com/en/code/50992"
#property version   "1.10"
#property strict
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   2

#property indicator_type1   DRAW_CANDLES
#property indicator_color1  clrBlue, clrAqua
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_type2   DRAW_CANDLES
#property indicator_color2  clrRed, clrDarkOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

input double dcpercent = 50;              // Decision Candle Body/range Percentage

double buff0[];
double buff1[];
double buff2[];
double buff3[];

double buff4[];
double buff5[];
double buff6[];
double buff7[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping

   IndicatorSetString(INDICATOR_SHORTNAME, "DCandles");

   SetIndexBuffer(0, buff0, INDICATOR_DATA);
   SetIndexBuffer(1, buff1, INDICATOR_DATA);
   SetIndexBuffer(2, buff2, INDICATOR_DATA);
   SetIndexBuffer(3, buff3, INDICATOR_DATA);

   SetIndexBuffer(4, buff4, INDICATOR_DATA);
   SetIndexBuffer(5, buff5, INDICATOR_DATA);
   SetIndexBuffer(6, buff6, INDICATOR_DATA);
   SetIndexBuffer(7, buff7, INDICATOR_DATA);

   for(int in = 0; in < 8; in++)PlotIndexSetInteger(in, PLOT_SHOW_DATA, false);

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
   int start = prev_calculated;

   if(start >= rates_total)start = rates_total - 1;
   if(start < 0)start = 0;

   for(int i = start; i < rates_total; i++)
     {
      buff0[i] = EMPTY_VALUE;
      buff1[i] = EMPTY_VALUE;
      buff2[i] = EMPTY_VALUE;
      buff3[i] = EMPTY_VALUE;
      buff4[i] = EMPTY_VALUE;
      buff5[i] = EMPTY_VALUE;
      buff6[i] = EMPTY_VALUE;
      buff7[i] = EMPTY_VALUE;

      bool DC = (high[i] - low[i]) * dcpercent / 100 <= fabs(close[i] - open[i]);
      bool up = DC && close[i] > open[i];
      bool dn = DC && close[i] < open[i];

      if(up)
        {
         buff0[i] = open[i];
         buff1[i] = high[i];
         buff2[i] = low[i];
         buff3[i] = close[i];
        }
      if(dn)
        {
         buff4[i] = open[i];
         buff5[i] = high[i];
         buff6[i] = low[i];
         buff7[i] = close[i];
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

