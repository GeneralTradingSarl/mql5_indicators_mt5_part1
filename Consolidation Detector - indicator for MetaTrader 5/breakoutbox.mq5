//+------------------------------------------------------------------+
//|                                                  BreakOutBox.mq5 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property link      "https://twitter.comDarkRyd3r"
#property version   "1.00"

#property indicator_chart_window
#property indicator_plots 0

int BoxHeight=30,BoxLength=140;
input string          InpName="Box "; // Channel name
input color           InpColor=clrMagenta;     // Channel color
input ENUM_LINE_STYLE InpStyle=STYLE_DASHDOTDOT; // Style of Channel  lines
input int             InpWidth=2;          // Width of Channel  lines
input bool            InpBack=true;       // Background Channel
input bool            InpSelection=false;   // Highlight to move
input bool            InpHidden=true;      // Hidden in the object list
input long            InpZOrder=0;         // Priority for mouse click

input bool            InpFill2=false;       // Filling the channel with color
bool            InpRayLeft=false;    // Channel 's continuation to the left
bool            InpRayRight=false;   // Channel 's continuation to the right

bool break_out_box=false,break_out_up=false,break_out_down=false;
datetime box_start,box_end;
double highest,lowest,range,box_high,box_low;
int range_time;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping

//---
   return(0);
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
//if(rates_total>maxbars) return 0;
   highest=high[0];
   lowest=low[0];
   for(int i=1; i<rates_total; i++) {
      if(close[i]>highest)highest=close[i];
      if(close[i]<lowest)lowest=close[i];
      range=highest-lowest;
      range_time++;
      if(range<BoxHeight*_Point*10 && range_time>=BoxLength) {
         break_out_box=true;
         box_high=highest;
         box_low=lowest;
         box_start=time[MathAbs(i-range_time)];
      } else if(range>BoxHeight*_Point*10 && range_time>=BoxLength && break_out_box==true && box_high<highest) {
         break_out_up=true;
         break_out_down=false;
         break_out_box=false;
         box_end=time[i-1];

         if(!ChannelCreate(0,InpName+IntegerToString(i),0,box_start,box_high,box_end,box_high,box_start,box_low,InpColor,
                           InpStyle,InpWidth,InpFill2,InpBack,InpSelection,InpRayLeft,InpRayRight,InpHidden,InpZOrder)) {
            return 0;
         }

         range=0;
         range_time=0;
      } else if(range>BoxHeight*_Point*10 && range_time>=BoxLength && break_out_box==true && box_low>lowest) {
         break_out_down=true;
         break_out_up=false;
         break_out_box=false;
         box_end=time[i-1];

         if(!ChannelCreate(0,InpName+IntegerToString(i),0,box_start,box_high,box_end,box_high,box_start,box_low,InpColor,
                           InpStyle,InpWidth,InpFill2,InpBack,InpSelection,InpRayLeft,InpRayRight,InpHidden,InpZOrder)) {
            return 0;
         }
         range=0;
         range_time=0;
      } else if(range>BoxHeight*_Point*10 && range_time<=BoxLength) {
         range=0;
         range_time=0;
         highest=high[i];
         lowest=low[i];
      }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   ObjectsDeleteAll(0,-1,OBJ_CHANNEL);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Create an equidistant channel by the given coordinates           |
//+------------------------------------------------------------------+
bool ChannelCreate(const long            chart_ID=0,        // chart's ID
                   const string          name="Channel",    // channel name
                   const int             sub_window=0,      // subwindow index
                   datetime              time1=0,           // first point time
                   double                price1=0,          // first point price
                   datetime              time2=0,           // second point time
                   double                price2=0,          // second point price
                   datetime              time3=0,           // third point time
                   double                price3=0,          // third point price
                   const color           clr=clrRed,        // channel color
                   const ENUM_LINE_STYLE style=STYLE_SOLID, // style of channel lines
                   const int             width=1,           // width of channel lines
                   const bool            fill=false,        // filling the channel with color
                   const bool            back=false,        // in the background
                   const bool            selection=true,    // highlight to move
                   const bool            ray_left=false,    // channel's continuation to the left
                   const bool            ray_right=false,   // channel's continuation to the right
                   const bool            hidden=true,       // hidden in the object list
                   const long            z_order=0) {       // priority for mouse click
//--- set anchor points' coordinates if they are not set
   //ChangeChannelEmptyPoints(time1,price1,time2,price2,time3,price3);
//--- reset the error value
   ResetLastError();
//--- create a channel by the given coordinates
   if(!ObjectCreate(chart_ID,name,OBJ_CHANNEL,sub_window,time1,price1,time2,price2,time3,price3)) {
      Print(__FUNCTION__,
            ": failed to create an equidistant channel! Error code = ",GetLastError());
      return(false);
   }
//--- set channel color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set style of the channel lines
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set width of the channel lines
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- enable (true) or disable (false) the mode of filling the channel
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of highlighting the channel for moving
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- enable (true) or disable (false) the mode of continuation of the channel's display to the left
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_LEFT,ray_left);
//--- enable (true) or disable (false) the mode of continuation of the channel's display to the right
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
}
//+------------------------------------------------------------------+
