//+------------------------------------------------------------------+
//|                        Convert iExposure.mq4 From MetaQuotes.mq5 |
//|                                                    Dwi Sudarsono |
//|                                        https://t.me/DwiSudarsono |
//+------------------------------------------------------------------+
#property copyright "Dwi Sudarsono"
#property link      "https://t.me/DwiSudarsono"
#property version   "1.00"
#property indicator_separate_window
#property indicator_plots 0
#property indicator_buffers 1
#property indicator_minimum 0.0
#property indicator_maximum 0.1

#define SYMBOLS_MAX 1024
#define DEALS          0
#define BUY_LOTS       1
#define BUY_PRICE      2
#define SELL_LOTS      3
#define SELL_PRICE     4
#define NET_LOTS       5
#define PROFIT         6

input color InpColor=LightSeaGreen;  // Text color

string ExtName="Exposure";
string ExtSymbols[SYMBOLS_MAX];
int    ExtSymbolsTotal=0;
double ExtSymbolsSummaries[SYMBOLS_MAX][7];
int    ExtLines=-1;
string ExtCols[8]= {"Symbol",
                    "Deals",
                    "Buy lots",
                    "Buy price",
                    "Sell lots",
                    "Sell price",
                    "Net lots",
                    "Profit",
                   };
int    ExtShifts[8]= { 10, 80, 130, 180, 260, 310, 390, 460 };
int    ExtVertShift=14;
double ExtMapBuffer[];
long chartid = 0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME,ExtName);
   SetIndexBuffer(0,ExtMapBuffer,INDICATOR_CALCULATIONS);
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
   IndicatorSetInteger(INDICATOR_DIGITS,0);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   int windex=ChartWindowFind(chartid,ExtName);
   if(windex>0)
      ObjectsDeleteAll(windex);

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
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   string name;
   int    i,col,line,windex=ChartWindowFind(chartid,ExtName);
//----
   if(windex<0)
      return(rates_total);
//---- header line
   if(ExtLines<0)
     {
      for(col=0; col<8; col++)
        {
         name="Head_"+string(col);
         if(ObjectCreate(chartid,name,OBJ_LABEL,windex,0,0))
           {
            ObjectSetInteger(chartid,name,OBJPROP_XDISTANCE,ExtShifts[col]);
            ObjectSetInteger(chartid,name,OBJPROP_YDISTANCE,ExtVertShift);
            ObjectSetString(chartid,name,OBJPROP_TEXT,ExtCols[col]);
            ObjectSetString(chartid,name,OBJPROP_FONT,"Arial");
            ObjectSetInteger(chartid,name,OBJPROP_FONTSIZE,9);
            ObjectSetInteger(chartid,name,OBJPROP_COLOR,InpColor);
           }
        }
      ExtLines=0;
     }
//----
   ArrayInitialize(ExtSymbolsSummaries,0.0);
   int total=Analyze();
   if(total>0)
     {
      line=0;
      for(i=0; i<ExtSymbolsTotal; i++)
        {
         if(ExtSymbolsSummaries[i][DEALS]<=0)
            continue;
         line++;
         //---- add line
         if(line>ExtLines)
           {
            int y_dist=ExtVertShift*(line+1)+1;
            for(col=0; col<8; col++)
              {
               name="Line_"+string(line)+"_"+string(col);
               if(ObjectCreate(chartid,name,OBJ_LABEL,windex,0,0))
                 {
                  ObjectSetInteger(chartid,name,OBJPROP_XDISTANCE,ExtShifts[col]);
                  ObjectSetInteger(chartid,name,OBJPROP_YDISTANCE,y_dist);
                 }
              }
            ExtLines++;
           }
         //---- set line
         int    digits=(int)SymbolInfoInteger(ExtSymbols[i],SYMBOL_DIGITS);
         double buy_lots=ExtSymbolsSummaries[i][BUY_LOTS];
         double sell_lots=ExtSymbolsSummaries[i][SELL_LOTS];
         double buy_price=0.0;
         double sell_price=0.0;
         if(buy_lots!=0)
            buy_price=ExtSymbolsSummaries[i][BUY_PRICE]/buy_lots;
         if(sell_lots!=0)
            sell_price=ExtSymbolsSummaries[i][SELL_PRICE]/sell_lots;
         name="Line_"+string(line)+"_0";
           {
            ObjectSetString(chartid,name,OBJPROP_TEXT,ExtSymbols[i]);
            ObjectSetString(chartid,name,OBJPROP_FONT,"Arial");
            ObjectSetInteger(chartid,name,OBJPROP_FONTSIZE,9);
            ObjectSetInteger(chartid,name,OBJPROP_COLOR,InpColor);
           }
         name="Line_"+string(line)+"_1";
           {
            ObjectSetString(chartid,name,OBJPROP_TEXT,DoubleToString(ExtSymbolsSummaries[i][DEALS],0));
            ObjectSetString(chartid,name,OBJPROP_FONT,"Arial");
            ObjectSetInteger(chartid,name,OBJPROP_FONTSIZE,9);
            ObjectSetInteger(chartid,name,OBJPROP_COLOR,InpColor);
           }
         name="Line_"+string(line)+"_2";
           {
            ObjectSetString(chartid,name,OBJPROP_TEXT,DoubleToString(buy_lots,2));
            ObjectSetString(chartid,name,OBJPROP_FONT,"Arial");
            ObjectSetInteger(chartid,name,OBJPROP_FONTSIZE,9);
            ObjectSetInteger(chartid,name,OBJPROP_COLOR,InpColor);
           }
         name="Line_"+string(line)+"_3";
           {
            ObjectSetString(chartid,name,OBJPROP_TEXT,DoubleToString(buy_price,digits));
            ObjectSetString(chartid,name,OBJPROP_FONT,"Arial");
            ObjectSetInteger(chartid,name,OBJPROP_FONTSIZE,9);
            ObjectSetInteger(chartid,name,OBJPROP_COLOR,InpColor);
           }
         name="Line_"+string(line)+"_4";
           {
            ObjectSetString(chartid,name,OBJPROP_TEXT,DoubleToString(sell_lots,2));
            ObjectSetString(chartid,name,OBJPROP_FONT,"Arial");
            ObjectSetInteger(chartid,name,OBJPROP_FONTSIZE,9);
            ObjectSetInteger(chartid,name,OBJPROP_COLOR,InpColor);
           }
         name="Line_"+string(line)+"_5";
           {
            ObjectSetString(chartid,name,OBJPROP_TEXT,DoubleToString(sell_price,digits));
            ObjectSetString(chartid,name,OBJPROP_FONT,"Arial");
            ObjectSetInteger(chartid,name,OBJPROP_FONTSIZE,9);
            ObjectSetInteger(chartid,name,OBJPROP_COLOR,InpColor);
           }
         name="Line_"+string(line)+"_6";
           {
            ObjectSetString(chartid,name,OBJPROP_TEXT,DoubleToString(buy_lots-sell_lots,2));
            ObjectSetString(chartid,name,OBJPROP_FONT,"Arial");
            ObjectSetInteger(chartid,name,OBJPROP_FONTSIZE,9);
            ObjectSetInteger(chartid,name,OBJPROP_COLOR,InpColor);
           }
         name="Line_"+string(line)+"_7";
           {
            ObjectSetString(chartid,name,OBJPROP_TEXT,DoubleToString(ExtSymbolsSummaries[i][PROFIT],2));
            ObjectSetString(chartid,name,OBJPROP_FONT,"Arial");
            ObjectSetInteger(chartid,name,OBJPROP_FONTSIZE,9);
            ObjectSetInteger(chartid,name,OBJPROP_COLOR,InpColor);
           }
        }
     }
//---- remove lines
   if(total<ExtLines)
     {
      for(line=ExtLines; line>total; line--)
        {
         name="Line_"+string(line)+"_0";
         ObjectSetString(chartid,name,OBJPROP_TEXT," ");
         name="Line_"+string(line)+"_1";
         ObjectSetString(chartid,name,OBJPROP_TEXT," ");
         name="Line_"+string(line)+"_2";
         ObjectSetString(chartid,name,OBJPROP_TEXT," ");
         name="Line_"+string(line)+"_3";
         ObjectSetString(chartid,name,OBJPROP_TEXT," ");
         name="Line_"+string(line)+"_4";
         ObjectSetString(chartid,name,OBJPROP_TEXT," ");
         name="Line_"+string(line)+"_5";
         ObjectSetString(chartid,name,OBJPROP_TEXT," ");
         name="Line_"+string(line)+"_6";
         ObjectSetString(chartid,name,OBJPROP_TEXT," ");
         name="Line_"+string(line)+"_7";
         ObjectSetString(chartid,name,OBJPROP_TEXT," ");
        }
     }
//---- to avoid minimum==maximum
   int bars=iBars(_Symbol,_Period);
   ExtMapBuffer[bars-1]=-1;
//----
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Analyze()
  {
   double profit;
   int    i,index,total=PositionsTotal();
//----
   for(i=0; i<total; i++)
     {
      if(!PositionGetTicket(i))
         continue;
      if(PositionGetInteger(POSITION_TYPE)!=POSITION_TYPE_BUY && PositionGetInteger(POSITION_TYPE)!=POSITION_TYPE_SELL)
         continue;
      index=SymbolsIndex(PositionGetString(POSITION_SYMBOL));
      if(index<0 || index>=SYMBOLS_MAX)
         continue;
      //----
      ExtSymbolsSummaries[index][DEALS]++;
      profit=PositionGetDouble(POSITION_PROFIT)+PositionGetDouble(POSITION_SWAP)+AccountInfoDouble(ACCOUNT_COMMISSION_BLOCKED);
      ExtSymbolsSummaries[index][PROFIT]+=profit;
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         ExtSymbolsSummaries[index][BUY_LOTS]+=PositionGetDouble(POSITION_VOLUME);
         ExtSymbolsSummaries[index][BUY_PRICE]+=PositionGetDouble(POSITION_PRICE_OPEN)*PositionGetDouble(POSITION_VOLUME);
        }
      else
        {
         ExtSymbolsSummaries[index][SELL_LOTS]+=PositionGetDouble(POSITION_VOLUME);
         ExtSymbolsSummaries[index][SELL_PRICE]+=PositionGetDouble(POSITION_PRICE_OPEN)*PositionGetDouble(POSITION_VOLUME);
        }

     }
//----
   total=0;
   for(i=0; i<ExtSymbolsTotal; i++)
     {
      if(ExtSymbolsSummaries[i][DEALS]>0)
         total++;
     }
//----
   return(total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SymbolsIndex(string SymbolName)
  {
   bool found=false;
   int  i;
//----
   for(i=0; i<ExtSymbolsTotal; i++)
     {
      if(SymbolName==ExtSymbols[i])
        {
         found=true;
         break;
        }
     }
//----
   if(found)
      return(i);
   if(ExtSymbolsTotal>=SYMBOLS_MAX)
      return(-1);
//----
   i=ExtSymbolsTotal;
   ExtSymbolsTotal++;
   ExtSymbols[i]=SymbolName;
   ExtSymbolsSummaries[i][DEALS]=0;
   ExtSymbolsSummaries[i][BUY_LOTS]=0;
   ExtSymbolsSummaries[i][BUY_PRICE]=0;
   ExtSymbolsSummaries[i][SELL_LOTS]=0;
   ExtSymbolsSummaries[i][SELL_PRICE]=0;
   ExtSymbolsSummaries[i][NET_LOTS]=0;
   ExtSymbolsSummaries[i][PROFIT]=0;
//----
   return(i);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+