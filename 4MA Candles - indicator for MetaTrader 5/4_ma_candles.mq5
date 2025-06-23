//------------------------------------------------------------------
#property copyright   "mladen"
#property link        "www.forex-tsd.com"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1

#property indicator_label1  "4 ma candles"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGray,clrLimeGreen,clrSandyBrown

//
//
//
//
//

enum enMaTypes
{
   avgSma,    // Simple moving average
   avgEma,    // Exponential moving average
   avgSmma,   // Smoothed MA
   avgLwma    // Linear weighted MA
};

input int       AvgPeriod  = 25;       // Averages period
input enMaTypes AvgType    = avgEma;   // Averages method

double canc[],cano[],canh[],canl[],colors[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,cano  ,INDICATOR_DATA);
   SetIndexBuffer(1,canh  ,INDICATOR_DATA);
   SetIndexBuffer(2,canl  ,INDICATOR_DATA);
   SetIndexBuffer(3,canc  ,INDICATOR_DATA);
   SetIndexBuffer(4,colors,INDICATOR_COLOR_INDEX);
   return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

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
   int bars = Bars(_Symbol,_Period); if (bars<rates_total) return(-1);
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
   {
      double mao = iCustomMa(AvgType,open[i] ,AvgPeriod,i,rates_total,0);
      double mac = iCustomMa(AvgType,close[i],AvgPeriod,i,rates_total,1);
      double mah = iCustomMa(AvgType,high[i] ,AvgPeriod,i,rates_total,2);
      double mal = iCustomMa(AvgType,low[i]  ,AvgPeriod,i,rates_total,3);
         canh[i] = MathMax(MathMax(MathMax(mao,mac),mal),mah);
         canl[i] = MathMin(MathMin(MathMin(mao,mac),mal),mah);
         cano[i] = mao;
         canc[i] = mac;
         colors[i] = mao>mac ? 2 : mao<mac ? 1 : 0; 
   }
   return(rates_total);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

#define _maInstances 4
#define _maWorkBufferx1 1*_maInstances
#define _maWorkBufferx2 2*_maInstances

double iCustomMa(int mode, double price, double length, int r, int bars, int instanceNo=0)
{
   switch (mode)
   {
      case avgSma   : return(iSma(price,(int)length,r,bars,instanceNo));
      case avgEma   : return(iEma(price,length,r,bars,instanceNo));
      case avgSmma  : return(iSmma(price,(int)length,r,bars,instanceNo));
      case avgLwma  : return(iLwma(price,(int)length,r,bars,instanceNo));
      default       : return(price);
   }
}

//
//
//
//
//

double workSma[][_maWorkBufferx2];
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars); instanceNo *= 2; int k;

   //
   //
   //
   //
   //
      
   workSma[r][instanceNo+0] = price;
   workSma[r][instanceNo+1] = price; for(k=1; k<period && (r-k)>=0; k++) workSma[r][instanceNo+1] += workSma[r-k][instanceNo+0];  
   workSma[r][instanceNo+1] /= 1.0*k;
   return(workSma[r][instanceNo+1]);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workEma,0)!= _bars) ArrayResize(workEma,_bars);

   //
   //
   //
   //
   //
      
   workEma[r][instanceNo] = price;
   double alpha = 2.0 / (1.0+period);
   if (r>0)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+alpha*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workSmma,0)!= _bars) ArrayResize(workSmma,_bars);

   //
   //
   //
   //
   //

   if (r<period)
         workSmma[r][instanceNo] = price;
   else  workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workLwma,0)!= _bars) ArrayResize(workLwma,_bars);
   
   //
   //
   //
   //
   //
   
   workLwma[r][instanceNo] = price;
      double sumw = period;
      double sum  = period*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k;
                sumw  += weight;
                sum   += weight*workLwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}