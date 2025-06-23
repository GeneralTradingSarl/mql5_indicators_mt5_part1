//+------------------------------------------------------------------+
//|                                       CorrelationCoefficient.mq5 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1

//--- plot Correlation
#property indicator_label1  "Correlation"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- input parameters
input string               InpSymbol=  "GBPUSD";      // Symbol
input ENUM_APPLIED_PRICE   InpPrice =  PRICE_CLOSE;   // Source
input uint                 InpPeriod=  20;            // Length

//--- indicator buffers
double         ExtBufferCorrelation[];
double         ExtBufferMA1[];
double         ExtBufferMA2[];

//--- global variables
int      ExtHandleMA1;
int      ExtHandleMA2;
int      ExtPeriod;
string   ExtSymbol;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtBufferCorrelation,INDICATOR_DATA);
   SetIndexBuffer(1,ExtBufferMA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,ExtBufferMA2,INDICATOR_CALCULATIONS);
   
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(ExtBufferCorrelation,true);
   ArraySetAsSeries(ExtBufferMA1,true);
   ArraySetAsSeries(ExtBufferMA2,true);
   
//--- setting the period, symbol, short name and levels for the indicator
   ExtPeriod=int(InpPeriod<1 ? 1 : InpPeriod);
   ExtSymbol=InpSymbol;
   if(!CheckSymbol(ExtSymbol))
     {
      PrintFormat("Since the symbol '%s' was not found, use current symbol '%s'",ExtSymbol,Symbol());
      ExtSymbol=Symbol();
     }
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("Correlation Coefficient (%s vs %s)",Symbol(),ExtSymbol));
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0, 1.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1, 0.0);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,-1.0);
   IndicatorSetDouble(INDICATOR_MAXIMUM, 1.2);
   IndicatorSetDouble(INDICATOR_MINIMUM,-1.2);
   
//--- create handle MA
   ResetLastError();
   ExtHandleMA1=iMA(NULL,PERIOD_CURRENT,1,0,MODE_SMA,InpPrice);
   if(ExtHandleMA1==INVALID_HANDLE)
     {
      PrintFormat("The First iMA(%s, %s) object was not created: Error %d",Symbol(),StringSubstr(EnumToString(InpPrice),6),GetLastError());
      return INIT_FAILED;
     }
   ExtHandleMA2=iMA(ExtSymbol,PERIOD_CURRENT,1,0,MODE_SMA,InpPrice);
   if(ExtHandleMA2==INVALID_HANDLE)
     {
      PrintFormat("The Second iMA(%s, %s) object was not created: Error %d",ExtSymbol,StringSubstr(EnumToString(InpPrice),6),GetLastError());
      return INIT_FAILED;
     }
     
//--- success
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
//--- checking for the minimum number of bars for calculation
   if(rates_total<ExtPeriod)
      return 0;
      
//--- checking and calculating the number of bars to be calculated
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-1;
      ArrayInitialize(ExtBufferCorrelation,EMPTY_VALUE);
      ArrayInitialize(ExtBufferMA1,0);
      ArrayInitialize(ExtBufferMA2,0);
     }
     
//--- calculate data of current symbol
   int to_copy=(limit>1 ? rates_total : 1),copied=0;
   copied=CopyBuffer(ExtHandleMA1,0,0,to_copy,ExtBufferMA1);
   if(copied!=to_copy)
      return 0;
//--- calculate data of any second symbol
   int bars=(ExtSymbol!=Symbol() ? Bars(ExtSymbol,PERIOD_CURRENT) : rates_total);
   to_copy=(limit>1 ? fmin(bars,limit) : 1);
   copied=CopyBuffer(ExtHandleMA2,0,0,to_copy,ExtBufferMA2);
   if(copied<1)
      return 0;

//--- correlation coefficient calculation
   double array_a[];
   double array_b[];
   vector a;
   vector b;

   for(int i=limit; i>=0; i--)
     {
      int count=ExtPeriod;
      if(limit>1 && i+count>limit)
         count=limit-i+1;

      if(ArrayCopy(array_a,ExtBufferMA1,0,i,count)!=count || ArrayCopy(array_b,ExtBufferMA2,0,i,count)!=count)
         continue;
      a.Swap(array_a);
      b.Swap(array_b);
      ExtBufferCorrelation[i]=a.CorrCoef(b);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Check symbol                                                     |
//+------------------------------------------------------------------+
bool CheckSymbol(const string symbol)
  {
   bool is_custom;
   if(!SymbolExist(symbol,is_custom))
      return false;
   if(is_custom)
      PrintFormat("The symbol '%s' is custom",symbol);
   return true;
  }
//+------------------------------------------------------------------+
