//+------------------------------------------------------------------+
//|                                                       ATR_MAs.mq5|
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//|                                          Author: Yashar Seyyedin |
//|       Web Address: https://www.mql5.com/en/users/yashar.seyyedin |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.10"
#property indicator_chart_window
#property indicator_buffers 10
#property indicator_plots   1

#property indicator_label1  "MA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#define BARS MathMax(rates_total-_length-_atr_length-_stdev_length-prev_calculated,1)
enum MA_TYPE {ATRWSMA, ATRWEMA, ATRWRMA, ATRWWMA};
enum MA_TYPE2 {SMA, EMA, RMA, WMA};

//--- input parameters
input int _length=8;
input MA_TYPE _type=ATRWEMA;
input int _atr_length = 14;
input int _stdev_length = 100;
input double _stdev_mult = 1.0;

//--- indicator buffers
double         MABuffer[];
double         EMA1Buffer[];
double         EMA2Buffer[];
double         RMA1Buffer[];
double         RMA2Buffer[];
double         RMA3Buffer[];
double         atrwoBuffer[];
double         trwoBuffer[];
double         ta_trBuffer[];
double         atrwotmpBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MABuffer,INDICATOR_DATA);
   SetIndexBuffer(1,EMA1Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,EMA2Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,RMA1Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,RMA2Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,RMA3Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,atrwoBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,trwoBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,ta_trBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,atrwotmpBuffer,INDICATOR_CALCULATIONS);

   ArraySetAsSeries(MABuffer,true);
   ArraySetAsSeries(EMA1Buffer,true);
   ArraySetAsSeries(EMA2Buffer,true);
   ArraySetAsSeries(RMA1Buffer,true);
   ArraySetAsSeries(RMA2Buffer,true);
   ArraySetAsSeries(RMA3Buffer,true);
   ArraySetAsSeries(atrwoBuffer,true);
   ArraySetAsSeries(trwoBuffer,true);
   ArraySetAsSeries(ta_trBuffer,true);
   ArraySetAsSeries(atrwotmpBuffer,true);
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
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);

   for(int i=BARS; i>=0; i--)
      MABuffer[i]=anyma(open, close, high, low, close, _length, _type, _atr_length, _stdev_length, _stdev_mult, i);

   return(rates_total);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double anyma(const double &open[],
             const double &close[],
             const double &high[],
             const double &low[],
             const double &src[],
             int length,
             MA_TYPE type,
             int atr_length = 14,
             int stdev_length = 100,
             double stdev_mult = 1.0,
             int index = 0)
  {
   switch(type)
     {
      case ATRWSMA:
         return atrwma(open, close, high, low, src, length, SMA, atr_length, stdev_length, stdev_mult, index);
      case ATRWEMA:
         return atrwma(open, close, high, low, src, length, EMA, atr_length, stdev_length, stdev_mult, index);
      case ATRWRMA:
         return atrwma(open, close, high, low, src, length, RMA, atr_length, stdev_length, stdev_mult, index);
      case ATRWWMA:
         return atrwma(open, close, high, low, src, length, WMA, atr_length, stdev_length, stdev_mult, index);
      default:
         return EMPTY_VALUE;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double atrwma(
   const double &open[],
   const double &close[],
   const double &high[],
   const double &low[],
   const double &src[],
   int length,
   MA_TYPE2 type,
   int atr_length,
   int stdev_length,
   double stdev_mult,
   int index)
  {
   atrwo(open, close, high, low, length, stdev_length, stdev_mult, index);
   atrwotmpBuffer[index]=src[index]*atrwoBuffer[index];
   switch(type)
     {
      case SMA:
         return pine_sma(atrwotmpBuffer, length, index)/pine_sma(atrwoBuffer, length, index);
      case EMA:
         return pine_ema(atrwotmpBuffer, EMA1Buffer, length, index)/pine_ema(atrwoBuffer, EMA2Buffer, length, index);
      case RMA:
         return pine_rma(atrwotmpBuffer, RMA1Buffer, length, index)/pine_rma(atrwoBuffer, RMA2Buffer, length, index);
      case WMA:
         return pine_wma(atrwotmpBuffer, length, index)/pine_wma(atrwoBuffer,length, index);
     }
   return EMPTY_VALUE;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void atrwo(const double &open[],
           const double &close[],
           const double &high[],
           const double &low[],
           int length = 14,
           int stdev_length = 100,
           double stdev_mult = 1,
           int index = 0)
  {
   atrwoBuffer[index] = 0.0;
   trwoBuffer[index] = 0.0;
   ta_trBuffer[index]=MathMax(high[index] - low[index], MathAbs(high[index] - close[index+1]));
   ta_trBuffer[index]=MathMax(ta_trBuffer[index], MathAbs(low[index] - close[index+1]));
   double max_tr = atrwoBuffer[index+1] + stdev_mult * pine_stdev(ta_trBuffer, stdev_length, index);
   trwoBuffer[index] = ta_trBuffer[index] > max_tr ? trwoBuffer[index+1] : ta_trBuffer[index];
   atrwoBuffer[index] = pine_rma(trwoBuffer, RMA3Buffer, length, index);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double pine_stdev(double &src[], int length, int index)
  {
   double avg = pine_sma(src, length, index);
   double sumOfSquareDeviations = 0.0;
   for(int i = index; i<index+length; i++)
     {
      double sum = src[i]-avg;
      sumOfSquareDeviations = sumOfSquareDeviations + sum * sum;
     }
   return MathSqrt(sumOfSquareDeviations / length);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double pine_sma(const double &src[], int length, int index)
  {
   double sum = 0.0;
   for(int i = index; i<index+length; i++)
      sum = sum + src[i] / length;
   return sum;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double pine_ema(const double &src[], double &out[], int length, int index)
  {
   double alpha=2.0/(1+length);
   out[index] = out[index+1]*(1-alpha)+src[index]*alpha;
   return out[index];
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double pine_rma(const double &src[], double &out[], int length, int index)
  {
   double alpha=1.0/(length);
   out[index] = out[index+1]*(1-alpha)+src[index]*alpha;
   return out[index];
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double pine_wma(const double &src[], int length, int index)
  {
   double norm = 0.0;
   double sum = 0.0;
   for(int i = index; i<index+length; i++)
     {
      double weight = (length - i+index) * length;
      norm = norm + weight;
      sum = sum + src[i] * weight;
     }
   return sum/norm;
  }

//+------------------------------------------------------------------+