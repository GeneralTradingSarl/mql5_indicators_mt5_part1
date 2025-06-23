#property copyright "*** Click here for more experts ***"
#property link      "https://www.google.com/search?q=forexeas+payhip&rlz=1C1CHBF_en-GBAU972AU972&sxsrf=APq-WBtD_BRErb2qCXBGJg8Yh8QJmO9hng%3A1647519330253&ei=YiYzYoH9DoK_4-EP78-ZuAw&ved=0ahUKEwiBtsLjj832AhWC3zgGHe9nBscQ4dUDCA4&uact=5&oq=forexeas+payhip&gs_lcp=Cgdnd3Mtd2l6EAMyBQghEKABMgUIIRCgAToHCAAQRxCwAzoICAAQCBANEB46BAgAEA06BggAEA0QHjoHCCEQChCgAUoECEEYAEoECEYYAFCZC1j6GGCuIGgBcAF4AIAB3QKIAYgQkgEFMi00LjOYAQCgAQHIAQjAAQE&sclient=gws-wiz"
#property version   "1.00"
#property description "Forex Experts & Indicators"

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2

#property indicator_type1 DRAW_ARROW
#property indicator_width1 5
#property indicator_color1 0xFFAA00
#property indicator_label1 "Buy"

#property indicator_type2 DRAW_ARROW
#property indicator_width2 5
#property indicator_color2 0x0000FF
#property indicator_label2 "Sell"

//--- indicator buffers
double Buffer1[];
double Buffer2[];

input double Aolvl = 0;
input double rsiupperlimit = 100;
input double rsilowerlimit = 0;
input int rsiperiod = 14;
datetime time_alert; //used when sending alert
input bool Send_Email = true;
input bool Audible_Alerts = true;
input bool Push_Notifications = true;
double myPoint; //initialized in OnInit
int AO_handle;
double AO[];
int RSI_handle;
double RSI[];
double Close[];
double High[];
double Low[];

void myAlert(string type, string message)
  {
   if(type == "print")
      Print(message);
   else if(type == "error")
     {
      Print(type+" | AO oc @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
   else if(type == "order")
     {
     }
   else if(type == "modify")
     {
     }
   else if(type == "indicator")
     {
      if(Audible_Alerts) Alert(type+" | AO oc @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
      if(Send_Email) SendMail("AO oc", type+" | AO oc @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
      if(Push_Notifications) SendNotification(type+" | AO oc @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {   
   SetIndexBuffer(0, Buffer1);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(0, PLOT_ARROW, 241);
   SetIndexBuffer(1, Buffer2);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetInteger(1, PLOT_ARROW, 242);
   //initialize myPoint
   myPoint = Point();
   if(Digits() == 5 || Digits() == 3)
     {
      myPoint *= 10;
     }
   AO_handle = iAO(NULL, PERIOD_CURRENT);
   if(AO_handle < 0)
     {
      Print("The creation of iAO has failed: AO_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }
   
   RSI_handle = iRSI(NULL, PERIOD_CURRENT, rsiperiod, PRICE_CLOSE);
   if(RSI_handle < 0)
     {
      Print("The creation of iRSI has failed: RSI_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }
   
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   int limit = rates_total - prev_calculated;
   //--- counting from 0 to rates_total
   ArraySetAsSeries(Buffer1, true);
   ArraySetAsSeries(Buffer2, true);
   //--- initial zero
   if(prev_calculated < 1)
     {
      ArrayInitialize(Buffer1, EMPTY_VALUE);
      ArrayInitialize(Buffer2, EMPTY_VALUE);
     }
   else
      limit++;
   datetime Time[];
   
   if(BarsCalculated(AO_handle) <= 0) 
      return(0);
   if(CopyBuffer(AO_handle, 0, 0, rates_total, AO) <= 0) return(rates_total);
   ArraySetAsSeries(AO, true);
   if(BarsCalculated(RSI_handle) <= 0) 
      return(0);
   if(CopyBuffer(RSI_handle, 0, 0, rates_total, RSI) <= 0) return(rates_total);
   ArraySetAsSeries(RSI, true);
   if(CopyClose(Symbol(), PERIOD_CURRENT, 0, rates_total, Close) <= 0) return(rates_total);
   ArraySetAsSeries(Close, true);
   if(CopyHigh(Symbol(), PERIOD_CURRENT, 0, rates_total, High) <= 0) return(rates_total);
   ArraySetAsSeries(High, true);
   if(CopyLow(Symbol(), PERIOD_CURRENT, 0, rates_total, Low) <= 0) return(rates_total);
   ArraySetAsSeries(Low, true);
   if(CopyTime(Symbol(), Period(), 0, rates_total, Time) <= 0) return(rates_total);
   ArraySetAsSeries(Time, true);
   //--- main loop
   for(int i = limit-1; i >= 0; i--)
     {
      if (i >= MathMin(5000-1, rates_total-1-50)) continue; //omit some old rates to prevent "Array out of range" or slow calculation   
      
      //Indicator Buffer 1
      if(AO[2+i] > AO[1+i] //Awesome Oscillator > Awesome Oscillator
      && AO[i] > AO[1+i] //Awesome Oscillator > Awesome Oscillator
      && AO[i] > Aolvl //Awesome Oscillator > fixed value
      && RSI[i] < rsiupperlimit //Relative Strength Index < fixed value
      && RSI[i] > rsilowerlimit //Relative Strength Index > fixed value
      && AO[3+i] > AO[2+i] //Awesome Oscillator > Awesome Oscillator
      && Close[i] > High[1+i] //Candlestick Close > Candlestick High
      )
        {
         Buffer1[i] = Low[1+i]; //Set indicator value at Candlestick Low
         if(i == 1 && Time[1] != time_alert) myAlert("indicator", "Buy"); //Alert on next bar open
         time_alert = Time[1];
        }
      else
        {
         Buffer1[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 2
      if(AO[2+i] < AO[1+i] //Awesome Oscillator < Awesome Oscillator
      && AO[i] < AO[1+i] //Awesome Oscillator < Awesome Oscillator
      && AO[i] < Aolvl //Awesome Oscillator < fixed value
      && RSI[i] < rsiupperlimit //Relative Strength Index < fixed value
      && RSI[i] > rsilowerlimit //Relative Strength Index > fixed value
      && AO[3+i] < AO[2+i] //Awesome Oscillator < Awesome Oscillator
      && Close[i] < Low[1+i] //Candlestick Close < Candlestick Low
      )
        {
         Buffer2[i] = High[1+i]; //Set indicator value at Candlestick High
         if(i == 1 && Time[1] != time_alert) myAlert("indicator", "Sell"); //Alert on next bar open
         time_alert = Time[1];
        }
      else
        {
         Buffer2[i] = EMPTY_VALUE;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+