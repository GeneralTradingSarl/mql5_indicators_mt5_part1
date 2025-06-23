/*
Copyright (C) 2021 Mateus Matucuma Teixeira

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, write to the Free Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
*/
#ifndef GRADIENTCANDLES_H
#define GRADIENTCANDLES_H
//+------------------------------------------------------------------+
//|                                    Barebone Gradient Candles.mq5 |
//|                     Copyright (C) 2021, Mateus Matucuma Teixeira |
//|                                            mateusmtoss@gmail.com |
//| GNU General Public License version 2 - GPL-2.0                   |
//| https://opensource.org/licenses/gpl-2.0.php                      |
//+------------------------------------------------------------------+
// https://github.com/BRMateus2/
//---- Main Properties
#property copyright "2021, Mateus Matucuma Teixeira"
#property link "https://github.com/BRMateus2/"
#property description "Colored Candlestick exemplifying a gradient"
#property version "1.01"
#property strict
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots 1
//---- Definitions
#define GRADIENT 64 // Has a platform limit of 64!
//---- Indicator Indexes, Buffers and Handlers
input color cStart = 0x000000; // Beginning of the Gradient
input color cEnd = 0x7FFF00; // End of the Gradient
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
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
// Constructor or initialization function
//+------------------------------------------------------------------+
int OnInit()
{
    // DRAW_COLOR_CANDLES is a specific plotting, which must be coded manually - those are the important sets
    SetIndexBuffer(iBufOpenI, iBufOpen, INDICATOR_DATA);
    SetIndexBuffer(iBufHighI, iBufHigh, INDICATOR_DATA);
    SetIndexBuffer(iBufLowI, iBufLow, INDICATOR_DATA);
    SetIndexBuffer(iBufCloseI, iBufClose, INDICATOR_DATA);
    SetIndexBuffer(iBufColorI, iBufColor, INDICATOR_COLOR_INDEX);
    PlotIndexSetInteger(iBufOpenI, PLOT_DRAW_TYPE, DRAW_COLOR_CANDLES); // You can just set 0 in place of iBufOpenI, but it might be possible to have multiple colored plots, and the first Index for a colored draw is what defines its colors
    // Define a value which will not plot, if any of the buffers has this value
    PlotIndexSetDouble(iBufOpenI, PLOT_EMPTY_VALUE, DBL_MIN); // You can set 0.0 in place of DBL_MIN, but it will cause invisible candlesticks if any of the buffers is at 0.0
    PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, GRADIENT); // Set the color indexes to be of size GRADIENT
    //Set color for each index
    for(int i = 0; i < GRADIENT; i++) {
        PlotIndexSetInteger(iBufOpenI, PLOT_LINE_COLOR, i, argbGradient(cStart, cEnd, (1.0 - (((double) GRADIENT - i) / GRADIENT)), (1.0 - (((double) GRADIENT - i) / GRADIENT))));
    }
    // Set the starting/default formatting for the candles
    PlotIndexSetString(iBufOpenI, PLOT_LABEL, "Open;" + "High;" + "Low;" + "Close"); // A strange formatting where ';' defines the separators, it is always Open;High;Low;Close and there are no additional values (you can change the names of Open, etc, for translation purposes)
    return INIT_SUCCEEDED;
}
//+------------------------------------------------------------------+
// Destructor or Deinitialization function
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    return;
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
    static int colors = 0;
    static int bars = 0;
    // Main loop of calculations
    for(int i = (prev_calculated - 1); i < rates_total && !IsStopped(); i++) {
        if(i < 0) {
            continue;
        }
        iBufOpen[i] = open[i];
        iBufHigh[i] = high[i];
        iBufLow[i] = low[i];
        iBufClose[i] = close[i];
        iBufColor[i] = colors;
        if(bars != Bars(Symbol(), PERIOD_CURRENT)) colors++; // Comment this line for color change at every tick, else at every new bar
        //colors++; // Comment this line for color change at every bar, else at every new tick
        if(colors >= GRADIENT) colors = 0; // Upper limit for colors indexer
    }
    bars = Bars(Symbol(), PERIOD_CURRENT);
    return rates_total; // Calculations are done and valid
}
//+------------------------------------------------------------------+
// Color
// Parameters c1 and c2 are ARGB Colors to Gradient into the return value
// Gradient and Alpha is a percentage from c1 towards c2, accepts any range, but anything out of [0; 1.0] is cut
// The return value of the function is guaranteed to be between [0xYY000000; 0xYYFFFFFF], even if the gradient is invalid, and YY equals to the Alpha between [0; 1.0] -> AA[0; 255]
// If using "colors", Alpha should be 0.0 or it will mess with the printed colors
//+------------------------------------------------------------------+
uint argbGradient(uint c1, uint c2, double gradient = 0.5, double alpha = 0.0)
{
    uint c = 0x00000000;
    // Red is at 0x000000##
    // Green is at 0x0000##00
    // Blue is at 0x00##0000
    // There is no Alpha for Plots and Buffers, but for some reason, the function ColorToARGB() exists in the documentation, for Alpha at 0x##000000
    if(gradient > 1.0) gradient = 1.0;
    else if (gradient < +0.0) gradient = +0.0;
    if(alpha > 1.0) alpha = 1.0;
    else if(alpha < +0.0) alpha = +0.0;
    uint red1 = (c1 & 0xFF);
    uint green1 = (c1 & 0xFF00) >> 8;
    uint blue1 = (c1 & 0xFF0000) >> 16;
    uint alpha1 = (c1 & 0xFF000000) >> 24;
    uint red2 = (c2 & 0xFF);
    uint green2 = (c2 & 0xFF00) >> 8;
    uint blue2 = (c2 & 0xFF0000) >> 16;
    uint alpha2 = (c2 & 0xFF000000) >> 24;
    if (red1 > red2) c = ((uint) (red1 - ((red1 - red2) * gradient))) & 0xFF;
    else c = ((uint) (red1 + ((red2 - red1) * gradient))) & 0xFF;
    if (green1 > green2) c = ((((uint) (green1 - ((green1 - green2) * gradient))) & 0xFF) << 8) + c;
    else c = ((((uint) (green1 + ((green2 - green1) * gradient))) & 0xFF) << 8) + c;
    if (blue1 > blue2) c = ((((uint) (blue1 - ((blue1 - blue2) * gradient))) & 0xFF) << 16) + c;
    else c = ((((uint) (blue1 + ((blue2 - blue1) * gradient))) & 0xFF) << 16) + c;
    if (alpha1 > alpha2) c = ((((uint) (alpha1 - ((alpha1 - alpha2) * alpha))) & 0xFF) << 24) + c;
    else c = ((((uint) (alpha1 + ((alpha2 - alpha1) * alpha))) & 0xFF) << 24) + c;
    return c;
}
//+------------------------------------------------------------------+
//| Header Guard #endif
//+------------------------------------------------------------------+
#endif
//+------------------------------------------------------------------+
