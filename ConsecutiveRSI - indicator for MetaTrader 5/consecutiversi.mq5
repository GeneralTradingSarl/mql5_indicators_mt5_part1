//+------------------------------------------------------------------+
//|                                               ConsecutiveRSI.mq5 |
//|                                                        Jay Davis |
//|                                         https://www.tidyneat.com |
//+------------------------------------------------------------------+
#property copyright "Jay Davis"
#property link      "https://tidyneat.com"
#property version   "1.00"
#property description "Detect bullish and bearish consecutive candles when entering overbought or oversold territory" 

#property indicator_separate_window 
#property indicator_buffers 5 
#property indicator_plots   5 
//--- drawing iRSI 
#property indicator_label1  "iRSI" 
#property indicator_type1   DRAW_LINE 
#property indicator_color1  clrDodgerBlue 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  1 
//--- the Bullish Consecutive OverSold symbol 
#property indicator_label2  "Bullish_OverSold" 
#property indicator_type2   DRAW_ARROW 
#property indicator_color2  clrOrange
#property indicator_width2  3
//--- the Bearish OverSold symbol
#property indicator_label3  "Bearish OverSold" 
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrOrange
#property indicator_width3  3
//--- the Bullish OverBought symbol 
#property indicator_label4  "Bullish_OverBought" 
#property indicator_type4   DRAW_ARROW 
#property indicator_color4  clrCornflowerBlue
#property indicator_width4  3
//--- the Bearish OverBought symbol
#property indicator_label5  "Bearish_OverBought" 
#property indicator_type5   DRAW_ARROW
#property indicator_color5  clrCornflowerBlue 
#property indicator_width5  3
//--- limits for displaying of values in the indicator window 
#property indicator_maximum 100 
#property indicator_minimum 0 
//--- horizontal levels in the indicator window 
#property indicator_level1  70.0 
#property indicator_level2  30.0 
//--- input parameters 
input int                  consecutive=3; // No. of Consecutive candles
input string               RSI_parameters="===================================";
input int                  ma_period=14;                 // period of averaging 
input int overBought=70;
input int overSold=30;
input ENUM_APPLIED_PRICE   applied_price=PRICE_CLOSE;    // type of price 
input ENUM_TIMEFRAMES      period=PERIOD_CURRENT;        // timeframe 
//--- indicator buffer 
double         iRSIBuffer[],bulloversold[],bearoversold[],
bulloverbought[],bearoverbought[];

//--- variable for storing the handle of the iRSI indicator 
int    handle;
//--- variable for storing 
string name=_Symbol;
//--- name of the indicator on a chart 
string short_name;
//--- we will keep the number of values in the Relative Strength Index indicator 
int    bars_calculated=0;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- set horizontal levels accoring to input overbought and oversold
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,overBought);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,overSold);
//--- set descriptions of horizontal levels
   string display="OverBought "+(string) overBought;
   IndicatorSetString(INDICATOR_LEVELTEXT,0,display);
   display="OverSold "+(string) overSold;
   IndicatorSetString(INDICATOR_LEVELTEXT,1,display);

//--- assignment of array to indicator buffer 
   SetIndexBuffer(0,iRSIBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,bulloversold,INDICATOR_DATA);
   SetIndexBuffer(2,bearoversold,INDICATOR_DATA);
   SetIndexBuffer(3,bulloverbought,INDICATOR_DATA);
   SetIndexBuffer(4,bearoverbought,INDICATOR_DATA);

   PlotIndexSetInteger(1,PLOT_ARROW,246);
   PlotIndexSetInteger(2,PLOT_ARROW,248);
   PlotIndexSetInteger(3,PLOT_ARROW,246);
   PlotIndexSetInteger(4,PLOT_ARROW,248);
//--- Set an empty value
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0);

//--- create handle of the indicator 
   handle=iRSI(name,period,ma_period,applied_price);
//--- if the handle is not created 
   if(handle==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iRSI indicator for the symbol %s/%s, error code %d",
                  name,
                  EnumToString(period),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- show the symbol/timeframe the Relative Strength Index indicator is calculated for 
   short_name=StringFormat("iRSI(%s/%s, %d, %d)",name,EnumToString(period),
                           ma_period,applied_price);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- normal initialization of the indicator 

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
//--- number of values copied from the iRSI indicator 
   int values_to_copy;
//--- determine the number of values calculated in the indicator 
   int calculated=BarsCalculated(handle);
   if(calculated<=0)
     {
      PrintFormat("BarsCalculated() returned %d, error code %d",calculated,GetLastError());
      return(0);
     }
//--- if it is the first start of calculation of the indicator or if the number of values in the iRSI indicator changed 
//---or if it is necessary to calculated the indicator for two or more bars (it means something has changed in the price history) 
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- if the iRSIBuffer array is greater than the number of values in the iRSI indicator for symbol/period, then we don't copy everything  
      //--- otherwise, we copy less than the size of indicator buffers 
      if(calculated>rates_total) values_to_copy=rates_total;
      else                       values_to_copy=calculated;
     }
   else
     {
      //--- it means that it's not the first time of the indicator calculation, and since the last call of OnCalculate() 
      //--- for calculation not more than one bar is added 
      values_to_copy=(rates_total-prev_calculated)+1;
     }
//--- fill the array with values of the iRSI indicator 
//--- if FillArrayFromBuffer returns false, it means the information is nor ready yet, quit operation 
   if(!FillArrayFromBuffer(iRSIBuffer,handle,values_to_copy)) return(0);
//--- form the message 
   string comm=StringFormat("%s ==>  Updated value in the indicator %s: %d",
                            TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),
                            short_name,
                            values_to_copy);
//--- display the service message on the chart 
   Comment(comm);
//--- memorize the number of values in the Relative Strength Index indicator 
   bars_calculated=calculated;
//--- Insert Candle counting logic and fill the buffers
  ArraySetAsSeries(open,false);
  ArraySetAsSeries(close,false);
   int startValue=prev_calculated;
   if(startValue==0)startValue=consecutive;
   for(int i=rates_total; i>startValue; i--)
     {
      if(i<=rates_total-consecutive)
         if(iRSIBuffer[i]>overBought && iRSIBuffer[i-1]<overBought)
           {
            // Check for consecutive candles on overbought cross
            if(ConsecutiveBulls(i,open,close))
              {
               bulloverbought[i]=iRSIBuffer[i];
              }
            else if(ConsecutiveBears(i,open,close))
              {
               bearoverbought[i]=iRSIBuffer[i];
              }
           }
      else if(iRSIBuffer[i]<overSold && iRSIBuffer[i-1]>overSold)
        {
         // Check for consecutive candles on oversold cross
         if(ConsecutiveBulls(i,open,close))
           {
            bulloversold[i]=iRSIBuffer[i];
           }
         else if(ConsecutiveBears(i,open,close))
           {
            bearoversold[i]=iRSIBuffer[i];
           }
        }
     }

//--- return the prev_calculated value for the next call 
   return(rates_total);
  }
//+------------------------------------------------------------------+ 
//| Filling indicator buffers from the iRSI indicator                | 
//+------------------------------------------------------------------+ 
bool FillArrayFromBuffer(double &rsi_buffer[],  // indicator buffer of Relative Strength Index values 
                         int ind_handle,        // handle of the iRSI indicator 
                         int amount             // number of copied values 
                         )
  {
//--- reset error code 
   ResetLastError();
//--- fill a part of the iRSIBuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(ind_handle,0,0,amount,rsi_buffer)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iRSI indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
//--- everything is fine 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Indicator deinitialization function                              | 
//+------------------------------------------------------------------+ 
void OnDeinit(const int reason)
  {
//--- clear the chart after deleting the indicator 
   Comment("");
  }
//+------------------------------------------------------------------+
//| produces true is there is a given number of consecutive bulls    |
//+------------------------------------------------------------------+
bool ConsecutiveBulls(int bar,
                      const double &open[],
                      const double &close[])                    
  {
   for(int i=0; i<consecutive; i++)
     {
      if(open[bar-i]>close[bar-i])
        {
         return false;
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
//| produces true if there is a given number fo consecutive bears    |
//+------------------------------------------------------------------+
bool ConsecutiveBears(int bar,
                      const double &open[],
                      const double &close[])

  {
   for(int i=0; i<consecutive; i++)
     {
      if(open[bar-i]<close[bar-i])
        {
         return false;
        }
     }
   return true;
  }
//+------------------------------------------------------------------+
