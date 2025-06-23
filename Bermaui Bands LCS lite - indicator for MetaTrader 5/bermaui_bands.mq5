//+------------------------------------------------------------------+
//|                                                Bermaui Bands.mq5 |
//|                                                            Misha |
//|                                                textyping@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Misha"
#property link      "textyping@mail.ru"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot MiddleBB
#property indicator_label1  "MiddleBB"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrGray
#property indicator_style1  STYLE_DASH
#property indicator_width1  1
//--- plot UpperBB
#property indicator_label2  "UpperBB"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGray
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot LowerBB
#property indicator_label3  "LowerBB"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

input    int               candles        = 50;       // Candles [Min=2]
input    double            deviation      = 2.1;      // Deviation Multiplier [>0]
// input    int               width          = 2;        // Bands Width

double         dev, csd[], bbMiddle[], bbUpper[], bbLower[], maxValue, minValue, curValue;

int            handleStdDev, handleMA, handleBB;

//--- indicator buffers
double         MiddleBBBuffer[];
double         UpperBBBuffer[];
double         LowerBBBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,MiddleBBBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,UpperBBBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,LowerBBBuffer,INDICATOR_DATA);
   
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, 2);
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, 2);
   
   handleStdDev = iStdDev (_Symbol, PERIOD_CURRENT, candles, 0, MODE_SMA, PRICE_CLOSE);
   handleMA = iMA (_Symbol, PERIOD_CURRENT, candles, 0, MODE_SMA, PRICE_CLOSE); 
   handleBB = iBands(_Symbol, PERIOD_CURRENT, candles, 0, deviation, PRICE_CLOSE);
   
//---
   return(INIT_SUCCEEDED);
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
   for (int i = prev_calculated-1; i < rates_total; i++)
    {
     if (i < 0) continue;
     if (i <= candles * 2) 
      {
       MiddleBBBuffer[i] = EMPTY_VALUE;
       UpperBBBuffer[i] = EMPTY_VALUE;
       LowerBBBuffer[i] = EMPTY_VALUE;
       continue;
      }
     CopyBuffer (handleStdDev, 0, rates_total - i - 1, candles, csd);
     CopyBuffer (handleBB, BASE_LINE, rates_total - i - 1, 1, bbMiddle);
     CopyBuffer (handleBB, UPPER_BAND, rates_total - i - 1, 1, bbUpper);
     CopyBuffer (handleBB, LOWER_BAND, rates_total - i - 1, 1, bbLower);
     maxValue = csd[ArrayMaximum(csd)];
     minValue = csd[ArrayMinimum(csd)];
     curValue = csd [candles - 1];
    
     dev = (maxValue - curValue) / (maxValue - minValue);
     
     MiddleBBBuffer[i] = bbMiddle[0];
     UpperBBBuffer[i] = bbMiddle[0] + dev * (bbUpper[0] - bbMiddle[0]);
     LowerBBBuffer[i] = bbMiddle[0] + dev * (bbLower[0] - bbMiddle[0]);
    }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
