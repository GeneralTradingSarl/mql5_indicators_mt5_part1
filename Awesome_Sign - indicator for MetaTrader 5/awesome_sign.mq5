//+---------------------------------------------------------------------+
//|                                                    Awesome_Sign.mq5 |
//|                                  Copyright © 2015, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован DeepPink цвет
#property indicator_color1  clrDeepPink
//--- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//--- отображение медвежьей метки индикатора
#property indicator_label1  "Awesome Sell"
//+----------------------------------------------+
//| Параметры отрисовки бычьего индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычьей линии индикатора использован Aqua цвет
#property indicator_color2  clrAqua
//--- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//--- отображение бычьей метки индикатора
#property indicator_label2 "Awesome Buy"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0       // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//|  Описание классов усреднений                 |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2,XMA3;
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
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
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
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
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input Smooth_Method XMA_Method=MODE_SMA; // Метод усреднения Awesome гистограммы
input int Fast_XMA = 5;  // Период быстрого мувинга
input int Slow_XMA = 34; // Период медленного мувинга
input int XPhase = 100;  // Параметр усреднения мувингов,
//--- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//--- для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method Signal_Method=MODE_SMA; // Метод усреднения сигнальной линии
input int Signal_XMA=5; // Период сигнальной линии 
input int Signal_Phase=100; // Параметр сигнальной линии
//--- изменяющийся в пределах -100 ... +100,
//--- влияет на качество переходного процесса;
input Applied_price_ AppliedPrice=PRICE_CLOSE; // Ценовая константа
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//--- объявление целочисленных переменных для хендлов индикаторов
int ATR_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total,min_rates_1;
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double SellBuffer[],BuyBuffer[];
//+------------------------------------------------------------------+    
//| Awesome indicator initialization function                        | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- получение хендла индикатора ATR
   int ATR_Period=15;
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//---- инициализация переменных начала отсчета данных
   min_rates_1=MathMax(XMA1.GetStartBars(XMA_Method,Fast_XMA,XPhase),XMA1.GetStartBars(XMA_Method,Slow_XMA,XPhase));
   min_rates_total=min_rates_1+XMA1.GetStartBars(Signal_Method,Signal_XMA,Signal_Phase)+2;
   min_rates_total=MathMax(ATR_Period,min_rates_total+2);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,172);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,172);
//--- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("Fast_XMA", Fast_XMA);
   XMA1.XMALengthCheck("Slow_XMA", Slow_XMA);
   XMA1.XMALengthCheck("Signal_XMA", Signal_XMA);
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMAPhaseCheck("XPhase", XPhase, XMA_Method);
   XMA1.XMAPhaseCheck("Signal_Phase", Signal_Phase, Signal_Method);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(XMA_Method);
   string Smooth2=XMA1.GetString_MA_Method(Signal_Method);
   StringConcatenate(shortname,"AwesomeSign( ",Fast_XMA,", ",Slow_XMA,", ",Signal_XMA,", ",Smooth1,", ",Smooth2," )");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Awesome iteration function                                       | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//---- объявление целочисленных переменных
   int first,bar;
//---- объявление переменных с плавающей точкой  
   double price,fast_xma,slow_xma,xmacd,sign,dif,trend,ATR[1];
   static double trend_prev;
//---- инициализация индикатора в блоке OnCalculate()
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      first=0; // стартовый номер для расчета всех баров первого цикла
      trend_prev=0;
     }
   else // стартовый номер для расчета новых баров
     {
      first=prev_calculated-1;
     }
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total; bar++)
     {
      price=PriceSeries(AppliedPrice,bar,open,low,high,close);;
      fast_xma=XMA1.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,Fast_XMA,price,bar,false);
      slow_xma=XMA2.XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,Slow_XMA,price,bar,false);
      xmacd=fast_xma-slow_xma;
      sign=XMA3.XMASeries(min_rates_1,prev_calculated,rates_total,Signal_Method,Signal_Phase,Signal_XMA,xmacd,bar,false);
      dif=xmacd-sign;
      if(dif) trend=dif;
      else trend=trend_prev;
      //--- 
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      //---
      if(trend_prev<=0 && trend>0)
        {
         //--- копируем вновь появившиеся данные в массив
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         BuyBuffer[bar]=low[bar]-ATR[0]*3/8;
        }
      //---
      if(trend_prev>=0 && trend<0)
        {
         //--- копируем вновь появившиеся данные в массив
         if(CopyBuffer(ATR_Handle,0,time[bar],1,ATR)<=0) return(RESET);
         SellBuffer[bar]=high[bar]+ATR[0]*3/8;
        }
      //---
      if(bar<rates_total-1) trend_prev=trend;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
