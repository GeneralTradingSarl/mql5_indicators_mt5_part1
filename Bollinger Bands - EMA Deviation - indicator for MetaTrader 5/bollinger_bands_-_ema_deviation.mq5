//------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property description "Bollinger bands - EMA deviation"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   5
#property indicator_label1  "upper filling"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'207,243,207'
#property indicator_label2  "lower filling"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  C'252,225,205'
#property indicator_label3  "Upper band"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrLimeGreen,clrSandyBrown
#property indicator_width3  3
#property indicator_label4  "Lower band"
#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrLimeGreen,clrSandyBrown
#property indicator_width4  3
#property indicator_label5  "Middle value"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrDarkGray
#property indicator_width5  2
//
//
//
//
//

enum enMaTypes
  {
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
  };
input int                 inpPeriods    = 20;           // Bollinger bands period
input double              inpDeviations = 2.0;          // Bollinger bands deviations
input enMaTypes           inpMaMethod   = ma_ema;       // Bands median average method
input ENUM_APPLIED_PRICE  inpPrice      = PRICE_CLOSE;  // Price
                                                        //
//---
//
double bufferUp[],bufferUpc[],bufferDn[],bufferDnc[],bufferMe[],fupu[],fupd[],fdnd[],fdnu[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,fupu,INDICATOR_DATA);      SetIndexBuffer(1,fupd,INDICATOR_DATA);
   SetIndexBuffer(2,fdnu,INDICATOR_DATA);      SetIndexBuffer(3,fdnd,INDICATOR_DATA);
   SetIndexBuffer(4,bufferUp,INDICATOR_DATA); SetIndexBuffer(5,bufferUpc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,bufferDn,INDICATOR_DATA); SetIndexBuffer(7,bufferDnc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(8,bufferMe,INDICATOR_DATA);
   return(0);
  }
void OnDeinit(const int reason) { return; }
//+------------------------------------------------------------------+
//| Custom indicator calculation function                            |
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
   if(Bars(_Symbol,_Period)<rates_total) return(-1);
   for(int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
     {
      double price     = getPrice(inpPrice,open,close,high,low,i,rates_total);
      double deviation = iEmaDeviation(price,inpPeriods,i,rates_total);

      //
      //---
      //

      bufferMe[i] = iCustomMa(inpMaMethod,price,inpPeriods,i,rates_total);
      bufferUp[i] = bufferMe[i]+deviation*inpDeviations;
      bufferDn[i] = bufferMe[i]-deviation*inpDeviations;
      fupd[i]     = bufferMe[i]; fupu[i] = bufferUp[i];
      fdnu[i]     = bufferMe[i]; fdnd[i] = bufferDn[i];
      if(i>0)
        {
         bufferUpc[i] = bufferUpc[i-1];
         bufferDnc[i] = bufferDnc[i-1];

         //
         //---
         //

         if(bufferUp[i]>bufferUp[i-1]) bufferUpc[i] = 0;
         if(bufferUp[i]<bufferUp[i-1]) bufferUpc[i] = 1;
         if(bufferDn[i]>bufferDn[i-1]) bufferDnc[i] = 0;
         if(bufferDn[i]<bufferDn[i-1]) bufferDnc[i] = 1;
        }
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
#define _edevInstances 1
#define _edevInstancesSize 2
double workEmaDeviation[][_edevInstances*_edevInstancesSize];
#define _ema0 0
#define _ema1 1
//
//---
//
double iEmaDeviation(double price,double period,int i,int bars,int instanceNo=0)
  {
   if(ArrayRange(workEmaDeviation,0)!=bars) ArrayResize(workEmaDeviation,bars); instanceNo*=_edevInstancesSize;

   workEmaDeviation[i][instanceNo+_ema0] = price;
   workEmaDeviation[i][instanceNo+_ema1] = price;
   if(i>0 && period>1)
     {
      double alpha=2.0/(1.0+period);
      workEmaDeviation[i][instanceNo+_ema0] = workEmaDeviation[i-1][instanceNo+_ema0]+alpha*(price      -workEmaDeviation[i-1][instanceNo+_ema0]);
      workEmaDeviation[i][instanceNo+_ema1] = workEmaDeviation[i-1][instanceNo+_ema1]+alpha*(price*price-workEmaDeviation[i-1][instanceNo+_ema1]);
     }
   return(MathSqrt(period*(workEmaDeviation[i][instanceNo+_ema1]-workEmaDeviation[i][instanceNo+_ema0]*workEmaDeviation[i][instanceNo+_ema0])/MathMax(period-1,1)));
  }
//
//---
///
#define _maInstances 2
#define _maWorkBufferx1 1*_maInstances
//
//---
//
double iCustomMa(int mode,double price,double length,int r,int bars,int instanceNo=0)
  {
   switch(mode)
     {
      case ma_sma   : return(iSma(price,(int)length,r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)length,r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)length,r,bars,instanceNo));
      default       : return(price);
     }
  }
//
//---
//
double workSma[][_maWorkBufferx1];
//
//---
//
double iSma(double price,int period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSma,0)!=_bars) ArrayResize(workSma,_bars);

   workSma[r][instanceNo]=price;
   double avg=price; int k=1; for(; k<period && (r-k)>=0; k++) avg+=workSma[r-k][instanceNo];
   return(avg/(double)k);
  }
//
//---
//
double workEma[][_maWorkBufferx1];
//
//---
//
double iEma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workEma,0)!=_bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo]=price;
   if(r>0 && period>1)
      workEma[r][instanceNo]=workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
  }
//
//---
//
double workSmma[][_maWorkBufferx1];
//
//---
//
double iSmma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workSmma,0)!=_bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo]=price;
   if(r>1 && period>1)
      workSmma[r][instanceNo]=workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
  }
//
//---
//
double workLwma[][_maWorkBufferx1];
//
//---
//
double iLwma(double price,double period,int r,int _bars,int instanceNo=0)
  {
   if(ArrayRange(workLwma,0)!=_bars) ArrayResize(workLwma,_bars);

   workLwma[r][instanceNo] = price; if(period<1) return(price);
   double sumw = period;
   double sum  = period*price;

   for(int k=1; k<period && (r-k)>=0; k++)
     {
      double weight=period-k;
      sumw  += weight;
      sum   += weight*workLwma[r-k][instanceNo];
     }
   return(sum/sumw);
  }
//
//---
//
double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i,int _bars)
  {
   switch(tprice)
     {
      case PRICE_CLOSE:     return(close[i]);
      case PRICE_OPEN:      return(open[i]);
      case PRICE_HIGH:      return(high[i]);
      case PRICE_LOW:       return(low[i]);
      case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
      case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
      case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
     }
   return(0);
  }
//+------------------------------------------------------------------+
