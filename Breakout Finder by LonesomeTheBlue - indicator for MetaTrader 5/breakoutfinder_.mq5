//+------------------------------------------------------------------+
//|                                              BreakOutFinder.mq5  |
//|                                  Copyright 2025, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//|                                          Author: Yashar Seyyedin |
//|       Web Address: https://www.mql5.com/en/users/yashar.seyyedin |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot UpArrow
#property indicator_label1  "UpArrow"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DnArrow
#property indicator_label2  "DnArrow"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- indicator buffers
double         UpArrowBuffer[];
double         DnArrowBuffer[];


// Input Parameters
input int lookback= 3000; //Lookback bars
input int prd = 5; //Period
input int bo_len = 200; //Max Breakout Length
input double cwidthu = 3.; //Threshold Rate %
input int mintest = 2; //Minimum Number of Tests
input color bocolordown=clrRed;
input color bocolorup=clrBlue;

// Arrays to store pivot points and their locations
double phval [];
double phloc [];
double plval [];
double plloc [];
double _cwidthu;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,UpArrowBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,DnArrowBuffer,INDICATOR_DATA);

   ArraySetAsSeries(UpArrowBuffer,true);
   ArraySetAsSeries(DnArrowBuffer,true);

//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,233);
   PlotIndexSetInteger(1,PLOT_ARROW,234);

   _cwidthu=cwidthu/100;
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
   //Not available anymore
   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+