//+------------------------------------------------------------------+
//|                                                     averages.mq5 |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "www.forex-tsd.com"

//
//
//
//
//

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1

#property indicator_label1  "Label1"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  DeepSkyBlue,PaleVioletRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//
//
//
//
//

enum enumAveragesType
{
   avgSma,    // Simple moving average
   avgEma,    // Exponential moving average
   avgDsema,  // Double smoothed EMA
   avgDema,   // Double EMA
   avgTema,   // Tripple EMA
   avgSmma,   // Smoothed MA
   avgLwma,   // Linear weighted MA
   avgPwma,   // Parabolic weighted MA
   avgAlex,   // Alexander MA
   avgVwma,   // Volume weighted MA
   avgHull,   // Hull MA
   avgTma,    // Triangular MA
   avgSine,   // Sine weighted MA
   avgLsma,   // Linear regression value
   avgIe2,    // IE/2
   avgNlma,   // Non lag MA
   avgZlma,   // Zeo lag EMA
   avgLead    // Leader EMA
};


input ENUM_TIMEFRAMES    TimeFrame     = PERIOD_CURRENT; // Time frame
input ENUM_APPLIED_PRICE Price         = PRICE_CLOSE;    // Apply to 
input int                AveragePeriod = 14;             // Calculation period
input enumAveragesType   AverageType   = 0;              // Calculation type
input bool               Multicolor    = true;           // Multi color mode?
input bool               Interpolate   = true;           // Interpolate mtf data ?

//
//
//
//
//
//

double MaBuffer[];
double ColorBuffer[];
double CountBuffer[];
enumAveragesType gAverageType;


//
//
//
//

ENUM_TIMEFRAMES timeFrame;
int             mtfHandle;
bool            calculating;
int totalBars;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,MaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ColorBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,CountBuffer,INDICATOR_CALCULATIONS); 
            gAverageType = AverageType;

      //
      //
      //
      //
      //
      
      timeFrame   = MathMax(_Period,TimeFrame);
      calculating = (timeFrame==_Period);
      if (!calculating)
      {
         string name = getIndicatorName(); mtfHandle = iCustom(NULL,timeFrame,name,PERIOD_CURRENT,Price,AveragePeriod,AverageType,Multicolor);
      }

   PlotIndexSetString(0,PLOT_LABEL,getAverageName(AverageType)+" ("+(string)AveragePeriod+")");
   IndicatorSetString(INDICATOR_SHORTNAME,getAverageName(gAverageType)+" ("+(string)AveragePeriod+")");
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &Time[],
                const double &Open[], const double &High[], const double &Low[], const double &Close[],
                const long &TickVolume[], const long &Volume[], const int &Spread[])
{                
   //
   //
   //
   //
   //

   if (calculating)
   {
      totalBars = rates_total;
      for (int i=(int)MathMax(prev_calculated-1,1); i<rates_total; i++)
      {
         double price = getPrice(Price,rates_total-i-1);
            MaBuffer[i] = iCustomMa(AverageType,price,AveragePeriod,TickVolume,i);
            if (Multicolor && i>0)
            {
               ColorBuffer[i] = ColorBuffer[i-1];
                  if (MaBuffer[i]>MaBuffer[i-1]) ColorBuffer[i]=0;
                  if (MaBuffer[i]<MaBuffer[i-1]) ColorBuffer[i]=1;
            }
            else ColorBuffer[i]=0;
      }
      CountBuffer[rates_total-1] = MathMax(rates_total-prev_calculated+1,1);
      return(rates_total);
   }
   
   //
   //
   //
   //
   //
   
      datetime times[]; 
      datetime startTime = Time[0]-PeriodSeconds(timeFrame);
      datetime endTime   = Time[rates_total-1];
         int bars = CopyTime(NULL,timeFrame,startTime,endTime,times);
        
         if (times[0]>Time[0] || bars<1) return(prev_calculated);
               double values[]; CopyBuffer(mtfHandle,0,0,bars,values);
               double colors[]; CopyBuffer(mtfHandle,1,0,bars,colors);
               double counts[]; CopyBuffer(mtfHandle,2,0,bars,counts);
         int maxb = (int)MathMax(MathMin(counts[bars-1]*PeriodSeconds(timeFrame)/PeriodSeconds(Period()),rates_total-1),1);

      //
      //
      //
      //
      //
      
      for(int i=(int)MathMax(prev_calculated-maxb,0);i<rates_total;i++)
      {
         int d = dateArrayBsearch(times,Time[i],bars);
         if (d > -1 && d < bars)
         {
            MaBuffer[i]    = values[d];
            ColorBuffer[i] = colors[d];
         }
         if (!Interpolate) continue;
         
         //
         //
         //
         //
         //
         
         int l=MathMin(i+1,rates_total-1);
         if (d!=dateArrayBsearch(times,Time[l],bars) || i==l)
         {
            int n,k;
               for(n = 1; (i-n)> 0 && Time[i-n] >= times[d]; n++) continue;	
               for(k = 1; (i-k)>=0 && k<n; k++)
                  MaBuffer[i-k] = MaBuffer[i] + (MaBuffer[i-n]-MaBuffer[i])*k/n;
         }
      }
   
   return(rates_total);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double getPrice(ENUM_APPLIED_PRICE price, int position)
{
   MqlRates _rates[];

   //
   //
   //
   //
   //
   
      int copyCount = CopyRates(_Symbol,_Period,position,1,_rates);
      if (copyCount==1)
      {
         switch (price)
         {
            case PRICE_CLOSE:    return(_rates[0].close);
            case PRICE_HIGH:     return(_rates[0].high);
            case PRICE_LOW:      return(_rates[0].low);
            case PRICE_OPEN:     return(_rates[0].open);
            case PRICE_MEDIAN:   return((_rates[0].high+_rates[0].low)/2.0);
            case PRICE_TYPICAL:  return((_rates[0].high+_rates[0].low+_rates[0].close)/3.0);
            case PRICE_WEIGHTED: return((_rates[0].high+_rates[0].low+_rates[0].close+_rates[0].close)/4.0);
            default: return(0);
         }            
      }
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int dateArrayBsearch(datetime& times[], datetime toFind, int total)
{
   int mid   = 0;
   int first = 0;
   int last  = total-1;
   
   while (last >= first)
   {
      mid = (first + last) >> 1;
      if (toFind == times[mid] || (mid < (total-1) && (toFind > times[mid]) && (toFind < times[mid+1]))) break;
      if (toFind <  times[mid])
            last  = mid - 1;
      else  first = mid + 1;
   }
   return (mid);
}

//
//
//
//
//

string getIndicatorName()
{
   string progPath     = MQL5InfoString(MQL5_PROGRAM_PATH);
   string terminalPath = TerminalInfoString(TERMINAL_PATH);
   
   int startLength = StringLen(terminalPath)+17;
   int progLength  = StringLen(progPath);
         string indicatorName = StringSubstr(progPath,startLength);
                indicatorName = StringSubstr(indicatorName,0,StringLen(indicatorName)-4);
   return(indicatorName);
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

string methodNames[] = {"SMA","EMA","Double smoothed EMA","Double EMA","Tripple EMA","Smoothed MA","Linear weighted MA","Parabolic weighted MA","Alexander MA","Volume weghted MA","Hull MA","Triangular MA","Sine weighted MA","Linear regression","IE/2","NonLag MA","Zero lag EMA","Leader EMA"};
string getAverageName(int method)
{
   int max = ArraySize(methodNames)-1;
      method = (int)MathMax(MathMin(method,max),0); return(methodNames[method]);
}

//
//
//
//
//

//
//
//
//
//

#define _maWorkBufferx1 1
#define _maWorkBufferx2 2
#define _maWorkBufferx3 3

double iCustomMa(int mode, double price, double length, const long& Volume[], int r, int instanceNo=0)
{
   switch (mode)
   {
      case avgSma   : return(iSma(price,(int)length,r,instanceNo));
      case avgEma   : return(iEma(price,length,r,instanceNo));
      case avgDsema : return(iDsema(price,length,r,instanceNo));
      case avgDema  : return(iDema(price,length,r,instanceNo));
      case avgTema  : return(iTema(price,length,r,instanceNo));
      case avgSmma  : return(iSmma(price,length,r,instanceNo));
      case avgLwma  : return(iLwma(price,length,r,instanceNo));
      case avgPwma  : return(iLwmp(price,length,r,instanceNo));
      case avgAlex  : return(iAlex(price,length,r,instanceNo));
      case avgVwma  : return(iWwma(price,length,Volume,r,instanceNo));
      case avgHull  : return(iHull(price,length,r,instanceNo));
      case avgTma   : return(iTma(price,length,r,instanceNo));
      case avgSine  : return(iSineWMA(price,(int)length,r,instanceNo));
      case avgLsma  : return(iLinr(price,length,r,instanceNo));
      case avgIe2   : return(iIe2(price,length,r,instanceNo));
      case avgNlma  : return(iNonLagMa(price,length,r,instanceNo));
      case avgZlma  : return(iZeroLag(price,length,r,instanceNo));
      case avgLead  : return(iLeader(price,length,r,instanceNo));
      default : return(price);
   }
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double workSma[][_maWorkBufferx2];
double iSma(double price, int period, int r, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= totalBars) ArrayResize(workSma,totalBars); instanceNo *= 2;

   //
   //
   //
   //
   //

   int k;      
   workSma[r][instanceNo] = price;
   if (r>=period)
          workSma[r][instanceNo+1] = workSma[r-1][instanceNo+1]+(workSma[r][instanceNo]-workSma[r-period][instanceNo])/period;
   else { workSma[r][instanceNo+1] = 0; for(k=0; k<period && (r-k)>=0; k++) workSma[r][instanceNo+1] += workSma[r-k][instanceNo];  
          workSma[r][instanceNo+1] /= k; }
   return(workSma[r][instanceNo+1]);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= totalBars) ArrayResize(workEma,totalBars);

   //
   //
   //
   //
   //
      
   double alpha = 2.0 / (1.0+period);
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+alpha*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//
//
//
//
//

double workDsema[][_maWorkBufferx2];
#define _ema1 0
#define _ema2 1
double iDsema(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workDsema,0)!= totalBars) ArrayResize(workDsema,totalBars); instanceNo*=2;

   //
   //
   //
   //
   //
      
   double alpha = 2.0 /(1.0+MathSqrt(period));
          workDsema[r][_ema1+instanceNo] = workDsema[r-1][_ema1+instanceNo]+alpha*(price                         -workDsema[r-1][_ema1+instanceNo]);
          workDsema[r][_ema2+instanceNo] = workDsema[r-1][_ema2+instanceNo]+alpha*(workDsema[r][_ema1+instanceNo]-workDsema[r-1][_ema2+instanceNo]);
   return(workDsema[r][_ema2+instanceNo]);
}

//
//
//
//
//

double workDema[][_maWorkBufferx2];
double iDema(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workDema,0)!= totalBars) ArrayResize(workDema,totalBars); instanceNo*=2;

   //
   //
   //
   //
   //
      
   double alpha = 2.0 / (1.0+period);
          workDema[r][_ema1+instanceNo] = workDema[r-1][_ema1+instanceNo]+alpha*(price                        -workDema[r-1][_ema1+instanceNo]);
          workDema[r][_ema2+instanceNo] = workDema[r-1][_ema2+instanceNo]+alpha*(workDema[r][_ema1+instanceNo]-workDema[r-1][_ema2+instanceNo]);
   return(workDema[r][_ema1+instanceNo]*2.0-workDema[r][_ema2+instanceNo]);
}

//
//
//
//
//

double workTema[][_maWorkBufferx3];
#define _ema3 2
double iTema(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workTema,0)!= totalBars) ArrayResize(workTema,totalBars); instanceNo*=3;

   //
   //
   //
   //
   //
      
   double alpha = 2.0 / (1.0+period);
          workTema[r][_ema1+instanceNo] = workTema[r-1][_ema1+instanceNo]+alpha*(price                        -workTema[r-1][_ema1+instanceNo]);
          workTema[r][_ema2+instanceNo] = workTema[r-1][_ema2+instanceNo]+alpha*(workTema[r][_ema1+instanceNo]-workTema[r-1][_ema2+instanceNo]);
          workTema[r][_ema3+instanceNo] = workTema[r-1][_ema3+instanceNo]+alpha*(workTema[r][_ema2+instanceNo]-workTema[r-1][_ema3+instanceNo]);
   return(workTema[r][_ema3+instanceNo]+3.0*(workTema[r][_ema1+instanceNo]-workTema[r][_ema2+instanceNo]));
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= totalBars) ArrayResize(workSmma,totalBars);

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
double iLwma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLwma,0)!= totalBars) ArrayResize(workLwma,totalBars);
   
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

//
//
//
//
//

double workLwmp[][_maWorkBufferx1];
double iLwmp(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLwmp,0)!= totalBars) ArrayResize(workLwmp,totalBars);
   
   //
   //
   //
   //
   //
   
   workLwmp[r][instanceNo] = price;
      double sumw = period*period;
      double sum  = sumw*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = (period-k)*(period-k);
                sumw  += weight;
                sum   += weight*workLwmp[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workAlex[][_maWorkBufferx1];
double iAlex(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workAlex,0)!= totalBars) ArrayResize(workAlex,totalBars);
   if (period<4) return(price);
   
   //
   //
   //
   //
   //

   workAlex[r][instanceNo] = price;
      double sumw = period-2;
      double sum  = sumw*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k-2;
                sumw  += weight;
                sum   += weight*workAlex[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workTma[][_maWorkBufferx1];
double iTma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workTma,0)!= totalBars) ArrayResize(workTma,totalBars);
   
   //
   //
   //
   //
   //
   
   workTma[r][instanceNo] = price;

      double half = (period+1.0)/2.0;
      double sum  = price;
      double sumw = 1;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = k+1; if (weight > half) weight = period-k;
                sumw  += weight;
                sum   += weight*workTma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workSineWMA[][_maWorkBufferx1];
#define Pi 3.14159265358979323846264338327950288
double iSineWMA(double price, int period, int r, int instanceNo=0)
{
   if (period<1) return(price);
   if (ArrayRange(workSineWMA,0)!= totalBars) ArrayResize(workSineWMA,totalBars);
   
   //
   //
   //
   //
   //
   
   workSineWMA[r][instanceNo] = price;
      double sum  = 0;
      double sumw = 0;
  
      for(int k=0; k<period && (r-k)>=0; k++)
      { 
         double weight = MathSin(Pi*(k+1.0)/(period+1.0));
                sumw  += weight;
                sum   += weight*workSineWMA[r-k][instanceNo]; 
      }
      return(sum/sumw);
}

//
//
//
//
//

double workWwma[][_maWorkBufferx1];
double iWwma(double price, double period,const long& Volume[], int r, int instanceNo=0)
{
   if (ArrayRange(workWwma,0)!= totalBars) ArrayResize(workWwma,totalBars);
   
   //
   //
   //
   //
   //
   
   workWwma[r][instanceNo] = price;
      double sumw = (double)Volume[r];
      double sum  = sumw*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = (double)Volume[r-k];
                sumw  += weight;
                sum   += weight*workWwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//

double workHull[][_maWorkBufferx2];
double iHull(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workHull,0)!= totalBars) ArrayResize(workHull,totalBars);

   //
   //
   //
   //
   //

      int k;
      int HmaPeriod  = (int)MathMax(period,2);
      int HalfPeriod = (int)MathFloor(HmaPeriod/2);
      int HullPeriod = (int)MathFloor(MathSqrt(HmaPeriod));
      double hma,hmw,weight; instanceNo *= 2;

         workHull[r][instanceNo] = price;

         //
         //
         //
         //
         //
               
         hmw = HalfPeriod; hma = hmw*price; 
            for(k=1; k<HalfPeriod && (r-k)>=0; k++)
            {
               weight = HalfPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][instanceNo];  
            }             
            workHull[r][instanceNo+1] = 2.0*hma/hmw;

         hmw = HmaPeriod; hma = hmw*price; 
            for(k=1; k<period && (r-k)>=0; k++)
            {
               weight = HmaPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][instanceNo];
            }             
            workHull[r][instanceNo+1] -= hma/hmw;

         //
         //
         //
         //
         //
         
         hmw = HullPeriod; hma = hmw*workHull[r][instanceNo+1];
            for(k=1; k<HullPeriod && (r-k)>=0; k++)
            {
               weight = HullPeriod-k;
               hmw   += weight;
               hma   += weight*workHull[r-k][1+instanceNo];  
            }
   return(hma/hmw);
}

//
//
//
//
//

double workLinr[][_maWorkBufferx1];
double iLinr(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLinr,0)!= totalBars) ArrayResize(workLinr,totalBars);

   //
   //
   //
   //
   //
   
      period = MathMax(period,1);
      workLinr[r][instanceNo] = price;
         double lwmw = period; double lwma = lwmw*price;
         double sma  = price;
         for(int k=1; k<period && (r-k)>=0; k++)
         {
            double weight = period-k;
                   lwmw  += weight;
                   lwma  += weight*workLinr[r-k][instanceNo];  
                   sma   +=        workLinr[r-k][instanceNo];
         }             
   
   return(3.0*lwma/lwmw-2.0*sma/period);
}

//
//
//
//
//

double workIe2[][_maWorkBufferx1];
double iIe2(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workIe2,0)!= totalBars) ArrayResize(workIe2,totalBars);

   //
   //
   //
   //
   //
   
      period = MathMax(period,1);
      workIe2[r][instanceNo] = price;
         double sumx=0, sumxx=0, sumxy=0, sumy=0;
         for (int k=0; k<period && (r-k)>=0; k++)
         {
            price = workIe2[r-k][instanceNo];
                   sumx  += k;
                   sumxx += k*k;
                   sumxy += k*price;
                   sumy  +=   price;
         }
         double slope   = (period*sumxy - sumx*sumy)/(sumx*sumx-period*sumxx);
         double average = sumy/period;
   return(((average+slope)+(sumy+slope*sumx)/period)/2.0);
}

//
//
//
//
//

double workLeader[][_maWorkBufferx2];
double iLeader(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLeader,0)!= totalBars) ArrayResize(workLeader,totalBars); instanceNo*=2;

   //
   //
   //
   //
   //
   
      period = MathMax(period,1);
      double alpha = 2.0/(period+1.0);
         workLeader[r][instanceNo  ] = workLeader[r-1][instanceNo  ]+alpha*(price                          -workLeader[r-1][instanceNo  ]);
         workLeader[r][instanceNo+1] = workLeader[r-1][instanceNo+1]+alpha*(price-workLeader[r][instanceNo]-workLeader[r-1][instanceNo+1]);

   return(workLeader[r][instanceNo]+workLeader[r][instanceNo+1]);
}

//
//
//
//
//

double workZl[][_maWorkBufferx2];
#define _price 0
#define _zlema 1

double iZeroLag(double price, double length, int r, int instanceNo=0)
{
   if (ArrayRange(workZl,0)!=totalBars) ArrayResize(workZl,totalBars); instanceNo *= 2;

   //
   //
   //
   //
   //

   double alpha = 2.0/(1.0+length); 
   int    per   = (int)((length-1.0)/2.0); 

   workZl[r][_price+instanceNo] = price;
   if (r<per)
          workZl[r][_zlema+instanceNo] = price;
   else   workZl[r][_zlema+instanceNo] = workZl[r-1][_zlema+instanceNo]+alpha*(2.0*price-workZl[r-per][_price+instanceNo]-workZl[r-1][_zlema+instanceNo]);
   return(workZl[r][_zlema+instanceNo]);
}

//
//
//
//
//

#define _length  0
#define _len     1
#define _weight  2

double  nlm_values[3][_maWorkBufferx1];
double  nlm_prices[ ][_maWorkBufferx1];
double  nlm_alphas[ ][_maWorkBufferx1];

//
//
//
//
//

double iNonLagMa(double price, double length, int r, int instanceNo=0)
{
   if (ArrayRange(nlm_prices,0) != totalBars) ArrayResize(nlm_prices,totalBars);
                               nlm_prices[r][instanceNo]=price;
   if (length<3 || r<3) return(nlm_prices[r][instanceNo]);
   
   //
   //
   //
   //
   //
   
   int k;
   if (nlm_values[_length][instanceNo] != length)
   {
      double Cycle = 4.0;
      double Coeff = 3.0*Pi;
      int    Phase = (int)(length-1);
      
         nlm_values[_length][instanceNo] = length;
         nlm_values[_len   ][instanceNo] = length*4 + Phase;  
         nlm_values[_weight][instanceNo] = 0;

         if (ArrayRange(nlm_alphas,0) < nlm_values[_len][instanceNo]) ArrayResize(nlm_alphas,(int)nlm_values[_len][instanceNo]);
         for (k=0; k<nlm_values[_len][instanceNo]; k++)
         {
            double t;
            if (k<=Phase-1) 
                 t = 1.0 * k/(Phase-1);
            else t = 1.0 + (k-Phase+1)*(2.0*Cycle-1.0)/(Cycle*length-1.0); 
            double beta = MathCos(Pi*t);
            double g = 1.0/(Coeff*t+1); if (t <= 0.5 ) g = 1;
      
            nlm_alphas[k][instanceNo]        = g * beta;
            nlm_values[_weight][instanceNo] += nlm_alphas[k][instanceNo];
         }
   }
   
   //
   //
   //
   //
   //
   
   if (nlm_values[_weight][instanceNo]>0)
   {
      double sum = 0;
           for (k=0; k < nlm_values[_len][instanceNo] && (r-k)>=0; k++) sum += nlm_alphas[k][instanceNo]*nlm_prices[r-k][instanceNo];
           return( sum / nlm_values[_weight][instanceNo]);
   }
   else return(0);           
}
