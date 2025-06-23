//+------------------------------------------------------------------+
//|                                              Didi_Index_Sign.mq5 |
//|                              Copyright © 2016, Rudinei Felipetto |
//|                                         http://www.conttinua.com |
//+------------------------------------------------------------------+
//--- авторство индикатора
#property copyright "Copyright © 2016, Rudinei Felipetto"
//--- ссылка на сайт автора
#property link      "http://www.conttinua.com"
//--- номер версии индикатора
#property version   "1.00"
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
#property indicator_color1  clrMagenta
//--- толщина линии индикатора 1 равна 4
#property indicator_width1  4
//--- отображение медвежьей метки индикатора
#property indicator_label1  "Didi_Index Sell"
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
#property indicator_label2 "Didi_Index Buy"
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint      Curta=3;
input uint      Longa=20;
input ENUM_MA_METHOD MA_Method=MODE_SMA; // Метод усреднения индикатора
input ENUM_APPLIED_PRICE MA_Price=PRICE_CLOSE;// Ценовая константа
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double SellBuffer[];
double BuyBuffer[];
//---
int K,C_Handle,L_Handle,ATR_Handle,min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- инициализация глобальных переменных 
   int ATR_Period=15;
   min_rates_total=int(MathMax(Curta,Longa));
   min_rates_total=MathMax(min_rates_total,ATR_Period)+1;
//--- получение хендла индикатора iMA Curta
   C_Handle=iMA(NULL,0,Curta,0,MA_Method,MA_Price);
   if(C_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA Curta");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора iMA Longa
   L_Handle=iMA(NULL,0,Longa,0,MA_Method,MA_Price);
   if(L_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iMA Longa");
      return(INIT_FAILED);
     }
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
   PlotIndexSetInteger(0,PLOT_ARROW,170);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,170);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);
//--- установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- имя для окон данных и метка для подокон 
   string short_name="Didi_Index_Sig";
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
   if(BarsCalculated(ATR_Handle)<rates_total
      || BarsCalculated(C_Handle)<rates_total
      || BarsCalculated(L_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);
//--- объявления локальных переменных 
   int to_copy,limit,bar;
   double trend,Cur[],Lon[],ATR[];
   static double prev_trend;
//--- расчеты необходимого количества копируемых данных и
//--- стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчета всех баров
      prev_trend=0;
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
   to_copy=limit+1;
//--- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(C_Handle,0,0,to_copy,Cur)<=0) return(RESET);
   if(CopyBuffer(L_Handle,0,0,to_copy,Lon)<=0) return(RESET);
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(Cur,true);
   ArraySetAsSeries(Lon,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      trend=Cur[bar]-Lon[bar];
      if(!trend) trend=prev_trend;
      //---
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      //---
      if(prev_trend<0 && trend>0) BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
      if(prev_trend>0 && trend<0) SellBuffer[bar]=high[bar]+ATR[bar]*3/8;
      //---
      if(bar) prev_trend=trend;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
