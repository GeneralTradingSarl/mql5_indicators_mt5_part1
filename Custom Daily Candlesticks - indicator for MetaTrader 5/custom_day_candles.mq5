//+------------------------------------------------------------------+
//|                                           Custom_Day_Candles.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright     "Copyright 2018, MetaQuotes Software Corp."
#property link          "https://mql5.com"
#property version       "1.00"
#property description   "Draws of custom day candles"
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
//--- plot Candle
#property indicator_label1  "Candle"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrMediumSeaGreen,clrOrange,clrGray
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input int      InpBeginDayHour   =  0;                   // Hour of begin day
input int      InpShift          =  500;                 // Candles vertical shift
input color    InpBullishColor   =  clrMediumSeaGreen;   // Color of bullish candle
input color    InpBearishColor   =  clrOrange;           // Color of bearish candle
input color    InpDojiColor      =  clrGray;             // Color of doji candle
//--- indicator buffers
double         BufferCandleOpen[];
double         BufferCandleHigh[];
double         BufferCandleLow[];
double         BufferCandleClose[];
double         BufferColors[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- check for period
   if(Period()!=PERIOD_D1)
     {
      Alert("\"Custom Day Candles\": Timeframe must be D1");
      return INIT_FAILED;
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferCandleOpen,INDICATOR_DATA);
   SetIndexBuffer(1,BufferCandleHigh,INDICATOR_DATA);
   SetIndexBuffer(2,BufferCandleLow,INDICATOR_DATA);
   SetIndexBuffer(3,BufferCandleClose,INDICATOR_DATA);
   SetIndexBuffer(4,BufferColors,INDICATOR_COLOR_INDEX);
//--- set plots parameters
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
//--- the colors parameters 
   PlotIndexSetInteger(4,PLOT_LINE_COLOR,0,InpBullishColor);
   PlotIndexSetInteger(4,PLOT_LINE_COLOR,1,InpBearishColor);
//--- set indicators parameters
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   IndicatorSetString(INDICATOR_SHORTNAME,"Custom Day Candles");
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
   if(rates_total<2) return 0;
//--- Set arrays as time series
   ArraySetAsSeries(BufferCandleOpen,true);
   ArraySetAsSeries(BufferCandleHigh,true);
   ArraySetAsSeries(BufferCandleLow,true);
   ArraySetAsSeries(BufferCandleClose,true);
   ArraySetAsSeries(BufferColors,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
//--- check for limits
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(BufferCandleOpen,0.0);
      ArrayInitialize(BufferCandleHigh,0.0);
      ArrayInitialize(BufferCandleLow,0.0);
      ArrayInitialize(BufferCandleClose,0.0);
     }
//--- calculate indicator
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      datetime DT1=time[i]+InpBeginDayHour*PeriodSeconds(PERIOD_H1);
      datetime DT2=time[i]+PeriodSeconds(PERIOD_D1)+(InpBeginDayHour)*PeriodSeconds(PERIOD_H1)-1;
      int Bar1=BarShift(Symbol(),PERIOD_H1,DT1);
      int Bar2=BarShift(Symbol(),PERIOD_H1,DT2);
      if(Bar1==WRONG_VALUE || Bar2==WRONG_VALUE) return 0;
      datetime Time1=Time(NULL,PERIOD_H1,Bar1);
      datetime Time2=Time(NULL,PERIOD_H1,Bar2);
      if(Time1==0 || Time2==0) return 0;
      if(Time1<DT1) Bar1--;
      if(Time2>DT2) Bar2++;
      if(Bar1<Bar2) continue;
      double O=Open(Symbol(),PERIOD_H1,Bar1);
      double C=Close(Symbol(),PERIOD_H1,Bar2);
      double H=High(Symbol(),PERIOD_H1,Highest(Symbol(),PERIOD_H1,PRICE_HIGH,Bar1-Bar2+1,Bar2));
      double L=Low(Symbol(),PERIOD_H1,Lowest(Symbol(),PERIOD_H1,PRICE_LOW,Bar1-Bar2+1,Bar2));
      if(O==0 || H==0 || L==0 || C==0) return 0;
      //---
      if(DT1>TimeCurrent() || Point()==0) return 0;
      BufferCandleOpen[i]=NormalizeDouble(O+InpShift*Point(),Digits());
      BufferCandleHigh[i]=NormalizeDouble(H+InpShift*Point(),Digits());
      BufferCandleLow[i]=NormalizeDouble(L+InpShift*Point(),Digits());
      BufferCandleClose[i]=NormalizeDouble(C+InpShift*Point(),Digits());
      if(O<C)
         BufferColors[i]=0;
      else if(O>C)
         BufferColors[i]=1;
      else
         BufferColors[i]=2;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Returns the bar number by time                                   |
//+------------------------------------------------------------------+
int BarShift(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const datetime time)
  {
   int res=WRONG_VALUE;
   datetime last_bar=0;
   if(SeriesInfoInteger(symbol_name,timeframe,SERIES_LASTBAR_DATE,last_bar))
     {
      if(time>last_bar) res=0;
      else
        {
         const int shift=::Bars(symbol_name,timeframe,time,last_bar);
         if(shift>0) res=shift-1;
        }
     }
   return(res);
  }
//+------------------------------------------------------------------+
//| Returns specified Open by shift                                  |
//+------------------------------------------------------------------+
double Open(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   double array[];
   if(CopyOpen(symbol_name,timeframe,shift,1,array)==1) return array[0];
   return 0;
  }
//+------------------------------------------------------------------+
//| Returns specified High by shift                                  |
//+------------------------------------------------------------------+
double High(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   double array[];
   if(CopyHigh(symbol_name,timeframe,shift,1,array)==1) return array[0];
   return 0;
  }
//+------------------------------------------------------------------+
//| Returns specified Low by shift                                   |
//+------------------------------------------------------------------+
double Low(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   double array[];
   if(CopyLow(symbol_name,timeframe,shift,1,array)==1) return array[0];
   return 0;
  }
//+------------------------------------------------------------------+
//| Returns specified Close by shift                                 |
//+------------------------------------------------------------------+
double Close(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   double array[];
   if(CopyClose(symbol_name,timeframe,shift,1,array)==1) return array[0];
   return 0;
  }
//+------------------------------------------------------------------+
//| Returns specified Time by shift                                  |
//+------------------------------------------------------------------+
datetime Time(const string symbol_name,const ENUM_TIMEFRAMES timeframe,const int shift)
  {
   datetime array[];
   if(CopyTime(symbol_name,timeframe,shift,1,array)==1) return array[0];
   return 0;
  }
//+------------------------------------------------------------------+
//| Returns highest prices value from timeseries array               |
//+------------------------------------------------------------------+
int Highest(const string symbol_name,const ENUM_TIMEFRAMES timeframe,ENUM_APPLIED_PRICE mode_price,int count=WHOLE_ARRAY,int start=0) 
  {
   if(start<0) return(-1);
   if(count==WHOLE_ARRAY) count=Bars(symbol_name,timeframe);
   double array[];
   ArraySetAsSeries(array,true);
   int copied=
     (
      mode_price==PRICE_CLOSE ?  CopyClose(symbol_name,timeframe,start,count,array) :
      mode_price==PRICE_HIGH  ?  CopyHigh(symbol_name,timeframe,start,count,array)  :
      mode_price==PRICE_LOW   ?  CopyLow(symbol_name,timeframe,start,count,array)   :
      CopyOpen(symbol_name,timeframe,start,count,array)
     );
   return(copied<=0 ? 0 : ArrayMaximum(array)+start);
  }
//+------------------------------------------------------------------+
//| Returns lowest prices value from timeseries array                |
//+------------------------------------------------------------------+
int Lowest(const string symbol_name,const ENUM_TIMEFRAMES timeframe,ENUM_APPLIED_PRICE mode_price,int count=WHOLE_ARRAY,int start=0) 
  {
   if(start<0) return(-1);
   if(count==WHOLE_ARRAY) count=Bars(symbol_name,timeframe);
   double array[];
   ArraySetAsSeries(array,true);
   int copied=
     (
      mode_price==PRICE_CLOSE ?  CopyClose(symbol_name,timeframe,start,count,array) :
      mode_price==PRICE_HIGH  ?  CopyHigh(symbol_name,timeframe,start,count,array)  :
      mode_price==PRICE_LOW   ?  CopyLow(symbol_name,timeframe,start,count,array)   :
      CopyOpen(symbol_name,timeframe,start,count,array)
     );
   return(copied<=0 ? 0 : ArrayMinimum(array)+start);
  }
//+------------------------------------------------------------------+
