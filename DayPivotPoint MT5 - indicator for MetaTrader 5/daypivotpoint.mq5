//+------------------------------------------------------------------+
//|                                                DayPivotPoint.mq5 |
//|                           Copyright 2020, Roberto Jacobs (3rjfx) |
//|                              https://www.mql5.com/en/users/3rjfx |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Roberto Jacobs (3rjfx) ~ By 3rjfx ~ Created: 2020/10/11"
#property link      "https://www.mql5.com/en/users/3rjfx"
#property strict
#property version     "1.00"
#property description "version: 1.0 ~ Last update: 2020/10/11 @ 01:35 AM WIT (Western Indonesian Time)"
#property description "Indicator DayPivotPoint System with Signal and Alert for MetaTrader 5"
#property description "with options to display signal on the chart."
#property description "This Indicator can use only on TF_M1 to H4, and will visually appealing"
#property description "only on TF-M5 to TF-H1. Recommendation for Day Trading use on TF-M15."
//--
/* Last update: 2023/06/20 */
//--
#property indicator_chart_window
#property indicator_plots  0
//--
enum YN
 {
   No,  // No
   Yes  // Yes
 };
//--
enum fonts
  {
    Arial_Black,    // Arial Black
    Bodoni_MT_Black // Bodoni MT Black
  };
//---
//--
input YN                     alerts = Yes;           // Display Alerts / Messages (Yes) or (No)
input YN                 EmailAlert = No;            // Email Alert (Yes) or (No)
input YN                 sendnotify = No;            // Send Notification (Yes) or (No)
input YN                displayinfo = Yes;           // Display Trade Info
input color               textcolor = clrSnow;       // Text Color
input fonts             Fonts_Model = Arial_Black;   // Choose Fonts Model
input color              WindColors = clrRed;        // Colors for Wingdings
input color              PvtLColors = clrGold;       // Colors for Pivot Lines
input ENUM_LINE_STYLE  PvtLineStyle = STYLE_SOLID;   // Pivot Line style
input int              PvtLineWidth = 1;             // Pivot Line width
//---
//--
int arrpvt=20;
int font_siz_=7;
color wind_color;
string font_ohlc;
//--
double Pvt,
      PvtO,
      PvtL,
      PvtH,
      PvtO1,
      PvtL1,
      PvtH1,
      PvtC1;
//--
double pivot[20];
string label[]={"S7","S6","S5","S4","S3","S2","SS1","S1","P20","P40","P60","P80","R1","SR1","R2","R3","R4","R5","R6","R7"};
             //  0    1    2    3    4     5    6     7     8     9    10    11   12    13   14   15   16   17   18   19
//--
ENUM_TIMEFRAMES
    prsi=PERIOD_M15,
    prdp=PERIOD_D1;
//--
long chart_Id;
datetime TIME[];   
datetime thistm,
         prvtmp,
         prvtmo;
int cur,prv,
    imnn,imnp,
    cmnt,pmnt,
    lpvt=77,
    limit;
int HandleEMA2;
double EMA2[];
string posisi,
       sigpos,
       iname,
       msgText;
string _model;
string frtext="PivotLine_";
bool drawpivot,
     drawpohl;
//--
//--- bars minimum for calculation
#define DATA_LIMIT  100
//---------//
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   chart_Id=ChartID();
//---
   //--
   font_ohlc=FontsModel(Fonts_Model);
   wind_color=WindColors;
//---
   //--
   iname="DayPivotPoint ("+TF2Str(Period())+")";
   IndicatorSetString(INDICATOR_SHORTNAME,iname+"_("+Symbol()+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   //--
   _model=FontsModel(Fonts_Model);
   drawpivot=false;
   drawpohl=false;
   prvtmp=iTime(Symbol(),0,1);
   prvtmo=iTime(Symbol(),0,1);
   //--
   HandleEMA2=iMA(Symbol(),0,2,0,MODE_EMA,PRICE_MEDIAN);
   if(HandleEMA2==INVALID_HANDLE)
     {
       printf("Error creating EMA2 indicator for ",Symbol());
       return(INIT_FAILED);
     }
//---
   return(INIT_SUCCEEDED);
  }
//---------//
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Comment("");
   if(HandleEMA2!=INVALID_HANDLE)
      IndicatorRelease(HandleEMA2);
   PrintFormat("%s: Deinitialization reason code=%d",__FUNCTION__,reason);
   Print(getUninitReasonText(reason));
   ObjectsDeleteAll(chart_Id,0,OBJ_TREND);
   ObjectsDeleteAll(chart_Id,0,OBJ_TEXT);
   //--
   return;
//---
  } //-end OnDeinit()
//---------//
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
//--- Set Last error value to Zero
   ResetLastError();
   //--
//--- check for rates total
   if(rates_total<DATA_LIMIT)
      return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0) limit++;
   if(limit>=DATA_LIMIT) limit=DATA_LIMIT;
   else limit=lpvt+2;
   ArrayResize(EMA2,2);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(TIME,true);
   ArraySetAsSeries(EMA2,true);
   //--
   thistm=time[0];
   imnn=Minutes();
   BarTimeInit(limit);
   //--
   if((!drawpivot)||(thistm!=prvtmp)) 
     DrawPivotPoint();
   if((!drawpohl)||(close[0]>PvtH||close[0]<PvtL)||(thistm!=prvtmo)) 
     DrawPOHL();
   //--
   if(imnn!=imnp) cur=SignalIndi();
   //--
   if(alerts==Yes||EmailAlert==Yes||sendnotify==Yes) Do_Alerts(cur);
   if(displayinfo==Yes) ChartComm();
   //--
   ChartRedraw(chart_Id);
   //--
//--- return value of prev_calculated for next call
   return(rates_total);
  } //- Done!
//---------//

bool DrawPivotPoint()
  {
//---
   //--
   int pb=1;
   datetime dtcb=iTime(Symbol(),prdp,0);
   pb=DayOfWeek(dtcb)==1 ? 2 : 1;
   //--
   PvtL1=iLow(Symbol(),prdp,pb);
   PvtH1=iHigh(Symbol(),prdp,pb);
   PvtC1=iClose(Symbol(),prdp,pb);
   PvtO1=iOpen(Symbol(),prdp,pb);
   //--
   Pvt=(PvtH1+PvtL1+PvtC1)/3;
   //-
   double sup1=((Pvt*2)-PvtH1);          // support_1
   double res1=((Pvt*2)-PvtL1);          // resistance_1
   double disr=res1-sup1;                // distance R1 - S1
   double disl=disr*0.20;                // distance line
   //--
   pivot[19]=(Pvt*6)+(PvtH1)-(PvtL1*6);  // resistance_7
   pivot[18]=(Pvt*5)+(PvtH1)-(PvtL1*5);  // resistance_6
   pivot[17]=(Pvt*4)+(PvtH1)-(PvtL1*4);  // resistance_5
   pivot[16]=(Pvt*3)+(PvtH1)-(PvtL1*3);  // resistance_4
   pivot[15]=(Pvt*2)+(PvtH1)-(PvtL1*2);  // resistance_3
   pivot[14]=(Pvt+PvtH1-PvtL1);          // resistance_2
   pivot[13]=res1+(disl*0.618);          // strong_resistance_1
   pivot[12]=res1;                       // resistance_1
   pivot[11]=(sup1+(disr*0.8));          // point_80
   pivot[10]=(sup1+(disr*0.6));          // point_60
   pivot[9] =(sup1+(disr*0.4));          // point_40
   pivot[8] =(sup1+(disr*0.2));          // point_20
   pivot[7] =sup1;                       // support_1
   pivot[6]=sup1-(disl*0.618);           // strong_suppot_1
   pivot[5]=(Pvt-PvtH1+PvtL1);           // support_2
   pivot[4]=(Pvt*2)-((PvtH1*2)-(PvtL1)); // support_3
   pivot[3]=(Pvt*3)-((PvtH1*3)-(PvtL1)); // support_4
   pivot[2]=(Pvt*4)-((PvtH1*4)-(PvtL1)); // support_5
   pivot[1]=(Pvt*5)-((PvtH1*5)-(PvtL1)); // support_6
   pivot[0]=(Pvt*6)-((PvtH1*6)-(PvtL1)); // support_7
   //--
   for(int x=0; x<arrpvt; x++)
     {
       CreateTrendLine(chart_Id,frtext+label[x],TIME[lpvt],pivot[x],TIME[0],pivot[x],PvtLineWidth,PvtLineStyle,PvtLColors,false,true);
       CreateText(chart_Id,frtext+"PDW"+string(x),TIME[0],pivot[x],CharToString(108),"Wingdings",font_siz_,wind_color,ANCHOR_LEFT);
       CreateText(chart_Id,frtext+"PPP"+string(x),TIME[0],pivot[x],"   "+label[x]+" - "+DoubleToString(pivot[x],_Digits),_model,font_siz_,textcolor,ANCHOR_LEFT); 
       prvtmp=thistm;
       drawpivot=true;
       DrawPOHL();
     }
   //--
   return(drawpivot);
//---
  } //-end DrawPivotPoint()   
//---------//

bool DrawPOHL(void)
  {
//--- 
   double POHL[4];
   string labelpric[]={"Pivot","Low","Open","High"};
   color clrPOHL[]={clrAqua,clrDeepPink,clrMediumOrchid,clrBlue};
   POHL[0]=Pvt;
   POHL[1]=iLow(Symbol(),prdp,0);
   POHL[2]=iOpen(Symbol(),prdp,0);
   POHL[3]=iHigh(Symbol(),prdp,0);
   PvtH=POHL[3];
   PvtL=POHL[1];
   //--
   for(int x=0; x<ArraySize(POHL); x++)
     {
       CreateTrendLine(chart_Id,frtext+labelpric[x],TIME[lpvt],POHL[x],TIME[0],POHL[x],PvtLineWidth,PvtLineStyle,clrPOHL[x],false,true);
       CreateText(chart_Id,frtext+"PWDOHLC"+string(x),TIME[0],POHL[x],CharToString(108),"Wingdings",font_siz_,wind_color,ANCHOR_LEFT);
       CreateText(chart_Id,frtext+"PPDOHLC"+string(x),TIME[0],POHL[x],"   "+labelpric[x]+" - "+DoubleToString(POHL[x],_Digits),
                  FontsModel(0),font_siz_,textcolor,ANCHOR_LEFT);
       prvtmo=thistm;            
       drawpohl=true;
     }
   //--
   return(drawpohl);
//---
  } //-end DrawPOHL()
//---------//

void BarTimeInit(int bars)
  {
//---
    ArrayResize(TIME,bars);
    //--
    for(int i=bars-1; i>=0; i--) 
      TIME[i]=iTime(Symbol(),0,i);
    //--
    return;
//---
  } //-end BarTimeInit()
//---------//

int SignalIndi()
  {
//---
   int res=0;
   //--
   double OPEN=iOpen(Symbol(),0,0);
   CopyBuffer(HandleEMA2,0,0,2,EMA2);
   if(OPEN<EMA2[0]) res=1;
   if(OPEN>EMA2[0]) res=-1;
   //--
   imnp=imnn;
   //--
   return(res);
//---
  } //-end SignalIndi()
//---------//

string FontsModel(int mode)
  { 
   string str_font;
   switch(mode) 
     { 
      case 0: str_font="Arial Black"; break;
      case 1: str_font="Bodoni MT Black"; break; 
     }
   //--
   return(str_font);
//----
  } //-end FontsModel()
//---------//

bool CreateTrendLine(long     chartid, 
                     string   line_name,
                     datetime line_time1,
                     double   line_price1,
                     datetime line_time2,
                     double   line_price2,
                     int      line_width,
                     int      line_style,
                     color    line_color,
                     bool     ray_right,
                     bool     line_hidden)
  {  
//---
   ObjectDelete(chartid,line_name);
   //--
   if(ObjectCreate(chartid,line_name,OBJ_TREND,0,line_time1,line_price1,line_time2,line_price2)) // create trend line
     {
       ObjectSetInteger(chartid,line_name,OBJPROP_WIDTH,line_width);
       ObjectSetInteger(chartid,line_name,OBJPROP_STYLE,line_style);
       ObjectSetInteger(chartid,line_name,OBJPROP_COLOR,line_color);
       ObjectSetInteger(chartid,line_name,OBJPROP_RAY_RIGHT,ray_right);
       ObjectSetInteger(chartid,line_name,OBJPROP_HIDDEN,line_hidden);
       ObjectSetInteger(chartid,line_name,OBJPROP_TIMEFRAMES,OBJ_PERIOD_M1|OBJ_PERIOD_M5|OBJ_PERIOD_M15|OBJ_PERIOD_M30|OBJ_PERIOD_H1|OBJ_PERIOD_H4); 
     } 
   else 
      {Print("Failed to create the object OBJ_TREND ",line_name,", Error code = ", GetLastError()); return(false);}
   //--
   return(true);
//---
  } //-end CreateTrendLine()   
//---------//

bool CreateText(long   chart_id, 
                string text_name,
                datetime txt_time,
                double   txt_price,
                string label_text,
                string font_model,
                int    font_size,
                color  text_color,
                int    anchor)
  { 
//--- 
   ObjectDelete(chart_id,text_name);
   //--
   if(ObjectCreate(chart_id,text_name,OBJ_TEXT,0,txt_time,txt_price))
     { 
       ObjectSetString(chart_id,text_name,OBJPROP_TEXT,label_text);
       ObjectSetString(chart_id,text_name,OBJPROP_FONT,font_model); 
       ObjectSetInteger(chart_id,text_name,OBJPROP_FONTSIZE,font_size);
       ObjectSetInteger(chart_id,text_name,OBJPROP_COLOR,text_color);
       ObjectSetInteger(chart_id,text_name,OBJPROP_ANCHOR,anchor);
       ObjectSetInteger(chart_id,text_name,OBJPROP_TIMEFRAMES,OBJ_PERIOD_M1|OBJ_PERIOD_M5|OBJ_PERIOD_M15|OBJ_PERIOD_M30|OBJ_PERIOD_H1|OBJ_PERIOD_H4); 
     } 
   else 
      {Print("Failed to create the object OBJ_TEXT ",text_name,", Error code = ", GetLastError()); return(false);}
   //--
   return(true);
//---
  } //-end CreateText()
//---------//

void Do_Alerts(int fcur)
  {
//---
    cmnt=Minutes();
    if(cmnt!=pmnt)
      {
        //--
        if(fcur==1)
          {
            msgText="The price will be rise";
            posisi="Bullish"; 
            sigpos="Open BUY Order!";
          }
        else
        if(fcur==-1)
          {
            msgText="The price will be down";
            posisi="Bearish"; 
            sigpos="Open SELL Order!";
          }
        else
          {
            msgText="Trend Not Found!";
            posisi="Not Found!"; 
            sigpos="Wait for Confirmation!";
          }
        //--
        if(fcur!=prv)
          {
            Print(iname,"--- "+Symbol()+" "+TF2Str(_Period)+": "+msgText+
                  "\n--- at: ",TimeToString(iTime(Symbol(),0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);
            //--
            if(alerts==Yes)
              Alert(iname,"--- "+Symbol()+" "+TF2Str(_Period)+": "+msgText+
                    "--- at: ",TimeToString(iTime(Symbol(),0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);
            //--
            if(EmailAlert==Yes) 
              SendMail(iname,"--- "+Symbol()+" "+TF2Str(_Period)+": "+msgText+
                               "\n--- at: "+TimeToString(iTime(Symbol(),0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);
            //--
            if(sendnotify==Yes) 
              SendNotification(iname+"--- "+Symbol()+" "+TF2Str(_Period)+": "+msgText+
                               "\n--- at: "+TimeToString(iTime(Symbol(),0,0),TIME_DATE|TIME_MINUTES)+" - "+sigpos);                
            //--
            prv=fcur;
          }
        //--
        pmnt=cmnt;
      }
    //--
    return;
    //--
//---
  } //-end Do_Alerts()
//---------//

string TF2Str(int period)
  {
//---
   switch(period)
     {
       //--
       case PERIOD_M1:  return("M1");
       case PERIOD_M5:  return("M5");
       case PERIOD_M15: return("M15");
       case PERIOD_M30: return("M30");
       case PERIOD_H1:  return("H1");
       case PERIOD_H4:  return("H4");
       case PERIOD_D1:  return("D1");
       case PERIOD_W1:  return("W1");
       case PERIOD_MN1: return("MN");
       //--
     }
   return(string(period));
//---
  } //-end TF2Str()  
//---------//

string AccountMode() // function: to known account trade mode
   {
//----
//--- Demo, Contest or Real account 
   ENUM_ACCOUNT_TRADE_MODE account_type=(ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);
 //---
   string trade_mode;
   //--
   switch(account_type) 
     { 
      case  ACCOUNT_TRADE_MODE_DEMO: 
         trade_mode="Demo"; 
         break; 
      case  ACCOUNT_TRADE_MODE_CONTEST: 
         trade_mode="Contest"; 
         break; 
      default: 
         trade_mode="Real"; 
         break; 
     }
   //--
   return(trade_mode);
//----
   } //-end AccountMode()
//---------//

void ChartComm() // function: write comments on the chart
  {
//----
   //--
   Comment("\n     :: Server Date Time : ",(string)Year(),".",(string)Month(),".",(string)Day(), "   ",TimeToString(TimeCurrent(),TIME_SECONDS), 
      "\n     ------------------------------------------------------------", 
      "\n      :: Broker             :  ",TerminalInfoString(TERMINAL_COMPANY), 
      "\n      :: Acc. Name       :  ",AccountInfoString(ACCOUNT_NAME),
      "\n      :: Acc, Number    :  ",(string)AccountInfoInteger(ACCOUNT_LOGIN),
      "\n      :: Acc,TradeMode :  ",AccountMode(),
      "\n      :: Acc. Leverage   :  1 : ",(string)AccountInfoInteger(ACCOUNT_LEVERAGE), 
      "\n      :: Acc. Balance     :  ",DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE),2),
      "\n      :: Acc. Equity       :  ",DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY),2), 
      "\n      --------------------------------------------",
      "\n      :: Indicator Name  :  ",iname,
      "\n      :: Currency Pair    :  ",Symbol(),
      "\n      :: Current Spread  :  ",IntegerToString(SymbolInfoInteger(Symbol(),SYMBOL_SPREAD),0),
      "\n      :: Indicator Signal :  ",posisi,
      "\n      :: Suggested        :  ",sigpos);
   //---
   ChartRedraw();
   return;
//----
  } //-end ChartComm()  
//---------//

int Year(void)
  {
//---
    return(MqlReturnDateTime(TimeCurrent(),TimeReturn(year)));
//---
  } //-end Year()
//---------//

int Month(void)
  {
//---
    return(MqlReturnDateTime(TimeCurrent(),TimeReturn(mon)));
//---
  } //-end Month()
//---------//

int DayOfWeek(datetime dow)
  {
//---
    return(MqlReturnDateTime(dow,TimeReturn(day_of_week)));
//---
  } //-end Day()
//---------//

int Day(void)
  {
//---
    return(MqlReturnDateTime(TimeCurrent(),TimeReturn(day)));
//---
  } //-end Day()
//---------//

int Hours(void)
  {
//---
    return(MqlReturnDateTime(TimeCurrent(),TimeReturn(hour)));
//---
  } //-end Hours()
//---------//

int Minutes(void)
  {
//---
    return(MqlReturnDateTime(TimeCurrent(),TimeReturn(min)));
//---
  } //-end Minutes()
//---------//

int Seconds(void)
  {
//---
    return(MqlReturnDateTime(TimeCurrent(),TimeReturn(sec)));
//---
  } //-end Seconds()
//---------//

enum TimeReturn
  {
//---
    year        = 0,   // Year 
    mon         = 1,   // Month 
    day         = 2,   // Day 
    hour        = 3,   // Hour 
    min         = 4,   // Minutes 
    sec         = 5,   // Seconds 
    day_of_week = 6,   // Day of week (0-Sunday, 1-Monday, ... ,6-Saturday) 
    day_of_year = 7    // Day number of the year (January 1st is assigned the number value of zero) 
//---
  };
//---------//

int MqlReturnDateTime(datetime reqtime,
                      const int mode) 
  {
//---
    MqlDateTime mqltm;
    TimeToStruct(reqtime,mqltm);
    int valdate=0;
    //--
    switch(mode)
      {
        case 0: valdate=mqltm.year; break;        // Return Year 
        case 1: valdate=mqltm.mon;  break;        // Return Month 
        case 2: valdate=mqltm.day;  break;        // Return Day 
        case 3: valdate=mqltm.hour; break;        // Return Hour 
        case 4: valdate=mqltm.min;  break;        // Return Minutes 
        case 5: valdate=mqltm.sec;  break;        // Return Seconds 
        case 6: valdate=mqltm.day_of_week; break; // Return Day of week (0-Sunday, 1-Monday, ... ,6-Saturday) 
        case 7: valdate=mqltm.day_of_year; break; // Return Day number of the year (January 1st is assigned the number value of zero) 
      }
    return(valdate);
//---
  } //-end MqlReturnDateTime()
//---------//

string getUninitReasonText(int reasonCode) 
  { 
//---
   string text=""; 
   //--- 
   switch(reasonCode) 
     { 
       case REASON_PROGRAM:
            text="The EA has stopped working calling by remove function."; break;
       case REASON_REMOVE: 
            text="Program "+__FILE__+" was removed from chart"; break;
       case REASON_RECOMPILE:
            text="Program recompiled."; break;    
       case REASON_CHARTCHANGE: 
            text="Symbol or timeframe was changed"; break;
       case REASON_CHARTCLOSE: 
            text="Chart was closed"; break; 
       case REASON_PARAMETERS: 
            text="Input-parameter was changed"; break;            
       case REASON_ACCOUNT: 
            text="Account was changed"; break; 
       case REASON_TEMPLATE: 
            text="New template was applied to chart"; break; 
       case REASON_INITFAILED:
            text="The OnInit() handler returned a non-zero value."; break;
       case REASON_CLOSE: 
            text="Terminal closed."; break;
       default: text="Another reason"; break;
     } 
   //--
   return text;
//---
  } //-end getUninitReasonText()
//---------//
//+------------------------------------------------------------------+