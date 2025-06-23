//+------------------------------------------------------------------+ 
//|                                           Awesome_HTF_Signal.mq5 | 
//|                               Copyright © 2015, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2015, Nikolay Kositsin"
#property link "farria@mail.redcom.ru" 
//---- номер версии индикатора
#property version   "1.60"
//+------------------------------------------------+ 
//| Параметры отрисовки индикатора                 |
//+------------------------------------------------+ 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
#property indicator_buffers 1
#property indicator_plots   1
//+------------------------------------------------+ 
//| Объявление констант                            |
//+------------------------------------------------+
#define INDICATOR_NAME      "Awesome"           // Имя индикатора
#define RESET               0                   // Константа для возврата терминалу команды на пересчет индикатора
#define NAMES_SYMBOLS_FONT  "Georgia"           // Шрифт для названия индикатора
#define SIGNAL_SYMBOLS_FONT "Wingdings 3"       // Шрифт для символа входа в позицию
#define TREND_SYMBOLS_FONT  "Wingdings"         // Шрифт для символа тренда
#define UP_SIGNAL_SYMBOL    "ж"                 // Символ для открывания long
#define DN_SIGNAL_SYMBOL    "и"                 // Символ для открывания short
#define UP_TREND_SYMBOL     "]"                 // Символ для растущего тренда
#define DN_TREND_SYMBOL     "]"                 // Символ для падающего тренда
#define BUY_SOUND           "alert.wav"         // Звуковой файл для входа в long
#define SELL_SOUND          "alert.wav"         // Звуковой файл для входа в short
#define BUY_ALERT_TEXT      "Buy signal"        // Текст алерта для входа в long
#define SELL_ALERT_TEXT     "Sell signal"       // Текст алерта для входа в short
//+------------------------------------------------+ 
//| Перечисление для индикации срабатывания уровня |
//+------------------------------------------------+ 
enum ENUM_ALERT_MODE // тип константы
  {
   OnlySound,   // только звук
   OnlyAlert    // только алерт
  };
//+------------------------------------------------+ 
//| Объявление перечислений                        |
//+------------------------------------------------+ 
enum Applied_price_ //тип константы
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
//+------------------------------------------------+ 
//| Описание класса CXMA                           |
//+------------------------------------------------+ 
#include <SmoothAlgorithms.mqh>
//+------------------------------------------------+ 
//| Объявление перечислений                        |
//+------------------------------------------------+ 
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
//+------------------------------------------------+ 
//| Входные параметры индикатора                   |
//+------------------------------------------------+ 
input string Symbol_="";                               // Финансовый актив
input ENUM_TIMEFRAMES Timeframe=PERIOD_H6;             // Таймфрейм индикатора для расчета индикатора
input Smooth_Method XMA_Method=MODE_SMA;               // Метод усреднения Awesome гистограммы
input int Fast_XMA = 5;                                // Период быстрой скользящей средней
input int Slow_XMA = 34;                               // Период медленной скользящей средней
input int XPhase = 100;                                // Параметр усреднения скользящих средних
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method Signal_Method=MODE_SMA;            // Метод усреднения сигнальной линии
input int Signal_XMA=5;                                // Период сигнальной линии
input int Signal_Phase=100;                            // Параметр сигнальной линии
//---- изменяющийся в пределах -100 ... +100,
//---- влияет на качество переходного процесса;
input Applied_price_ AppliedPrice=PRICE_CLOSE;         // Ценовая константа
//---- настройки визуального отображения индикатора
input uint SignalBar=0;                                // Номер бара для получения сигнала (0 - текущий бар)
input string Symbols_Sirname=INDICATOR_NAME"_Label_";  // Название для меток индикатора
input color Upsymbol_Color=clrDodgerBlue;              // Цвет символа роста
input color Dnsymbol_Color=clrMagenta;                 // Цвет символа падения
input color IndName_Color=clrDarkOrchid;               // Цвет названия индикатора
input uint Symbols_Size=60;                            // Размер символов сигнала
input uint Font_Size=10;                               // Размер шрифта названия индикатора
input int X_1=5;                                       // Смещение названия по горизонтали
input int Y_1=-15;                                     // Смещение названия по вертикали
input bool ShowIndName=true;                           // Отображение названия индикатора
input ENUM_BASE_CORNER  WhatCorner=CORNER_RIGHT_UPPER; // Угол расположения
input uint X_=0;                                       // Смещение по горизонтали
input uint Y_=20;                                      // Смещение по вертикали
//---- настройки алертов
input ENUM_ALERT_MODE alert_mode=OnlySound;            // Вариант индикации срабатывания
input uint AlertCount=0;                               // Количество подаваемых алертов
//+-----------------------------------+
//---- объявление целочисленных переменных для хендлов индикаторов
int Ind_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//---- объявление целочисленных переменных расположения индексов по горизонтали и вертикали
uint X_0,Yn,X_1_,Y_1_;
//---- объявление переменных для имен меток
string name0,name1,IndName,Symb;
//+------------------------------------------------------------------+
//| Получение таймфрейма в виде строки                               |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
//----
  }
//+------------------------------------------------------------------+
//|  Создание текстовой метки                                        |
//+------------------------------------------------------------------+
void CreateTLabel(long   chart_id,         // идентификатор графика
                  string name,             // имя объекта
                  int    nwin,             // индекс окна
                  ENUM_BASE_CORNER corner, // положение угла привязки
                  ENUM_ANCHOR_POINT point, // положение точки привязки
                  int    X,                // дистанция в пикселях по оси X от угла привязки
                  int    Y,                // дистанция в пикселях по оси Y от угла привязки
                  string text,             // текст
                  string textTT,           // текст всплывающей подсказки
                  color  Color,            // цвет текста
                  string Font,             // шрифт текста
                  int    Size)             // размер шрифта
  {
//----
   ObjectCreate(chart_id,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(chart_id,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,point);
   ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
   ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
   ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,textTT);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true); //объект на заднем плане
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка текстовой метки                                   |
//+------------------------------------------------------------------+
void SetTLabel(long   chart_id,         // идентификатор графика
               string name,             // имя объекта
               int    nwin,             // индекс окна
               ENUM_BASE_CORNER corner, // положение угла привязки
               ENUM_ANCHOR_POINT point, // положение точки привязки
               int    X,                // дистанция в пикселях по оси X от угла привязки
               int    Y,                // дистанция в пикселях по оси Y от угла привязки
               string text,             // текст
               string textTT,           // текст всплывающей подсказки
               color  Color,            // цвет текста
               string Font,             // шрифт текста
               int    Size)             // размер шрифта
  {
//----
   if(ObjectFind(chart_id,name)==-1)
     {
      CreateTLabel(chart_id,name,nwin,corner,point,X,Y,text,textTT,Color,Font,Size);
     }
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
      ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
     }
  }
//+------------------------------------------------------------------+    
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+  
int OnInit()
  {
   int ATR_Period=15;
//---- инициализация переменных начала отсчета данных
   min_rates_total=MathMax(GetStartBars(XMA_Method,Fast_XMA,XPhase),GetStartBars(XMA_Method,Slow_XMA,XPhase));
   min_rates_total+=GetStartBars(Signal_Method,Signal_XMA,Signal_Phase)+2;
   min_rates_total=MathMax(ATR_Period,min_rates_total+2);
   min_rates_total+=int(SignalBar);
//---- инициализация переменных
   if(Symbol_!="") Symb=Symbol_;
   else Symb=Symbol();
//----
   X_0=X_;
   Yn=Y_+5;
//----
   name0=Symbols_Sirname+"0";
   if(ShowIndName)
     {
      Y_1_=Yn+Y_1;
      X_1_=X_0+X_1;
      name1=Symbols_Sirname+"1";
      StringConcatenate(IndName,INDICATOR_NAME,"(",Symb," ",GetStringTimeframe(Timeframe),")");
     }
//---- получение хендла индикатора Awesome_Sign
   Ind_Handle=iCustom(Symb,Timeframe,"Awesome_Sign",XMA_Method,Fast_XMA,Slow_XMA,XPhase,Signal_Method,Signal_XMA,Signal_Phase,AppliedPrice);
   if(Ind_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора Awesome_Sign");
      return(INIT_FAILED);
     }
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,INDICATOR_NAME);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void Deinit()
  {
//----
   if(ObjectFind(0,name0)!=-1) ObjectDelete(0,name0);
   if(ObjectFind(0,name1)!=-1) ObjectDelete(0,name1);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   Deinit();
//----
   ChartRedraw(0);
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
   if(BarsCalculated(Ind_Handle)<min_rates_total) return(RESET);
   if(BarsCalculated(Ind_Handle)<Bars(Symb,Timeframe)) return(prev_calculated);
//---- объявление локальных переменных
   int limit,trend;
   double UpBTR[],DnBTR[];
   datetime rates_time,TIME[1];
   color Color0=clrNONE;
   string SignSymbol;
   static datetime prev_time;
   static int trend_;
   bool signal=false;
   static uint buycount=0,sellcount=0;
//---- копируем вновь появившиеся данные в массивы
   if(CopyTime(Symb,Timeframe,SignalBar,1,TIME)<=0) return(RESET);
//---- расчеты необходимого количества копируемых данных для функции CopyBuffer
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      prev_time=time[0];
      trend_=0;
     }
//----
   rates_time=TimeCurrent();
//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(Ind_Handle,0,rates_time,prev_time,DnBTR)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle,1,rates_time,prev_time,UpBTR)<=0) return(RESET);
//---- расчеты стартового номера limit для цикла пересчета баров  
   limit=ArraySize(UpBTR)-1;
   trend=trend_;
//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(DnBTR,true);
   ArraySetAsSeries(UpBTR,true);
//---- ставим счетчики алертов в исходное положение   
   if(TIME[0]!=prev_time && AlertCount)
     {
      buycount=AlertCount;
      sellcount=AlertCount;
     }
//---- основной цикл расчета индикатора
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      if(UpBTR[bar]&&UpBTR[bar]!=EMPTY_VALUE) {trend=+1; if(!bar) signal=true;}
      if(DnBTR[bar]&&DnBTR[bar]!=EMPTY_VALUE) {trend=-1; if(!bar) signal=true;}
      if(bar|| SignalBar) trend_=trend;
     }
//----
   if(trend>0)
     {
      Color0=Upsymbol_Color;
      //----
      if(signal)
        {
         SignSymbol=UP_SIGNAL_SYMBOL;
         if(buycount)
           {
            switch(alert_mode)
              {
               case OnlyAlert: Alert(IndName+": "+BUY_ALERT_TEXT); break;
               case OnlySound: PlaySound(BUY_SOUND); break;
              }
            //----
            buycount--;
           }
        }
      else SignSymbol=UP_TREND_SYMBOL;
     }
//----
   if(trend<0)
     {
      Color0=Dnsymbol_Color;
      //----
      if(signal)
        {
         SignSymbol=DN_SIGNAL_SYMBOL;
         if(sellcount)
           {
            switch(alert_mode)
              {
               case OnlyAlert: Alert(IndName+": "+SELL_ALERT_TEXT); break;
               case OnlySound: PlaySound(SELL_SOUND); break;
              }
            //----
            sellcount--;
           }
        }
      else SignSymbol=DN_TREND_SYMBOL;
     }
//----
   if(trend)
     {
      if(ShowIndName)
         SetTLabel(0,name1,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_1_,Y_1_,IndName,IndName,IndName_Color,NAMES_SYMBOLS_FONT,Font_Size);
      if(signal) SetTLabel(0,name0,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_0,Yn,SignSymbol,IndName,Color0,SIGNAL_SYMBOLS_FONT,Symbols_Size);
      else SetTLabel(0,name0,0,WhatCorner,ENUM_ANCHOR_POINT(2*WhatCorner),X_0,Yn,SignSymbol,IndName,Color0,TREND_SYMBOLS_FONT,Symbols_Size);
     }
   else Deinit();
//----
   ChartRedraw(0);
   prev_time=TIME[0];
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
