//+---------------------------------------------------------------------+
//|                                                  ColorParabolic.mq5 | 
//|                         Copyright © 2010, Nikolay Kositsin + lukas1 | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin + lukas1"
#property link "farria@mail.redcom.ru"
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано четыре буфера
#property indicator_buffers 4
//---- использовано всего четыре графических построения
#property indicator_plots   4
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 1 в виде символа
#property indicator_type1   DRAW_ARROW
//---- в качестве цвета индикатора использован Magenta цвет
#property indicator_color1  clrMagenta
//---- толщина индикатора 1 равна 1
#property indicator_width1  4
//---- отображение бычей метки индикатора
#property indicator_label1  "Lower Parabolic"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета индикатора использован DodgerBlue цвет
#property indicator_color2  clrDodgerBlue
//---- толщина индикатора 2 равна 1
#property indicator_width2  4
//---- отображение медвежьей метки индикатора
#property indicator_label2 "Upper Parabolic"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде символа
#property indicator_type3   DRAW_ARROW
//---- в качестве цвета индикатора использован Magenta цвет
#property indicator_color3  clrMagenta
//---- толщина индикатора 3 равна 4
#property indicator_width3  4
//---- отображение бычей метки индикатора
#property indicator_label3  "Parabolic Sell"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде символа
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета индикатора использован DodgerBlue цвет
#property indicator_color4  clrDodgerBlue
//---- толщина индикатора 4 равна 4
#property indicator_width4  4
//---- отображение медвежьей метки индикатора
#property indicator_label4 "Parabolic Buy"
//+----------------------------------------------+
//| Входные параметры индикатора Parabolic       |
//+----------------------------------------------+
input double StepH_=0.02;//Шаг для верхних точек
input double MaximumH=0.5;//Максимум для верхних точек
input double StepL_=0.02;//Шаг для нижних точек
input double MaximumL=0.5;//Максимум для нижних точек
//+----------------------------------------------+

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double BuyBuffer[],SellBuffer[];
double UpSarBuffer[],DnSarBuffer[];
//---- 
bool dirlong_,first_;
double ep_,start_,last_high_,last_low_,prev_sar_;
double StepH,StepL;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//+------------------------------------------------------------------+   
//| Parabolic indicator initialization function                      | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=2;
   StepH=MathMin(StepH_,MaximumH);
   StepL=MathMin(StepL_,MaximumL);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,UpSarBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(0,PLOT_ARROW,158);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(1,DnSarBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(1,PLOT_ARROW,158);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(2,SellBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,BuyBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора 4
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- символ для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,159);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,"Parabolic");

//---- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| Parabolic iteration function                                     | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const int begin,          // номер начала достоверного отсчёта баров
                const double &price[]     // ценовой массив для расчёта индикатора
                )
  {
//---- проверка количества баров на достаточность для расчёта
   if(rates_total<min_rates_total) return(0);

//---- Объявление переменных с плавающей точкой
   double price_low,price_high,sar;
   double ep,start,last_high,last_low,prev_sar;
//---- Объявление целых переменных и получение уже посчитанных баров
   int gfirst,bar;
   bool dirlong,first;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      gfirst=begin+min_rates_total; // стартовый номер для расчёта всех баров
      first_=false;
      dirlong_=false;
      last_high_=0.0;
      last_low_=999999999.0;
      ep_=price[min_rates_total-1];
      prev_sar_=ep_;
      start_=0.0;

      //---- осуществление сдвига начала отсчёта отрисовки индикатора
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,begin+min_rates_total);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,begin+min_rates_total);
      PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,begin+min_rates_total);
      PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,begin+min_rates_total);
     }
   else gfirst=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- восстановим значения переменных
   ep=ep_;
   start=start_;
   last_high=last_high_;
   last_low=last_low_;
   dirlong=dirlong_;
   first=first_;
   prev_sar=prev_sar_;

//---- Основной цикл расчёта индикатора Parabolic
   for(bar=gfirst; bar<rates_total; bar++)
     {
      price_low=price[bar];
      price_high=price[bar];
      sar=prev_sar+start*(ep-prev_sar);
      //----
      if(dirlong)
        {
         if(ep<price_high && start+StepL<=MaximumL) start+=StepL;
         if(sar>=price_low)
           {
            start=StepL;
            dirlong=false;
            ep=price_low;
            last_low=price_low;

            if(price_high<last_high) sar=last_high;
            else sar=price_high;
           }
         else
           {
            if(ep<price_low && start+StepL<=MaximumL) start+=StepL;

            if(ep<price_high)
              {
               last_high=price_high;
               ep=price_high;
              }
           }
        }
      //----
      else
        {
         if(ep>price_low && start+StepH<=MaximumH) start+=StepH;
         if(sar<=price_high)
           {
            start=StepH;
            dirlong=true;
            ep=price_high;
            last_high=price_high;
            if(price_low>last_low) sar=last_low;
            else sar=price_low;
           }
         else
           {
            if(ep>price_high && start+StepH<=MaximumH) start+=StepH;

            if(ep>price_low)
              {
               last_low=price_low;
               ep=price_low;
              }
           }
        }

      //---- обнулим содержимое индикаторных буферов до расчёта
      DnSarBuffer[bar]=EMPTY_VALUE;
      UpSarBuffer[bar]=EMPTY_VALUE;

      if(price[bar]<sar) UpSarBuffer[bar]=sar;
      else               DnSarBuffer[bar]=sar;

      //---- сохраним значения переменных
      if(bar==rates_total-2)
        {
         ep_=ep;
         start_=start;
         last_high_=last_high;
         last_low_=last_low;
         dirlong_=dirlong;
         first_=first;
         prev_sar_=sar;
        }
        
        if(bar<rates_total-1) prev_sar=sar;
     }

//---- пересчёт стартового номера для расчёта всех баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора     
      gfirst++;

//---- второй цикл расчёта Parabolic
   for(bar=gfirst; bar<rates_total; bar++)
     {
      //---- обнулим содержимое индикаторных буферов до расчёта
      BuyBuffer[bar]=EMPTY_VALUE;
      SellBuffer[bar]=EMPTY_VALUE;
      
      if(UpSarBuffer[bar-1]==EMPTY_VALUE&&UpSarBuffer[bar]!=EMPTY_VALUE) SellBuffer[bar]=UpSarBuffer[bar];
      if(DnSarBuffer[bar-1]==EMPTY_VALUE&&DnSarBuffer[bar]!=EMPTY_VALUE) BuyBuffer[bar]=DnSarBuffer[bar];
     }
//----      
   return(rates_total);
  }
//+------------------------------------------------------------------+
