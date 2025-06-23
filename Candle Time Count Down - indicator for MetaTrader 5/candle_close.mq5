//+------------------------------------------------------------------+
//|                                                 Candle Close.mq5 |
//|                                 Copyright 2023, Obunadike Chioma |
//|                                    https://devbidden.netlify.app |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Obunadike Chioma"
#property link      "https://devbidden.netlify.app"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
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
                const int &spread[])
  {
Comment("Current candle to close in: ", main_can());
   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
datetime candl_lef()
  {
   datetime last_tr = iTime(_Symbol, PERIOD_CURRENT, 1);
   datetime c_time = iTime(_Symbol, PERIOD_CURRENT, 0);
   datetime interval = c_time - last_tr;
   datetime next_ = last_tr + interval + interval;
   datetime diff = next_ - TimeCurrent();
   return diff;
  }
//+------------------------------------------------------------------+
string hour()
  {
   MqlDateTime tm;
   TimeToStruct(candl_lef(), tm);
   int hrt = tm.hour;
   string hrt_m = "";
   if(hrt < 10)
     {
      if(hrt == 0)
        {
         hrt_m = "00";
        }
      if(hrt == 1)
        {
         hrt_m = "01";
        }
      if(hrt == 2)
        {
         hrt_m = "02";
        }
      if(hrt == 3)
        {
         hrt_m = "03";
        }
      if(hrt == 4)
        {
         hrt_m = "04";
        }
      if(hrt == 5)
        {
         hrt_m = "05";
        }
      if(hrt == 6)
        {
         hrt_m = "06";
        }
      if(hrt == 7)
        {
         hrt_m = "07";
        }
      if(hrt == 8)
        {
         hrt_m = "08";
        }
      if(hrt == 9)
        {
         hrt_m = "09";
        }
     }
   else
     {
      hrt_m = IntegerToString(hrt);
     }
   return(hrt_m);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string homin()
  {
   MqlDateTime tm;
   TimeToStruct(candl_lef(), tm);
   int hrt = tm.min;
   string hrt_m = "";
   if(hrt < 10)
     {
      if(hrt == 0)
        {
         hrt_m = "00";
        }
      if(hrt == 1)
        {
         hrt_m = "01";
        }
      if(hrt == 2)
        {
         hrt_m = "02";
        }
      if(hrt == 3)
        {
         hrt_m = "03";
        }
      if(hrt == 4)
        {
         hrt_m = "04";
        }
      if(hrt == 5)
        {
         hrt_m = "05";
        }
      if(hrt == 6)
        {
         hrt_m = "06";
        }
      if(hrt == 7)
        {
         hrt_m = "07";
        }
      if(hrt == 8)
        {
         hrt_m = "08";
        }
      if(hrt == 9)
        {
         hrt_m = "09";
        }
     }
   else
     {
      hrt_m = IntegerToString(hrt);
     }
   return(hrt_m);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string secon()
  {
   MqlDateTime tm;
   TimeToStruct(candl_lef(), tm);
   int hrt = tm.sec;
   string hrt_m = "";
   if(hrt < 10)
     {
      if(hrt == 0)
        {
         hrt_m = "00";
        }
      if(hrt == 1)
        {
         hrt_m = "01";
        }
      if(hrt == 2)
        {
         hrt_m = "02";
        }
      if(hrt == 3)
        {
         hrt_m = "03";
        }
      if(hrt == 4)
        {
         hrt_m = "04";
        }
      if(hrt == 5)
        {
         hrt_m = "05";
        }
      if(hrt == 6)
        {
         hrt_m = "06";
        }
      if(hrt == 7)
        {
         hrt_m = "07";
        }
      if(hrt == 8)
        {
         hrt_m = "08";
        }
      if(hrt == 9)
        {
         hrt_m = "09";
        }
     }
   else
     {
      hrt_m = IntegerToString(hrt);
     }
   return(hrt_m);
  }
//+------------------------------------------------------------------+
string main_can()
  {
   return (hour() + ":" + homin() + ":" + secon());
  }
//+------------------------------------------------------------------+
