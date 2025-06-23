//+------------------------------------------------------------------+
//|                                            Chart Window MACD.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                       saeed.h.mashhadi@gmail.com |
//+------------------------------------------------------------------+
#property link        "Author: saeed.h.mashhadi@gmail.com"
#property version     "1.1"
#property description "The indicator is an equivalent \"Chart Window\" version of MACD."
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   2

#property indicator_label1  "Fast-Slow EMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrSilver
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "MACD SMA"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

//+------------------------------------------------------------------+
//| Indicator inputs & global variables                              |
//+------------------------------------------------------------------+
input int                InpFastEMA=12;               // Fast EMA Period = 12
input int                InpSlowEMA=26;               // Slow EMA Period = 26
input int                InpSignalSMA=9;              // Signal SMA Period = 9
input ENUM_APPLIED_PRICE InpAppliedPrice=PRICE_CLOSE; // Applied Price

double Fast_Slow_Buffer[];
double MACD_Buffer[];

double ExtMacdBuffer[];
double ExtSignalBuffer[];
double ExtFastMaBuffer[];
double ExtSlowMaBuffer[];

int ExtFastMaHandle;
int ExtSlowMaHandle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,Fast_Slow_Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,MACD_Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtMacdBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ExtSignalBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,ExtFastMaBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,ExtSlowMaBuffer,INDICATOR_CALCULATIONS);

   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,InpSignalSMA-1);
   IndicatorSetString(INDICATOR_SHORTNAME,"MACD("+string(InpFastEMA)+","+string(InpSlowEMA)+","+string(InpSignalSMA)+")");

   ExtFastMaHandle=iMA(NULL,0,InpFastEMA,0,MODE_EMA,InpAppliedPrice);
   ExtSlowMaHandle=iMA(NULL,0,InpSlowEMA,0,MODE_EMA,InpAppliedPrice);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Indicator "Calculate" event handler function                     |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   CopyBuffer(ExtFastMaHandle,0,0,rates_total,ExtFastMaBuffer);
   CopyBuffer(ExtSlowMaHandle,0,0,rates_total,ExtSlowMaBuffer);
   
   // Indicator
   int ii;
   for(ii=0;ii<rates_total && !IsStopped();ii++)
     {
      ExtMacdBuffer[ii]=ExtFastMaBuffer[ii]-ExtSlowMaBuffer[ii];
      Fast_Slow_Buffer[ii]=EMPTY_VALUE;
      MACD_Buffer[ii]=EMPTY_VALUE;
     }
   
   // Reverse Indicator
   for(ii=1;ii<rates_total;ii++)
      Fast_Slow_Buffer[ii]=((1-2/((double)InpFastEMA+1))*ExtFastMaBuffer[ii-1]-(1-2/((double)InpSlowEMA+1))*ExtSlowMaBuffer[ii-1])/(2/((double)InpSlowEMA+1)-2/((double)InpFastEMA+1));
   
   // Indicator
   for(ii=0;ii<InpSignalSMA-1;ii++)
      ExtSignalBuffer[ii]=0;
   double firstValue=0;
   for(ii=0;ii<InpSignalSMA;ii++)
      firstValue+=ExtMacdBuffer[ii];
   firstValue/=InpSignalSMA;
   ExtSignalBuffer[InpSignalSMA-1]=firstValue;

   for(ii=InpSignalSMA;ii<rates_total;ii++)
      ExtSignalBuffer[ii]=ExtSignalBuffer[ii-1]+(ExtMacdBuffer[ii]-ExtMacdBuffer[ii-InpSignalSMA])/InpSignalSMA;
      
   // Reverse Indicator
   for(ii=InpSignalSMA;ii<rates_total;ii++)
      MACD_Buffer[ii]=Fast_Slow_Buffer[ii]-(InpSignalSMA*ExtSignalBuffer[ii-1]-ExtMacdBuffer[ii-InpSignalSMA])/(2/((double)InpSlowEMA+1)-2/((double)InpFastEMA+1))/(InpSignalSMA-1);
      
   return(rates_total);
  }