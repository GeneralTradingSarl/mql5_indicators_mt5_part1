//+------------------------------------------------------------------+
//|                                         Colored Zerolag MACD.mq5 |
//|             Copyright 2014-2017, PersiansDream Informatics Group |
//|                                    http://my.pdhost.net/cart.php |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014-2017, PersiansDream Informatics Group"
#property link      "http://my.pdhost.net/cart.php"
#property version   "612.069"
#property description "Original code by : RD - marynarz15@wp.pl \n"
#property description "Join our telegram : https://telegram.me/FXCOFOREX"
#property description "\n"
#property description "Change log : 2016.11.23-Fixed some bugs in colored indicator-By Farzin."
#property description "Change log : 2016.11.28_12.06-MQL5 version-By Farzin."
#property description "Change log : 2016.12.06-MQL5 version-Recoded IMAonArray for reading all history candles."
#property indicator_separate_window
#property indicator_buffers 10
#property indicator_plots 4
#property indicator_color1 Black
#property indicator_color2 Lime
#property indicator_color3 Red
#property indicator_color4 Blue

#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
//---- input parameters
input int FastEMA = 12;
input int SlowEMA = 26;
input int SignalEMA = 9;
      int      FastEMAHandle;   
      int      SlowEMAHandle;
//---- buffers
      double   MACDBufferZeroLag[];
      double   FastEMABuffer[];
      double   SlowEMABuffer[];
      double   EMApArray[];
      double   EMAqArray[];
      double   SignalEMAArray[];
      double   SignalEMABuffer[];
      double   SignalBuffer[];

      double   Buffer1[];
      double   Buffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(){
   //Print((string)__LINE__+"-OnInit Executed.");
   //Print((string)__LINE__+"-Bars(_Symbol,_Period)="+(string)Bars(_Symbol,_Period));  
   //--- indicator buffers mapping
   
   bool MACDresult=SetIndexBuffer(0,MACDBufferZeroLag,INDICATOR_DATA);
   //Print((string)__LINE__+"-MACD result="+(string)MACDresult);
   SetIndexBuffer(1,Buffer1,INDICATOR_DATA);
   SetIndexBuffer(2,Buffer2,INDICATOR_DATA);
   SetIndexBuffer(3,SignalBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,FastEMABuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,SlowEMABuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,EMApArray,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,EMAqArray,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,SignalEMAArray,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,SignalEMABuffer,INDICATOR_CALCULATIONS);
   
   PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
   PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_HISTOGRAM);
   PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_HISTOGRAM);
   PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_LINE);

   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,SlowEMA);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,SlowEMA);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,SlowEMA);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,SlowEMA);
   IndicatorSetString(INDICATOR_SHORTNAME,"Far-ZeroLag MACD Colored(" + (string)FastEMA + "," + (string)SlowEMA + "," + (string)SignalEMA + ")");
   bool MACDplotResult=PlotIndexSetString(0,PLOT_LABEL,"MACD");
   //Print((string)__LINE__+"-MACD plot Result="+(string)MACDplotResult);
   PlotIndexSetString(1,PLOT_LABEL,"MACD-Growing");
   PlotIndexSetString(2,PLOT_LABEL,"MACD-Decreasing");
   PlotIndexSetString(3,PLOT_LABEL,"Signal");

   FastEMAHandle = iMA(NULL,PERIOD_CURRENT,FastEMA,/*ma_shift*/0,MODE_EMA,PRICE_CLOSE);
   SlowEMAHandle = iMA(NULL,PERIOD_CURRENT,SlowEMA,/*ma_shift*/0,MODE_EMA,PRICE_CLOSE);

   //ArraySetAsSeries(time,true);
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| end of OnInit                                                    |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| start of OnDeInit                                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
   //--- The first way to get the uninitialization reason code
   Print(__FUNCTION__,"_Uninitalization reason code = ",reason);
   //Log((string)__LINE__+"-"+__FUNCTION__+"-Uninitalization reason code = "+(string)reason);
   //--- The second way to get the uninitialization reason code
   Print(__FUNCTION__,"_UninitReason = ",getUninitReasonText(_UninitReason));
}
//+------------------------------------------------------------------+
//| End of OnDeInit                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| get UninitReason text Start                                      |
//+------------------------------------------------------------------+
string getUninitReasonText(int reasonCode){
   string text="";
//---
   switch(reasonCode){
      case REASON_PROGRAM:/*0*/
         text="Expert Advisor terminated its operation by calling the ExpertRemove() function";break;
      case REASON_ACCOUNT:
         text="Account was changed";break;
      case REASON_CHARTCHANGE:
         text="Symbol or timeframe was changed";break;
      case REASON_CHARTCLOSE:
         text="Chart was closed";break;
      case REASON_PARAMETERS:
         text="Input-parameter was changed";break;
      case REASON_RECOMPILE:
         text="Program "+__FILE__+" was recompiled";break;
      case REASON_REMOVE:
         text="Program "+__FILE__+" was removed from chart";break;
      case REASON_TEMPLATE:
         text="New template was applied to chart";break;
      default:text="Another reason";
   }
   return text;
}
//+------------------------------------------------------------------+
//| End of get UninitReason text                                     |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| start of iMAOnArrayMQL4                                          |
//+------------------------------------------------------------------+
void iMAOnArrayMQL4(double &array[],
                     double &dstArray[],
                     int period,
                     int shift)
{
   //Print((string)__LINE__+"-period="+(string)period+" | ma_shift="+(string)ma_shift+" | shift="+(string)shift);
   //Print((string)__LINE__+"-array size[buf]="+(string)ArraySize(buf));   
   double pr=2.0/(period+1);
   if(shift==Bars(_Symbol,_Period)-1){
      dstArray[shift]=array[shift];
   }
   if(shift<(Bars(_Symbol,_Period)-1)){
      dstArray[shift]=NormalizeDouble((array[shift]*pr)+(dstArray[shift+1]*(1-pr)),6);
   }
   //Print((string)__LINE__+"-shift="+(string)(shift)+" | FastEMABuffer["+(string)(shift)+"]="+(string)FastEMABuffer[shift]+" | EMApArray["+(string)(shift)+"]="+(string)EMApArray[shift]+" | EMAqArray["+(string)(shift)+"]="+(string)EMAqArray[shift]);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

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
   //ArraySetAsSeries(time,true);
   //--- check for data
   if(rates_total<SlowEMA){
      Print((string)__LINE__+"-Error : Not enough Data is available.");
      return(0);
   }
   int calculated=BarsCalculated(FastEMAHandle);
   //Print((string)__LINE__+"-rates_total="+(string)rates_total+" | calculated FastMA="+(string)calculated);
   if(calculated<rates_total){
      Print("Not all data of FastEMAHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
   }
   int SlowEMAcalculated=BarsCalculated(SlowEMAHandle);
   //Print((string)__LINE__+"-rates_total="+(string)rates_total+" | calculated SlowEMAHandle="+(string)SlowEMAcalculated+" | Bars on "+EnumToString(_Period)+" TF="+(string)Bars(_Symbol,_Period)+" | prev_calculated="+(string)prev_calculated);
   if(SlowEMAcalculated<rates_total){
      Print("Not all data of SlowEMAHandle is calculated (",SlowEMAcalculated,"bars ). Error",GetLastError());
      return(0);
   }
   //--- we can copy not all data
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0){
      to_copy=rates_total;   
   }else{
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
   }
//--- get Fast EMA buffer
   if(IsStopped()){
      Print((string)__LINE__+"-Stop Flag is active");
      return(0); //Checking for stop flag
   }   
   if(CopyBuffer(FastEMAHandle,0,0,to_copy,FastEMABuffer)<=0){
      Print("Error : Getting fast EMA is failed! Error",GetLastError());
      return(0);
   }
   if(CopyBuffer(SlowEMAHandle,0,/*start position 0 = current position*/0,to_copy,SlowEMABuffer)<=0){
      Print("Error : Getting slow EMA is failed! Error",GetLastError());
      return(0);
   }
   if(prev_calculated==0){
      int SignalInitZero=ArrayInitialize(SignalBuffer,0);
      int Buffer1InitZero=ArrayInitialize(Buffer1,0);
      int Buffer2InitZero=ArrayInitialize(Buffer2,0);
      //Print((string)__LINE__+"-SignalInitZero="+(string)SignalInitZero+" | Buffer1InitZero="+(string)Buffer1InitZero+" | Buffer2InitZero="+(string)Buffer2InitZero);
   }   
   //Print((string)__LINE__+"-ArraySize FastEMABuffer="+(string)ArraySize(FastEMABuffer)+" | ArraySize SlowEMABuffer="+(string)ArraySize(SlowEMABuffer));
   /*if(EMApArray[5300]==EMPTY_VALUE){
      Print((string)__LINE__+"-EMApArray[5300]=EMPTY_VALUE which is "+(string)EMApArray[5300]);
   }
   if(EMAqArray[5200]==EMPTY_VALUE){
      Print((string)__LINE__+"-EMApArray[5200]=EMPTY_VALUE which is "+(string)EMAqArray[5200]);
   }
   if(SignalEMAArray[5100]==EMPTY_VALUE){
      Print((string)__LINE__+"-EMApArray[5100]=EMPTY_VALUE which is "+(string)SignalEMAArray[5100]);
   } */   
   double ZeroLagEMAp, ZeroLagEMAq;
   int CandleLimiter=0;
   if( (prev_calculated>0) ){
      CandleLimiter=rates_total-3;
   }
   /*if( (rates_total>=5000) && (prev_calculated==0) ){
      CandleLimiter=rates_total-5000;
   }else if( (rates_total>=5000) && (prev_calculated>0) ){
      CandleLimiter=rates_total-4;
   }*/
   //Print((string)__LINE__+"-Bars:"+(string)Bars(_Symbol,_Period)+" | rates_total="+(string)rates_total+" | prev Counted Bars:"+(string)prev_calculated+" | CandleLimiter="+(string)CandleLimiter);
   //ArraySetAsSeries(SignalBuffer,true);
   //Print((string)__LINE__+"-calculating EMAp 4651="+(string)iMAOnArrayMQL4(FastEMABuffer,/*total*/(counterlimit),/*period*/FastEMA,/*ma_shift*/0, MODE_EMA, 4651));
   //for(int i=limit;(i<(counterlimit)) && !IsStopped();i++){
   //for(int i = SlowEMA; i < limit; i++){
   /*if(prev_calculated==0){
      Print((string)__LINE__+"-Bars:"+(string)Bars(_Symbol,_Period)+" | rates_total="+(string)rates_total+" | Counted Bars:"+(string)prev_calculated+" | CandleLimiter="+(string)CandleLimiter);
      Print((string)__LINE__+"-ArraySize MACDBuffer="+(string)ArraySize(MACDBufferZeroLag)+"-ArraySize EMApArray="+(string)ArraySize(EMApArray)+"-ArraySize EMAqArray="+(string)ArraySize(EMAqArray));
   } */ 
   for(int i=(rates_total-1)/*-1 because arrays start from 0*/;(i>(CandleLimiter)) && !IsStopped();i--){
      iMAOnArrayMQL4(FastEMABuffer,/*dstArray*/EMApArray,/*period*/FastEMA,i);
      ZeroLagEMAp = FastEMABuffer[i] + FastEMABuffer[i] - EMApArray[i];
      //Print((string)__LINE__+"-i="+(string)i+" | FastEMABuffer="+(string)FastEMABuffer[i]+" | EMAp="+(string)EMAp+" | ZeroLagEMAp="+(string)ZeroLagEMAp);
      //Print((string)__LINE__+"-calculating EMAq");
      iMAOnArrayMQL4(SlowEMABuffer,/*dstArray*/EMAqArray,/*period*/SlowEMA,i);
      ZeroLagEMAq = SlowEMABuffer[i] + SlowEMABuffer[i] - EMAqArray[i];
      //Print((string)__LINE__+"-i="+(string)i+" | time[i] = ",(string)time[i]+" | SlowEMABuffer="+(string)SlowEMABuffer[i]+" | EMAq="+(string)EMAq+" | ZeroLagEMAq="+(string)ZeroLagEMAq);
      //Print((string)__LINE__+"-i="+(string)i+" | time[i] = ",(string)time[i]+" | EMAp="+(string)EMAp+" | EMAq="+(string)EMAq);
      
      MACDBufferZeroLag[i] = ZeroLagEMAp - ZeroLagEMAq;
      //Print((string)__LINE__+"-i="+(string)i+" | time[i] = ",(string)time[i]+" | ZeroLagEMAp="+(string)ZeroLagEMAp+" | ZeroLagEMAq="+(string)ZeroLagEMAq+" | MACDBuffer[i]="+(string)MACDBufferZeroLag[i]);
      iMAOnArrayMQL4(MACDBufferZeroLag,/*dstArray*/SignalEMAArray,SignalEMA,i);
      iMAOnArrayMQL4(SignalEMAArray,/*dstArray*/SignalEMABuffer,SignalEMA,i);
      SignalBuffer[i] = (2*SignalEMAArray[i]) - SignalEMABuffer[i];
   }
      //---- dispatch values between 2 buffers
      bool up=true;
      double prev,current;
      //for(int i=limit;i<(counterlimit) && !IsStopped();i++){
      for(int i=(rates_total-1);(i>(CandleLimiter)) && !IsStopped();i--){  
         current=MACDBufferZeroLag[i];
         prev=MACDBufferZeroLag[i-1];
         //Print((string)__LINE__+"-i="+(string)i+" | time[i] = ",(string)time[i]+" | MACDBuffer[i]="+(string)MACDBuffer[i]+" | prev="+(string)prev);
         if(current>prev){
            up=true;
         }   
         if(current<prev){
            up=false;
         }   
         if(!up){
            Buffer2[i]=current;
            Buffer1[i]=0.0;
         }else{
            Buffer1[i]=current;
            Buffer2[i]=0.0;
         }
      }
   //Print((string)__LINE__+"-First loop is finished.calculating SignalEMABuffer");
   //for(int i=limit;i<(counterlimit) && !IsStopped();i++){
//--- return value of prev_calculated for next call
   return(rates_total);
}