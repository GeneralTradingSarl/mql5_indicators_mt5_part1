//+---------------------------------------------------------------------+
//|                                     ColorJFatl_Cloud_Digit_Grid.mq5 | 
//|                                  Copyright © 2016, Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Для работы  индикатора  следует  положить файл SmoothAlgorithms.mqh |
//| в папку (директорию): каталог_данных_терминала\\MQL5\Include        |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2016, Nikolay Kositsin"
#property link      "farria@mail.redcom.ru"
#property version   "1.00"

//---- отрисовка индикатора в основном окне
#property indicator_chart_window
//---- количество индикаторных буферов 6
#property indicator_buffers 6 
//---- использовано всего три графических построения
#property indicator_plots   3
//+------------------------------------------------+
//|  Параметры отрисовки фона                      |
//+------------------------------------------------+
//---- отрисовка фона в облачном виде
#property indicator_type1   DRAW_FILLING
#property indicator_type2   DRAW_FILLING
//---- выбор цветов фона
#property indicator_color1  clrPaleTurquoise
#property indicator_color2  clrThistle
//---- отображение меток
#property indicator_label1  "Upper Cloud"
#property indicator_label2  "Lower Cloud"
//+------------------------------------------------+
//|  Параметры отрисовки индикатора                |
//+------------------------------------------------+
//---- отрисовка индикатора в виде многоцветной линии
#property indicator_type3   DRAW_COLOR_LINE
//---- в качестве цветов трехцветной линии использованы
#property indicator_color3  clrMagenta,clrGray,clrGold
//---- линия индикатора - непрерывная кривая
#property indicator_style3  STYLE_SOLID
//---- толщина линии индикатора равна 5
#property indicator_width3  5
//---- отображение метки индикатора
#property indicator_label3  "JFATL"
//+------------------------------------------------+
//|  объявление перечислений                       |
//+------------------------------------------------+
enum Applied_price_ //Тип константы
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPL_,         //PRICE_SIMPL_
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };
//+------------------------------------------------+
//|  объявление перечисления                       |
//+------------------------------------------------+
enum WIDTH
  {
   Width_1=1, //1
   Width_2,   //2
   Width_3,   //3
   Width_4,   //4
   Width_5    //5
  };
//+------------------------------------------------+
//|  объявление перечисления                       |
//+------------------------------------------------+
enum STYLE
  {
   SOLID_,//Сплошная линия
   DASH_,//Штриховая линия
   DOT_,//Пунктирная линия
   DASHDOT_,//Штрих-пунктирная линия
   DASHDOTDOT_   //Штрих-пунктирная линия с двойными точками
  };
//+------------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                  |
//+------------------------------------------------+
input string  SirName="ColorJFatl_Cloud_Digit_Grid";     //Первая часть имени графических объектов
input int JLength=5; // глубина JMA сглаживания                   
input int JPhase=-100; // параметр JMA сглаживания,
//---- изменяющийся в пределах -100 ... +100,
//---- влияет на качество переходного процесса;
input Applied_price_ IPC=PRICE_CLOSE_;//ценовая константа
input int FATLShift=0; // сдвиг Фатла по горизонтали в барах
input int PriceFATLShift=0; // cдвиг Фатла по вертикали в пунктах
input uint Dev=20; // Девиация заливки фоном
input uint Digit=2;                       //количество разрядов округления
input bool ShowPrice=true; //показывать ценовые метки
//---- цвета ценовых меток
input color  Price_color=clrGray;
//---- Параметры ценовой сетки
input uint  Total=200;                       //количество блоков сетки сверху или снизу от цены
//----
input color  Color_A = clrSlateBlue;         //цвет уровня 1 
input STYLE  Style_A = DASHDOTDOT_;          //стиль линии уровня 1
input WIDTH  Width_A = Width_1;              //толщина линии уровня 1
//----
input color  Color_B = clrDarkOrange;        //цвет уровня 2
input STYLE  Style_B = DASH_;                //стиль линии уровня 2
input WIDTH  Width_B = Width_1;              //толщина линии уровня 2
//----
input color  Color_C = clrMagenta;           //цвет уровня 3
input STYLE  Style_C = SOLID_;               //стиль линии уровня 3
input WIDTH  Width_C = Width_1;              //толщина линии уровня 3
//----
input color  Color_D = clrRed;               //цвет уровня 4
input STYLE  Style_D = SOLID_;               //стиль линии уровня 4
input WIDTH  Width_D = Width_1;              //толщина линии уровня 4
//----
input color  Color_E = clrLime;              //цвет уровня 5
input STYLE  Style_E = SOLID_;               //стиль линии уровня 5
input WIDTH  Width_E = Width_1;              //толщина линии уровня 5
//----
input bool ShowLineInfo = true;              //отображение значения уровня на ценовом графике
input int Shift=0; // Сдвиг ценовой сетки по горизонтали в барах
//+------------------------------------------------+

//---- объявление и инициализация переменной для хранения количества расчётных баров
int FATLPeriod=39;
//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double LineBuffer[];
double ColorLineBuffer[];

double UpCloudBuffer1[],UpCloudBuffer2[];
double DnCloudBuffer1[],DnCloudBuffer2[];

//---- Объявление целых переменных начала отсчета данных
int min_rates_total,fstart,FATLSize;
double dPriceFATLShift;
//---- Объявление стрингов для текстовых меток
string Price_name;
//---- Объявление переменных ценовой сетки
color clr;
STYLE Style;
WIDTH Width;
bool ShowPriceLable;
int middle,sizex,Normalize,Count;
string ObjectNames[];
double PointPow10,PointPow100,PointPow1000,PointPow10000,PointPow100000,PriceGrid[],Price[];
//+------------------------------------------------+
//| Инициализация коэффициентов цифрового фильтра  |
//+------------------------------------------------+
double dFATLTable[]=
  {
   +0.4360409450, +0.3658689069, +0.2460452079, +0.1104506886,
   -0.0054034585, -0.0760367731, -0.0933058722, -0.0670110374,
   -0.0190795053, +0.0259609206, +0.0502044896, +0.0477818607,
   +0.0249252327, -0.0047706151, -0.0272432537, -0.0338917071,
   -0.0244141482, -0.0055774838, +0.0128149838, +0.0226522218,
   +0.0208778257, +0.0100299086, -0.0036771622, -0.0136744850,
   -0.0160483392, -0.0108597376, -0.0016060704, +0.0069480557,
   +0.0110573605, +0.0095711419, +0.0040444064, -0.0023824623,
   -0.0067093714, -0.0072003400, -0.0047717710, +0.0005541115,
   +0.0007860160, +0.0130129076, +0.0040364019
  };
//+------------------------------------------------------------------+
// Описание функции iPriceSeries()                                   |
// Описание функции iPriceSeriesAlert()                              |
// Описание класса CJJMA                                             |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh>  
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных 
   FATLSize=ArraySize(dFATLTable);
   min_rates_total=FATLSize+30;
   //---- Инициализация сдвига по вертикали
   dPriceFATLShift=_Point*PriceFATLShift;
//---- Инициализация стрингов
   Price_name=SirName+"Price";
//---- распределение памяти под массивы переменных ценовой сетки 
   sizex=int(Total*2);
   ArrayResize(ObjectNames,sizex);
   ArrayResize(PriceGrid,sizex);
   ArrayResize(Price,sizex);
//---- инициализация имён
   for(Count=0; Count<sizex; Count++) ObjectNames[Count]=SirName+" PriceLine "+string(Count);
//---- инициализация переменных         
   PointPow10=_Point*MathPow(10,Digit);
   PointPow100=PointPow10*10;
   PointPow1000=PointPow10*100;
   PointPow10000=PointPow10*1000;
   PointPow100000=PointPow10*10000;
   middle=(sizex/2)-1;
   Normalize=int(_Digits-Digit);
//---- инициализация переменных         
   for(Count=middle; Count<sizex; Count++) PriceGrid[Count]=+NormalizeDouble(PointPow10*(Count-middle),Normalize);
   for(Count=middle-1; Count>=0; Count--) PriceGrid[Count]=-NormalizeDouble(PointPow10*(middle-Count),Normalize);
//---- инициализации переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"JFatl_Cloud_Digi_Grid(",JLength," ,",JPhase,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- Инициализация сдвига по вертикали
   dPriceFATLShift=_Point*PriceFATLShift; 
//---- превращение динамического массива в индикаторный буфер   
   SetIndexBuffer(0,UpCloudBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,UpCloudBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,DnCloudBuffer1,INDICATOR_DATA);
   SetIndexBuffer(3,DnCloudBuffer2,INDICATOR_DATA);
   SetIndexBuffer(4,LineBuffer,INDICATOR_DATA);
//---- превращение динамического массива в цветовой, индексный буфер   
   SetIndexBuffer(5,ColorLineBuffer,INDICATOR_COLOR_INDEX);
   
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,FATLShift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   
//---- осуществление сдвига индикатора 2 по горизонтали
   PlotIndexSetInteger(1,PLOT_SHIFT,FATLShift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   
//---- осуществление сдвига индикатора 3 по горизонтали
   PlotIndexSetInteger(2,PLOT_SHIFT,FATLShift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0.0);
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,Price_name);
   for(Count=0; Count<sizex; Count++) ObjectDelete(0,ObjectNames[Count]);
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   ArraySetAsSeries(close,false);
   ArraySetAsSeries(time,false);
double res=NormalizeDouble(PointPow10*MathCeil(close[rates_total-1]/PointPow10),Normalize);
   if(prev_calculated!=rates_total)
     {
      for(Count=0; Count<sizex; Count++) ObjectDelete(0,ObjectNames[Count]);
     }
   for(Count=0; Count<sizex; Count++) Price[Count]=NormalizeDouble(res+PriceGrid[Count],Normalize);
   datetime time0=time[rates_total-1]+PeriodSeconds()*Shift;
   datetime timeX=time[0];
   for(Count=0; Count<sizex; Count++)
     {
      string info="";
      if(ShowLineInfo) info=ObjectNames[Count]+" "+DoubleToString(Price[Count],Normalize);
      
      if(!NormalizeDouble(Price[Count]-PointPow100000*MathCeil(Price[Count]/PointPow100000),Normalize))
        {
         SetTline(0,ObjectNames[Count],0,timeX,Price[Count],time0,Price[Count],Color_E,Style_E,Width_E,info);
        }
      else if(!NormalizeDouble(Price[Count]-PointPow10000*MathCeil(Price[Count]/PointPow10000),Normalize))
        {
         SetTline(0,ObjectNames[Count],0,timeX,Price[Count],time0,Price[Count],Color_D,Style_D,Width_D,info);
        }
      else if(!NormalizeDouble(Price[Count]-PointPow1000*MathCeil(Price[Count]/PointPow1000),Normalize))
        {
         SetTline(0,ObjectNames[Count],0,timeX,Price[Count],time0,Price[Count],Color_C,Style_C,Width_C,info);
        }
      else  if(!NormalizeDouble(Price[Count]-PointPow100*MathCeil(Price[Count]/PointPow100),Normalize))
        {
         SetTline(0,ObjectNames[Count],0,timeX,Price[Count],time0,Price[Count],Color_B,Style_B,Width_B,info);
        }
      else
        {
         SetTline(0,ObjectNames[Count],0,timeX,Price[Count],time0,Price[Count],Color_A,Style_A,Width_A,info);
        }
     }

//---- индексация элементов в массивах не как в таймсериях
   ArraySetAsSeries(close,false);
   ArraySetAsSeries(time,false);

//---- объявления локальных переменных 
   int first,bar;
   double jfatl,FATL;

//---- расчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
     {
      first=FATLPeriod-1; // стартовый номер для расчёта всех баров
      fstart=first;
     }
   else first=prev_calculated-1; // стартовый номер для расчёта новых баров

//---- объявление переменной класса CJJMA из файла JJMASeries_Cls.mqh
   static CJJMA JMA;

//---- основной цикл расчёта индикатора
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- формула для фильтра FATL
      FATL=0.0;
      for(int iii=0; iii<FATLSize; iii++) FATL+=dFATLTable[iii]*PriceSeries(IPC,bar-iii,open,low,high,close);
      jfatl=JMA.JJMASeries(fstart,prev_calculated,rates_total,0,JPhase,JLength,FATL,bar,false);
      LineBuffer[bar]=jfatl+dPriceFATLShift;  
      LineBuffer[bar]=UpCloudBuffer2[bar]=DnCloudBuffer1[bar]=PointPow10*MathRound(LineBuffer[bar]/PointPow10);   
      UpCloudBuffer1[bar]=LineBuffer[bar]*Dev;
      DnCloudBuffer2[bar]=LineBuffer[bar]/Dev;
     }
   if(ShowPrice)
     {
      int bar0=rates_total-1;
      time0=time[bar0]+1*PeriodSeconds();
      SetRightPrice(0,Price_name,0,time0,LineBuffer[bar0],Price_color);
     }

//---- пересчёт стартового номера first для цикла пересчёта баров
   if(prev_calculated>rates_total || prev_calculated<=0) // проверка на первый старт расчёта индикатора
      first++;
//---- Основной цикл раскраски сигнальной линии
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      double Clr=1;
      double trend=LineBuffer[bar]-LineBuffer[bar-1];
      if(!trend) Clr=ColorLineBuffer[bar-1];
      else
        {
         if(trend>0) Clr=2;
         if(trend<0) Clr=0;
        }
      ColorLineBuffer[bar]=Clr;
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
//|  Создание трендовой линии                                        |
//+------------------------------------------------------------------+
void CreateTline(
                 long     chart_id,      // идентификатор графика
                 string   name,          // имя объекта
                 int      nwin,          // индекс окна
                 datetime time1,         // время 1 ценового уровня
                 double   price1,        // 1 ценовой уровень
                 datetime time2,         // время 2 ценового уровня
                 double   price2,        // 2 ценовой уровень
                 color    Color,         // цвет линии
                 int      style,         // стиль линии
                 int      width,         // толщина линии
                 string   text           // текст
                 )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_TREND,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,true);
//----
  }
//+------------------------------------------------------------------+
//|  Переустановка трендовой линии                                   |
//+------------------------------------------------------------------+
void SetTline(
              long     chart_id,      // идентификатор графика
              string   name,          // имя объекта
              int      nwin,          // индекс окна
              datetime time1,         // время 1 ценового уровня
              double   price1,        // 1 ценовой уровень
              datetime time2,         // время 2 ценового уровня
              double   price2,        // 2 ценовой уровень
              color    Color,         // цвет линии
              int      style,         // стиль линии
              int      width,         // толщина линии
              string   text           // текст
              )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateTline(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,text);
   else
     {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
      ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
      ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
     }
//----
  }
//+------------------------------------------------------------------+
