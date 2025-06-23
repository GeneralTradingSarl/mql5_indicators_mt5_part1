//+------------------------------------------------------------------+
//|                                                    AroonHorn.mq5 |
//|                                        Copyright © 2011, tonyc2a | 
//|                                         mailto:tonyc2a@yahoo.com | 
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2011, tonyc2a"
//---- ссылка на сайт автора
#property link "mailto:tonyc2a@yahoo.com"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчёта и отрисовки индикатора использовано четыре буфера
#property indicator_buffers 4
//---- использовано три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета бычей линии индикатора использован зелёный цвет
#property indicator_color1  clrLimeGreen
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 2
#property indicator_width1  2
//---- отображение бычей метки индикатора
#property indicator_label1  "BullsAroon"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован красный цвет
#property indicator_color2  clrCrimson
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение медвежьей метки индикатора
#property indicator_label2  "BearsAroon"
//+----------------------------------------------+
//|  Параметры отрисовки сигнального облака      |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type3   DRAW_FILLING
//---- в качестве цветов индикатора использованы
#property indicator_color3  clrPaleGreen,clrLightPink
//---- отображение метки индикатора
#property indicator_label3  "Signal Aroon Cloud"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 70.0
#property indicator_level2 50.0
#property indicator_level3 30.0
#property indicator_levelcolor clrGray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int AroonPeriod= 9; // период индикатора 
input int AroonShift = 0; // сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double BullsAroonBuffer1[];
double BearsAroonBuffer1[];
double BullsAroonBuffer2[];
double BearsAroonBuffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- превращение динамического массива BullsAroonBuffer в индикаторный буфер
   SetIndexBuffer(0,BullsAroonBuffer1,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на AroonShift
   PlotIndexSetInteger(0,PLOT_SHIFT,AroonShift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1 на AroonPeriod
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,AroonPeriod);

//---- превращение динамического массива BearsAroonBuffer в индикаторный буфер
   SetIndexBuffer(1,BearsAroonBuffer1,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на AroonShift
   PlotIndexSetInteger(1,PLOT_SHIFT,AroonShift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2 на AroonPeriod
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,AroonPeriod);

//---- превращение динамического массива BullsAroonBuffer в индикаторный буфер
   SetIndexBuffer(2,BullsAroonBuffer2,INDICATOR_DATA);
//---- превращение динамического массива BearsAroonBuffer в индикаторный буфер
   SetIndexBuffer(3,BearsAroonBuffer2,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на AroonShift
   PlotIndexSetInteger(2,PLOT_SHIFT,AroonShift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1 на AroonPeriod
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,AroonPeriod);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Aroon(",AroonPeriod,", ",AroonShift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчёта индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчёта индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<AroonPeriod-1) return(0);

//---- объявления локальных переменных 
   int first,bar;
   double BULLS,BEARS;

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=AroonPeriod-1; // стартовый номер для расчёта всех баров
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      int barx=rates_total-bar-1;
      //---- вычисление индикаторных значений
      BULLS=NormalizeDouble(100-(ArrayMaximum(high,barx,AroonPeriod)-barx+0.5)*100/AroonPeriod,0);
      BEARS=NormalizeDouble(100-(ArrayMinimum(low,barx,AroonPeriod)-barx+0.5)*100/AroonPeriod,0);

      //---- инициализация ячеек индикаторных буферов полученными значениями 
      BullsAroonBuffer1[bar]=BULLS;
      BearsAroonBuffer1[bar]=BEARS;
      BullsAroonBuffer2[bar]=0;
      BearsAroonBuffer2[bar]=0;

      if(BULLS!=BEARS)
        {
         if(BULLS>BEARS && BULLS>=50)
           {
            BullsAroonBuffer2[bar]=BULLS;
            BearsAroonBuffer2[bar]=BEARS;           
           }

         if(BULLS<BEARS && BEARS>=50)
           {
            BullsAroonBuffer2[bar]=BULLS;
            BearsAroonBuffer2[bar]=BEARS;
           }
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
