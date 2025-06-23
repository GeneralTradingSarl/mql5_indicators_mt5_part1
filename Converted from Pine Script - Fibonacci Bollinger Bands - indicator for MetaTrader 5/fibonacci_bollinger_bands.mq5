//+------------------------------------------------------------------+
//|                                        Fibonnaci Bollinger Bands |
//|                          Copyright 2024, Rama Destrian (vilraxq) |
//|                             http://www.mql5.com/ru/users/vilraxq |
//+------------------------------------------------------------------+
#property copyright     "Copyright 2024, Rama Destrian (vilraxq)"
#property link          "http://www.mql5.com/ru/users/vilraxq"
#property version       "1.00"
#property description   "Convert Pine Script code for Fibonacci Bollinger Bands to MQL5"

#property indicator_applied_price PRICE_TYPICAL

#property indicator_chart_window
#property indicator_buffers 13
#property indicator_plots   13

// Plot Properties
#property indicator_label1  "Upper Band"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_width1  2

#property indicator_label2  "Lower Band"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_width2  2

#property indicator_label3  "Basis Line"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrBlue
#property indicator_width3  1

#property indicator_label4  "Upper Band : 0.764"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrBlack
#property indicator_width4  1

#property indicator_label5  "Upper Band : 0.618"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrBlack
#property indicator_width5  1

#property indicator_label6  "Upper Band : 0.5"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrBlack
#property indicator_width6  1

#property indicator_label7  "Upper Band : 0.382"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrBlack
#property indicator_width7  1

#property indicator_label8  "Upper Band : 0.236"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrBlack
#property indicator_width8  1

#property indicator_label9  "Lower Band : 0.764"
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrBlack
#property indicator_width9  1

#property indicator_label10  "Lower Band : 0.618"
#property indicator_type10   DRAW_LINE
#property indicator_color10  clrBlack
#property indicator_width10  1

#property indicator_label11  "Lower Band : 0.5"
#property indicator_type11   DRAW_LINE
#property indicator_color11  clrBlack
#property indicator_width11  1

#property indicator_label12  "Lower Band : 0.382"
#property indicator_type12   DRAW_LINE
#property indicator_color12  clrBlack
#property indicator_width12  1

#property indicator_label13  "Lower Band : 0.236"
#property indicator_type13   DRAW_LINE
#property indicator_color13  clrBlack
#property indicator_width13  1

// Input Parameters
input int                  Length = 200;         // BB Period
input double               Mult   = 3.0;         // BB Multiplier
input ENUM_APPLIED_PRICE   Applied_price = PRICE_TYPICAL; // Stdev Source

// Buffers
double basisBuffer[];
double upperBuffer[];
double lowerBuffer[];
double devValue[];

// Buffers for fibonacci
double upper764[];
double upper618[];
double upper5[];
double upper382[];
double upper236[];

double lower764[];
double lower618[];
double lower5[];
double lower382[];
double lower236[];

// Handle
int devHandle;

// Initialization
int OnInit()
  {
// Mapping Buffers
   SetIndexBuffer(0, upperBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, lowerBuffer, INDICATOR_DATA);
   SetIndexBuffer(2, basisBuffer, INDICATOR_DATA);
   SetIndexBuffer(3, upper764, INDICATOR_DATA);
   SetIndexBuffer(4, upper618, INDICATOR_DATA);
   SetIndexBuffer(5, upper5, INDICATOR_DATA);
   SetIndexBuffer(6, upper382, INDICATOR_DATA);
   SetIndexBuffer(7, upper236, INDICATOR_DATA);
   SetIndexBuffer(8, lower764, INDICATOR_DATA);
   SetIndexBuffer(9, lower618, INDICATOR_DATA);
   SetIndexBuffer(10, lower5, INDICATOR_DATA);
   SetIndexBuffer(11, lower382, INDICATOR_DATA);
   SetIndexBuffer(12, lower236, INDICATOR_DATA);

// Initialize Arrays
   ArraySetAsSeries(basisBuffer, true);
   ArraySetAsSeries(upperBuffer, true);
   ArraySetAsSeries(lowerBuffer, true);
   ArraySetAsSeries(devValue, true);
   ArraySetAsSeries(upper764, true);
   ArraySetAsSeries(upper618, true);
   ArraySetAsSeries(upper5, true);
   ArraySetAsSeries(upper382, true);
   ArraySetAsSeries(upper236, true);
   ArraySetAsSeries(lower764, true);
   ArraySetAsSeries(lower618, true);
   ArraySetAsSeries(lower5, true);
   ArraySetAsSeries(lower382, true);
   ArraySetAsSeries(lower236, true);

// Create StdDev Indicator
   devHandle = iStdDev(_Symbol, PERIOD_CURRENT, Length, 0, MODE_SMA, Applied_price);
   if(devHandle == INVALID_HANDLE)
     {
      Print("Error creating StdDev handle");
      return(INIT_FAILED);
     }

   return(INIT_SUCCEEDED);
  }

// VWMA Calculation
double vwma(const double &src[], int lengthVWMA, int index)
  {
   double s1 = 0, s2 = 0;
   for(int i = index; i < MathMin(index + lengthVWMA, ArraySize(src)); i++)
     {
      double vol = (double)iVolume(_Symbol, PERIOD_CURRENT, i);
      if(vol == 0)
         continue; // Skip invalid volume
      s1 += src[i] * vol;
      s2 += vol;
     }
   return s2 == 0 ? 0 : s1 / s2; // Prevent division by zero
  }

// OnCalculate Function
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   ArraySetAsSeries(price, true);

   if(CopyBuffer(devHandle, 0, 0, rates_total, devValue) <= 0 || ArraySize(devValue) < rates_total)
     {
      Print("Failed to copy StdDev values or devValue array size mismatch");
      return(prev_calculated);
     }

   // Define the calculation limit based on the number of previously calculated bars.
   int limit = rates_total - prev_calculated;
   if (prev_calculated == 0)
      limit = rates_total - 2;
   else
      limit++; 

   if(limit > rates_total - 2) 
      limit = rates_total - 2;
      
   /// Loop through each bar for calculation.
   for(int i = limit; i >= 0; i--)
     {
      // Calculate the basis using the VWMA.
      double basis = vwma(price, Length, i);
      if (basis == 0 || basis == EMPTY_VALUE)
        {
         basisBuffer[i] = EMPTY_VALUE;
         upperBuffer[i] = EMPTY_VALUE;
         lowerBuffer[i] = EMPTY_VALUE;
         upper236[i] = EMPTY_VALUE;
         lower236[i] = EMPTY_VALUE;
         continue; // Skip this bar's calculation.
        }
      
      basisBuffer[i] = basis;

      double dev = devValue[i];
      if (dev == EMPTY_VALUE || dev <= 0)
        {
         basisBuffer[i] = EMPTY_VALUE;
         upperBuffer[i] = EMPTY_VALUE;
         lowerBuffer[i] = EMPTY_VALUE;
         upper236[i] = EMPTY_VALUE;
         lower236[i] = EMPTY_VALUE;
         continue;
        }

      // Calculate the upper and lower bands based on the multiplier and standard deviation.
      upperBuffer[i] = basis + Mult * dev;  // Upper Band
      lowerBuffer[i] = basis - Mult * dev;  // Lower Band

      // Calculate Fibonacci levels for the bands.
      upper236[i] = basis + Mult * dev * 0.236;
      upper382[i] = basis + Mult * dev * 0.382;
      upper5[i]   = basis + Mult * dev * 0.5;
      upper618[i] = basis + Mult * dev * 0.618;
      upper764[i] = basis + Mult * dev * 0.764;

      lower236[i] = basis - Mult * dev * 0.236;
      lower382[i] = basis - Mult * dev * 0.382;
      lower5[i]   = basis - Mult * dev * 0.5;
      lower618[i] = basis - Mult * dev * 0.618;
      lower764[i] = basis - Mult * dev * 0.764;
     }

   return rates_total;
  }
