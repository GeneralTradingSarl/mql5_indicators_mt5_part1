//+------------------------------------------------------------------+
//|                                                     averages.mq5 |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"
#property version   "1.00"

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
   avgSmma,   // Smoothed moving average
   avgLwma,   // Linear weighted moving average
   avgLsma,   // Linear regression value
   avgTrima,  // Triangular moving average
   avgSwma,   // Sine weighted moving average
   avgHullma, // Hull moving average
   avgT3ma,   // T3 moving average
   avgQuant   // Qunatiles
};

input ENUM_TIMEFRAMES    TimeFrame     = PERIOD_CURRENT; // Time frame
input ENUM_APPLIED_PRICE Price         = PRICE_CLOSE;    // Apply to 
input int                AveragePeriod = 14;             // Calculation period
input enumAveragesType   AverageType   = 0;              // Calculation type
input string             _             = "";             // T3 parameters (used only if T3 chosen)
input double             T3Hot         = 0.7;            // T3 hot value
input bool               T3Original    = false;          // T3 original Tillson calculation?
input string             __            = "";             // Quantile parameters (used only if Quantiles chosen)
input double             QuantPercent  = 50.0;           // Quantile percent (50 == Median)
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
         string name = getIndicatorName(); mtfHandle = iCustom(NULL,timeFrame,name,PERIOD_CURRENT,Price,AveragePeriod,AverageType,"",T3Hot,T3Original,"",QuantPercent,Multicolor);
      }

   PlotIndexSetString(0,PLOT_LABEL,getAverageName(gAverageType)+" ("+(string)AveragePeriod+")");
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
      static averages caverage; 
      if (AverageType==avgT3ma  && !caverage.T3Initialized)    caverage.setT3Parameters(AveragePeriod,T3Hot,T3Original);
      if (AverageType==avgQuant && !caverage.QuantInitialized) caverage.setQuantParameters(QuantPercent);
      
      //
      //
      //
      //
      //

      for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total; i++)
      {
         double price = getPrice(Price,rates_total-i-1);
            MaBuffer[i] = caverage.calc(NULL,0,AveragePeriod,gAverageType,price,i);
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

string methodNames[] = {"Simple MA","Eexponential MA","Smoothed MA","Liner weighted MA","Linear regression value","Triangular MA","Sine weighted MA","Hull MA","T3 MA","Quantile"};
string getAverageName(enumAveragesType& method)
{
   method=MathMax(MathMin(method,10),0); return(methodNames[method]);
}

//
//
//
//
//

class averages
{
   protected:
      double aResultBuffer[];
      double aPricesBuffer[];
      double t3c1,t3c2,t3c3,t3c4,t3period;
      bool   t3Original;
      double quantPercent;

   //
   //
   //
   //
   //
         
   public :
      bool   T3Initialized;
      bool   QuantInitialized;
      
      //
      //
      //
      //
      //
      
      void   averages() { T3Initialized=false; QuantInitialized=false; };
      double calc(string symbol, ENUM_TIMEFRAMES period, double cPeriod, int cType, double cPrice, int i);
      void   setT3Parameters(double cPeriod, double cT3Hot, bool cT3Original);
      void   setQuantParameters(double cPercent);
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void averages::setQuantParameters(double cPercent)
{
   quantPercent = MathMax(MathMin(cPercent,100),0);
   QuantInitialized = true;            
}
void averages::setT3Parameters(double cPeriod, double cT3Hot, bool cT3Original)
{
   cT3Hot = MathMax(MathMin(cT3Hot,1),0.0001);
   double a    = cT3Hot;
          t3c1 = -a*a*a;
          t3c2 =  3*(a*a+a*a*a);
          t3c3 = -3*(2*a*a+a+a*a*a);
          t3c4 = 1+3*a+a*a*a+3*a*a;
          t3period  = cPeriod; 
            if (!cT3Original) t3period = 1.0 + (t3period-1.0)/2.0;
   T3Initialized = true;            
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//


double averages::calc(string symbol, ENUM_TIMEFRAMES period, double cPeriod, int cType, double cPrice, int i)
{
   if (symbol==NULL) symbol = _Symbol;
   if (period==0)    period = _Period;
   int bars = Bars(symbol,period);
         if (ArrayRange(aPricesBuffer,0)!=bars) ArrayResize(aPricesBuffer,bars);
                        aPricesBuffer[i] = cPrice;
      
   //
   //
   //
   //
   //
   //
      
   switch (cType)
   {
      case avgSma:
      {
         double avg = 0;  int k;
               for (k=0; k<cPeriod && (i-k)>=0; k++ ) avg += aPricesBuffer[i-k];
         return(avg/k);
      }                  
         
      //
      //
      //  
      //
      //
         
      case avgEma:
      {
         if (ArrayRange(aResultBuffer,0)!=bars) ArrayResize(aResultBuffer,bars);
         if (i>0)
                aResultBuffer[i] = aResultBuffer[i-1]+(2/(cPeriod+1))*(cPrice-aResultBuffer[i-1]);
         else   aResultBuffer[i] = aPricesBuffer[i];
         return(aResultBuffer[i]);
      }
         
      //
      //
      //  
      //
      //
         
      case avgSmma:
      {
         if (ArrayRange(aResultBuffer,0)!=bars) ArrayResize(aResultBuffer,bars);
         if (i<=cPeriod)
         {
            double avg = 0;  int k;
            for (k=0; k<cPeriod && (i-k)>=0; k++ ) avg += aPricesBuffer[i-k];
            if (k>0)                                                         
                  aResultBuffer[i] = avg/k;
            else  aResultBuffer[i] = aPricesBuffer[i];
         }
         else   aResultBuffer[i] = (aResultBuffer[i-1]*(cPeriod-1)+aPricesBuffer[i])/cPeriod;
         return(aResultBuffer[i]);
      }                  

      //
      //
      //  
      //
      //
         
      case avgLwma:
      {
         double sum  = 0;
         double sumw = 0;
            for (int k=0; k<cPeriod && (i-k)>=0; k++ )
            {
               double weight =  cPeriod-k;
                      sumw   += weight;
                      sum    += weight*aPricesBuffer[i-k];  
            }             
            if (sumw!=0)
                  return(sum/sumw);
            else  return(EMPTY_VALUE);
      }                  
      
      //
      //
      //
      //
      //
      
      case avgLsma:
      {
         static averages lwma;
         static averages sma;
            return (3*lwma.calc(symbol,period,cPeriod,avgLwma,cPrice,i)-2*sma.calc(symbol,period,cPeriod,avgSma,cPrice,i));
      }
      
      //
      //  
      //
      //
      //
         
      case avgTrima:
      {
         double half = (cPeriod+1.0)/2.0;
         double sum  = 0;
         double sumw = 0;
            for (int k=0; k<cPeriod && (i-k)>=0; k++ )
            {
               double weight =  cPeriod-k;  if (weight > half) weight = cPeriod-k;
                      sumw   += weight;
                      sum    += weight*aPricesBuffer[i-k];  
            }             
            if (sumw!=0)
                  return(sum/sumw);
            else  return(EMPTY_VALUE);
      }                  

      //
      //  
      //
      //
      //
         
      case avgSwma:
      {
         #define Pi 3.14159265358979323846
         double sum  = 0;
         double sumw = 0;
            for (int k=0; k<cPeriod && (i-k)>=0; k++ )
            {
               double weight = MathSin(Pi*(k+1)/(cPeriod+1));
                      sumw   += weight;
                      sum    += weight*aPricesBuffer[i-k];  
            }             
            if (sumw!=0)
                  return(sum/sumw);
            else  return(EMPTY_VALUE);
      }                  
      
      //
      //
      //
      //
      //

      case avgHullma:
      {
         int HalfPeriod = (int)MathFloor(cPeriod/2);
         int HullPeriod = (int)MathFloor(MathSqrt(cPeriod));
            static averages lwma1;
            static averages lwma2;
            static averages lwma3;
            double price1 = lwma1.calc(symbol,period,HalfPeriod,avgLwma,cPrice,i)*2-lwma2.calc(symbol,period,cPeriod,avgLwma,cPrice,i);
            return (lwma3.calc(symbol,period,HullPeriod,avgLwma,price1,i));
      }

      //
      //
      //
      //
      //
      
      case avgQuant:
      {
         static double quantileArray[];
         if (ArraySize(quantileArray)!=cPeriod) ArrayResize(quantileArray,(int)cPeriod);
                     for(int k=0; k<cPeriod && (i-k)>=0; k++) quantileArray[k] = aPricesBuffer[i-k];
         ArraySort(quantileArray);
      
         //
         //
         //
         //
         //
   
         double index = (cPeriod-1)*quantPercent/100.0;
         int    ind   = (int)index;
         double delta = index - ind;
         if (ind == NormalizeDouble(index,5))
               return(            quantileArray[ind]);
         else  return((1.0-delta)*quantileArray[ind]+delta*quantileArray[ind+1]);
      }                  

      //
      //
      //
      //
      //

      case avgT3ma:
      {
        
            static averages ema1; double price1 = ema1.calc(symbol,period,t3period,avgEma,cPrice,i);
            static averages ema2; double price2 = ema2.calc(symbol,period,t3period,avgEma,price1,i);
            static averages ema3; double price3 = ema3.calc(symbol,period,t3period,avgEma,price2,i);
            static averages ema4; double price4 = ema4.calc(symbol,period,t3period,avgEma,price3,i);
            static averages ema5; double price5 = ema5.calc(symbol,period,t3period,avgEma,price4,i);
            static averages ema6; double price6 = ema6.calc(symbol,period,t3period,avgEma,price5,i);
            
         return (t3c1*price6 + t3c2*price5 + t3c3*price4 + t3c4*price3);
      }
   }
   
   //
   //
   //
   //
   //
  
   return(EMPTY_VALUE);
}