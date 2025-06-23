//+------------------------------------------------------------------+
//|                                               Counter_Attack.mq5 |
//|                                Copyright 2024, Rajesh Kumar Nait |
//|                  https://www.mql5.com/en/users/rajeshnait/seller |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Rajesh Kumar Nait"
#property link      "https://www.mql5.com/en/users/rajeshnait/seller"
#property version   "1.00"
#property indicator_chart_window
#property indicator_plots 0
string prefix="c_";
input int total = 1000; // Number of Bars
input color clr = clrSnow; // Adjust color as required
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping

//---
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
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
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);

   if(rates_total<total) {
      Print("Required Bars not available");
      return(rates_total);
   }

   for(int i=1; i<total; i++) {
      //bullish
      if(open[i]<close[i] && open[i+1]>close[i+1] && open[i]<=close[i+1] && close[i]<=close[i+1]  && high[i]>close[i+1] && low[i+1]<open[i])
         crearFlecha(prefix+"Bull_CounterAttack"+IntegerToString(i),time[i],low[i+1],clr,225,ANCHOR_TOP);

      if(open[i]>close[i] && open[i+1]<close[i+1] && close[i]>=open[i+1]   && close[i]>=close[i+1] && low[i]<close[i+1] && high[i+1]>close[i])
         crearFlecha(prefix+"Bear_CounterAttack"+IntegerToString(i),time[i],high[i+1],clr,226,ANCHOR_BOTTOM);
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//| CREATE ARROWS
//+------------------------------------------------------------------+
bool crearFlecha(string nameAux, datetime timeAux, double priceAux, color clrAux, int code, ENUM_ARROW_ANCHOR anchorAux) {
   const long              chart_ID=0;           // chart's ID
   const string            name=nameAux;         // arrow name
   const int               sub_window=0;         // subwindow index
   datetime                time=timeAux;         // anchor point time
   double                  price=priceAux;       // anchor point price
   const int               arrow_code=code;      // arrow code
   const ENUM_ARROW_ANCHOR anchor=anchorAux;     // anchor point position
   const color             clr_=clrAux;           // arrow color
   const ENUM_LINE_STYLE   style=STYLE_SOLID;    // border line style
   const int               width=1;              // arrow size
   const bool              back=true;            // in the background
   const bool              selection=false;      // highlight to move
   const bool              hidden=true;          // hidden in the object list
   const long              z_order=0;            // priority for mouse click

   ObjectCreate(chart_ID,name,OBJ_ARROW,sub_window,time,price);
   ObjectSetInteger(chart_ID,name,OBJPROP_ARROWCODE,arrow_code);
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchorAux);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr_);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
}
//+------------------------------------------------------------------+
