//+------------------------------------------------------------------+
//|                                            AverageRange_v1.6.mq4 |
//|                                         Copyright 2020, NickBixy |
//|             https://www.forexfactory.com/showthread.php?t=904734 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, NickBixy"
#property link      "https://www.forexfactory.com/showthread.php?t=904734"
//#property version   "1.6"
#property strict
#property indicator_chart_window

//--- Declaration of constants
#define OP_BUY 0           //Buy 
#define OP_SELL 1          //Sell 
#define OP_BUYLIMIT 2      //Pending order of BUY LIMIT type 
#define OP_SELLLIMIT 3     //Pending order of SELL LIMIT type 
#define OP_BUYSTOP 4       //Pending order of BUY STOP type 
#define OP_SELLSTOP 5      //Pending order of SELL STOP type 
//---
#define MODE_OPEN 0
#define MODE_CLOSE 3
#define MODE_VOLUME 4
#define MODE_REAL_VOLUME 5
#define MODE_TRADES 0
#define MODE_HISTORY 1
#define SELECT_BY_POS 0
#define SELECT_BY_TICKET 1
//---
#define DOUBLE_VALUE 0
#define FLOAT_VALUE 1
#define LONG_VALUE INT_VALUE
//---
#define CHART_BAR 0
#define CHART_CANDLE 1
//---
#define MODE_ASCEND 0
#define MODE_DESCEND 1
//---
#define MODE_LOW 1
#define MODE_HIGH 2
#define MODE_TIME 5
#define MODE_BID 9
#define MODE_ASK 10
#define MODE_POINT 11
#define MODE_DIGITS 12
#define MODE_SPREAD 13
#define MODE_STOPLEVEL 14
#define MODE_LOTSIZE 15
#define MODE_TICKVALUE 16
#define MODE_TICKSIZE 17
#define MODE_SWAPLONG 18
#define MODE_SWAPSHORT 19
#define MODE_STARTING 20
#define MODE_EXPIRATION 21
#define MODE_TRADEALLOWED 22
#define MODE_MINLOT 23
#define MODE_LOTSTEP 24
#define MODE_MAXLOT 25
#define MODE_SWAPTYPE 26
#define MODE_PROFITCALCMODE 27
#define MODE_MARGINCALCMODE 28
#define MODE_MARGININIT 29
#define MODE_MARGINMAINTENANCE 30
#define MODE_MARGINHEDGED 31
#define MODE_MARGINREQUIRED 32
#define MODE_FREEZELEVEL 33
//---
#define EMPTY -1

#define OBJPROP_TIME1 300

#define OBJPROP_PRICE1 301

#define OBJPROP_TIME2 302

#define OBJPROP_PRICE2 303

#define OBJPROP_TIME3 304

#define OBJPROP_PRICE3 305

#define OBJPROP_FIBOLEVELS 200

enum pipPointChoice
  {
   Pips,//Pips
   Points,//Points
  };

enum yesnoChoiceToggle
  {
   No,
   Yes
  };

input string adrHeader="-----------------Average Range Settings------------------------------------------";//----- Average Range Settings
input ENUM_TIMEFRAMES timeFrame=PERIOD_D1;//TimeFrame
input yesnoChoiceToggle useShortLines=Yes;//Draw Short Lines
input int Line_Length=15;//Length of Short Line

input int period=14;//Period
input string lineLabelHeader="-----------------Line/Label Customize  Settings------------------------------------------";//----- Line/Label Customize  Settings
input string Font="Arial";//Font
input int labelFontSize=8;//Font Size
input int ShiftLabel=10;//Label Shift +move right -move left
input string highHeader="High Line/Label Customize--------------------------------------------";//----- High Line/Label Customize
input string customHighMSG="ADR High";//High Label custom MSG
input ENUM_LINE_STYLE highLineStyle=STYLE_DOT;//High Line Style
input int highLineWidth=1;//High Line Width
input color highLineClr=clrOrange;//High Line Color
input color highLabelClr=clrOrange;//High Label Color
input string lowHeader="Low Line/Label Customize--------------------------------------------";//----- Low Line/Label Customize
input string customLowMSG="ADR Low";//Low Label custom MSG
input ENUM_LINE_STYLE lowLineStyle=STYLE_DOT;//Low Line Style
input int lowLineWidth=1;//Low Line Width
input color lowLineClr=clrOrange;//Low Line Color
input color lowLabelClr=clrOrange;//Low Label Color
string indiName="ARL"+" "+EnumToString(timeFrame)+" "+(string)period;

//+------------------------------------------------------------------+
int OnInit()
  {
   if(period<1)
     {
      Alert("Period can't be less than 1");
     }
   ObjectsDeleteAll(0,indiName,0,OBJ_TREND) ;
   ObjectsDeleteAll(0,indiName,0,OBJ_TEXT) ;
   indiName="ARL"+" "+EnumToString(timeFrame)+" "+(string)period;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
void deinit()
  {
   ObjectsDeleteAll(0,indiName,0,OBJ_TREND) ;
   ObjectsDeleteAll(0,indiName,0,OBJ_TEXT) ;
  }
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
   DrawRangeLines();
   return 0;
  }
//+------------------------------------------------------------------+
void DrawRangeLines()
  {
   int timeframeValue=0;
   switch(Period())                                  // Header of the 'switch'
     {
      // Start of the 'switch' body
      case PERIOD_M1 :
         timeframeValue=1;
         break;// Variations..
      case PERIOD_M2 :
         timeframeValue=2;
         break;// Variations..
      case PERIOD_M3 :
         timeframeValue=3;
         break;// Variations..
      case PERIOD_M4 :
         timeframeValue=4;
         break;// Variations..
      case PERIOD_M5 :
         timeframeValue=5;
         break;// Variations..
      case PERIOD_M6 :
         timeframeValue=6;
         break;// Variations..
      case PERIOD_M10 :
         timeframeValue=10;
         break;// Variations..
      case PERIOD_M12 :
         timeframeValue=12;
         break;// Variations..
      case PERIOD_M15 :
         timeframeValue=15;
         break;// Variations..
      case PERIOD_M20 :
         timeframeValue=20;
         break;// Variations..
      case PERIOD_M30 :
         timeframeValue=30;
         break;// Variations..
      case PERIOD_H1 :
         timeframeValue=60;
         break;// Variations..
      case PERIOD_H2 :
         timeframeValue=240;
         break;// Variations..
      case PERIOD_H3 :
         timeframeValue=180;
         break;// Variations..
      case PERIOD_H4 :
         timeframeValue=240;
         break;// Variations..
      case PERIOD_H6 :
         timeframeValue=360;
         break;// Variations..
      case PERIOD_H8 :
         timeframeValue=480;
         break;// Variations..
      case PERIOD_H12 :
         timeframeValue=720;
         break;// Variations..
      case PERIOD_D1 :
         timeframeValue=1440;
         break;// Variations..
      case PERIOD_W1 :
         timeframeValue=10080;
         break;// Variations..
      case PERIOD_MN1 :
         timeframeValue=43200;
         break;// Variations..
     }


   string highMSG="";
   string lowMSG="";

   highMSG=customHighMSG;
   lowMSG=customLowMSG;

   datetime Time[];
   int count=2;   // number of elements to copy
   ArraySetAsSeries(Time,true);
   CopyTime(_Symbol,_Period,0,count,Time);

//HIGH Range Line
   string highLine=indiName+" High";
   if(ObjectFindMQL4(highLine) != 0)
     {
      if(useShortLines==Yes)
        {
         ObjectCreateMQL4(highLine, OBJ_TREND, 0, Time[1]+timeframeValue*60, GetAverageRangeHigh(), Time[0]+timeframeValue*60*Line_Length, GetAverageRangeHigh());
         ObjectSetMQL4(highLine,OBJPROP_RAY,false);
        }
      else
        {
         ObjectCreateMQL4(highLine,OBJ_TREND,0,iTime(NULL,timeFrame,0),GetAverageRangeHigh(),Time[0]+timeframeValue*60,GetAverageRangeHigh());
         ObjectSetMQL4(highLine,OBJPROP_RAY,true);
        }

      ObjectSetMQL4(highLine,OBJPROP_COLOR,highLineClr);
      ObjectSetMQL4(highLine,OBJPROP_STYLE,highLineStyle);
      ObjectSetMQL4(highLine,OBJPROP_WIDTH,highLineWidth);
      ObjectSetMQL4(highLine,OBJPROP_BACK,true);
      ObjectSetMQL4(highLine,OBJPROP_SELECTED,false);
      ObjectSetMQL4(highLine,OBJPROP_SELECTABLE,false);

     }
   else
     {
      if(useShortLines==Yes)
        {
         ObjectSetMQL4(highLine,OBJPROP_RAY,false);
         ObjectMoveMQL4(highLine, 0, Time[1]+timeframeValue*60, GetAverageRangeHigh());
         ObjectMoveMQL4(highLine, 1, Time[0]+timeframeValue*60*Line_Length, GetAverageRangeHigh());
        }
      else
        {
         ObjectSetMQL4(highLine,OBJPROP_RAY,true);
         ObjectMoveMQL4(highLine,0,iTime(NULL,timeFrame,0),GetAverageRangeHigh());
         ObjectMoveMQL4(highLine,1,Time[0]+timeframeValue*60,GetAverageRangeHigh());
        }

     }

//LOW Range Line
   string lowLine=indiName+" LOW";

   if(ObjectFindMQL4(lowLine) != 0)
     {
      if(useShortLines==Yes)
        {
         ObjectCreateMQL4(lowLine, OBJ_TREND, 0, Time[1]+timeframeValue*60, GetAverageRangeLow(), Time[0]+timeframeValue*60*Line_Length, GetAverageRangeLow());
         ObjectSetMQL4(lowLine,OBJPROP_RAY,false);
        }
      else
        {
         ObjectCreateMQL4(lowLine,OBJ_TREND,0,iTime(NULL,timeFrame,0),GetAverageRangeLow(),Time[0]+timeframeValue*60,GetAverageRangeLow());
         ObjectSetMQL4(lowLine,OBJPROP_RAY,true);
        }
      ObjectSetMQL4(lowLine,OBJPROP_COLOR,lowLineClr);
      ObjectSetMQL4(lowLine,OBJPROP_STYLE,lowLineStyle);
      ObjectSetMQL4(lowLine,OBJPROP_WIDTH,lowLineWidth);
      ObjectSetMQL4(lowLine,OBJPROP_BACK,true);
      ObjectSetMQL4(lowLine,OBJPROP_SELECTED,false);
      ObjectSetMQL4(lowLine,OBJPROP_SELECTABLE,false);


     }
   else
     {
      if(useShortLines==Yes)
        {
         ObjectSetMQL4(lowLine,OBJPROP_RAY,false);
         ObjectMoveMQL4(lowLine, 0, Time[1]+timeframeValue*60, GetAverageRangeLow());
         ObjectMoveMQL4(lowLine, 1, Time[0]+timeframeValue*60*Line_Length, GetAverageRangeLow());
        }
      else
        {
         ObjectSetMQL4(lowLine,OBJPROP_RAY,true);
         ObjectMoveMQL4(lowLine,0,iTime(NULL,timeFrame,0),GetAverageRangeLow());
         ObjectMoveMQL4(lowLine,1,Time[0]+timeframeValue*60,GetAverageRangeLow());
        }

     }
///////////////////////////////////////////////////////////
//HIGH Range LABEL
   string highLabel=indiName+" HighLabel";

   if(ObjectFindMQL4(highLabel) != 0)
     {
      ObjectCreateMQL4(highLabel,OBJ_TEXT,0,Time[0]+timeframeValue*60*ShiftLabel,GetAverageRangeHigh());
      ObjectSetTextMQL4(highLabel,highMSG,labelFontSize,Font,highLabelClr);
      ObjectSetMQL4(highLabel,OBJPROP_BACK,true);
      ObjectSetMQL4(highLabel,OBJPROP_SELECTED,false);
      ObjectSetMQL4(highLabel,OBJPROP_SELECTABLE,false);
     }
   else
     {
      ObjectMoveMQL4(highLabel, 0,Time[0]+timeframeValue*60*ShiftLabel,GetAverageRangeHigh());
      ObjectSetTextMQL4(highLabel,highMSG,labelFontSize,Font,highLabelClr);
     }

//LOW Range LABEL
   string lowLabel=indiName+" LowLabel";

   if(ObjectFindMQL4(lowLabel) != 0)
     {
      ObjectCreateMQL4(lowLabel,OBJ_TEXT,0,Time[0]+timeframeValue*60*ShiftLabel,GetAverageRangeLow());
      ObjectSetTextMQL4(lowLabel,lowMSG,labelFontSize,Font,lowLabelClr);
      ObjectSetMQL4(lowLabel,OBJPROP_BACK,true);
      ObjectSetMQL4(lowLabel,OBJPROP_SELECTED,false);
      ObjectSetMQL4(lowLabel,OBJPROP_SELECTABLE,false);
     }
   else
     {
      ObjectMoveMQL4(lowLabel, 0,Time[0]+timeframeValue*60*ShiftLabel,GetAverageRangeLow());
      ObjectSetTextMQL4(lowLabel,lowMSG,labelFontSize,Font,lowLabelClr);
     }
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
double GetBidAverageRangeDistancePipsPoints(double rangeValue)
  {
   double value=0;
   double bid=MarketInfoMQL4(NULL,MODE_BID);
   double points=MarketInfoMQL4(NULL,MODE_POINT);

   if(rangeValue!=0 && rangeValue!=NULL && bid!=0 && bid!=NULL)
     {
      value=(rangeValue-bid)/points;
     }





   return value;
  }
//+------------------------------------------------------------------+
double GetAverageRangeRatioPipsPoints()
  {
   double value=0;

   double todayRange=GetTodayRangePipsPoints();
   double averageRangeNumPeriods=GetAverageRangeNumPeriodsPipsPoints();

   if((todayRange!=0 && todayRange!=NULL) && (averageRangeNumPeriods!=0 && averageRangeNumPeriods!=NULL))
     {
      value=(todayRange/averageRangeNumPeriods)*100;
     }



   return value;
  }
//+------------------------------------------------------------------+
int PipsToPointFactor()
  {
   int point=1;

   if(Digits()==5 || Digits()==3)
     {
      point=10; //1 pip to 10 point if 5 digit
     } //Check whether it's a 5 digit broker (3 digits for Yen)
   else
      if(Digits()==4 || Digits()==2)
        {
         point=1; //1 pip to 1 point if 4 digit
        }
      else
         if(Digits()==1)
           {
            point=1;
           }

   return(point);
  }
//+------------------------------------------------------------------+
double GetAverageRangeNumPeriodsPipsPoints()
  {
   double value=GetAverageRangeNumPeriods();
   double points=MarketInfoMQL4(NULL,MODE_POINT);

   if(value!=0 && value!=NULL && points!=0 && points!=NULL)
     {
      value=value/points;
     }





   return value;
  }
//+------------------------------------------------------------------+
double GetTodayRangePipsPoints()
  {
   double value=0;
   double points=MarketInfoMQL4(NULL,MODE_POINT);
   double high=iHigh(NULL,timeFrame,0);
   double low=iLow(NULL,timeFrame,0);
   value=MathAbs(high-low);

   if(value!=0 && value!=NULL && points!=0 && points!=NULL)
     {
      value=value/points;
     }






   return value;
  }
//+------------------------------------------------------------------+
double GetAverageRangeNumPeriods()
  {
   double result=0;
   double averageRange=0;
   for(int i=1; i<=period; i++)
     {

      if(timeFrame==PERIOD_D1)
        {
         datetime dayCheck1=iTime(NULL,PERIOD_D1,i);
         if(TimeDayOfWeekMQL4(dayCheck1) == 0)//found sunday
           {
            continue;
           }

         datetime dayCheck2=iTime(NULL,PERIOD_D1,i);
         if(TimeDayOfWeekMQL4(dayCheck2) == 6)//found saturday
           {
            continue;
           }
        }

      double high=iHigh(NULL,timeFrame,i);
      double low=iLow(NULL,timeFrame,i);
      averageRange+=high-low;
     }
   return result=averageRange/period;
  }
//+------------------------------------------------------------------+
double GetTimeFrameHighestHigh()
  {
   return iHigh(NULL,timeFrame,0);
  }
//+------------------------------------------------------------------+
double GetTimeFrameLowestLow()
  {
   return iLow(NULL,timeFrame,0);
  }
//+------------------------------------------------------------------+
double GetAverageRangeHigh()
  {
   double todayHigh=iHigh(NULL,timeFrame,0);
   double todayLow=iLow(NULL,timeFrame,0);

   double rangeHigh=GetTimeFrameLowestLow()+GetAverageRangeNumPeriods();;

   double averageRange=GetAverageRangeNumPeriods();

   if(todayHigh - todayLow > averageRange)
     {
      if(MarketInfoMQL4(NULL,MODE_BID) >= todayHigh- (todayHigh-todayLow)/2)
        {
         rangeHigh = todayLow + averageRange;

        }
      else
        {
         rangeHigh  = todayHigh;
        }
     }

   return rangeHigh;
  }
//+------------------------------------------------------------------+
double GetAverageRangeLow()
  {
   double todayHigh=iHigh(NULL,timeFrame,0);
   double todayLow=iLow(NULL,timeFrame,0);

   double rangeLow=GetTimeFrameHighestHigh()-GetAverageRangeNumPeriods();

   double averageRange=GetAverageRangeNumPeriods();

   if(todayHigh - todayLow > averageRange)
     {
      if(MarketInfoMQL4(NULL,MODE_BID) >= todayHigh- (todayHigh-todayLow)/2)
        {
         rangeLow  = todayLow;
        }
      else
        {
         rangeLow = todayHigh - averageRange;
        }
     }

   return rangeLow;
  }
//+------------------------------------------------------------------+
int ObjectFindMQL4(string name)
  {
   return(ObjectFind(0,name));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ObjectSetMQL4(string name,
                   int index,
                   double value)
  {
   switch(index)
     {
      case OBJPROP_TIME1:
         ObjectSetInteger(0,name,OBJPROP_TIME,(int)value);
         return(true);
      case OBJPROP_PRICE1:
         ObjectSetDouble(0,name,OBJPROP_PRICE,value);
         return(true);
      case OBJPROP_TIME2:
         ObjectSetInteger(0,name,OBJPROP_TIME,1,(int)value);
         return(true);
      case OBJPROP_PRICE2:
         ObjectSetDouble(0,name,OBJPROP_PRICE,1,value);
         return(true);
      case OBJPROP_TIME3:
         ObjectSetInteger(0,name,OBJPROP_TIME,2,(int)value);
         return(true);
      case OBJPROP_PRICE3:
         ObjectSetDouble(0,name,OBJPROP_PRICE,2,value);
         return(true);
      case OBJPROP_COLOR:
         ObjectSetInteger(0,name,OBJPROP_COLOR,(int)value);
         return(true);
      case OBJPROP_STYLE:
         ObjectSetInteger(0,name,OBJPROP_STYLE,(int)value);
         return(true);
      case OBJPROP_WIDTH:
         ObjectSetInteger(0,name,OBJPROP_WIDTH,(int)value);
         return(true);
      case OBJPROP_BACK:
         ObjectSetInteger(0,name,OBJPROP_BACK,(int)value);
         return(true);
      case OBJPROP_RAY:
         ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,(int)value);
         return(true);
      case OBJPROP_ELLIPSE:
         ObjectSetInteger(0,name,OBJPROP_ELLIPSE,(int)value);
         return(true);
      case OBJPROP_SCALE:
         ObjectSetDouble(0,name,OBJPROP_SCALE,value);
         return(true);
      case OBJPROP_ANGLE:
         ObjectSetDouble(0,name,OBJPROP_ANGLE,value);
         return(true);
      case OBJPROP_ARROWCODE:
         ObjectSetInteger(0,name,OBJPROP_ARROWCODE,(int)value);
         return(true);
      case OBJPROP_TIMEFRAMES:
         ObjectSetInteger(0,name,OBJPROP_TIMEFRAMES,(int)value);
         return(true);
      case OBJPROP_DEVIATION:
         ObjectSetDouble(0,name,OBJPROP_DEVIATION,value);
         return(true);
      case OBJPROP_FONTSIZE:
         ObjectSetInteger(0,name,OBJPROP_FONTSIZE,(int)value);
         return(true);
      case OBJPROP_CORNER:
         ObjectSetInteger(0,name,OBJPROP_CORNER,(int)value);
         return(true);
      case OBJPROP_XDISTANCE:
         ObjectSetInteger(0,name,OBJPROP_XDISTANCE,(int)value);
         return(true);
      case OBJPROP_YDISTANCE:
         ObjectSetInteger(0,name,OBJPROP_YDISTANCE,(int)value);
         return(true);
      case OBJPROP_FIBOLEVELS:
         ObjectSetInteger(0,name,OBJPROP_LEVELS,(int)value);
         return(true);
      case OBJPROP_LEVELCOLOR:
         ObjectSetInteger(0,name,OBJPROP_LEVELCOLOR,(int)value);
         return(true);
      case OBJPROP_LEVELSTYLE:
         ObjectSetInteger(0,name,OBJPROP_LEVELSTYLE,(int)value);
         return(true);
      case OBJPROP_LEVELWIDTH:
         ObjectSetInteger(0,name,OBJPROP_LEVELWIDTH,(int)value);
         return(true);

      default:
         return(false);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ObjectMoveMQL4(string name,
                    int point,
                    datetime time1,
                    double price1)
  {
   return(ObjectMove(0,name,point,time1,price1));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ObjectCreateMQL4(string name,
                      ENUM_OBJECT type,
                      int window,
                      datetime time1,
                      double price1,
                      datetime time2=0,
                      double price2=0,
                      datetime time3=0,
                      double price3=0)
  {
   return(ObjectCreate(0,name,type,window,
                       time1,price1,time2,price2,time3,price3));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ObjectSetTextMQL4(string name,
                       string text,
                       int font_size,
                       string font="",
                       color text_color=CLR_NONE)
  {
   int tmpObjType=(int)ObjectGetInteger(0,name,OBJPROP_TYPE);
   if(tmpObjType!=OBJ_LABEL && tmpObjType!=OBJ_TEXT)
      return(false);
   if(StringLen(text)>0 && font_size>0)
     {
      if(ObjectSetString(0,name,OBJPROP_TEXT,text)==true
         && ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size)==true)
        {
         if((StringLen(font)>0)
            && ObjectSetString(0,name,OBJPROP_FONT,font)==false)
            return(false);
         if(text_color>-1
            && ObjectSetInteger(0,name,OBJPROP_COLOR,text_color)==false)
            return(false);
         return(true);
        }
      return(false);
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MarketInfoMQL4(string symbol,
                      int type)
  {
   switch(type)
     {
      case MODE_LOW:
         return(SymbolInfoDouble(symbol,SYMBOL_LASTLOW));
      case MODE_HIGH:
         return(SymbolInfoDouble(symbol,SYMBOL_LASTHIGH));
      case MODE_TIME:
         return(SymbolInfoInteger(symbol,SYMBOL_TIME));

      case MODE_POINT:
         return(SymbolInfoDouble(symbol,SYMBOL_POINT));
      case MODE_DIGITS:
         return(SymbolInfoInteger(symbol,SYMBOL_DIGITS));
      case MODE_SPREAD:
         return(SymbolInfoInteger(symbol,SYMBOL_SPREAD));
      case MODE_STOPLEVEL:
         return(SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL));
      case MODE_LOTSIZE:
         return(SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE));
      case MODE_TICKVALUE:
         return(SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE));
      case MODE_TICKSIZE:
         return(SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE));
      case MODE_SWAPLONG:
         return(SymbolInfoDouble(symbol,SYMBOL_SWAP_LONG));
      case MODE_SWAPSHORT:
         return(SymbolInfoDouble(symbol,SYMBOL_SWAP_SHORT));
      case MODE_STARTING:
         return(0);
      case MODE_EXPIRATION:
         return(0);
      case MODE_TRADEALLOWED:
         return(0);
      case MODE_MINLOT:
         return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN));
      case MODE_LOTSTEP:
         return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP));
      case MODE_MAXLOT:
         return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX));
      case MODE_SWAPTYPE:
         return(SymbolInfoInteger(symbol,SYMBOL_SWAP_MODE));
      case MODE_PROFITCALCMODE:
         return(SymbolInfoInteger(symbol,SYMBOL_TRADE_CALC_MODE));
      case MODE_MARGINCALCMODE:
         return(0);
      case MODE_MARGININIT:
         return(0);
      case MODE_MARGINMAINTENANCE:
         return(0);
      case MODE_MARGINHEDGED:
         return(0);
      case MODE_MARGINREQUIRED:
         return(0);
      case MODE_FREEZELEVEL:
         return(SymbolInfoInteger(symbol,SYMBOL_TRADE_FREEZE_LEVEL));

      default:
         return(0);
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeDayOfWeekMQL4(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day_of_week);
  }
//+------------------------------------------------------------------+
