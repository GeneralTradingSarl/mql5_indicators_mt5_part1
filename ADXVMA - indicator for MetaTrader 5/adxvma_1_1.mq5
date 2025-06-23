//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-tsd.com"
#property version   "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1

#property indicator_label1  "Adxvma"
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

input int      AdxVmaPeriod = 14;       // Calculation period
input enPrices AdxvmaPrice  = pr_close; // Price to use

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
   IndicatorSetString(INDICATOR_SHORTNAME,"Adxvma ("+(string)AdxVmaPeriod+")");
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
         double price = getPrice(AdxvmaPrice,open,close,high,low,rates_total,i);
                MaBuffer[i] = iAdxvma(price,AdxVmaPeriod,rates_total,i);
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

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

#define adxvmaInstances 1
double  adxvmaWork[][adxvmaInstances*7];
#define _adxvmaWprc 0
#define _adxvmaWpdm 1
#define _adxvmaWmdm 2
#define _adxvmaWpdi 3
#define _adxvmaWmdi 4
#define _adxvmaWout 5
#define _adxvmaWval 6

double iAdxvma(double price, double period, int bars, int r, int instanceNo=0)
{
   if (ArrayRange(adxvmaWork,0)!=bars) ArrayResize(adxvmaWork,bars); instanceNo*=7;
   
   //
   //
   //
   //
   //
   
   adxvmaWork[r][instanceNo+_adxvmaWprc] = price;
   if (r<1) 
   { 
      adxvmaWork[r][instanceNo+_adxvmaWval] = adxvmaWork[r][instanceNo+_adxvmaWprc]; 
            return(adxvmaWork[r][_adxvmaWval]); 
   }

   //
   //
   //
   //
   //
      
      double tpdm = 0;
      double tmdm = 0;
      double diff = adxvmaWork[r][instanceNo+_adxvmaWprc]-adxvmaWork[r-1][instanceNo+_adxvmaWprc];
      if (diff>0)
            tpdm =  diff;
      else  tmdm = -diff;          
      adxvmaWork[r][instanceNo+_adxvmaWpdm] = ((AdxVmaPeriod-1.0)*adxvmaWork[r-1][instanceNo+_adxvmaWpdm]+tpdm)/AdxVmaPeriod;
      adxvmaWork[r][instanceNo+_adxvmaWmdm] = ((AdxVmaPeriod-1.0)*adxvmaWork[r-1][instanceNo+_adxvmaWmdm]+tmdm)/AdxVmaPeriod;

      //
      //
      //
      //
      //

         double trueRange = adxvmaWork[r][instanceNo+_adxvmaWpdm]+adxvmaWork[r][instanceNo+_adxvmaWmdm];
         double tpdi      = 0;
         double tmdi      = 0;
               if (trueRange>0)
               {
                  tpdi = adxvmaWork[r][instanceNo+_adxvmaWpdm]/trueRange;
                  tmdi = adxvmaWork[r][instanceNo+_adxvmaWmdm]/trueRange;
               }            
         adxvmaWork[r][instanceNo+_adxvmaWpdi] = ((AdxVmaPeriod-1.0)*adxvmaWork[r-1][instanceNo+_adxvmaWpdi]+tpdi)/AdxVmaPeriod;
         adxvmaWork[r][instanceNo+_adxvmaWmdi] = ((AdxVmaPeriod-1.0)*adxvmaWork[r-1][instanceNo+_adxvmaWmdi]+tmdi)/AdxVmaPeriod;
   
         //
         //
         //
         //
         //
                  
         double tout  = 0; 
            if ((adxvmaWork[r][instanceNo+_adxvmaWpdi]+adxvmaWork[r][instanceNo+_adxvmaWmdi])>0) 
                  tout = MathAbs(adxvmaWork[r][instanceNo+_adxvmaWpdi]-adxvmaWork[r][instanceNo+_adxvmaWmdi])/(adxvmaWork[r][instanceNo+_adxvmaWpdi]+adxvmaWork[r][instanceNo+_adxvmaWmdi]);
                                 adxvmaWork[r][instanceNo+_adxvmaWout] = ((AdxVmaPeriod-1.0)*adxvmaWork[r-1][instanceNo+_adxvmaWout]+tout)/AdxVmaPeriod;

         //
         //
         //
         //
         //
                 
         double thi = MathMax(adxvmaWork[r][instanceNo+_adxvmaWout],adxvmaWork[r-1][instanceNo+_adxvmaWout]);
         double tlo = MathMin(adxvmaWork[r][instanceNo+_adxvmaWout],adxvmaWork[r-1][instanceNo+_adxvmaWout]);
            for (int j = 2; j<AdxVmaPeriod && r-j>=0; j++)
            {
               thi = MathMax(adxvmaWork[r-j][instanceNo+_adxvmaWout],thi);
               tlo = MathMin(adxvmaWork[r-j][instanceNo+_adxvmaWout],tlo);
            }            
         double vi = 0; if ((thi-tlo)>0) vi = (adxvmaWork[r][instanceNo+_adxvmaWout]-tlo)/(thi-tlo);

         //
         //
         //
         //
         //
         
          adxvmaWork[r][instanceNo+_adxvmaWval] = ((AdxVmaPeriod-vi)*adxvmaWork[r-1][instanceNo+_adxvmaWval]+vi*adxvmaWork[r][instanceNo+_adxvmaWprc])/AdxVmaPeriod;
   return(adxvmaWork[r][instanceNo+_adxvmaWval]);
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