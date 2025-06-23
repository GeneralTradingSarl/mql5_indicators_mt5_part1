//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   2

#property indicator_label1  "Aroon trend"
#property indicator_type1   DRAW_COLOR_BARS
#property indicator_color1  clrDeepSkyBlue,clrBurlyWood
#property indicator_width1  2
#property indicator_label2  "Aroon trend"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrLimeGreen,clrPaleVioletRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

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
enum enStyles
{
   st_automatic, // automatically adjust style
   st_bars,      // view as bars
   st_candles,   // view as candles
   st_line       // view as line
};

input int      AroonPeriod  = 25;             // calculation period
input enPrices PriceHigh    = pr_high;        // Price to use for high
input enPrices PriceLow     = pr_low;         // Price to use for low
input enStyles Style        = st_automatic;   // Style
input color    ColorUp      = clrDeepSkyBlue; // Up color
input color    ColorDown    = clrBurlyWood;   // Up color

//
//
//
//
//
//

double barh[];
double barl[];
double baro[];
double barc[];
double colorBuffer[];
double line[];
double cololBuffer[];
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
   SetIndexBuffer(0,baro,INDICATOR_DATA); 
   SetIndexBuffer(1,barh,INDICATOR_DATA);
   SetIndexBuffer(2,barl,INDICATOR_DATA);
   SetIndexBuffer(3,barc,INDICATOR_DATA);
   SetIndexBuffer(4,colorBuffer,INDICATOR_COLOR_INDEX); 
   SetIndexBuffer(5,line,INDICATOR_DATA); 
   SetIndexBuffer(6,cololBuffer,INDICATOR_COLOR_INDEX); 
   SetIndexBuffer(7,prh ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,prl ,INDICATOR_CALCULATIONS);
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
  
      static bool styleSetUp = false;
      static int  styleInUse = -1;
      static int  styleToUse;
             int  style = (int)ChartGetInteger(0,CHART_MODE,0);
      
      //
      //
      //
      //
      //
      
      if (!styleSetUp || (Style==st_automatic && styleInUse!=style))
      {
         if (Style==st_automatic)
            switch(style)
            {
               case CHART_BARS:    styleToUse = DRAW_COLOR_BARS;    break;
               case CHART_CANDLES: styleToUse = DRAW_COLOR_CANDLES; break;
               case CHART_LINE:    styleToUse = DRAW_COLOR_LINE;    break;
            }
         else
            switch(Style)
            {
               case st_bars:    styleToUse = DRAW_COLOR_BARS;    break;
               case st_candles: styleToUse = DRAW_COLOR_CANDLES; break;
               case st_line:    styleToUse = DRAW_COLOR_LINE;    break;
            }
            styleInUse = style;
            
         //
         //
         //
         //
         //
                     
         if (styleToUse==DRAW_COLOR_LINE)
         {
            PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrNONE);
            PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,clrNONE);
            PlotIndexSetInteger(1,PLOT_LINE_COLOR,0,ColorUp);
            PlotIndexSetInteger(1,PLOT_LINE_COLOR,1,ColorDown);
         }
         else
         {
            PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,ColorUp);
            PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,ColorDown);
            PlotIndexSetInteger(1,PLOT_LINE_COLOR,0,clrNONE);
            PlotIndexSetInteger(1,PLOT_LINE_COLOR,1,clrNONE);
            PlotIndexSetInteger(0,PLOT_DRAW_TYPE,styleToUse);               
         }
      }            

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
         double valueup = 100*(AroonPeriod-max)/AroonPeriod;
         double valuedn = 100*(AroonPeriod-min)/AroonPeriod;
         baro[i] = open[i];
         barc[i] = close[i];
         barh[i] = high[i];         
         barl[i] = low[i];         
         line[i] = close[i];
         if (i>0)
         {
            colorBuffer[i] = colorBuffer[i-1];
            if (valueup>valuedn) { cololBuffer[i]= 0; colorBuffer[i]= 0; }
            if (valueup<valuedn) { cololBuffer[i]= 1; colorBuffer[i]= 1; }
         }                     
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