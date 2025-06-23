//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-tsd.com"
#property version   "1.1"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1

#property indicator_label1  "Alma"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDeepSkyBlue,clrSandyBrown
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
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased   // Heiken ashi trend biased price
};

input int      AlmaPeriod = 14;       // Calculation period
input enPrices AlmaPrice  = pr_close; // Price to use
input double   AlmaSigma  = 6.0;      // Alma sigma
input double   AlmaSample = 0.25;     // Alma sample

//
//
//
//
//
//

double MaBuffer[];
double ColorBuffer[];

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
   IndicatorSetString(INDICATOR_SHORTNAME,"Alma ("+(string)AlmaPeriod+","+(string)AlmaSigma+(string)AlmaSample+")");
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

int totalBars;
int OnCalculate(const int rates_total,const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
{
   totalBars = rates_total;
   
   //
   //
   //
   //
   //
      
      for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
      {
         double price = getPrice(AlmaPrice,open,close,high,low,rates_total,i);
                MaBuffer[i] = iAlma(price,AlmaPeriod,AlmaSigma,AlmaSample,rates_total,i);
         if (i>0)
         {
            ColorBuffer[i] = ColorBuffer[i-1];
               if (MaBuffer[i]>MaBuffer[i-1]) ColorBuffer[i]=0;
               if (MaBuffer[i]<MaBuffer[i-1]) ColorBuffer[i]=1;
         }
         else ColorBuffer[i]=0;
      }
   
   //
   //
   //
   //
   //
   
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

#define almaInstances 1
double  almaWork[][almaInstances];
double iAlma(double price, int period, double sigma, double sample, int bars, int r, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(almaWork,0)!=bars) ArrayResize(almaWork,bars); almaWork[r][instanceNo] = price;
   
   //
   //
   //
   //
   //

   double m = MathFloor(sample * (period - 1.0));
   double s = period/sigma, sum=0, div=0;
   for (int i=0; i<period && (r-i)>=0; i++)
      {
         double coeff = MathExp(-((i-m)*(i-m))/(2.0*s*s));
            sum += coeff*almaWork[r-i][instanceNo];
            div += coeff;
      }
   double talma = price; if (div!=0) talma = sum/div;
   return(talma);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
//


double workHa[][4];
double getPrice(int price, const double& open[], const double& close[], const double& high[], const double& low[], int bars, int i,  int instanceNo=0)
{
  if (price>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= bars) ArrayResize(workHa,bars); instanceNo *= 4;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (i>0)
                haOpen  = (workHa[i-1][instanceNo+2] + workHa[i-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[i][instanceNo+0] = haLow;  workHa[i][instanceNo+1] = haHigh; } 
         else                 { workHa[i][instanceNo+0] = haHigh; workHa[i][instanceNo+1] = haLow;  } 
                                workHa[i][instanceNo+2] = haOpen;
                                workHa[i][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (price)
         {
            case pr_haclose:     return(haClose);
            case pr_haopen:      return(haOpen);
            case pr_hahigh:      return(haHigh);
            case pr_halow:       return(haLow);
            case pr_hamedian:    return((haHigh+haLow)/2.0);
            case pr_hamedianb:   return((haOpen+haClose)/2.0);
            case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (price)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:   
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
   }
   return(0);
}