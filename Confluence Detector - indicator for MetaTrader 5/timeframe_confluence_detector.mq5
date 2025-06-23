//+------------------------------------------------------------------+
//|                                Timeframe Confluence Detector.mq5 |
//|                                                                  |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "phade"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 5 
#property indicator_plots   3 

#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBurlyWood
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDarkGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

#define offset 60

input ENUM_TIMEFRAMES timeframe_a = PERIOD_CURRENT; //Current period
input ENUM_TIMEFRAMES timeframe_b = PERIOD_H2; // 1st timeframe deviation to current period
input ENUM_TIMEFRAMES timeframe_c = PERIOD_H1; // 2nd timeframe deviation to current period

int bars;

double buf_a[];
double buf_b[];
double buf_c[];

double deviator_a[], deviator_b[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorRelease(0);

   SetIndexBuffer(0, buf_a, INDICATOR_DATA);
   SetIndexBuffer(1, deviator_a, INDICATOR_DATA);
   SetIndexBuffer(2, deviator_b, INDICATOR_DATA);
   SetIndexBuffer(3, buf_b, INDICATOR_CALCULATIONS);  
   SetIndexBuffer(4, buf_c, INDICATOR_CALCULATIONS);  
      
   ArraySetAsSeries(buf_a,true);
   ArraySetAsSeries(buf_b,true);
   ArraySetAsSeries(buf_c,true);
   ArraySetAsSeries(deviator_a,true);
   ArraySetAsSeries(deviator_b,true);
      
   PlotIndexSetString(0, PLOT_LABEL, TimeframeToString(timeframe_a));
   PlotIndexSetString(1, PLOT_LABEL, "Deviation from " + TimeframeToString(timeframe_b) + " to " + TimeframeToString(timeframe_a));
   PlotIndexSetString(2, PLOT_LABEL, "Deviation from " + TimeframeToString(timeframe_c) + " to " + TimeframeToString(timeframe_a));
     
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
   CopySeries(Symbol(), timeframe_a, 0, rates_total, COPY_RATES_CLOSE, buf_a);
   CopySeries(Symbol(), timeframe_b, 0, rates_total, COPY_RATES_CLOSE, buf_b);
   CopySeries(Symbol(), timeframe_c, 0, rates_total, COPY_RATES_CLOSE, buf_c);
    
   for(int i = rates_total - 1; i>=0; i--){
   
      deviator_a[i] = MathAbs(buf_b[i] - buf_a[i]) + buf_b[i] - offset*_Point;
      deviator_b[i] = MathAbs(buf_c[i] - buf_a[i]) + buf_c[i] - (offset*2)*_Point;
   }

   return(rates_total);
}


string TimeframeToString(const ENUM_TIMEFRAMES timeframe)
{
    string result;
    switch (timeframe){
    
        case PERIOD_M1:      result = "M1";      break;
        case PERIOD_M5:      result = "M5";      break;
        case PERIOD_M15:     result = "M15";     break;
        case PERIOD_M30:     result = "M30";     break;
        case PERIOD_H1:      result = "H1";      break;
        case PERIOD_H2:      result = "H2";      break;
        case PERIOD_H4:      result = "H4";      break;
        case PERIOD_D1:      result = "D1";      break;
        case PERIOD_W1:      result = "W1";      break;
        case PERIOD_MN1:     result = "MN1";     break;
        default:             result = "";        break;
    }
    return result;
}
