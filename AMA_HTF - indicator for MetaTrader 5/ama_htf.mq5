//+------------------------------------------------------------------+ 
//|                                                      AMA_HTF.mq5 | 
//|                               Copyright © 2016, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//--- номер версии индикатора
#property version   "1.00"
//--- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использован один буфер
#property indicator_buffers 1
//--- использовано одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0                    // константа для возврата терминалу команды на пересчет индикатора
#define INDICATOR_NAME "AMA"       // константа для имени индикатора
//+----------------------------------------------+
//| Параметры отрисовки индикатора               |
//+----------------------------------------------+
//--- отрисовка индикатора 1 в виде линии
#property indicator_type1   DRAW_LINE
//--- в качестве цвета бычей линии индикатора использован DodgerBlue цвет
#property indicator_color1  clrDodgerBlue
//--- линия индикатора 1 - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//--- толщина линии индикатора 1 равна 3
#property indicator_width1  3
//--- отображение бычей метки индикатора
#property indicator_label1  INDICATOR_NAME
//+-------------------------------------+
//| Входные параметры индикатора        |
//+-------------------------------------+ 
input ENUM_TIMEFRAMES TimeFrame=PERIOD_H4;       // Период графика
input int ama_period=9;                          // Период AMA
input int fast_ma_period=2;                      // Период быстрой скользящей
input int slow_ma_period=30;                     // Период медленной скользящей
input ENUM_APPLIED_PRICE   AMAPrice=PRICE_CLOSE; // Ценовая константа
input int                  Shift=0;              // Сдвиг индикатора по горизонтали в барах
//+-------------------------------------+
//--- объявление динамических массивов, которые в дальнейшем
//--- будут использованы в качестве индикаторных буферов
double IndBuffer[];
//--- объявление строковых переменных
string Symbol_,Word;
//--- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//--- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle;
//+------------------------------------------------------------------+
//| Получение таймфрейма в виде строки                               |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {return(StringSubstr(EnumToString(timeframe),7,-1));}
//+------------------------------------------------------------------+
//| Получение цены в виде строки                                     |
//+------------------------------------------------------------------+
string GetStringPrice(ENUM_APPLIED_PRICE price)
  {return(StringSubstr(EnumToString(price),6,-1));}
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
//--- проверка периодов графиков на корректность
   if(TimeFrame<Period() && TimeFrame!=PERIOD_CURRENT)
     {
      Print("Период графика для индикатора JFatl не может быть меньше периода текущего графика");
      return(INIT_FAILED);
     }
//--- инициализация переменных 
   min_rates_total=2;
   Symbol_=Symbol();
   Word=INDICATOR_NAME+" индикатор: "+Symbol_+StringSubstr(EnumToString(_Period),7,-1);
//--- получение хендла индикатора AMA
   Ind_Handle=iAMA(Symbol_,TimeFrame,ama_period,fast_ma_period,slow_ma_period,0,AMAPrice);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора AMA");
      return(INIT_FAILED);
     }
//--- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//--- осуществление сдвига начала отсчета отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(IndBuffer,true);
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   string shortname;
   StringConcatenate(shortname,INDICATOR_NAME,"(",
                     GetStringTimeframe(TimeFrame)," ,",ama_period," ,",fast_ma_period," ,",slow_ma_period," ,",GetStringPrice(AMAPrice),")");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+  
//| Custom iteration function                                        | 
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
//--- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);
//--- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(time,true);
//--- основной цикл расчета индикатора
   if(!CountIndicator(0,NULL,TimeFrame,Ind_Handle,0,IndBuffer,time,rates_total,prev_calculated,min_rates_total)) return(RESET);
//---     
   return(rates_total);
  }
//---
#define SIZE 1 // константа для количества вызовов функции CountLine
//+------------------------------------------------------------------+
//| CountLine                                                        |
//+------------------------------------------------------------------+
bool CountIndicator(uint     Numb,            // номер функции CountLine по списку в коде индикатора (стартовый номер - 0)
                    string   Symb,            // символ графика
                    ENUM_TIMEFRAMES TFrame,   // период графика
                    int      IndHandle,       // хендл обрабатываемого индикатора
                    uint     BuffNumb,        // номер буфера обрабатываемого индикатора
                    double&  IndBuf[],        // приемный буфер индикатора
                    const datetime& iTime[],  // таймсерия времени
                    const int Rates_Total,    // количество истории в барах на текущем тике
                    const int Prev_Calculated,// количество истории в барах на предыдущем тике
                    const int Min_Rates_Total)// минимальное количество истории в барах для расчета
  {
//---
   static int LastCountBar[SIZE];
   datetime IndTime[1];
   int limit;
//--- расчеты необходимого количества копируемых данных
//--- и стартового номера limit для цикла пересчета баров
   if(Prev_Calculated>Rates_Total || Prev_Calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=Rates_Total-Min_Rates_Total-1; // стартовый номер для расчета всех баров
      LastCountBar[Numb]=limit;
     }
   else limit=LastCountBar[Numb]+Rates_Total-Prev_Calculated; // стартовый номер для расчета новых баров 
//--- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //--- обнулим содержимое индикаторных буферов до расчета
      IndBuf[bar]=0.0;
      //--- копируем вновь появившиеся данные в массив IndTime
      if(CopyTime(Symbol_,TimeFrame,iTime[bar],1,IndTime)<=0) return(RESET);
      //---
      if(iTime[bar]>=IndTime[0] && iTime[bar+1]<IndTime[0])
        {
         LastCountBar[Numb]=bar;
         double Arr[1];
         //--- копируем вновь появившиеся данные в массив Arr
         if(CopyBuffer(IndHandle,BuffNumb,iTime[bar],1,Arr)<=0) return(RESET);
         IndBuf[bar]=Arr[0];
        }
      else IndBuf[bar]=IndBuf[bar+1];
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
