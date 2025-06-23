//+------------------------------------------------------------------+
//|                                                     Candle Range |
//|                                    Copyright © 2025 Wolfforex.com|
//|                                        https://www.wolfforex.com |
//+------------------------------------------------------------------+
#property copyright "www.Wolfforex.com, 2024"
#property version   "1.01"

#property description "Candle Range - displays candle's pip range on mouseover."
#property description "Modifiable font parameters, location, and normalization."

#property indicator_chart_window
#property indicator_plots 0

input bool ShowBodySize = false; // ShowBodySize: if true, body size will be shown too.
input bool HavePipettes = false; // HavePipettes: if true, ranges will be divided by 10.
input bool TrueRange = false;    // TrueRange: if true, use true range formula.
input color font_color = clrLightGray;
input int font_size = 10;
input string font_face = "Verdana";
input ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER;
input int distance_x = 3;
input int distance_y = 12;
input bool DrawTextAsBackground = false; //DrawTextAsBackground: if true, the text will be drawn as background.
input string ObjectPrefix = "CR-";

int n_digits = 0;
double divider = 1;

void OnInit()
{
    ObjectCreate(ChartID(), ObjectPrefix + "Range", OBJ_LABEL, 0, 0, 0);
    ObjectSetString(ChartID(), ObjectPrefix + "Range", OBJPROP_TEXT, "");
    ObjectSetInteger(ChartID(), ObjectPrefix + "Range", OBJPROP_FONTSIZE, font_size);
    ObjectSetString(ChartID(), ObjectPrefix + "Range", OBJPROP_FONT, font_face);
    ObjectSetInteger(ChartID(), ObjectPrefix + "Range", OBJPROP_COLOR, font_color);
    ObjectSetInteger(ChartID(), ObjectPrefix + "Range", OBJPROP_CORNER, corner);
    ObjectSetInteger(ChartID(), ObjectPrefix + "Range", OBJPROP_XDISTANCE, distance_x);
    ObjectSetInteger(ChartID(), ObjectPrefix + "Range", OBJPROP_YDISTANCE, distance_y);
    ObjectSetInteger(ChartID(), ObjectPrefix + "Range", OBJPROP_BACK, DrawTextAsBackground);

    if (HavePipettes)
    {
        divider = 10;
        n_digits = 1;
    }
    
    // Enable mouse move events for the chart.
    ChartSetInteger(ChartID(), CHART_EVENT_MOUSE_MOVE, true);
}

void OnDeinit(const int reason)
{
    ObjectDelete(ChartID(), ObjectPrefix + "Range");
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[]
)
{
    return rates_total;
}

void OutputRange(double range, double body)
{
    string text = "Range: " + DoubleToString(Normalize(range), n_digits);
    if (ShowBodySize) text += " Body: " + DoubleToString(Normalize(body), n_digits);
    ObjectSetString(ChartID(), ObjectPrefix + "Range", OBJPROP_TEXT, text);
    ChartRedraw();
}

double Normalize(double distance)
{
    return NormalizeDouble(distance / _Point / divider, n_digits);
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
    if (id == CHARTEVENT_MOUSE_MOVE)
    {
        int subwindow;
        datetime time;
        double price;
        ChartXYToTimePrice(ChartID(), (int)lparam, (int)dparam, subwindow, time, price);
        int i = iBarShift(Symbol(), Period(), time, true);
        if (i < 0) return;
        static double prev_range = 0;
        static double prev_body = 0;
        double range = iHigh(Symbol(), Period(), i) - iLow(Symbol(), Period(), i);
        if (TrueRange)
        {
            double range0 = 0;
            if (i < iBars(Symbol(), Period()) - 1) // Otherwise cannot calculate range0.
            {
                range0 = MathMax(MathAbs(iClose(Symbol(), Period(), i + 1) - iHigh(Symbol(), Period(), i)), MathAbs(iClose(Symbol(), Period(), i + 1) - iLow(Symbol(), Period(), i)));
            }
            range = MathMax(range, range0);
        }
        double body = MathAbs(iOpen(Symbol(), Period(), i) - iClose(Symbol(), Period(), i));
        if ((range == prev_range) && (body == prev_body)) return; // Optimization to avoid updating the range object when nothing changed.
        prev_range = range;
        prev_body = body;
        OutputRange(range, body);
    }
}
//+------------------------------------------------------------------+