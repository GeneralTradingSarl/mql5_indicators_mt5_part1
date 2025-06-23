//+------------------------------------------------------------------+
//|                                             DarvasBoxesCloud.mq5 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2004, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//--- для расчета и отрисовки индикатора использовано семь буферов
#property indicator_buffers 7
//--- использовано пять графических построений
#property indicator_plots   5
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета облака использован LightSkyBlue
#property indicator_color1  clrLightSkyBlue
//---- отображение метки индикатора
#property indicator_label1  "Upper Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки верхней границы         |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде линии
#property indicator_type2   DRAW_LINE
//---- в качестве цвета бычей линии индикатора использован DodgerBlue
#property indicator_color2  clrDodgerBlue
//---- линия индикатора 2 - непрерывная кривая
#property indicator_style2  STYLE_SOLID
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение бычей метки индикатора
#property indicator_label2  "Upper DarvasBox"
//+----------------------------------------------+
//|  Параметры отрисовки средней линии           |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде линии
#property indicator_type3   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован Gray
#property indicator_color3  clrGray
//---- линия индикатора 3 - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение медвежьей метки индикатора
#property indicator_label3  "Middle DarvasBox"
//+----------------------------------------------+
//|  Параметры отрисовки нижней границы          |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде линии
#property indicator_type4   DRAW_LINE
//---- в качестве цвета медвежьей линии индикатора использован Brown
#property indicator_color4  clrBrown
//---- линия индикатора 4 - непрерывная кривая
#property indicator_style4  STYLE_SOLID
//---- толщина линии индикатора 4 равна 2
#property indicator_width4  2
//---- отображение медвежьей метки индикатора
#property indicator_label4  "Lower DarvasBox"
//+----------------------------------------------+
//|  Параметры отрисовки облака                  |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type5   DRAW_FILLING
//---- в качестве цвета облака использован Orchid
#property indicator_color5  clrOrchid
//---- отображение метки индикатора
#property indicator_label5  "Lower Cloud"
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input bool symmetry=true;
input int Shift=0; // сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtUp1Buffer[];
double ExtUp2Buffer[];
double ExtABuffer[];
double ExtBBuffer[];
double ExtCBuffer[];
double ExtDn1Buffer[];
double ExtDn2Buffer[];
//---- Объявление целых переменных начала отсчёта данных
int  min_rates_total;
//+------------------------------------------------------------------+    
//| Donchian Channel indicator initialization function               | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=2;
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtUp1Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtUp2Buffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtUp1Buffer,true);
   ArraySetAsSeries(ExtUp2Buffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,ExtABuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtABuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,ExtBBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtBBuffer,true);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(4,ExtCBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtCBuffer,true);
   
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(5,ExtDn1Buffer,INDICATOR_DATA);
   SetIndexBuffer(6,ExtDn2Buffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора по горизонтали
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtDn1Buffer,true);
   ArraySetAsSeries(ExtDn2Buffer,true);

//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"DarvasBoxesCloud");
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+  
//| Donchian Channel iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);

//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- Объявление целых переменных
   int limit,bar;
//---- Объявление статических переменных
   static int state,STATE;
   static double box_top,box_bottom,BOX_TOP,BOX_BUTTOM;

//---- расчёты стартового номера limit для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-min_rates_total; // стартовый номер для расчёта всех баров
      BOX_TOP=high[limit+1];
      BOX_BUTTOM=low[limit+1];
      STATE=1;
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }

//---- восстанавливаем значения переменных
   state=STATE;
   box_top=BOX_TOP;
   box_bottom=BOX_BUTTOM;

//---- Основной цикл расчёта индикатора    
   for(bar=limit; bar>=0; bar--)
     {       
      switch(state)
        {
         case 1:  box_top=high[bar]; if(symmetry)box_bottom=low[bar]; break;
         case 2:  if(box_top<=high[bar]) box_top=high[bar]; break;
         case 3:  if(box_top> high[bar]) box_bottom=low[bar]; else box_top=high[bar]; break;
         case 4:  if(box_top > high[bar]) {if(box_bottom >= low[bar]) box_bottom=low[bar];} else box_top=high[bar]; break;
         case 5:  if(box_top > high[bar]) {if(box_bottom >= low[bar]) box_bottom=low[bar];} else box_top=high[bar]; state=0; break;
        }

      ExtABuffer[bar] = box_top;
      ExtCBuffer[bar] = box_bottom;
      ExtBBuffer[bar]=(box_top+box_bottom)/2.0;
      ExtUp1Buffer[bar]=ExtABuffer[bar];
      ExtUp2Buffer[bar]=ExtBBuffer[bar];
      ExtDn1Buffer[bar]=ExtBBuffer[bar];
      ExtDn2Buffer[bar]=ExtCBuffer[bar];
      state++;
      
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(bar==1)
        {
         STATE=state;
         BOX_TOP=box_top;
         BOX_BUTTOM=box_bottom;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
