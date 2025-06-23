//------------------------------------------------------------------
//
//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1

//
//
//
//
//

input color ValuesPositiveColor = MediumSeaGreen; // Color for positive timer values
input color ValuesNegativeColor = PaleVioletRed;  // Color for negative timer values
input int   TimeFontSize        = 10;             // Font size for timer
input int   TimerShift          = 7;              // Timer shift

#define clockName "CandleTimer"
int  atrHandle;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int  OnInit()                   { atrHandle = iATR(NULL,0,30); EventSetTimer(1);  return(0); }
void OnDeinit(const int reason) { EventKillTimer(); }
void OnTimer( )                 { refreshClock();  }
int  OnCalculate(const int rates_total,
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
   refreshClock();
   return(rates_total);
}
void refreshClock()
{
   static bool inRefresh = false;
           if (inRefresh) return;
               inRefresh = true;
                              ShowClock(); ChartRedraw();
               inRefresh=false;
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void ShowClock()
{
   int periodMinutes = periodToMinutes(Period());
   int shift         = periodMinutes*TimerShift*60;
   int currentTime   = (int)TimeCurrent();
   int localTime     = (int)TimeLocal();
   int barTime       = (int)iTime();
   int diff          = (int)MathMax(round((currentTime-localTime)/3600.0)*3600,-24*3600);

   //
   //
   //
   //
   //

      color  theColor;
      string time = getTime(barTime+periodMinutes*60-localTime-diff,theColor);
             time = (TerminalInfoInteger(TERMINAL_CONNECTED)) ? time : time+" x";

      //
      //
      //
      //
      //
                          
      if(ObjectFind(0,clockName) < 0)
         ObjectCreate(0,clockName,OBJ_TEXT,0,barTime+shift,0);
         ObjectSetString(0,clockName,OBJPROP_TEXT,time);
         ObjectSetString(0,clockName,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,clockName,OBJPROP_FONTSIZE,TimeFontSize);
         ObjectSetInteger(0,clockName,OBJPROP_COLOR,theColor);
         if (ChartGetInteger(0,CHART_SHIFT,0)==0 && (shift >=0))
               ObjectSetInteger(0,clockName,OBJPROP_TIME,barTime-shift*3);
         else  ObjectSetInteger(0,clockName,OBJPROP_TIME,barTime+shift);

      //
      //
      //
      //
      //

      double price[]; if (CopyClose(Symbol(),0,0,1,price)<=0) return;
      double atr[];   if (CopyBuffer(atrHandle,0,0,1,atr)<=0) return;
             price[0] += 3.0*atr[0]/4.0;
             
      //
      //
      //
      //
      //

      bool visible = ((ChartGetInteger(0,CHART_VISIBLE_BARS,0)-ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR,0)) > 0);
      if ( visible && price[0]>=ChartGetDouble(0,CHART_PRICE_MAX,0))
            ObjectSetDouble(0,clockName,OBJPROP_PRICE,price[0]-1.5*atr[0]);
      else  ObjectSetDouble(0,clockName,OBJPROP_PRICE,price[0]);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

string getTime(int times, color& theColor)
{
   string stime = "";
   int    seconds;
   int    minutes;
   int    hours;
   
   //
   //
   //
   //
   //
   
   if (times < 0) {
         theColor = ValuesNegativeColor; times = (int)fabs(times); }
   else  theColor = ValuesPositiveColor;
   seconds = (times%60);
   hours   = (times-times%3600)/3600;
   minutes = (times-seconds)/60-hours*60;

   //
   //
   //
   //
   //
   
   if (hours>0)
   if (minutes < 10)
         stime = stime+(string)hours+":0";
   else  stime = stime+(string)hours+":";
         stime = stime+(string)minutes;
   if (seconds < 10)
         stime = stime+":0"+(string)seconds;
   else  stime = stime+":" +(string)seconds;
   return(stime);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

datetime iTime(ENUM_TIMEFRAMES forPeriod=PERIOD_CURRENT)
{
   datetime times[]; if (CopyTime(Symbol(),forPeriod,0,1,times)<=0) return(TimeLocal());
   return(times[0]);
}

//
//
//

int periodToMinutes(int period)
{
   int i;
   static int _per[]={1,2,3,4,5,6,10,12,15,20,30,0x4001,0x4002,0x4003,0x4004,0x4006,0x4008,0x400c,0x4018,0x8001,0xc001};
   static int _min[]={1,2,3,4,5,6,10,12,15,20,30,60,120,180,240,360,480,720,1440,10080,43200};

   if (period==PERIOD_CURRENT) 
       period = Period();   
            for(i=0;i<20;i++) if(period==_per[i]) break;
   return(_min[i]);   
}
