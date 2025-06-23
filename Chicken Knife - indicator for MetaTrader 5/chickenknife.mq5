//+------------------------------------------------------------------+
//|                                                 ChickenKnife.mq5 |
//|                                                    Marco Marconi |
//+------------------------------------------------------------------+
#property copyright "Marco Marconi"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1

#property indicator_label1  "Main Line"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlueViolet
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#include <MovingAverages.mqh>

//--- input parameters
input int                CKPeriod   = 14;               // Smoothing Period



//--- indicator buffer
double Buffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

   int max_period;
//--- indicator buffer mapping
   SetIndexBuffer(0,Buffer,INDICATOR_DATA);

//ArraySetAsSeries(Buffer,true);

   if(Digits()==0)
      IndicatorSetInteger(INDICATOR_DIGITS,6);
   else
      IndicatorSetInteger(INDICATOR_DIGITS,Digits());

   ArrayInitialize(Buffer,0);

   max_period=CKPeriod;

   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,max_period);

   IndicatorSetString(INDICATOR_SHORTNAME,"CK("+IntegerToString(CKPeriod)+")");


//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---


//---
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double inv_logit(double x)
  {
   return(exp(x)/(1+exp(x)));
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const int begin,const double &price[])
  {
//---
   int limit;
   limit=rates_total-prev_calculated;
   if(prev_calculated==0)
      limit=CKPeriod;

   double diff[];
   ArrayResize(diff, rates_total-limit+1);

   double tmp[];
   ArrayResize(tmp, rates_total);
   ArrayInitialize(tmp,0);
   for(int i=limit+1; i<rates_total; i++)
     {
      diff[i-limit+1] = (log(price[i])-log(price[i-1]))*100;
     }

   double err = 0;
   for(int i=limit+3; i<rates_total; i++)
     {
      err = diff[i-limit+1] - 2*(inv_logit(tmp[i-1])-0.5) * diff[i-limit];
      tmp[i] = err * diff[i-limit];

     }
   if(CKPeriod > 1)
      SimpleMAOnBuffer(rates_total,prev_calculated,begin,CKPeriod,tmp,Buffer);
   else
      ArrayCopy(Buffer, tmp)  ;

//---
   return(rates_total);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SMA(double& array[],int length,int bar)
  {
   int i;
   double sum = 0;
   for(i = 0; i < length; i++)
      sum += array[bar-i];

   return(sum/length);
  }

//+------------------------------------------------------------------+
