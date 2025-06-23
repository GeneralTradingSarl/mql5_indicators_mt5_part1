//+------------------------------------------------------------------+
//|                                                  CyclePeriod.mq5 |
//|                                                                  |
//| Cycle Period                                                     |
//|                                                                  |
//| Algorithm taken from book                                        |
//|     "Cybernetics Analysis for Stock and Futures"                 |
//| by John F. Ehlers                                                |
//|                                                                  |
//|                                              contact@mqlsoft.com |
//|                                          http://www.mqlsoft.com/ |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Coded by Witold Wozniak"
//---- авторство индикатора
#property link      "www.mqlsoft.com"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчёта и отрисовки индикатора использовано два буфера
#property indicator_buffers 1
//---- использовано два графических построения
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора Cycle Period |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован красный цвет
#property indicator_color1  clrRed
//---- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора 1 равна 1
#property indicator_width1  1
//---- отображение бычей метки индикатора
#property indicator_label1  "Cycle Period"

//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input double Alpha=0.07;// коэффициент индикатора 
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double CPeriodBuffer[];
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление глобальных переменных
bool med2;
int median,median2;
double InstPeriod_,CPeriod_;
//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве кольцевых буферов
int Count1[],Count2[];
double K0,K1,K2,K3,F0,F1,F2,F3;
double Smooth[],Cycle[],Q1[],I1[],DeltaPhase[],M[],Price[];
//+------------------------------------------------------------------+
//|  пересчёт позиции самого нового элемента в массиве               |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos1
(
 int &CoArr[]// Возврат по ссылке номера текущего значения ценового ряда
 )
// Recount_ArrayZeroPos(count, Length)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=7;
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
//|  пересчёт позиции самого нового элемента в массиве               |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos2
(
 int &CoArr[]// Возврат по ссылке номера текущего значения ценового ряда
 )
// Recount_ArrayZeroPos(count, Length)
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=median;
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
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных
   K0=MathPow((1.0 - 0.5*Alpha),2);
   K1=2.0;
   K2=K1 *(1.0 - Alpha);
   K3=MathPow((1.0 - Alpha),2);
   F0=0.0962;
   F1=0.5769;
   F2=0.5;
   F3=0.08;
   median=5;
   median2=median/2;
   if(median%2==0) med2=true;
   else            med2=false;

//---- Распределение памяти под массивы переменных  
   ArrayResize(Count1,7);
   ArrayResize(Smooth,7);
   ArrayResize(Cycle,7);
   ArrayResize(Q1,7);
   ArrayResize(I1,7);
   ArrayResize(Price,7);
   ArrayResize(Count2,median);
   ArrayResize(DeltaPhase,median);
   ArrayResize(M,median);

//---- Инициализация массивов переменных
   ArrayInitialize(Smooth,0.0);
   ArrayInitialize(Cycle,0.0);
   ArrayInitialize(Q1,0.0);
   ArrayInitialize(I1,0.0);
   ArrayInitialize(Price,0.0);
   ArrayInitialize(DeltaPhase,0.0);

//---- Инициализация переменных начала отсчёта данных
   min_rates_total=median+16;

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,CPeriodBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"Cycle Period(",DoubleToString(Alpha,4),")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+2);
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
   if(rates_total<min_rates_total) return(0);

//---- объявления локальных переменных 
   int first,bar,bar0,bar1,bar2,bar3,bar4,bar6;
   double CPeriod,InstPeriod,MedianDelta,DC;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=0; // стартовый номер для расчёта всех баров
      CPeriod_=1.0;
      InstPeriod_=1.0;
      CPeriodBuffer[0]=1.0;
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- восстанавливаем значения переменных
   InstPeriod=InstPeriod_;
   CPeriod=CPeriod_;

//---- основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && bar==rates_total-1)
        {
         CPeriod_=CPeriod;
         InstPeriod_=InstPeriod;
        }

      bar0=Count1[0];
      bar1=Count1[1];
      bar2=Count1[2];
      bar3=Count1[3];
      bar4=Count1[4];
      bar6=Count1[6];

      Price[bar0]=(high[bar]+low[bar])/2.0;
      Smooth[bar0]=(Price[bar0]+2.0*Price[bar1]+2.0*Price[bar2]+Price[bar3])/6.0;

      if(bar<6) Cycle[bar0]=(Price[bar0]-2.0*Price[bar1]+Price[bar2])/4.0;
      else Cycle[bar0]=K0*(Smooth[bar0]-K1*Smooth[bar1]+Smooth[bar2])+K2*Cycle[bar1]-K3*Cycle[bar2];

      Q1[bar0]=(F0*Cycle[bar0]+F1*Cycle[bar2]-F1*Cycle[bar4]-F0*Cycle[bar6])*(F2+F3*InstPeriod);
      I1[bar0]= Cycle[Count1[3]];

      if(Q1[bar0] && Q1[bar1])
         DeltaPhase[Count2[0]]=(I1[bar0]/Q1[bar0]-I1[bar1]/Q1[bar1])/(1.0+I1[bar0]*I1[bar1]/(Q1[bar0]*Q1[bar1]));

      bar0=Count2[0];
      DeltaPhase[bar0]=MathMax(0.1,DeltaPhase[bar0]);
      DeltaPhase[bar0]=MathMin(1.1,DeltaPhase[bar0]);

      ArrayCopy(M,DeltaPhase,0,0,WHOLE_ARRAY);
      ArraySort(M);

      if(med2) MedianDelta=(M[median2]+M[median2+1])/2.0;
      else     MedianDelta=M[median2];

      if(!MedianDelta) DC=15.0;
      else             DC=6.28318/MedianDelta+0.5;

      InstPeriod=0.67*InstPeriod+0.33*DC;
      CPeriod=0.85*CPeriod+0.15*InstPeriod;
      CPeriodBuffer[bar]=CPeriod;

      if(bar<rates_total-1)
        {
         Recount_ArrayZeroPos1(Count1);
         Recount_ArrayZeroPos2(Count2);
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
