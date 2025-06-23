//+------------------------------------------------------------------+
//|                                                HourlyBuffers.mq5 |
//|   25  buffers, one for each hour and an hour buffer              |
//+------------------------------------------------------------------+
#property copyright "Sam Beatson, PhD"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#property indicator_chart_window
#property indicator_buffers 25
#property indicator_plots 25

//--- Labels in Data Window
#property indicator_label1  "Hour 00"
#property indicator_label2  "Hour 01"
#property indicator_label3  "Hour 02"
#property indicator_label4  "Hour 03"
#property indicator_label5  "Hour 04"
#property indicator_label6  "Hour 05"
#property indicator_label7  "Hour 06"
#property indicator_label8  "Hour 07"
#property indicator_label9  "Hour 08"
#property indicator_label10 "Hour 09"
#property indicator_label11 "Hour 10"
#property indicator_label12 "Hour 11"
#property indicator_label13 "Hour 12"
#property indicator_label14 "Hour 13"
#property indicator_label15 "Hour 14"
#property indicator_label16 "Hour 15"
#property indicator_label17 "Hour 16"
#property indicator_label18 "Hour 17"
#property indicator_label19 "Hour 18"
#property indicator_label20 "Hour 19"
#property indicator_label21 "Hour 20"
#property indicator_label22 "Hour 21"
#property indicator_label23 "Hour 22"
#property indicator_label24 "Hour 23"
#property indicator_label25 "Hour"

//--- 24 buffers (arrays), one per hour
double hourBuffer0[];
double hourBuffer1[];
double hourBuffer2[];
double hourBuffer3[];
double hourBuffer4[];
double hourBuffer5[];
double hourBuffer6[];
double hourBuffer7[];
double hourBuffer8[];
double hourBuffer9[];
double hourBuffer10[];
double hourBuffer11[];
double hourBuffer12[];
double hourBuffer13[];
double hourBuffer14[];
double hourBuffer15[];
double hourBuffer16[];
double hourBuffer17[];
double hourBuffer18[];
double hourBuffer19[];
double hourBuffer20[];
double hourBuffer21[];
double hourBuffer22[];
double hourBuffer23[];
double hourBuffer[];

int bar_hour;

//+------------------------------------------------------------------+
//| Custom indicator initialization                                  |
//+------------------------------------------------------------------+
int OnInit()
{
   IndicatorSetString(INDICATOR_SHORTNAME, "Hourly Buffers (0/1)");

   // Assign buffers to index, hide from chart, show in Data Window
   SetIndexBuffer(0,  hourBuffer0,  INDICATOR_DATA); 
   SetIndexBuffer(1,  hourBuffer1,  INDICATOR_DATA); 
   SetIndexBuffer(2,  hourBuffer2,  INDICATOR_DATA); 
   SetIndexBuffer(3,  hourBuffer3,  INDICATOR_DATA); 
   SetIndexBuffer(4,  hourBuffer4,  INDICATOR_DATA); 
   SetIndexBuffer(5,  hourBuffer5,  INDICATOR_DATA); 
   SetIndexBuffer(6,  hourBuffer6,  INDICATOR_DATA); 
   SetIndexBuffer(7,  hourBuffer7,  INDICATOR_DATA); 
   SetIndexBuffer(8,  hourBuffer8,  INDICATOR_DATA); 
   SetIndexBuffer(9,  hourBuffer9,  INDICATOR_DATA); 
   SetIndexBuffer(10, hourBuffer10, INDICATOR_DATA); 
   SetIndexBuffer(11, hourBuffer11, INDICATOR_DATA); 
   SetIndexBuffer(12, hourBuffer12, INDICATOR_DATA); 
   SetIndexBuffer(13, hourBuffer13, INDICATOR_DATA); 
   SetIndexBuffer(14, hourBuffer14, INDICATOR_DATA); 
   SetIndexBuffer(15, hourBuffer15, INDICATOR_DATA); 
   SetIndexBuffer(16, hourBuffer16, INDICATOR_DATA); 
   SetIndexBuffer(17, hourBuffer17, INDICATOR_DATA); 
   SetIndexBuffer(18, hourBuffer18, INDICATOR_DATA); 
   SetIndexBuffer(19, hourBuffer19, INDICATOR_DATA); 
   SetIndexBuffer(20, hourBuffer20, INDICATOR_DATA); 
   SetIndexBuffer(21, hourBuffer21, INDICATOR_DATA); 
   SetIndexBuffer(22, hourBuffer22, INDICATOR_DATA); 
   SetIndexBuffer(23, hourBuffer23, INDICATOR_DATA);
   SetIndexBuffer(24, hourBuffer, INDICATOR_DATA);

   for(int i = 0; i < 24; i++)
   {
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_NONE);
      PlotIndexSetInteger(i, PLOT_SHOW_DATA, true);
   }

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| This gets called on new bars or chart refresh                    |
//+------------------------------------------------------------------+
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
    if(rates_total <= 0)
        return(0);

    // We'll recalc from the first unprocessed bar
    int start = (prev_calculated > 0 ? prev_calculated - 1 : 0);

    for(int i = start; i < rates_total; i++)
    {
       // Calculate hour (0..23) for bar i
       bar_hour = (int)((time[i] % 86400) / 3600);
      

       // 1) Set ALL 24 buffers for bar i to 0
       hourBuffer0[i]  = 0.0;
       hourBuffer1[i]  = 0.0;
       hourBuffer2[i]  = 0.0;
       hourBuffer3[i]  = 0.0;
       hourBuffer4[i]  = 0.0;
       hourBuffer5[i]  = 0.0;
       hourBuffer6[i]  = 0.0;
       hourBuffer7[i]  = 0.0;
       hourBuffer8[i]  = 0.0;
       hourBuffer9[i]  = 0.0;
       hourBuffer10[i] = 0.0;
       hourBuffer11[i] = 0.0;
       hourBuffer12[i] = 0.0;
       hourBuffer13[i] = 0.0;
       hourBuffer14[i] = 0.0;
       hourBuffer15[i] = 0.0;
       hourBuffer16[i] = 0.0;
       hourBuffer17[i] = 0.0;
       hourBuffer18[i] = 0.0;
       hourBuffer19[i] = 0.0;
       hourBuffer20[i] = 0.0;
       hourBuffer21[i] = 0.0;
       hourBuffer22[i] = 0.0;
       hourBuffer23[i] = 0.0;
       hourBuffer[i] = EMPTY_VALUE;

       // 2) Now set ONLY the matching buffer to 1
       switch (bar_hour)
       {
         case 0:  hourBuffer0[i]  = 1.0; hourBuffer[i] = bar_hour; break;
         case 1:  hourBuffer1[i]  = 1.0; hourBuffer[i] = bar_hour; break;
         case 2:  hourBuffer2[i]  = 1.0; hourBuffer[i] = bar_hour; break;
         case 3:  hourBuffer3[i]  = 1.0; hourBuffer[i] = bar_hour; break;
         case 4:  hourBuffer4[i]  = 1.0; hourBuffer[i] = bar_hour; break;
         case 5:  hourBuffer5[i]  = 1.0; hourBuffer[i] = bar_hour; break;
         case 6:  hourBuffer6[i]  = 1.0; hourBuffer[i] = bar_hour; break;
         case 7:  hourBuffer7[i]  = 1.0; hourBuffer[i] = bar_hour; break;
         case 8:  hourBuffer8[i]  = 1.0; hourBuffer[i] = bar_hour; break;
         case 9:  hourBuffer9[i]  = 1.0; hourBuffer[i] = bar_hour; break;
         case 10: hourBuffer10[i] = 1.0; hourBuffer[i] = bar_hour; break;
         case 11: hourBuffer11[i] = 1.0; hourBuffer[i] = bar_hour; break;
         case 12: hourBuffer12[i] = 1.0; hourBuffer[i] = bar_hour; break;
         case 13: hourBuffer13[i] = 1.0; hourBuffer[i] = bar_hour; break;
         case 14: hourBuffer14[i] = 1.0; hourBuffer[i] = bar_hour; break;
         case 15: hourBuffer15[i] = 1.0; hourBuffer[i] = bar_hour; break;
         case 16: hourBuffer16[i] = 1.0; hourBuffer[i] = bar_hour; break;
         case 17: hourBuffer17[i] = 1.0; hourBuffer[i] = bar_hour; break;
         case 18: hourBuffer18[i] = 1.0; hourBuffer[i] = bar_hour; break;
         case 19: hourBuffer19[i] = 1.0; hourBuffer[i] = bar_hour; break;
         case 20: hourBuffer20[i] = 1.0; hourBuffer[i] = bar_hour; break;
         case 21: hourBuffer21[i] = 1.0; hourBuffer[i] = bar_hour; break;
         case 22: hourBuffer22[i] = 1.0; hourBuffer[i] = bar_hour; break;
         case 23: hourBuffer23[i] = 1.0; hourBuffer[i] = bar_hour; break;
       }
       
      string localHourText = HourToText(bar_hour);
      Comment("The hour is: ", localHourText);
    }

    // Return number of bars processed
    return(rates_total);
}

string HourToText(int bh) {
string TextHour;

switch(bh)
{
   case 0:
      TextHour = "12 am"; // midnight hour in 12-hour format
      break;

   case 1:
      TextHour = "1 am";
      break;

   case 2:
      TextHour = "2 am";
      break;

   case 3:
      TextHour = "3 am";
      break;

   case 4:
      TextHour = "4 am";
      break;

   case 5:
      TextHour = "5 am";
      break;

   case 6:
      TextHour = "6 am";
      break;

   case 7:
      TextHour = "7 am";
      break;

   case 8:
      TextHour = "8 am";
      break;

   case 9:
      TextHour = "9 am";
      break;

   case 10:
      TextHour = "10 am";
      break;

   case 11:
      TextHour = "11 am";
      break;

   case 12:
      TextHour = "12 pm"; // noon hour in 12-hour format
      break;

   case 13:
      TextHour = "1 pm";
      break;

   case 14:
      TextHour = "2 pm";
      break;

   case 15:
      TextHour = "3 pm";
      break;

   case 16:
      TextHour = "4 pm";
      break;

   case 17:
      TextHour = "5 pm";
      break;

   case 18:
      TextHour = "6 pm";
      break;

   case 19:
      TextHour = "7 pm";
      break;

   case 20:
      TextHour = "8 pm";
      break;

   case 21:
      TextHour = "9 pm";
      break;

   case 22:
      TextHour = "10 pm";
      break;

   case 23:
      TextHour = "11 pm";
      break;

   default:
      // Just in case 'bh' is out of range (0..23)
      TextHour = "Unknown";
      break;
}

return TextHour;
}