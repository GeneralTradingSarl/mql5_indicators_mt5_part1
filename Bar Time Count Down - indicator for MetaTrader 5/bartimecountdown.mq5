//+------------------------------------------------------------------+
//|                                             BarTimeCountDown.mq5 |
//|                                          Copyright 2014,fxMeter. |
//|                            https://www.mql5.com/en/users/fxmeter |
//+------------------------------------------------------------------+
//2020-6-12 14:17:58
//MT4 version https://www.mql5.com/en/code/29646
//MT5 version https://www.mql5.com/en/code/29647
//2017-11-13 publish to MQL5.COM code base
//2014-11-15 create
#property copyright "Copyright 2014,fxMeter."
#property link      "https://mql5.com/en/users/fxmeter"
#property version   "1.00"
#property indicator_chart_window
#define  OBJ_NAME "time_left_label"
#define  FONT_NAME "Microsoft YaHei"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_POS_TL
{
   FOLLOW_PRICE,
   FIXED_POSITION
};
input color  LabelColor=clrOrangeRed;
input ENUM_POS_TL LabelPosition=FIXED_POSITION;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteLabel()
{
   int try=10;
   while(ObjectFind(0,OBJ_NAME)==0)
   {
      ObjectDelete(0,OBJ_NAME);
      if(try--<=0)break;
   }
}
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   EventSetTimer(1);
   DeleteLabel();
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   EventKillTimer();
   DeleteLabel();
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

//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
{
//---
   UpdateTimeLeft();
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateTimeLeft()
{

   int seconds=0;// the left seconds of the current bar
   int h = 0; //Hour
   int m = 0; //Minute
   int s = 0; //Second  hh:mm:ss

   datetime time  = iTime(Symbol(),PERIOD_CURRENT,0);
   double   close = iClose(Symbol(),PERIOD_CURRENT,0);

   seconds=PeriodSeconds(PERIOD_CURRENT) -(int)(TimeCurrent()-time);

   h = seconds/3600;
   m = (seconds - h*3600)/60;
   s = (seconds - h*3600 - m*60);

   string text="  >>> "
               +StringFormat("%02d",h)+":"
               +StringFormat("%02d",m)+":"
               +StringFormat("%02d",s);

   if(LabelPosition==FOLLOW_PRICE)
   {
      if(ObjectFind(0,OBJ_NAME)!=0)
      {
         ObjectCreate(0,OBJ_NAME,OBJ_TEXT,0,time,close+_Point);
         ObjectSetString(0,OBJ_NAME,OBJPROP_TEXT,text);
         ObjectSetString(0,OBJ_NAME,OBJPROP_FONT,FONT_NAME);
         ObjectSetInteger(0,OBJ_NAME,OBJPROP_COLOR,LabelColor);
         ObjectSetInteger(0,OBJ_NAME,OBJPROP_SELECTABLE,false);
         ObjectSetInteger(0,OBJ_NAME,OBJPROP_FONTSIZE,12);

      }
      else
      {
         ObjectSetString(0,OBJ_NAME,OBJPROP_TEXT,text);
         ObjectMove(0,OBJ_NAME,0,time,close+_Point);
      }
   }
   else if(LabelPosition==FIXED_POSITION)
   {
      if(ObjectFind(0,OBJ_NAME)!=0)
      {
         ObjectCreate(0,OBJ_NAME,OBJ_LABEL,0,0,0);
         ObjectSetInteger(0,OBJ_NAME,OBJPROP_ANCHOR,ANCHOR_RIGHT_UPPER);
         ObjectSetInteger(0,OBJ_NAME,OBJPROP_CORNER,CORNER_RIGHT_UPPER);
         ObjectSetInteger(0,OBJ_NAME,OBJPROP_XDISTANCE,200);
         ObjectSetInteger(0,OBJ_NAME,OBJPROP_YDISTANCE,2);
         ObjectSetString(0,OBJ_NAME,OBJPROP_TEXT,text);
         ObjectSetString(0,OBJ_NAME,OBJPROP_FONT,FONT_NAME);
         ObjectSetInteger(0,OBJ_NAME,OBJPROP_COLOR,LabelColor);
         ObjectSetInteger(0,OBJ_NAME,OBJPROP_SELECTABLE,true);
         ObjectSetInteger(0,OBJ_NAME,OBJPROP_FONTSIZE,12);
      }
      else
         ObjectSetString(0,OBJ_NAME,OBJPROP_TEXT,text);
   }
}
////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//datetime iTime(string sym,ENUM_TIMEFRAMES tf,int index)
//  {
//   datetime t[1]={0};
//   if(CopyTime(sym,tf,index,1,t)!=1)
//      return(0);
//   return(t[0]);
//  }
////+------------------------------------------------------------------+
////|                                                                  |
////+------------------------------------------------------------------+
//double iClose(string sym,ENUM_TIMEFRAMES tf,int index)
//  {
//   double cls[1]={0.0};
//   if(CopyClose(sym,tf,index,1,cls)!=1)
//      return(0.0);
//   return(cls[0]);
//  }
////+------------------------------------------------------------------+
