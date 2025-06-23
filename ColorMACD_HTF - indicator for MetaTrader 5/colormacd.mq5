//+---------------------------------------------------------------------+ 
//|                                                       ColorMACD.mq5 | 
//|                                  Copyright © 2011, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window 
//---- количество индикаторных буферов 4
#property indicator_buffers 4 
//---- использовано всего два графических построения
#property indicator_plots   2
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде четырехцветной гистограммы
#property indicator_type1 DRAW_COLOR_HISTOGRAM
//---- в качестве цветов четырехцветной гистограммы использованы
#property indicator_color1 clrGray,clrTeal,clrDarkViolet,clrIndianRed,clrMagenta
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1 2
//---- отображение метки индикатора
#property indicator_label1 "MACD"
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде трехцветной линии
#property indicator_type2 DRAW_COLOR_LINE
//---- в качестве цветов трехцветной линии использованы
#property indicator_color2 clrGray,clrLime,clrRed
//---- линия индикатора - штрихпунктирная кривая
#property indicator_style2 STYLE_DASHDOTDOT
//---- толщина линии индикатора равна 3
#property indicator_width2 3
//---- отображение метки сигнальной линии
#property indicator_label2  "Signal Line"
//+-----------------------------------+
//| Объявление перечислений           |
//+-----------------------------------+
enum Applied_price_      //тип константы
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
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input int Fast_MA = 12; // Период быстрой скользящей средней
input int Slow_MA = 26; // Глубина SMMA сглаживания
input ENUM_MA_METHOD MA_Method_=MODE_EMA; // Метод усреднения индикатора
input int Signal_MA=9; // Период сигнальной линии
input ENUM_MA_METHOD Signal_Method_=MODE_EMA; // Метод усреднения индикатора
input Applied_price_ AppliedPrice=PRICE_CLOSE_;// Ценовая константа
//+-----------------------------------+
//---- объявление целочисленных переменных начала отсчета данных
int start,macd_start=0;
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double MACDBuffer[],SignBuffer[],ColorMACDBuffer[],ColorSignBuffer[];
//+------------------------------------------------------------------+
//| Описание функции iPriceSeries                                    |
//| Описание класса Moving_Average                                   |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh> 
//+------------------------------------------------------------------+    
//| MACD indicator initialization function                           | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   if(MA_Method_!=MODE_EMA) macd_start=MathMax(Fast_MA,Slow_MA);
   start=macd_start+Signal_MA+1;
//---- превращение динамического массива MACDBuffer в индикаторный буфер
   SetIndexBuffer(0,MACDBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,macd_start);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"MACD");
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorMACDBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,macd_start+1);

//---- превращение динамического массива SignBuffer в индикаторный буфер
   SetIndexBuffer(2,SignBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,start);
//--- создание метки для отображения в DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"Signal SMA");
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(3,ColorSignBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,start+1);

//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"MACD( ",Fast_MA,", ",Slow_MA,", ",Signal_MA," )");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| MACD iteration function                                          | 
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
   if(rates_total<start) return(0);
//---- объявление целочисленных переменных
   int first1,first2,first3,bar;
//---- объявление переменных с плавающей точкой  
   double price,fast_ma,slow_ma;
//---- инициализация индикатора в блоке OnCalculate()
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      first1=0; // стартовый номер для расчета всех баров первого цикла
      first2=macd_start+1; // стартовый номер для расчета всех баров второго цикла
      first3=start+1; // стартовый номер для расчета всех баров третьего цикла
     }
   else // стартовый номер для расчета новых баров
     {
      first1=prev_calculated-1;
      first2=first1;
      first3=first1;
     }
//---- объявление переменных класса CMoving_Average из файла MASeries_Cls.mqh
   static CMoving_Average MA1,MA2,MA3;
//---- основной цикл расчета индикатора
   for(bar=first1; bar<rates_total; bar++)
     {
      price=PriceSeries(AppliedPrice,bar,open,low,high,close);
      fast_ma = MA1.MASeries(0,prev_calculated,rates_total,Fast_MA, MA_Method_,price,bar,false);
      slow_ma = MA2.MASeries(0,prev_calculated,rates_total,Slow_MA, MA_Method_,price,bar,false);
      MACDBuffer[bar]=fast_ma-slow_ma;
      SignBuffer[bar]=MA3.MASeries(macd_start,prev_calculated,rates_total,Signal_MA,Signal_Method_,MACDBuffer[bar],bar,false);
     }
//---- основной цикл раскраски индикатора MACD
   for(bar=first2; bar<rates_total; bar++)
     {
      int clr=0;
      //----
      if(MACDBuffer[bar]>0)
        {
         if(MACDBuffer[bar]>MACDBuffer[bar-1]) clr=1;
         if(MACDBuffer[bar]<MACDBuffer[bar-1]) clr=2;
        }
      //----
      if(MACDBuffer[bar]<0)
        {
         if(MACDBuffer[bar]<MACDBuffer[bar-1]) clr=3;
         if(MACDBuffer[bar]>MACDBuffer[bar-1]) clr=4;
        }
      ColorMACDBuffer[bar]=clr;
     }
//---- основной цикл раскраски сигнальной линии
   for(bar=first3; bar<rates_total; bar++)
     {
      int clr=0;
      if(MACDBuffer[bar]>SignBuffer[bar-1]) clr=1;
      if(MACDBuffer[bar]<SignBuffer[bar-1]) clr=2;
      ColorSignBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
