//+---------------------------------------------------------------------+
//|                                          ColorXvaMA_Digit_StDev.mq5 | 
//|                                               Copyright © 2013, J.B | 
//|                                                                     | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2013, J.B"
#property link ""
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано шесть буферов
#property indicator_buffers 6
//---- использовано всего пять графических построений
#property indicator_plots   5
//+----------------------------------------------+
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_COLOR_LINE
//---- в качестве цветов линии использованы
#property indicator_color1  clrDeepPink,clrDodgerBlue
//---- линия индикатора - непрерывная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 3
#property indicator_width1  3
//---- отображение метки индикатора
#property indicator_label1  "ColorXvaMA_Digit"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде символа
#property indicator_type2   DRAW_ARROW
//---- в качестве цвета медвежьего индикатора использован жёлтый цвет
#property indicator_color2  clrGold
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение медвежьей метки индикатора
#property indicator_label2  "Dn_Signal 1"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде символа
#property indicator_type3   DRAW_ARROW
//---- в качестве цвета бычьего индикатора использован аквамариновый цвет
#property indicator_color3  clrAqua
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение бычей метки индикатора
#property indicator_label3  "Up_Signal 1"
//+----------------------------------------------+
//|  Параметры отрисовки медвежьего индикатора   |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде символа
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета медвежьего индикатора использован жёлтый цвет
#property indicator_color4  clrGold
//---- толщина линии индикатора 4 равна 4
#property indicator_width4  4
//---- отображение медвежьей метки индикатора
#property indicator_label4  "Dn_Signal 2"
//+----------------------------------------------+
//|  Параметры отрисовки бычьго индикатора       |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде символа
#property indicator_type5   DRAW_ARROW
//---- в качестве цвета бычьего индикатора использован аквамариновый цвет
#property indicator_color5  clrAqua
//---- толщина линии индикатора 5 равна 4
#property indicator_width5  4
//---- отображение бычей метки индикатора
#property indicator_label5  "Up_Signal 2"
//+----------------------------------------------+
//|  Описание класса CXMA                        |
//+----------------------------------------------+
#include <SmoothAlgorithms.mqh> 
//+----------------------------------------------+

//---- объявление переменных класса CXMA из файла SmoothAlgorithms.mqh
CXMA XMA1,XMA2;
//+----------------------------------------------+
//|  объявление перечислений                     |
//+----------------------------------------------+
enum Applied_price_      //Тип константы
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
//|  объявление перечислений                     |
//+----------------------------------------------+
/*enum SmoothMethod - перечисление объявлено в файле SmoothAlgorithms.mqh
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
//| Входные параметры индикатора                 |
//+----------------------------------------------+
input string  SirName="ColorXvaMA_Digit"; //Первая часть имени графических объектов
input Smooth_Method XMA_Method1=MODE_EMA_;//метод усреднения
input uint XLength1=15;                   //глубина усреднения                    
input int XPhase1=15;                     //параметр усреднения,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Smooth_Method XMA_Method2=MODE_JJMA;//метод сглаживания
input uint XLength2=5;                    //глубина сглаживания                    
input int XPhase2=100;                    //параметр сглаживания,
//---- для JJMA изменяющийся в пределах -100 ... +100, влияет на качество переходного процесса;
//---- Для VIDIA это период CMO, для AMA это период медленной скользящей
input Applied_price_ IPC=PRICE_CLOSE_;    //ценовая константа
input int Shift=0;                        //сдвиг индикатора по горизонтали в барах
input int PriceShift=0;                   //cдвиг индикатора по вертикали в пунктах
input uint Digit=2;                       //количество разрядов округления
input bool ShowPrice=true;                //показывать ценовую метку
//---- цвета ценовых меток
input color  Price_color=clrGray;         //цвет ценовой метки
input double dK1=1.5;                     //коэффициент 1 для квадратичного фильтра
input double dK2=2.5;                     //коэффициент 2 для квадратичного фильтра
input uint std_period=9;                  //период квадратичного фильтра
//+----------------------------------------------+
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double ExtLineBuffer[],ColorExtLineBuffer[];
double BearsBuffer1[],BullsBuffer1[];
double BearsBuffer2[],BullsBuffer2[];
//---- Объявление переменной значения вертикального сдвига мувинга
double dPriceShift;
double PointPow10;
//---- Объявление целых переменных начала отсчёта данных
int min_rates,min_rates_total,XLength4,XLength8,XLength12,std_period1;
//---- объявление глобальных переменных
int Count1[],Count2[];
double Xma[],dXVama[],XVama[];
//---- Объявление стрингов для текстовых меток
string Price_name;
//+------------------------------------------------------------------+
//|  Пересчет позиции самого нового элемента в массиве               |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos1(int &CoArr[],// Возврат по ссылке номера текущего значения ценового ряда
                           int Size)
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=Size;
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+
//|  Пересчет позиции самого нового элемента в массиве               |
//+------------------------------------------------------------------+   
void Recount_ArrayZeroPos2(int &CoArr[],// Возврат по ссылке номера текущего значения ценового ряда
                           int Size)
  {
//----
   int numb,Max1,Max2;
   static int count=1;

   Max2=Size;
   Max1=Max2-1;

   count--;
   if(count<0) count=Max1;

   for(int iii=0; iii<Max2; iii++)
     {
      numb=iii+count;
      if(numb>Max1) numb-=Max2;
      CoArr[iii]=numb;
     }
//----
  }
//+------------------------------------------------------------------+   
//| XvaMA indicator initialization function                          | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates=GetStartBars(XMA_Method1,XLength1,XPhase1);
   min_rates_total=min_rates+GetStartBars(XMA_Method2,XLength2,XPhase2)+int(std_period);
   std_period1=int(std_period)+1;
   XLength4=int(XLength1/4);
   XLength8=int(XLength1/8);
   XLength12=int(XLength1/12);
   PointPow10=_Point*MathPow(10,Digit);
//---- Инициализация стрингов
   Price_name=SirName+"Price";
//---- установка алертов на недопустимые значения внешних переменных
   XMA1.XMALengthCheck("XLength1",XLength1);
   XMA1.XMALengthCheck("XLength2",XLength2);
   XMA1.XMAPhaseCheck("XPhase1",XPhase1,XMA_Method1);
   XMA1.XMAPhaseCheck("XPhase2",XPhase2,XMA_Method2);
//---- Инициализация сдвига по вертикали
   dPriceShift=_Point*PriceShift;
//---- распределение памяти под массивы переменных  
   ArrayResize(Count1,XLength1);
   ArrayResize(Xma,XLength1);
//---- Распределение памяти под массивы переменных  
   ArrayResize(Count2,std_period1);
   ArrayResize(XVama,std_period1);
   ArrayResize(dXVama,std_period1);

//---- превращение динамического массива ExtLineBuffer в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);

//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(1,ColorExtLineBuffer,INDICATOR_COLOR_INDEX);

//---- превращение динамического массива BearsBuffer в индикаторный буфер
   SetIndexBuffer(2,BearsBuffer1,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(1,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива BullsBuffer в индикаторный буфер
   SetIndexBuffer(3,BullsBuffer1,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(2,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива BearsBuffer в индикаторный буфер
   SetIndexBuffer(4,BearsBuffer2,INDICATOR_DATA);
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(3,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- превращение динамического массива BullsBuffer в индикаторный буфер
   SetIndexBuffer(5,BullsBuffer2,INDICATOR_DATA);
//---- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчёта отрисовки индикатора
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- выбор символа для отрисовки
   PlotIndexSetInteger(4,PLOT_ARROW,159);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- инициализации переменной для короткого имени индикатора
   string shortname;
   string Smooth1=XMA1.GetString_MA_Method(XMA_Method1);
   StringConcatenate(shortname,"XvaMA(",XLength1,", ",Smooth1,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,Price_name);
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+ 
//| XvaMA iteration function                                         | 
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

//---- Объявление переменных с плавающей точкой  
   double price,vel,acc,aaa,vama,xvama,trend;
//---- Объявление целых переменных
   int first,bar;
   double SMAdif,Sum,StDev,dstd,BEARS1,BULLS1,BEARS2,BULLS2,Filter1,Filter2;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=0; // стартовый номер для расчёта всех баров
      //---- Обнуление содержимого циклических буферов
      ArrayInitialize(Count1,0);
      ArrayInitialize(Xma,0.0);
      ArrayInitialize(Count2,0);
      ArrayInitialize(XVama,0.0);
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- Основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      price=PriceSeries(IPC,bar,open,low,high,close);                                                             //Получение цены
      Xma[Count1[0]]=XMA1.XMASeries(0,prev_calculated,rates_total,XMA_Method1,XPhase1,XLength1,price,bar,false);  //Усреднение цены 
      vel=Xma[Count1[0]]-Xma[Count1[XLength4]];                                                                   //Приращение между барами
      acc=Xma[Count1[0]]-2*Xma[Count1[XLength4]]+Xma[Count1[XLength8]];                                           //Приращение приращения между барами
      aaa=Xma[Count1[0]]-3*Xma[Count1[XLength4]]+3*Xma[Count1[XLength8]]-Xma[Count1[XLength12]];                  //Приращение приращения приращения...                                                                                         
      vama=Xma[Count1[0]]+vel+acc/2+aaa/6;                                                                        //Алхимический микс
      xvama=XMA2.XMASeries(min_rates,prev_calculated,rates_total,XMA_Method2,XPhase2,XLength2,vama,bar,false);    //Сглаживание индикатора   
      XVama[Count2[0]]=xvama;
      ExtLineBuffer[bar]=PointPow10*MathRound(xvama/PointPow10);                                                  //инициализация буфера и округление последних разрядов индикатора 
      ExtLineBuffer[bar]+=dPriceShift;                                                                            //Добавление вертикального шифта      
      
      //---- загружаем приращения индикатора в массив для промежуточных вычислений
      for(int iii=0; iii<int(std_period); iii++) dXVama[iii]=XVama[Count2[iii]]-XVama[Count2[iii+1]];

      //---- находим простое среднее приращений индикатора
      Sum=0.0;
      for(int iii=0; iii<int(std_period); iii++) Sum+=dXVama[iii];
      SMAdif=Sum/std_period;

      //---- находим сумму квадратов разностей приращений и среднего
      Sum=0.0;
      for(int iii=0; iii<int(std_period); iii++) Sum+=MathPow(dXVama[iii]-SMAdif,2);

      //---- определяем итоговое значение среднеквадратичного отклонения StDev от приращения индикатора
      StDev=MathSqrt(Sum/std_period);

      //---- инициализация переменных
      dstd=NormalizeDouble(dXVama[0],_Digits+2);
      Filter1=NormalizeDouble(dK1*StDev,_Digits+2);
      Filter2=NormalizeDouble(dK2*StDev,_Digits+2);
      BEARS1=EMPTY_VALUE;
      BULLS1=EMPTY_VALUE;
      BEARS2=EMPTY_VALUE;
      BULLS2=EMPTY_VALUE;
      xvama=ExtLineBuffer[bar];

      //---- вычисление индикаторных значений
      if(dstd<-Filter1 && dstd>=-Filter2) BEARS1=xvama; //есть нисходящий тренд
      if(dstd<-Filter2) BEARS2=xvama; //есть нисходящий тренд
      if(dstd>+Filter1 && dstd<=+Filter2) BULLS1=xvama; //есть восходящий тренд
      if(dstd>+Filter2) BULLS2=xvama; //есть восходящий тренд

      //---- инициализация ячеек индикаторных буферов полученными значениями 
      BullsBuffer1[bar]=BULLS1;
      BearsBuffer1[bar]=BEARS1;
      BullsBuffer2[bar]=BULLS2;
      BearsBuffer2[bar]=BEARS2;
      
      if(bar<rates_total-1)
        {
         Recount_ArrayZeroPos1(Count1,XLength1);                                                                  //Смещение нулевой позиции в циклическом буфере 1
         Recount_ArrayZeroPos2(Count2,std_period1);                                                               //Смещение нулевой позиции в циклическом буфере 2
        }

     }
//---- отображение ценовой метки
   if(ShowPrice)
     {
      int bar0=rates_total-1;
      datetime time0=time[bar0]+1*PeriodSeconds();
      SetRightPrice(0,Price_name,0,time0,ExtLineBuffer[bar0],Price_color);
     }
//---- корректировка значения переменной first
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчета индикатора
      first++; // стартовый номер для расчета всех баров

//---- Основной цикл раскраски сигнальной линии
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      double clr=ColorExtLineBuffer[bar-1];
      trend=ExtLineBuffer[bar]-ExtLineBuffer[bar-1];
      if(trend>0) clr=1;
      if(trend<0) clr=0;
      ColorExtLineBuffer[bar]=clr;
     }
//----    
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  RightPrice creation                                             |
//+------------------------------------------------------------------+
void CreateRightPrice(long chart_id,// chart ID
                      string   name,              // object name
                      int      nwin,              // window index
                      datetime time,              // price level time
                      double   price,             // price level
                      color    Color              // Text color
                      )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,time,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,2);
//----
  }
//+------------------------------------------------------------------+
//|  RightPrice reinstallation                                       |
//+------------------------------------------------------------------+
void SetRightPrice(long chart_id,// chart ID
                   string   name,              // object name
                   int      nwin,              // window index
                   datetime time,              // price level time
                   double   price,             // price level
                   color    Color              // Text color
                   )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateRightPrice(chart_id,name,nwin,time,price,Color);
   else ObjectMove(chart_id,name,0,time,price);
//----
  }
//+------------------------------------------------------------------+
