//+------------------------------------------------------------------+
//|                                                Custom BidAsk.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0
#define Factor 0.036
#define X_offset 70

input bool show_bid = true;                  // Show the bid
input bool show_ask = true;                  // Show the ask
input int bid_line_width = 1;                // Size of Bid line
input int ask_line_width = 1;                // Size of Ask line
input color bid_line_color = clrSilver;      // Color of Bid line
input color ask_line_color = clrPurple;      // Color of Ask line
input bool show_text = true;                 // Show Bid/Ask text

int bid_text_size = 8;                 // Font size for Bid text
int ask_text_size = 8;                 // Font size for Ask text

string bid_obj_name, bid_text_obj_name;
string ask_obj_name, ask_text_obj_name;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   bid_obj_name = "Bid";
   bid_text_obj_name = "_BidText";
   ask_obj_name = "Ask";
   ask_text_obj_name = "_AskText";

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
   ArraySetAsSeries(time, true);
   
   double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
    
   // Bid Line
   if(show_bid){
      if (ObjectFind(0, bid_obj_name) == -1){
         ObjectCreate(0, bid_obj_name, OBJ_HLINE, 0, 0, bid);
      }
      
      ObjectSetDouble(0, bid_obj_name, OBJPROP_PRICE, bid);
      ObjectSetInteger(0, bid_obj_name, OBJPROP_STYLE, DRAW_LINE);
      ObjectSetInteger(0, bid_obj_name, OBJPROP_WIDTH, bid_line_width);
      ObjectSetInteger(0, bid_obj_name, OBJPROP_COLOR, bid_line_color);
      
      if(show_text){  
         Text(0, bid_text_obj_name, "Bid", bid, bid_text_size, bid_line_color, time[X_offset]);
      }
      else{
         if (ObjectFind(0, bid_text_obj_name) != -1) ObjectDelete(0, bid_text_obj_name);
      }
   }
   else{
      if (ObjectFind(0, bid_obj_name) != -1) ObjectDelete(0, bid_obj_name);
      if (ObjectFind(0, bid_text_obj_name) != -1) ObjectDelete(0, bid_text_obj_name);
   }

   // Ask Line
   if(show_ask){
      if (ObjectFind(0, ask_obj_name) == -1){
         ObjectCreate(0, ask_obj_name, OBJ_HLINE, 0, 0, ask);
      }
      
      ObjectSetDouble(0, ask_obj_name, OBJPROP_PRICE, ask);
      ObjectSetInteger(0, ask_obj_name, OBJPROP_STYLE, DRAW_LINE);
      ObjectSetInteger(0, ask_obj_name, OBJPROP_WIDTH, ask_line_width);
      ObjectSetInteger(0, ask_obj_name, OBJPROP_COLOR, ask_line_color);
      
      double dynamic_offset = (ChartGetDouble(0, CHART_PRICE_MAX) - ChartGetDouble(0, CHART_PRICE_MIN)) * Factor;
      
      if(show_text){
         Text(0, ask_text_obj_name, "Ask", ask + dynamic_offset, ask_text_size, ask_line_color, time[X_offset]);
      }
      else{
         if (ObjectFind(0, ask_text_obj_name) != -1) ObjectDelete(0, ask_text_obj_name);
      } 
   }
   else{
      if (ObjectFind(0, ask_obj_name) != -1) ObjectDelete(0, ask_obj_name);
      if (ObjectFind(0, ask_text_obj_name) != -1) ObjectDelete(0, ask_text_obj_name);
   }
   
   return(rates_total);
  }
//+------------------------------------------------------------------+

void Text(int id, string name, string text, double distance, int fontSize, color fontColor, datetime time){

    if (ObjectFind(0, name) == -1){
        ObjectCreate(id, name, OBJ_TEXT, 0, time, distance);
    }
    ObjectSetInteger(id, name, OBJPROP_CORNER, 0);
    ObjectSetInteger(id, name, OBJPROP_FONTSIZE, fontSize);
    ObjectSetInteger(id, name, OBJPROP_COLOR, fontColor);
    ObjectSetString(id, name, OBJPROP_TEXT, text);
    ObjectSetDouble(id, name, OBJPROP_PRICE, distance);    
}

void OnDeinit(const int reason){

   ObjectDelete(0, bid_obj_name);
   ObjectDelete(0, bid_text_obj_name);
   ObjectDelete(0, ask_obj_name);
   ObjectDelete(0, ask_text_obj_name);
}





