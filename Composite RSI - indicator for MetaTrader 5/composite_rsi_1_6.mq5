//------------------------------------------------------------------

   #property copyright "mladen"
   #property link      "www.forex-tsd.com"

//------------------------------------------------------------------

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_plots   5

#property indicator_label1  "Composite RSI"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  clrDeepSkyBlue,clrSandyBrown
#property indicator_label2  "CompositeRSI level up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_DOT
#property indicator_label3  "Composite RSI middle level"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSilver
#property indicator_style3  STYLE_DOT
#property indicator_label4  "Composite RSI level down"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrSandyBrown
#property indicator_style4  STYLE_DOT
#property indicator_label5  "Composite RSI"
#property indicator_type5   DRAW_COLOR_LINE
#property indicator_color5  clrSilver,clrDeepSkyBlue,clrSandyBrown
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
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
};
enum enumAveragesType
{
   avgSma,    // Simple moving average
   avgEma,    // Exponential moving average
   avgSmma,   // Smoothed MA
   avgLwma    // Linear weighted MA
};


input ENUM_TIMEFRAMES  TimeFrame         = PERIOD_CURRENT; // Time frame
input int              RsiPeriod         = 14;       // Rsi calculation period
input int              RsiDepth          = 10;       // Rsi calculation depth
input bool             RsiFast           = false;    // Use "fast" claculation
input enPrices         Price             = pr_close; // Price to use
input int              PriceSmooth       = 9;        // Price smoothing period
input enumAveragesType PriceSmoothMethod = avgLwma;  // Price smoothing method
input int              flLookBack        = 25;       // Floating levels look back period
input double           flLevelUp         = 90;       // Floating levels up level %
input double           flLevelDown       = 10;       // Floating levels down level %
input bool             alertsOn          = false;    // Turn alerts on?
input bool             alertsOnCurrent   = true;     // Alert on current bar?
input bool             alertsMessage     = true;     // Display messageas on alerts?
input bool             alertsSound       = false;    // Play sound on alerts?
input bool             alertsEmail       = false;    // Send email on alerts?
input bool             alertsNotify      = false;    // Send push notification on alerts?
input bool             Interpolate       = true;     // Interpolate in multi time frame mode?

//
//
//
//
//

double rsi[],fillup[],filldn[],levelup[],levelmi[],leveldn[],colorBuffer[],count[];
ENUM_TIMEFRAMES timeFrame;

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
   SetIndexBuffer(0,fillup     ,INDICATOR_DATA);
   SetIndexBuffer(1,filldn     ,INDICATOR_DATA);
   SetIndexBuffer(2,levelup    ,INDICATOR_DATA);
   SetIndexBuffer(3,levelmi    ,INDICATOR_DATA);
   SetIndexBuffer(4,leveldn    ,INDICATOR_DATA);
   SetIndexBuffer(5,rsi        ,INDICATOR_DATA);
   SetIndexBuffer(6,colorBuffer,INDICATOR_COLOR_INDEX); 
   SetIndexBuffer(7,count      ,INDICATOR_CALCULATIONS); 
      timeFrame = MathMax(_Period,TimeFrame);
      IndicatorSetString(INDICATOR_SHORTNAME,timeFrameToString(timeFrame)+" Composite RSI ("+string(RsiPeriod)+","+string(RsiDepth)+","+string(PriceSmooth)+")");
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

   if (Bars(_Symbol,_Period)<rates_total) return(-1);

      //
      //
      //
      //
      //

      if (timeFrame!=_Period)
      {
         double result[]; datetime currTime[],nextTime[]; 
         static int indHandle =-1;
                if (indHandle==-1) indHandle = iCustom(_Symbol,timeFrame,getIndicatorName(),PERIOD_CURRENT,RsiPeriod,RsiDepth,RsiFast,Price,PriceSmooth,PriceSmoothMethod,flLookBack,flLevelUp,flLevelDown,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsNotify);
                if (indHandle==-1)                          return(0);
                if (CopyBuffer(indHandle,7,0,1,result)==-1) return(0); 
             
                //
                //
                //
                //
                //
              
                #define _processed EMPTY_VALUE-1
                int i,limit = rates_total-(int)MathMin(result[0]*PeriodSeconds(timeFrame)/PeriodSeconds(_Period),rates_total); 
                for (limit=MathMax(limit,0); limit>0 && !IsStopped(); limit--) if (count[limit]==_processed) break;
                for (i=MathMin(limit,MathMax(prev_calculated-1,0)); i<rates_total && !IsStopped(); i++    )
                {
                   if (CopyBuffer(indHandle,0,time[i],1,result)==-1) break; fillup[i]      = result[0];
                   if (CopyBuffer(indHandle,1,time[i],1,result)==-1) break; filldn[i]      = result[0];
                   if (CopyBuffer(indHandle,2,time[i],1,result)==-1) break; levelup[i]     = result[0];
                   if (CopyBuffer(indHandle,3,time[i],1,result)==-1) break; levelmi[i]     = result[0];
                   if (CopyBuffer(indHandle,4,time[i],1,result)==-1) break; leveldn[i]     = result[0];
                   if (CopyBuffer(indHandle,5,time[i],1,result)==-1) break; rsi[i]         = result[0];
                   if (CopyBuffer(indHandle,6,time[i],1,result)==-1) break; colorBuffer[i] = result[0];
                                                                            count[i]       = _processed;
                   
                   //
                   //
                   //
                   //
                   //
                   
                   if (!Interpolate) continue;  CopyTime(_Symbol,TimeFrame,time[i  ],1,currTime); 
                       if (i<(rates_total-1)) { CopyTime(_Symbol,TimeFrame,time[i+1],1,nextTime); if (currTime[0]==nextTime[0]) continue; }
                       int n,k;
                          for(n=1; (i-n)> 0 && time[i-n] >= currTime[0]; n++) continue;	
                          for(k=1; (i-k)>=0 && k<n; k++)
                          {
                             fillup[i-k]  = fillup[i]  + (fillup[i-n] -fillup[i] )*k/n;
                             filldn[i-k]  = filldn[i]  + (filldn[i-n] -filldn[i] )*k/n;
                             levelup[i-k] = levelup[i] + (levelup[i-n]-levelup[i])*k/n;
                             levelup[i-k] = levelup[i] + (levelup[i-n]-levelup[i])*k/n;
                             leveldn[i-k] = leveldn[i] + (leveldn[i-n]-leveldn[i])*k/n;
                             levelmi[i-k] = levelmi[i] + (levelmi[i-n]-levelmi[i])*k/n;
                             rsi[i-k]     = rsi[i]     + (rsi[i-n]    -rsi[i]    )*k/n;
                          }
                }
                if (i!=rates_total) return(0); return(rates_total);
      }

   //
   //
   //
   //
   //
   
   for (int i=(int)MathMax(prev_calculated-1,0); i<rates_total  && !IsStopped(); i++)
   {
      rsi[i] = iCompRsi(iCustomMa(PriceSmoothMethod,getPrice(Price,open,close,high,low,i,rates_total),PriceSmooth,rates_total,i),RsiPeriod,RsiDepth,RsiFast,rates_total,i,0);
         double min = rsi[i];
         double max = rsi[i];
            for (int k=1; k<flLookBack && i-k>=0; k++)
            {
                  min = MathMin(rsi[i-k],min);
                  max = MathMax(rsi[i-k],max);
            }
         double range = max-min;
         levelup[i] = min+flLevelUp  *range/100.0;
         leveldn[i] = min+flLevelDown*range/100.0;
         levelmi[i] = min+0.5*range;
         fillup[i]  = rsi[i];
         filldn[i]  = MathMin(MathMax(rsi[i],leveldn[i]),levelup[i]);
         colorBuffer[i] = (i>0 && (rsi[i]>levelup[i] || rsi[i]<leveldn[i])) ? (rsi[i]>rsi[i-1]) ? 1 : (rsi[i]<rsi[i-1]) ? 2 : colorBuffer[i-1] : 0; 
   }      
   count[rates_total-1] = MathMax(rates_total-prev_calculated+1,1);
   manageAlerts(time,colorBuffer,rates_total);
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

double workCompRsi[][26];
double iCompRsi(double price, double period, int depth, bool fast, int total, int i, int instanceNo=0)
{
   if (ArrayRange(workCompRsi,0) !=total) ArrayResize(workCompRsi,total);
   
   
      double alpha = 2.0/(1.0 + period);
            if (fast) alpha = 2.0/(2.0 + (period-1.0)/2.0);
      instanceNo *= 26; depth = (int)MathMin(depth,25);
   
   //
   //
   //
   //
   //
   
   double CU = 0;
   double CD = 0;
   for (int k=0; k<=depth; k++)
   {
      if (i == 0)
            workCompRsi[i][instanceNo+k] = price;
      else  workCompRsi[i][instanceNo+k] = workCompRsi[i-1][instanceNo+k]+alpha*(price-workCompRsi[i-1][instanceNo+k]);

      //
      //
      //
      //
      //
         
      price = workCompRsi[i][k+instanceNo];
      if (k>0)
         if (workCompRsi[i][instanceNo+k-1] >= workCompRsi[i][instanceNo+k])
              CU += workCompRsi[i][instanceNo+k-1] - workCompRsi[i][instanceNo+k  ];
         else CD += workCompRsi[i][instanceNo+k  ] - workCompRsi[i][instanceNo+k-1];
   }
   double trsi = 0; if (CU + CD != 0) trsi = CU / (CU + CD); 
   return(trsi);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

#define _maInstances 2
#define _maWorkBufferx1 1*_maInstances
#define _maWorkBufferx2 2*_maInstances

double iCustomMa(int mode, double price, double length, int bars, int r, int instanceNo=0)
{
   switch (mode)
   {
      case avgSma   : return(iSma(price,(int)length,r,bars,instanceNo));
      case avgEma   : return(iEma(price,length,r,bars,instanceNo));
      case avgSmma  : return(iSmma(price,(int)length,r,bars,instanceNo));
      case avgLwma  : return(iLwma(price,(int)length,r,bars,instanceNo));
      default       : return(price);
   }
}

//
//
//
//
//

double workSma[][_maWorkBufferx2];
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
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
double iEma(double price, double period, int r, int _bars, int instanceNo=0)
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
double iSmma(double price, double period, int r, int _bars, int instanceNo=0)
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
double iLwma(double price, double period, int r, int _bars, int instanceNo=0)
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

void manageAlerts(const datetime& time[], double& trend[], int bars)
{
   if (!alertsOn) return;
      int whichBar = bars-1; if (!alertsOnCurrent) whichBar = bars-2; datetime time1 = time[whichBar];
      if (trend[whichBar] != trend[whichBar-1])
      {
         if (trend[whichBar] == 1) doAlert(time1,"up");
         if (trend[whichBar] == 2) doAlert(time1,"down");
      }         
}   

//
//
//
//
//

void doAlert(datetime forTime, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != forTime) 
   {
      previousAlert  = doWhat;
      previousTime   = forTime;

      //
      //
      //
      //
      //

      message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToString(TimeLocal(),TIME_SECONDS)+" composite RSI state changed to "+doWhat;
         if (alertsMessage) Alert(message);
         if (alertsEmail)   SendMail(_Symbol+" composite RSI",message);
         if (alertsNotify)  SendNotification(message);
         if (alertsSound)   PlaySound("alert2.wav");
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
//

double workHa[][4];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int _tbars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= _tbars) ArrayResize(workHa,_tbars); instanceNo*=4;
         
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
            case pr_hatbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
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
      case pr_tbiased2:   
               if (close[i]>open[i]) return(high[i]);
               if (close[i]<open[i]) return(low[i]);
                                     return(close[i]);        
   }
   return(0);
}   

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string getIndicatorName()
{
   string progPath = MQL5InfoString(MQL5_PROGRAM_PATH); int start=-1;
   while (true)
   {
      int foundAt = StringFind(progPath,"\\",start+1);
      if (foundAt>=0) 
               start = foundAt;
      else  break;     
   }
   
   string indicatorName = StringSubstr(progPath,start+1);
          indicatorName = StringSubstr(indicatorName,0,StringLen(indicatorName)-4);
   return(indicatorName);
}

//
//
//
//
//

int    _tfsPer[]={PERIOD_M1,PERIOD_M2,PERIOD_M3,PERIOD_M4,PERIOD_M5,PERIOD_M6,PERIOD_M10,PERIOD_M12,PERIOD_M15,PERIOD_M20,PERIOD_M30,PERIOD_H1,PERIOD_H2,PERIOD_H3,PERIOD_H4,PERIOD_H6,PERIOD_H8,PERIOD_H12,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
string _tfsStr[]={"1 minute","2 minutes","3 minutes","4 minutes","5 minutes","6 minutes","10 minutes","12 minutes","15 minutes","20 minutes","30 minutes","1 hour","2 hours","3 hours","4 hours","6 hours","8 hours","12 hours","daily","weekly","monthly"};
string timeFrameToString(int period)
{
   if (period==PERIOD_CURRENT) 
       period = _Period;   
         int i; for(i=0;i<ArraySize(_tfsPer);i++) if(period==_tfsPer[i]) break;
   return(_tfsStr[i]);   
}