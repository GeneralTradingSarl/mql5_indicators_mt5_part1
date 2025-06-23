//+------------------------------------------------------------------+ 
//|                                                         BoDi.mq5 | 
//|                                      Copyright © 2011, paladin80 | 
//|                                                  forevex@mail.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2011, paladin80"
#property link "forevex@mail.ru"
//--- номер версии индикатора
#property version   "1.01"
//--- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//--- количество индикаторных буферов 2
#property indicator_buffers 2 
//--- использовано всего одно графическое построение
#property indicator_plots   1
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//--- отрисовка индикатора в виде трёхцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//--- в качестве цветов трёхцветной гистограммы использованы
#property indicator_color1 clrDeepPink,clrGray,clrDodgerBlue
//--- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//--- толщина линии индикатора равна 2
#property indicator_width1 2
//--- отображение метки индикатора
#property indicator_label1 "BoDi"
//+-----------------------------------+
//| объявление констант               |
//+-----------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint                BBPeriod=20;                 // Период для расчета средней линии
input double              StdDeviation=2;              // Кол-во отклонений
input ENUM_APPLIED_PRICE  applied_price=PRICE_CLOSE;   // Тип цены
//+-----------------------------------+
//--- объявление целых переменных начала отсчёта данных
int min_rates_total;
//--- объявление динамических массивов, которые будут
//--- в дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[],ColorIndBuffer[];
//--- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle;
//+------------------------------------------------------------------+    
//| BoDi indicator initialization function                           | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- инициализация переменных начала отсчёта данных
   min_rates_total=int(BBPeriod+1);
//--- получение хендла индикатора iBands
   Ind_Handle=iBands(Symbol(),PERIOD_CURRENT,BBPeriod,0,StdDeviation,applied_price);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iBands");
      return(INIT_FAILED);
     }
//--- превращение динамического массива IndBuffer в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//--- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorIndBuffer,true);  
//--- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"BoDi");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| BoDi iteration function                                          | 
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
//--- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(Ind_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- объявления локальных переменных 
   int to_copy,limit,bar;
   double UpBB[],DnBB[];
//--- расчёты необходимого количества копируемых данных
//--- и стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total-2; // стартовый номер для расчёта всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }
   to_copy=limit+1;
//--- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(Ind_Handle,UPPER_BAND,0,to_copy,UpBB)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle,LOWER_BAND,0,to_copy,DnBB)<=0) return(RESET);
//--- индексация элементов в массивах как в таймсериях
   ArraySetAsSeries(UpBB,true);
   ArraySetAsSeries(DnBB,true);
//--- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--) IndBuffer[bar]=(UpBB[bar]-DnBB[bar])/_Point;
   if(prev_calculated>rates_total || prev_calculated<=0) limit--;
//--- основной цикл раскраски индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ColorIndBuffer[bar]=1;
      if(IndBuffer[bar]>IndBuffer[bar+1]) ColorIndBuffer[bar]=2;
      if(IndBuffer[bar]<IndBuffer[bar+1]) ColorIndBuffer[bar]=0;
     }
//---
   return(rates_total);
  }
//+------------------------------------------------------------------+
