//+---------------------------------------------------------------------+
//|                                         ColorXMA_Ishimoku_StDev.mq5 | 
//|                                           Copyright © 2010, ellizii | 
//|                                                                     | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2010, ellizii"
#property link ""
#property description "Ishimoku XMA StDev"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 1
#property indicator_buffers 1 
//---- использовано всего 1 графическое построение
#property indicator_plots   1  
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- для расчёта и отрисовки индикатора использовано шесть буферов
#property indicator_buffers 6
//---- использовано всего пять графических построений
#property indicator_plots   5
//+----------------------------------------------+
//|  Параметры отрисовки линии индикатора        |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_COLOR_LINE
//---- в качестве цветов трёхцветной линии использованы
#property indicator_color1  clrMagenta,clrGray,clrBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "XMA_Ishimoku"
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
//---- в качестве цвета бычьего индикатора использован салатовый цвет
#property indicator_color3  clrLime
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
//---- в качестве цвета бычьего индикатора использован салатовый цвет
#property indicator_color5  clrLime
//---- толщина линии индикатора 5 равна 4
#property indicator_width5  4
//---- отображение бычей метки индикатора
#property indicator_label5  "Up_Signal 2"

//+----------------------------------------------+
//|  Описание классов усреднений                 |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- объявление переменных классов CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1;
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum MODE_PRICE //Тип константы
  {
   OPEN = 0,     //По ценам открытия
   LOW,          //По минимумам
   HIGH,         //По максимумам
   CLOSE         //По ценам закрытия
  };
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
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
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
input uint Up_period=3; //период, используемый для вычисления наивысшего значения цены
input uint Dn_period=3; //период, используеммый для вычисления наинизшего значения цены
//---- 
input MODE_PRICE Up_mode=HIGH;  //таймсерия для поиска максимумов 
input MODE_PRICE Dn_mode=LOW;   //таймсерия для поиска минимумов 
//---- 
input Smooth_Method XMA_Method=MODE_SMA_; //метод усреднения
input int XLength=8; //глубина сглаживания                    
input int XPhase=15; //параметр усреднения,
                     //для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
// Для VIDIA это период CMO, для AMA это период медленной скользящей
//---- 
input double dK1=1.5;  //коэффициент 1 для квадратичного фильтра
input double dK2=2.5;  //коэффициент 2 для квадратичного фильтра
input uint std_period=9; //период квадратичного фильтра
input int Shift=0; // сдвиг индикатора по горизонтали в барах
input int PriceShift=0; // cдвиг индикатора по вертикали в пунктах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double ExtLineBuffer[],ColorExtLineBuffer[];
double BearsBuffer1[],BullsBuffer1[];
double BearsBuffer2[],BullsBuffer2[];
//---- Объявление переменной значения вертикального сдвига мувинга
double dPriceShift;
double dXMa[];
//---- Объявление целых переменных начала отсчёта данных
int StartBars,StartBars1;
//+------------------------------------------------------------------+   
//| Ishimoku XMA indicator initialization function                   | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных

   StartBars1=int(MathMax(Up_period,Dn_period));
   StartBars=StartBars1+GetStartBars(XMA_Method,XLength,XPhase)+int(std_period);
//---- Распределение памяти под массивы переменных  
   ArrayResize(dXMa,std_period);

//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("XLength", XLength);
   XMA1.XMAPhaseCheck("XPhase", XPhase, XMA_Method);

//---- Инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;

//---- превращение динамического массива ExtLineBuffer в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtLineBuffer,true);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorExtLineBuffer,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorExtLineBuffer,true);

//---- превращение динамического массива BearsBuffer в индикаторный буфер
   SetIndexBuffer(2,BearsBuffer1,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BearsBuffer1,true);

//---- превращение динамического массива BullsBuffer в индикаторный буфер
   SetIndexBuffer(3,BullsBuffer1,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,StartBars);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BullsBuffer1,true);

//---- превращение динамического массива BearsBuffer в индикаторный буфер
   SetIndexBuffer(4,BearsBuffer2,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,StartBars);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(3,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BearsBuffer2,true);

//---- превращение динамического массива BullsBuffer в индикаторный буфер
   SetIndexBuffer(5,BullsBuffer2,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,StartBars);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(4,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BullsBuffer2,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth=XMA1.GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"Ishimoku XMA(",XLength,", ",XPhase,", ",Smooth,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+
//| Поиск максимумов                                                 |
//+------------------------------------------------------------------+
int FindMaximum
(
 const double &Open[],
 const double &High[],
 const double &Low[],
 const double &Close[],
 MODE_PRICE Mode,
 uint index,
 uint period
 )
// FindMaximum(open,high,low,close,Up_mode,bar,Up_period)
  {
//----
   int max=0;
   int Mode_=int(Mode);

   switch(Mode_)
     {
      case OPEN: max=ArrayMaximum(Open,index,period); break;
      case LOW: max=ArrayMaximum(Low,index,period); break;
      case HIGH: max=ArrayMaximum(High,index,period); break;
      case CLOSE: max=ArrayMaximum(Close,index,period); break;
     }

//----
   return(max);
  }
//+------------------------------------------------------------------+
//| Поиск минимумов                                                  |
//+------------------------------------------------------------------+
int FindMinimum
(
 const double &Open[],
 const double &High[],
 const double &Low[],
 const double &Close[],
 MODE_PRICE Mode,
 uint index,
 uint period
 )
// FindMinimum(open,high,low,close,Dn_mode,bar,Dn_period)
  {
//----
   int min=0;
   int Mode_=int(Mode);

   switch(Mode_)
     {
      case OPEN: min=ArrayMinimum(Open,index,period); break;
      case LOW: min=ArrayMinimum(Low,index,period); break;
      case HIGH: min=ArrayMinimum(High,index,period); break;
      case CLOSE: min=ArrayMinimum(Close,index,period); break;
     }

//----
   return(min);
  }
//+------------------------------------------------------------------+ 
//| Ishimoku XMA iteration function                                  | 
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
   if(rates_total<StartBars) return(0);

//---- Объявление переменных с плавающей точкой  
   double ish_Up,ish_Dn,xma;
   double SMAdif,Sum,StDev,dstd,BEARS1,BULLS1,BEARS2,BULLS2,Filter1,Filter2;
//---- Объявление целых переменных
   int limit,maxbar,clr;

   maxbar=rates_total-1-StartBars1;
//---- расчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
      limit=maxbar; // стартовый номер для расчёта всех баров
   else limit=rates_total-prev_calculated;  // стартовый номер для расчёта только новых баров

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);

//---- основной цикл расчёта индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ish_Up=high[FindMaximum(open,high,low,close,Up_mode,bar,Up_period)];
      ish_Dn=low[FindMinimum(open,high,low,close,Dn_mode,bar,Dn_period)];
      ExtLineBuffer[bar]=XMA1.XMASeries(maxbar,prev_calculated,rates_total,XMA_Method,XPhase,XLength,(ish_Up+ish_Dn)/2,bar,true)+PriceShift;
     }
//---- пересчёт стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      limit--;

//---- Основной цикл раскраски сигнальной линии
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      clr=1;
      if(ExtLineBuffer[bar+1]<ExtLineBuffer[bar]) clr=2;
      if(ExtLineBuffer[bar+1]>ExtLineBuffer[bar]) clr=0;
      ColorExtLineBuffer[bar]=clr;
     }

//---- пересчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      limit=rates_total-1-StartBars;
//---- основной цикл расчёта индикатора стандартных отклонений
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- загружаем приращения индикатора в массив для промежуточных вычислений
      for(int iii=0; iii<int(std_period); iii++) dXMa[iii]=ExtLineBuffer[bar+iii]-ExtLineBuffer[bar+iii+1];

      //---- находим простое среднее приращений индикатора
      Sum=0.0;
      for(int iii=0; iii<int(std_period); iii++) Sum+=dXMa[iii];
      SMAdif=Sum/std_period;

      //---- находим сумму квадратов разностей приращений и среднего
      Sum=0.0;
      for(int iii=0; iii<int(std_period); iii++) Sum+=MathPow(dXMa[iii]-SMAdif,2);

      //---- определяем итоговое значение среднеквадратичного отклонения StDev от приращения индикатора
      StDev=MathSqrt(Sum/std_period);

      //---- инициализация переменных
      dstd=NormalizeDouble(dXMa[0],_Digits+2);
      Filter1=NormalizeDouble(dK1*StDev,_Digits+2);
      Filter2=NormalizeDouble(dK2*StDev,_Digits+2);
      BEARS1=EMPTY_VALUE;
      BULLS1=EMPTY_VALUE;
      BEARS2=EMPTY_VALUE;
      BULLS2=EMPTY_VALUE;
      xma=ExtLineBuffer[bar];

      //---- вычисление индикаторных значений
      if(dstd<-Filter1 && dstd>=-Filter2) BEARS1=xma; //есть нисходящий тренд
      if(dstd<-Filter2) BEARS2=xma; //есть нисходящий тренд
      if(dstd>+Filter1 && dstd<=+Filter2) BULLS1=xma; //есть восходящий тренд
      if(dstd>+Filter2) BULLS2=xma; //есть восходящий тренд

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
