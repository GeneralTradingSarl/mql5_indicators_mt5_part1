//+------------------------------------------------------------------+
//| Candle Closing Time Remaining-(CCTR).mq5                         |
//| Copyright 2013-2018,Foad Tahmasebi                               |
//| Version 3.0                                                      |                                                  |
//+------------------------------------------------------------------+

#property copyright "Copyright 2013-2018,Foad Tahmasebi"
#property version   "3.0"
#property indicator_chart_window
#property indicator_plots 0
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum lctn
  {
   l1=CORNER_LEFT_UPPER,// Top-Left
   l2=CORNER_RIGHT_UPPER,// Top-Right
   l3=CORNER_LEFT_LOWER, // Bottom-Left
   l4=CORNER_RIGHT_LOWER,// Bottom-Right
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum onoff
  {
   on=1,// On
   off=0,// Off
  };

//--- input parameters
input lctn           location=l1; // Lable Location
input onoff displayServerTime=on; // Display Server Time
input onoff         playAlert=off; // Sound alert when the candle is closed
input string customAlertSound=""; // Custom alert sound
input int            fontSize=9; // Font Size
input color            colour=Silver; // Colour

//--- variables
int leftTime;
string sTime;
int days;
string sCurrentTime;
bool alert_played=false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

   if(location!=l1)
     {
      if(ObjectCreate(0,"CandleClosingTimeRemaining-CCTR",OBJ_LABEL,0,0,0))
        {
         ObjectSetInteger(0,"CandleClosingTimeRemaining-CCTR",OBJPROP_CORNER,location);
         switch(location)
           {
            case l2:
               ObjectSetInteger(0,"CandleClosingTimeRemaining-CCTR",OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
               break;
            case l3:
               ObjectSetInteger(0,"CandleClosingTimeRemaining-CCTR",OBJPROP_ANCHOR,ANCHOR_LEFT_LOWER);
               break;
            case l4:
               ObjectSetInteger(0,"CandleClosingTimeRemaining-CCTR",OBJPROP_ANCHOR,ANCHOR_RIGHT_LOWER);
               break;
           }

         ObjectSetInteger(0,"CandleClosingTimeRemaining-CCTR",OBJPROP_XDISTANCE,5);
         ObjectSetInteger(0,"CandleClosingTimeRemaining-CCTR",OBJPROP_YDISTANCE,3);

         ObjectSetString(0,"CandleClosingTimeRemaining-CCTR",OBJPROP_FONT,"verdana");
         ObjectSetInteger(0,"CandleClosingTimeRemaining-CCTR",OBJPROP_COLOR,colour);

        }
      else
        {
         printf("Failed to create the object OBJ_LABEL CandleClosingTimeRemaining-CCTR, Error code = ",GetLastError());
        }
     }

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   ObjectDelete(0,"CandleClosingTimeRemaining-CCTR");
   Comment(" ");

  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {

   sCurrentTime=TimeToString(TimeCurrent(),TIME_SECONDS);
   ArraySetAsSeries(time,true);

   leftTime=PeriodSeconds(Period())-(int)(TimeCurrent()-time[0]);

   if(playAlert==1 && !alert_played && leftTime<=5)
     {
      if(customAlertSound!="")
        {
         PlaySound(customAlertSound);
           }else{
         PlaySound("alert2.wav");
        }
      alert_played=true;
     }

   if(leftTime>5)
     {
      alert_played=false;
     }

   sTime=TimeToString(leftTime,TIME_SECONDS);
   if(DayOfWeek()==0 || DayOfWeek()==6)
     {
      if(location==0)
        {
         Comment("CCTR: "+"Market Is Closed");
           }else{
         ObjectSetString(0,"CandleClosingTimeRemaining-CCTR",OBJPROP_TEXT,OBJ_LABEL,"Market Is Closed");
        }
        }else{
      if(Period()==PERIOD_MN1 || Period()==PERIOD_W1)
        {
         days=((leftTime/60)/60)/24;
         if(location==0)
           {
            if(!displayServerTime)
              {
               Comment("CCTR: "+(string)days+"D - "+sTime);
                 }else{
               Comment("CCTR: "+(string)days+"D - "+sTime+" ["+sCurrentTime+"]");
              }
              }else{
            if(!displayServerTime)
              {
               ObjectSetString(0,"CandleClosingTimeRemaining-CCTR",OBJPROP_TEXT,OBJ_LABEL,(string)days+"D - "+sTime);

                 }else{
               ObjectSetString(0,"CandleClosingTimeRemaining-CCTR",OBJPROP_TEXT,OBJ_LABEL,(string)days+"D - "+sTime+" ["+sCurrentTime+"]");

              }
           }
           }else{
         if(location==0)
           {
            if(!displayServerTime)
              {
               Comment("CCTR: "+sTime);
                 }else{
               Comment("CCTR: "+sTime+" ["+sCurrentTime+"]");
              }
              }else{
            if(!displayServerTime)
              {
               ObjectSetString(0,"CandleClosingTimeRemaining-CCTR",OBJPROP_TEXT,OBJ_LABEL,sTime);

                 }else{
               ObjectSetString(0,"CandleClosingTimeRemaining-CCTR",OBJPROP_TEXT,OBJ_LABEL,sTime+" ["+sCurrentTime+"]");

              }
           }
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+

int DayOfWeek()
  {
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.day_of_week);
  }
//+------------------------------------------------------------------+
