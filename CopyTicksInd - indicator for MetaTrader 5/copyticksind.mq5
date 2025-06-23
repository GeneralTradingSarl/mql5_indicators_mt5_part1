//+------------------------------------------------------------------+
//|                                                 CopyTicksInd.mq5 |
//|                              Copyright © 2015, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.442"
#property description "Indicator for comparing the three modes of receiving ticks"
#property description "Индикатор для сравнения трёх режимов получения тиков"
#property indicator_plots 0
#property indicator_chart_window
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum  ENUM_COPY_TICKS
  {
   TICKS_INFO=1,     // only/только Bid и Ask 
   TICKS_TRADE=2,    // only/только Last и Volume
   TICKS_ALL=-1,     // all ticks/все тики
  };
//--- input parameters
input int               ticks=30;       // number of requested tics/количество запрашиваемых тиков
//--- parameters
input ENUM_COPY_TICKS   type=TICKS_ALL;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   Print(TICK_FLAG_BID," - tick has changed a Bid price/тик изменил цену бид");
   Print(TICK_FLAG_ASK,"  - a tick has changed an Ask price/тик изменил цену аск");
   Print(TICK_FLAG_LAST," - a tick has changed the last deal price/тик изменил цену последней сделки");
   Print(TICK_FLAG_VOLUME," - a tick has changed a volume/тик изменил объем");
   Print(TICK_FLAG_BUY," - a tick is a result of a buy deal/тик возник в результате сделки на покупку");
   Print(TICK_FLAG_SELL," - a tick is a result of a sell deal/тик возник в результате сделки на продажу");
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//--- the array that receives ticks/массив для приема тиков
   MqlTick tick_array[];
//--- requesting ticks/запросим тики
   int copied=CopyTicks(_Symbol,tick_array,type,0,ticks);
//--- if ticks are received, show the Bid and Ask values on the chart
//--- если тики получены, то выведем на график значения Bid и Ask  
   if(copied>0)
     {
      string comment=EnumToString(type)+" ,requested "+IntegerToString(ticks)+
                     ", copied "+IntegerToString(copied)+"\r\n";
      comment+="#      Time         Bid        Ask       Last    Volume            time_msc            flags\r\n";
      //--- generate the comment contents /сформируем содержимое комментария 
      int j=copied;
      if(ticks>42 && copied>42)
         j=42;
      string flags="";
      for(int i=copied-1;i>copied-1-j;i--)
        {
         MqlTick tick=tick_array[i];
         flags="";
         if((tick.flags  &TICK_FLAG_BID)==TICK_FLAG_BID)
            flags=" TICK_FLAG_BID ";
         if((tick.flags  &TICK_FLAG_ASK)==TICK_FLAG_ASK)
            flags+=" TICK_FLAG_ASK ";
         if((tick.flags  &TICK_FLAG_LAST)==TICK_FLAG_LAST)
            flags+=" TICK_FLAG_LAST ";
         if((tick.flags  &TICK_FLAG_VOLUME)==TICK_FLAG_VOLUME)
            flags+=" TICK_FLAG_VOLUME ";
         if((tick.flags  &TICK_FLAG_BUY)==TICK_FLAG_BUY)
            flags+=" TICK_FLAG_BUY ";
         if((tick.flags  &TICK_FLAG_SELL)==TICK_FLAG_SELL)
            flags+=" TICK_FLAG_SELL ";
         //string tick_string=StringFormat("%-4d: %-10s  %-10.6G  %-10.6G  %-10.6G  %-4.7d  %-4I64d  %-4.2d",
         //                                i,
         //                                TimeToString(tick.time,TIME_MINUTES|TIME_SECONDS),
         //                                tick.bid,tick.ask,tick.last,tick.volume,tick.time_msc,tick.flags);
         string tick_string=IntegerToString(i,2,'0')+"  "+TimeToString(tick.time,TIME_MINUTES|TIME_SECONDS)+"  "+
                            DoubleToString(tick.bid,Digits())+"  "+DoubleToString(tick.ask,Digits())+"  "+
                            DoubleToString(tick.last,Digits())+"  "+IntegerToString(tick.volume,7,'0')+"  "+
                            IntegerToString(tick.time_msc,19,'0')+"  "+IntegerToString(tick.flags,2,'0');
         tick_string+=flags;
         comment=comment+tick_string+"\r\n";
        }
      //--- show a comment on the chart/выводим комментарий на график        
      Comment(comment);
     }
   else // report an error that occurred when receiving ticks/сообщим об ошибке при получении тиков
     {
      Comment("Ticks could not be loaded/Не удалось загрузить тики. GetLastError()=",GetLastError());
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Indicator  deinitialization function                             |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- 
   Comment("");
  }
//+------------------------------------------------------------------+
