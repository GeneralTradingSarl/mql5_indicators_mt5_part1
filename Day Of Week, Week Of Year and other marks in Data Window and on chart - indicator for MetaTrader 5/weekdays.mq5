//+------------------------------------------------------------------+
//|                                                    ShowWeeks.mq5 |
//|                               Copyright (c) 2009-2024, Marketeer |
//|                          https://www.mql5.com/en/users/marketeer |
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2009-2024, Marketeer"
#property link      "https://www.mql5.com/en/users/marketeer"
#property description "Tracks current mouse position to show day of week, week number, day of year, or bar index under the cursor."
#property description "Two selected parameters are combined in a single value as a whole part and a fractional part in the Data Window."
#property version "1.0"

#property indicator_chart_window 0
#property indicator_buffers      1
#property indicator_plots        1
#property indicator_type1   DRAW_NONE

#include <MQL5Book/DateTime.mqh>
#include <MQL5Book/ArrayUtils.mqh>

#define PUSH(A,V) (A[ArrayResize(A, ArrayRange(A, 0) + 1, ArrayRange(A, 0) * 2) - 1] = V)
#define OBJ_PREFIX "WDi_"
#define DAY (60 * 60 * 24)

//+------------------------------------------------------------------+
//| I N P U T S                                                      |
//+------------------------------------------------------------------+

enum InfoType
{
  None = 1,
  DoW = 10,         // Day Of Week
  Week = 100,       // Week Of Year
  DoY = 1000,       // Day Of Year
  Bar = 1000000000, // Bar Index
};

input group "Display In Data Window via Buffer"
input InfoType WholePart = Week;
input InfoType FractionalPart = DoY;

enum Alignment
{
   Top,
   Middle,
   Bottom,
};

input group "Display Labels on Chart"
input bool      ShowLabels = false;
input string    FontName = "Segoe UI";
input int       FontSize = 25;
input color     FontColor = clrNONE;
input int       Padding = 5;           // Padding (% of chart height, for top/bottom alignment)
input Alignment AlignTo = Top;
input int       RotationAngle = 0;     // RotationAngle (for middle alignment)

//+------------------------------------------------------------------+
//| G L O B A L S                                                    |
//+------------------------------------------------------------------+

double Buffer1[];
int objCache[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   if(_Period > PERIOD_D1) return INIT_PARAMETERS_INCORRECT;
   
   SetIndexBuffer(0, Buffer1, INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS, (int)MathLog10(FractionalPart));
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true); // does not work in tester
   
   if(WholePart == FractionalPart && WholePart != None)
      Alert("The same info is selected to display as whole part and fractional part of indicator values!");
   
   if(ShowLabels && _Period < PERIOD_D1) AdjustLabels();
   
   return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int)
{
   ObjectsDeleteAll(0, OBJ_PREFIX);
   ChartRedraw();
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
   int limit = 0;
   if(prev_calculated <= 0)
      ArrayInitialize(Buffer1, EMPTY_VALUE);
   else
      limit = prev_calculated - 1;
  
   for(int i = limit; i < rates_total && !IsStopped(); i++)
   {
      if(WholePart * FractionalPart > 1)
      {
         const int d = TimeDayOfYear(time[i]); // cache datetime object
         Buffer1[i] = GetPart(WholePart, i) + GetPart(FractionalPart, i) / (double)FractionalPart;
      }
      else
      {
         Buffer1[i] = DayOfWeek(time[i]);
      }
   }
   
   return rates_total;
}

//+------------------------------------------------------------------+
//| Event handler function                                           |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id == CHARTEVENT_MOUSE_MOVE)
   {
      int window;
      datetime time;
      double price;
      if(ChartXYToTimePrice(0, (int)lparam, (int)dparam, window, time, price))
      {
         const int b = iBarShift(_Symbol, _Period, time);
         if(b > -1)
            time = iTime(_Symbol, _Period, b);
         else
            time = (time + PeriodSeconds() / 2) / PeriodSeconds() * PeriodSeconds();
         static int day = -1;
         int now = DayOfWeek(time);
         // Comment((string)time);
         if(now != day)
         {
            day = now;
            const bool valid = WholePart * FractionalPart > 1;
            const string legend = StringFormat("%s%s%s%s", valid ? " | " : "", WholePart > 1 ? EnumToString(WholePart) : "",
               FractionalPart > 1 ? "." + EnumToString(FractionalPart) : "",
               valid ? ": ->" : "");
            PlotIndexSetString(0, PLOT_LABEL,
               StringFormat("Day: %s%s", DayName(day), legend));
            ChartRedraw(0);
         }
      }
   }
   else if(id == CHARTEVENT_CHART_CHANGE)
   {
      if(ShowLabels && _Period < PERIOD_D1) AdjustLabels();
   }
}

//+------------------------------------------------------------------+
//| Main batch processing of labels                                  |
//+------------------------------------------------------------------+
void AdjustLabels()
{
   const int left = (int)ChartGetInteger(0, CHART_FIRST_VISIBLE_BAR);
   const int width = (int)ChartGetInteger(0, CHART_VISIBLE_BARS);
   datetime overnights[][2]; // [prev day end] [next day start]
   int prevday = -1;
   
   for(int i = 0; i < width; i++)
   {
      if(left - i < 0) continue;
      const int day = DayOfWeek(iTime(_Symbol, _Period, left - i));
      if(day != prevday || left - i == 0)
      {
         datetime range[1][2] =
         {{
            (left - i > 0) ? iTime(_Symbol, _Period, left - i + 1) : iTime(_Symbol, _Period, 0) / DAY * DAY - PeriodSeconds(),
            (left - i > 0) ? iTime(_Symbol, _Period, left - i) : iTime(_Symbol, _Period, 0) / DAY * DAY + DAY
         }};
         ArrayInsert(overnights, range, ArrayRange(overnights, 0));
         prevday = day;
      }
   }
   
   const double add = Padding / 100.0 * (ChartGetDouble(0, CHART_PRICE_MAX) - ChartGetDouble(0, CHART_PRICE_MIN));
   const double price = 
      AlignTo == Top ?
      ChartGetDouble(0, CHART_PRICE_MAX) - add : (AlignTo == Bottom ? ChartGetDouble(0, CHART_PRICE_MIN) + add :
      (ChartGetDouble(0, CHART_PRICE_MAX) + ChartGetDouble(0, CHART_PRICE_MIN)) / 2);
   
   const int realFontSize = (int)(FontSize / (6 - ChartGetInteger(0, CHART_SCALE)));
   
   for(int i = 1; i < ArrayRange(overnights, 0); i++)
   {
      CreateLabel(overnights[i - 1][1], overnights[i][1] > TimeCurrent() ? overnights[i][1] : overnights[i][0] + PeriodSeconds(), price, realFontSize);
   }
   
   CleanUpLabels(iTime(_Symbol, _Period, left), iTime(_Symbol, _Period, left - width), price, realFontSize);
   ChartRedraw();
}

//+------------------------------------------------------------------+
//| Create or adjust a single label                                  |
//+------------------------------------------------------------------+
void CreateLabel(const datetime left, const datetime right, const double price, const int realFontSize)
{
   if(right - left < DAY / 2) return;
   
   iClose(_Symbol, _Period, 0);
   const int d = TimeDayOfYear(left);
   const string name = OBJ_PREFIX + (string)d;
   ObjectCreate(0, name, OBJ_TEXT, 0, (left + right) / 2, price);
   ObjectSetInteger(0, name, OBJPROP_ANCHOR, AlignTo == Top ? ANCHOR_UPPER : (AlignTo == Bottom ? ANCHOR_LOWER : ANCHOR_CENTER));
   ObjectSetString(0, name, OBJPROP_TEXT, DayName(DayOfWeek(left)) +
      (WholePart == Week || FractionalPart == Week ? "|" + (string)WeekNumber() : "") +
      (WholePart == DoY || FractionalPart == DoY ? "|" + (string)d : ""));
   ObjectSetString(0, name, OBJPROP_FONT, FontName);
   ObjectSetInteger(0, name, OBJPROP_FONTSIZE, realFontSize);
   ObjectSetInteger(0, name, OBJPROP_COLOR, FontColor != clrNONE ? FontColor : ~ChartGetInteger(0, CHART_COLOR_BACKGROUND));
   ObjectSetInteger(0, name, OBJPROP_BACK, true);
   if(AlignTo == Middle) ObjectSetDouble(0, name, OBJPROP_ANGLE, RotationAngle);
   
   PUSH(objCache, d);
}

//+------------------------------------------------------------------+
//| Remove objects outside of visible part of the chart              |
//+------------------------------------------------------------------+
void CleanUpLabels(const datetime left, const datetime right, const double price, const int realFontSize)
{
   for(int i = 0; i < ArraySize(objCache); i++)
   {
      const string name = OBJ_PREFIX + (string)objCache[i];
      const datetime t = (datetime)ObjectGetInteger(0, name, OBJPROP_TIME, 0);
      if(t != 0 && (t < left || t > (right ? right : TimeCurrent() + DAY * 7)))
      {
         ObjectDelete(0, name);
         objCache[i] = -1;
      }
      else
      {
         ObjectSetDouble(0, name, OBJPROP_PRICE, price);
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, realFontSize);
      }
   }
   ArrayPurge(objCache, -1);
}

//+------------------------------------------------------------------+
//| Helper functions                                                 |
//+------------------------------------------------------------------+

double GetPart(const InfoType part, const int i)
{
   switch(part)
   {
      case DoW:
         return _TimeDayOfWeek();
      case DoY:
         return _TimeDayOfYear();
      case Week:
         return WeekNumber();
      case Bar:
         return i;
   }
   return 0;
}

string DayName(const int DayNo)
{
   const static string Days[7] = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
   return Days[DayNo % 7];
}

int DayOfWeek(const datetime time)
{
   return (int)((time / 86400) + 4) % 7;
}

int WeekNumber(/*const datetime dt*/) // prerequisite: parameter is cached in _macros
{
   const datetime d1 = StringToTime(((string)_TimeYear(/*dt*/) + ".01.01 00:00"));
  
   return (_TimeDayOfYear() + DayOfWeek(d1)) / 7 + 1;
}

//+------------------------------------------------------------------+
