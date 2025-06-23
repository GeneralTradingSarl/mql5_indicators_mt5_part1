//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_label1  "CCI pre-filtered"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrSilver,clrLimeGreen,clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//
//
//
//
//

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average     // Average (high+low+oprn+close)/4
};
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

input double           CciPeriod   = 14;         // CCI Calculation period
input enPrices         Price       = pr_typical; // CCI Price to use
input int              AvgPeriod   = 5;          // Filtering length
input enumAveragesType AvgMethod   = avgEma;     // Filtering mode
input double           levelUp     =  100;       // Upper level
input double           levelDown   = -100;       // Lower level

//
//
//
//
//
//

double cci[];
double colorBuffer[];
int    totalBars;

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
   SetIndexBuffer(0,cci,INDICATOR_DATA); 
   SetIndexBuffer(1,colorBuffer,INDICATOR_COLOR_INDEX); 
      IndicatorSetInteger(INDICATOR_LEVELS,2);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0,levelDown);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1,levelUp);
      IndicatorSetString(INDICATOR_SHORTNAME,"CCI "+getAverageName(AvgMethod)+" pre-filtered("+(string)CciPeriod+","+(string)AvgPeriod+")");
   return(0);
}

//
//
//
//
//

double prices[];
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

   if (ArraySize(prices)!=rates_total) ArrayResize(prices,rates_total);
   
   //
   //
   //
   //
   //

   totalBars = rates_total;
   for (int i=(int)MathMax(prev_calculated-1,1); i<rates_total; i++)
   {
      prices[i] = iCustomMa(AvgMethod,getPrice(Price,open,close,high,low,i,rates_total),AvgPeriod,tick_volume,i);
         double avg = 0; for(int k=0; k<CciPeriod && (i-k)>=0; k++) avg +=         prices[i-k];      avg /= (double)CciPeriod;
         double dev = 0; for(int k=0; k<CciPeriod && (i-k)>=0; k++) dev += MathAbs(prices[i-k]-avg); dev /= (double)CciPeriod;
            if (dev!=0)
                  cci[i] = (prices[i]-avg)/(0.015*dev);
            else  cci[i] = 0;
         
            //
            //
            //
            //
            //
         
            if (i>0)
            {
               colorBuffer[i] = colorBuffer[i-1];
                  if (cci[i]>levelUp)                     colorBuffer[i] =  1;
                  if (cci[i]<levelDown)                   colorBuffer[i] =  2;
                  if (cci[i]>levelDown && cci[i]<levelUp) colorBuffer[i] =  0;
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

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double getPrice(enPrices price, const double& open[], const double& close[], const double& high[], const double& low[], int i, int bars)
{
   switch (price)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
   }
   return(0);
}
