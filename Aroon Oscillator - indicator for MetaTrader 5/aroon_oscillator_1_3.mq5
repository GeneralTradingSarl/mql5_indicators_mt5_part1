//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   3
#property indicator_label1  "Aroon"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'255,230,230'
#property indicator_label2  "Aroon"
#property indicator_type2   DRAW_FILLING
#property indicator_color2  C'219,247,219'
#property indicator_label3  "Aroon oscillator"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  C'98,217,98',C'255,100,40'
#property indicator_style3  STYLE_SOLID
#property indicator_width3  3
#property indicator_minimum -101
#property indicator_maximum  101

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
enum enFilterWhat
{
   flt_prc, // Filter the price
   flt_val, // Filter the Aroon value
   flt_both // Filter price and the Aroon value
};

input int          AroonPeriod   = 25;       // Aroon period
input double       Filter        = 50;       // Level filter value
input enPrices     PriceHigh     = pr_high;  // Price to use for high
input enPrices     PriceLow      = pr_low;   // Price to use for low
input double       pFilter       = 0;        // Filter to apply to prices or Aroon values
input int          pFilterPeriod = 0;        // Filter period (<=0 for using Aroon period)
input enFilterWhat pFilterWhat   = flt_val;  // Filter what?

double osc[],oscc[];
double filuu[],filud[],fildu[],fildd[];
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
   SetIndexBuffer(0,filuu,INDICATOR_DATA); SetIndexBuffer(1,filud,INDICATOR_DATA);
   SetIndexBuffer(2,fildu,INDICATOR_DATA); SetIndexBuffer(3,fildd,INDICATOR_DATA);
   SetIndexBuffer(4,osc ,INDICATOR_DATA);  SetIndexBuffer(5,oscc ,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,prh ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,prl ,INDICATOR_CALCULATIONS);
      for (int i=0; i<2; i++)  PlotIndexSetInteger(i,PLOT_SHOW_DATA,false);
      IndicatorSetInteger(INDICATOR_LEVELS,2);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,0, Filter);
      IndicatorSetDouble(INDICATOR_LEVELVALUE,1,-Filter);
      IndicatorSetString(INDICATOR_SHORTNAME,"Arron oscillator("+DoubleToString(AroonPeriod,0)+")");
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
   //
   //
   //
   //
   //
   
   int tperiod = pFilterPeriod; if (tperiod<=0) tperiod = AroonPeriod;
   double pfilter = pFilter; if (pFilterWhat==flt_val) pfilter = 0;
   double vfilter = pFilter; if (pFilterWhat==flt_prc) vfilter = 0;
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total; i++)
   {
      prh[i] = iFilter(getPrice(PriceHigh,open,close,high,low,rates_total,i),pfilter,tperiod,i,rates_total,0);
      prl[i] = iFilter(getPrice(PriceLow ,open,close,high,low,rates_total,i),pfilter,tperiod,i,rates_total,1);
      double max = prh[i]; double maxi = 0;
      double min = prl[i];  double mini = 0;
             for (int k=1; k<=AroonPeriod && (i-k)>=0; k++)
             {
                if (max<prh[i-k]) { maxi=k; max = prh[i-k]; }
                if (min>prl[i-k]) { mini=k; min = prl[i-k]; }
             }                  
      osc[i]   = iFilter(100.0*(mini-maxi)/(double)AroonPeriod,vfilter,tperiod,i,rates_total,2);
      filuu[i] =  100; filud[i] = osc[i];
      fildd[i] = -100; fildu[i] = osc[i];
      if (i>0) oscc[i] = (osc[i]<osc[i-1]) ? 1 : (osc[i]>osc[i-1]) ? 0 : (oscc[i-1]);
   }
   return(rates_total);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

#define filterInstances 3
double workFil[][filterInstances*3];

#define _fchange 0
#define _fachang 1
#define _fprice  2

double iFilter(double tprice, double filter, int period, int i, int bars, int instanceNo=0)
{
   if (filter<=0) return(tprice);
   if (ArrayRange(workFil,0)!= bars) ArrayResize(workFil,bars); instanceNo*=3;
   
   //
   //
   //
   //
   //
   
   workFil[i][instanceNo+_fprice]  = tprice; if (i<1) return(tprice);
   workFil[i][instanceNo+_fchange] = MathAbs(workFil[i][instanceNo+_fprice]-workFil[i-1][instanceNo+_fprice]);
   workFil[i][instanceNo+_fachang] = workFil[i][instanceNo+_fchange];

   for (int k=1; k<period && (i-k)>=0; k++) workFil[i][instanceNo+_fachang] += workFil[i-k][instanceNo+_fchange];
                                            workFil[i][instanceNo+_fachang] /= period;
    
   double stddev = 0; for (int k=0;  k<period && (i-k)>=0; k++) stddev += MathPow(workFil[i-k][instanceNo+_fchange]-workFil[i-k][instanceNo+_fachang],2);
          stddev = MathSqrt(stddev/(double)period); 
   double filtev = filter * stddev;
   if( MathAbs(workFil[i][instanceNo+_fprice]-workFil[i-1][instanceNo+_fprice]) < filtev ) workFil[i][instanceNo+_fprice]=workFil[i-1][instanceNo+_fprice];
        return(workFil[i][instanceNo+_fprice]);
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