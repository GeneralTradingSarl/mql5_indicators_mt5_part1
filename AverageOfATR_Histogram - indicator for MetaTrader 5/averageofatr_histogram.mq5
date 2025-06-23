//+---------------------------------------------------------------------+
//|                                          AverageOfATR_Histogram.mq5 |
//|                                        Copyright 2015, FXMatics.com |
//|                                             http://www.fxmatics.com |
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright 2015, FXMatics.com"
#property link      "http://www.fxmatics.com"
#property description ""
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 4 
//---- использовано всего три графических построения
#property indicator_plots   3
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде гистограммы
#property indicator_type1   DRAW_COLOR_HISTOGRAM
//---- в качестве цветов индикатора использованы
#property indicator_color1  clrYellow,clrDarkBlue
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1 3
//---- отображение метки индикатора
#property indicator_label1  "AverageOfATR_Histogram"
//+----------------------------------------------+
//| Параметры отрисовки индикатора тренда        |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета индикатора использован розовый цвет
#property indicator_color2  clrMagenta
//--- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//--- отображение бычей метки индикатора
#property indicator_label2  "AverageOfATR Trend"
//+----------------------------------------------+
//| Параметры отрисовки индикатора флета         |
//+----------------------------------------------+
//--- отрисовка индикатора 3 в виде символа
#property indicator_type3   DRAW_ARROW
//--- в качестве цвета индикатора использован голубой цвет
#property indicator_color3  clrDodgerBlue
//--- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//--- отображение медвежьей метки индикатора
#property indicator_label3 "AverageOfATR Flat"
//+-----------------------------------+
//| Объявление констант               |
//+-----------------------------------+
#define RESET 0                    // Константа для возврата терминалу команды на пересчет индикатора
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
input int    ATRPeriod=7;
input Smooth_Method XMA_Method=MODE_SMA; //Метод усреднения
input int XLength=3; //Глубина  сглаживания
input int XPhase=15; //Параметр усреднения
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- для VIDIA это период CMO, для AMA это период медленной скользящей
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorBuffer[];
double UpIndBuffer[],DnIndBuffer[];
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
   min_rates_total=min_rates_ATR+GetStartBars(XMA_Method,XLength,XPhase)+2;
//---- установка алертов на недопустимые значения внешних переменных
   XMA.XMALengthCheck("XLength",XLength);
   XMA.XMAPhaseCheck("XPhase",XPhase,XMA_Method);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorBuffer,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,UpIndBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,172);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpIndBuffer,true);

//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,DnIndBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,163);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnIndBuffer,true);

//---- инициализация переменной для короткого имени индикатора
   string shortname;
   string Smooth=XMA.GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"AverageOfATR_Histogram(",ATRPeriod," ",XLength," ",Smooth,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,4);
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
//---- объявления локальных переменных
   int to_copy,limit,bar,maxbar,clr;
   double ATR[],diff,xatr;
   static double diff_prev;
   maxbar=rates_total-1-min_rates_ATR-2;
//---- расчеты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=maxbar; // стартовый номер для расчета всех баров
      diff_prev=0.0;
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
   to_copy=limit+2;
//---- индексация элементов в массиве как в таймсерии
   ArraySetAsSeries(ATR,true);
//---- копируем вновь появившиеся данные в массив ATR[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      xatr=XMA.XMASeries(maxbar,prev_calculated,rates_total,XMA_Method,XPhase,XLength,ATR[bar],bar,true);
      diff=IndBuffer[bar]=ATR[bar]-xatr;
      if(diff>0) clr=0;
      else clr=1;
      ColorBuffer[bar]=clr;
      //----      
      UpIndBuffer[bar]=EMPTY_VALUE;
      DnIndBuffer[bar]=EMPTY_VALUE;
      if(diff>0 && diff_prev<=0) UpIndBuffer[bar]=0.0;
      if(diff<0 && diff_prev>=0) DnIndBuffer[bar]=0.0;
      //----
      if(bar) diff_prev=diff;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
