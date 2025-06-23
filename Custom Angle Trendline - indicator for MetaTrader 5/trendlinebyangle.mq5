//+------------------------------------------------------------------+
//|                                       Custom Angle Trendline.mq5 |
//|                                       Copyright 2021, Dark Ryd3r |
//|                                    https://twitter.com/DarkRyd3r |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Dark Ryd3r"
#property link      "https://twitter.com/DarkRyd3r"
#property version   "1.00"
#property description "Custom Angle Trendline"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0

enum Width {
   Width_1=1, //1
   Width_2,   //2
   Width_3,   //3
   Width_4,   //4
   Width_5    //5
};
enum STYLE {
   SOLID_,//Solid line
   DASH_,//Dashed line
   DOT_,//Dotted line
   DASHDOT_,//Dot-dash line
   DASHDOTDOT_   // Dot-dash line with double dots
};


input int CandlesOnChartH =500; // Previous Number of Bars for Downside Line
input int CandlesOnChartL =500; // Previous Number of Bars for Upside Line
input int DownLineAngle = 45; // DownLine Angle
input int UpLineAngle = 45; // UpLine Angle

input STYLE  Style_DownLine = DASHDOTDOT_ ;  //DownLine style
input STYLE  Style_UpLine = DASHDOTDOT_ ;    //UpLine style

input Width  Width_DownLine = Width_1;       //DownLine width
input Width  Width_UpLine = Width_1;         //UpLine width

input color  Color_DownLine = clrDeepPink;   //DownLine Color
input color  Color_UpLine = clrAqua;         //UpLine Color
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//---
   IndicatorSetString(INDICATOR_SHORTNAME,"Custom Angle Trendline");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
//----
   ObjectDelete(0,"DownLine");
   ObjectDelete(0,"UpLine");
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
   if(prev_calculated!=rates_total) {
      int HighestCandle, LowestCandle;
      double High[], Low[];
      ArraySetAsSeries(High,true);
      ArraySetAsSeries(Low,true);
      CopyHigh(_Symbol,_Period,0,CandlesOnChartH,High);
      CopyLow(_Symbol,_Period,0,CandlesOnChartL,Low);
      HighestCandle = ArrayMaximum(High,0,CandlesOnChartH);
      LowestCandle = ArrayMinimum(Low,0,CandlesOnChartL);
      MqlRates PriceInformation[];
      ArraySetAsSeries(PriceInformation,true);
      int DataH = CopyRates(_Symbol,_Period,0,CandlesOnChartH,PriceInformation);
      int DataL = CopyRates(_Symbol,_Period,0,CandlesOnChartL,PriceInformation);


//downline
      ObjectCreate(0,"DownLine",OBJ_TRENDBYANGLE,0,PriceInformation[HighestCandle].time,PriceInformation[HighestCandle].high,PriceInformation[0].time,PriceInformation[0].high);
      ObjectSetDouble(0,"DownLine",OBJPROP_ANGLE,DownLineAngle);
      ObjectSetDouble(0,"DownLine",OBJPROP_SCALE,1.0);
      ObjectSetInteger(0,"DownLine", OBJPROP_RAY_LEFT, true);
      ObjectSetInteger(0,"DownLine", OBJPROP_WIDTH, 2);
      ObjectSetInteger(0,"DownLine", OBJPROP_STYLE, Style_DownLine);
      ObjectSetInteger(0,"DownLine", OBJPROP_COLOR,Color_DownLine);
      ObjectMove(0,"DownLine",0,PriceInformation[HighestCandle].time,PriceInformation[HighestCandle].high);

//upline
      ObjectCreate(0,"UpLine",OBJ_TRENDBYANGLE,0,PriceInformation[LowestCandle].time,PriceInformation[LowestCandle].low,PriceInformation[0].time,PriceInformation[0].low);
      ObjectSetDouble(0,"UpLine",OBJPROP_ANGLE,UpLineAngle);
      ObjectSetDouble(0,"UpLine",OBJPROP_SCALE,1.0);
      ObjectSetInteger(0,"UpLine", OBJPROP_RAY_RIGHT, true);
      ObjectSetInteger(0,"UpLine", OBJPROP_WIDTH, 2);
      ObjectSetInteger(0,"UpLine", OBJPROP_STYLE, Style_UpLine);
      ObjectSetInteger(0,"UpLine", OBJPROP_COLOR,Color_UpLine);
      ObjectMove(0,"UpLine",0,PriceInformation[LowestCandle].time,PriceInformation[LowestCandle].low);

   }//end prev_calculated
   ChartRedraw(0);
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
