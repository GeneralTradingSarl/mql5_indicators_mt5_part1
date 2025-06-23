//+---------------------------------------------------------------------+
//|                                                     ATRSmoothed.mq5 |
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
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 1 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде гистограммы
#property indicator_type1   DRAW_HISTOGRAM
//---- в качестве цвета линии индикатора использован сине-фиолетовый цвет
#property indicator_color1 clrBlueViolet
//---- линия индикатора - сплошная линия
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "ATRSmoothed"
//+-----------------------------------+
//| Объявление констант               |
//+-----------------------------------+
#define RESET 0                    // константа для возврата терминалу команды на пересчет индикатора
//+-----------------------------------+
//| Описание классов усреднений       |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA;
//+-----------------------------------+
//| Объявление перечислений           |
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
//| Входные параметры индикатора      |
//+-----------------------------------+
input int    ATRPeriod=14;
input Smooth_Method XMA_Method=MODE_JJMA; // Метод усреднения
input int XLength=5; // Глубина  сглаживания
input int XPhase=15; // Параметр усреднения
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- для VIDIA это период CMO, для AMA это период медленной скользящей
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление динамического массива, который будет в 
//---- дальнейшем использован в качестве индикаторного буфера
double ExtLineBuffer[];
//---- объявление переменной для хранения хендла индикатора
int ATR_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_ATR,min_rates_total;
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
//---- инициализация переменных начала отсчета данных
   min_rates_ATR=int(ATRPeriod);
   min_rates_total=min_rates_ATR+GetStartBars(XMA_Method,XLength,XPhase)+1;
//---- установка алертов на недопустимые значения внешних переменных
   XMA.XMALengthCheck("XLength",XLength);
   XMA.XMAPhaseCheck("XPhase",XPhase,XMA_Method);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(ExtLineBuffer,true);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   string Smooth=XMA.GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"ATRSmoothed(",ATRPeriod," ",XLength," ",Smooth,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| ATR Channels iteration function                                  | 
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
//---- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//---- объявление переменных с плавающей точкой  
   double Range[];
//---- объявление целочисленных переменных и получение уже посчитанных баров
   int to_copy,limit,bar,maxbar;
   maxbar=rates_total-1-min_rates_ATR;
//---- расчеты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=maxbar; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
   to_copy=limit+1;
//---- копируем вновь появившиеся данные в массив Range[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,Range)<=0) return(RESET);
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Range,true);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtLineBuffer[bar]=XMA.XMASeries(maxbar,prev_calculated,rates_total,XMA_Method,XPhase,XLength,Range[bar],bar,true);
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
