//+------------------------------------------------------------------+
//|                                       AsymmetricStochNR_Sign.mq5 | 
//|                                    Copyright © 2010,   Svinozavr | 
//+------------------------------------------------------------------+
//| Для работы индикатора файл SmoothAlgorithms.mqh                  |
//| следует положить в папку: каталог_данных_терминала\MQL5\Include  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010,   Svinozavr"
#property link ""
#property description "Asymmetric Stoch NR"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type1 DRAW_ARROW
//---- в качестве окраски индикатора использован
#property indicator_color1 clrDeepSkyBlue
//---- линия индикатора - сплошная
#property indicator_style1 STYLE_SOLID
//---- толщина линии индикатора равна 5
#property indicator_width1 5
//---- отображение метки сигнальной линии
#property indicator_label1  "Buy AsymmetricStochNR signal"
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде значка
#property indicator_type2 DRAW_ARROW
//---- в качестве окраски индикатора использован
#property indicator_color2 clrPlum
//---- линия индикатора - сплошная
#property indicator_style2 STYLE_SOLID
//---- толщина линии индикатора равна 5
#property indicator_width2 5
//---- отображение метки сигнальной линии
#property indicator_label2  "Sell AsymmetricStochNR signal"
//+----------------------------------------------+
//|  Объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA;
//+----------------------------------------------+
//|  Объявление перечислений                     |
//+----------------------------------------------+
/*enum Smooth_Method - объявлено в файле SmoothAlgorithms.mqh
  {
   MODE_SMA_,  // SMA
   MODE_EMA_,  // EMA
   MODE_SMMA_, // SMMA
   MODE_LWMA_, // LWMA
   MODE_JJMA,  // JJMA
   MODE_JurX,  // JurX
   MODE_ParMA, // ParMA
   MODE_T3,    // T3
   MODE_VIDYA, // VIDYA
   MODE_AMA,   // AMA
  }; */
//+----------------------------------------------+
//|  Входные параметры индикатора                |
//+----------------------------------------------+
input uint KperiodShort=5;                   // Период %K
input uint KperiodLong=12;                   // Период %K
input Smooth_Method DMethod=MODE_SMA_;       // Метод сглаживания сигнальной линии 
input uint Dperiod=7;                        // Период сигнальной линии %D
input int DPhase=15;                         // Параметр сглаживания сигнальной линии
input uint Slowing=3;                        // Замедление
input ENUM_STO_PRICE PriceField=STO_LOWHIGH; // Параметр выбора цен для расчета
input uint Sens=7;                           // Чувствительность в пунктах
input uint OverBought=80;                    // Уровень перекупленности в %%
input uint OverSold=20;                      // Уровень перепроданности в %%
input int Shift=0;                           // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double SignUp[];
double SignDown[];
double sens; // чувствительность в ценах
//--- объявление целочисленных переменных для хендлов индикаторов
int ATR_Handle;
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total,min_rates_stoch;
//+------------------------------------------------------------------+   
//| Asymmetric Stoch NR indicator initialization function            | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_stoch=int(MathMax(KperiodShort,KperiodLong)+Slowing);
   min_rates_total=min_rates_stoch+XMA.GetStartBars(DMethod,Dperiod,DPhase)+1;
   int ATR_Period=15;
   min_rates_total=int(MathMax(min_rates_total,ATR_Period))+1;
//--- получение хендла индикатора ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Не удалось получить хендл индикатора ATR");
      return(INIT_FAILED);
     }

//---- инициализация переменных   
   sens=Sens*_Point; // чувствительность в ценах

//---- установка алертов на недопустимые значения внешних переменных
   XMA.XMALengthCheck("Dperiod",Dperiod);
   XMA.XMALengthCheck("Dperiod",Dperiod);
   XMA.XMAPhaseCheck("DPhase",DPhase,DMethod);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,SignUp,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(SignUp,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,SignDown,INDICATOR_DATA);
//---- осуществление сдвига индикатора по горизонтали на Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- индексация элементов в буферах, как в таймсериях   
   ArraySetAsSeries(SignDown,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname,Smooth;
   Smooth=XMA.GetString_MA_Method(DMethod);
   StringConcatenate(shortname,"Asymmetric Stochastic NR(",KperiodShort,",",KperiodLong,",",Dperiod,",",Smooth,",",Slowing,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- завершение инициализации
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| Asymmetric Stoch NR iteration function                           | 
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
   if(BarsCalculated(ATR_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- объявление целочисленных переменных
   int limit,to_copy,bar,maxbar;
//---- объявление переменных   
   double ATR[],Stoch,XStoch;

//---- объявление статических переменных памяти
   static uint Kperiod0,Kperiod1;
   static double Stoch_prev,XStoch_prev;

//---- расчеты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-1-min_rates_stoch; // стартовый номер для расчета всех баров
      Kperiod0=KperiodShort;
      Kperiod1=KperiodShort;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров 
   to_copy=limit+1;

//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(ATR,true);

   maxbar=rates_total-1-min_rates_stoch;

//--- копируем вновь появившиеся данные в массивы ATR[]
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);

//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Stoch=Stoch(Kperiod0,Kperiod1,Slowing,PriceField,sens,bar,low,high,close);
      //----
      XStoch=XMA.XMASeries(maxbar,prev_calculated,rates_total,DMethod,DPhase,Dperiod,Stoch,bar,true);

      //--- переключение направления
      if(XStoch_prev>OverBought)
        { // восходящий тренд
         Kperiod0=KperiodShort;
         Kperiod1=KperiodLong;
        }

      if(XStoch_prev<OverSold)
        { // нисходящий тренд
         Kperiod0=KperiodLong;
         Kperiod1=KperiodShort;
        }
        
      SignUp[bar]=NULL;
      SignDown[bar]=NULL;
      
      if(XStoch_prev>=Stoch_prev && XStoch<Stoch) SignUp[bar]=low[bar]-ATR[bar]*3/8;
      if(Stoch_prev>=XStoch_prev && Stoch<XStoch) SignDown[bar]=high[bar]+ATR[bar]*3/8;

      if(bar)
        {
         Stoch_prev=Stoch;
         XStoch_prev=XStoch;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Расчет стохастика с шумоподавлением                              |
//+------------------------------------------------------------------+    
double Stoch(
             int Kperiod0,
             int Kperiod1,
             int Slowing_,
             int PriceField_,
             double sens_,
             int Bar,
             const double &Low[],
             const double &High[],
             const double &Close[])
  {
//----
   double max,min,c,delta,diff;

   c=0.0;
   max=0.0;
   min=0.0;
   int end=Bar+Slowing_;;

   for(int j=Bar; j<end; j++)
     {
      if(PriceField_==STO_CLOSECLOSE)
        {
         max+=Close[ArrayMaximum(Close,j,Kperiod0)];
         min+=Close[ArrayMinimum(Close,j,Kperiod1)];
        }

      if(PriceField_==STO_LOWHIGH)
        {
         max+=High[ArrayMaximum(High,j,Kperiod0)];
         min+=Low[ArrayMinimum(Low,j,Kperiod1)];
        }

      c+=Close[j];
     }

//--- шумоподавление
   sens_*=Slowing_; // приведение чувствительности в соответствие с периодом замедления
   delta=max-min;   // размах
   diff=sens-delta; // разница между порогом чувствительности и размахом

//--- если разница >0 (размах меньше порога)
   if(diff>0)
     {
      delta=sens;   // размах = порогу
      min-=diff/2;  // новое значение минимума
     }
//--- вычисление осциллятора
   if(delta) return(100*(c-min)/delta); // стохастик
//----
   return(-2);
  }
//+------------------------------------------------------------------+
