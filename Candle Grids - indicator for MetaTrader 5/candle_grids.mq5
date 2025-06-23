//+------------------------------------------------------------------+
//|                                                 Candle_Grids.mq5 |
//|                                Copyright 2024, Rajesh Kumar Nait |
//|                  https://www.mql5.com/en/users/rajeshnait/seller |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Rajesh Kumar Nait"
#property link      "https://www.mql5.com/en/users/rajeshnait/seller"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0

string name_,prefix;
double ciel_price,floor_price,range;

input int points=50;
input int number_of_levels = 50;
input bool is_range = true; // Use Rectangle Range for Grid?

input color Grid_up_color = clrDimGray;
input ENUM_LINE_STYLE Grid_up_Style = STYLE_DASHDOTDOT;

input color Grid_dn_color = clrDimGray;
input ENUM_LINE_STYLE Grid_dn_Style = STYLE_DASHDOTDOT;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping
   prefix="g_";
   ChartSetInteger(0, CHART_EVENT_OBJECT_CREATE, true);
   ChartSetInteger(0, CHART_EVENT_OBJECT_DELETE, true);
//---
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator Deinitialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   ObjectsDeleteAll(0,prefix);
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


//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawGrid() {

   ObjectsDeleteAll(0,prefix);
   name_ = ObjectName(0,0,-1,OBJ_RECTANGLE);
   ciel_price = ObjectGetDouble(0,name_,OBJPROP_PRICE,1);
   floor_price = ObjectGetDouble(0,name_,OBJPROP_PRICE,0);
   range = ciel_price- floor_price;

   for(int i=1; i<number_of_levels; i++) {
      if(is_range==false) {
         HLineCreate(0,prefix+"Gridup_"+(string)i,0,ciel_price+i*points*Point(),Grid_up_color,Grid_up_Style,1,true,false,true,0);
         HLineCreate(0,prefix+"Griddn_"+(string)i,0,floor_price-i*points*Point(),Grid_dn_color,Grid_dn_Style,1,true,false,true,0);
      } else {
         HLineCreate(0,prefix+"Gridup_"+(string)i,0,ciel_price+i*range,Grid_up_color,Grid_up_Style,1,true,false,true,0);
         HLineCreate(0,prefix+"Griddn_"+(string)i,0,floor_price-i*range,Grid_dn_color,Grid_dn_Style,1,true,false,true,0);

      }

   }
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
//---

   if(id==CHARTEVENT_OBJECT_CREATE) {
      if(ObjectFind(0,ObjectName(0,0,-1,OBJ_RECTANGLE))!=-1) {
         DrawGrid();
      }
   }

   if(id==CHARTEVENT_OBJECT_DRAG) {
      if(ObjectFind(0,ObjectName(0,0,-1,OBJ_RECTANGLE))!=-1) {
         ObjectsDeleteAll(0,prefix);
         DrawGrid();
      }

      if(id==CHARTEVENT_OBJECT_DELETE) {
         if(ObjectFind(0,ObjectName(0,0,-1,OBJ_RECTANGLE))==-1) {
            ObjectsDeleteAll(0,prefix);
            name_="";
         }
      }


   }


}
//+------------------------------------------------------------------+
//| Create the horizontal line                                       |
//+------------------------------------------------------------------+
bool HLineCreate(const long            chart_ID=0,        // chart's ID
                 const string          name="HLine",      // line name
                 const int             sub_window=0,      // subwindow index
                 double                price=0,           // line price
                 const color           clr=clrRed,        // line color
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style
                 const int             width=1,           // line width
                 const bool            back=false,        // in the background
                 const bool            selection=true,    // highlight to move
                 const bool            hidden=true,       // hidden in the object list
                 const long            z_order=0) {       // priority for mouse click
//--- if the price is not set, set it at the current Bid price level
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- create a horizontal line
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price)) {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
   }
//--- set line color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
