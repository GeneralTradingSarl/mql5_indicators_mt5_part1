//+---------------------------------------------------------------------+
//|                                        ATR_Channels_Cloud_Digit.mq5 |
//|                            Copyright © 2005, Luis Guilherme Damiani |
//|                                         http://www.damianifx.com.br |
///+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2005, Luis Guilherme Damiani"
#property link      "http://www.damianifx.com.br"
#property description "ATR Channels"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 11
#property indicator_buffers 11 
//---- использовано всего шесть графических построений
#property indicator_plots   6
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color1  clrDeepSkyBlue
//---- отображение метки индикатора
#property indicator_label1  "Upper Envelope3 Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type2   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color2  clrLime
//---- отображение метки индикатора
#property indicator_label2  "Upper Envelope2 Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type3   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color3  clrLavender
//---- отображение метки индикатора
#property indicator_label3  "Envelope1 Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки мувинга                 |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета линии индикатора использован сине-фиолетовый цвет
#property indicator_color4 clrSlateBlue
//---- линия индикатора - сплошная
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width4  2
//---- отображение метки индикатора
#property indicator_label4  "XMA"
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type5   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color5  clrGold
//---- отображение метки индикатора
#property indicator_label5  "Lower Envelope2 Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type6   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color6  clrDarkOrange
//---- отображение метки индикатора
#property indicator_label6  "Lower Envelope3 Cloud"
//+-----------------------------------+
//| объявление констант               |
//+-----------------------------------+
#define RESET 0                    // Константа для возврата терминалу команды на пересчет индикатора
//+-----------------------------------+
//|  Описание классов усреднений      |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA;
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
enum Applied_price_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simpl Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price  
  };
//+-----------------------------------+
//|  объявление перечислений          |
//+-----------------------------------+
/*enum Smooth_Method - перечисление объявлено в файле SmoothAlgorithms.mqh
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+-----------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА     |
//+-----------------------------------+
input uint    ATRPeriod=18;
input double Mult_Factor1= 1.6;
input double Mult_Factor2= 3.2;
input double Mult_Factor3= 4.8;
//----
input Smooth_Method XMA_Method=MODE_SMA_; //метод усреднения
input uint XLength=100; //глубина  сглаживания                    
input int XPhase=15; //параметр усреднения,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_CLOSE_;//ценовая константа
input uint Digit=2; //количество разрядов округления
input int Shift=0; // сдвиг индикатора по горизонтали в барах
input int PriceShift=0; // cдвиг индикатора по вертикали в пунктах
input bool ShowPrice=true; //показывать ценовые метки
//---- цвета ценовых меток
input color  Middle_color=clrBlue;
input color  Upper_color1=clrMediumSeaGreen;
input color  Lower_color1=clrRed;
input color  Upper_color2=clrDodgerBlue;
input color  Lower_color2=clrMagenta;
input color  Upper_color3=clrBlue;
input color  Lower_color3=clrOrange;
//+-----------------------------------+
//---- объявление динамического массива, который будет в 
// дальнейшем использован в качестве индикаторного буфера
double ExtLineBuffer0[];
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов уровней Боллинджера
double UpBuffer1[],DnBuffer1[],UpBuffer2[],DnBuffer2[],UpBuffer3[],DnBuffer3[];
double UpBuffer4[],DnBuffer4[],UpBuffer5[],DnBuffer5[];
//---- Объявление переменной значения вертикального сдвига мувинга
double dPriceShift,PointPow10;
//---- Объявление переменной для хранения хендла индикатора
int ATR_Handle;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_XMA,min_rates_ATR,min_rates_total;
//---- Объявление стрингов для текстовых меток
string upper_name1,middle_name,lower_name1,upper_name2,lower_name2,upper_name3,lower_name3;
//+------------------------------------------------------------------+   
//| ATR Channels indicator initialization function                   | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,PERIOD_CURRENT,ATRPeriod);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }

//---- Инициализация переменных начала отсчёта данных
   min_rates_XMA=GetStartBars(XMA_Method,XLength,XPhase)+1;
   min_rates_ATR=min_rates_XMA+int(ATRPeriod);
   min_rates_total=min_rates_XMA+min_rates_ATR;
   PointPow10=_Point*MathPow(10,Digit);

//---- установка алертов на недопустимые значения внешних переменных
   XMA.XMALengthCheck("XLength",XLength);
   XMA.XMAPhaseCheck("XPhase",XPhase,XMA_Method);

//---- Инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;
//---- Инициализация стрингов
   upper_name1="Price_Channel_Central upper text lable 1";
   middle_name="Price_Channel_Central middle text lable";
   lower_name1="Price_Channel_Central lower text lable 1";
   upper_name2="Price_Channel_Central upper text lable 2";
   lower_name2="Price_Channel_Central lower text lable 2";
   upper_name3="Price_Channel_Central upper text lable 3";
   lower_name3="Price_Channel_Central lower text lable 3";

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpBuffer4,INDICATOR_DATA);
   SetIndexBuffer(1,DnBuffer4,INDICATOR_DATA);
   SetIndexBuffer(2,UpBuffer2,INDICATOR_DATA);
   SetIndexBuffer(3,DnBuffer2,INDICATOR_DATA);
   SetIndexBuffer(4,UpBuffer1,INDICATOR_DATA);
   SetIndexBuffer(5,DnBuffer1,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLineBuffer0,INDICATOR_DATA);
   SetIndexBuffer(7,UpBuffer3,INDICATOR_DATA);
   SetIndexBuffer(8,DnBuffer3,INDICATOR_DATA);
   SetIndexBuffer(9,UpBuffer5,INDICATOR_DATA);
   SetIndexBuffer(10,DnBuffer5,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(5,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,min_rates_total);
   
//---- индексация элементов в буферах как в таймсериях
   ArraySetAsSeries(UpBuffer4,true);
   ArraySetAsSeries(DnBuffer4,true);
   ArraySetAsSeries(UpBuffer2,true);
   ArraySetAsSeries(DnBuffer2,true);
   ArraySetAsSeries(UpBuffer1,true);
   ArraySetAsSeries(DnBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer0,true);
   ArraySetAsSeries(UpBuffer3,true);
   ArraySetAsSeries(DnBuffer3,true);
   ArraySetAsSeries(UpBuffer5,true);
   ArraySetAsSeries(DnBuffer5,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth=XMA.GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"ATR_Channels_Cloud_Digit(",XLength," ",Smooth,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,upper_name1);
   ObjectDelete(0,middle_name);
   ObjectDelete(0,lower_name1);
   ObjectDelete(0,upper_name2);
   ObjectDelete(0,lower_name2);
   ObjectDelete(0,upper_name3);
   ObjectDelete(0,lower_name3);
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+ 
//| ATR Channels iteration function                                  | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- Объявление переменных с плавающей точкой  
   double price,line,Range[];
//---- Объявление целых переменных и получение уже посчитанных баров
   int to_copy,limit,bar,maxbar=rates_total-1;

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      to_copy=rates_total; // расчётное количество всех баров
      limit=rates_total-1; // стартовый номер для расчёта всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
      to_copy=limit+1; // расчётное количество только новых баров
     }

//---- копируем вновь появившиеся данные в массив Range[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,Range)<=0) return(RESET);

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Range,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);

//---- Основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      price=PriceSeries(IPC,bar,open,low,high,close);
      line=XMA.XMASeries(maxbar,prev_calculated,rates_total,XMA_Method,XPhase,XLength,price,bar,true);
      line+=dPriceShift;
      ExtLineBuffer0[bar]=PointPow10*MathRound(line/PointPow10);
      //---- расчёт и округление первых уровней
      UpBuffer1[bar]=DnBuffer2[bar]=PointPow10*MathCeil((line+Range[bar]*Mult_Factor1)/PointPow10);
      DnBuffer1[bar]=UpBuffer3[bar]=PointPow10*MathFloor((line-Range[bar]*Mult_Factor1)/PointPow10);
      //---- исправление первых уровней
      if(ExtLineBuffer0[bar]>=UpBuffer1[bar]) UpBuffer1[bar]=DnBuffer2[bar]=ExtLineBuffer0[bar]+PointPow10;
      if(ExtLineBuffer0[bar]<=DnBuffer1[bar]) DnBuffer1[bar]=UpBuffer3[bar]=ExtLineBuffer0[bar]-PointPow10;

      //---- расчёт и округление вторых уровней
      UpBuffer2[bar]=DnBuffer4[bar]=PointPow10*MathCeil((line+Range[bar]*Mult_Factor2)/PointPow10);
      DnBuffer3[bar]=UpBuffer5[bar]=PointPow10*MathFloor((line-Range[bar]*Mult_Factor2)/PointPow10);
      //---- исправление вторых уровней
      if(UpBuffer1[bar]>=UpBuffer2[bar]) UpBuffer2[bar]=DnBuffer4[bar]=UpBuffer1[bar]+PointPow10;
      if(DnBuffer1[bar]<=DnBuffer3[bar]) DnBuffer3[bar]=UpBuffer5[bar]=DnBuffer1[bar]-PointPow10;

      //---- расчёт и округление третьих уровней       
      UpBuffer4[bar]=PointPow10*MathCeil((line+Range[bar]*Mult_Factor3)/PointPow10);
      DnBuffer5[bar]=PointPow10*MathFloor((line-Range[bar]*Mult_Factor3)/PointPow10);
      //---- исправление третьих уровней
      if(UpBuffer2[bar]>=UpBuffer4[bar]) UpBuffer4[bar]=UpBuffer2[bar]+PointPow10;
      if(DnBuffer3[bar]<=DnBuffer5[bar]) DnBuffer5[bar]=DnBuffer3[bar]-PointPow10;
     }
   if(ShowPrice)
     {
      int bar0=0;
      datetime time0=time[bar0]+Shift*PeriodSeconds();
      SetRightPrice(0,middle_name,0,time0,ExtLineBuffer0[bar0],Middle_color,"Georgia");
      SetRightPrice(0,upper_name1,0,time0,UpBuffer1[bar0],Upper_color1,"Georgia");
      SetRightPrice(0,lower_name1,0,time0,DnBuffer1[bar0],Lower_color1,"Georgia");
      SetRightPrice(0,upper_name2,0,time0,UpBuffer2[bar0],Upper_color2,"Georgia");
      SetRightPrice(0,lower_name2,0,time0,DnBuffer3[bar0],Lower_color2,"Georgia");
      SetRightPrice(0,upper_name3,0,time0,UpBuffer4[bar0],Upper_color3,"Georgia");
      SetRightPrice(0,lower_name3,0,time0,DnBuffer5[bar0],Lower_color3,"Georgia");
     }
//----     
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  RightPrice creation                                             |
//+------------------------------------------------------------------+
void CreateRightPrice(long chart_id,// chart ID
                      string   name,              // object name
                      int      nwin,              // window index
                      datetime time,              // price level time
                      double   price,             // price level
                      color    Color,             // Text color
                      string   Font               // Text font
                      )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,time,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,2);
//----
  }
//+------------------------------------------------------------------+
//|  RightPrice reinstallation                                       |
//+------------------------------------------------------------------+
void SetRightPrice(long chart_id,// chart ID
                   string   name,              // object name
                   int      nwin,              // window index
                   datetime time,              // price level time
                   double   price,             // price level
                   color    Color,             // Text color
                   string   Font               // Text font
                   )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateRightPrice(chart_id,name,nwin,time,price,Color,Font);
   else ObjectMove(chart_id,name,0,time,price);
//----
  }
//+------------------------------------------------------------------+
