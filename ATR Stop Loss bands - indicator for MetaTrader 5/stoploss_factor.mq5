//+------------------------------------------------------------------+
//|                                              stoploss_factor.mq5 |
//|                                       Copyright 2022, mr_schmidt |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, mr_schmidt."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers   4                             // How many data buffers are we using
#property indicator_plots     2                             // How many indicators are being drawn on screen

#property indicator_type1  DRAW_LINE
#property indicator_label1 "Stop Loss Upper"
#property indicator_color1 clrRed
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2

#property indicator_type2  DRAW_LINE
#property indicator_label2 "Stop Loss Lower"
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2

//--- input parameters
input    group          "Indicator Settings"
input    int            InpATRPeriod      =  14;            // ATR period
input    double         InpATRPercent     =  1.50;          // ATR factor
input    int            InpMAPeriod       =  1;             // MA period (keep at 1 for standard price action)
input    ENUM_MA_METHOD InpMAMethod       =  MODE_SMA;      // MA method (keep at SMA for standard price action)

//-- indicator buffers
double   BufferMA[];
double   BufferATR[];
double   BufferMAUpper[];
double   BufferMALower[];

int      MaxPeriod;

//--- indicator handles
int      HandleMA;
int      HandleATR;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, BufferMAUpper, INDICATOR_CALCULATIONS);
   SetIndexBuffer(1, BufferMALower, INDICATOR_CALCULATIONS);
   SetIndexBuffer(2, BufferMA, INDICATOR_DATA);
   SetIndexBuffer(3, BufferATR, INDICATOR_DATA);
   
   IndicatorSetInteger(INDICATOR_DIGITS, 2);
   IndicatorSetInteger(INDICATOR_LEVELS, 2);
   
   MaxPeriod         =  (int)MathMax(MathMax(InpATRPeriod, InpATRPercent), InpMAPeriod);

   HandleATR         =  iATR(Symbol(), PERIOD_CURRENT, InpATRPeriod);
   HandleMA          =  iMA(Symbol(), PERIOD_CURRENT, InpMAPeriod, 0, InpMAMethod, PRICE_OPEN);
   
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, MaxPeriod);
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
   if(IsStopped()) return 0;                                // Stop flag
   
   if(rates_total<MaxPeriod) return 0;                      // Check if enough bars are available to calculate
   
   //--- Check if all indicator has been calculated
   if(BarsCalculated(HandleATR) < rates_total)          
      return 0;
   if(BarsCalculated(HandleMA) < rates_total)           
      return 0;
   
   int copyBars = 0;
   if(prev_calculated>rates_total || prev_calculated<=0) {
      copyBars = rates_total;
   }
   else {
      copyBars = rates_total-prev_calculated;
      if(prev_calculated>0) copyBars++;
   }

   for(int i=1;i<rates_total;i++) {
      BufferMAUpper[i]=NormalizeDouble((BufferMA[i] + BufferATR[i]*InpATRPercent), _Digits);
      BufferMALower[i]=NormalizeDouble((BufferMA[i] - BufferATR[i]*InpATRPercent), _Digits);   
   }

   if(IsStopped()) return 0;
   if(CopyBuffer(HandleMA, 0, 0, copyBars, BufferMA) <= 0)  
      return 0;
   if(CopyBuffer(HandleATR, 0, 0, copyBars, BufferATR) <= 0)  
      return 0;  
    

   return(rates_total);
  }
//+------------------------------------------------------------------+
