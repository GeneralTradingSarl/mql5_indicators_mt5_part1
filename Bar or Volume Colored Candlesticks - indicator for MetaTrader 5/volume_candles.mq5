/*
Copyright (C) 2021 Mateus Matucuma Teixeira

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/
#ifndef VOLUMECANDLES_H
#define VOLUMECANDLES_H
//+------------------------------------------------------------------+
//|                                               Volume Candles.mq5 |
//|                     Copyright (C) 2021, Mateus Matucuma Teixeira |
//|                                            mateusmtoss@gmail.com |
//| GNU General Public License version 2 - GPL-2.0                   |
//| https://opensource.org/licenses/gpl-2.0.php                      |
//+------------------------------------------------------------------+
// https://github.com/BRMateus2/
//---- Main Properties
#property copyright "2021, Mateus Matucuma Teixeira"
#property link "https://github.com/BRMateus2/"
#property description "Volume Colored Candlestick with Bollinger Bands as the Standard Deviation"
#property version "1.02"
#property fpfast
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots 1
//---- Imports
//---- Include Libraries and Modules
//#include <MT-Utilities.mqh>
// Metatrader 5 has a limitation of 64 User Input Variable description, for reference this has 64 traces ----------------------------------------------------------------
//---- Definitions
#ifndef ErrorPrint
#define ErrorPrint(Dp_error) Print("ERROR: " + Dp_error + " at \"" + __FUNCTION__ + ":" + IntegerToString(__LINE__) + "\", last internal error: " + IntegerToString(GetLastError()) + " (" + __FILE__ + ")"); ResetLastError(); DebugBreak(); // It should be noted that the GetLastError() function doesn't zero the _LastError variable. Usually the ResetLastError() function is called before calling a function, after which an error appearance is checked.
#endif
//#define INPUT const
#ifndef INPUT
#define INPUT input
#endif
//---- Input Parameters
//---- Class Definitions
//---- "Basic Settings"
input group "Basic Settings"
string iName = "VolumeCandles";
INPUT int iPeriodInp = 1440; // Period of Bollinger Bands
int iPeriod = 60; // Backup iPeriod if user inserts wrong value
INPUT double iBandsDev = 2.0; // Bollinger Bands Standard Deviation
INPUT double iSensitivity = 1.0; // Sensitivity, default 1.0, lower means less sensitive
INPUT bool iShowIndicators = false; // Calibration: show calculation indicators in chart
INPUT bool iShowGradient = false; // Calibration: show gradients in chart
// Explanation: we want to have three gradients, from [cLow; cMean[ and [cMean; cHigh], but to cHigh be inclusive, we need a module of cGradientSize % cCount equal to 1, as it happens that is the slot needed for cHigh to be correctly placed in the Index - for every extra gradient, there must be one "free slot" to put the last color
INPUT color cLow = 0xF0E040; // Low Volume
INPUT color cAvg = 0x00F0E0; // Average Volume
INPUT color cHigh = 0x2020FF; // High Volume
const int cCount = 2; // Counter of gradient variations (cLow->cMean is one, cMean->cHigh is the second)
const int cGradientSize = 63; // Has a platform limit of 64! There is also some math craziness to make the gradients fit all colors without loss
const int cGradientParts = (cGradientSize / cCount); // Counter of the parts
// Applied to
INPUT ENUM_APPLIED_VOLUME ENUM_APPLIED_VOLUMEInp = VOLUME_TICK; // Volume by "Ticks" or by "Real"
//INPUT ENUM_APPLIED_PRICE ENUM_APPLIED_PRICEInp = PRICE_CLOSE; // Applied Price Equation
//INPUT ENUM_MA_METHOD ENUM_MA_METHODInp = MODE_SMA; // Applied Moving Average Method
//const int iShift = 0; // Shift data
//---- "Adaptive Period"
input group "Adaptive Period"
INPUT bool adPeriodInp = true; // Adapt the Period? Overrides Standard Period Settings
INPUT int adPeriodMinutesInp = 27600; // Period in minutes that all M and H timeframes should adapt to?
INPUT int adPeriodD1Inp = 20; // Period for D1 - Daily Timeframe
INPUT int adPeriodW1Inp = 4; // Period for W1 - Weekly Timeframe
INPUT int adPeriodMN1Inp = 1; // Period for MN - Monthly Timeframe
//---- Indicator Indexes, Buffers and Handlers
int iVolHandle = 0;
//double iVolBuf[] = {};
int iBandsBufUpperI = 5;
int iBandsBufMiddleI = 6;
int iBandsBufLowerI = 7;
int iBandsHandle = 0;
double iBandsBufUpper[] = {};
double iBandsBufMiddle[] = {};
double iBandsBufLower[] = {};
int iBufOpenI = 0; // Index for Open Buffer values, also this is the first index and is the most important for setting the next plots
double iBufOpen[] = {}; // Open Buffer values
int iBufHighI = 1;
double iBufHigh[] = {};
int iBufLowI = 2;
double iBufLow[] = {};
int iBufCloseI = 3;
double iBufClose[] = {};
int iBufColorI = 4;
double iBufColor[] = {}; // Colors have 8+8+8 bits in this representation, value up to 2^(8+8+8) - 1, meaning [0; 16777216[ and it is represented as 0x## for Red, 0x##00 for Green and 0x##0000 for Blue - Alpha at 0xFF000000 is INVALID! Meaning there is no transparency
int subwindow = 0; // Subwindow which iShowIndicators will be used
string iVolName = ""; // Should be released if created
string iBandsName = ""; // Should be released if created
//---- Objects
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
    // iSensitivity should not be Zero, neither negative, or else Exception Division by Zero, or undesirable calculations resulting in negative
    if(iSensitivity < 0.001) {
        ErrorPrint("Sensitivity cannot be smaller than 0.001");
        return INIT_PARAMETERS_INCORRECT;
    }
    // Check for free slot in the Color Indexes
    if((cGradientSize % cCount) != 1) {
        ErrorPrint("cGradientSize is not divisible by cCount without there being one free slot, as for the fact that [cGradients; ...; cGradients] can't be closed correctly");
        return INIT_PARAMETERS_INCORRECT;
    }
    // Treat Indicator
    // Treat Handlers and Buffers
    iVolHandle = iVolumes(Symbol(), Period(), ENUM_APPLIED_VOLUMEInp);
    if(iVolHandle == INVALID_HANDLE || iVolHandle < 0) {
        ErrorPrint("iVolHandle == INVALID_HANDLE || iVolHandle < 0");
        return INIT_FAILED;
    }
    iBandsHandle = iBands(Symbol(), Period(), iPeriod, 0, iBandsDev, iVolHandle);
    if(iBandsHandle == INVALID_HANDLE || iBandsHandle < 0) {
        ErrorPrint("iBandsHandle == INVALID_HANDLE || iBandsHandle < 0");
        return INIT_FAILED;
    }
    if(iShowIndicators) {
        // Receive the number of a new subwindow, to which we will try to add the indicator
        subwindow = (int) ChartGetInteger(ChartID(), CHART_WINDOWS_TOTAL);
        if(!ChartIndicatorAdd(ChartID(), subwindow, iVolHandle)) {
            ErrorPrint("!ChartIndicatorAdd(ChartID(), subwindow, iVolHandle)");
            return INIT_FAILED;
        }
        iVolName = ChartIndicatorName(ChartID(), subwindow, 0); // Save the name so we can delete at OnDeinit()
        if(!ChartIndicatorAdd(ChartID(), subwindow, iBandsHandle)) {
            ErrorPrint("!ChartIndicatorAdd(ChartID(), subwindow, iBandsHandle)");
            return INIT_FAILED;
        }
        iBandsName = ChartIndicatorName(ChartID(), subwindow, 1);
    }
    // DRAW_COLOR_CANDLES is a specific plotting, which must be coded manually - those are the important sets
    if(!SetIndexBuffer(iBufOpenI, iBufOpen, INDICATOR_DATA)) {
        ErrorPrint("");
        return INIT_FAILED;
    }
    if(!SetIndexBuffer(iBufHighI, iBufHigh, INDICATOR_DATA)) {
        ErrorPrint("");
        return INIT_FAILED;
    }
    if(!SetIndexBuffer(iBufLowI, iBufLow, INDICATOR_DATA)) {
        ErrorPrint("");
        return INIT_FAILED;
    }
    if(!SetIndexBuffer(iBufCloseI, iBufClose, INDICATOR_DATA)) {
        ErrorPrint("");
        return INIT_FAILED;
    }
    if(!SetIndexBuffer(iBufColorI, iBufColor, INDICATOR_COLOR_INDEX)) {
        ErrorPrint("");
        return INIT_FAILED;
    }
    // Treat Plots
    if(!PlotIndexSetInteger(iBufOpenI, PLOT_DRAW_TYPE, DRAW_COLOR_CANDLES)) { // You can just set 0 in place of iBufOpenI, but it might be possible to have multiple colored plots, and the first Index for a colored draw is what defines its colors
        ErrorPrint("");
        return INIT_FAILED;
    }
    // Define a value which will not plot, if any of the buffers has this value
    if(!PlotIndexSetDouble(iBufOpenI, PLOT_EMPTY_VALUE, DBL_MIN)) {  // You can set 0.0 in place of DBL_MIN, but it will cause invisible candlesticks if any of the buffers is at 0.0
        ErrorPrint("");
        return INIT_FAILED;
    }
    if(!PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, cGradientSize)) { // Set the color indexes to be of size cGradientSize
        ErrorPrint("");
        return INIT_FAILED;
    }
    if(!SetIndexBuffer(iBandsBufUpperI, iBandsBufUpper, INDICATOR_CALCULATIONS)) {
        ErrorPrint("");
        return INIT_FAILED;
    }
    if(!SetIndexBuffer(iBandsBufMiddleI, iBandsBufMiddle, INDICATOR_CALCULATIONS)) {
        ErrorPrint("");
        return INIT_FAILED;
    }
    if(!SetIndexBuffer(iBandsBufLowerI, iBandsBufLower, INDICATOR_CALCULATIONS)) {
        ErrorPrint("");
        return INIT_FAILED;
    }
    // Set color for each index
    for(int i = 0; i < cGradientParts; i++) {
        PlotIndexSetInteger(iBufOpenI, PLOT_LINE_COLOR, i, argbGradient(cLow, cAvg, (1.0 - (((double) cGradientParts - i) / cGradientParts)))); // [cLow; cAvg[ on 31 elements, cAvg is not part of the 31 elements, [0; 30] indexable elements
        PlotIndexSetInteger(iBufOpenI, PLOT_LINE_COLOR, i + cGradientParts, argbGradient(cAvg, cHigh, (1.0 - (((double) cGradientParts - i) / cGradientParts)))); // [cAvg; cHigh[ on 31 elements, [31; 62] indexable elements
    }
    PlotIndexSetInteger(iBufOpenI, PLOT_LINE_COLOR, (cGradientSize - 1), argbGradient(cAvg, cHigh, 1.0)); // Set the last slot, to finalize [cAvg; cHigh] a full 32 elements, totalling 63 colors - yes, it is "biased by one" because cAvg is at slot 31, and we now have [32; 63] between ]cAvg; cHigh]
    //for(int i = 0; i < cGradientSize+1; i++) Print(IntegerToString(i, 2, '0') + " " + ColorToString(PlotIndexGetInteger(iBufOpenI, PLOT_LINE_COLOR, i))); // Debug
    // Indicator Subwindow Short Name
    iName = StringFormat("VC(%d)", iPeriod); // Indicator name in Subwindow
    if(!IndicatorSetString(INDICATOR_SHORTNAME, iName)) { // Set Indicator name
        ErrorPrint("IndicatorSetString(INDICATOR_SHORTNAME, iName)");
        return INIT_FAILED;
    }
    // Set the starting/default formatting for the candles
    PlotIndexSetString(iBufOpenI, PLOT_LABEL, "Open;" + "High;" + "Low;" + "Close"); // A strange formatting where ';' defines the separators, it is always Open;High;Low;Close and there are no additional values
    // Treat Objects
    return INIT_SUCCEEDED;
}
//+------------------------------------------------------------------+
// Destructor or Deinitialization function
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    if(iShowIndicators) {
        ChartIndicatorDelete(ChartID(), subwindow, iVolName);
        ChartIndicatorDelete(ChartID(), subwindow, iBandsName);
    }
    IndicatorRelease(iVolHandle);
    IndicatorRelease(iBandsHandle);
    return;
}
//+------------------------------------------------------------------+
// Calculation function
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime & time[],
                const double & open[],
                const double & high[],
                const double & low[],
                const double & close[],
                const long & tick_volume[],
                const long & volume[],
                const int& spread[])
{
    // Guarantee that Invalid Bars don't have Invalid Chart Data (hide uncalculable Bars), also check for Minimum Bars
    static int chartBars = 0;
    static int chartBarsLast = 0;
    chartBars = Bars(Symbol(), PERIOD_CURRENT);
    if((chartBars != chartBarsLast) && (!iShowGradient)) {
        if((chartBars != 0) && (chartBars < iPeriod)) {
            ErrorPrint("not enough past data to calculate, the Indicator has \"" + IntegerToString(chartBars) + "\" bars and needs \"" + IntegerToString(iPeriod) + "\" bars");
        }
        chartBarsLast = chartBars;
        for(int i = 0; i < iPeriod && i < rates_total; i++) {
            iBufOpen[i] = DBL_MIN; // We only need to set iBufOpen, because it is the only checked Buffer
        }
    }
    if(rates_total < iPeriod) { // No need to calculate if the Data is less than the requested Period - it is returned as 0, because if we return rates_total, then the terminal interprets that the Indicator has Valid Data
        return 0;
    } else if((BarsCalculated(iVolHandle) < rates_total) || (BarsCalculated(iBandsHandle) < rates_total)) { // Indicator Data is still not ready
        return 0;
    }
    if((CopyBuffer(iBandsHandle, 1, 0, (rates_total - prev_calculated + 1), iBandsBufUpper) <= 0) || (CopyBuffer(iBandsHandle, 0, 0, (rates_total - prev_calculated + 1), iBandsBufMiddle) <= 0) || (CopyBuffer(iBandsHandle, 2, 0, (rates_total - prev_calculated + 1), iBandsBufLower) <= 0)) { // Try to copy, if there is no data copied for some reason, then we don't need to calculate - also, we don't need to copy rates before prev_calculated as they have the same result
        ErrorPrint("");
        return 0;
    }
    // Only used if iShowGradient
    static int iShowGradientColors = 0;
    static int iShowGradientBars = 0;
    // Main loop of calculations
    int i = (((prev_calculated - 1) > iPeriod) ? (prev_calculated - 1) : (iShowGradient ? 0 : iPeriod));
    for(; i < rates_total && !IsStopped(); i++) {
        iBufOpen[i] = open[i];
        iBufHigh[i] = high[i];
        iBufLow[i] = low[i];
        iBufClose[i] = close[i];
        if(((ENUM_APPLIED_VOLUMEInp == VOLUME_TICK) ? tick_volume[i] : volume[i]) > iBandsBufMiddle[i]) {
            // Normalization Formula's -> xNormalized = (x - xMinimum) / (xMaximum - xMinimum), where x = Volume, xMinimum = iBandsBufMiddle and xMaximum = iBandsBufUpper
            double indexColor = (MathRound((
                                               iSensitivity *
                                               (((ENUM_APPLIED_VOLUMEInp == VOLUME_TICK) ? (tick_volume[i] - iBandsBufMiddle[i]) : (volume[i] - iBandsBufMiddle[i]))
                                                / (((iBandsBufUpper[i] - iBandsBufMiddle[i]) == 0.0) ? 1.0 : (iBandsBufUpper[i] - iBandsBufMiddle[i]))
                                               ))
                                           * (double) cGradientParts
                                          )
                                 + cGradientParts);
            if(indexColor < cGradientParts) indexColor = cGradientParts;
            else if(indexColor >= cGradientSize) indexColor = cGradientSize - 1;
            iBufColor[i] = indexColor;
        } else { // The comparison of BufLower and 0.0, is because volume should never be negative; the stddev does not consider this fact and biases the lower color indexes to never show, depending on the situation - the comparison fixes the lower indexes not showing, but biases towards a lower-index color below BufMiddle, which seems to be acceptable
            // Normalization Formula's -> xNormalized = (x - xMinimum) / (xMaximum - xMinimum), where x = Volume, xMinimum = iBandsBufLower and xMaximum = iBandsBufMiddle
            double indexColor = MathRound((
                                              (1.0 / iSensitivity) *
                                              (((ENUM_APPLIED_VOLUMEInp == VOLUME_TICK) ? (tick_volume[i] - (iBandsBufLower[i] < 0.0 ? 0.0 : iBandsBufLower[i])) : (volume[i] - (iBandsBufLower[i] < 0.0 ? 0.0 : iBandsBufLower[i])))
                                               / (((iBandsBufMiddle[i] - ((iBandsBufLower[i] < 0.0) ? 0.0 : iBandsBufLower[i])) == 0.0) ? 1.0 : (iBandsBufMiddle[i] - ((iBandsBufLower[i] < 0.0) ? 0.0 : iBandsBufLower[i])))
                                              ))
                                          * (double) cGradientParts
                                         );
            if(indexColor < 0.0) indexColor = 0.0;
            else if(indexColor > cGradientParts) indexColor = cGradientParts - 1;
            iBufColor[i] = indexColor;
        }
        if(iShowGradient) {
            iBufColor[i] = iShowGradientColors;
            if(iShowGradientBars != Bars(Symbol(), PERIOD_CURRENT)) iShowGradientColors++; // Comment this line for color change at every tick, else at every new bar
            //iShowGradientColors++; // Comment this line for color change at every bar, else at every new tick
            if(iShowGradientColors >= cGradientSize) iShowGradientColors = 0; // Upper limit for iShowGradientColors indexer
        }
    }
    //PlotIndexSetString(iBufOpenI, PLOT_LABEL, (
    //                       "Lastest candle values: \n" +
    //                       "O: " + DoubleToString(iBufOpen[i - 1], Digits()) +
    //                       "\nH: " + DoubleToString(iBufHigh[i - 1], Digits()) +
    //                       "\nL: " + DoubleToString(iBufLow[i - 1], Digits()) +
    //                       "\nC: " + DoubleToString(iBufClose[i - 1], Digits()) +
    //                       "\nSpr: " + DoubleToString(spread[i - 1]) +
    //                       "\n Past Open;" +
    //                       "Lastest candle values: \n" +
    //                       "O: " + DoubleToString(iBufOpen[i - 1], Digits()) +
    //                       "\nH: " + DoubleToString(iBufHigh[i - 1], Digits()) +
    //                       "\nL: " + DoubleToString(iBufLow[i - 1], Digits()) +
    //                       "\nC: " + DoubleToString(iBufClose[i - 1], Digits()) +
    //                       "\nSpr: " + DoubleToString(spread[i - 1]) +
    //                       "\n Past High;" +
    //                       "Lastest candle values: \n" +
    //                       "O: " + DoubleToString(iBufOpen[i - 1], Digits()) +
    //                       "\nH: " + DoubleToString(iBufHigh[i - 1], Digits()) +
    //                       "\nL: " + DoubleToString(iBufLow[i - 1], Digits()) +
    //                       "\nC: " + DoubleToString(iBufClose[i - 1], Digits()) +
    //                       "\nSpr: " + DoubleToString(spread[i - 1]) +
    //                       "\n Past Low;" +
    //                       "Lastest candle values: \n" +
    //                       "O: " + DoubleToString(iBufOpen[i - 1], Digits()) +
    //                       "\nH: " + DoubleToString(iBufHigh[i - 1], Digits()) +
    //                       "\nL: " + DoubleToString(iBufLow[i - 1], Digits()) +
    //                       "\nC: " + DoubleToString(iBufClose[i - 1], Digits()) +
    //                       "\nSpr: " + DoubleToString(spread[i - 1]) +
    //                       "\n Past Close;"
    //                   )); // There is no need for this, for performance reasons and because the old data is not saved (it prints only the Lastest ones), and the ';' separator does the job of changing past candles
    if(iShowGradient) {
        iShowGradientBars = Bars(Symbol(), PERIOD_CURRENT);
    }
    return rates_total; // Calculations are done and valid
}
//+------------------------------------------------------------------+
// Extra functions, utilities and conversion
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// Color
// Parameters c1 and c2 are ARGB Colors to Gradient into the return value
// Gradient and Alpha is a percentage from c1 towards c2, accepts any range, but anything out of [0; 1.0] is cut
// The return value of the function is guaranteed to be between [0xYY000000; 0xYYFFFFFF], even if the gradient is invalid, and YY equals to the Alpha between [0; 1.0] -> AA[0; 255]
// If using "colors", which is a MQL5 type for 24-bit RGB color with no Alpha, Alpha should be 0.0, and c1 Alpha (bits [24; 32[) should be Zero, or it will mess with the printed colors
//+------------------------------------------------------------------+
uint argbGradient(uint c1, uint c2, double gradient = 0.5, double alpha = 0.0)
{
    uint c = 0x00000000;
    // Red is at 0x000000##
    // Green is at 0x0000##00
    // Blue is at 0x00##0000
    // There is no Alpha for Plots and Buffers, but for some reason, the function ColorToARGB() exists in the documentation, for Alpha at 0x##000000
    if(gradient > 1.0) gradient = 1.0; // Guarantees range [+0.0; +1.0]
    else if (gradient < +0.0) gradient = +0.0;
    if(alpha > 1.0) alpha = 1.0;
    else if(alpha < +0.0) alpha = +0.0;
    uint red1 = (c1 & 0xFF); // Bitwise/extract the first 16 binary digits
    uint green1 = (c1 & 0xFF00) >> 8; // Bitwise/extract the binary digits, ranging from [16;31], and Bitshift them 16 binary moves towards zero, shifted to [0; 15]
    uint blue1 = (c1 & 0xFF0000) >> 16;
    uint alpha1 = (c1 & 0xFF000000) >> 24;
    uint red2 = (c2 & 0xFF);
    uint green2 = (c2 & 0xFF00) >> 8;
    uint blue2 = (c2 & 0xFF0000) >> 16;
    uint alpha2 = (c2 & 0xFF000000) >> 24;
    if(red1 > red2) c = (red1 - ((uint) ((red1 - red2) * gradient))) & 0xFF; // Comparison guarantees no overflow, which is Undefined Behaviour
    else c = (red1 + ((uint) ((red2 - red1) * gradient))) & 0xFF;
    if(green1 > green2) c = (((green1 - ((uint) ((green1 - green2) * gradient))) & 0xFF) << 8) + c; // Start rebuilding the Color by Bitwises, Bitshifts and Sum to variable "c"
    else c = (((green1 + ((uint) ((green2 - green1) * gradient))) & 0xFF) << 8) + c;
    if(blue1 > blue2) c = (((blue1 - ((uint) ((blue1 - blue2) * gradient))) & 0xFF) << 16) + c;
    else c = (((blue1 + ((uint) ((blue2 - blue1) * gradient))) & 0xFF) << 16) + c;
    if(alpha1 > alpha2) c = (((alpha1 - ((uint) ((alpha1 - alpha2) * alpha))) & 0xFF) << 24) + c;
    else c = (((alpha1 + ((uint) ((alpha2 - alpha1) * alpha))) & 0xFF) << 24) + c;
    return c;
}
//+------------------------------------------------------------------+
// Header Guard #endif
//+------------------------------------------------------------------+
#endif
//+------------------------------------------------------------------+
