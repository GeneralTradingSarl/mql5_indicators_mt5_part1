//+------------------------------------------------------------------+
//|                                                 ATR Channels.mq5 |
//|                                           Copyright 2025, matfx. |
//|                           https://theregulartrader.blogspot.com/ |
//|         Converted the ATR Channel from ATR Channel indicator mql4|
//|                      Original version from Luis Guilherme Damiani|
//+------------------------------------------------------------------+

#property copyright "Copyright 2025, matfx."
#property link      "https://theregulartrader.blogspot.com"
#property version   "1.00"
#property description "ATR Channels"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   7
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlueViolet
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRoyalBlue
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDeepSkyBlue
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrAqua
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrDeepSkyBlue
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrRoyalBlue
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrBlueViolet


//--- labels
#property indicator_label1  "Upper Band3"
#property indicator_label2  "Upper Band2"
#property indicator_label3  "Upper Band1"
#property indicator_label4  "Middle Band"
#property indicator_label5  "Lower Band1"
#property indicator_label6  "Lower Band2"
#property indicator_label7  "Lower Band3"

//--- input parameters
input int    InpSMAPeriod   =49;    // Period of SMA
input int    InpATRPeriod   =18;    // Period of ATR
input double InpATRFactor1  =1.6;   // ATR multiplier1
input double InpATRFactor2  = 3.2;  // ATR multiplier2
input double InpATRFactor3  = 4.8;  // ATR multiplier3



//--- global variables for parameters
int    ExtSMAPeriod;
int    ExtATRPeriod;
double ExtATRFactor1;
double ExtATRFactor2;
double ExtATRFactor3;

//--- indicator buffers
double ExtUpp3Buffer[];
double ExtUpp2Buffer[];
double ExtUpp1Buffer[];
double ExtSMABuffer[];
double ExtDwn1Buffer[];
double ExtDwn2Buffer[];
double ExtDwn3Buffer[];

//--- indicator handles
int    ExtSMAHandle;
int    ExtATRHandle;

//--- unique prefix to identify indicator objects
string ExtPrefixUniq;
int    ExtPeriod;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- check for input values
   if(InpSMAPeriod<10)
     {
      ExtSMAPeriod=20;
      PrintFormat("Incorrect value for input variable InpEMAPeriod=%d. Indicator will use value=%d for calculations.",
                  InpSMAPeriod, ExtSMAPeriod);
     }
   else
      ExtSMAPeriod=InpSMAPeriod;

   if(InpATRPeriod<3)
     {
      ExtATRPeriod=18;
      PrintFormat("Incorrect value for input variable InpATRPeriod=%d. Indicator will use value=%d for calculations.",
                  InpATRPeriod, ExtATRPeriod);
     }
   else
      ExtATRPeriod=InpATRPeriod;

   if(InpATRFactor1<1.0)
     {
      ExtATRFactor1=1.6;
      PrintFormat("Incorrect value for input variable InpBandsDeviations=%f. Indicator will use value=%f for calculations.",
                  InpATRFactor1, ExtATRFactor1);
     }
   else
      ExtATRFactor1=InpATRFactor1;
      
      if(InpATRFactor2<1.0)
     {
      ExtATRFactor2=3.2;
      PrintFormat("Incorrect value for input variable InpBandsDeviations=%f. Indicator will use value=%f for calculations.",
                  InpATRFactor2, ExtATRFactor2);
     }
   else
      ExtATRFactor2=InpATRFactor2;

        if(InpATRFactor3<1.0)
     {
      ExtATRFactor3=4.8;
      PrintFormat("Incorrect value for input variable InpBandsDeviations=%f. Indicator will use value=%f for calculations.",
                  InpATRFactor3, ExtATRFactor3);
     }
   else
      ExtATRFactor3=InpATRFactor3;

      

//--- define buffers
   SetIndexBuffer(0, ExtUpp3Buffer);
   SetIndexBuffer(1, ExtUpp2Buffer);
   SetIndexBuffer(2, ExtUpp1Buffer);
   SetIndexBuffer(3, ExtSMABuffer);
   SetIndexBuffer(4, ExtDwn1Buffer);
   SetIndexBuffer(5, ExtDwn2Buffer);
   SetIndexBuffer(6, ExtDwn3Buffer);

//--- indexes draw begin settings
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, InpSMAPeriod+1);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, InpSMAPeriod+1);
   PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, InpSMAPeriod+1);
   PlotIndexSetInteger(3, PLOT_DRAW_BEGIN, InpSMAPeriod+1);
   PlotIndexSetInteger(4, PLOT_DRAW_BEGIN, InpSMAPeriod+1);
   PlotIndexSetInteger(5, PLOT_DRAW_BEGIN, InpSMAPeriod+1);
   PlotIndexSetInteger(6, PLOT_DRAW_BEGIN, InpSMAPeriod+1);
   
//--- set a 1-bar offset for each line
   PlotIndexSetInteger(0, PLOT_SHIFT, 1);
   PlotIndexSetInteger(1, PLOT_SHIFT, 1);
   PlotIndexSetInteger(2, PLOT_SHIFT, 1);
   PlotIndexSetInteger(3, PLOT_SHIFT, 1);
   PlotIndexSetInteger(4, PLOT_SHIFT, 1);
   PlotIndexSetInteger(5, PLOT_SHIFT, 1);
   PlotIndexSetInteger(6, PLOT_SHIFT, 1);
   
//--- set drawing line empty value
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(5, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(6, PLOT_EMPTY_VALUE, 0.0);
   
   //--- indicator name
   IndicatorSetString(INDICATOR_SHORTNAME, "ATR Channels");
//--- number of digits of indicator value
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

//--- create indicators
   ExtSMAHandle=iMA(NULL, 0, InpSMAPeriod, 0, MODE_LWMA, PRICE_CLOSE);
   ExtATRHandle=iATR(NULL, 0, InpATRPeriod);

   ExtPeriod=PeriodSeconds(_Period);

//--- prepare prefix for objects
   string number=StringFormat("%I64d", GetTickCount64());
   ExtPrefixUniq=StringSubstr(number, StringLen(number)-4);
   ExtPrefixUniq=ExtPrefixUniq+"_KLT";
   Print("Indicator \"ATR Channels\" started, prefix=", ExtPrefixUniq);

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
//--- if this is the first calculation of the indicator
   if(prev_calculated==0)
     {
      //--- populate the beginning values, for which the indicator cannot be calculated, with empty values
      ArrayFill(ExtUpp1Buffer, 0, rates_total, 0);
      ArrayFill(ExtUpp2Buffer, 0, rates_total, 0);
      ArrayFill(ExtUpp3Buffer, 0, rates_total, 0);
      ArrayFill(ExtSMABuffer, 0, rates_total, 0);
      ArrayFill(ExtDwn1Buffer, 0, rates_total, 0);
      ArrayFill(ExtDwn2Buffer, 0, rates_total, 0);
      ArrayFill(ExtDwn3Buffer, 0, rates_total, 0);


      //--- get EMA values into the indicator buffer
      if(CopyBuffer(ExtSMAHandle, 0, 0, rates_total, ExtSMABuffer)<0)
         return(0);

      //--- get ATR indicator values into a dynamic array
      double atr[];
      if(CopyBuffer(ExtATRHandle, 0, 0, rates_total, atr)<0)
         return(0);

      //--- shift from the beginning by the required number of bars
      int start=MathMax(InpSMAPeriod, InpATRPeriod)+1;

      //--- fill in the values of the upper and lower channel borders
      for(int i=start; i<rates_total; i++)
        {
         ExtUpp3Buffer[i]=ExtSMABuffer[i]+InpATRFactor3*atr[i];
         ExtUpp2Buffer[i]=ExtSMABuffer[i]+InpATRFactor2*atr[i];
         ExtUpp1Buffer[i]=ExtSMABuffer[i]+InpATRFactor1*atr[i];
         ExtDwn1Buffer[i]=ExtSMABuffer[i]-InpATRFactor1*atr[i];
         ExtDwn2Buffer[i]=ExtSMABuffer[i]-InpATRFactor2*atr[i];
         ExtDwn3Buffer[i]=ExtSMABuffer[i]-InpATRFactor3*atr[i];
        }

      //--- succesfully calculated
      return(rates_total);
     }

//--- if the indicator has previously been calculated, calculate values for the last 2 bars
   int start=prev_calculated-2;
   for(int i=start; i<rates_total; i++)
     {
      //--- for element-by-element copying from the indicator, use the reverse index
      int reverse_index=rates_total-i;

      //--- get indicator values
      double sma[];
      if(CopyBuffer(ExtSMAHandle, 0, reverse_index, 1, sma)<0)
         return(prev_calculated);
      double atr[];
      if(CopyBuffer(ExtATRHandle, 0, reverse_index, 1, atr)<0)
         return(prev_calculated);

      //--- write values into buffers
      ExtSMABuffer[i]=sma[0];
      ExtUpp1Buffer[i]=sma[0]+InpATRFactor1*atr[0];
      ExtUpp2Buffer[i]=sma[0]+InpATRFactor2*atr[0];
      ExtUpp3Buffer[i]=sma[0]+InpATRFactor3*atr[0];
      ExtDwn1Buffer[i]=sma[0]-InpATRFactor1*atr[0];
      ExtDwn2Buffer[i]=sma[0]-InpATRFactor2*atr[0];
      ExtDwn3Buffer[i]=sma[0]-InpATRFactor3*atr[0];
     }

//--- draw labels on levels
   

//--- successfully calculated
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- delete all our graphical objects after use
   Print("Indicator \"ATR Channels\" stopped, delete all objects with prefix=", ExtPrefixUniq);
   ObjectsDeleteAll(0, ExtPrefixUniq, 0, OBJ_ARROW_RIGHT_PRICE);
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//|  Show prices' levels                                             |
//+------------------------------------------------------------------+
