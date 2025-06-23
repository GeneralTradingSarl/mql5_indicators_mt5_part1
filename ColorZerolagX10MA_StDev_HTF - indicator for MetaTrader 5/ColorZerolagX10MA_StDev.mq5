//+---------------------------------------------------------------------+
//|                                         ColorZerolagX10MA_StDev.mq5 | 
//|                                  Copyright © 2015, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.03"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано шесть буферов
#property indicator_buffers 6
//---- использовано всего пять графических построений
#property indicator_plots   5
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде многоцветной линии
#property indicator_type1   DRAW_COLOR_LINE
//---- в качестве цветов трехцветной линии использованы
#property indicator_color1  clrRed,clrGray,clrTeal
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "ColorZerolagX10MA"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета медвежьего индикатора использован красный цвет
#property indicator_color2  clrRed
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение медвежьей метки индикатора
#property indicator_label2  "Dn_Signal 1"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде символа
#property indicator_type3   DRAW_ARROW
//---- в качестве цвета бычьего индикатора использован аквамариновый цвет
#property indicator_color3  clrAqua
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение бычей метки индикатора
#property indicator_label3  "Up_Signal 1"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде символа
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета медвежьего индикатора использован красный цвет
#property indicator_color4  clrRed
//---- толщина линии индикатора 4 равна 4
#property indicator_width4  4
//---- отображение медвежьей метки индикатора
#property indicator_label4  "Dn_Signal 2"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде символа
#property indicator_type5   DRAW_ARROW
//---- в качестве цвета бычьего индикатора использован аквамариновый цвет
#property indicator_color5  clrAqua
//---- толщина линии индикатора 5 равна 4
#property indicator_width5  4
//---- отображение бычей метки индикатора
#property indicator_label5  "Up_Signal 2"
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA[11];
//+----------------------------------------------+
//|  объявление перечислений                     |
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
//|  объявление перечислений                     |
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
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input Smooth_Method XMA_Method=MODE_JJMA; //Метод усреднения 
input uint Length1=3; //Глубина усреднения 1
input double Factor1=0.1;
input uint Length2=5; //Глубина усреднения 2
input double Factor2=0.1;                    
input uint Length3=7; //Глубина усреднения 3
input double Factor3=0.1;                 
input uint Length4=9; //Глубина усреднения 4 
input double Factor4=0.1;                   
input uint Length5=11; //Глубина усреднения 5 
input double Factor5=0.1;                  
input uint Length6=13; //Глубина усреднения 6
input double Factor6=0.1;               
input uint Length7=15; //Глубина усреднения 7 
input double Factor7=0.1;                
input uint Length8=17; //Глубина усреднения 8
input double Factor8=0.1;                 
input uint Length9=21; //Глубина усреднения 9
input double Factor9=0.1;
input uint Length10=23; //Глубина усреднения 10 
input double Factor10=0.1;                                                    
input int XPhase=15; //Параметр усреднений,
  //для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
  // Для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method SmoothMethod=MODE_SMA_; //Метод сглаживания 
input uint Smooth=3; //Глубина сглаживания
input int SmoothPhase=15; //Параметр сглаживания,
  //для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
  // Для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_CLOSE_;//Ценовая константа
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
input double dK1=1.5;  //коэффициент 1 для квадратичного фильтра
input double dK2=2.5;  //коэффициент 2 для квадратичного фильтра
input uint std_period=9; //период квадратичного фильтра
input int PriceShift=0; // Сдвиг индикатора по вертикали в пунктах
//+----------------------------------------------+

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double IndBuffer[];
double ColorIndBuffer[];
double BearsBuffer1[],BullsBuffer1[];
double BearsBuffer2[],BullsBuffer2[];

//---- Объявление переменной значения вертикального сдвига мувинга
double dPriceShift;
double dXZLagMA[];
//---- Объявление целых переменных начала отсчета данных
int min_rates_total,min_rates_;
//+------------------------------------------------------------------+   
//| XMA indicator initialization function                            | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчета данных
   int min_rates[10];
   min_rates[0]=GetStartBars(XMA_Method,Length1,XPhase);
   min_rates[1]=GetStartBars(XMA_Method,Length2,XPhase);
   min_rates[2]=GetStartBars(XMA_Method,Length3,XPhase);
   min_rates[3]=GetStartBars(XMA_Method,Length4,XPhase);
   min_rates[4]=GetStartBars(XMA_Method,Length5,XPhase);
   min_rates[5]=GetStartBars(XMA_Method,Length6,XPhase);
   min_rates[6]=GetStartBars(XMA_Method,Length7,XPhase);
   min_rates[7]=GetStartBars(XMA_Method,Length8,XPhase);
   min_rates[8]=GetStartBars(XMA_Method,Length9,XPhase);
   min_rates[9]=GetStartBars(XMA_Method,Length10,XPhase);
   min_rates_=min_rates[ArrayMaximum(min_rates)];
   min_rates_total=min_rates_+GetStartBars(SmoothMethod,Smooth,SmoothPhase)+int(std_period);
   
//---- Инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;
//---- Распределение памяти под массивы переменных  
   ArrayResize(dXZLagMA,std_period);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorIndBuffer,INDICATOR_COLOR_INDEX);
   
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   
//---- превращение динамического массива BearsBuffer в индикаторный буфер
   SetIndexBuffer(2,BearsBuffer1,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива BullsBuffer в индикаторный буфер
   SetIndexBuffer(3,BullsBuffer1,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива BearsBuffer в индикаторный буфер
   SetIndexBuffer(4,BearsBuffer2,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(3,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива BullsBuffer в индикаторный буфер
   SetIndexBuffer(5,BullsBuffer2,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(4,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"ColorZerolagX10MA");
   
//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| XMA iteration function                                           | 
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
   double price,xma[10],zlagxma,xzlagxma;
   double SMAdif,Sum,StDev,dstd,BEARS1,BULLS1,BEARS2,BULLS2,Filter1,Filter2;
//---- Объявление целых переменных и получение уже посчитанных баров
   int first,bar;

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=0; // стартовый номер для расчета всех баров
   else first=prev_calculated-1; // стартовый номер для расчета новых баров

//---- Основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- Вызов функции PriceSeries для получения входной цены price
      price=PriceSeries(IPC,bar,open,low,high,close);
      xma[0]=XMA[0].XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,Length1,price,bar,false);
      xma[1]=XMA[1].XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,Length2,price,bar,false);
      xma[2]=XMA[2].XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,Length3,price,bar,false);
      xma[3]=XMA[3].XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,Length4,price,bar,false);
      xma[4]=XMA[4].XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,Length5,price,bar,false);
      xma[5]=XMA[5].XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,Length6,price,bar,false);
      xma[6]=XMA[6].XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,Length7,price,bar,false);
      xma[7]=XMA[7].XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,Length8,price,bar,false);
      xma[8]=XMA[8].XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,Length9,price,bar,false);
      xma[9]=XMA[9].XMASeries(0,prev_calculated,rates_total,XMA_Method,XPhase,Length10,price,bar,false);
      zlagxma=Factor1*xma[0]+Factor2*xma[1]+Factor3*xma[2]+Factor4*xma[3]+Factor5*xma[4]
      +Factor6*xma[5]+Factor7*xma[6]+Factor8*xma[7]+Factor9*xma[8]+Factor10*xma[9];
      IndBuffer[bar]=XMA[10].XMASeries(min_rates_,prev_calculated,rates_total,SmoothMethod,SmoothPhase,Smooth,zlagxma,bar,false);
      IndBuffer[bar]+=dPriceShift;
     }

//---- корректировка значения переменной first
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first=min_rates_total; // стартовый номер для расчета всех баров
           
//---- Основной цикл раскраски сигнальной линии
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      ColorIndBuffer[bar]=1;
      if(IndBuffer[bar-1]<IndBuffer[bar]) ColorIndBuffer[bar]=2;
      if(IndBuffer[bar-1]>IndBuffer[bar]) ColorIndBuffer[bar]=0;
     }

//---- пересчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first=min_rates_total;
//---- основной цикл расчёта индикатора стандартных отклонений
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- загружаем приращения индикатора в массив для промежуточных вычислений
      for(int iii=0; iii<int(std_period); iii++) dXZLagMA[iii]=IndBuffer[bar-iii]-IndBuffer[bar-iii-1];

      //---- находим простое среднее приращений индикатора
      Sum=0.0;
      for(int iii=0; iii<int(std_period); iii++) Sum+=dXZLagMA[iii];
      SMAdif=Sum/std_period;

      //---- находим сумму квадратов разностей приращений и среднего
      Sum=0.0;
      for(int iii=0; iii<int(std_period); iii++) Sum+=MathPow(dXZLagMA[iii]-SMAdif,2);

      //---- определяем итоговое значение среднеквадратичного отклонения StDev от приращения индикатора
      StDev=MathSqrt(Sum/std_period);

      //---- инициализация переменных
      dstd=NormalizeDouble(dXZLagMA[0],_Digits+2);
      Filter1=NormalizeDouble(dK1*StDev,_Digits+2);
      Filter2=NormalizeDouble(dK2*StDev,_Digits+2);
      BEARS1=EMPTY_VALUE;
      BULLS1=EMPTY_VALUE;
      BEARS2=EMPTY_VALUE;
      BULLS2=EMPTY_VALUE;
      xzlagxma=IndBuffer[bar];

      //---- вычисление индикаторных значений
      if(dstd<-Filter1 && dstd>=-Filter2) BEARS1=xzlagxma; //есть нисходящий тренд
      if(dstd<-Filter2) BEARS2=xzlagxma; //есть нисходящий тренд
      if(dstd>+Filter1 && dstd<=+Filter2) BULLS1=xzlagxma; //есть восходящий тренд
      if(dstd>+Filter2) BULLS2=xzlagxma; //есть восходящий тренд

      //---- инициализация ячеек индикаторных буферов полученными значениями 
      BullsBuffer1[bar]=BULLS1;
      BearsBuffer1[bar]=BEARS1;
      BullsBuffer2[bar]=BULLS2;
      BearsBuffer2[bar]=BEARS2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
