//+------------------------------------------------------------------+
//|                                   Detrended Price Oscillator.mq5 |
//|                                    Copyright © 2025 Wolfforex.com|
//|                                        https://www.wolfforex.com |
//+------------------------------------------------------------------+
#property version   "1.01"

#property description "Detrended Price Oscillator tries to capture the short-term trend changes."
#property description "Indicator's cross with the zero is the best indicator of such a change."
#property description "Optional alerts on zero cross available."

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots 1
#property indicator_color1 clrBlue
#property indicator_type1 DRAW_LINE
#property indicator_level1 0
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_DOT
#property indicator_levelcolor clrDarkGray

enum enum_candle_to_check
{
    Current,
    Previous
};

input int MA_Period = 14;
input int BarsToCount = 400;
input bool EnableNativeAlerts = false;
input bool EnableEmailAlerts = false;
input bool EnablePushAlerts = false;
input enum_candle_to_check TriggerCandle = Previous;

// Global variables:
int Shift;
int MA_handle;
datetime LastAlertTime = D'01.01.1970';
int LastBars = 0;

// Buffer:
double DPO[];

void OnInit()
{
    IndicatorSetString(INDICATOR_SHORTNAME, "DPO(" + IntegerToString(MA_Period) + ")");
    SetIndexBuffer(0, DPO, INDICATOR_DATA);
    MA_handle = iMA(Symbol(), Period(), MA_Period, 0, MODE_SMA, PRICE_CLOSE);
    Shift = MA_Period / 2 + 1;
    LastBars = 0;
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &Close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
    // Too few bars to do anything.
    if (rates_total <= MA_Period) return 0;
    // If we don't have enough bars to count as specified in the input
    int limit = BarsToCount;
    if (BarsToCount >= rates_total) limit = rates_total;

    double MA[];
    if (CopyBuffer(MA_handle, 0, 0, rates_total, MA) != rates_total)
    {
        Print("Waiting for MA data...");
        return prev_calculated;
    }

    for (int i = rates_total - limit + MA_Period + 1; i < rates_total; i++)
    {
        DPO[i] = Close[i] - MA[i - Shift];
    }

    if (((TriggerCandle > 0) && (Time[rates_total - 1] > LastAlertTime)) || (TriggerCandle == 0))
    {
        // Crosses zero from below
        if ((DPO[rates_total - 2 - TriggerCandle] <= 0) && (DPO[rates_total - 1 - TriggerCandle] > 0))
        {
            if (LastBars != 0) // Skip actual alerts if it is the first run after attachment.
            {
                string NativeText = "DPO Zero Cross: DPO above zero.";
                string Text = "DPO Zero Cross: " + Symbol() + " - " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)Period()), 7) + " - DPO above zero.";
                if (EnableNativeAlerts) Alert(NativeText);
                if (EnableEmailAlerts) SendMail("DPO Zero Cross Alert - " + Symbol() + " - " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)Period()), 7), Text);
                if (EnablePushAlerts) SendNotification(Text);
            }
            LastAlertTime = Time[rates_total - 1];
        }
        // Crosses zero from above
        if ((DPO[rates_total - 2 - TriggerCandle] >= 0) && (DPO[rates_total - 1 - TriggerCandle] < 0))
        {
            if (LastBars != 0) // Skip actual alerts if it is the first run after attachment.
            {
                string NativeText = "DPO Zero Cross: DPO below zero.";
                string Text = "DPO Zero Cross: " + Symbol() + " - " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)Period()), 7) + " - DPO below zero.";
                if (EnableNativeAlerts) Alert(NativeText);
                if (EnableEmailAlerts) SendMail("DPO Zero Cross Alert - " + Symbol() + " - " + StringSubstr(EnumToString((ENUM_TIMEFRAMES)Period()), 7), Text);
                if (EnablePushAlerts) SendNotification(Text);
            }
            LastAlertTime = Time[rates_total - 1];
        }
    }

    LastBars = rates_total;
    return rates_total;
}
//+------------------------------------------------------------------+