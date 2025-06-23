/*
Copyright (C) 2021 Mateus Matucuma Teixeira

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/
#ifndef AMPLITUDE_H
#define AMPLITUDE_H
//+------------------------------------------------------------------+
//|                                                    Amplitude.mq5 |
//|                     Copyright (C) 2021, Mateus Matucuma Teixeira |
//|                                            mateusmtoss@gmail.com |
//| GNU General Public License version 2 - GPL-2.0                   |
//| https://opensource.org/licenses/gpl-2.0.php                      |
//+------------------------------------------------------------------+
// https://github.com/BRMateus2/Amplitude-Indicator/
//---- Main Properties
#property copyright "2021, Mateus Matucuma Teixeira"
#property link "https://github.com/BRMateus2/Amplitude-Indicator/"
#property description "This Indicator will show the Amplitude [Minimum; Maximum] of a given period and can act as a substitute of the ATR indicator.\n"
#property description "The indicator can be used to observe volatility and the force of past swings, useful to determine excesses that will possibly be reversed or repeated, given that the user has knowledge to complement with volume or standard-deviation strategies.\n"
#property description "It is suggested a period of 55200 at M1 or 2400 at H1 (meaning 40 sessions of 23hs each), or any period that complements your strategy."
#property version "1.05"
#property strict
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots 1
//---- Definitions
#ifndef ErrorPrint
#define ErrorPrint(Dp_error) Print("ERROR: " + Dp_error + " at \"" + __FUNCTION__ + ":" + IntegerToString(__LINE__) + "\", last internal error: " + IntegerToString(GetLastError()) + " (" + __FILE__ + ")"); ResetLastError(); DebugBreak(); // It should be noted that the GetLastError() function doesn't zero the _LastError variable. Usually the ResetLastError() function is called before calling a function, after which an error appearance is checked.
#endif
//#define INPUT const
#ifndef INPUT
#define INPUT input
#endif
//---- Input Parameters
//---- "Basic Settings"
input group "Basic Settings"
string iName; // Defined at OnInit()
const int iDigits = Digits(); // Subdigits on data
INPUT int iPeriodInp = 2400; // Amplitude of last N candles
int iPeriod = 60; // Backup iPeriod if user inserts wrong value
INPUT bool iIgnoreGapsInp = false; // Ignore gaps between candles? (Not include last close?)
INPUT bool iShowPercentageInp = true; // Show percentage instead of absolute values? (V*100 / (H+L)/2)
const int iShift = 0; // Shift data
//---- "Adaptive Period"
input group "Adaptive Period"
INPUT bool adPeriodInp = true; // Adapt the Period? Overrides Standard Period Settings
INPUT int adPeriodMinutesInp = 55200; // Period in minutes that all M and H timeframes should adapt to?
INPUT int adPeriodD1Inp = 40; // Period for D1 - Daily Timeframe
INPUT int adPeriodW1Inp = 8; // Period for W1 - Weekly Timeframe
INPUT int adPeriodMN1Inp = 2; // Period for MN - Monthly Timeframe
//---- Indicator Indexes, Buffers and Handlers
const int iBufIndex = 0;
double iBuf[];
//---- Plot Definitions
input group "Plot Definitions";
// iBuf
input group "Amplitude";
const string iBufLabel = "Amplitude";
INPUT color iBufColor = clrTurquoise; // Drawing Color
const ENUM_DRAW_TYPE iBufDraw = DRAW_LINE; // Drawing Type
INPUT ENUM_LINE_STYLE iBufStyle = STYLE_SOLID; // Drawing Style
INPUT int iBufWidth = 1; // Drawing Width
//---- PlotIndexSetString() Timer optimization, updates once per second
datetime last = 0;
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// Constructor or initialization function
// https://www.mql5.com/en/docs/basis/function/events
// https://www.mql5.com/en/articles/100
//+------------------------------------------------------------------+
int OnInit()
{
// User and Developer Input scrutiny
    if(adPeriodInp == true) { // Calculate iPeriod if period_adaptive_inp == true. Adaptation works flawless for less than D1 - D1, W1 and MN1 are a constant set by the user.
        if((PeriodSeconds(PERIOD_CURRENT) < PeriodSeconds(PERIOD_D1)) && (PeriodSeconds(PERIOD_CURRENT) >= PeriodSeconds(PERIOD_M1))) {
            if(adPeriodMinutesInp > 0) {
                int iPeriodCalc = ((adPeriodMinutesInp * 60) / PeriodSeconds(PERIOD_CURRENT));
                if(iPeriodCalc == 0) { // If the division is less than 1, then we have to complement to a minimum, user can also hide on timeframes that are not needed.
                    iPeriod = iPeriodCalc + 1;
                } else if(iPeriod < 0) {
                    ErrorPrint("calculation error with \"iPeriod = ((adPeriodMinutesInp * 60) / PeriodSeconds(PERIOD_CURRENT))\". Indicator will use value \"" + IntegerToString(iPeriod) + "\" for calculations."); // iPeriod is already defined
                } else { // If iPeriodCalc is not zero, neither negative, them it is valid.
                    iPeriod = iPeriodCalc;
                }
            } else {
                ErrorPrint("wrong value for \"adPeriodMinutesInp\" = \"" + IntegerToString(adPeriodMinutesInp) + "\". Indicator will use value \"" + IntegerToString(iPeriod) + "\" for calculations."); // iPeriod is already defined
            }
        } else if(PeriodSeconds(PERIOD_CURRENT) == PeriodSeconds(PERIOD_D1)) {
            if(adPeriodD1Inp > 0) {
                iPeriod = adPeriodD1Inp;
            } else {
                ErrorPrint("wrong value for \"adPeriodD1Inp\" = \"" + IntegerToString(adPeriodD1Inp) + "\". Indicator will use value \"" + IntegerToString(iPeriod) + "\" for calculations."); // iPeriod is already defined
            }
        } else if(PeriodSeconds(PERIOD_CURRENT) == PeriodSeconds(PERIOD_W1)) {
            if(adPeriodW1Inp > 0) {
                iPeriod = adPeriodW1Inp;
            } else {
                ErrorPrint("wrong value for \"adPeriodW1Inp\" = \"" + IntegerToString(adPeriodW1Inp) + "\". Indicator will use value \"" + IntegerToString(iPeriod) + "\" for calculations."); // iPeriod is already defined
            }
        } else if(PeriodSeconds(PERIOD_CURRENT) == PeriodSeconds(PERIOD_MN1)) {
            if(adPeriodMN1Inp > 0) {
                iPeriod = adPeriodMN1Inp;
            } else {
                ErrorPrint("wrong value for \"adPeriodMN1Inp\" = \"" + IntegerToString(adPeriodMN1Inp) + "\". Indicator will use value \"" + IntegerToString(iPeriod) + "\" for calculations."); // iPeriod is already defined
            }
        } else {
            ErrorPrint("untreated condition. Indicator will use value \"" + IntegerToString(iPeriod) + "\" for calculations."); // iPeriod is already defined
        }
    } else if(iPeriodInp <= 0 && adPeriodInp == false) {
        ErrorPrint("wrong value for \"iPeriodInp\" = \"" + IntegerToString(iPeriodInp) + "\". Indicator will use value \"" + IntegerToString(iPeriod) + "\" for calculations."); // iPeriod is already defined
    } else {
        iPeriod = iPeriodInp;
    }
// Treat Indicator
    if(iShowPercentageInp) {
        if(!IndicatorSetInteger(INDICATOR_DIGITS, 2)) { // Indicator subdigit precision
            ErrorPrint("IndicatorSetInteger(INDICATOR_DIGITS, 2)");
            return INIT_FAILED;
        }
    } else {
        if(!IndicatorSetInteger(INDICATOR_DIGITS, iDigits)) { // Indicator subdigit precision
            ErrorPrint("IndicatorSetInteger(INDICATOR_DIGITS, iDigits)");
            return INIT_FAILED;
        }
    }
// Treat iBuf
    if(!PlotIndexConstruct(iBufIndex, iBufLabel, iBufColor, iBuf, INDICATOR_DATA, iBufDraw, iShift, iBufStyle, iBufWidth, iPeriod)) {
        ErrorPrint("");
    }
// Indicator Subwindow Short Name
    iName = StringFormat("A(%d)", iPeriod); // Indicator name in Subwindow
    if(!IndicatorSetString(INDICATOR_SHORTNAME, iName)) { // Set Indicator name
        ErrorPrint("IndicatorSetString(INDICATOR_SHORTNAME, iName)");
        return INIT_FAILED;
    }
    return INIT_SUCCEEDED;
}
//+------------------------------------------------------------------+
// Calculation function
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
    if(rates_total < iPeriod) { // No need to calculate if the data is less than the requested iPeriod - it is returned as 0, because if we return rates_total, then the terminal interprets that the indicator has valid data
        return 0;
    }
    /*
        Math Function:
            On proposed Amplitude of a single candle, represents the MinMax of that candle, where:
                MinMax = Max - Min, if Max >= 0;
                MinMax = Min - Max, if Max < 0;
            For a iPeriod larger than 1, I propose the MinMax of the last X candles, where X equals to the iPeriod:
                MinMax = Highest Max - Lowest Min, where Highest and Lowest from the last X data points, if Max >= 0;
                MinMax = Lowest Min - Highest Max, where Highest and Lowest from the last X data points, if Max < 0;
            Since the first X candles are expected to be invalid, because there is no X < 0 data point, it will be skipped.

            If the setting Ignore Gaps is set, then the amplitude between last close candle and "current calculating candle" are not used, meaning the values are not absolutely-contiguous (in other words, gaps (auctions or broker gaps) are not meaningful at all when iPeriod is equal to 1).
    */
// Main loop of calculations
    int i = (prev_calculated - 1);
    for(; i < rates_total && !IsStopped(); i++) {
        if(i < 0) {
            continue;
        }
        double highest = DBL_MIN;
        double lowest = DBL_MAX;
        for(int j = (i - iPeriod + 1); j <= i && !IsStopped(); j++) {
            if(j < 0) {
                continue;
            }
            if(highest < (iIgnoreGapsInp ? high[j] : (j == 0 ? high[j] : MathMax(high[j], close[j - 1])))) {
                highest = (iIgnoreGapsInp ? high[j] : (j == 0 ? high[j] : MathMax(high[j], close[j - 1])));
            }
            if(lowest > (iIgnoreGapsInp ? low[j] : (j == 0 ? low[j] : MathMin(low[j], close[j - 1])))) {
                lowest = (iIgnoreGapsInp ? low[j] : (j == 0 ? low[j] : MathMin(low[j], close[j - 1])));
            }
        }
        iBuf[i] = iShowPercentageInp ? ((highest - lowest) * 100.0 / (MathAbs(highest + lowest) / 2.0)) : (highest - lowest);
    }
    if(i == rates_total && last < TimeCurrent()) {
        last = TimeCurrent();
        if(iShowPercentageInp) {
            if(!PlotIndexSetString(iBufIndex, PLOT_LABEL, "Relative Amplitude (" + DoubleToString(iBuf[i - 1], 2) + "%)")) {
                ErrorPrint("!PlotIndexSetString(iBufIndex, PLOT_LABEL, \"Relative Amplitude (\" + DoubleToString(iBuf[i - 1], 2) + \"%)\")");
            }
        } else {
            if(!PlotIndexSetString(iBufIndex, PLOT_LABEL, "Absolute Amplitude (" + DoubleToString(iBuf[i - 1], iDigits) + ")")) {
                ErrorPrint("!PlotIndexSetString(iBufIndex, PLOT_LABEL, \"Absolute Amplitude (\" + DoubleToString(iBuf[i - 1], iDigits) + \")\")");
            }
        }
    }
    return rates_total; // Calculations are done and valid
}
//+------------------------------------------------------------------+
// Deinitialization
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    return;
}
//+------------------------------------------------------------------+
// Extra functions, utilities and conversion
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// PlotIndexConstruct, substitute for common call
// Fixed Issue: the function solves a issue with the platform #property, where every single time the .ex5 file is updated or recompiled, all of the Plot (color, etc) user settings are reset - this function is not made for Levels.
//+------------------------------------------------------------------+
bool PlotIndexConstruct(const int plotIndex,
                        const string plotLabel,
                        const color plotColor,
                        double& plotBuffer[], // Cannot set this to const, because SetIndexBuffer() parameter is not const
                        const ENUM_INDEXBUFFER_TYPE plotIndexType = INDICATOR_DATA,
                        const ENUM_DRAW_TYPE plotDraw = DRAW_LINE,
                        const int plotShift = 0,
                        const ENUM_LINE_STYLE plotStyle = STYLE_SOLID,
                        const int plotWidth = 1,
                        const int plotBegin = 0,
                        const bool plotShowOnDatawindow = true,
                        const double plotEmptyValue = 0.0)
{
    bool success = true;
    if(!SetIndexBuffer(plotIndex, plotBuffer, plotIndexType)) {
        ErrorPrint("!SetIndexBuffer(plotIndex, plotBuffer, plotIndexType)");
        success = false;
    }
    if(!PlotIndexSetString(plotIndex, PLOT_LABEL, plotLabel)) {
        ErrorPrint("!PlotIndexSetString(plotIndex, PLOT_LABEL, plotLabel)");
        success = false;
    }
    if(!PlotIndexSetInteger(plotIndex, PLOT_LINE_COLOR, plotColor)) {
        ErrorPrint("!PlotIndexSetInteger(plotIndex, PLOT_LINE_COLOR, plotColor)");
        success = false;
    }
    if(plotDraw != DRAW_ARROW) {
        if(!PlotIndexSetInteger(plotIndex, PLOT_DRAW_TYPE, plotDraw)) {
            ErrorPrint("!PlotIndexSetInteger(plotIndex, PLOT_DRAW_TYPE, plotDraw)");
            success = false;
        }
        if(!PlotIndexSetInteger(plotIndex, PLOT_SHIFT, plotShift)) {
            ErrorPrint("!PlotIndexSetInteger(plotIndex, PLOT_SHIFT, plotShift)");
            success = false;
        }
    } else {
        if(!PlotIndexSetInteger(plotIndex, PLOT_DRAW_TYPE, plotDraw)) {
            ErrorPrint("!PlotIndexSetInteger(plotIndex, PLOT_DRAW_TYPE, plotDraw)");
            success = false;
        }
        if(!PlotIndexSetInteger(plotIndex, PLOT_ARROW_SHIFT, plotShift)) {
            ErrorPrint("!PlotIndexSetInteger(plotIndex, PLOT_ARROW_SHIFT, plotShift)");
            success = false;
        }
    }
    if(!PlotIndexSetInteger(plotIndex, PLOT_LINE_STYLE, plotStyle)) {
        ErrorPrint("!PlotIndexSetInteger(plotIndex, PLOT_LINE_STYLE, plotStyle)");
        success = false;
    }
    if(!PlotIndexSetInteger(plotIndex, PLOT_LINE_WIDTH, plotWidth)) {
        ErrorPrint("!PlotIndexSetInteger(plotIndex, PLOT_LINE_WIDTH, plotWidth)");
        success = false;
    }
    if(!PlotIndexSetInteger(plotIndex, PLOT_DRAW_BEGIN, plotBegin)) {
        ErrorPrint("!PlotIndexSetInteger(plotIndex, PLOT_DRAW_BEGIN, plotBegin)");
        success = false;
    }
    if(!PlotIndexSetInteger(plotIndex, PLOT_SHOW_DATA, plotShowOnDatawindow)) {
        ErrorPrint("!PlotIndexSetInteger(plotIndex, PLOT_SHOW_DATA, plotShowOnDatawindow)");
        success = false;
    }
    if(!PlotIndexSetDouble(plotIndex, PLOT_EMPTY_VALUE, plotEmptyValue)) {
        ErrorPrint("!PlotIndexSetDouble(plotIndex, PLOT_EMPTY_VALUE, plotEmptyValue)");
        success = false;
    }
    return success;
}
//+------------------------------------------------------------------+
//| Creating Chart object
//+------------------------------------------------------------------+
bool ObjectChartCreate(const string symbol, // Symbol
                       const long chart_ID = 0, // Chart ID
                       const int sub_window = 0, // Subwindow Index
                       const string name = "Chart", // Object Name
                       const ENUM_TIMEFRAMES period = PERIOD_H1, // Period
                       const long x = 0, // X Coordinate
                       const long y = 0, // Y Coordinate
                       const long width = 300, // Width
                       const long height = 200, // Height
                       const ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER, // Anchoring Corner
                       const long scale = 2, // Scale
                       const bool date_scale = true, // Time Scale display
                       const bool price_scale = true, // Price Scale display
                       const color clr = clrRed, // Border color when highlighted
                       const ENUM_LINE_STYLE style = STYLE_SOLID, // Line Style when highlighted
                       const long point_width = 1, // Move Point size
                       const bool back = false, // In the background
                       const bool selection = false, // Highlight to move
                       const bool hidden = true, // Hidden in the Object List
                       const long z_order = 0) // Priority for mouse click
{
    if(!ObjectCreate(chart_ID, name, OBJ_CHART, sub_window, 0, 0)) {
        ErrorPrint("!ObjectCreate(chart_ID, name, OBJ_CHART, sub_window, 0, 0)");
        return false;
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x)) { // Wont be returning false, because supposedly the ObjectCreate() was successful at this point
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_XDISTANCE, x)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_YDISTANCE, y)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_XSIZE, width)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_YSIZE, height)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_CORNER, corner)");
    }
    if(!ObjectSetString(chart_ID, name, OBJPROP_SYMBOL, symbol)) {
        ErrorPrint("!ObjectSetString(chart_ID, name, OBJPROP_SYMBOL, symbol)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_PERIOD, period)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_PERIOD, period)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_CHART_SCALE, scale)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_CHART_SCALE, scale)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_DATE_SCALE, date_scale)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_DATE_SCALE, date_scale)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_PRICE_SCALE, price_scale)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_PRICE_SCALE, price_scale)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, point_width)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, point_width)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden)");
    }
    if(!ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order)) {
        ErrorPrint("!ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order)");
    }
    return true;
}
//+------------------------------------------------------------------+
//| Header Guard #endif
//+------------------------------------------------------------------+
#endif
//+------------------------------------------------------------------+
