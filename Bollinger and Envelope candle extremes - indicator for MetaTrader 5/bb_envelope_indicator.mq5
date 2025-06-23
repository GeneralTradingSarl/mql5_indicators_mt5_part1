
#property copyright "https://www.mql5.com/en/users/paultraderone/seller"
#property link      "https://www.mql5.com/en/users/paultraderone/seller"
#property version   "1.00"
#property description "Vist Mql4 Mql5 website market here for more"

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2

#property indicator_type1 DRAW_ARROW
#property indicator_width1 4
#property indicator_color1 0xBBFF00
#property indicator_label1 "Buy"

#property indicator_type2 DRAW_ARROW
#property indicator_width2 4
#property indicator_color2 0x2207EB
#property indicator_label2 "sell"

//--- indicator buffers
double Buffer1[];
double Buffer2[];

input int bbperiod = 20;
input double bbDeviations = 2;
input int envelopeperiod = 14;
input double envelopeDeviation = 0.5;
datetime time_alert; //used when sending alert
input bool Send_Email = true;
input bool Audible_Alerts = true;
input bool Push_Notifications = true;
double myPoint; //initialized in OnInit
double Open[];
int Bands_handle;
double Bands_Lower[];
double Close[];
int Envelopes_handle;
double Envelopes_Lower[];
double Low[];
double Bands_Upper[];
double Envelopes_Upper[];
double High[];

void myAlert(string type, string message)
  {
   int handle;
   if(type == "print")
      Print(message);
   else if(type == "error")
     {
      Print(type+" | bb envelope ind @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
   else if(type == "order")
     {
     }
   else if(type == "modify")
     {
     }
   else if(type == "indicator")
     {
      Print(type+" | bb envelope ind @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
      if(Audible_Alerts) Alert(type+" | bb envelope ind @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
      if(Send_Email) SendMail("bb envelope ind", type+" | bb envelope ind @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
      handle = FileOpen("bb envelope ind.txt", FILE_TXT|FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_SHARE_WRITE, ';');
      if(handle != INVALID_HANDLE)
        {
         FileSeek(handle, 0, SEEK_END);
         FileWrite(handle, type+" | bb envelope ind @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
         FileClose(handle);
        }
      if(Push_Notifications) SendNotification(type+" | bb envelope ind @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
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
   Bands_handle = iBands(NULL, PERIOD_CURRENT, bbperiod, 0, bbDeviations, PRICE_CLOSE);
   if(Bands_handle < 0)
     {
      Print("The creation of iBands has failed: Bands_handle=", INVALID_HANDLE);
      Print("Runtime error = ", GetLastError());
      return(INIT_FAILED);
     }
   
   Envelopes_handle = iEnvelopes(NULL, PERIOD_CURRENT, envelopeperiod, 0, MODE_SMA, PRICE_CLOSE, envelopeDeviation);
   if(Envelopes_handle < 0)
     {
      Print("The creation of iEnvelopes has failed: Envelopes_handle=", INVALID_HANDLE);
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
   
   if(CopyOpen(Symbol(), PERIOD_CURRENT, 0, rates_total, Open) <= 0) return(rates_total);
   ArraySetAsSeries(Open, true);
   if(BarsCalculated(Bands_handle) <= 0) 
      return(0);
   if(CopyBuffer(Bands_handle, LOWER_BAND, 0, rates_total, Bands_Lower) <= 0) return(rates_total);
   ArraySetAsSeries(Bands_Lower, true);
   if(CopyClose(Symbol(), PERIOD_CURRENT, 0, rates_total, Close) <= 0) return(rates_total);
   ArraySetAsSeries(Close, true);
   if(BarsCalculated(Envelopes_handle) <= 0) 
      return(0);
   if(CopyBuffer(Envelopes_handle, LOWER_LINE, 0, rates_total, Envelopes_Lower) <= 0) return(rates_total);
   ArraySetAsSeries(Envelopes_Lower, true);
   if(CopyLow(Symbol(), PERIOD_CURRENT, 0, rates_total, Low) <= 0) return(rates_total);
   ArraySetAsSeries(Low, true);
   if(BarsCalculated(Bands_handle) <= 0) 
      return(0);
   if(CopyBuffer(Bands_handle, UPPER_BAND, 0, rates_total, Bands_Upper) <= 0) return(rates_total);
   ArraySetAsSeries(Bands_Upper, true);
   if(BarsCalculated(Envelopes_handle) <= 0) 
      return(0);
   if(CopyBuffer(Envelopes_handle, UPPER_LINE, 0, rates_total, Envelopes_Upper) <= 0) return(rates_total);
   ArraySetAsSeries(Envelopes_Upper, true);
   if(CopyHigh(Symbol(), PERIOD_CURRENT, 0, rates_total, High) <= 0) return(rates_total);
   ArraySetAsSeries(High, true);
   if(CopyTime(Symbol(), Period(), 0, rates_total, Time) <= 0) return(rates_total);
   ArraySetAsSeries(Time, true);
   //--- main loop
   for(int i = limit-1; i >= 0; i--)
     {
      if (i >= MathMin(5000-1, rates_total-1-50)) continue; //omit some old rates to prevent "Array out of range" or slow calculation   
      
      //Indicator Buffer 1
      if(Open[1+i] < Bands_Lower[1+i] //Candlestick Open < Bollinger Bands
      && Close[1+i] < Bands_Lower[1+i] //Candlestick Close < Bollinger Bands
      && Open[1+i] < Envelopes_Lower[1+i] //Candlestick Open < Envelopes
      && Close[1+i] < Envelopes_Lower[1+i] //Candlestick Close < Envelopes
      && Open[1+i] < Close[1+i] //Candlestick Open < Candlestick Close
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
      if(Open[1+i] > Bands_Upper[1+i] //Candlestick Open > Bollinger Bands
      && Close[1+i] > Bands_Upper[1+i] //Candlestick Close > Bollinger Bands
      && Open[1+i] > Envelopes_Upper[1+i] //Candlestick Open > Envelopes
      && Close[1+i] > Envelopes_Upper[1+i] //Candlestick Close > Envelopes
      && Open[1+i] > Close[1+i] //Candlestick Open > Candlestick Close
      )
        {
         Buffer2[i] = High[1+i]; //Set indicator value at Candlestick High
         if(i == 1 && Time[1] != time_alert) myAlert("indicator", "sell"); //Alert on next bar open
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