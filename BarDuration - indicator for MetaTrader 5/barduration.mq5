//+------------------------------------------------------------------+
//|                                                  BarDuration.mq5 |
//|                                    Copyright (c) 2025, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2025, Marketeer"
#property link      "https://www.mql5.com/en/users/marketeer"
#property description "Display histogram of custom bars' durations in minutes. Applicable for renko boxes, PnF, equivolume bars, etc."

#property indicator_separate_window
#property indicator_buffers      1
#property indicator_plots        1
#property indicator_type1        DRAW_HISTOGRAM
#property indicator_width1       3
#property indicator_color1       clrRoyalBlue
#property indicator_label1       "Duration (min)"

//+------------------------------------------------------------------+
//| I N P U T S                                                      |
//+------------------------------------------------------------------+

input bool Directional = false;

//+------------------------------------------------------------------+
//| G L O B A L S                                                    |
//+------------------------------------------------------------------+

double Buffer1[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, Buffer1, INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS, 2);
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated,
    const datetime &time[],
    const double &open[],
    const double &high[],
    const double &low[],
    const double &close[],
    const long &tick_volume[],
    const long &volume[],
    const int &spread[])
{
   int limit = rates_total;
   if(prev_calculated <= 0)
   {
      ArrayInitialize(Buffer1, EMPTY_VALUE);
      ArraySetAsSeries(Buffer1, true);
   }
   else
   {
      limit = rates_total - prev_calculated + 1;
   }

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(close, true);
   
   for(int i = 0; i < limit && !IsStopped(); i++)
   {
      datetime stop = GetTradeScheduleBreak(_Symbol, time[i]);
      if(i)
      {
         Buffer1[i] = ((close[i] > open[i] || !Directional) * 2 - 1) * (double)(fmin(time[i - 1], stop) - time[i]) / 60;
      }
      else
      {
         Buffer1[i] = ((close[i] > open[i] || !Directional) * 2 - 1) * (double)(fmin(TimeCurrent(), stop) - time[0]) / 60;
      }
   }
   
   return rates_total;
}

//+------------------------------------------------------------------+
//| Aux functions                                                    |
//+------------------------------------------------------------------+

ENUM_DAY_OF_WEEK DayOfWeek(const datetime _t)
{
   return (ENUM_DAY_OF_WEEK)(((_t / 86400) + 4) % 7);
}

datetime GetTradeScheduleBreak(const string symbol, datetime now)
{
   const static ulong day = 60 * 60 * 24;
   const ulong time = (ulong)now % day;
   const datetime date = (datetime)(now / day * day);
   datetime from, to;
   int i = 0;
   
   ENUM_DAY_OF_WEEK d = DayOfWeek(now);
   
   struct Session
   {
      datetime from, to;
      Session()
      {
         ZeroMemory(this);
      }
   };
   
   static Session schedule[][7];
   static int sessions = 0;
   
   if(!ArrayRange(schedule, 0))
   {
      for(int j = 0; j < 7; j++)
      {
         i = 0;
         while(SymbolInfoSessionQuote(symbol, (ENUM_DAY_OF_WEEK)j, i++, from, to))
         {
            if(i > ArrayRange(schedule, 0)) ArrayResize(schedule, i);
            schedule[i - 1][j].from = from;
            schedule[i - 1][j].to = to;
         }
      }
      sessions = ArrayRange(schedule, 0);
   }
   
   i = 0;
   while(i < sessions)
   {
      if(time >= (ulong)schedule[i][d].from && time < (ulong)schedule[i][d].to)
      {
         return (datetime)(date + schedule[i][d].to);
      }
      i++;
   }

   return D'3000.12.31 23:59';
}
//+------------------------------------------------------------------+
