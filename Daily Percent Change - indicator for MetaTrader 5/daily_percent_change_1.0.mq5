//+------------------------------------------------------------------+
//|                                         Daily Percent Change.mq5 |
//|                                          Copyright 2019, Rob Rice|
//+------------------------------------------------------------------+
#property copyright   "2019 Rob Rice"
#property description "Daily Percent Change"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_level1  0.85
#property indicator_level2 -0.85
#property indicator_type1   DRAW_LINE
#property indicator_color1  LightSeaGreen
#property indicator_label1  "Daily Percent Change"

//--- input params

//---- buffers
double DPCBuffer[];
double C,O;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME,"Daily Percent Change");
//---- index buffer
   SetIndexBuffer(0,DPCBuffer,INDICATOR_DATA);
   ArraySetAsSeries(DPCBuffer,true);
//   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,100);
   return(INIT_SUCCEEDED);

//---- OnInit done
  }
//+------------------------------------------------------------------+
//| Calculation                                        |
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

//--- check for bars count
   if(rates_total<1440/Period())
      return(0); //exit with zero result 

//--- prevent total recalculation
   int i=rates_total-1;
   if(prev_calculated>0)
      i=rates_total-prev_calculated -1;

//--- current value should be recalculated
   if(i<0)
      i=0;
//---
   while(i>=0)
     {
      datetime date=iTime(NULL,0,i);
      int Hour=TimeHourMQL4(date);
      int Minute=TimeMinuteMQL4(date);
      //     Print("i = ",i," Hour = ",Hour," Minute = ",Minute);

      if(Hour==0 && Minute==0)
        {
         O=iOpen(NULL,0,i);
        }

      C=iClose(NULL,0,i);

      if(O==0)
         DPCBuffer[i]=0;
      else
         DPCBuffer[i]=NormalizeDouble(((C-O)/O*100),6);
      //     Print(date," i = ",i," Open = ",O," Close = ",C," DPC = ",DPCBuffer[i]);
      i--;

     }

//----
   return(rates_total);
  }
//+------------------ Functions -----------------------------------------------+

int TimeHourMQL4(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.hour);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeMinuteMQL4(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.min);
  }
//+------------------------------------------------------------------+
