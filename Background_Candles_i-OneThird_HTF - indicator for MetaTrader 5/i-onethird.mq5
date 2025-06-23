//+------------------------------------------------------------------+
//|                                                   i-OneThird.mq5 |
//|                                          Copyright © 2007, RickD | 
//|                                                   www.e2e-fx.net | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, RickD"
#property link "www.e2e-fx.net"
#property description "Бычьи и медвежьи паттерны, в стиле HeikenAshi"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчета и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- в качестве индикатора использованы цветные свечи
#property indicator_type1   DRAW_COLOR_CANDLES
//---- в качестве цветов индикатора использованы
#property indicator_color1  clrTeal,clrDeepPink
//---- отображение метки индикатора
#property indicator_label1  "open;high;low;close"
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+


//+----------------------------------------------+

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//----
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- инициализация глобальных переменных 
   min_rates_total=1;

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);

//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и метка для субъокон 
   string short_name="i-OneThird";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
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

//---- объявления локальных переменных 
   int first,bar;

//---- расчет стартового номера first для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=0; // стартовый номер для расчета всех баров
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      ExtLowBuffer[bar]=0.0;
      ExtHighBuffer[bar]=0.0;
      ExtOpenBuffer[bar]=0.0;
      ExtCloseBuffer[bar]=0.0;

      double third=(high[bar]-low[bar])/3;
      //----
      if(close[bar]>high[bar]-third)
        {
         ExtLowBuffer[bar]=low[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtOpenBuffer[bar]=MathMin(open[bar],close[bar]);
         ExtCloseBuffer[bar]=MathMax(open[bar],close[bar]);
        }
      //----
      if(close[bar]<low[bar]+third)
        {
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
         ExtOpenBuffer[bar]=MathMax(open[bar],close[bar]);
         ExtCloseBuffer[bar]=MathMin(open[bar],close[bar]);
        }

      //--- Раскрашивание свечей
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar]) ExtColorBuffer[bar]=0.0;
      else ExtColorBuffer[bar]=1.0;

     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
