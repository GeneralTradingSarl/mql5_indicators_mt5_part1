//+------------------------------------------------------------------+
//|                                                    AML_StDev.mq5 | 
//|                                       Copyright © 2011, andreybs | 
//|                                               andreybs@yandex.ru | 
//+------------------------------------------------------------------+ 
//---- авторство индикатора
#property copyright "Adaptive Market Level"
//---- авторство индикатора
#property link      "andreybs@yandex.ru"
//---- номер версии индикатора
#property version   "1.11"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано четыре буфера
#property indicator_buffers 4
//---- использовано три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде многоцветной линии
#property indicator_type1   DRAW_COLOR_LINE
//---- в качестве цветов трехцветной линии использованы
#property indicator_color1  clrGray,clrDeepSkyBlue,clrViolet
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1  3
//---- отображение метки индикатора
#property indicator_label1  "AML"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета медвежьего индикатора использован красный цвет
#property indicator_color2  clrRed
//---- толщина линии индикатора 2 равна 3
#property indicator_width2  3
//---- отображение медвежьей метки индикатора
#property indicator_label2  "Dn_Signal"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде символа
#property indicator_type3   DRAW_ARROW
//---- в качестве цвета бычьего индикатора использован зелёный цвет
#property indicator_color3  clrLime
//---- толщина линии индикатора 3 равна 3
#property indicator_width3  3
//---- отображение бычей метки индикатора
#property indicator_label3  "Up_Signal"

//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input uint Fractal=6;
input int Lag=7;
input double dK=3.0;  //коэффициент для квадратичного фильтра
input uint std_period=9; //период квадратичного фильтра
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
input int PriceShift=0; // Сдвиг индикатора по вертикали в пунктах
//+----------------------------------------------+

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double AMLBuffer[];
double ColorAMLBuffer[];
double BearsBuffer[];
double BullsBuffer[];
//----
double dAML[];
//---- Объявление переменной значения вертикального сдвига мувинга
double dPriceShift;
double LagLagPoint;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_1,min_rates_total,size,Fractal2;
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве кольцевых буферов
int Count[];
double Smooth[];
//+------------------------------------------------------------------+
//|  Пересчет позиции самого нового элемента в массиве               |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos(int &CoArr[],// Возврат по ссылке номера текущего значения ценового ряда
                          int Size)
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=Size;
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+
//| расчёт максимального диапозона движения цены                     |
//+------------------------------------------------------------------+
double Range(int period,int start,const double &High[],const double &Low[])
  {
//----
   double max = High[ArrayMaximum(High,start,period)];
   double min = Low[ArrayMinimum(Low,start,period)];
//----
   return(max-min);
  }
//+------------------------------------------------------------------+   
//| AML indicator initialization function                            | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчета данных
   Fractal2=int(2*Fractal);
   min_rates_1=int(MathMax(Fractal+Lag,Fractal2));
   min_rates_total=min_rates_1+1+int(std_period);
   

//---- Инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;

//---- Распределение памяти под массивы переменных  
   ArrayResize(dAML,std_period);

//---- Инициализация переменных
   LagLagPoint=Lag*Lag*_Point;
   size=int(Lag+1);

//---- Распределение памяти под массивы переменных  
   ArrayResize(Count,size);
   ArrayResize(Smooth,size);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,AMLBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(AMLBuffer,true);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorAMLBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorAMLBuffer,true);

//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- превращение динамического массива BearsBuffer в индикаторный буфер
   SetIndexBuffer(2,BearsBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BearsBuffer,true);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);

//---- превращение динамического массива BullsBuffer в индикаторный буфер
   SetIndexBuffer(3,BullsBuffer,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BullsBuffer,true);
//---- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"AML(",Fractal,", ",Lag,", ",Shift,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| AML iteration function                                           | 
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
   if(rates_total<min_rates_total) return(0);

//---- Объявление переменных с плавающей точкой  
   double SMAdif,Sum,StDev,dstd,BEARS,BULLS,Filter;
//---- Объявление целых переменных и получение уже посчитанных баров
   int limit,bar;
   
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);

//---- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_1-1; // стартовый номер для расчёта всех баров
      bar=limit;
      double price=(high[bar]+low[bar]+2*open[bar]+2*close[bar])/6;
      //---- Инициализация массивов переменных
      ArrayInitialize(Smooth,price);
      ArrayInitialize(Count,0.0);
      AMLBuffer[bar+1]=price;
      ColorAMLBuffer[bar+1]=0;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      double R1=Range(Fractal,bar,high,low)/Fractal;
      double R2=Range(Fractal,bar+Fractal,high,low)/Fractal;
      double R3=Range(Fractal2,bar,high,low)/Fractal2;

      double dim=0;
      if(R1+R2>0 && R3>0) dim=(MathLog(R1+R2)-MathLog(R3))*1.44269504088896;

      double alpha=MathExp(-Lag*(dim-1.0));
      alpha=MathMin(alpha,1.0);
      alpha=MathMax(alpha,0.01);

      double price=(high[bar]+low[bar]+2*open[bar]+2*close[bar])/6;
      Smooth[Count[0]]=alpha*price+(1.0-alpha)*Smooth[Count[1]];

      if(MathAbs(Smooth[Count[0]]-Smooth[Count[Lag]])>=LagLagPoint) AMLBuffer[bar]=Smooth[Count[0]];
      else AMLBuffer[bar]=AMLBuffer[bar+1];
      AMLBuffer[bar]+=PriceShift;

      if(bar) Recount_ArrayZeroPos(Count,size);
     }

//---- корректировка значения переменной limit
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров

//---- Основной цикл раскраски сигнальной линии
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ColorAMLBuffer[bar]=0;
      if(AMLBuffer[bar+1]<AMLBuffer[bar]) ColorAMLBuffer[bar]=1;
      if(AMLBuffer[bar+1]>AMLBuffer[bar]) ColorAMLBuffer[bar]=2;
      if(AMLBuffer[bar+1]==AMLBuffer[bar]) ColorAMLBuffer[bar]=ColorAMLBuffer[bar+1];
     }

//---- основной цикл расчёта индикатора стандартного отклонения
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- загружаем приращения индикатора в массив для промежуточных вычислений
      for(int iii=0; iii<int(std_period); iii++) dAML[iii]=AMLBuffer[bar+iii]-AMLBuffer[bar+iii+1];

      //---- находим простое среднее приращений индикатора
      Sum=0.0;
      for(int iii=0; iii<int(std_period); iii++) Sum+=dAML[iii];
      SMAdif=Sum/std_period;

      //---- находим сумму квадратов разностей приращений и среднего
      Sum=0.0;
      for(int iii=0; iii<int(std_period); iii++) Sum+=MathPow(dAML[iii]-SMAdif,2);

      //---- определяем итоговое значение среднеквадратичного отклонения StDev от приращения индикатора
      StDev=MathSqrt(Sum/std_period);

      //---- инициализация переменных
      dstd=NormalizeDouble(dAML[0],_Digits+2);
      Filter=NormalizeDouble(dK*StDev,_Digits+2);
      BEARS=0;
      BULLS=0;

      //---- вычисление индикаторных значений
      if(dstd<-Filter) BEARS=AMLBuffer[bar]; //есть нисходящий тренд
      if(dstd>+Filter) BULLS=AMLBuffer[bar]; //есть восходящий тренд

      //---- инициализация ячеек индикаторных буферов полученными значениями 
      BullsBuffer[bar]=BULLS;
      BearsBuffer[bar]=BEARS;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
