//+---------------------------------------------------------------------+
//|                                                       CCI_Chart.mq5 | 
//|                                Copyright © 2015, Yuriy Tokman (YTG) |
//|                                                  http://ytg.com.ua/ |
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2015, Yuriy Tokman (YTG)"
#property link      "http://ytg.com.ua/"
#property description "Индикатор CCI на ценовом графике"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- количество индикаторных буферов 4
#property indicator_buffers 4 
//---- использовано всего три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//|  Параметры отрисовки индикатора  CCI Cloud   |
//+----------------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветов облака индикатора использованы
#property indicator_color1  clrLavender
//---- отображение метки индикатора
#property indicator_label1  "CCI Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора XMA          |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета линии индикатора использован цвет DeepPink
#property indicator_color2  clrDeepPink
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение метки индикатора
#property indicator_label2  "XMA"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора CCI          |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета линии индикатора использован цвет Green
#property indicator_color3  clrGreen
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение метки индикатора
#property indicator_label3  "CCI"
//+----------------------------------------------+
//|  Объявление констант                         |
//+----------------------------------------------+
#define RESET 0                // Константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1;
//+----------------------------------------------+
//|  Объявление перечислений                     |
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
//|  Объявление перечислений                     |
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
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint PeriodCCI=14;                              // Период индикатора CCI
input Smooth_Method XMA_Method=MODE_SMMA;             // Метод усреднения
input uint XLength=12;                                // Глубина  усреднения
input int XPhase=15;                                  // Параметр сглаживания
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- для VIDIA это период CMO, для AMA это период медленной скользящей
input double Dev=1.0;                                 // Девиация ширины канала
input ENUM_APPLIED_PRICE  Applied_price=PRICE_CLOSE;  // Тип цены или handle
input int  Level_CCI_UP = 100;                        // Уровень перекупленности
input int  Level_CCI_DN = -100;                       // Уровень перепроданности
input int Shift=0;                                    // Сдвиг индикатора по горизонтали в барах  
//+----------------------------------------------+
//---- объявление динамических массивов, которые в дальнейшем
//---- будут использованы в качестве индикаторных буферов
double Line1Buffer[];
double Line2Buffer[];
double Line3Buffer[];
double Line4Buffer[];
//----
double dLevel_CCI_UP,dLevel_CCI_DN;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total,min_rates_1;
//--- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_1=int(PeriodCCI);
   min_rates_total=min_rates_1+GetStartBars(XMA_Method,XLength,XPhase);
//----
   dLevel_CCI_UP=Level_CCI_UP*_Point*Dev;
   dLevel_CCI_DN=Level_CCI_DN*_Point*Dev;
//--- получение хендла индикатора CCI
   Ind_Handle=iCCI(Symbol(),NULL,PeriodCCI,Applied_price);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print("Не удалось получить хендл индикатора CCI");
      return(INIT_FAILED);
     }
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,Line1Buffer,INDICATOR_DATA);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,Line2Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,Line3Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 2 на min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,Line4Buffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали на Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора 3 на min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);

//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(Line1Buffer,true);
   ArraySetAsSeries(Line2Buffer,true);
   ArraySetAsSeries(Line3Buffer,true);
   ArraySetAsSeries(Line4Buffer,true);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"F_CCI(",PeriodCCI,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   if(BarsCalculated(Ind_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//---- Объявление переменных с плавающей точкой  
   double price,xma,CCI[];
//---- Объявление целочисленных переменных и получение уже посчитанных баров
   int to_copy,limit,bar,maxbar=rates_total-1-min_rates_1;
//---- расчет стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=maxbar; // стартовый номер для расчета всех баров
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
//----
   to_copy=limit+1;
//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(Ind_Handle,MAIN_LINE,0,to_copy,CCI)<=0) return(RESET);
//---- индексация элементов в массиве как в таймсерии
   ArraySetAsSeries(CCI,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(close,true);
//---- Основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      price=PriceSeries(Applied_price,bar,open,low,high,close);
      xma=XMA1.XMASeries(maxbar,prev_calculated,rates_total,XMA_Method,XPhase,XLength,price,bar,true);
      Line3Buffer[bar]=xma;
      Line4Buffer[bar]=xma+Dev*CCI[bar]*_Point;
      Line1Buffer[bar]=xma+dLevel_CCI_UP;
      Line2Buffer[bar]=xma+dLevel_CCI_DN;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
