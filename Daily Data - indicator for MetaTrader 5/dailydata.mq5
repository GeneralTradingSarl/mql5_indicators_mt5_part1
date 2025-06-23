//+------------------------------------------------------------------+
//|                                                    DailyData.mq5 |
//+------------------------------------------------------------------+
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1  "Daily data"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  SteelBlue,PaleVioletRed,DimGray

//
//
//
//
//

input color TextColor           = White;          // Text color
input color ButtonColor         = SteelBlue;      // Background color
input color AreaColor           = C'72,72,72';    // Area color
input color SymbolColor         = PaleVioletRed;  // Symbol color
input color LabelsColor         = DarkGray;       // Labels color
input color ValuesNeutralColor  = DimGray;        // Color for unchanged values
input color ValuesPositiveColor = MediumSeaGreen; // Color for positive values
input color ValuesNegativeColor = PaleVioletRed;  // Color for negative values
input int   XPosition           = 10;
input int   YPosition           = 10;
input ENUM_BASE_CORNER Corner   = CORNER_RIGHT_UPPER;
input int   CandleShift         = 5;              // Candle shift
input int   TimeFontSize        = 10;             // Font size for timer
input int   TimerShift          = 7;              // Timer shift

//
//
//
//
//

double candleOpen[];
double candleHigh[];
double candleLow[];
double candleClose[];
double candleColor[];

//
//
//
//
//

#define bnameA "DailyDataShowBasic" 
#define bnameB "DailyDataShowSwaps" 
#define bnameC "DailyDataShowCandle" 
#define bnameD "DailyDataShowArea" 
#define bnameE "DailyDataShowTimer" 
#define cnameA "DailyDataArea" 
#define lnameA "DailyDataSymbol" 
#define lnameB "DailyDataClock" 
#define lnameC "DailyDataRange" 
#define lnameD "DailyDataChange" 
#define lnameE "DailyDataDistH" 
#define snameA "DailyDataSwapShort" 
#define snameB "DailyDataSwapLong" 
#define clockName "DailyDataTimer"

//
//
//
//
//

int  atrHandle;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int OnInit()
{
   SetIndexBuffer(0,candleOpen ,INDICATOR_DATA);
   SetIndexBuffer(1,candleHigh ,INDICATOR_DATA);
   SetIndexBuffer(2,candleLow  ,INDICATOR_DATA);
   SetIndexBuffer(3,candleClose,INDICATOR_DATA);
   SetIndexBuffer(4,candleColor,INDICATOR_COLOR_INDEX);
      PlotIndexSetInteger(0,PLOT_SHIFT,CandleShift);
         createObjects(); setControls();
         atrHandle = iATR(NULL,0,30);
   return(0);
}

//
//
//
//
//

void OnDeinit(const int reason)
{
   switch(reason)
   {
      case REASON_REMOVE :
         for (int i=ObjectsTotal(0); i>= 0; i--)
         {
            string name = ObjectName(ChartID(),i);
                  if (StringSubstr(name,0,9)=="DailyData") ObjectDelete(ChartID(),name);
         }
         ChartRedraw();
   }
	if (!getState(bnameE)) EventKillTimer();
}

//
//
//
//
//

void OnTimer( ) {	refreshData(); }
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
   refreshData(); 
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

void refreshData()
{
   static bool inRefresh = false;
           if (inRefresh) return;
               inRefresh = true;
   
   //
   //
   //
   //
   //
   
   int bars = ArraySize(candleClose);
   ENUM_TIMEFRAMES period = PERIOD_D1;
      if (Period()>= PERIOD_D1) period=PERIOD_W1;
      if (Period()>= PERIOD_W1) period=PERIOD_MN1;
         static datetime times[1]; CopyTime(Symbol(),0,0,1,times);
         static MqlRates rates[1]; 
            if (CopyRates( Symbol(),period,0,1,rates)<1) { inRefresh=false; return; }

         //
         //
         //
         //
         //
      
            candleOpen [bars-1] = rates[0].open;
            candleClose[bars-1] = rates[0].close;
            candleHigh [bars-1] = rates[0].high;
            candleLow  [bars-1] = rates[0].low;
            candleColor[bars-1] = 2; 
                  if (candleOpen[bars-1]<candleClose[bars-1]) candleColor[bars-1]=0;
                  if (candleOpen[bars-1]>candleClose[bars-1]) candleColor[bars-1]=1;

            //
            //
            //
            //
            //
         
            ObjectSetDouble(0,cnameA,OBJPROP_PRICE,0,rates[0].high);
            ObjectSetDouble(0,cnameA,OBJPROP_PRICE,1,rates[0].low );
            ObjectSetInteger(0,cnameA,OBJPROP_TIME,0,rates[0].time);
            ObjectSetInteger(0,cnameA,OBJPROP_TIME,1,times[0]);

   //
   //
   //
   //
   //
            
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,bars-1);
   double pipModifier=1;
      if (_Digits==3 || _Digits==5) pipModifier=10;
      setBasicValue(lnameA,DoubleToString(rates[0].close,_Digits)                             ,XPosition,YPosition+20,Corner);
      setBasicValue(lnameB,DoubleToString((rates[0].high-rates[0].low)  /_Point/pipModifier,1),XPosition,YPosition+38,Corner);
      setBasicValue(lnameC,DoubleToString((rates[0].close-rates[0].open)/_Point/pipModifier,1),XPosition,YPosition+56,Corner);
      setBasicValue(lnameD,DoubleToString((rates[0].high-rates[0].close)/_Point/pipModifier,1),XPosition,YPosition+74,Corner);
      setBasicValue(lnameE,DoubleToString((rates[0].close-rates[0].low) /_Point/pipModifier,1),XPosition,YPosition+92,Corner);

      setSwapValue(snameA,DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT),1),XPosition,YPosition+20,Corner);
      setSwapValue(snameB,DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG) ,1),XPosition,YPosition+38,Corner);

   //
   //
   //
   //
   //
   
   if (!getState(bnameE)) ShowClock(); ChartRedraw();
   inRefresh=false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void OnChartEvent(const int id,const long& lparam,const double& dparam,const string& sparam)
{
   if(id==CHARTEVENT_OBJECT_CLICK)
   {
      if (sparam==bnameA) setControls();
      if (sparam==bnameB) setControls();
      if (sparam==bnameC) setControls();
      if (sparam==bnameD) setControls();
      if (sparam==bnameE) setControls();
   }      
}

//
//
//
//
//

void createObjects()
{
   if (ObjectFind(0,bnameA)<0) { ObjectCreate(0,bnameA,OBJ_BUTTON   ,0,0,0,0,0); }
   if (ObjectFind(0,bnameB)<0) { ObjectCreate(0,bnameB,OBJ_BUTTON   ,0,0,0,0,0); }
   if (ObjectFind(0,bnameC)<0) { ObjectCreate(0,bnameC,OBJ_BUTTON   ,0,0,0,0,0); }
   if (ObjectFind(0,bnameD)<0) { ObjectCreate(0,bnameD,OBJ_BUTTON   ,0,0,0,0,0); }
   if (ObjectFind(0,bnameE)<0) { ObjectCreate(0,bnameE,OBJ_BUTTON   ,0,0,0,0,0); }
   if (ObjectFind(0,cnameA)<0) { ObjectCreate(0,cnameA,OBJ_RECTANGLE,0,0,0,0,0); }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

bool getState(string name)
{
   bool ans = (int)ObjectGetInteger(0,name,OBJPROP_STATE);
   return(ans);
}
void setVisibleState(string control, bool state)
{
   if (state)
         ObjectSetInteger(0,control,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   else  ObjectSetInteger(0,control,OBJPROP_TIMEFRAMES,OBJ_NO_PERIODS);
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

#define heightForBasic 110
#define heightForSwap  56
int     heightTotal; 

//
//
//
//
//

void setControls()
{
   int heightBasic  = 20; if (!getState(bnameA)) heightBasic = heightForBasic;
   int heightSwap   = 20; if (!getState(bnameB)) heightSwap  = heightForSwap;
   int heightCandle = 20;
   int heightArea   = 20;
   int heightTimer  = 20;
       heightTotal  =  YPosition+heightArea+heightBasic+heightCandle+heightSwap+heightTimer;

   //
   //
   //
   //
   //
   
   int pos = YPosition;
   string caption;
      if (!getState(bnameA))
            caption = "Hide basic data";
      else  caption = "Show basic data";
      setButton(bnameA,caption,XPosition,pos,TextColor,ButtonColor,Corner);
      
      pos+=heightBasic;
      if (!getState(bnameB))
            caption = "Hide swaps";
      else  caption = "Show swaps";
      setButton(bnameB,caption,XPosition,pos,TextColor,ButtonColor,Corner);

      pos+=heightSwap;
      if (!getState(bnameC))
            caption = "Hide candle";
      else  caption = "Show candle";
      setButton(bnameC,caption,XPosition,pos,TextColor,ButtonColor,Corner);
      
      pos+=heightCandle;
      if (!getState(bnameD))
            caption = "Hide area";
      else  caption = "Show area";
      setButton(bnameD,caption,XPosition,pos,TextColor,ButtonColor,Corner);

      pos+=heightArea;
      if (!getState(bnameE))
            caption = "Hide timer";
      else  caption = "Show timer";
      setButton(bnameE,caption,XPosition,pos,TextColor,ButtonColor,Corner);
      setVisibleState(clockName,!getState(bnameE));
            if (!getState(bnameE))
                  EventSetTimer(1);
            else  EventKillTimer();

   //
   //
   //
   //
   //
   
      ObjectSetInteger(0,cnameA,OBJPROP_COLOR,AreaColor);
      ObjectSetInteger(0,cnameA,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,cnameA,OBJPROP_BACK,true);
         setVisibleState(cnameA,!getState(bnameD));

      //
      //
      //
      //
      //
      
         setBasicLabel(lnameA,Symbol()            ,XPosition,YPosition+20,Corner,SymbolColor,13);
         setBasicLabel(lnameB,"range"             ,XPosition,YPosition+38,Corner,LabelsColor);
         setBasicLabel(lnameC,"change"            ,XPosition,YPosition+56,Corner,LabelsColor);
         setBasicLabel(lnameD,"distance from high",XPosition,YPosition+74,Corner,LabelsColor);
         setBasicLabel(lnameE,"distance from low" ,XPosition,YPosition+92,Corner,LabelsColor);
         setVisibleState(lnameA+"v",!getState(bnameA));
         setVisibleState(lnameB+"v",!getState(bnameA));
         setVisibleState(lnameC+"v",!getState(bnameA));
         setVisibleState(lnameD+"v",!getState(bnameA));
         setVisibleState(lnameE+"v",!getState(bnameA));
            ObjectSetInteger(0,lnameA+"v",OBJPROP_YDISTANCE,ObjectGetInteger(0,lnameA,OBJPROP_YDISTANCE));
            ObjectSetInteger(0,lnameB+"v",OBJPROP_YDISTANCE,ObjectGetInteger(0,lnameB,OBJPROP_YDISTANCE));
            ObjectSetInteger(0,lnameC+"v",OBJPROP_YDISTANCE,ObjectGetInteger(0,lnameC,OBJPROP_YDISTANCE));
            ObjectSetInteger(0,lnameD+"v",OBJPROP_YDISTANCE,ObjectGetInteger(0,lnameD,OBJPROP_YDISTANCE));
            ObjectSetInteger(0,lnameE+"v",OBJPROP_YDISTANCE,ObjectGetInteger(0,lnameE,OBJPROP_YDISTANCE));
      
      //
      //
      //
      //
      //
      
         setSwapLabel(snameA,"swap short",XPosition,YPosition+20,Corner,LabelsColor);
         setSwapLabel(snameB,"swap long" ,XPosition,YPosition+38,Corner,LabelsColor);
         setVisibleState(snameA+"v",!getState(bnameB));
         setVisibleState(snameB+"v",!getState(bnameB));
            ObjectSetInteger(0,snameA+"v",OBJPROP_YDISTANCE,ObjectGetInteger(0,snameA,OBJPROP_YDISTANCE));
            ObjectSetInteger(0,snameB+"v",OBJPROP_YDISTANCE,ObjectGetInteger(0,snameB,OBJPROP_YDISTANCE));
   
   //
   //
   //
   //
   //

      if (getState(bnameC))
            PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
      else  PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_COLOR_CANDLES);
   ChartRedraw();
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void setButton(string name, string caption, int xposition, int yposition, color textColor, color backColor, int corner)
{
   int relXPosition = xposition; if (corner==2 || corner==3) relXPosition  = 190+xposition;
   int relYPosition = yposition; if (corner==1 || corner==2) relYPosition  = heightTotal-yposition+YPosition;
   
      ObjectSetInteger(0,name,OBJPROP_COLOR,textColor);
      ObjectSetInteger(0,name,OBJPROP_BGCOLOR,backColor);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,relXPosition);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,relYPosition);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,190);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,18);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,10);
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,corner);
         ObjectSetString(0,name,OBJPROP_FONT,"Arial");
         ObjectSetString(0,name,OBJPROP_TEXT,caption);
}

//
//
//
//
//

void setBasicLabel(string name, string label, int xposition, int yposition, int corner, color labelColor, int fontSize=10, ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT_UPPER, string statusCheck = bnameA, int displacement=0)
{
   int relXPosition = xposition;              if (corner==2 || corner==3) relXPosition = 190+xposition;
   int relYPosition = yposition+displacement; if (corner==1 || corner==2) relYPosition = heightTotal-yposition-displacement+YPosition;

   //
   //
   //
   //
   //
   
   if (ObjectFind(0,name)<0) ObjectCreate(0,name,OBJ_LABEL,0,0,0,0,0);
      ObjectSetInteger(0,name,OBJPROP_CORNER,corner);
      ObjectSetInteger(0,name,OBJPROP_COLOR,labelColor);
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,relXPosition);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,relYPosition);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,anchor);
      ObjectSetInteger(0,name,OBJPROP_FONTSIZE,fontSize);
            ObjectSetString(0,name,OBJPROP_FONT,"Arial");
            ObjectSetString(0,name,OBJPROP_TEXT,label);
      setVisibleState(name,!getState(statusCheck));
}

//
//
//
//
//

void setBasicValue(string name, string value, int xposition, int yposition, int corner, int fontSize=12, string statusCheck = bnameA, int displacement=0 )
{
   double dvalue = StringToDouble(value);
   color  cvalue = ValuesNeutralColor;
   
      if (dvalue>0) cvalue = ValuesPositiveColor;
      if (dvalue<0) cvalue = ValuesNegativeColor;
      if (corner==0 || corner==1) xposition += 190;
      if (corner==2 || corner==3) xposition -= 190;
         setBasicLabel(name+"v",value,xposition,yposition,corner,cvalue,fontSize,ANCHOR_RIGHT_UPPER,statusCheck,displacement);
}

//
//
//
//
//

void setSwapLabel(string name, string label, int xposition, int yposition, int corner, color labelColor, int fontSize=10)
{
   int heightBasic = !getState(bnameA) ? heightForBasic : 20;
         setBasicLabel(name,label,xposition,yposition,corner,labelColor,fontSize,ANCHOR_LEFT_UPPER,bnameB,heightBasic);
}
void setSwapValue(string name, string value, int xposition, int yposition, int corner, int fontSize=12)
{
   int heightBasic = !getState(bnameA) ? heightForBasic : 20;
         setBasicValue(name,value,xposition,yposition,corner,fontSize,bnameB,heightBasic);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void ShowClock()
{
   int periodMinutes = periodToMinutes(Period());
   int shift         = periodMinutes*TimerShift*60;
   int currentTime   = (int)TimeCurrent();
   int localTime     = (int)TimeLocal();
   int barTime       = (int)iTime();
   int diff          = (int)MathMax(round((currentTime-localTime)/3600.0)*3600,-24*3600);

   //
   //
   //
   //
   //

      color  theColor;
      string time = getTime(barTime+periodMinutes*60-localTime-diff,theColor);
             time = (TerminalInfoInteger(TERMINAL_CONNECTED)) ? time : time+" x";

      //
      //
      //
      //
      //
                          
      if(ObjectFind(0,clockName) < 0)
         ObjectCreate(0,clockName,OBJ_TEXT,0,barTime+shift,0);
         ObjectSetString(0,clockName,OBJPROP_TEXT,time);
         ObjectSetString(0,clockName,OBJPROP_FONT,"Arial");
         ObjectSetInteger(0,clockName,OBJPROP_FONTSIZE,TimeFontSize);
         ObjectSetInteger(0,clockName,OBJPROP_COLOR,theColor);
         if (ChartGetInteger(0,CHART_SHIFT,0)==0 && (shift >=0))
               ObjectSetInteger(0,clockName,OBJPROP_TIME,barTime-shift*3);
         else  ObjectSetInteger(0,clockName,OBJPROP_TIME,barTime+shift);

      //
      //
      //
      //
      //

      double price[]; if (CopyClose(Symbol(),0,0,1,price)<=0) return;
      double atr[];   if (CopyBuffer(atrHandle,0,0,1,atr)<=0) return;
             price[0] += 3.0*atr[0]/4.0;
             
      //
      //
      //
      //
      //

      bool visible = ((ChartGetInteger(0,CHART_VISIBLE_BARS,0)-ChartGetInteger(0,CHART_FIRST_VISIBLE_BAR,0)) > 0);
      if ( visible && price[0]>=ChartGetDouble(0,CHART_PRICE_MAX,0))
            ObjectSetDouble(0,clockName,OBJPROP_PRICE,price[0]-1.5*atr[0]);
      else  ObjectSetDouble(0,clockName,OBJPROP_PRICE,price[0]);
}


//+------------------------------------------------------------------+
//|
//+------------------------------------------------------------------+
//
//
//
//
//

string getTime(int times, color& theColor)
{
   string stime = "";
   int    seconds;
   int    minutes;
   int    hours;
   
   //
   //
   //
   //
   //
   
   if (times < 0) {
         theColor = ValuesNegativeColor; times = (int)fabs(times); }
   else  theColor = ValuesPositiveColor;
   seconds = (times%60);
   hours   = (times-times%3600)/3600;
   minutes = (times-seconds)/60-hours*60;

   //
   //
   //
   //
   //
   
   if (hours>0)
   if (minutes < 10)
         stime = stime+(string)hours+":0";
   else  stime = stime+(string)hours+":";
         stime = stime+(string)minutes;
   if (seconds < 10)
         stime = stime+":0"+(string)seconds;
   else  stime = stime+":" +(string)seconds;
   return(stime);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

datetime iTime(ENUM_TIMEFRAMES forPeriod=PERIOD_CURRENT)
{
   datetime times[]; if (CopyTime(Symbol(),forPeriod,0,1,times)<=0) return(TimeLocal());
   return(times[0]);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int periodToMinutes(int period)
{
   int i;
   static int _per[]={1,2,3,4,5,6,10,12,15,20,30,0x4001,0x4002,0x4003,0x4004,0x4006,0x4008,0x400c,0x4018,0x8001,0xc001};
   static int _min[]={1,2,3,4,5,6,10,12,15,20,30,60,120,180,240,360,480,720,1440,10080,43200};

   if (period==PERIOD_CURRENT) 
       period = Period();   
            for(i=0;i<20;i++) if(period==_per[i]) break;
   return(_min[i]);   
}
