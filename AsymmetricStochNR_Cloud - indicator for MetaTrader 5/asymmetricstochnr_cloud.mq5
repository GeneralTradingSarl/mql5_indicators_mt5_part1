//+------------------------------------------------------------------+
//|                                      AsymmetricStochNR_Cloud.mq5 | 
//|                                    Copyright © 2010,   Svinozavr | 
//+------------------------------------------------------------------+
//| Для работы индикатора файл SmoothAlgorithms.mqh                  |
//| следует положить в папку: каталог_данных_терминала\MQL5\Include  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010,   Svinozavr"
#property link ""
#property description "Asymmetric Stoch NR"
//---- номер версии индикатора
#property version   "1.01"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 2
#property indicator_buffers 2 
//---- использовано всего одно графическое построение
#property indicator_plots   1
//+----------------------------------------------+
//|  Объявление констант                         |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветов облака
#property indicator_color1  clrDeepSkyBlue,clrPlum
//---- отображение метки индикатора
#property indicator_label1  "Asymmetric Stochastic NR"
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
//|  Объявление перечисления                     |
//+----------------------------------------------+  
enum WIDTH
  {
   Width_1=1, // 1
   Width_2,   // 2
   Width_3,   // 3
   Width_4,   // 4
   Width_5    // 5
  };
//+----------------------------------------------+
//|  Объявление перечисления                     |
//+----------------------------------------------+
enum STYLE
  {
   SOLID_,       // Сплошная линия
   DASH_,        // Штриховая линия
   DOT_,         // Пунктирная линия
   DASHDOT_,     // Штрих-пунктирная линия
   DASHDOTDOT_   // Штрих-пунктирная линия с двойными точками
  };
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
input color UpLevelsColor=clrBlue;           // Цвет уровня перекупленности
input color DnLevelsColor=clrMagenta;        // Цвет уровня перепроданности
input STYLE Levelstyle=DASH_;                // Стиль уровней
input WIDTH  LevelsWidth=Width_1;            // Толщина уровней
input int Shift=0;                           // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые в дальнейшем
//---- будут использованы в качестве индикаторных буферов
double Stoch[],XStoch[];
double sens; // чувствительность в ценах
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total,min_rates_stoch;
//+------------------------------------------------------------------+   
//| Asymmetric Stoch NR indicator initialization function            | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_stoch=int(MathMax(KperiodShort,KperiodLong)+Slowing);
   min_rates_total=min_rates_stoch+XMA.GetStartBars(DMethod,Dperiod,DPhase);

//---- инициализация переменных   
   sens=Sens*_Point; // чувствительность в ценах

//---- параметры отрисовки линий  
   IndicatorSetInteger(INDICATOR_LEVELS,2);

   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,OverSold);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,DnLevelsColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,Levelstyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,0,LevelsWidth);

   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,OverBought);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,UpLevelsColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,Levelstyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,1,LevelsWidth);

//---- установка алертов на недопустимые значения внешних переменных
   XMA.XMALengthCheck("Dperiod",Dperiod);
   XMA.XMALengthCheck("Dperiod",Dperiod);
   XMA.XMAPhaseCheck("DPhase",DPhase,DMethod);

//---- превращение динамического массива Stoch[] в индикаторный буфер
   SetIndexBuffer(0,Stoch,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере, как в таймсерии
   ArraySetAsSeries(Stoch,true);

//---- превращение динамического массива XStoch[] в индикаторный буфер
   SetIndexBuffer(1,XStoch,INDICATOR_DATA);
//---- индексация элементов в буфере, как в таймсерии
   ArraySetAsSeries(XStoch,true);

//---- инициализации переменной для короткого имени индикатора
   string shortname,Smooth;
   Smooth=XMA.GetString_MA_Method(DMethod);
   StringConcatenate(shortname,"Asymmetric Stochastic NR(",KperiodShort,",",KperiodLong,",",Dperiod,",",Smooth,",",Slowing,")");
//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
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
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(RESET);

//---- объявление целочисленных переменных
   int limit,bar,maxbar;

//---- объявление статических переменных памяти
   static uint Kperiod0,Kperiod1;

//---- расчеты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-1-min_rates_stoch; // стартовый номер для расчета всех баров
      Kperiod0=KperiodShort;
      Kperiod1=KperiodShort;
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров 

//---- индексация элементов в массивах, как в таймсериях  
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

   maxbar=rates_total-1-min_rates_stoch;

//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      Stoch[bar]=Stoch(Kperiod0,Kperiod1,Slowing,PriceField,sens,bar,low,high,close);
      //----
      XStoch[bar]=XMA.XMASeries(maxbar,prev_calculated,rates_total,DMethod,DPhase,Dperiod,Stoch[bar],bar,true);

      //--- переключение направления
      if(XStoch[bar+1]>OverBought)
        { // восходящий тренд
         Kperiod0=KperiodShort;
         Kperiod1=KperiodLong;
        }

      if(XStoch[bar+1]<OverSold)
        { // нисходящий тренд
         Kperiod0=KperiodLong;
         Kperiod1=KperiodShort;
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
