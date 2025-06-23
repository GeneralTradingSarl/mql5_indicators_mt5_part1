//+------------------------------------------------------------------+
//|                                                   Body_Range.mq5 |
//|                                Copyright 2023, Rajesh Kumar Nait |
//|                  https://www.mql5.com/en/users/rajeshnait/seller |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, Rajesh Kumar Nait"
#property link      "https://www.mql5.com/en/users/rajeshnait/seller"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0


input string            InpFont        = "Courier New";     // Font
input int               InpFontSize    = 12;                // Font size
input color             InpFontColor   = clrSnow;          // Font color
//---
string         m_prefix       = "BR_Info_";         // prefix for object
bool           m_init_error   = false;                // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

//--- indicator buffers mapping
   ObjectsDeleteAll(0,m_prefix,0,OBJ_TEXT);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,m_prefix,0,OBJ_TEXT);
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
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(m_init_error)
      return;
//--- the left mouse button has been pressed on the chart
   if(id==CHARTEVENT_CLICK)
     {

      int sub_window;      // the number of the subwindow
      datetime time;       // time on the chart
      double price;        // price on the chart
      double price_offset; // price on the chart
      if(!ChartXYToTimePrice(ChartID(),(int)lparam,(int)dparam,sub_window,time,price))
         return;
      if(!ChartXYToTimePrice(ChartID(),(int)lparam,(int)dparam+20,sub_window,time,price_offset))
         return;
      //---
      int bar_shift=iBarShift(Symbol(),Period(),time,false);
      if(bar_shift<0)
         return;
      //---
      MqlRates rates[];
      if(CopyRates(Symbol(),Period(),bar_shift,1,rates)!=1)
         return;
      //---
      double vertical_offset=price-price_offset;

      if(!TextCreate(0,m_prefix+"Bull_BR",0,0,0.0,"BR ",0,InpFont,InpFontSize,InpFontColor,ANCHOR_LEFT_UPPER))
        {
         ObjectsDeleteAll(0,m_prefix,0,OBJ_TEXT);
         m_init_error=true;
         return;
        }
      if(!TextCreate(0,m_prefix+"Bear_BR",0,0,0.0,"BR ",0,InpFont,InpFontSize,InpFontColor,ANCHOR_LEFT_UPPER))
        {
         ObjectsDeleteAll(0,m_prefix,0,OBJ_TEXT);
         m_init_error=true;
         return;
        }

      if(rates[0].open>rates[0].close)
         TextChange(ChartID(),m_prefix+"Bull_BR", "BR:  "+DoubleToString(-(rates[0].close-rates[0].open),Digits()));
      else
         TextChange(ChartID(),m_prefix+"Bear_BR", "BR:  "+DoubleToString(-(rates[0].open-rates[0].close),Digits()));
      //---
      TextMove(ChartID(),m_prefix+"Bull_BR",rates[0].time+PeriodSeconds(),price-vertical_offset*1.0);
      TextMove(ChartID(),m_prefix+"Bear_BR",rates[0].time+PeriodSeconds(),price-vertical_offset*1.0);
      //---
      ChartRedraw();

     }

   if(id==CHARTEVENT_KEYDOWN)
     {
      switch(int(lparam))
        {
         case 68 : //D
            ObjectsDeleteAll(0,m_prefix,0,OBJ_TEXT);
            ChartRedraw();
            break;

        }
      return;
     }
  }
//+------------------------------------------------------------------+
//| Creating Text object                                             |
//+------------------------------------------------------------------+
bool TextCreate(const long              chart_ID=0,               // chart's ID
                const string            name="Text",              // object name
                const int               sub_window=0,             // subwindow index
                datetime                time=0,                   // anchor point time
                double                  price=0,                  // anchor point price
                const string            text="Text",              // the text itself
                const double            angle=90.0,               // text slope
                const string            font="Lucida Console",    // font
                const int               font_size=10,             // font size
                const color             clr=clrBlue,              // color
                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT,// anchor type
                const bool              back=false,               // in the background
                const bool              selection=false,          // highlight to move
                const bool              hidden=true,              // hidden in the object list
                const long              z_order=0)                // priority for mouse click
  {
//--- set anchor point coordinates if they are not set
//ChangeTextEmptyPoint(time,price);
//--- reset the error value
   ResetLastError();
//--- create Text object
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create \"Text\" object! Error code = ",GetLastError());
      return(false);
     }
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the object by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,10);
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Move the anchor point                                            |
//+------------------------------------------------------------------+
bool TextMove(const long   chart_ID=0,  // chart's ID
              const string name="Text", // object name
              datetime     time=0,      // anchor point time coordinate
              double       price=0)     // anchor point price coordinate
  {
//--- if point position is not set, move it to the current bar having Bid price
   if(!time)
      time=TimeCurrent();
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- move the anchor point
   if(!ObjectMove(chart_ID,name,0,time,price))
     {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Change the object text                                           |
//+------------------------------------------------------------------+
bool TextChange(const long   chart_ID=0,              // chart's ID
                const string name="Text",             // object name
                const string text="Text")             // text
  {
//--- reset the error value
   ResetLastError();
//--- change object text
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
     {
      Print(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }

//+------------------------------------------------------------------+
