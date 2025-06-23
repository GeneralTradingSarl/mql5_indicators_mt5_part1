//+------------------------------------------------------------------+
//|                                             3D_OscilatorSign.mq5 |
//|                                   Copyright © 2005, Luis Damiani |
//|                                                                  |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2005, Luis Damiani"
//---- ссылка на сайт автора
#property link      ""
//---- номер версии индикатора
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
#property indicator_label1  "3D_Oscilator Sell"
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
#property indicator_label2 "3D_Oscilator Buy"
//+----------------------------------------------+
//|  объявление констант                         |
//+----------------------------------------------+
#define RESET  0 // Константа для возврата терминалу команды на пересчёт индикатора
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input int D1RSIPer=13;
input int D2StochPer=8;
input int D3tunnelPer=8;
input double hot=0.4;
input int sigsmooth=4;
//+----------------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double SellBuffer[];
double BuyBuffer[];
//---
double sk,sk2;
int ss,min_rates_total,ATR_Handle,RSI_Handle,CCI_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- инициализация глобальных переменных
   ss=sigsmooth;
   if(ss<2) ss=2;
   sk = 2.0 / (ss + 1.0);
   sk2=2.0/(ss*0.8+1.0);
   int ATR_Period=15;
   min_rates_total=int(D1RSIPer+D2StochPer+D2StochPer+hot+sigsmooth);
   min_rates_total=MathMax(min_rates_total,ATR_Period)+1;

//---- получение хендла индикатора
   RSI_Handle=iRSI(NULL,0,D1RSIPer,PRICE_CLOSE);
   if(RSI_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iRSI");
      return(INIT_FAILED);
     }
//---- получение хендла индикатора
   CCI_Handle=iCCI(NULL,0,D3tunnelPer,PRICE_TYPICAL);
   if(CCI_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора iCCI");
      return(INIT_FAILED);
     }
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,159);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SellBuffer,true);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(BuyBuffer,true);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string short_name="3D OscillatorSign";
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
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(RSI_Handle)<rates_total
      || BarsCalculated(CCI_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      ||rates_total<min_rates_total) return(RESET);

//---- объявления локальных переменных 
   int to_copy,limit,bar;
   double rsi,maxrsi,minrsi,storsi,E3D,RSI[],CCI[],ATR[],rangrsi,ind,sig;
   static double prev_ind,prev_sig;

//---- расчёты необходимого количества копируемых данных и
//стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      to_copy=rates_total; // расчётное количество всех баров
      limit=rates_total-min_rates_total-1; // стартовый номер для расчёта всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
      to_copy=limit+D2StochPer+3; // расчётное количество всех баров
     }

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(RSI,true);
   ArraySetAsSeries(CCI,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(RSI_Handle,0,0,to_copy,RSI)<=0) return(RESET);
   to_copy=limit+1;
   if(CopyBuffer(CCI_Handle,0,0,to_copy,CCI)<=0) return(RESET);
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);

//---- основной цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      rsi=RSI[bar];
      maxrsi=rsi;
      minrsi=rsi;

      for(int iii=bar+D2StochPer; iii>=bar; iii--)
        {
         rsi=RSI[iii];
         if(rsi>maxrsi) maxrsi=rsi;
         if(rsi<minrsi) minrsi=rsi;
        }

      rangrsi=maxrsi-minrsi;
      if(rangrsi==0) storsi=0.0;
      else storsi=(rsi-minrsi)/((maxrsi-minrsi)*200)-100;
      E3D=hot*CCI[bar]+(1.0-hot)*storsi;

      ind=sk*E3D+(1.0-sk)*prev_ind;
      sig=sk2*prev_ind+(1.0-sk2)*prev_sig;

      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;

      if(ind>sig && prev_ind<prev_sig) BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
      if(ind<sig && prev_ind>prev_sig) SellBuffer[bar]=high[bar]+ATR[bar]*3/8;

      if(bar)
        {
         prev_ind=ind;
         prev_sig=sig;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
