//+------------------------------------------------------------------+
//|                                             NotifyBefore5Min.mq5 |
//|                                       Copyright 2021, Dark Ryd3r |
//|                                    https://twitter.com/DarkRyd3r |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Dark Ryd3r"
#property link      "https://twitter.com/DarkRyd3r"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

datetime timex[6];
input string info ="Add Closing time -5 minute in HH:MM format (Ignore the date)";
input datetime T0 =  D'1970.01.01 05:25'; // Time 1
input datetime T1 =  D'1970.01.01 09:25'; // Time 2
input datetime T2 =  D'1970.01.01 01:25'; // Time 3
input datetime T3 =  D'1970.01.01 17:25'; // Time 4
input datetime T4 =  D'1970.01.01 21:25'; // Time 5
input datetime T5 =  D'1970.01.01 01:25'; // Time 6

input string message       ="5min remaining in Closing of 4H Candle at"; //Enter your alert message here
input bool   alertsOn      = true;  // Turn alerts on?

input bool   alertsPopup   = true;  // Show Popup Window?
input bool   alertsSound   = false; // Play sound on alerts?
input bool   alertsEmail   = false; // Send email on alerts?
input bool   alertsPrint   = true; // Print the Message?
input bool   alertsPush     = false; // Send Push Notification?
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping

//---
   return(INIT_SUCCEEDED);
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
                const int &spread[]) {
//---

   timex[0] = T0;
   timex[1] = T1;
   timex[2] = T2;
   timex[3] = T3;
   timex[4] = T4;
   timex[5] = T5;

   ArraySize(timex);

   ENUM_TIMEFRAMES tf=PERIOD_M1;
   datetime ClosingTime = iTime(_Symbol,tf,0);
   for(int i=0; i<6; i++) {
      if(TimeToString(ClosingTime,TIME_MINUTES) == TimeToString(timex[i],TIME_MINUTES)) {
         doAlert(time[rates_total-1],"Alert : ");
      }
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
void doAlert(datetime forTime, string doWhat) {
   static string   previousAlert="nothing";
   static datetime previousTime;

   if (previousAlert != doWhat || previousTime != forTime) {
      previousAlert  = doWhat;
      previousTime   = forTime;

      //message = TimeToString(TimeLocal(),TIME_SECONDS)+" "+_Symbol+" 5min Left on Closing of 4H Candle "+doWhat;
      if (alertsPopup)   Alert(message, " : "+TimeToString(TimeLocal(),TIME_SECONDS));
      if (alertsEmail)   SendMail(_Symbol+" : ",message);
      if (alertsSound)   PlaySound("alert.wav");
      if (alertsPrint)   Print(message, " : "+TimeToString(TimeLocal(),TIME_SECONDS));
      if (alertsPush)    SendNotification(message+ " : "+TimeToString(TimeLocal(),TIME_SECONDS));
   }
}
//+------------------------------------------------------------------+
