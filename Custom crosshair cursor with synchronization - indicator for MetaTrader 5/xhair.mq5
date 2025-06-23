//+------------------------------------------------------------------+
//|                                                    crosshair.mq5 |
//|                                            Copyright 2024, seffx |
//|                              https://www.mql5.com/en/users/seffx |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, seffx"
#property link      "https://www.mql5.com/en/users/seffx"
#property version   "1.20"
#property indicator_chart_window

#define PREFIX "_xhair_"

sinput bool localTime = true; // Show localtime
sinput color cursorColor = clrLightGray; // Cursor color
sinput string cursorName = "XHAIR"; // Cursor name
const string YLINE = PREFIX "Y";
const string XLINE = PREFIX "X";
string xhair_price = "";
string xhair_time = "";
datetime last_time = 0;
double last_price = 0;
int started = 20;
bool lines_hidden = false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool VLineCreate(const string name, datetime time=0)
  {
   const long              chart_ID=0;
   const int               sub_window=0;
   const color             clr=cursorColor;
   const ENUM_LINE_STYLE   style=STYLE_DOT;
   const int               width=1;
   const bool              back=false;
   const bool              selection=false;
   const bool              ray=true;
   const bool              hidden=true;
   const long              z_order=-1;

   if(!time)
      time=TimeCurrent();

   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_VLINE,sub_window,time,0))
     {
      Print(__FUNCTION__,
            ": failed to create a vertical line! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY,ray);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   ObjectSetString(chart_ID,name, OBJPROP_TOOLTIP, "\n");
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HLineCreate(const string name, double price=0)
  {
   const long              chart_ID=0;
   const int               sub_window=0;
   const color             clr=cursorColor;
   const ENUM_LINE_STYLE   style=STYLE_DOT;
   const int               width=1;
   const bool              back=false;
   const bool              selection=false;
   const bool              ray=true;
   const bool              hidden=true;
   const long              z_order=0;

   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   ObjectSetString(chart_ID,name, OBJPROP_TOOLTIP, "\n");
   return(true);
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   ChartSetInteger(0, CHART_AUTOSCROLL, false);
//ChartSetInteger(0, CHART_CROSSHAIR_TOOL, false);
   xhair_price = StringFormat("%s_PRICE", cursorName);
   xhair_time = StringFormat("%s_TIME", cursorName);
   datetime time = TimeCurrent();
   double price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   VLineCreate(YLINE, time);
   HLineCreate(XLINE, price);
//GlobalVariableSet(xhair_price, price);
//GlobalVariableSet(xhair_time, time);
   EventSetMillisecondTimer(100);
//---
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   ObjectsDeleteAll(0, PREFIX);
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
//---

//--- return value of prev_calculated for next call
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void showLocaltime(datetime time, double price)
  {
   if(localTime)
     {
      datetime tserver = TimeTradeServer();
      datetime tlocal = TimeLocal();
      int diff = (int)(tserver - tlocal);
      datetime localtime = time - diff;
      string localtime_str = TimeToString(localtime);
      ObjectSetString(0, YLINE, OBJPROP_TOOLTIP, localtime_str);
      ObjectSetString(0, XLINE, OBJPROP_TOOLTIP, localtime_str+"\n"+DoubleToString(price, _Digits));
     }
   else
     {
      ObjectSetString(0, YLINE, OBJPROP_TOOLTIP, "\n");
      ObjectSetString(0, XLINE, OBJPROP_TOOLTIP, "\n");
     }
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   if(id==CHARTEVENT_KEYDOWN)
     {
      if(lparam == 27)
        {
         int t = (int) GlobalVariableGet(xhair_time);
         datetime dt = (datetime) t;
         if(t == 0)
            GlobalVariableSet(xhair_time, last_time);
         else
            GlobalVariableSet(xhair_time, 0);
         return;
        }
     }
   if(id != CHARTEVENT_MOUSE_MOVE)
      return;
   int x = (int)lparam;
   int y = (int)dparam;
   int sub;
   datetime time;
   double price;
   if(ChartXYToTimePrice(0,x,y,sub,time,price))
     {
      long flags = StringToInteger(sparam);
      if(((flags & 8) == 8) || ((flags & 4) == 4) || ((flags & 16) == 16))
        {
         started = 0;
         last_price = price;
         last_time = time;
         GlobalVariableSet(xhair_price, price);
         GlobalVariableSet(xhair_time, time);
         ObjectMove(0, YLINE, 0, time, 0);
         ObjectMove(0, XLINE, 0, time, price);
         showLocaltime(time, price);
         ChartRedraw(0);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NavigateTo(datetime time, double price)
  {
   int bar_index=iBarShift(NULL,PERIOD_CURRENT, time, false);
   if(bar_index == -1)
      return false;

   int first_bar = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
   int total_bars = (int)ChartGetInteger(0, CHART_VISIBLE_BARS);
   int last_bar = first_bar - total_bars;
   if(bar_index > first_bar)
     {
      // navigate left
      if(!ChartNavigate(0, CHART_CURRENT_POS, first_bar - bar_index - total_bars/4))
         return false;
     }
   else
      if(bar_index < last_bar)
        {
         // navigate right
         if(!ChartNavigate(0, CHART_CURRENT_POS, first_bar - bar_index - (total_bars-total_bars/4)))
            return false;
        }
   ObjectMove(0, XLINE, 0, 0, price);
   ObjectMove(0, YLINE, 0, time, 0);
//showLocaltime(time, price);
   ChartRedraw(0);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   double tmp;
   double price;
   datetime time = 0;
   if(GlobalVariableGet(xhair_time, tmp))
     {
      time = (datetime) tmp;
     }
   else
     {
      if(started > 0)
        {
         started = started - 1;
         if(started <= 0)
           {
            ObjectSetInteger(0, XLINE, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
            ObjectSetInteger(0, YLINE, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
            ChartRedraw(0);
            lines_hidden = true;
           }
        }
      return;
     }
   if(time == 0)
     {
      ObjectSetInteger(0, XLINE, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
      ObjectSetInteger(0, YLINE, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
      ChartRedraw(0);
      lines_hidden = true;
      return;
     }
   if(!GlobalVariableGet(xhair_price, price))
      return;
   ObjectSetInteger(0, XLINE, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   ObjectSetInteger(0, YLINE, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   ChartRedraw(0);
   bool price_changed = MathAbs(price - last_price) > DBL_EPSILON;
   bool time_changed  = time != last_time;
   if(lines_hidden || time_changed || price_changed)
     {
      lines_hidden = false;
      ChartSetInteger(0, CHART_AUTOSCROLL, false);
      ChartRedraw(0);
      last_price = price;
      last_time = time;
      NavigateTo(time, price);
     }
  }
//+------------------------------------------------------------------+
