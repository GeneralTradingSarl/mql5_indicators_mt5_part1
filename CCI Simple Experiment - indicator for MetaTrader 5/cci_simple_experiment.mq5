//------------------------------------------------------------------
#property copyright "mladen"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots   5

#property indicator_label1  "CCI fill"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrDodgerBlue,clrSandyBrown
#property indicator_label2  "CCI level up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_DOT
#property indicator_label3  "CCI middle level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSilver
#property indicator_style3  STYLE_DOT
#property indicator_label4  "CCI level down"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrSandyBrown
#property indicator_style4  STYLE_DOT
#property indicator_label5  "CCI"
#property indicator_type5   DRAW_COLOR_LINE
#property indicator_color5  clrSilver,clrDodgerBlue,clrSandyBrown
#property indicator_style5  STYLE_SOLID
#property indicator_width5  2

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

input  int             pperiod       = 50;            // CCI calculating period
input  enPrices        pprice        = pr_close;      // Price
input  int             psmooth       = 32;            // Price smoothing
input  ENUM_MA_METHOD  psmoothMethod = MODE_EMA;      // Price smoothing method
input  int             flLookBack    = 25;            // Floating levels look back period
input  double          flLevelUp     = 90;            // Floating levels up level %
input  double          flLevelDown   = 10;            // Floating levels down level %

double buffer[],levelup[],levelmi[],leveldn[],fill1[],fill2[],prices[],pricer[],trend[];
int _bars;

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
   SetIndexBuffer(2,levelup,INDICATOR_DATA);
   SetIndexBuffer(3,levelmi,INDICATOR_DATA);
   SetIndexBuffer(4,leveldn,INDICATOR_DATA);
   SetIndexBuffer(5,buffer ,INDICATOR_DATA);
   SetIndexBuffer(6,trend  ,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(7,prices ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,pricer ,INDICATOR_CALCULATIONS);
   return(0);
}

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
   _bars = rates_total;
   
   //
   //
   //
   //
   //
   
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total; i++)
   {
      pricer[i] = getPrice(pprice,open,close,high,low,i);
      switch (psmoothMethod)
      {
         case MODE_SMA  : prices[i] = iSma (pricer[i],psmooth,i,0); break;
         case MODE_EMA  : prices[i] = iEma (pricer[i],psmooth,i,0); break;
         case MODE_SMMA : prices[i] = iSmma(pricer[i],psmooth,i,0); break;
         case MODE_LWMA : prices[i] = iLwma(pricer[i],psmooth,i,0); break;
      }
      double noise = 0, vhf = 0, period = pperiod;
      double max = prices[i];
      double min = prices[i];
         for (int k=0; k<pperiod && (i-k-1)>=0; k++)
         {
            noise += MathAbs(pricer[i-k]-pricer[i-k-1]);
            max    = MathMax(pricer[i-k],max);   
            min    = MathMin(pricer[i-k],min);   
         }      
         if (noise>0) vhf = (max-min)/noise;
         if (vhf!=0)
               period = MathCeil(pperiod*(-MathLog(vhf)));
         double avg = 0; for(int k=0; k<(int)period && (i-k)>=0; k++) avg +=         prices[i-k];      avg /= (int)period;
         double dev = 0; for(int k=0; k<(int)period && (i-k)>=0; k++) dev += MathAbs(prices[i-k]-avg); dev /= (int)period;
         if (dev!=0)
               buffer[i] = (prices[i]-avg)/(0.015*dev);
         else  buffer[i] = 0;          

      //
      //
      //
      //
      //
               
      min = buffer[i];
      max = buffer[i];
         for (int k=1; k<flLookBack && i-k>=0; k++)
         {
            min = MathMin(buffer[i-k],min);
            max = MathMax(buffer[i-k],max);
         }
      double range = max-min;
      levelup[i] = min+flLevelUp*range/100.0;
      leveldn[i] = min+flLevelDown*range/100.0;
      levelmi[i] = min+0.5*range;
      
      fill1[i]   = buffer[i];
      fill2[i]   = buffer[i];
      if (buffer[i]>levelup[i]) fill2[i] = levelup[i]; 
      if (buffer[i]<leveldn[i]) fill2[i] = leveldn[i]; 
      trend[i] = 0;
         if (buffer[i]>levelup[i]) trend[i] = 1;
         if (buffer[i]<leveldn[i]) trend[i] = 2;
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

#define _maInstances 1
#define _maWorkBufferx1 1*_maInstances
#define _maWorkBufferx2 2*_maInstances
#define _maWorkBufferx3 3*_maInstances
#define _maWorkBufferx4 4*_maInstances
#define _maWorkBufferx5 5*_maInstances

double workSma[][_maWorkBufferx2];
double iSma(double price, int period, int r, int instanceNo=0)
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
double iEma(double price, double period, int r, int instanceNo=0)
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
double iSmma(double price, double period, int r, int instanceNo=0)
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
double iLwma(double price, double period, int r, int instanceNo=0)
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
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= _bars) ArrayResize(workHa,_bars); int r=i;
         
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