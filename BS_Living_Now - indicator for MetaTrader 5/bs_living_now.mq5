//+------------------------------------------------------------------+
//|                                                BS_Living_Now.mq5 |
//|                                      Copyright © 2013, Backspace | 
//|                                                  Success Version | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2013, Backspace" 
#property link      "Success Version" 
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- количество индикаторных буферов 4
#property indicator_buffers 4 
//---- использовано всего четыре графических построения
#property indicator_plots   4
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type1 DRAW_ARROW
//---- в качестве окраски индикатора использован
#property indicator_color1 clrLime
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки сигнальной линии
#property indicator_label1  "BS_Living_Now ExtrimHi"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type2 DRAW_ARROW
//---- в качестве окраски индикатора использован
#property indicator_color2 clrRed
//---- толщина линии индикатора равна 2
#property indicator_width2 2
//---- отображение метки сигнальной линии
#property indicator_label2  "BS_Living_Now ExtrimLo"
//+----------------------------------------------+
//|  Параметры отрисовки бычьего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде значка
#property indicator_type3   DRAW_ARROW
//---- в качестве цвета бычей линии индикатора использован цвет Blue
#property indicator_color3  clrBlue
//---- толщина линии индикатора 3 равна 1
#property indicator_width3  1
//---- отображение бычьей метки индикатора
#property indicator_label3  "Buy BS_Living_Now BreakHi"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде значка
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета медвежьей линии индикатора использован цвет Magenta
#property indicator_color4  clrMagenta
//---- толщина линии индикатора 2 равна 1
#property indicator_width4  1
//---- отображение медвежьей метки индикатора
#property indicator_label4  "Sell BS_Living_Now BreakLo"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint iPeriod=10;  // Период индикатора
input int Shift=0;      // Сдвиг индикатора по горизонтали в барах 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double ExtrimHi[],ExtrimLo[];
double BreakHi[],BreakLo[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(iPeriod);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"BS_Living_Now(",string(iPeriod),", ",string(Shift),")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtrimHi,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(ExtrimHi,true);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,217);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,ExtrimLo,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(ExtrimLo,true);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,218);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,BreakHi,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(BreakHi,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
//---- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,177);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,BreakLo,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(BreakLo,true);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0.0);
//---- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,177);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // ценовой массив минимумов цены для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);

//---- объявления локальных переменных 
   double HH,LL;
   int limit,bar;

//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1;               // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated;                 // стартовый номер для расчета новых баров
     }

//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ExtrimHi[bar]=0.0;
      ExtrimLo[bar]=0.0;
      BreakHi[bar]=0.0;
      BreakLo[bar]=0.0;
      if(!bar) break;

      HH=high[ArrayMaximum(high,bar+1,iPeriod)];
      LL=low[ArrayMinimum(low,bar+1,iPeriod)];

      if(high[bar]>HH && high[bar]>high[bar-1])
        {
         double AvgRange=0.0;
         for(int iii=0; iii<int(iPeriod); iii++) AvgRange+=MathAbs(high[bar+iii]-low[bar+iii]);
         AvgRange/=iPeriod;
         ExtrimHi[bar]=high[bar]+0.3*AvgRange;
        
        for(int iii=int(iPeriod); iii>0; iii--)
          {
          if(high[bar+iii]<high[ArrayMaximum(high,bar+iii+1,iPeriod)])
          BreakHi[bar]=low[ArrayMinimum(low,bar+iii+1,iPeriod)];
          }

        }

      if(low[bar]<LL && low[bar]<low[bar-1])
        {
         double AvgRange=0.0;
         for(int iii=0; iii<int(iPeriod); iii++) AvgRange+=MathAbs(high[bar+iii]-low[bar+iii]);
         AvgRange/=iPeriod;
         ExtrimLo[bar]=low[bar]-0.3*AvgRange;

      for(int iii=int(iPeriod); iii>0; iii--)
          {
          if(low[bar+iii]>low[ArrayMinimum(low,bar+iii+1,iPeriod)])
          BreakLo[bar]=high[ArrayMaximum(high,bar+iii+1,iPeriod)];
          }
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
