//+------------------------------------------------------------------+
//|                                                      BB macd.mq5 |
//|                                                 Copyright mladen |
//|                                               mladenfx@gmail.com |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"
#property version   "1.00"


#property indicator_separate_window
#property indicator_buffers   7
#property indicator_plots     3


//
//
//
//
//

#property indicator_label1  "Bollinger bands of MACD"
#property indicator_type1   DRAW_FILLING
#property indicator_color1  C'51,54,57'
#property indicator_label2  "MACD"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  LimeGreen,Lime,MediumOrchid,Magenta
#property indicator_width2  2
#property indicator_label3  "MACD signal"
#property indicator_type3   DRAW_LINE
#property indicator_color3  DimGray
#property indicator_width3  1

//
//
//
//
//

input int                FastEMA   = 12;          // MACD fast EMA period
input int                SlowEMA   = 26;          // MACD slow EMA period
input int                SignalEMA =  9;          // Signal EMA period
input ENUM_APPLIED_PRICE Price     = PRICE_CLOSE; // Aplied price
input double             StDv      = 2.0;         // Bands deviation multiplier


//
//
//
//
//

double BBUpperBand[];
double BBLowerBand[];
double Macd[];
double MacdColors[];
double fastMA[];
double slowMA[];
double signalBuffer[];

int FastMaHandle;
int SlowMaHandle;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,BBUpperBand ,INDICATOR_DATA);         ArraySetAsSeries(BBUpperBand ,true);
   SetIndexBuffer(1,BBLowerBand ,INDICATOR_DATA);         ArraySetAsSeries(BBLowerBand ,true);
   SetIndexBuffer(2,Macd        ,INDICATOR_DATA);         ArraySetAsSeries(Macd        ,true);
   SetIndexBuffer(3,MacdColors  ,INDICATOR_COLOR_INDEX);  ArraySetAsSeries(MacdColors  ,true);
   SetIndexBuffer(4,signalBuffer,INDICATOR_DATA);         ArraySetAsSeries(signalBuffer,true);
   SetIndexBuffer(5,fastMA      ,INDICATOR_CALCULATIONS); ArraySetAsSeries(fastMA      ,true);
   SetIndexBuffer(6,slowMA      ,INDICATOR_CALCULATIONS); ArraySetAsSeries(slowMA      ,true);

   //
   //
   //
   //
   //
     
   FastMaHandle=iMA(NULL,0,FastEMA,0,MODE_EMA,Price);
   SlowMaHandle=iMA(NULL,0,SlowEMA,0,MODE_EMA,Price);
   
   IndicatorSetString(INDICATOR_SHORTNAME,"BB macd ("+(string)FastEMA+","+(string)SlowEMA+","+(string)SignalEMA+")");
   return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//

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

   //
   //
   //
   //
   //

      int last  = (FastEMA>SlowEMA) ? FastEMA: SlowEMA; 
          last  = (SignalEMA>last)  ? SignalEMA : last;
      if (rates_total<=last) return(0);
      
      //
      //
      //
      //
      //
      
      int limit = rates_total-prev_calculated; if (prev_calculated > 0) limit++;
      
         if (!checkCalculated(FastMaHandle,rates_total,"fast MA"))  return(0);
         if (!checkCalculated(SlowMaHandle,rates_total,"slow MA"))  return(0);
         if (!doCopy(FastMaHandle,fastMA,0,limit,"fast MA buffer")) return(0);
         if (!doCopy(SlowMaHandle,slowMA,0,limit,"slow MA buffer")) return(0);
         if (prev_calculated == 0)
         {
            limit -= last;
            for (int i=1; i<=last; i++)
            {
               Macd[rates_total-i]         = 0;
               MacdColors[rates_total-i]   = 0;
               signalBuffer[rates_total-i] = 0;
               BBUpperBand[rates_total-i]  = 0;
               BBLowerBand[rates_total-i]  = 0;
            }
         }

   //
   //
   //
   //
   //

   double alpha = 2.0 / (SignalEMA + 1.0);

      for(int i = limit; i >= 0 ; i--)
      {
         Macd[i]         = fastMA[i]-slowMA[i];
         signalBuffer[i] = signalBuffer[i+1] + alpha*(Macd[i]-signalBuffer[i+1]);
         double standardDeviation = iDeviation(Macd, signalBuffer[i], SignalEMA, i);
               BBUpperBand[i] = signalBuffer[i] + (StDv * standardDeviation);
               BBLowerBand[i] = signalBuffer[i] - (StDv * standardDeviation);

         //
         //
         //
         //
         //

         MacdColors[i] = MacdColors[i+1];
            if (Macd[i]>Macd[i+1]) MacdColors[i] = (Macd[i]<=BBUpperBand[i] && Macd[i]>=BBLowerBand[i]) ? 0 : 1;
            if (Macd[i]<Macd[i+1]) MacdColors[i] = (Macd[i]<=BBUpperBand[i] && Macd[i]>=BBLowerBand[i]) ? 2 : 3;
                     
      }
   
   //
   //
   //
   //
   //
   
   return(rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

double iDeviation(double& array[],double dMA, int period,int shift)
{
   double dSum = 0.00;
      for(int i=0; i<period; i++) dSum += (array[shift+i]-dMA)*(array[shift+i]-dMA);
   return(MathSqrt(dSum/period));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//

bool checkCalculated(int bufferHandle, int total, string checkDescription)
{
   int calculated=BarsCalculated(bufferHandle);
   if (calculated<total)
   {
      Print("Not all data of "+checkDescription+" calculated (",(string)(total-calculated)," un-calculated bars )");
      return(false);
   }
   return(true);
}

//
//
//
//
//

bool doCopy(const int bufferHandle, double& buffer[], const int buffNum, const int copyCount, string copyDescription)
{
   if(CopyBuffer(bufferHandle,buffNum,0,copyCount,buffer)<=0)
   {
      Print("Getting "+copyDescription+" failed! Error",GetLastError());
      return(false);
   }
   return(true);
}
