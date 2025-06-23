//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------

//
//
//
//
//

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   3

#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrDeepSkyBlue,clrBurlyWood
#property indicator_label1  "Aroon filling"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrSilver
#property indicator_width2  2
#property indicator_label2  "Aroon up"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSilver
#property indicator_width3  2
#property indicator_label3  "Aroon down"
#property indicator_minimum -5
#property indicator_maximum 105
#property indicator_level1  0
#property indicator_level2  100

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

input int      AroonPeriod  = 25;      // calculation period
input enPrices PriceHigh    = pr_high; // Price to use for high
input enPrices PriceLow     = pr_low;  // Price to use for low

//
//
//
//
//
//

double valueup[];
double valuedn[];
double fill1[];
double fill2[];
double prh[],prl[];

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
   SetIndexBuffer(0,fill1  ,INDICATOR_DATA);
   SetIndexBuffer(1,fill2  ,INDICATOR_DATA);
   SetIndexBuffer(2,valueup,INDICATOR_DATA);
   SetIndexBuffer(3,valuedn,INDICATOR_DATA);
   SetIndexBuffer(4,prh ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,prl ,INDICATOR_CALCULATIONS);
      IndicatorSetString(INDICATOR_SHORTNAME,"Aroon ("+DoubleToString(AroonPeriod,0)+")");
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

   //
   //
   //
   //
   //
  
      for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total; i++)
      {
         prh[i] = getPrice(PriceHigh,open,close,high,low,rates_total,i);
         prl[i] = getPrice(PriceLow ,open,close,high,low,rates_total,i);
         double max=0; double maxv=prh[i];
         double min=0; double minv=prl[i];
         for (int k=1; k<=AroonPeriod && (i-k)>=0; k++)
         {
            if (prh[i-k]>maxv) { max=k; maxv = prh[i-k]; }
            if (prl[i-k]<minv) { min=k; minv = prl[i-k]; }
         }
         valueup[i] = 100*(AroonPeriod-max)/AroonPeriod;
         valuedn[i] = 100*(AroonPeriod-min)/AroonPeriod;
         fill1[i]   = valueup[i];
         fill2[i]   = valuedn[i];
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
//


double workHa[][4];
double getPrice(int price, const double& open[], const double& close[], const double& high[], const double& low[], int bars, int i,  int instanceNo=0)
{
  if (price>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= bars) ArrayResize(workHa,bars);
         
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