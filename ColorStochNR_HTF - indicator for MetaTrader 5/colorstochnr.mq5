//+------------------------------------------------------------------+
//|                                                 ColorStochNR.mq5 | 
//|                                      Copyright © 2010, Svinozavr |
//|                                                                  |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2010, Svinozavr"
//---- авторство индикатора
#property link      ""
#property description "Стохастический осциллятор с подавлением шума, выполненный в виде цветной гистограммы"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов
#property indicator_buffers 5 
//---- использовано всего два графических построения
#property indicator_plots   2
//+----------------------------------------------+
//| Объявление констант                          |
//+----------------------------------------------+
#define RESET 0 // константа для возврата терминалу команды на пересчет индикатора
//+----------------------------------------------+
//| Параметры отрисовки индикатора 1             |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветной гистограммы
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
//---- в качестве цветов гистограммы использованы
#property indicator_color1 clrGray,clrLightSeaGreen,clrDodgerBlue,clrDeepPink,clrMagenta
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1  3
//---- отображение метки индикатора
#property indicator_label1  "Main"
//+----------------------------------------------+
//| Параметры отрисовки индикатора 2             |
//+----------------------------------------------+
//---- отрисовка индикатора в виде трехцветной линии
#property indicator_type2   DRAW_COLOR_LINE
//---- в качестве цвета линии индикатора использованы
#property indicator_color2 clrGray,clrLime,clrMagenta
//---- линия индикатора - штрих
#property indicator_style2  STYLE_DASH
//---- толщина линии индикатора равна 2
#property indicator_width2  2
//---- отображение метки индикатора
#property indicator_label2  "Signal"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1  70.0
#property indicator_level2  50.0
#property indicator_level3  30.0
#property indicator_levelcolor Violet
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Объявление перечисления                      |
//+----------------------------------------------+
enum ENUM_MA_METHOD_
  {
   MODE_SMA_,       // Простое усреднение
   MODE_EMA_        // Экспоненциальное
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input uint Kperiod=5;  // K period
input uint Dperiod=3;  // D period
input uint Slowing=3;  // Slowing
input ENUM_MA_METHOD_ Dmethod=MODE_SMA_; // Тип сглаживания
input ENUM_STO_PRICE PriceFild=STO_LOWHIGH; // Способ расчета стохастика
input uint Sens=0; // Чувствительность в пунктах
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double UpSTOH[],DnSTOH[],SIGN[];
double ColorSTOH[],ColorSIGN[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total;
//----
double sens; // чувствительность в ценах
double kd; // коэфф. EMA для сигнальной
//+------------------------------------------------------------------+   
//| STOH indicator initialization function                           | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_total=int(Kperiod+Dperiod+Slowing+1);
//---- инициализация переменных  
   sens=Sens*_Point; // чувствительность в ценах
   if(Dmethod==MODE_EMA_) kd=2.0/(1+Dperiod); // коэфф. EMA для сигнальной
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpSTOH,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(UpSTOH,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnSTOH,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(DnSTOH,true);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(2,ColorSTOH,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorSTOH,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,SIGN,INDICATOR_DATA);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(SIGN,true);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ColorSIGN,INDICATOR_COLOR_INDEX);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ColorSIGN,true);

//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"StochNR("+(string)Kperiod+","+(string)Dperiod+","+(string)Slowing+")");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| STOH iteration function                                          | 
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
   int limit,bar;
//---- объявление переменных с плавающей точкой  
   double Main,prevMain;
//---- расчеты необходимого количества копируемых данных и
//---- стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_total-1; // стартовый номер для расчета всех баров
      SIGN[limit+1]=50;
      for(bar=rates_total-1; bar>limit && !IsStopped(); bar--)
        {
         UpSTOH[bar]=50;
         DnSTOH[bar]=50;
        }
     }
   else limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров 
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//---- основной цикл расчета индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- главная линия
      Main=Stoch(Kperiod,Slowing,PriceFild,sens,high,low,close,bar);
      //----
      if(Main<50)
        {
         DnSTOH[bar]=Main;
         UpSTOH[bar]=50;
        }
      else
        {
         UpSTOH[bar]=Main;
         DnSTOH[bar]=50;
        }
      //---- сигнальная линия
      switch(Dmethod)
        {
         case MODE_EMA_: /* EMA */  SIGN[bar]=kd*Main+(1-kd)*SIGN[bar+1]; break;
         case MODE_SMA_: /* SMA */
           {
            int sh=int(bar+Dperiod);
            double OldMain=UpSTOH[sh]+DnSTOH[sh]-50;
            double sum=SIGN[bar+1]*Dperiod-OldMain;
            SIGN[bar]=(sum+Main)/Dperiod;
           }
        }
     }
//----
   if(!prev_calculated) limit--;
//---- основной цикл раскраски индикатора Stoh
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ColorSTOH[bar]=0;
      Main=UpSTOH[bar]+DnSTOH[bar]-50;
      prevMain=UpSTOH[bar+1]+DnSTOH[bar+1]-50;
      //----
      if(Main>50)
        {
         if(Main>prevMain) ColorSTOH[bar]=1;
         if(Main<prevMain) ColorSTOH[bar]=2;
        }
      //----
      if(Main<50)
        {
         if(Main<prevMain) ColorSTOH[bar]=3;
         if(Main>prevMain) ColorSTOH[bar]=4;
        }
     }
//---- основной цикл раскраски сигнальной линии
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      ColorSIGN[bar]=0;
      Main=UpSTOH[bar]+DnSTOH[bar]-50;
      //----
      if(Main>SIGN[bar]) ColorSIGN[bar]=1;
      if(Main<SIGN[bar]) ColorSIGN[bar]=2;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+ 
//| STOH iteration function                                          | 
//+------------------------------------------------------------------+ 
double Stoch(int Kperiod_, // %K
             int Slowing_, // замедление
             ENUM_STO_PRICE PriceFild_,// тип цены
             double Sens_,// чувствительность в центах
             const double &High[],
             const double &Low[],
             const double &Close[],
             int index) // сдвиг
  {
//----
   double delta,sens2,s0;
//---- экстремумы цены 
   double max=0.0;
   double min=0.0;
   double closesum=0.0;
//----
   for(int j=index; j<index+Slowing_; j++)
     {
      if(PriceFild_==STO_CLOSECLOSE) // по Close
        {
         max+=Close[ArrayMaximum(Close,j,Kperiod_)];
         min+=Close[ArrayMinimum(Close,j,Kperiod_)];
        }
      else // по High/Low
        {
         max+=High[ArrayMaximum(High,j,Kperiod_)];
         min+=Low[ArrayMinimum(Low,j,Kperiod_)];
        }
      //----
      closesum+=Close[j];
     }
//----
   delta=max-min;
//----
   if(delta<Sens_)
     {
      sens2=Sens_/2;
      max+=sens2;
      min-=sens2;
     }
//----
   delta=max-min;
//----
   if(delta) s0=(closesum-min)/delta;
   else s0=1.0;
//----
   return(100*s0);
  }
//+------------------------------------------------------------------+
