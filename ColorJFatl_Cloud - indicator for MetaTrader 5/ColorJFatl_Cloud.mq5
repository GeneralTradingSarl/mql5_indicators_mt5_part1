//+---------------------------------------------------------------------+
//|                                                ColorJFatl_Cloud.mq5 | 
//|                                  Copyright © 2016, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"

//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- количество индикаторных буферов 6
#property indicator_buffers 6 
//---- использовано всего три графических построения
#property indicator_plots   3
//+------------------------------------------------+
//|  Параметры отрисовки фона                      |
//+------------------------------------------------+
//---- отрисовка фона в облачном виде
#property indicator_type1   DRAW_FILLING
#property indicator_type2   DRAW_FILLING
//---- выбор цветов фона
#property indicator_color1  clrPaleTurquoise
#property indicator_color2  clrThistle
//---- отображение меток
#property indicator_label1  "Upper Cloud"
#property indicator_label2  "Lower Cloud"
//+------------------------------------------------+
//|  Параметры отрисовки индикатора                |
//+------------------------------------------------+
//---- отрисовка индикатора в виде многоцветной линии
#property indicator_type3   DRAW_COLOR_LINE
//---- в качестве цветов трехцветной линии использованы
#property indicator_color3  clrMagenta,clrGray,clrGold
//---- линия индикатора - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 5
#property indicator_width3  5
//---- отображение метки индикатора
#property indicator_label3  "JFATL"
//+------------------------------------------------+
//|  объявление перечислений                       |
//+------------------------------------------------+
enum Applied_price_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPL_,         //PRICE_SIMPL_
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+------------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                  |
//+------------------------------------------------+
input int JLength=5; // глубина JMA сглаживания                   
input int JPhase=-100; // параметр JMA сглаживания,
//---- изменяющийся в пределах -100 ... +100,
//---- влияет на качество переходного процесса;
input Applied_price_ IPC=PRICE_CLOSE_;//ценовая константа
input int FATLShift=0; // сдвиг Фатла по горизонтали в барах
input int PriceFATLShift=0; // cдвиг Фатла по вертикали в пунктах
input uint Dev=20; // Девиация заливки фоном
//+------------------------------------------------+

//---- объявление и инициализация переменной для хранения количества расчётных баров
int FATLPeriod=39;
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double LineBuffer[];
double ColorLineBuffer[];

double UpCloudBuffer1[],UpCloudBuffer2[];
double DnCloudBuffer1[],DnCloudBuffer2[];

//---- Объявление целых переменных начала отсчета данных
int min_rates_total,fstart,FATLSize;
double dPriceFATLShift;
//+------------------------------------------------+
//| Инициализация коэффициентов цифрового фильтра  |
//+------------------------------------------------+
double dFATLTable[]=
  {
   +0.4360409450, +0.3658689069, +0.2460452079, +0.1104506886,
   -0.0054034585, -0.0760367731, -0.0933058722, -0.0670110374,
   -0.0190795053, +0.0259609206, +0.0502044896, +0.0477818607,
   +0.0249252327, -0.0047706151, -0.0272432537, -0.0338917071,
   -0.0244141482, -0.0055774838, +0.0128149838, +0.0226522218,
   +0.0208778257, +0.0100299086, -0.0036771622, -0.0136744850,
   -0.0160483392, -0.0108597376, -0.0016060704, +0.0069480557,
   +0.0110573605, +0.0095711419, +0.0040444064, -0.0023824623,
   -0.0067093714, -0.0072003400, -0.0047717710, +0.0005541115,
   +0.0007860160, +0.0130129076, +0.0040364019
  };
//+------------------------------------------------------------------+
// Описание функции iPriceSeries()                                   |
// Описание функции iPriceSeriesAlert()                              |
// Описание класса CJJMA                                             |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh>  
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных 
   FATLSize=ArraySize(dFATLTable);
   min_rates_total=FATLSize+30;
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"_Cloud(",JLength," ,",JPhase,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- Инициализация сдвига по вертикали
   dPriceFATLShift=_Point*PriceFATLShift;
//---- объявление переменной класса CJJMA из файла JJMASeries_Cls.mqh
   CJJMA JMA;
//---- установка алертов на недопустимые значения внешних переменных
   JMA.JJMALengthCheck("JLength", JLength);
   JMA.JJMAPhaseCheck("JPhase", JPhase);  
//---- превращение динамического массива в индикаторный буфер   
   SetIndexBuffer(0,UpCloudBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,UpCloudBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,DnCloudBuffer1,INDICATOR_DATA);
   SetIndexBuffer(3,DnCloudBuffer2,INDICATOR_DATA);
   SetIndexBuffer(4,LineBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(5,ColorLineBuffer,INDICATOR_COLOR_INDEX);
   
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,FATLShift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,FATLShift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   
//---- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,FATLShift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
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
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);

//---- объявления локальных переменных 
   int first,bar,clr;
   double jfatl,FATL;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=FATLPeriod-1; // стартовый номер для расчёта всех баров
      fstart=first;
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- объявление переменной класса CJJMA из файла JJMASeries_Cls.mqh
   static CJJMA JMA;

//---- основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- формула для фильтра FATL
      FATL=0.0;
      for(int iii=0; iii<FATLSize; iii++) FATL+=dFATLTable[iii]*PriceSeries(IPC,bar-iii,open,low,high,close);
      jfatl=JMA.JJMASeries(fstart,prev_calculated,rates_total,0,JPhase,JLength,FATL,bar,false);
      LineBuffer[bar]=UpCloudBuffer2[bar]=DnCloudBuffer1[bar]=jfatl+dPriceFATLShift;     
      UpCloudBuffer1[bar]=LineBuffer[bar]*Dev;
      DnCloudBuffer2[bar]=LineBuffer[bar]/Dev;
     }

//---- пересчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first++;

//---- Основной цикл раскраски сигнальной линии
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      clr=1;
      if(LineBuffer[bar-1]<LineBuffer[bar]) clr=2;
      if(LineBuffer[bar-1]>LineBuffer[bar]) clr=0;
      ColorLineBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
