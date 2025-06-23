//+------------------------------------------------------------------+
//|                                          ATR Value Indicator.mq5 |
//|                               Copyright 2018-2024, Hossein Nouri |
//|                           https://www.mql5.com/en/users/hsnnouri |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018-2024, Hossein Nouri"
#property description "Fully Coded By Hossein Nouri"
#property description "Email : hsn.nouri@gmail.com"
#property description "Skype : hsn.nouri"
#property description "Telegram : @hypernova1990"
#property description "Website : http://www.metatraderprogrammer.ir"
#property description "MQL5 Profile : https://www.mql5.com/en/users/hsnnouri"
#property description " "
#property description "Feel free to contact me for MQL4/MQL5 coding."
#property link      "https://www.mql5.com/en/users/hsnnouri"
#property version   "1.12"
#property indicator_chart_window
#property strict
//--- v1.10
// Added timeframe visulization for multi sample support
// Added custom timeframe for ATR
// Added movement capability by offset
// Code optimization
// Code optimization
//--- v1.11
// Position adjustment added
//--- v1.12
// Fixed overlapping and copying on loading from a template

//--- input parameters
enum ENUM_VALUE_TYPE
{
   Points=0,
   Pips=1,
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_CORNER
  {
   LEFT_UPPER,// Left Upper
   LEFT_LOWER,// Left Lower
   RIGHT_UPPER,// Right Upper
   RIGHT_LOWER,// Right Lower
  };
input ENUM_TIMEFRAMES   InpATRTimeframe         = PERIOD_CURRENT;                         // ATR Timeframe
input int               InpATRPeriod            = 14;                                     // ATR Period
input double            InpMultiplier           = 2.0;                                    // Multiplier
input string            DescStyle               = "======== Style ========";              // Description
input ENUM_CORNER       InpPosition             = RIGHT_UPPER;                            // Position
input int               InpOffsetX              = 0;                                      // Offset X
input int               InpOffsetY              = 30;                                     // Offset Y
input ENUM_VALUE_TYPE   InpDisplay              = 0;                                      // Display Mode
input color             InpLabelColor           = clrRed;                                 // Color
input int               InpFontSize             = 10;                                     // Font Size
input string            DescVisulizations       = "===== Visulizations =====";            // Description
input bool              InpTimeframeAll         = true;                                   // All Timeframes
input bool              InpTimeframeM1          = false;                                  // M1
input bool              InpTimeframeM2          = false;                                  // M2
input bool              InpTimeframeM3          = false;                                  // M3
input bool              InpTimeframeM4          = false;                                  // M4
input bool              InpTimeframeM5          = false;                                  // M5
input bool              InpTimeframeM6          = false;                                  // M6
input bool              InpTimeframeM10         = false;                                  // M10
input bool              InpTimeframeM12         = false;                                  // M12
input bool              InpTimeframeM15         = false;                                  // M15
input bool              InpTimeframeM20         = false;                                  // M20
input bool              InpTimeframeM30         = false;                                  // M30
input bool              InpTimeframeH1          = false;                                  // H1
input bool              InpTimeframeH2          = false;                                  // H2
input bool              InpTimeframeH3          = false;                                  // H3
input bool              InpTimeframeH4          = false;                                  // H4
input bool              InpTimeframeH6          = false;                                  // H6
input bool              InpTimeframeH8          = false;                                  // H8
input bool              InpTimeframeH12         = false;                                  // H12
input bool              InpTimeframeD1          = false;                                  // D1
input bool              InpTimeframeW1          = false;                                  // W1
input bool              InpTimeframeMN1         = false;                                  // MN1



//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
string               OBJ_NAME;
string               OBJ_PATTERN;
int                  Visibility;
int                  ATRHandle;
double               ATRBuffer[];
ENUM_BASE_CORNER     TextCorner;
ENUM_ANCHOR_POINT    TextAnchor;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void SetVisibility()
{
   Visibility=0;
   if(InpTimeframeAll)
   {
      Visibility+=OBJ_ALL_PERIODS;
      return;
   }
   if(InpTimeframeM1)         Visibility+=OBJ_PERIOD_M1;
   if(InpTimeframeM2)         Visibility+=OBJ_PERIOD_M2;
   if(InpTimeframeM3)         Visibility+=OBJ_PERIOD_M3;
   if(InpTimeframeM4)         Visibility+=OBJ_PERIOD_M4;
   if(InpTimeframeM5)         Visibility+=OBJ_PERIOD_M5;
   if(InpTimeframeM6)         Visibility+=OBJ_PERIOD_M6;
   if(InpTimeframeM10)        Visibility+=OBJ_PERIOD_M10;
   if(InpTimeframeM12)        Visibility+=OBJ_PERIOD_M12;
   if(InpTimeframeM15)        Visibility+=OBJ_PERIOD_M15;
   if(InpTimeframeM20)        Visibility+=OBJ_PERIOD_M20;
   if(InpTimeframeM30)        Visibility+=OBJ_PERIOD_M30;
   if(InpTimeframeH1)         Visibility+=OBJ_PERIOD_H1;
   if(InpTimeframeH2)         Visibility+=OBJ_PERIOD_H2;
   if(InpTimeframeH3)         Visibility+=OBJ_PERIOD_H3;
   if(InpTimeframeH4)         Visibility+=OBJ_PERIOD_H4;
   if(InpTimeframeH6)         Visibility+=OBJ_PERIOD_H6;
   if(InpTimeframeH8)         Visibility+=OBJ_PERIOD_H8;
   if(InpTimeframeH12)        Visibility+=OBJ_PERIOD_H12;
   if(InpTimeframeD1)         Visibility+=OBJ_PERIOD_D1;
   if(InpTimeframeW1)         Visibility+=OBJ_PERIOD_W1;
   if(InpTimeframeMN1)        Visibility+=OBJ_PERIOD_MN1;
   
   if(Visibility==0)          Visibility=OBJ_NO_PERIODS;
   
}
int OnInit()
  {
//--- indicator buffers mapping
   ATRHandle=iATR(_Symbol,InpATRTimeframe,InpATRPeriod);
   ArraySetAsSeries(ATRBuffer,true);
   SetVisibility();
   SetTextPosition();
   OBJ_PATTERN = "ATRInd_"+(string) ChartID();
   CleanUpChart();
   OBJ_NAME=OBJ_PATTERN+"_"+GetTFName()+"_"+IntegerToString(InpATRPeriod)+"_"+GetTFName(InpATRTimeframe)+"_"+DoubleToString(InpMultiplier,2)+"_";
   ShowATR();
//---
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
  {
   ObjectDelete(0,OBJ_NAME);
   ChartRedraw();
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
   ShowATR();
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
void ShowATR()
{
   if(CopyBuffer(ATRHandle,0,0,2,ATRBuffer)<=0)
     {
      Print("Getting ATR failed! Error",GetLastError());
      return;
     }
   static double ATR;
   ATR = ATRBuffer[0];
   ATR = (ATR * InpMultiplier) * MathPow(10,_Digits - InpDisplay);
   DrawATROnChart(ATR);
}
void DrawATROnChart(double ATR)
{
   string Dis;
   if(InpDisplay==0) Dis=" Points";
   if(InpDisplay==1) Dis=" Pips";
   
   string Output = StringFormat("%s%s of ATR(%s,%s): %s %s  ",DoubleToString(InpMultiplier * 100,0),"%",IntegerToString(InpATRPeriod),GetTFName(InpATRTimeframe),DoubleToString(ATR,0),Dis);
   if(ObjectFind(0,OBJ_NAME) < 0)
   {
      ObjectCreate(0,OBJ_NAME, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0,OBJ_NAME, OBJPROP_YDISTANCE, InpOffsetY);
      ObjectSetInteger(0,OBJ_NAME, OBJPROP_XDISTANCE, InpOffsetX);
      ObjectSetInteger(0,OBJ_NAME, OBJPROP_CORNER, TextCorner);
      ObjectSetString(0,OBJ_NAME,OBJPROP_TEXT, Output);
      ObjectSetString(0,OBJ_NAME,OBJPROP_FONT, "Arial");
      ObjectSetInteger(0,OBJ_NAME, OBJPROP_FONTSIZE, InpFontSize);
      ObjectSetDouble(0,OBJ_NAME,OBJPROP_ANGLE,0); 
      ObjectSetInteger(0,OBJ_NAME,OBJPROP_ANCHOR,TextAnchor);
      ObjectSetInteger(0,OBJ_NAME, OBJPROP_COLOR, InpLabelColor);
      ObjectSetInteger(0,OBJ_NAME,OBJPROP_BACK,false); 
      
      ObjectSetInteger(0,OBJ_NAME,OBJPROP_SELECTABLE,false);
      ObjectSetInteger(0,OBJ_NAME,OBJPROP_SELECTED,false); 
      ObjectSetInteger(0,OBJ_NAME,OBJPROP_HIDDEN,true); 
      ObjectSetInteger(0,OBJ_NAME,OBJPROP_ZORDER,0); 
      
      ObjectSetInteger(0,OBJ_NAME,OBJPROP_TIMEFRAMES,Visibility);
   }
   
   ObjectSetString(0,OBJ_NAME,OBJPROP_TEXT, Output);
   
   ChartRedraw();
}
string GetTFName(ENUM_TIMEFRAMES _TF=-1)
{
   if(_TF==PERIOD_CURRENT)       _TF=_Period;
   if(_TF==1)  return "M1";
   if(_TF==2)  return "M2";
   if(_TF==3)  return "M3";
   if(_TF==4)  return "M4";
   if(_TF==5)  return "M5";
   if(_TF==6)  return "M6";
   if(_TF==10)  return "M10";
   if(_TF==12)  return "M12";
   if(_TF==15)  return "M15";
   if(_TF==20)  return "M20";
   if(_TF==30)  return "M30";
   if(_TF==16385)  return "H1";
   if(_TF==16386)  return "H2";
   if(_TF==16387)  return "H3";
   if(_TF==16388)  return "H4";
   if(_TF==16390)  return "H6";
   if(_TF==16392)  return "H8";
   if(_TF==16396)  return "H12";
   if(_TF==16408)  return "D1";
   if(_TF==32769)  return "W1";
   if(_TF==49153)  return "MN1";
return _TF;
}
void SetTextPosition()
  {
   if(InpPosition==LEFT_UPPER)
     {
      TextCorner=CORNER_LEFT_UPPER;
      TextAnchor=ANCHOR_LEFT_UPPER;
     }
   else if(InpPosition==LEFT_LOWER)
     {
      TextCorner=CORNER_LEFT_LOWER;
      TextAnchor=ANCHOR_LEFT_LOWER;
     }
   else if(InpPosition==RIGHT_UPPER)
     {
      TextCorner=CORNER_RIGHT_UPPER;
      TextAnchor=ANCHOR_RIGHT_UPPER;
     }
   else if(InpPosition==RIGHT_LOWER)
     {
      TextCorner=CORNER_RIGHT_LOWER;
      TextAnchor=ANCHOR_RIGHT_LOWER;
     }
  }
//+------------------------------------------------------------------+
void CleanUpChart()
{
   int TotalObjects = ObjectsTotal(0,0,OBJ_LABEL);
   string ObjName="";
   for(int i=TotalObjects-1; i>=0; i--)
   {
      ObjName = ObjectName(0,i,0,OBJ_LABEL);
      if(StringFind(ObjName,"ATRInd_")!=-1)
      {
         if(StringFind(ObjName,OBJ_PATTERN)==-1)
         {
            ObjectDelete(0,ObjName);
         }
      }
   }
}