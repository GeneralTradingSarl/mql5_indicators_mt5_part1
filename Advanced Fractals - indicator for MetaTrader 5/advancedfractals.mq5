//+------------------------------------------------------------------+
//|                                             AdvancedFractals.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright     "Copyright 2018, MetaQuotes Software Corp."
#property link          "https://mql5.com"
#property version       "1.00"
#property description   "Draws fractals of any dimension (Frames)"
#property description   "------------------------------------"
#property description   "If the Frames is less than one,"
#property description   "then one Frames will be used."
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot UpFactal
#property indicator_label1 "Factal Up"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DownFractal
#property indicator_label2  "Fractal Down"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input uint     Frames=2;   // Frames
//--- indicator buffers
double         BufferUpFactal[];
double         BufferDownFractal[];
//--- global variables
int            frames;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- settings parameters
   frames=int(Frames<1 ? 1 : Frames);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferUpFactal,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDownFractal,INDICATOR_DATA);
//--- setting a buffers parameters
   PlotIndexSetInteger(0,PLOT_ARROW,119);
   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,4);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetInteger(1,PLOT_ARROW,119);
   PlotIndexSetInteger(1,PLOT_LINE_WIDTH,4);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- strings parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Advanced fractals("+(string)frames+")");
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
//--- Checking for minimum number of bars
   if(rates_total<frames*2+2) return 0;
//---
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-frames-1;
      ArrayInitialize(BufferUpFactal,0.0);
      ArrayInitialize(BufferDownFractal,0.0);
     }
//--- Calculate indicator
   for(int i=limit; i>frames && !IsStopped(); i--)
     {
      bool FrUp=true;
      bool FrDn=true;
      for(int n=1; n<=frames; n++)
        {
         if(high[i+n]>=high[i] || high[i-n]>=high[i]) FrUp=false;
         if(low[i+n]<=low[i] || low[i-n]<=low[i]) FrDn=false;
        }
      //----Fractals up
      if(FrUp)
         BufferUpFactal[i]=high[i];
      //----Fractals down
      if(FrDn)
         BufferDownFractal[i]=low[i];
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
