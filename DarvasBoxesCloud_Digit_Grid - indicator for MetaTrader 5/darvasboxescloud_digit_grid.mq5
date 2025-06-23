//+------------------------------------------------------------------+
//|                                  DarvasBoxesCloud_Digit_Grid.mq5 |
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
//|  объявление перечисления                     |
//+----------------------------------------------+  
enum WIDTH
  {
   Width_1=1, //1
   Width_2,   //2
   Width_3,   //3
   Width_4,   //4
   Width_5    //5
  };
//+----------------------------------------------+
//|  объявление перечисления                     |
//+----------------------------------------------+
enum STYLE
  {
   SOLID_,//Сплошная линия
   DASH_,//Штриховая линия
   DOT_,//Пунктирная линия
   DASHDOT_,//Штрих-пунктирная линия
   DASHDOTDOT_   //Штрих-пунктирная линия с двойными точками
  };
//+----------------------------------------------+
//|  ВХОДНЫЕ ПАРАМЕТРЫ ИНДИКАТОРА                |
//+----------------------------------------------+
input string  SirName="DarvasBoxes_Digit_Grid";     //Первая часть имени графических объектов
input bool symmetry=true;
input int Shift = 0; // сдвиг индикатора по горизонтали в барах
input uint Digit=2; //количество разрядов округления
input bool RoundPrice=true; //округлять цены
input bool ShowPrice=true; //показывать ценовые метки
//---- цвета ценовых меток
input color  Middle_color=clrGray;
input color  Upper_color=clrBlue;
input color  Lower_color=clrMagenta;
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
input uint Fontsizex= 2;                     //размер ценовых меток
input bool ShowLineInfo = true;              //отображение значения уровня на ценовом графике
//+----------------------------------------------+
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
//---- Объявление стрингов для текстовых меток
string upper_name,middle_name,lower_name;
//---- Объявление переменных ценовой сетки
color clr;
STYLE Style;
WIDTH Width;
bool ShowPriceLable;
int middle,sizex,Normalize,Count;
string ObjectNames[];
double PointPow10,PointPow100,PointPow1000,PointPow10000,PointPow100000,PriceGrid[],Price[];
//+------------------------------------------------------------------+    
//| Donchian Channel indicator initialization function               | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=2;
//---- Инициализация стрингов
   upper_name=SirName+" upper text lable";
   middle_name=SirName+" middle text lable";
   lower_name=SirName+" lower text lable";

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
   IndicatorSetString(INDICATOR_SHORTNAME,"DarvasBoxes_Digit_Grid");
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
   ObjectDelete(0,upper_name);
   ObjectDelete(0,middle_name);
   ObjectDelete(0,lower_name);
   for(Count=0; Count<sizex; Count++) ObjectDelete(0,ObjectNames[Count]);
//----
   ChartRedraw(0);
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
   
//---- индексация элементов в массивах не как в таймсериях
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
     
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);

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
      state++;
      if(RoundPrice)
        {
         ExtBBuffer[bar]=PointPow10*MathRound(ExtBBuffer[bar]/PointPow10);
         ExtABuffer[bar]=PointPow10*MathCeil(ExtABuffer[bar]/PointPow10);
         ExtCBuffer[bar]=PointPow10*MathFloor(ExtCBuffer[bar]/PointPow10);
        }
      ExtUp1Buffer[bar]=ExtABuffer[bar];
      ExtUp2Buffer[bar]=ExtBBuffer[bar];
      ExtDn1Buffer[bar]=ExtBBuffer[bar];
      ExtDn2Buffer[bar]=ExtCBuffer[bar];
      
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(bar==1)
        {
         STATE=state;
         BOX_TOP=box_top;
         BOX_BUTTOM=box_bottom;
        }
     }
     
  if(ShowPrice)
     {
      int bar0=0;
      time0=time[bar0]+Shift*PeriodSeconds();
      SetRightPrice(0,middle_name,0,time0,ExtBBuffer[bar0],Middle_color,"Georgia");
      SetRightPrice(0,upper_name,0,time0,ExtABuffer[bar0],Upper_color,"Georgia");
      SetRightPrice(0,lower_name,0,time0,ExtCBuffer[bar0],Lower_color,"Georgia");
     }

//----
   ChartRedraw(0);  
   return(rates_total);
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
//|  RightPrice creation                                             |
//+------------------------------------------------------------------+
void CreateRightPrice(long chart_id,// chart ID
                      string   name,              // object name
                      int      nwin,              // window index
                      datetime time,              // price level time
                      double   price,             // price level
                      color    Color,             // Text color
                      string   Font               // Text font
                      )
//---- 
  {
//----
   ObjectCreate(chart_id,name,OBJ_ARROW_RIGHT_PRICE,nwin,time,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
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
                   color    Color,             // Text color
                   string   Font               // Text font
                   )
//---- 
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateRightPrice(chart_id,name,nwin,time,price,Color,Font);
   else ObjectMove(chart_id,name,0,time,price);
//----
  }
//+------------------------------------------------------------------+
