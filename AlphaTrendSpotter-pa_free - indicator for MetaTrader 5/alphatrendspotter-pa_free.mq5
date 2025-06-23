//+------------------------------------------------------------------+
//|                                    AlphaTrendSpotter-pa_free.mq5 |               
//|             Copyright © 2015, Andy Ismail - All rights reserved! |
//|                                            http://fbsbroker.com/ |
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2015, Andy Ismail"
//--- ссылка на сайт автора
#property link      "http://fbsbroker.com"
//--- номер версии индикатора
#property version   "1.00"
#property description   "Alpha Trend Spotter Price Action"
#property description   "Suplement for Alpha Trend Spotter Indicator"
#property description   "Suitable for 5M to above timeframe"
#property description   "Suitable for 5 minutes Binary Option"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использовано два буфера
#property indicator_buffers 2
//--- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Параметры отрисовки медвежьего индикатора    |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//--- в качестве цвета медвежьей линии индикатора использован розовый цвет
#property indicator_color1  clrPink
//--- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//--- отображение медвежьей метки индикатора
#property indicator_label1  "AlphaTrendSpotter-pa_free Sell"
//+----------------------------------------------+
//| Параметры отрисовки бычьего индикатора       |
//+----------------------------------------------+
//--- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//--- в качестве цвета бычьей линии индикатора использован зеленый цвет
#property indicator_color2  clrLime
//--- толщина линии индикатора 2 равна 4
#property indicator_width2  4
//--- отображение бычьей метки индикатора
#property indicator_label2 "AlphaTrendSpotter-pa_free Buy"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint iPeriod=3;
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double SellBuffer[];
double BuyBuffer[];
//---
int ATR_Handle,min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация глобальных переменных 
   int ATR_Period=15;
   min_rates_total=int(iPeriod+iPeriod);
   min_rates_total=int(MathMax(min_rates_total,ATR_Period))+1;
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,234);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);
//--- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон 
   string short_name="AlphaTrendSpotter-pa_free";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---   
   return(INIT_SUCCEEDED);
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
//--- проверка количества баров на достаточность для расчета
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);
//--- объявления локальных переменных 
   int to_copy,limit,bar;
   double ATR[],CandleOpen,CandleOpen1,CandleHigh,CandleHigh1,CandleLow,CandleLow1;
//--- расчеты необходимого количества копируемых данных и
//--- стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
   to_copy=limit+1;
//--- копируем вновь появившиеся данные в массив ATR[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      CandleHigh=high[ArrayMaximum(high,bar,iPeriod)];
      CandleLow=low[ArrayMinimum(low,bar,iPeriod)];
      CandleOpen=open[bar];
      CandleHigh1=high[ArrayMaximum(high,bar+iPeriod,iPeriod)];
      CandleLow1=low[ArrayMinimum(low,bar+iPeriod,iPeriod)];
      CandleOpen1=open[bar+iPeriod];
      //---
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      //---
      if(CandleLow<CandleLow1  &&  CandleOpen>CandleHigh1) BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
      if(CandleHigh>CandleHigh1 && CandleOpen<CandleLow1) SellBuffer[bar]=high[bar]+ATR[bar]*3/8;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
