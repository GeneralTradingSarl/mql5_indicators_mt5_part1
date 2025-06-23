//+------------------------------------------------------------------+
//|                                              ATRStopLoss_Ind.mq5 |
//|                                                     Rosh Jardine |
//|                                        https://roshjardine.com   |
//+------------------------------------------------------------------+
#property copyright "Rosh Jardine (MQL5/MQL4)"
#property link      "https://roshjardine.com"
#property version   "1.00"
#property description "Based on https://www.mql5.com/en/forum/349885 , this indicator will draw ATR based stop loss calculation with adjustable multiplier and ATR period."
#property description "This indicator includes helper functions and example to run calculation via function call so the calculation logic can be placed in external include file"
#property indicator_chart_window

#property indicator_buffers 5
#property indicator_plots   2
#property indicator_type1   DRAW_LINE
#property indicator_color1  Orchid
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
#property indicator_type2   DRAW_LINE
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
#property indicator_color2  Blue
#property indicator_label1  "Up"
#property indicator_label2  "Dn"


//---- input parameters
input int    Length=10; //how many look back periods to check the price
input int    ATRperiod=10;
input double Kv=2.5;
//---- indicator buffers
double UpBuffer1[];
double DnBuffer1[];
double smin[];
double smax[];
double trend[];

int AtrHandle;
double AtrBfr[1];
int bars_calculated;
string short_name;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   bars_calculated = 0;

   short_name="ATRStopLoss_Ind";
   AtrHandle = iATR(_Symbol,_Period,ATRperiod);
   if(AtrHandle==INVALID_HANDLE)
     {
      return(INIT_FAILED);
     }
   ArrayInitialize(AtrBfr,EMPTY_VALUE);
   SetIndexBuffer(0,UpBuffer1);
   SetIndexBuffer(1,DnBuffer1);
   SetIndexBuffer(2,smin);
   SetIndexBuffer(3,smax);
   SetIndexBuffer(4,trend);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,Length);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,Length);
   PlotIndexSetInteger(0,PLOT_SHIFT,0);
   PlotIndexSetInteger(1,PLOT_SHIFT,0);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
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
   int limit;
   if(rates_total<=Length)
      return(0);
   if(prev_calculated<1)
     {
      /*
      int shift;
      ArrayInitialize(UpBuffer1,EMPTY_VALUE);
      ArrayInitialize(DnBuffer1,EMPTY_VALUE);
      ArrayInitialize(smin,EMPTY_VALUE);
      ArrayInitialize(smax,EMPTY_VALUE);
      ArrayInitialize(trend,EMPTY_VALUE);
      ArraySetAsSeries(UpBuffer1,true);
      ArraySetAsSeries(DnBuffer1,true);
      ArraySetAsSeries(smin,true);
      ArraySetAsSeries(smax,true);
      ArraySetAsSeries(trend,true);

      limit = rates_total-Length-1;

      for (shift=limit;shift>=0;shift--)
      {
          smin[shift] = -100000; smax[shift] = 100000;
          for(int i=Length-1;i>=0;i--)
          {
              int copybuffer = CopyBuffer(AtrHandle,0,shift+i,1,AtrBfr);
              if (copybuffer<1)
              {
                  StopIndicator();
              }
              smin[shift] = MathMax( smin[shift], iHigh(_Symbol,_Period,shift+i) - Kv*AtrBfr[0]);
              smax[shift] = MathMin( smax[shift], iLow(_Symbol,_Period,shift+i) + Kv*AtrBfr[0]);
          }
          trend[shift]= trend[shift+1];
        if ( iClose(_Symbol,_Period,shift) > smax[shift+1] )
        {
            trend[shift] =  1;
        }
        if ( iClose(_Symbol,_Period,shift) < smin[shift+1] )
        {
            trend[shift] = -1;
        }
        if ( trend[shift] >0 )
        {
            if( smin[shift]<smin[shift+1] ) smin[shift]=smin[shift+1];
            UpBuffer1[shift] = smin[shift];
            DnBuffer1[shift] = EMPTY_VALUE;
        }
        if ( trend[shift] <0 )
        {
            if( smax[shift]>smax[shift+1] ) smax[shift]=smax[shift+1];
            UpBuffer1[shift] = EMPTY_VALUE;
            DnBuffer1[shift] = smax[shift];
        }
      }
      */
      limit = rates_total-Length-1;
      if(!AtrStopFirstRun(limit,UpBuffer1,DnBuffer1,smin,smax,trend,AtrHandle,AtrBfr,Length,_Symbol,_Period,Kv))
        {
         StopIndicator();
        }
      bars_calculated = limit;
      return(rates_total);
     }


   else
     {
      limit=prev_calculated-Length-1;

      if(limit>bars_calculated)
        {
         if(!AtrStopNextRun(bars_calculated+1,UpBuffer1,DnBuffer1,smin,smax,trend,AtrHandle,AtrBfr,Length,_Symbol,_Period,Kv,false))
           {
            StopIndicator();
           }
         bars_calculated +=1;
        }
      else
        {
         if(!AtrStopNextRun(bars_calculated+1,UpBuffer1,DnBuffer1,smin,smax,trend,AtrHandle,AtrBfr,Length,_Symbol,_Period,Kv,true))
           {
            StopIndicator();
           }
        }
      /*
      if (limit>bars_calculated)
      {
          ArrayResize(UpBuffer1,bars_calculated+1);
          ArrayResize(DnBuffer1,bars_calculated+1);
          ArrayResize(smin,bars_calculated+1);
          ArrayResize(smax,bars_calculated+1);
          ArrayResize(trend,bars_calculated+1);
          UpBuffer1[0] = DnBuffer1[0]= smin[0] = smax[0] = trend[0] = EMPTY_VALUE;
          bars_calculated +=1;
      }
      for(int j=0;j<=1;j++)
      {
          smin[j] = -100000; smax[j] = 100000;
          for(int k=0;k<=Length-1;k++)
          {
              int copybuffer = CopyBuffer(AtrHandle,0,j+k,1,AtrBfr);
              if (copybuffer<1)
              {
                  StopIndicator();

              }
              smin[j] = MathMax( smin[j], iHigh(_Symbol,_Period,j+k) - Kv*AtrBfr[0]);
              smax[j] = MathMin( smax[j], iLow(_Symbol,_Period,j+k) + Kv*AtrBfr[0]);
          }
          trend[j]= trend[j+1];
        if ( iClose(_Symbol,_Period,j) > smax[j+1] ) trend[j] =  1;
        if ( iClose(_Symbol,_Period,j) < smin[j+1] ) trend[j] = -1;

        if ( trend[j] >0 )
        {
            if( smin[j]<smin[j+1] ) smin[j]=smin[j+1];
            UpBuffer1[j] = smin[j];
            DnBuffer1[j] = EMPTY_VALUE;
        }
        if ( trend[j] <0 )
        {
            if( smax[j]>smax[j+1] ) smax[j]=smax[j+1];
            UpBuffer1[j] = EMPTY_VALUE;
            DnBuffer1[j] = smax[j];
        }
      }*/
      return(rates_total);
     }
  }

/************************************ AS HELPERS ************************************/
bool AtrStopNextRun(int newlimit,double &upbfr[],
                    double &dnbfr[],double &min[],
                    double &max[],double &trd[],int &atrhandler,
                    double &atrbuffer[],int atrlength,
                    const string symbol,ENUM_TIMEFRAMES tframe,
                    double multiplier,bool samebar)
  {
   if(!samebar)
     {
      ArrayResize(upbfr,newlimit);
      ArrayResize(dnbfr,newlimit);
      ArrayResize(min,newlimit);
      ArrayResize(max,newlimit);
      ArrayResize(trd,newlimit);
      upbfr[0] = dnbfr[0]= min[0] = max[0] = trd[0] = EMPTY_VALUE;
     }
   else
     {
      upbfr[0] = dnbfr[0]= min[0] = max[0] = trd[0] = EMPTY_VALUE;
     }
   for(int j=0; j<=1; j++)
     {
      min[j] = -100000;
      max[j] = 100000;
      for(int k=0; k<=atrlength-1; k++)
        {
         int copybuffer = CopyBuffer(atrhandler,0,j+k,1,atrbuffer);
         if(copybuffer<1)
           {
            return(false);
           }
         min[j] = MathMax(smin[j], iHigh(symbol,tframe,j+k) - multiplier*AtrBfr[0]);
         max[j] = MathMin(smax[j], iLow(symbol,tframe,j+k) + multiplier*AtrBfr[0]);
        }
      trd[j]= trd[j+1];
      if(iClose(symbol,tframe,j) > max[j+1])
        {
         trd[j] =  1;
        }
      if(iClose(symbol,tframe,j) < min[j+1])
        {
         trd[j] = -1;
        }
      if(trd[j] >0)
        {
         if(min[j]<min[j+1])
           {
            min[j] = min[j+1];
           }
         upbfr[j] = min[j];
         dnbfr[j] = EMPTY_VALUE;
        }
      if(trend[j] <0)
        {
         if(max[j]>max[j+1])
           {
            max[j]=max[j+1];
           }
         upbfr[j] = EMPTY_VALUE;
         dnbfr[j] = max[j];
        }
     }
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AtrStopFirstRun(int limit,double &upbfr[],
                     double &dnbfr[],double &min[],
                     double &max[],double &trd[],int &atrhandler,
                     double &atrbuffer[],int atrlength,
                     const string symbol,ENUM_TIMEFRAMES tframe,
                     double multiplier
                    )
  {
   ArrayInitialize(upbfr,EMPTY_VALUE);
   ArrayInitialize(dnbfr,EMPTY_VALUE);
   ArrayInitialize(min,EMPTY_VALUE);
   ArrayInitialize(max,EMPTY_VALUE);
   ArrayInitialize(trd,EMPTY_VALUE);
   ArraySetAsSeries(upbfr,true);
   ArraySetAsSeries(dnbfr,true);
   ArraySetAsSeries(min,true);
   ArraySetAsSeries(max,true);
   ArraySetAsSeries(trd,true);
   int shift = 0;
   for(shift=limit; shift>=0; shift--)
     {
      min[shift] = -100000;
      max[shift] = 100000;
      for(int i=atrlength-1; i>=0; i--)
        {
         int copybuffer = CopyBuffer(atrhandler,0,shift+i,1,atrbuffer);
         if(copybuffer<1)
           {
            return(false);
           }
         min[shift] = MathMax(min[shift], iHigh(symbol,tframe,shift+i) - multiplier*atrbuffer[0]);
         max[shift] = MathMin(max[shift], iLow(symbol,tframe,shift+i) + multiplier*atrbuffer[0]);
        }
      trd[shift] = trd[shift+1];
      if(iClose(symbol,tframe,shift) > max[shift+1])
        {
         trd[shift] =  1;
        }
      if(iClose(symbol,tframe,shift) < min[shift+1])
        {
         trd[shift] = -1;
        }
      if(trd[shift] >0)
        {
         if(min[shift]<min[shift+1])
           {
            min[shift] = min[shift+1];
           }
         upbfr[shift] = min[shift];
         dnbfr[shift] = EMPTY_VALUE;
        }
      if(trd[shift] <0)
        {
         if(max[shift]>max[shift+1])
           {
            max[shift] = max[shift+1];
           }
         upbfr[shift] = EMPTY_VALUE;
         dnbfr[shift] = max[shift];
        }
     }
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StopIndicator()
  {
   IndicatorRelease(AtrHandle);
   ChartIndicatorDelete(ChartID(),0,short_name);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(AtrHandle!=INVALID_HANDLE)
      IndicatorRelease(AtrHandle);
  }


//---
//--- MQL4
//---

#ifdef __MQL4__
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//---- input parameters
extern int    Length=10;
extern int    ATRperiod=10;
extern double Kv=2.5;
double UpBuffer1[];
double DnBuffer1[];
double smin[];
double smax[];
double trend[];

double AtrBfr[1];
int bars_calculated;
string short_name;
int OnInit()
  {
   bars_calculated = 0;

   short_name="ATRStopLoss_Ind";
   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   IndicatorBuffers(5);
   SetIndexBuffer(0,UpBuffer1);
   SetIndexBuffer(1,DnBuffer1);
   SetIndexBuffer(2,smin);
   SetIndexBuffer(3,smax);
   SetIndexBuffer(4,trend);
   IndicatorShortName(short_name);
   SetIndexLabel(0,"Up");
   SetIndexLabel(1,"Dn");
   SetIndexDrawBegin(0,Length);
   SetIndexDrawBegin(1,Length);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
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
   int limit;
   if(rates_total<=Length)
     {
      return(0);
     }
   if(prev_calculated<1)
     {
      /*
      int shift;
      ArrayInitialize(UpBuffer1,EMPTY_VALUE);
      ArrayInitialize(DnBuffer1,EMPTY_VALUE);
      ArrayInitialize(smin,EMPTY_VALUE);
      ArrayInitialize(smax,EMPTY_VALUE);
      ArrayInitialize(trend,EMPTY_VALUE);
      ArraySetAsSeries(UpBuffer1,true);
      ArraySetAsSeries(DnBuffer1,true);
      ArraySetAsSeries(smin,true);
      ArraySetAsSeries(smax,true);
      ArraySetAsSeries(trend,true);
      limit = rates_total-Length-1;
      for (shift=limit;shift>=0;shift--)
      {
          smin[shift] = -100000;
      smax[shift] = 100000;
          for(int i=Length-1;i>=0;i--)
          {
              smin[shift] = MathMax( smin[shift], iHigh(_Symbol,_Period,shift+i) - Kv*iATR(Symbol(),Period(),ATRperiod,shift+i));
              smax[shift] = MathMin( smax[shift], iLow(_Symbol,_Period,shift+i) + Kv*iATR(Symbol(),Period(),ATRperiod,shift+i));
          }
          trend[shift]= trend[shift+1];
        if ( iClose(_Symbol,_Period,shift) > smax[shift+1] )
        {
            trend[shift] =  1;
        }
        if ( iClose(_Symbol,_Period,shift) < smin[shift+1] )
        {
            trend[shift] = -1;
        }
        if ( trend[shift] >0 )
        {
            if( smin[shift]<smin[shift+1] ) smin[shift]=smin[shift+1];
            UpBuffer1[shift] = smin[shift];
            DnBuffer1[shift] = EMPTY_VALUE;
        }
        if ( trend[shift] <0 )
        {
            if( smax[shift]>smax[shift+1] ) smax[shift]=smax[shift+1];
            UpBuffer1[shift] = EMPTY_VALUE;
            DnBuffer1[shift] = smax[shift];
        }
      }
      */

      /*** AS FUNCTION CALL EXAMPLE ***/

      limit = rates_total-Length-1;
      if(!AtrStopFirstRun(limit,UpBuffer1,DnBuffer1,smin,smax,trend,Length,Symbol(),Period(),Kv))
        {
         return(0);
        }
      bars_calculated = limit;
      return(rates_total);
     }
   else
     {
      limit = prev_calculated-Length-1;
      /*** AS FUNCTION CALL EXAMPLE ***/
      if(limit>bars_calculated)
        {
         if(!AtrStopNextRun(bars_calculated+1,UpBuffer1,DnBuffer1,smin,smax,trend,Length,Symbol(),Period(),Kv,false))
           {
            return(0);
           }
        }
      if(!AtrStopNextRun(bars_calculated+1,UpBuffer1,DnBuffer1,smin,smax,trend,Length,Symbol(),Period(),Kv,true))
        {
         return(0);
        }
      /*
      if (limit>bars_calculated)
      {
          ArrayResize(UpBuffer1,bars_calculated+1);
          ArrayResize(DnBuffer1,bars_calculated+1);
          ArrayResize(smin,bars_calculated+1);
          ArrayResize(smax,bars_calculated+1);
          ArrayResize(trend,bars_calculated+1);
          UpBuffer1[0] = DnBuffer1[0]= smin[0] = smax[0] = trend[0] = EMPTY_VALUE;
          bars_calculated +=1;
      }
      for(int j=0;j<=1;j++)
      {
          smin[j] = -100000;
      smax[j] = 100000;
          for(int k=0;k<=Length-1;k++)
          {
              smin[j] = MathMax( smin[j], iHigh(Symbol(),Period(),j+k) - Kv*iATR(Symbol(),Period(),ATRperiod,j+k));
              smax[j] = MathMin( smax[j], iLow(Symbol(),Period(),j+k) + Kv*AtrBfr[0]);
          }
          trend[j]= trend[j+1];
        if ( iClose(Symbol(),Period(),j) > smax[j+1] ) trend[j] =  1;
        if ( iClose(Symbol(),Period(),j) < smin[j+1] ) trend[j] = -1;

        if ( trend[j] >0 )
        {
            if( smin[j]<smin[j+1] ) smin[j]=smin[j+1];
            UpBuffer1[j] = smin[j];
            DnBuffer1[j] = EMPTY_VALUE;
        }
        if ( trend[j] <0 )
        {
            if( smax[j]>smax[j+1] ) smax[j]=smax[j+1];
            UpBuffer1[j] = EMPTY_VALUE;
            DnBuffer1[j] = smax[j];
        }
      }
      */
      return(rates_total);
     }
  }

/************************************ AS HELPERS ************************************/

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AtrStopFirstRun(int limit,double &upbfr[],
                     double &dnbfr[],double &min[],
                     double &max[],double &trd[],int atrlength,
                     const string symbol,const int tframe,
                     double multiplier
                    )
  {
   ArrayInitialize(upbfr,EMPTY_VALUE);
   ArrayInitialize(dnbfr,EMPTY_VALUE);
   ArrayInitialize(min,EMPTY_VALUE);
   ArrayInitialize(max,EMPTY_VALUE);
   ArrayInitialize(trd,EMPTY_VALUE);
   ArraySetAsSeries(upbfr,true);
   ArraySetAsSeries(dnbfr,true);
   ArraySetAsSeries(min,true);
   ArraySetAsSeries(max,true);
   ArraySetAsSeries(trd,true);
   int shift = 0;
   for(shift=limit; shift>=0; shift--)
     {
      min[shift] = -100000;
      max[shift] = 100000;
      for(int i=atrlength-1; i>=0; i--)
        {
         min[shift] = MathMax(min[shift], iHigh(symbol,tframe,shift+i) - multiplier*iATR(symbol,tframe,ATRperiod,shift+1));
         max[shift] = MathMin(max[shift], iLow(symbol,tframe,shift+i) + multiplier*iATR(symbol,tframe,ATRperiod,shift+1));
        }
      trd[shift] = trd[shift+1];
      if(iClose(symbol,tframe,shift) > max[shift+1])
        {
         trd[shift] =  1;
        }
      if(iClose(symbol,tframe,shift) < min[shift+1])
        {
         trd[shift] = -1;
        }
      if(trd[shift] >0)
        {
         if(min[shift]<min[shift+1])
           {
            min[shift] = min[shift+1];
           }
         upbfr[shift] = min[shift];
         dnbfr[shift] = EMPTY_VALUE;
        }
      if(trd[shift] <0)
        {
         if(max[shift]>max[shift+1])
           {
            max[shift]= max[shift+1];
           }
         upbfr[shift] = EMPTY_VALUE;
         dnbfr[shift] = max[shift];
        }
     }
   return(true);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AtrStopNextRun(int newlimit,double &upbfr[],
                    double &dnbfr[],double &min[],
                    double &max[],double &trd[],int atrlength,
                    const string symbol,const int tframe,
                    double multiplier,bool samebar)
  {
   if(!samebar)
     {
      ArrayResize(upbfr,newlimit);
      ArrayResize(dnbfr,newlimit);
      ArrayResize(min,newlimit);
      ArrayResize(max,newlimit);
      ArrayResize(trd,newlimit);
      upbfr[0] = dnbfr[0]= min[0] = max[0] = trd[0] = EMPTY_VALUE;
     }
   else
     {
      upbfr[0] = dnbfr[0]= min[0] = max[0] = trd[0] = EMPTY_VALUE;
     }
   for(int j=0; j<=1; j++)
     {
      min[j] = -100000;
      max[j] = 100000;
      for(int k=0; k<=atrlength-1; k++)
        {
         min[j] = MathMax(smin[j], iHigh(symbol,tframe,j+k) - multiplier*iATR(symbol,tframe,ATRperiod,j+k));
         max[j] = MathMin(smax[j], iLow(symbol,tframe,j+k) + multiplier*iATR(symbol,tframe,ATRperiod,j+k));
        }
      trd[j] = trd[j+1];
      if(iClose(symbol,tframe,j) > max[j+1])
        {
         trd[j] = 1;
        }
      if(iClose(symbol,tframe,j) < min[j+1])
        {
         trd[j] = -1;
        }
      if(trd[j] >0)
        {
         if(min[j]<min[j+1])
           {
            min[j] = min[j+1];
           }
         upbfr[j] = min[j];
         dnbfr[j] = EMPTY_VALUE;
        }
      if(trend[j] <0)
        {
         if(max[j]>max[j+1])
           {
            max[j] = max[j+1];
           }
         upbfr[j] = EMPTY_VALUE;
         dnbfr[j] = max[j];
        }
     }
   return(true);
  }
#endif

//+------------------------------------------------------------------+
