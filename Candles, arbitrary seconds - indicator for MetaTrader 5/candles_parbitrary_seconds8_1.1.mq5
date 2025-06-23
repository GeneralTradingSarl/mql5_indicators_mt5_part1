//------------------------------------------------------------------
#property copyright   "mladen"
#property link        "www.forex-tsd.com"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   1

#property indicator_label1  "open;high;low;close"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrGray,clrLimeGreen,clrSandyBrown

//
//
//
//
//

input int Seconds = 3;  // Seconds for candles interval

double canc[],cano[],canh[],canl[],colors[],seconds[][4];
#define sopen  0
#define sclose 1
#define shigh  2
#define slow   3

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,cano  ,INDICATOR_DATA);
   SetIndexBuffer(1,canh  ,INDICATOR_DATA);
   SetIndexBuffer(2,canl  ,INDICATOR_DATA);
   SetIndexBuffer(3,canc  ,INDICATOR_DATA);
   SetIndexBuffer(4,colors,INDICATOR_COLOR_INDEX);
      EventSetTimer(Seconds);
      IndicatorSetString(INDICATOR_SHORTNAME,(string)Seconds+" seconds chart");
   return(0);
}
void OnDeinit(const int reason)
{
   EventKillTimer();
}
void OnTimer()
{
   double close[]; CopyClose(_Symbol,_Period,0,1,close);
   int size = ArrayRange(seconds,0);
             ArrayResize(seconds,size+1);
                         seconds[size][sopen]  = close[0];
                         seconds[size][sclose] = close[0];
                         seconds[size][shigh]  = close[0];
                         seconds[size][slow]   = close[0];
   updateData();                         
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void updateData()
{
   int rates_total = ArraySize(canh);
   int size = ArrayRange(seconds,0); 
      if (size<=0) 
      {
         for (int i=rates_total-1; i>=0; i--)
         {
            canh[i] = EMPTY_VALUE;
            canl[i] = EMPTY_VALUE;
            cano[i] = EMPTY_VALUE;
            canc[i] = EMPTY_VALUE;
         }
         return;
      }         
   double close[]; CopyClose(_Symbol,_Period,0,1,close);
      seconds[size-1][shigh]  = MathMax(seconds[size-1][shigh] ,close[0]);
      seconds[size-1][slow]   = MathMin(seconds[size-1][slow]  ,close[0]);
      seconds[size-1][sclose] =                                 close[0];
   for (int i=(int)MathMin(rates_total-1,size-1); i>=0 && !IsStopped(); i--)
   {
      int y = rates_total-i-1;
         canh[y] = seconds[size-i-1][shigh ];
         canl[y] = seconds[size-i-1][slow  ];
         cano[y] = seconds[size-i-1][sopen ];
         canc[y] = seconds[size-i-1][sclose];
         colors[y] = cano[y]>canc[y] ? 2 : cano[y]<canc[y] ? 1 : 0; 
   }
}

//
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
   int bars = Bars(_Symbol,_Period); if (bars<rates_total) return(-1); updateData();
   return(rates_total);
}