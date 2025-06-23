//+------------------------------------------------------------------+
//|                                                    ColorXADX.mq5 |
//|                           Copyright © 2010,     Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2010, Nikolay Kositsin"
//---- ссылка на сайт автора
#property link "farria@mail.redcom.ru" 
//---- номер версии индикатора
#property version   "1.03"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- для расчета и отрисовки индикатора использовано пять буферов
#property indicator_buffers 5
//---- использовано три графических построения
#property indicator_plots   3
//+----------------------------------------------+
//| Параметры отрисовки индикатора XDi           |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цветов индикатора использованы
#property indicator_color1  clrLime,clrRed
//---- отображение метки индикатора
#property indicator_label1  "XDi"
//+----------------------------------------------+
//| Параметры отрисовки индикатора XADX Line     |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета  линии индикатора использован серый цвет
#property indicator_color2  clrGray
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 1
#property indicator_width2  1
//---- отображение метки индикатора
#property indicator_label2  "XADX Line"
//+----------------------------------------------+
//| Параметры отрисовки ADX индикатора           |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде значка
#property indicator_type3   DRAW_COLOR_ARROW
//---- в качестве цветов ADX линии индикатора использованы
#property indicator_color3  clrGray,clrBlue,clrMagenta,clrRed
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 3
#property indicator_width3  3
//---- отображение метки индикатора
#property indicator_label3  "XADX"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_levelcolor clrBlue
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Описание классов усреднений                  |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+
//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XDIP,XDIM,XADX;
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
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
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
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
//+----------------------------------------------+
//| Объявление перечислений                      |
//+----------------------------------------------+
enum ENUM_WIDTH //Тип константы
  {
   w_1=0,  //1
   w_2,    //2
   w_3,    //3
   w_4,    //4
   w_5     //5
  };
//+----------------------------------------------+
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input Smooth_Method XMA_Method=MODE_T3; // Метод усреднения гистограммы
input uint ADX_Period=14; // Период XMA усреднения
input int ADX_Phase=100; // Параметр XMA усреднения
//---- изменяющийся в пределах -100 ... +100,
//---- влияет на качество переходного процесса;
input Applied_price_ IPC=PRICE_CLOSE_;// Ценовая константа
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
input uint ExtraHighLevel=60; // Уровень максимального тренда
input uint HighLevel=40; // Уровень сильного тренда
input uint LowLevel=20;// Уровень слабого тренда
input ENUM_LINE_STYLE LevelStyle=STYLE_DASHDOTDOT; // Стиль линий уровней
input color LevelColor=clrBlue; // Цвет уровней
input ENUM_WIDTH LevelWidth=w_1; // Толщина уровней
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double DiPlusBuffer[];
double DiMinusBuffer[];
double ADXBuffer[];
double ADXLineBuffer[];
double ColorADXBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_di,min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_di=XADX.GetStartBars(XMA_Method,ADX_Period,ADX_Phase);
   min_rates_total=2*min_rates_di+1;
   min_rates_di++;
//---- превращение динамического массива DiPlusBuffer в индикаторный буфер
   SetIndexBuffer(0,DiPlusBuffer,INDICATOR_DATA);
//---- превращение динамического массива DiMinusBuffer в индикаторный буфер
   SetIndexBuffer(1,DiMinusBuffer,INDICATOR_DATA);
//---- превращение динамического массива ADXLineBuffer в индикаторный буфер
   SetIndexBuffer(2,ADXLineBuffer,INDICATOR_DATA);
//---- превращение динамического массива ADXBuffer в индикаторный буфер
   SetIndexBuffer(3,ADXBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(4,ColorADXBuffer,INDICATOR_COLOR_INDEX);

//---- осуществление сдвига начала отсчета отрисовки индикатора 1 на min_rates_di
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_di);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);

//---- осуществление сдвига начала отсчета отрисовки индикатора 2 на min_rates_di
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_di);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);

//---- осуществление сдвига начала отсчета отрисовки индикатора 3 на min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);

//---- инициализация переменной для короткого имени индикатора
   string shortname;
   string Smooth=XADX.GetString_MA_Method(XMA_Method);
   StringConcatenate(shortname,"XADX( ",Smooth,", ",ADX_Period,", ",ADX_Phase,", ",EnumToString(IPC),", ",Shift," )");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- параметры отрисовки уровней индикатора
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,ExtraHighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,HighLevel);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,LowLevel);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,LevelColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,LevelStyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,0,LevelWidth);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,LevelColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,LevelStyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,1,LevelWidth);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,LevelColor);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,LevelStyle);
   IndicatorSetInteger(INDICATOR_LEVELWIDTH,2,LevelWidth);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double& high[],     // ценовой массив максимумов цены для расчета индикатора
                const double& low[],      // ценовой массив минимумов цены  для расчета индикатора
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(rates_total<min_rates_total) return(0);
//---- объявление локальных переменных 
   int first,bar;
   double DiPlus,DiMinus;
   double Hi,Lo,prevHi,prevLo,prevCl,dTmpP,dTmpN,tr,dTmp;
//---- инициализация индикатора в блоке OnCalculate()
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
      first=1; // стартовый номер для расчета всех баров
   else first=prev_calculated-1;// стартовый номер для расчета новых баров
//---- основной цикл расчета индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      int bar1=bar-1;
      Hi=high[bar];
      prevHi=high[bar1];
      //----
      Lo=low[bar];
      prevLo=low[bar1];
      //----
      prevCl=close[bar1];
      //----
      dTmpP=Hi-prevHi;
      dTmpN=prevLo-Lo;
      //----
      dTmpP=MathMax(0.0,dTmpP);
      dTmpN=MathMax(0.0,dTmpN);
      //----
      if(dTmpP>dTmpN) dTmpN=NULL;
      else
        {
         if(dTmpP<dTmpN) dTmpP=NULL;
         else
           {
            dTmpP=NULL;
            dTmpN=NULL;
           }
        }
      //----
      tr=MathMax(MathMax(MathAbs(Hi-Lo),MathAbs(Hi-prevCl)),MathAbs(Lo-prevCl));
      //---
      if(tr)
        {
         DiPlus=100.0*dTmpP/tr;
         DiMinus=100.0*dTmpN/tr;
        }
      else
        {
         DiPlus=NULL;
         DiMinus=NULL;
        }
      //----
      DiPlusBuffer [bar]=XDIP.XMASeries(1,prev_calculated,rates_total,XMA_Method,ADX_Phase,ADX_Period,DiPlus, bar,false);
      DiMinusBuffer[bar]=XDIM.XMASeries(1,prev_calculated,rates_total,XMA_Method,ADX_Phase,ADX_Period,DiMinus,bar,false);
      //----
      dTmp=DiPlusBuffer[bar]+DiMinusBuffer[bar];
      //----
      if(dTmp) dTmp=100.0*MathAbs((DiPlusBuffer[bar]-DiMinusBuffer[bar])/dTmp);
      else          dTmp=NULL;
      //----
      ADXBuffer[bar]=XADX.XMASeries(min_rates_di,prev_calculated,rates_total,XMA_Method,ADX_Phase,ADX_Period,dTmp,bar,false);
      ADXLineBuffer[bar]=ADXBuffer[bar];
     }
//---- основной цикл раскраски сигнальной линии
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      int clr=1;
      if(ADXBuffer[bar]>ExtraHighLevel) clr=3;
      else if(ADXBuffer[bar]>HighLevel) clr=2;
      else if(ADXBuffer[bar]<LowLevel)  clr=0;
      ColorADXBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
