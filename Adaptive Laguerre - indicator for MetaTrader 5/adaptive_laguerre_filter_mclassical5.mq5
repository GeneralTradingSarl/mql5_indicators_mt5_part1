//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_label1  "Laguerre filter"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrLimeGreen,clrOrange
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
input int      LookBack = 20;       // Lookback period
input enPrices Price    = pr_close; // Price to use
input int      Median   = 5;        // Median for adapting

//
//
//
//
//
//

double lf[];
double colorBuffer[];
double diff[];

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
   SetIndexBuffer(0,lf,INDICATOR_DATA); 
   SetIndexBuffer(1,colorBuffer,INDICATOR_COLOR_INDEX); 
   SetIndexBuffer(2,diff,INDICATOR_CALCULATIONS); 
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

double sortDiff[];
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
      if (ArraySize(sortDiff)!=Median)  ArrayResize(sortDiff,Median);

   //
   //
   //
   //
   //

   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total && !IsStopped(); i++)
   {
      double price = getPrice(Price,open,close,high,low,i,rates_total);
      if (i>0) 
              diff[i] = MathAbs(price-lf[i-1]);
      else  { diff[i] = 0; lf[i] = price; continue; }
         double hi  = diff[i];
         double lo  = diff[i];
            for (int j=1; j<LookBack && (i-j)>=0; j++) 
            {
               hi = MathMax(hi,diff[i-j]);
               lo = MathMin(lo,diff[i-j]);
            }
         double alpha = 0;
         if (hi!=lo)    
         {
            for (int j=0; j<Median && (i-j)>=0; j++) sortDiff[j] = (diff[i-j]-lo)/(hi-lo);
            ArraySort(sortDiff);
               if (MathMod(Median,2.0) != 0) alpha =  sortDiff[Median/2];         
               else                          alpha = (sortDiff[Median/2]+sortDiff[(Median/2)-1])/2;
         }

      //
      //
      //
      //
      //
      
      lf[i] = iLaGuerreFilter(price,1-alpha,rates_total,i,0);
      if (i>0)
      {
         colorBuffer[i] = colorBuffer[i-1];
             if (lf[i] > lf[i-1]) colorBuffer[i]= 0;
             if (lf[i] < lf[i-1]) colorBuffer[i]= 1;
      }             
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

double workLagFil[][4];
double iLaGuerreFilter(double price, double gamma, int bars, int i, int instanceNo=0)
{
   if (ArrayRange(workLagFil,0)!=bars) ArrayResize(workLagFil,bars); instanceNo*=4;
   if (price==EMPTY_VALUE) return(0);
   if (gamma<=0) return(price);

   //
   //
   //
   //
   //


   if (i>0)
   {
      workLagFil[i][instanceNo+0] = (1.0 - gamma)*price                                                + gamma*workLagFil[i-1][instanceNo+0];
	   workLagFil[i][instanceNo+1] = -gamma*workLagFil[i][instanceNo+0] + workLagFil[i-1][instanceNo+0] + gamma*workLagFil[i-1][instanceNo+1];
	   workLagFil[i][instanceNo+2] = -gamma*workLagFil[i][instanceNo+1] + workLagFil[i-1][instanceNo+1] + gamma*workLagFil[i-1][instanceNo+2];
	   workLagFil[i][instanceNo+3] = -gamma*workLagFil[i][instanceNo+2] + workLagFil[i-1][instanceNo+2] + gamma*workLagFil[i-1][instanceNo+3];
   }
   else
   {
      workLagFil[i][instanceNo+0] = price;
      workLagFil[i][instanceNo+1] = price;
      workLagFil[i][instanceNo+2] = price;
      workLagFil[i][instanceNo+3] = price;
   }	   

   //
   //
   //
   //
   //
 
   return((workLagFil[i][instanceNo+0]+2.0*workLagFil[i][instanceNo+1]+2.0*workLagFil[i][instanceNo+2]+workLagFil[i][instanceNo+3])/6.0);
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

#define priceInstances 1
double workHa[][priceInstances*4];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i,int _bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= _bars) ArrayResize(workHa,_bars); int r=i; instanceNo*=4;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (r>0)
                haOpen  = (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; } 
         else                 { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  } 
                                workHa[r][instanceNo+2] = haOpen;
                                workHa[r][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (tprice)
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
   
   switch (tprice)
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