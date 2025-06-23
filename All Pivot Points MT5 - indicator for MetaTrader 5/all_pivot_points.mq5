//+------------------------------------------------------------------+
//|                                             All Pivot Points.mq5 |
//|                                    Copyright 2022, Hossein Nouri |
//|                           https://www.mql5.com/en/users/hsnnouri |
//+------------------------------------------------------------------+
// Version 1.11 changelog
// - Fixed reported issue by Maksim Diveev(gate)
//+------------------------------------------------------------------+
// Version 1.12 changelog
// - Fixed reported issue by Patrick Faria(patrickfaria)
//+------------------------------------------------------------------+
// Version 1.14 changelog
// - Fixed issue of not loading on chart and displaying objects sometimes
// - Alerts added
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Hossein Nouri"
#property description "Donation (BTC): 1B8523u9AuZ69j98nDrLJ7TMDEM27erXLx"
#property description " "
#property description "All important Pivot Points including:"
#property description "Classic1, Classic2, Camarilla, Woodie, Floor, Fibonacci, Fibonacci_Retracement"
#property description "Fully Coded By Hossein Nouri"
#property description "Email : hsn.nouri@gmail.com"
#property description "Skype : hsn.nouri"
#property description "Telegram : @hypernova1990"
#property description "Website : http://www.dlikedeveloper.com"
#property description "MQL5 Profile : https://www.mql5.com/en/users/hsnnouri"
#property description " "
#property description "Feel free to contact me for MQL4/MQL5/Pine coding."
#property link      "https://www.mql5.com/en/users/hsnnouri"
#property version   "1.14"
#property strict
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots 9

//--- plot Pivot
#property indicator_label1  "Pivot"
#property indicator_type1   DRAW_LINE
//--- S1
#property indicator_label2  "S1"
#property indicator_type2   DRAW_LINE
//--- S2
#property indicator_label3  "S2"
#property indicator_type3   DRAW_LINE
//--- S3
#property indicator_label4  "S3"
#property indicator_type4   DRAW_LINE
//--- S4
#property indicator_label5  "S4"
#property indicator_type5   DRAW_LINE
//--- R1
#property indicator_label6  "R1"
#property indicator_type6   DRAW_LINE
//--- R2
#property indicator_label7  "R2"
#property indicator_type7   DRAW_LINE
//--- R3
#property indicator_label8  "R3"
#property indicator_type8   DRAW_LINE
//--- R4
#property indicator_label9  "R4"
#property indicator_type9   DRAW_LINE




//--- indicator buffers
double         PivotBuffer[];
double         S1Buffer[];
double         S2Buffer[];
double         S3Buffer[];
double         S4Buffer[];
double         R1Buffer[];
double         R2Buffer[];
double         R3Buffer[];
double         R4Buffer[];

enum ENUM_CALC_MODE
{
   CALC_MODE_CLASSIC1=0,// Classic 1
   CALC_MODE_CLASSIC2=1,// Classic 2
   CALC_MODE_CAMARILLA=2,// Camarilla
   CALC_MODE_WOODIE=3,// Woodie
   CALC_MODE_FIBONACCI=4,// Fibonacci
   CALC_MODE_FLOOR=5,// Floor
   CALC_MODE_FIBONACCI_RETRACEMENT=6,// Fibonacci Retracement
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_SHOW_MODE
{
   SHOW_MODE_TODAY,// Today
   SHOW_MODE_HISTORICAL,// Historical
};
input ENUM_TIMEFRAMES         InpTimeframe         = PERIOD_D1;                                    // Timeframe
input ENUM_CALC_MODE          CalculationMode      = CALC_MODE_CLASSIC1;                           // Calculation Mode
input ENUM_SHOW_MODE          InpShowMode          = SHOW_MODE_HISTORICAL;                         // Displaying Mode
input int                     InpHistoricalBars    = 0;                                            // Historical Bars (0=All)
input bool                    InpShowLabels        = true;                                         // Show Labels
input bool                    InpShowPriceTags     = true;                                         // Show Price Tags
input bool                    InpIncludeSundays    = true;                                         // Include Sundays
input string                  InpDesc1             = "********* Fibonacci Levels *********";       // Description
input double                  InpFibR1S1           = 38.2;                                         // R1/S1
input double                  InpFibR2S2           = 61.8;                                         // R2/S2
input double                  InpFibR3S3           = 100.0;                                        // R3/S3
input double                  InpFibR4S4           = 161.8;                                        // R4/S4
input string                  InpDesc2             = "*********** Active Lines ***********";       // Description
input bool                    InpShowPivot         = true;                                         // Pivot
input bool                    InpShowS1            = true;                                         // S1
input bool                    InpShowS2            = true;                                         // S2
input bool                    InpShowS3            = true;                                         // S3
input bool                    InpShowS4            = true;                                         // S4
input bool                    InpShowR1            = true;                                         // R1
input bool                    InpShowR2            = true;                                         // R2
input bool                    InpShowR3            = true;                                         // R3
input bool                    InpShowR4            = true;                                         // R4
input string                  InpDesc3             = "*********** Line Color ***********";         // Description
input color                   InpPivotColor        = clrLightGray;                                 // Pivot
input color                   InpS1Color           = clrRed;                                       // S1
input color                   InpS2Color           = clrCrimson;                                   // S2
input color                   InpS3Color           = clrFireBrick;                                 // S3
input color                   InpS4Color           = clrMaroon;                                    // S4
input color                   InpR1Color           = clrLime;                                      // R1
input color                   InpR2Color           = clrLimeGreen;                                 // R2
input color                   InpR3Color           = clrMediumSeaGreen;                            // R3
input color                   InpR4Color           = clrSeaGreen;                                  // R4
input string                  InpDesc4             = "*********** Line Style ***********";         // Description
input ENUM_LINE_STYLE         InpPivotStyle        = STYLE_SOLID;                                  // Pivot
input ENUM_LINE_STYLE         InpS1Style           = STYLE_SOLID;                                  // S1
input ENUM_LINE_STYLE         InpS2Style           = STYLE_SOLID;                                  // S2
input ENUM_LINE_STYLE         InpS3Style           = STYLE_SOLID;                                  // S3
input ENUM_LINE_STYLE         InpS4Style           = STYLE_SOLID;                                  // S4
input ENUM_LINE_STYLE         InpR1Style           = STYLE_SOLID;                                  // R1
input ENUM_LINE_STYLE         InpR2Style           = STYLE_SOLID;                                  // R2
input ENUM_LINE_STYLE         InpR3Style           = STYLE_SOLID;                                  // R3
input ENUM_LINE_STYLE         InpR4Style           = STYLE_SOLID;                                  // R4
input string                  InpDesc5             = "*********** Line Width ***********";         // Description
input int                     InpPivotWidth        = 1;                                            // Pivot
input int                     InpS1Width           = 1;                                            // S1
input int                     InpS2Width           = 1;                                            // S2
input int                     InpS3Width           = 1;                                            // S3
input int                     InpS4Width           = 1;                                            // S4
input int                     InpR1Width           = 1;                                            // R1
input int                     InpR2Width           = 1;                                            // R2
input int                     InpR3Width           = 1;                                            // R3
input int                     InpR4Width           = 1;                                            // R4
input string                  DescAlertLines       = "*********** Alert Lines ***********";        // Description
input bool                    InpPivotAlert        = true;                                         // Pivot
input bool                    InpS1Alert           = true;                                         // S1
input bool                    InpS2Alert           = true;                                         // S2
input bool                    InpS3Alert           = true;                                         // S3
input bool                    InpS4Alert           = true;                                         // S4
input bool                    InpR1Alert           = true;                                         // R1
input bool                    InpR2Alert           = true;                                         // R2
input bool                    InpR3Alert           = true;                                         // R3
input bool                    InpR4Alert           = true;                                         // R4
input string                  DescAlertSettings    = "********** Alert Settings **********";       // Description
input bool                    InpAlertShowPopup    = true;                                         // Show Pop-up
input bool                    InpAlertSendEmail    = false;                                        // Send Email
input bool                    InpAlertSendNotification   = false;                                  // Send Notification
input bool                    InpAlertPlaySound    = false;                                        // Play Sound
input string                  InpAlertSoundFile    = "alert.wav";                                  // Sound File

//+------------------------------------------------------------------+
//| Global Variables                                                        |
//+------------------------------------------------------------------+
datetime StartTime,StopTime,OneCandleGap,OneCandle;
double   R1,R2,R3,R4,S1,S2,S3,S4,PP;
double   NextDayR1,NextDayR2,NextDayR3,NextDayR4,NextDayS1,NextDayS2,NextDayS3,NextDayS4,NextDayPP;
string   prefix;
string   CalcTypeAbb;
bool     Status=true;
int      CurrentCandleIndex=0;
int      PrevCandleIndex=1;
string   LastTouchedLine="";
double   LastTickClose=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{

   SetIndexBuffer(0,PivotBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,S1Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,S2Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,S3Buffer,INDICATOR_DATA);
   SetIndexBuffer(4,S4Buffer,INDICATOR_DATA);
   SetIndexBuffer(5,R1Buffer,INDICATOR_DATA);
   SetIndexBuffer(6,R2Buffer,INDICATOR_DATA);
   SetIndexBuffer(7,R3Buffer,INDICATOR_DATA);
   SetIndexBuffer(8,R4Buffer,INDICATOR_DATA);

   if(InpShowMode==SHOW_MODE_TODAY)
   {
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetInteger(4,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetInteger(5,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetInteger(6,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetInteger(7,PLOT_DRAW_TYPE,DRAW_NONE);
      PlotIndexSetInteger(8,PLOT_DRAW_TYPE,DRAW_NONE);
   }

   PlotIndexSetInteger(0,PLOT_LINE_STYLE,InpPivotStyle);
   PlotIndexSetInteger(1,PLOT_LINE_STYLE,InpS1Style);
   PlotIndexSetInteger(2,PLOT_LINE_STYLE,InpS2Style);
   PlotIndexSetInteger(3,PLOT_LINE_STYLE,InpS3Style);
   PlotIndexSetInteger(4,PLOT_LINE_STYLE,InpS4Style);
   PlotIndexSetInteger(5,PLOT_LINE_STYLE,InpR1Style);
   PlotIndexSetInteger(6,PLOT_LINE_STYLE,InpR2Style);
   PlotIndexSetInteger(7,PLOT_LINE_STYLE,InpR3Style);
   PlotIndexSetInteger(8,PLOT_LINE_STYLE,InpR4Style);

   PlotIndexSetInteger(0,PLOT_LINE_WIDTH,InpPivotWidth);
   PlotIndexSetInteger(1,PLOT_LINE_WIDTH,InpS1Width);
   PlotIndexSetInteger(2,PLOT_LINE_WIDTH,InpS2Width);
   PlotIndexSetInteger(3,PLOT_LINE_WIDTH,InpS3Width);
   PlotIndexSetInteger(4,PLOT_LINE_WIDTH,InpS4Width);
   PlotIndexSetInteger(5,PLOT_LINE_WIDTH,InpR1Width);
   PlotIndexSetInteger(6,PLOT_LINE_WIDTH,InpR2Width);
   PlotIndexSetInteger(7,PLOT_LINE_WIDTH,InpR3Width);
   PlotIndexSetInteger(8,PLOT_LINE_WIDTH,InpR4Width);

   PlotIndexSetInteger(0,PLOT_LINE_COLOR,InpPivotColor);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,InpS1Color);
   PlotIndexSetInteger(2,PLOT_LINE_COLOR,InpS2Color);
   PlotIndexSetInteger(3,PLOT_LINE_COLOR,InpS3Color);
   PlotIndexSetInteger(4,PLOT_LINE_COLOR,InpS4Color);
   PlotIndexSetInteger(5,PLOT_LINE_COLOR,InpR1Color);
   PlotIndexSetInteger(6,PLOT_LINE_COLOR,InpR2Color);
   PlotIndexSetInteger(7,PLOT_LINE_COLOR,InpR3Color);
   PlotIndexSetInteger(8,PLOT_LINE_COLOR,InpR4Color);

   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

   ArraySetAsSeries(S1Buffer,true);
   ArraySetAsSeries(S2Buffer,true);
   ArraySetAsSeries(S3Buffer,true);
   ArraySetAsSeries(S4Buffer,true);
   ArraySetAsSeries(R1Buffer,true);
   ArraySetAsSeries(R2Buffer,true);
   ArraySetAsSeries(R3Buffer,true);
   ArraySetAsSeries(R4Buffer,true);
   ArraySetAsSeries(PivotBuffer,true);


   StringConcatenate(prefix,EnumToString(CalculationMode),"_",EnumToString(InpTimeframe),"_");
//--- indicator buffers mapping
   Status=true;
   if(Period()>InpTimeframe)
   {
      Alert("Loading failed, please set a higher timeframe.");
      Status=false;
   }
   ExtractCalculationType();

   PlotIndexSetString(0,PLOT_LABEL,"Pivot ("+CalcTypeAbb+")");
   PlotIndexSetString(1,PLOT_LABEL,"S1 ("+CalcTypeAbb+")");
   PlotIndexSetString(2,PLOT_LABEL,"S2 ("+CalcTypeAbb+")");
   PlotIndexSetString(3,PLOT_LABEL,"S3 ("+CalcTypeAbb+")");
   PlotIndexSetString(4,PLOT_LABEL,"S4 ("+CalcTypeAbb+")");
   PlotIndexSetString(5,PLOT_LABEL,"R1 ("+CalcTypeAbb+")");
   PlotIndexSetString(6,PLOT_LABEL,"R2 ("+CalcTypeAbb+")");
   PlotIndexSetString(7,PLOT_LABEL,"R3 ("+CalcTypeAbb+")");
   PlotIndexSetString(8,PLOT_LABEL,"R4 ("+CalcTypeAbb+")");

   OneCandleGap=PeriodSeconds(InpTimeframe);
   OneCandle=PeriodSeconds(PERIOD_CURRENT);

//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0,prefix);
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
//---
   ArraySetAsSeries(time,true);
   if(!Status)       return 0;
   int limit;
   limit = prev_calculated==0?rates_total-1:rates_total-prev_calculated+1;

   if(rates_total>prev_calculated)
   {
      if(!IsChartLoaded())  return prev_calculated;
      UpdateCandlesIndex();
      if(InpShowMode==SHOW_MODE_HISTORICAL)
      {

         if(CalculationMode==CALC_MODE_CAMARILLA)
         {
            int j=0;
            for(int i=0; i<limit; i++)
            {
               if(InpHistoricalBars!=0 && i>InpHistoricalBars)
               {
                  PivotBuffer[i]=0;
                  S1Buffer[i]=0;
                  S2Buffer[i]=0;
                  S3Buffer[i]=0;
                  S4Buffer[i]=0;
                  R1Buffer[i]=0;
                  R2Buffer[i]=0;
                  R3Buffer[i]=0;
                  R4Buffer[i]=0;
                  continue;
               }
               if(time[i]>=iTime(Symbol(),InpTimeframe,j))
               {
                  calculateHistCamarilla(i,j+1);

               }
               else
               {
                  j++;
                  calculateHistCamarilla(i,j+1);
               }

            }
            calculateCamarilla();
         }
         else if(CalculationMode==CALC_MODE_CLASSIC1)
         {
            int j=0;
            for(int i=0; i<limit; i++)
            {
               if(InpHistoricalBars!=0 && i>InpHistoricalBars)
               {
                  PivotBuffer[i]=0;
                  S1Buffer[i]=0;
                  S2Buffer[i]=0;
                  S3Buffer[i]=0;
                  S4Buffer[i]=0;
                  R1Buffer[i]=0;
                  R2Buffer[i]=0;
                  R3Buffer[i]=0;
                  R4Buffer[i]=0;
                  continue;
               }
               if(time[i]>=iTime(Symbol(),InpTimeframe,j))
               {
                  calculateHistClassic1(i,j+1);

               }
               else
               {
                  j++;
                  calculateHistClassic1(i,j+1);
               }

            }
            calculateClassic1();
         }
         else if(CalculationMode==CALC_MODE_CLASSIC2)
         {
            int j=0;
            for(int i=0; i<limit; i++)
            {
               if(InpHistoricalBars!=0 && i>InpHistoricalBars)
               {
                  PivotBuffer[i]=0;
                  S1Buffer[i]=0;
                  S2Buffer[i]=0;
                  S3Buffer[i]=0;
                  S4Buffer[i]=0;
                  R1Buffer[i]=0;
                  R2Buffer[i]=0;
                  R3Buffer[i]=0;
                  R4Buffer[i]=0;
                  continue;
               }
               if(time[i]>=iTime(Symbol(),InpTimeframe,j))
               {
                  calculateHistClassic2(i,j+1);

               }
               else
               {
                  j++;
                  calculateHistClassic2(i,j+1);
               }

            }
            calculateClassic2();
         }
         else if(CalculationMode==CALC_MODE_WOODIE)
         {
            int j=0;
            for(int i=0; i<limit; i++)
            {
               if(InpHistoricalBars!=0 && i>InpHistoricalBars)
               {
                  PivotBuffer[i]=0;
                  S1Buffer[i]=0;
                  S2Buffer[i]=0;
                  S3Buffer[i]=0;
                  S4Buffer[i]=0;
                  R1Buffer[i]=0;
                  R2Buffer[i]=0;
                  R3Buffer[i]=0;
                  R4Buffer[i]=0;
                  continue;
               }
               if(time[i]>=iTime(Symbol(),InpTimeframe,j))
               {
                  calculateHistWoodie(i,j+1);

               }
               else
               {
                  j++;
                  calculateHistWoodie(i,j+1);
               }

            }
            calculateWoodie();
         }
         else if(CalculationMode==CALC_MODE_FIBONACCI)
         {
            int j=0;
            for(int i=0; i<limit; i++)
            {
               if(InpHistoricalBars!=0 && i>InpHistoricalBars)
               {
                  PivotBuffer[i]=0;
                  S1Buffer[i]=0;
                  S2Buffer[i]=0;
                  S3Buffer[i]=0;
                  S4Buffer[i]=0;
                  R1Buffer[i]=0;
                  R2Buffer[i]=0;
                  R3Buffer[i]=0;
                  R4Buffer[i]=0;
                  continue;
               }
               if(time[i]>=iTime(Symbol(),InpTimeframe,j))
               {
                  calculateHistFibonacci(i,j+1);

               }
               else
               {
                  j++;
                  calculateHistFibonacci(i,j+1);
               }

            }
            calculateFibonacci();
         }
         else if(CalculationMode==CALC_MODE_FLOOR)
         {
            int j=0;
            for(int i=0; i<limit; i++)
            {
               if(InpHistoricalBars!=0 && i>InpHistoricalBars)
               {
                  PivotBuffer[i]=0;
                  S1Buffer[i]=0;
                  S2Buffer[i]=0;
                  S3Buffer[i]=0;
                  S4Buffer[i]=0;
                  R1Buffer[i]=0;
                  R2Buffer[i]=0;
                  R3Buffer[i]=0;
                  R4Buffer[i]=0;
                  continue;
               }
               if(time[i]>=iTime(Symbol(),InpTimeframe,j))
               {
                  calculateHistFloor(i,j+1);

               }
               else
               {
                  j++;
                  calculateHistFloor(i,j+1);
               }

            }
            calculateFloor();
         }
         else if(CalculationMode==CALC_MODE_FIBONACCI_RETRACEMENT)
         {
            int j=0;
            for(int i=0; i<limit; i++)
            {
               if(InpHistoricalBars!=0 && i>InpHistoricalBars)
               {
                  PivotBuffer[i]=0;
                  S1Buffer[i]=0;
                  S2Buffer[i]=0;
                  S3Buffer[i]=0;
                  S4Buffer[i]=0;
                  R1Buffer[i]=0;
                  R2Buffer[i]=0;
                  R3Buffer[i]=0;
                  R4Buffer[i]=0;
                  continue;
               }
               if(time[i]>=iTime(Symbol(),InpTimeframe,j))
               {
                  calculateHistFibonacciRet(i,j+1);

               }
               else
               {
                  j++;
                  calculateHistFibonacciRet(i,j+1);
               }

            }
            calculateFibonacciRet();
         }
      }
      if(InpShowMode==SHOW_MODE_TODAY)
      {
         if(CalculationMode==CALC_MODE_CLASSIC1)                  calculateClassic1();
         if(CalculationMode==CALC_MODE_CLASSIC2)                  calculateClassic2();
         if(CalculationMode==CALC_MODE_CAMARILLA)                 calculateCamarilla();
         if(CalculationMode==CALC_MODE_WOODIE)                    calculateWoodie();
         if(CalculationMode==CALC_MODE_FIBONACCI)                 calculateFibonacci();
         if(CalculationMode==CALC_MODE_FLOOR)                     calculateFloor();
         if(CalculationMode==CALC_MODE_FIBONACCI_RETRACEMENT)     calculateFibonacciRet();
      }
   }
   RefreshAlerts();
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
void calculateHistFibonacciRet(int index,int barIndex)
{
   CorrectBarIndex(barIndex);
   double prevRange= iHigh(Symbol(),InpTimeframe,barIndex)-iLow(Symbol(),InpTimeframe,barIndex);
   double prevHigh = iHigh(Symbol(),InpTimeframe,barIndex);
   double prevLow=iLow(Symbol(),InpTimeframe,barIndex);
   double prevClose=iClose(Symbol(),InpTimeframe,barIndex);
   PivotBuffer[index]=NormalizeDouble(prevLow+(0.50*prevRange),_Digits);
   R1Buffer[index] = NormalizeDouble(prevLow +(0.618 * prevRange),_Digits);
   R2Buffer[index] = NormalizeDouble(prevLow +(0.786 * prevRange),_Digits);
   R3Buffer[index] = NormalizeDouble(prevHigh,_Digits);
   R4Buffer[index] = NormalizeDouble(prevLow +(1.382 * prevRange),_Digits);

   S1Buffer[index] = NormalizeDouble(prevLow +(0.382 * prevRange),_Digits);
   S2Buffer[index] = NormalizeDouble(prevLow +(0.236 * prevRange),_Digits);
   S3Buffer[index] = NormalizeDouble(prevLow,_Digits);
   S4Buffer[index] = NormalizeDouble(prevLow -(0.382 * prevRange),_Digits);
   checkVisiblity(index);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateFibonacciRet()
{
   double prevRange= iHigh(Symbol(),InpTimeframe,1)-iLow(Symbol(),InpTimeframe,1);
   double prevHigh = iHigh(Symbol(),InpTimeframe,1);
   double prevLow=iLow(Symbol(),InpTimeframe,1);
   double prevClose=iClose(Symbol(),InpTimeframe,1);
   PP = NormalizeDouble(prevLow +(0.50 * prevRange),_Digits);
   R1 = NormalizeDouble(prevLow +(0.618 * prevRange),_Digits);
   R2 = NormalizeDouble(prevLow +(0.786 * prevRange),_Digits);
   R3 = NormalizeDouble(prevHigh,_Digits);
   R4 = NormalizeDouble(prevLow +(1.382 * prevRange),_Digits);
   S1 = NormalizeDouble(prevLow +(0.382 * prevRange),_Digits);
   S2 = NormalizeDouble(prevLow +(0.236 * prevRange),_Digits);
   S3 = NormalizeDouble(prevLow,_Digits);
   S4 = NormalizeDouble(prevLow -(0.382 * prevRange),_Digits);
   DrawOnChart();

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateHistFloor(int index,int barIndex)
{
   CorrectBarIndex(barIndex);
   double prevRange= iHigh(Symbol(),InpTimeframe,barIndex)-iLow(Symbol(),InpTimeframe,barIndex);
   double prevHigh = iHigh(Symbol(),InpTimeframe,barIndex);
   double prevLow=iLow(Symbol(),InpTimeframe,barIndex);
   double prevClose=iClose(Symbol(),InpTimeframe,barIndex);
   PivotBuffer[index]=NormalizeDouble((prevHigh+prevLow+prevClose)/3,_Digits);
   R1Buffer[index] = NormalizeDouble((PivotBuffer[index] * 2)-prevLow,_Digits);
   S1Buffer[index] = NormalizeDouble((PivotBuffer[index] * 2)-prevHigh,_Digits);
   R2Buffer[index] = NormalizeDouble(PivotBuffer[index] + prevHigh - prevLow,_Digits);
   S2Buffer[index] = NormalizeDouble(PivotBuffer[index] - prevHigh + prevLow,_Digits);
   R3Buffer[index] = NormalizeDouble(R1Buffer[index] + (prevHigh-prevLow),_Digits);
   S3Buffer[index] = NormalizeDouble(prevLow - 2 * (prevHigh-PivotBuffer[index]),_Digits);
   checkVisiblity(index);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateFloor()
{
   double prevRange= iHigh(Symbol(),InpTimeframe,PrevCandleIndex)-iLow(Symbol(),InpTimeframe,PrevCandleIndex);
   double prevHigh = iHigh(Symbol(),InpTimeframe,PrevCandleIndex);
   double prevLow=iLow(Symbol(),InpTimeframe,PrevCandleIndex);
   double prevClose=iClose(Symbol(),InpTimeframe,PrevCandleIndex);
   PP = NormalizeDouble((prevHigh+prevLow+prevClose)/3,_Digits);
   R1 = NormalizeDouble((PP * 2)-prevLow,_Digits);
   S1 = NormalizeDouble((PP * 2)-prevHigh,_Digits);
   R2 = NormalizeDouble(PP + prevHigh - prevLow,_Digits);
   S2 = NormalizeDouble(PP - prevHigh + prevLow,_Digits);
   R3 = NormalizeDouble(R1 + (prevHigh-prevLow),_Digits);
   S3 = NormalizeDouble(prevLow - 2 * (prevHigh-PP),_Digits);
   DrawOnChart();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateHistFibonacci(int index,int barIndex)
{
   CorrectBarIndex(barIndex);
   double prevRange= iHigh(Symbol(),InpTimeframe,barIndex)-iLow(Symbol(),InpTimeframe,barIndex);
   double prevHigh = iHigh(Symbol(),InpTimeframe,barIndex);
   double prevLow=iLow(Symbol(),InpTimeframe,barIndex);
   double prevClose=iClose(Symbol(),InpTimeframe,barIndex);
   PivotBuffer[index]=NormalizeDouble((prevHigh+prevLow+prevClose)/3,_Digits);
   R1Buffer[index] = NormalizeDouble(PivotBuffer[index] + ((InpFibR1S1/100) * (prevHigh - prevLow)),_Digits);
   R2Buffer[index] = NormalizeDouble(PivotBuffer[index] + ((InpFibR2S2/100) * (prevHigh - prevLow)),_Digits);
   R3Buffer[index] = NormalizeDouble(PivotBuffer[index] + ((InpFibR3S3/100) * (prevHigh - prevLow)),_Digits);
   R4Buffer[index] = NormalizeDouble(PivotBuffer[index] + ((InpFibR4S4/100) * (prevHigh - prevLow)),_Digits);
   S1Buffer[index] = NormalizeDouble(PivotBuffer[index] - ((InpFibR1S1/100) * (prevHigh - prevLow)),_Digits);
   S2Buffer[index] = NormalizeDouble(PivotBuffer[index] - ((InpFibR2S2/100) * (prevHigh - prevLow)),_Digits);
   S3Buffer[index] = NormalizeDouble(PivotBuffer[index] - ((InpFibR3S3/100) * (prevHigh - prevLow)),_Digits);
   S4Buffer[index] = NormalizeDouble(PivotBuffer[index] - ((InpFibR4S4/100) * (prevHigh - prevLow)),_Digits);
   checkVisiblity(index);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateFibonacci()
{
   double prevRange= iHigh(Symbol(),InpTimeframe,PrevCandleIndex)-iLow(Symbol(),InpTimeframe,PrevCandleIndex);
   double prevHigh = iHigh(Symbol(),InpTimeframe,PrevCandleIndex);
   double prevLow=iLow(Symbol(),InpTimeframe,PrevCandleIndex);
   double prevClose=iClose(Symbol(),InpTimeframe,PrevCandleIndex);
   PP = NormalizeDouble((prevHigh+prevLow+prevClose)/3,_Digits);
   R1 = NormalizeDouble(PP + ((InpFibR1S1/100) * (prevHigh - prevLow)),_Digits);
   R2 = NormalizeDouble(PP + ((InpFibR2S2/100) * (prevHigh - prevLow)),_Digits);
   R3 = NormalizeDouble(PP + ((InpFibR3S3/100) * (prevHigh - prevLow)),_Digits);
   R4 = NormalizeDouble(PP + ((InpFibR4S4/100) * (prevHigh - prevLow)),_Digits);
   S1 = NormalizeDouble(PP - ((InpFibR1S1/100) * (prevHigh - prevLow)),_Digits);
   S2 = NormalizeDouble(PP - ((InpFibR2S2/100) * (prevHigh - prevLow)),_Digits);
   S3 = NormalizeDouble(PP - ((InpFibR3S3/100) * (prevHigh - prevLow)),_Digits);
   S4 = NormalizeDouble(PP - ((InpFibR4S4/100) * (prevHigh - prevLow)),_Digits);
   DrawOnChart();

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateHistCamarilla(int index,int barIndex)
{
   CorrectBarIndex(barIndex);
   double camRange = iHigh(Symbol(), InpTimeframe,barIndex) - iLow(Symbol(), InpTimeframe,barIndex);
   double prevHigh = iHigh(Symbol(), InpTimeframe,barIndex);
   double prevLow=iLow(Symbol(),InpTimeframe,barIndex);
   double prevClose= iClose(Symbol(),InpTimeframe,barIndex);
   R1Buffer[index] = NormalizeDouble(((1.1 / 12) * camRange) + prevClose,_Digits);
   R2Buffer[index] = NormalizeDouble(((1.1 / 6) * camRange) + prevClose,_Digits);
   R3Buffer[index] = NormalizeDouble(((1.1 / 4) * camRange) + prevClose,_Digits);
   R4Buffer[index] = NormalizeDouble(((1.1 / 2) * camRange) + prevClose,_Digits);
   S1Buffer[index] = NormalizeDouble(prevClose - ((1.1 / 12) * camRange),_Digits);
   S2Buffer[index] = NormalizeDouble(prevClose - ((1.1 / 6) * camRange),_Digits);
   S3Buffer[index] = NormalizeDouble(prevClose - ((1.1 / 4) * camRange),_Digits);
   S4Buffer[index] = NormalizeDouble(prevClose - ((1.1 / 2) * camRange),_Digits);
   PivotBuffer[index]=NormalizeDouble((R1Buffer[index]+S1Buffer[index])/2,_Digits);
   checkVisiblity(index);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateHistClassic1(int index,int barIndex)
{
   CorrectBarIndex(barIndex);
   double prevRange= iHigh(Symbol(),InpTimeframe,barIndex)-iLow(Symbol(),InpTimeframe,barIndex);
   double prevHigh = iHigh(Symbol(),InpTimeframe,barIndex);
   double prevLow=iLow(Symbol(),InpTimeframe,barIndex);
   double prevClose=iClose(Symbol(),InpTimeframe,barIndex);
   PivotBuffer[index]=NormalizeDouble((prevHigh+prevLow+prevClose)/3,_Digits);
   R1Buffer[index] = NormalizeDouble((PivotBuffer[index] * 2)-prevLow,_Digits);
   R2Buffer[index] = NormalizeDouble(PivotBuffer[index] + prevRange,_Digits);
   R3Buffer[index] = NormalizeDouble(R2Buffer[index] + prevRange,_Digits);
   R4Buffer[index] = NormalizeDouble(R3Buffer[index] + prevRange,_Digits);
   S1Buffer[index] = NormalizeDouble((PivotBuffer[index] * 2)-prevHigh,_Digits);
   S2Buffer[index] = NormalizeDouble(PivotBuffer[index] - prevRange,_Digits);
   S3Buffer[index] = NormalizeDouble(S2Buffer[index] - prevRange,_Digits);
   S4Buffer[index] = NormalizeDouble(S3Buffer[index] - prevRange,_Digits);
   checkVisiblity(index);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateHistClassic2(int index,int barIndex)
{
   CorrectBarIndex(barIndex);
   double prevRange= iHigh(Symbol(),InpTimeframe,barIndex)-iLow(Symbol(),InpTimeframe,barIndex);
   double prevHigh = iHigh(Symbol(),InpTimeframe,barIndex);
   double prevLow=iLow(Symbol(),InpTimeframe,barIndex);
   double prevClose=iClose(Symbol(),InpTimeframe,barIndex);
   double prevOpen=iOpen(Symbol(),InpTimeframe,barIndex);
   PivotBuffer[index]=NormalizeDouble((prevHigh+prevLow+prevClose+prevOpen)/4,_Digits);
   R1Buffer[index] = NormalizeDouble((PivotBuffer[index] * 2)-prevLow,_Digits);
   R2Buffer[index] = NormalizeDouble(PivotBuffer[index] + prevRange,_Digits);
   R3Buffer[index] = NormalizeDouble(PivotBuffer[index] + (prevRange*2),_Digits);
   R4Buffer[index] = NormalizeDouble(PivotBuffer[index] + (prevRange*3),_Digits);
   S1Buffer[index] = NormalizeDouble((PivotBuffer[index] * 2)-prevHigh,_Digits);
   S2Buffer[index] = NormalizeDouble(PivotBuffer[index] - prevRange,_Digits);
   S3Buffer[index] = NormalizeDouble(PivotBuffer[index] - (prevRange*2),_Digits);
   S4Buffer[index] = NormalizeDouble(PivotBuffer[index] - (prevRange*3),_Digits);
   checkVisiblity(index);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateHistWoodie(int index,int barIndex)
{
   CorrectBarIndex(barIndex);
   double prevRange= iHigh(Symbol(),InpTimeframe,barIndex)-iLow(Symbol(),InpTimeframe,barIndex);
   double prevHigh = iHigh(Symbol(),InpTimeframe,barIndex);
   double prevLow=iLow(Symbol(),InpTimeframe,barIndex);
   double prevClose = iClose(Symbol(), InpTimeframe,barIndex);
   double todayOpen = iOpen(Symbol(), InpTimeframe,barIndex-1);
   PivotBuffer[index]=NormalizeDouble((prevHigh+prevLow+(todayOpen*2))/4,_Digits);
   R1Buffer[index] = NormalizeDouble((PivotBuffer[index] * 2)-prevLow,_Digits);
   R2Buffer[index] = NormalizeDouble(PivotBuffer[index] + prevRange,_Digits);
   R3Buffer[index] = NormalizeDouble(prevHigh + 2*(PivotBuffer[index]-prevLow),_Digits);
   R4Buffer[index] = NormalizeDouble(R3Buffer[index] + prevRange,_Digits);
   S1Buffer[index] = NormalizeDouble((PivotBuffer[index] * 2)-prevHigh,_Digits);
   S2Buffer[index] = NormalizeDouble(PivotBuffer[index] - prevRange,_Digits);
   S3Buffer[index] = NormalizeDouble(prevLow - 2*(prevHigh - PivotBuffer[index]),_Digits);
   S4Buffer[index] = NormalizeDouble(S3Buffer[index] - prevRange,_Digits);
   checkVisiblity(index);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateWoodie()
{
   double prevRange= iHigh(Symbol(),InpTimeframe,PrevCandleIndex)-iLow(Symbol(),InpTimeframe,PrevCandleIndex);
   double prevHigh = iHigh(Symbol(),InpTimeframe,PrevCandleIndex);
   double prevLow=iLow(Symbol(),InpTimeframe,PrevCandleIndex);
   double prevClose = iClose(Symbol(), InpTimeframe,PrevCandleIndex);
   double todayOpen = iOpen(Symbol(), InpTimeframe,CurrentCandleIndex);
   PP = NormalizeDouble((prevHigh+prevLow+(todayOpen*2))/4,_Digits);
   R1 = NormalizeDouble((PP * 2)-prevLow,_Digits);
   R2 = NormalizeDouble(PP + prevRange,_Digits);
   R3 = NormalizeDouble(prevHigh + 2*(PP-prevLow),_Digits);
   R4 = NormalizeDouble(R3 + prevRange,_Digits);
   S1 = NormalizeDouble((PP * 2)-prevHigh,_Digits);
   S2 = NormalizeDouble(PP - prevRange,_Digits);
   S3 = NormalizeDouble(prevLow - 2*(prevHigh - PP),_Digits);
   S4 = NormalizeDouble(S3 - prevRange,_Digits);
   DrawOnChart();

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateClassic1()
{
   double prevRange= iHigh(Symbol(),InpTimeframe,PrevCandleIndex)-iLow(Symbol(),InpTimeframe,PrevCandleIndex);
   double prevHigh = iHigh(Symbol(),InpTimeframe,PrevCandleIndex);
   double prevLow=iLow(Symbol(),InpTimeframe,PrevCandleIndex);
   double prevClose=iClose(Symbol(),InpTimeframe,PrevCandleIndex);
   PP = NormalizeDouble((prevHigh+prevLow+prevClose)/3,_Digits);
   R1 = NormalizeDouble((PP * 2)-prevLow,_Digits);
   R2 = NormalizeDouble(PP + prevRange,_Digits);
   R3 = NormalizeDouble(R2 + prevRange,_Digits);
   R4 = NormalizeDouble(R3 + prevRange,_Digits);
   S1 = NormalizeDouble((PP * 2)-prevHigh,_Digits);
   S2 = NormalizeDouble(PP - prevRange,_Digits);
   S3 = NormalizeDouble(S2 - prevRange,_Digits);
   S4 = NormalizeDouble(S3 - prevRange,_Digits);
   DrawOnChart();

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateClassic2()
{
   double prevRange= iHigh(Symbol(),InpTimeframe,PrevCandleIndex)-iLow(Symbol(),InpTimeframe,PrevCandleIndex);
   double prevHigh = iHigh(Symbol(),InpTimeframe,PrevCandleIndex);
   double prevLow=iLow(Symbol(),InpTimeframe,PrevCandleIndex);
   double prevClose=iClose(Symbol(),InpTimeframe,PrevCandleIndex);
   double prevOpen=iOpen(Symbol(),InpTimeframe,PrevCandleIndex);
   PP = NormalizeDouble((prevHigh+prevLow+prevClose+prevOpen)/4,_Digits);
   R1 = NormalizeDouble((PP * 2)-prevLow,_Digits);
   R2 = NormalizeDouble(PP + prevRange,_Digits);
   R3 = NormalizeDouble(PP + (prevRange*2),_Digits);
   R4 = NormalizeDouble(PP + (prevRange*3),_Digits);
   S1 = NormalizeDouble((PP * 2)-prevHigh,_Digits);
   S2 = NormalizeDouble(PP - prevRange,_Digits);
   S3 = NormalizeDouble(PP - (prevRange*2),_Digits);
   S4 = NormalizeDouble(PP - (prevRange*3),_Digits);
   DrawOnChart();

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void calculateCamarilla()
{
   double camRange = iHigh(Symbol(), InpTimeframe,PrevCandleIndex) - iLow(Symbol(), InpTimeframe,PrevCandleIndex);
   double prevHigh = iHigh(Symbol(), InpTimeframe,PrevCandleIndex);
   double prevLow=iLow(Symbol(),InpTimeframe,PrevCandleIndex);
   double prevClose=iClose(Symbol(),InpTimeframe,PrevCandleIndex);
   R1 = NormalizeDouble(((1.1 / 12) * camRange) + prevClose,_Digits);
   R2 = NormalizeDouble(((1.1 / 6) * camRange) + prevClose,_Digits);
   R3 = NormalizeDouble(((1.1 / 4) * camRange) + prevClose,_Digits);
   R4 = NormalizeDouble(((1.1 / 2) * camRange) + prevClose,_Digits);
   S1 = NormalizeDouble(prevClose - ((1.1 / 12) * camRange),_Digits);
   S2 = NormalizeDouble(prevClose - ((1.1 / 6) * camRange),_Digits);
   S3 = NormalizeDouble(prevClose - ((1.1 / 4) * camRange),_Digits);
   S4 = NormalizeDouble(prevClose - ((1.1 / 2) * camRange),_Digits);
   PP = NormalizeDouble((R4+S4)/2,_Digits);
   DrawOnChart();

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawOnChart()
{
   while(TimeDayOfWeek(StartTime)==SUNDAY || TimeDayOfWeek(StartTime)==SATURDAY || (!InpIncludeSundays && TimeDayOfWeek(StartTime)==SUNDAY))
   {
      StartTime=StartTime+(24*60*60);
   }
   MqlDateTime TimeStruct;
   TimeToStruct(StartTime,TimeStruct);
   if(InpTimeframe==PERIOD_M1)
   {
      StopTime= StartTime+(1*60);
      StopTime=StopTime-OneCandle;
   }
   if(InpTimeframe==PERIOD_M5)
   {
      StopTime= StartTime+(5*60);
      StopTime=StopTime-OneCandle;
   }
   if(InpTimeframe==PERIOD_M15)
   {
      StopTime= StartTime+(15*60);
      StopTime=StopTime-OneCandle;
   }
   if(InpTimeframe==PERIOD_M30)
   {
      StopTime= StartTime+(30*60);
      StopTime=StopTime-OneCandle;
   }
   if(InpTimeframe==PERIOD_H1)
   {
      StopTime= StartTime+(60*60);
      StopTime=StopTime-OneCandle;
   }
   if(InpTimeframe==PERIOD_H4)
   {
      StopTime= StartTime+(4*60*60);
      StopTime=StopTime-OneCandle;
   }
   if(InpTimeframe==PERIOD_D1)
   {
      StopTime = StartTime + (24*60*60);
      StopTime = StopTime-OneCandle;
   }
   if(InpTimeframe==PERIOD_W1)
   {
      StopTime= StartTime+(7*24*60*60);
      StopTime=StopTime-OneCandle;
   }
   if(InpTimeframe==PERIOD_MN1)
   {
      if(TimeStruct.mon<12)
      {
         TimeStruct.mon+=1;
      }
      else
      {
         TimeStruct.mon=1;
         TimeStruct.year+=1;
      }
      StopTime= StructToTime(TimeStruct);
      StopTime=StopTime-OneCandle;
   }
   if(InpShowR1==true)
   {
      DrawTrendLine(0,"R1",InpR1Color,InpR1Style,InpR1Width,StartTime,StopTime,R1,R1,"R1 ("+CalcTypeAbb+"): "+DoubleToString(R1,_Digits));
      if(InpShowMode==SHOW_MODE_TODAY)
      {
         R1Buffer[2]=0;
         R1Buffer[1]=R1;
      }
   }
   if(InpShowR2==true)
   {
      DrawTrendLine(0,"R2",InpR2Color,InpR2Style,InpR2Width,StartTime,StopTime,R2,R2,"R2 ("+CalcTypeAbb+"): "+DoubleToString(R2,_Digits));
      if(InpShowMode==SHOW_MODE_TODAY)
      {
         R2Buffer[2]=0;
         R2Buffer[1]=R2;
      }
   }
   if(InpShowR3==true)
   {
      DrawTrendLine(0,"R3",InpR3Color,InpR3Style,InpR3Width,StartTime,StopTime,R3,R3,"R3 ("+CalcTypeAbb+"): "+DoubleToString(R3,_Digits));
      if(InpShowMode==SHOW_MODE_TODAY)
      {
         R3Buffer[2]=0;
         R3Buffer[1]=R3;
      }
   }
   if(InpShowR4==true)
   {
      DrawTrendLine(0,"R4",InpR4Color,InpR4Style,InpR4Width,StartTime,StopTime,R4,R4,"R4 ("+CalcTypeAbb+"): "+DoubleToString(R4,_Digits));
      if(InpShowMode==SHOW_MODE_TODAY)
      {
         R4Buffer[2]=0;
         R4Buffer[1]=R4;
      }
   }
   if(InpShowS1==true)
   {
      DrawTrendLine(0,"S1",InpS1Color,InpS1Style,InpS1Width,StartTime,StopTime,S1,S1,"S1 ("+CalcTypeAbb+"): "+DoubleToString(S1,_Digits));
      if(InpShowMode==SHOW_MODE_TODAY)
      {
         S1Buffer[2]=0;
         S1Buffer[1]=S1;
      }
   }
   if(InpShowS2==true)
   {
      DrawTrendLine(0,"S2",InpS2Color,InpS2Style,InpS2Width,StartTime,StopTime,S2,S2,"S2 ("+CalcTypeAbb+"): "+DoubleToString(S2,_Digits));
      if(InpShowMode==SHOW_MODE_TODAY)
      {
         S2Buffer[2]=0;
         S2Buffer[1]=S2;
      }
   }
   if(InpShowS3==true)
   {
      DrawTrendLine(0,"S3",InpS3Color,InpS3Style,InpS3Width,StartTime,StopTime,S3,S3,"S3 ("+CalcTypeAbb+"): "+DoubleToString(S3,_Digits));
      if(InpShowMode==SHOW_MODE_TODAY)
      {
         S3Buffer[2]=0;
         S3Buffer[1]=S3;
      }
   }
   if(InpShowS4==true)
   {
      DrawTrendLine(0,"S4",InpS4Color,InpS4Style,InpS4Width,StartTime,StopTime,S4,S4,"S4 ("+CalcTypeAbb+"): "+DoubleToString(S4,_Digits));
      if(InpShowMode==SHOW_MODE_TODAY)
      {
         S4Buffer[2]=0;
         S4Buffer[1]=S4;
      }
   }
   if(InpShowPivot==true)
   {
      DrawTrendLine(0,"Pivot",InpPivotColor,InpPivotStyle,InpPivotWidth,StartTime,StopTime,PP,PP,"P ("+CalcTypeAbb+"): "+DoubleToString(PP,_Digits));
      if(InpShowMode==SHOW_MODE_TODAY)
      {
         PivotBuffer[2]=0;
         PivotBuffer[1]=PP;
      }
   }
   if(InpShowLabels)
   {
      if(InpShowR1) DrawLabel(0,"LR1","R1",clrGray,R1,StartTime,"R1 ("+CalcTypeAbb+")");
      if(InpShowR2) DrawLabel(0,"LR2","R2",clrGray,R2,StartTime,"R2 ("+CalcTypeAbb+")");
      if(InpShowR3) DrawLabel(0,"LR3","R3",clrGray,R3,StartTime,"R3 ("+CalcTypeAbb+")");
      if(InpShowR4) DrawLabel(0,"LR4","R4",clrGray,R4,StartTime,"R4 ("+CalcTypeAbb+")");
      if(InpShowS1) DrawLabel(0,"LS1","S1",clrGray,S1,StartTime,"S1 ("+CalcTypeAbb+")");
      if(InpShowS2) DrawLabel(0,"LS2","S2",clrGray,S2,StartTime,"S2 ("+CalcTypeAbb+")");
      if(InpShowS3) DrawLabel(0,"LS3","S3",clrGray,S3,StartTime,"S3 ("+CalcTypeAbb+")");
      if(InpShowS4) DrawLabel(0,"LS4","S4",clrGray,S4,StartTime,"S4 ("+CalcTypeAbb+")");
      if(InpShowPivot) DrawLabel(0,"LPivot","P",clrGray,PP,StartTime,"P ("+CalcTypeAbb+")");
   }
   if(InpShowPriceTags)
   {
      datetime PriceTagTime=StopTime;
      if(InpShowR1) DrawPriceTag("R1",PriceTagTime,R1,InpR1Color,InpR1Style,InpR1Width);
      if(InpShowR2) DrawPriceTag("R2",PriceTagTime,R2,InpR2Color,InpR2Style,InpR2Width);
      if(InpShowR3) DrawPriceTag("R3",PriceTagTime,R3,InpR3Color,InpR3Style,InpR3Width);
      if(InpShowR4) DrawPriceTag("R4",PriceTagTime,R4,InpR4Color,InpR4Style,InpR4Width);
      if(InpShowS1) DrawPriceTag("S1",PriceTagTime,S1,InpS1Color,InpS1Style,InpS1Width);
      if(InpShowS2) DrawPriceTag("S2",PriceTagTime,S2,InpS2Color,InpS2Style,InpS2Width);
      if(InpShowS3) DrawPriceTag("S3",PriceTagTime,S3,InpS3Color,InpS3Style,InpS3Width);
      if(InpShowS4) DrawPriceTag("S4",PriceTagTime,S4,InpS4Color,InpS4Style,InpS4Width);
      if(InpShowPivot) DrawPriceTag("Pivot",PriceTagTime,PP,InpPivotColor,InpPivotStyle,InpPivotWidth);
   }
   ChartRedraw();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void checkVisiblity(int index)
{
   if(InpShowR1==false) R1Buffer[index]=0;
   if(InpShowR2==false) R2Buffer[index]=0;
   if(InpShowR3==false) R3Buffer[index]=0;
   if(InpShowR4==false) R4Buffer[index]=0;
   if(InpShowS1==false) S1Buffer[index]=0;
   if(InpShowS2==false) S2Buffer[index]=0;
   if(InpShowS3==false) S3Buffer[index]=0;
   if(InpShowS4==false) S4Buffer[index]=0;
   if(InpShowPivot==false) PivotBuffer[index]=0;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTrendLine(long chart_ID,string name,color trendColor,ENUM_LINE_STYLE lineStyle,int lineWidth,datetime timeStart,datetime timeEnd,double StartPrice,double StopPrice,string tooltip="")
{
   name=prefix+name;
   if(ObjectFind(0,name)<0)
   {
      ObjectCreate(chart_ID,name,OBJ_TREND,0,timeStart,StartPrice,timeEnd,StopPrice);
   }
   else
   {
      ObjectSetDouble(chart_ID,name,OBJPROP_PRICE,0,StartPrice);
      ObjectSetDouble(chart_ID,name,OBJPROP_PRICE,1,StopPrice);
      ObjectSetInteger(chart_ID,name,OBJPROP_TIME,0,timeStart);
      ObjectSetInteger(chart_ID,name,OBJPROP_TIME,1,timeEnd);
      return;
   }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,trendColor);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,lineStyle);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,lineWidth);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,false);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,true);
   ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,tooltip);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLabel(long chart_ID,string name,string text,color labelColor,double price,datetime time,string tooltip="")
{
   name=prefix+name;
   if(ObjectFind(0,name)<0)
   {
      ObjectCreate(chart_ID,name,OBJ_TEXT,0,time,price);
   }
   else
   {
      ObjectSetDouble(chart_ID,name,OBJPROP_PRICE,0,price);
      ObjectSetInteger(chart_ID,name,OBJPROP_TIME,0,time);
   }
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,ANCHOR_LEFT_UPPER);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,"Arial");
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,10);
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,0.0);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,labelColor);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,false);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,true);
   ObjectSetString(chart_ID,name,OBJPROP_TOOLTIP,tooltip);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);

}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ExtractCalculationType()
{
   switch(CalculationMode)
   {
   case CALC_MODE_CLASSIC1:
      CalcTypeAbb="Classic1";
      break;
   case CALC_MODE_CLASSIC2:
      CalcTypeAbb="Classic2";
      break;
   case CALC_MODE_CAMARILLA:
      CalcTypeAbb="Cam";
      break;
   case CALC_MODE_FIBONACCI:
      CalcTypeAbb="Fib";
      break;
   case CALC_MODE_FIBONACCI_RETRACEMENT:
      CalcTypeAbb="FibR";
      break;
   case CALC_MODE_FLOOR:
      CalcTypeAbb="Floor";
      break;
   case CALC_MODE_WOODIE:
      CalcTypeAbb="Woodie";
      break;
   default:
      CalcTypeAbb="";
      break;
   }
   CalcTypeAbb+=" "+FriendlyTimeframeName(InpTimeframe);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string FriendlyTimeframeName(ENUM_TIMEFRAMES _period)
{
   if(_period==PERIOD_M1)  return "1Minute";
   if(_period==PERIOD_M5)  return "5Minutes";
   if(_period==PERIOD_M5)  return "15Minutes";
   if(_period==PERIOD_M30) return "30Minutes";
   if(_period==PERIOD_H1)  return "1Hour";
   if(_period==PERIOD_H4)  return "4Hour";
   if(_period==PERIOD_D1)  return "Daily";
   if(_period==PERIOD_W1)  return "Weekly";
   if(_period==PERIOD_MN1) return "Monthly";
   return "";
}
//+------------------------------------------------------------------+
void DrawPriceTag(string name,datetime time,double price,color clr,ENUM_LINE_STYLE style,int width)
{
   name=prefix+"PriceTag_"+name;
   int chart_ID=0;
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW_RIGHT_PRICE,0,time,price))
   {
      ObjectSetInteger(chart_ID,name,OBJPROP_TIME,time);
      ObjectSetDouble(chart_ID,name,OBJPROP_PRICE,price);
   }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,false);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsChartLoaded()
{
   double testArray[];
   if(CopyClose(_Symbol,InpTimeframe,TimeCurrent(),2,testArray)<2)
   {
      Print("Loading ",_Symbol," chart failed...");
      return false;
   }

   StartTime=iTime(_Symbol,InpTimeframe,0);
   if(StartTime==0)
   {
      Print("Loading ",_Symbol," chart failed...");
      return false;
   }

   if(!PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0))         return false;
   if(!PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0))         return false;
   if(!PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0))         return false;
   if(!PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0))         return false;
   if(!PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0))         return false;
   if(!PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0))         return false;
   if(!PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,0))         return false;
   if(!PlotIndexSetDouble(7,PLOT_EMPTY_VALUE,0))         return false;
   if(!PlotIndexSetDouble(8,PLOT_EMPTY_VALUE,0))         return false;

   Print(_Symbol," chart loaded successfully!");

   return true;
}
//+------------------------------------------------------------------+
void UpdateCandlesIndex()
{
   if((InpTimeframe==PERIOD_W1 || InpTimeframe==PERIOD_MN1) || (InpTimeframe==PERIOD_CURRENT && (Period()==PERIOD_W1 || Period()==PERIOD_MN1)))
   {
      CurrentCandleIndex=0;
      PrevCandleIndex=1;
      return;
   }
   int i=0;
   CurrentCandleIndex=i;
   while(TimeDayOfWeek(iTime(_Symbol,InpTimeframe,i))==SATURDAY || (!InpIncludeSundays && TimeDayOfWeek(iTime(_Symbol,InpTimeframe,i))==SUNDAY))
   {
      i++;
      CurrentCandleIndex=i;
   }

   i=CurrentCandleIndex+1;
   PrevCandleIndex=i;
   while(TimeDayOfWeek(iTime(_Symbol,InpTimeframe,i))==SATURDAY || (!InpIncludeSundays && TimeDayOfWeek(iTime(_Symbol,InpTimeframe,i))==SUNDAY))
   {
      i++;
      PrevCandleIndex=i;
   }
}
//+------------------------------------------------------------------+
void CorrectBarIndex(int &barIndex)
{
   if(InpTimeframe==PERIOD_MN1)        return;

   int i=barIndex;
   while(TimeDayOfWeek(iTime(_Symbol,InpTimeframe,i))==SATURDAY || (!InpIncludeSundays && TimeDayOfWeek(iTime(_Symbol,InpTimeframe,i))==SUNDAY))
   {
      i++;
      barIndex=i;
   }
}
//+------------------------------------------------------------------+
int TimeDayOfWeek(datetime date)
{
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day_of_week);
}
//+------------------------------------------------------------------+
string GetTFName()
{
   string Result[];
   if(StringSplit(EnumToString(_Period),'_',Result)>0)
   {
      return Result[1];
   }
   else
   {
      return "";
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendAlert(string _OP)
{
   string message="";
   StringConcatenate(message,_Symbol,"(",CalcTypeToString()," ",APPTFtoString(),") - ",_OP," touched");
   if(InpAlertShowPopup) Alert(message);
   if(InpAlertSendEmail)
   {
      if(!SendMail("APP",message))
      {
         Print("Send email failed with error #",GetLastError());
      }
   }
   if(InpAlertPlaySound)   PlaySound(InpAlertSoundFile);
   if(InpAlertSendNotification)
   {
      if(!SendNotification(message))
      {
         Print("Send notification failed with error #",GetLastError());
      }
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RefreshAlerts()
{
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))          return;

   if(LastTickClose==0)
   {
      LastTickClose=SymbolInfoDouble(_Symbol,SYMBOL_BID);
      return;
   }

   if(InpShowR4)
   {
      if((LastTickClose<R4 && iClose(_Symbol,_Period,0)>=R4) || (LastTickClose>R4 && iClose(_Symbol,_Period,0)<=R4))
      {
         if(LastTouchedLine!="R4")
         {
            if(InpR4Alert)
            {
               SendAlert(StringFormat("R4 (%s)",DoubleToString(R4,_Digits)));
               LastTouchedLine="R4";
            }
         }
      }
   }

   if(InpShowR3)
   {
      if((LastTickClose<R3 && iClose(_Symbol,_Period,0)>=R3) || (LastTickClose>R3 && iClose(_Symbol,_Period,0)<=R3))
      {
         if(LastTouchedLine!="R3")
         {
            if(InpR3Alert)
            {
               SendAlert(StringFormat("R3 (%s)",DoubleToString(R3,_Digits)));
               LastTouchedLine="R3";
            }
         }
      }
   }

   if(InpShowR2)
   {
      if((LastTickClose<R2 && iClose(_Symbol,_Period,0)>=R2) || (LastTickClose>R2 && iClose(_Symbol,_Period,0)<=R2))
      {
         if(LastTouchedLine!="R2")
         {
            if(InpR2Alert)
            {
               SendAlert(StringFormat("R2 (%s)",DoubleToString(R2,_Digits)));
               LastTouchedLine="R2";
            }
         }
      }
   }

   if(InpShowR1)
   {
      if((LastTickClose<R1 && iClose(_Symbol,_Period,0)>=R1) || (LastTickClose>R1 && iClose(_Symbol,_Period,0)<=R1))
      {
         if(LastTouchedLine!="R1")
         {
            if(InpR1Alert)
            {
               SendAlert(StringFormat("R1 (%s)",DoubleToString(R1,_Digits)));
               LastTouchedLine="R1";
            }
         }
      }
   }

   if(InpShowPivot)
   {
      if((LastTickClose<PP && iClose(_Symbol,_Period,0)>=PP) || (LastTickClose>PP && iClose(_Symbol,_Period,0)<=PP))
      {
         if(LastTouchedLine!="PP")
         {
            if(InpPivotAlert)
            {
               SendAlert(StringFormat("PP (%s)",DoubleToString(PP,_Digits)));
               LastTouchedLine="PP";
            }
         }
      }
   }

   if(InpShowS1)
   {
      if((LastTickClose<S1 && iClose(_Symbol,_Period,0)>=S1) || (LastTickClose>S1 && iClose(_Symbol,_Period,0)<=S1))
      {
         if(LastTouchedLine!="S1")
         {
            if(InpS1Alert)
            {
               SendAlert(StringFormat("S1 (%s)",DoubleToString(S1,_Digits)));
               LastTouchedLine="S1";
            }
         }
      }
   }

   if(InpShowS2)
   {
      if((LastTickClose<S2 && iClose(_Symbol,_Period,0)>=S2) || (LastTickClose>S2 && iClose(_Symbol,_Period,0)<=S2))
      {
         if(LastTouchedLine!="S2")
         {
            if(InpS2Alert)
            {
               SendAlert(StringFormat("S2 (%s)",DoubleToString(S2,_Digits)));
               LastTouchedLine="S2";
            }
         }
      }
   }

   if(InpShowS3)
   {
      if((LastTickClose<S3 && iClose(_Symbol,_Period,0)>=S3) || (LastTickClose>S3 && iClose(_Symbol,_Period,0)<=S3))
      {
         if(LastTouchedLine!="S3")
         {
            if(InpS3Alert)
            {
               SendAlert(StringFormat("S3 (%s)",DoubleToString(S3,_Digits)));
               LastTouchedLine="S3";
            }
         }
      }
   }

   if(InpShowS4)
   {
      if((LastTickClose<S4 && iClose(_Symbol,_Period,0)>=S4) || (LastTickClose>S4 && iClose(_Symbol,_Period,0)<=S4))
      {
         if(LastTouchedLine!="S4")
         {
            if(InpS4Alert)
            {
               SendAlert(StringFormat("S4 (%s)",DoubleToString(S4,_Digits)));
               LastTouchedLine="S4";
            }
         }
      }
   }

   LastTickClose=SymbolInfoDouble(_Symbol,SYMBOL_BID);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string APPTFtoString()
{
   string Result[];
   if(StringSplit(EnumToString(InpTimeframe),'_',Result)>0)
   {
      return Result[1];
   }
   else
   {
      return "";
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CalcTypeToString()
{
   string Result="";
   switch(CalculationMode)
   {
   case CALC_MODE_CLASSIC1:
      Result="Classic1";
      break;
   case CALC_MODE_CLASSIC2:
      Result="Classic2";
      break;
   case CALC_MODE_CAMARILLA:
      Result="Cam";
      break;
   case CALC_MODE_FIBONACCI:
      Result="Fib";
      break;
   case CALC_MODE_FIBONACCI_RETRACEMENT:
      Result="FibR";
      break;
   case CALC_MODE_FLOOR:
      Result="Floor";
      break;
   case CALC_MODE_WOODIE:
      Result="Woodie";
      break;
   default:
      Result="";
      break;
   }

   return Result;
}
//+------------------------------------------------------------------+
